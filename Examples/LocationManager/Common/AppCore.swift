import ComposableArchitecture
import ComposableCoreLocation
import MapKit

public struct PointOfInterest: Equatable, Hashable, Sendable {
  public let coordinate: Coordinate
  public let subtitle: String?
  public let title: String?

  public init(
    coordinate: Coordinate,
    subtitle: String?,
    title: String?
  ) {
    self.coordinate = coordinate
    self.subtitle = subtitle
    self.title = title
  }
}

public enum PointOfInterestCategory: String, CaseIterable, Equatable, Hashable, Identifiable,
  Sendable
{
  case cafe
  case museum
  case nightlife
  case park
  case restaurant

  public var id: Self { self }

  public var displayName: String {
    switch self {
    case .cafe:
      "Cafe"
    case .museum:
      "Museum"
    case .nightlife:
      "Nightlife"
    case .park:
      "Park"
    case .restaurant:
      "Restaurant"
    }
  }

  var mapKitCategory: MKPointOfInterestCategory {
    switch self {
    case .cafe:
      .cafe
    case .museum:
      .museum
    case .nightlife:
      .nightlife
    case .park:
      .park
    case .restaurant:
      .restaurant
    }
  }
}

@Reducer
public struct AppFeature {
  @ObservableState
  public struct State: Equatable {
    @Presents public var alert: AlertState<Action.Alert>?
    public var isRequestingCurrentLocation = false
    public var pointOfInterestCategory: PointOfInterestCategory?
    public var pointsOfInterest: [PointOfInterest] = []
    public var region: CoordinateRegion?

    public init(
      alert: AlertState<Action.Alert>? = nil,
      isRequestingCurrentLocation: Bool = false,
      pointOfInterestCategory: PointOfInterestCategory? = nil,
      pointsOfInterest: [PointOfInterest] = [],
      region: CoordinateRegion? = nil
    ) {
      self.alert = alert
      self.isRequestingCurrentLocation = isRequestingCurrentLocation
      self.pointOfInterestCategory = pointOfInterestCategory
      self.pointsOfInterest = pointsOfInterest
      self.region = region
    }
  }

  public enum Action: Equatable, Sendable {
    public enum Alert: Equatable, Sendable {}

    public enum View: Equatable, Sendable {
      case categoryButtonTapped(PointOfInterestCategory)
      case currentLocationButtonTapped
      case regionChanged(CoordinateRegion?)
      case runLocationManager
    }

    public enum CurrentLocationPermissionStatus: Equatable, Sendable {
      case authorized
      case denied
      case notDetermined
      case restricted
      case servicesDisabled
    }

    case alert(PresentationAction<Alert>)
    case currentLocationPermissionStatus(CurrentLocationPermissionStatus)
    case localSearchResponse(Result<LocalSearchResponse, LocalSearchClient.Error>)
    case locationManager(LocationManager.Action)
    case view(View)
  }

  @Dependency(\.localSearch) private var localSearch
  @Dependency(\.locationManager) private var locationManager

  public init() {}

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .view(.categoryButtonTapped(let category)):
        guard category != state.pointOfInterestCategory else {
          state.pointOfInterestCategory = nil
          state.pointsOfInterest = []
          return .cancel(id: CancelID.search)
        }

        state.pointOfInterestCategory = category
        return search(category: category, region: state.region)

      case .view(.currentLocationButtonTapped):
        let authorizationStatus = locationManager.authorizationStatus
        let locationServicesEnabled = locationManager.locationServicesEnabled
        return .run { send in
          guard await locationServicesEnabled() else {
            await send(.currentLocationPermissionStatus(.servicesDisabled))
            return
          }

          switch await authorizationStatus() {
          case .notDetermined:
            await send(.currentLocationPermissionStatus(.notDetermined))

          case .restricted:
            await send(.currentLocationPermissionStatus(.restricted))

          case .denied:
            await send(.currentLocationPermissionStatus(.denied))

          case .authorizedAlways, .authorizedWhenInUse:
            await send(.currentLocationPermissionStatus(.authorized))

          @unknown default:
            await send(.currentLocationPermissionStatus(.denied))
          }
        }

      case .view(.regionChanged(let region)):
        state.region = region

        guard let category = state.pointOfInterestCategory else {
          return .none
        }
        return search(category: category, region: region)

      case .view(.runLocationManager):
        let delegate = locationManager.delegate
        return .run { send in
          for await action in await delegate() {
            await send(.locationManager(action))
          }
        }

      case .currentLocationPermissionStatus(.authorized):
        let requestLocation = locationManager.requestLocation
        return .run { _ in
          await requestLocation()
        }

      case .currentLocationPermissionStatus(.notDetermined):
        state.isRequestingCurrentLocation = true
        #if os(macOS)
          let requestAlwaysAuthorization = locationManager.requestAlwaysAuthorization
          return .run { _ in
            await requestAlwaysAuthorization()
          }
        #else
          let requestWhenInUseAuthorization = locationManager.requestWhenInUseAuthorization
          return .run { _ in
            await requestWhenInUseAuthorization()
          }
        #endif

      case .currentLocationPermissionStatus(.denied),
        .currentLocationPermissionStatus(.restricted):
        state.isRequestingCurrentLocation = false
        state.alert = AlertState {
          TextState("Please give us access to your location in settings.")
        }
        return .none

      case .currentLocationPermissionStatus(.servicesDisabled):
        state.isRequestingCurrentLocation = false
        state.alert = AlertState {
          TextState("Location services are turned off.")
        }
        return .none

      case .localSearchResponse(.success(let response)):
        state.pointsOfInterest = response.pointsOfInterest
        return .none

      case .localSearchResponse(.failure):
        state.alert = AlertState {
          TextState("Could not perform search. Please try again.")
        }
        return .none

      case .locationManager(.didChangeAuthorization(.authorizedAlways)),
        .locationManager(.didChangeAuthorization(.authorizedWhenInUse)):
        guard state.isRequestingCurrentLocation else {
          return .none
        }
        let requestLocation = locationManager.requestLocation
        return .run { _ in
          await requestLocation()
        }

      case .locationManager(.didChangeAuthorization(.denied)):
        guard state.isRequestingCurrentLocation else {
          return .none
        }
        state.alert = AlertState {
          TextState("Location makes this app better. Please consider giving us access.")
        }
        state.isRequestingCurrentLocation = false
        return .none

      case .locationManager(.didUpdateLocations(let locations)):
        state.isRequestingCurrentLocation = false
        guard let location = locations.first else {
          return .none
        }
        state.region = CoordinateRegion(
          center: Coordinate(location.coordinate),
          span: CoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
        return .none

      case .alert, .locationManager:
        return .none
      }
    }
    .ifLet(\.$alert, action: \.alert)
  }

  private func search(
    category: PointOfInterestCategory,
    region: CoordinateRegion?
  ) -> Effect<Action> {
    let search = localSearch.search
    return .run { [request = LocalSearchRequest(category: category, region: region)] send in
      do {
        await send(.localSearchResponse(.success(try await search(request))))
      } catch {
        await send(.localSearchResponse(.failure(LocalSearchClient.Error())))
      }
    }
    .cancellable(id: CancelID.search, cancelInFlight: true)
  }

  private enum CancelID {
    case search
  }
}
