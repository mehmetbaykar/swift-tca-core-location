import ComposableArchitecture
import ComposableCoreLocation
import CoreLocation
import Foundation
import Testing

@testable import LocationManagerFeature

@MainActor
@Suite
struct LocationManagerTests {
  @Test
  func requestLocationAllow() async {
    let (stream, continuation) = AsyncStream.makeStream(of: LocationManager.Action.self)
    let recorder = RequestRecorder()
    let currentLocation = Location(
      altitude: 0,
      coordinate: CLLocationCoordinate2D(latitude: 10, longitude: 20),
      course: 0,
      horizontalAccuracy: 0,
      speed: 0,
      timestamp: Date(timeIntervalSince1970: 1_234_567_890),
      verticalAccuracy: 0
    )

    let store = TestStore(initialState: AppFeature.State()) {
      AppFeature()
    } withDependencies: {
      $0.localSearch = .failing
      $0.locationManager = LocationManager.test(
        authorizationStatus: { .notDetermined },
        delegate: { stream },
        locationServicesEnabled: { true },
        recorder: recorder
      )
    }

    let task = await store.send(.view(.runLocationManager))

    await store.send(.view(.currentLocationButtonTapped))
    await store.receive(.currentLocationPermissionStatus(.notDetermined)) {
      $0.isRequestingCurrentLocation = true
    }
    #expect(recorder.didRequestAuthorization)

    continuation.yield(.didChangeAuthorization(.authorizedAlways))
    await store.receive(.locationManager(.didChangeAuthorization(.authorizedAlways)))
    #expect(recorder.didRequestLocation)

    continuation.yield(.didUpdateLocations([currentLocation]))
    await store.receive(.locationManager(.didUpdateLocations([currentLocation]))) {
      $0.isRequestingCurrentLocation = false
      $0.region = CoordinateRegion(
        center: Coordinate(latitude: 10, longitude: 20),
        span: CoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
      )
    }

    continuation.finish()
    await task.cancel()
  }

  @Test
  func requestLocationDeny() async {
    let (stream, continuation) = AsyncStream.makeStream(of: LocationManager.Action.self)
    let recorder = RequestRecorder()

    let store = TestStore(initialState: AppFeature.State()) {
      AppFeature()
    } withDependencies: {
      $0.localSearch = .failing
      $0.locationManager = LocationManager.test(
        authorizationStatus: { .notDetermined },
        delegate: { stream },
        locationServicesEnabled: { true },
        recorder: recorder
      )
    }

    let task = await store.send(.view(.runLocationManager))

    await store.send(.view(.currentLocationButtonTapped))
    await store.receive(.currentLocationPermissionStatus(.notDetermined)) {
      $0.isRequestingCurrentLocation = true
    }
    #expect(recorder.didRequestAuthorization)

    continuation.yield(.didChangeAuthorization(.denied))
    await store.receive(.locationManager(.didChangeAuthorization(.denied))) {
      $0.alert = AlertState {
        TextState("Location makes this app better. Please consider giving us access.")
      }
      $0.isRequestingCurrentLocation = false
    }

    continuation.finish()
    await task.cancel()
  }

  @Test
  func searchPointsOfInterestTapCategory() async {
    let pointOfInterest = PointOfInterest(
      coordinate: Coordinate(latitude: 0, longitude: 0),
      subtitle: nil,
      title: "Blob's Cafe"
    )
    let response = LocalSearchResponse(pointsOfInterest: [pointOfInterest])

    let store = TestStore(initialState: AppFeature.State()) {
      AppFeature()
    } withDependencies: {
      $0.localSearch = LocalSearchClient(search: { _ in response })
      $0.locationManager = .failing
    }

    await store.send(.view(.categoryButtonTapped(.cafe))) {
      $0.pointOfInterestCategory = .cafe
    }
    await store.receive(.localSearchResponse(.success(response))) {
      $0.pointsOfInterest = [pointOfInterest]
    }
  }

  @Test
  func searchPointsOfInterestPanMap() async {
    let pointOfInterest = PointOfInterest(
      coordinate: Coordinate(latitude: 0, longitude: 0),
      subtitle: nil,
      title: "Blob's Cafe"
    )
    let response = LocalSearchResponse(pointsOfInterest: [pointOfInterest])
    let coordinateRegion = CoordinateRegion(
      center: Coordinate(latitude: 10, longitude: 20),
      span: CoordinateSpan(latitudeDelta: 1, longitudeDelta: 2)
    )

    let store = TestStore(
      initialState: AppFeature.State(pointOfInterestCategory: .cafe)
    ) {
      AppFeature()
    } withDependencies: {
      $0.localSearch = LocalSearchClient(search: { _ in response })
      $0.locationManager = .failing
    }

    await store.send(.view(.regionChanged(coordinateRegion))) {
      $0.region = coordinateRegion
    }
    await store.receive(.localSearchResponse(.success(response))) {
      $0.pointsOfInterest = [pointOfInterest]
    }
  }
}

@MainActor
private final class RequestRecorder: @unchecked Sendable {
  var didRequestAuthorization = false
  var didRequestLocation = false
}

extension LocationManager {
  @MainActor
  fileprivate static func test(
    authorizationStatus: @escaping @MainActor @Sendable () -> CLAuthorizationStatus,
    delegate: @escaping @MainActor @Sendable () -> AsyncStream<Action>,
    locationServicesEnabled: @escaping @MainActor @Sendable () -> Bool,
    recorder: RequestRecorder
  ) -> Self {
    var manager = Self.failing
    manager.authorizationStatus = authorizationStatus
    manager.delegate = delegate
    manager.locationServicesEnabled = locationServicesEnabled
    manager.requestAlwaysAuthorization = {
      recorder.didRequestAuthorization = true
    }
    manager.requestLocation = {
      recorder.didRequestLocation = true
    }
    manager.requestWhenInUseAuthorization = {
      recorder.didRequestAuthorization = true
    }
    return manager
  }
}
