import ComposableArchitecture
import CoreLocation

/// A testable wrapper around `CLLocationManager` for TCA features.
///
/// Access it from reducers with `@Dependency(\.locationManager)`. Long-lived delegate callbacks are
/// exposed as an `AsyncStream`, and imperative Core Location commands are modeled as async closures.
public struct LocationManager: Sendable {
  /// Actions that correspond to `CLLocationManagerDelegate` methods.
  ///
  /// See `CLLocationManagerDelegate` for more information.
  public enum Action: Equatable, @unchecked Sendable {
    case didChangeAuthorization(CLAuthorizationStatus)

    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    case didDetermineState(CLRegionState, region: Region)

    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    case didEnterRegion(Region)

    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    case didExitRegion(Region)

    @available(macOS, unavailable)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    case didFailRanging(beaconConstraint: CLBeaconIdentityConstraint, error: Error)

    case didFailWithError(Error)

    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    case didFinishDeferredUpdatesWithError(Error?)

    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    case didPauseLocationUpdates

    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    case didResumeLocationUpdates

    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    case didStartMonitoring(region: Region)

    @available(macOS, unavailable)
    @available(tvOS, unavailable)
    case didUpdateHeading(newHeading: Heading)

    case didUpdateLocations([Location])

    @available(macCatalyst, deprecated: 13)
    @available(tvOS, unavailable)
    case didUpdateTo(newLocation: Location, oldLocation: Location)

    @available(macOS, unavailable)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    case didVisit(Visit)

    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    case monitoringDidFail(region: Region?, error: Error)

    @available(macOS, unavailable)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    case didRangeBeacons([Beacon], satisfyingConstraint: CLBeaconIdentityConstraint)
  }

  public struct Error: Swift.Error, Equatable, @unchecked Sendable {
    public let error: NSError

    public init(_ error: Swift.Error) {
      self.error = error as NSError
    }
  }

  public var accuracyAuthorization: @MainActor @Sendable () -> AccuracyAuthorization?

  public var authorizationStatus: @MainActor @Sendable () -> CLAuthorizationStatus

  public var delegate: @MainActor @Sendable () -> AsyncStream<Action>

  public var dismissHeadingCalibrationDisplay: @MainActor @Sendable () async -> Void

  public var heading: @MainActor @Sendable () -> Heading?

  public var headingAvailable: @MainActor @Sendable () -> Bool

  public var isRangingAvailable: @MainActor @Sendable () -> Bool

  public var location: @MainActor @Sendable () -> Location?

  public var locationServicesEnabled: @MainActor @Sendable () -> Bool

  public var maximumRegionMonitoringDistance: @MainActor @Sendable () -> CLLocationDistance

  public var monitoredRegions: @MainActor @Sendable () -> Set<Region>

  public var requestAlwaysAuthorization: @MainActor @Sendable () async -> Void

  public var requestLocation: @MainActor @Sendable () async -> Void

  public var requestWhenInUseAuthorization: @MainActor @Sendable () async -> Void

  public var requestTemporaryFullAccuracyAuthorization:
    @MainActor @Sendable (String) async throws -> Void

  public var set: @MainActor @Sendable (Properties) async -> Void

  public var significantLocationChangeMonitoringAvailable: @MainActor @Sendable () -> Bool

  public var startMonitoringForRegion: @MainActor @Sendable (Region) async -> Void

  public var startMonitoringSignificantLocationChanges: @MainActor @Sendable () async -> Void

  public var startMonitoringVisits: @MainActor @Sendable () async -> Void

  public var startUpdatingHeading: @MainActor @Sendable () async -> Void

  public var startUpdatingLocation: @MainActor @Sendable () async -> Void

  public var stopMonitoringForRegion: @MainActor @Sendable (Region) async -> Void

  public var stopMonitoringSignificantLocationChanges: @MainActor @Sendable () async -> Void

  public var stopMonitoringVisits: @MainActor @Sendable () async -> Void

  public var stopUpdatingHeading: @MainActor @Sendable () async -> Void

  public var stopUpdatingLocation: @MainActor @Sendable () async -> Void

  /// Updates the configurable properties of the live `CLLocationManager`.
  public func set(
    activityType: CLActivityType? = nil,
    allowsBackgroundLocationUpdates: Bool? = nil,
    desiredAccuracy: CLLocationAccuracy? = nil,
    distanceFilter: CLLocationDistance? = nil,
    headingFilter: CLLocationDegrees? = nil,
    headingOrientation: CLDeviceOrientation? = nil,
    pausesLocationUpdatesAutomatically: Bool? = nil,
    showsBackgroundLocationIndicator: Bool? = nil
  ) async {
    #if os(macOS) || os(tvOS) || os(watchOS)
      return
    #else
      await self.set(
        Properties(
          activityType: activityType,
          allowsBackgroundLocationUpdates: allowsBackgroundLocationUpdates,
          desiredAccuracy: desiredAccuracy,
          distanceFilter: distanceFilter,
          headingFilter: headingFilter,
          headingOrientation: headingOrientation,
          pausesLocationUpdatesAutomatically: pausesLocationUpdatesAutomatically,
          showsBackgroundLocationIndicator: showsBackgroundLocationIndicator
        )
      )
    #endif
  }
}

extension LocationManager {
  public struct Properties: Equatable, Sendable {
    var activityType: CLActivityType? = nil

    var allowsBackgroundLocationUpdates: Bool? = nil

    var desiredAccuracy: CLLocationAccuracy? = nil

    var distanceFilter: CLLocationDistance? = nil

    var headingFilter: CLLocationDegrees? = nil

    var headingOrientation: CLDeviceOrientation? = nil

    var pausesLocationUpdatesAutomatically: Bool? = nil

    var showsBackgroundLocationIndicator: Bool? = nil

    public static func == (lhs: Self, rhs: Self) -> Bool {
      var isEqual = true
      #if os(iOS) || targetEnvironment(macCatalyst) || os(watchOS)
        isEqual =
          isEqual
          && lhs.activityType == rhs.activityType
          && lhs.allowsBackgroundLocationUpdates == rhs.allowsBackgroundLocationUpdates
      #endif
      isEqual =
        isEqual
        && lhs.desiredAccuracy == rhs.desiredAccuracy
        && lhs.distanceFilter == rhs.distanceFilter
      #if os(iOS) || targetEnvironment(macCatalyst) || os(watchOS)
        isEqual =
          isEqual
          && lhs.headingFilter == rhs.headingFilter
          && lhs.headingOrientation == rhs.headingOrientation
      #endif
      #if os(iOS) || targetEnvironment(macCatalyst)
        isEqual =
          isEqual
          && lhs.pausesLocationUpdatesAutomatically == rhs.pausesLocationUpdatesAutomatically
          && lhs.showsBackgroundLocationIndicator == rhs.showsBackgroundLocationIndicator
      #endif
      return isEqual
    }

    @available(macOS, unavailable)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    public init(
      activityType: CLActivityType? = nil,
      allowsBackgroundLocationUpdates: Bool? = nil,
      desiredAccuracy: CLLocationAccuracy? = nil,
      distanceFilter: CLLocationDistance? = nil,
      headingFilter: CLLocationDegrees? = nil,
      headingOrientation: CLDeviceOrientation? = nil,
      pausesLocationUpdatesAutomatically: Bool? = nil,
      showsBackgroundLocationIndicator: Bool? = nil
    ) {
      self.activityType = activityType
      self.allowsBackgroundLocationUpdates = allowsBackgroundLocationUpdates
      self.desiredAccuracy = desiredAccuracy
      self.distanceFilter = distanceFilter
      self.headingFilter = headingFilter
      self.headingOrientation = headingOrientation
      self.pausesLocationUpdatesAutomatically = pausesLocationUpdatesAutomatically
      self.showsBackgroundLocationIndicator = showsBackgroundLocationIndicator
    }

    @available(iOS, unavailable)
    @available(macCatalyst, unavailable)
    @available(watchOS, unavailable)
    public init(
      desiredAccuracy: CLLocationAccuracy? = nil,
      distanceFilter: CLLocationDistance? = nil
    ) {
      self.desiredAccuracy = desiredAccuracy
      self.distanceFilter = distanceFilter
    }

    @available(iOS, unavailable)
    @available(macCatalyst, unavailable)
    @available(macOS, unavailable)
    @available(tvOS, unavailable)
    public init(
      activityType: CLActivityType? = nil,
      allowsBackgroundLocationUpdates: Bool? = nil,
      desiredAccuracy: CLLocationAccuracy? = nil,
      distanceFilter: CLLocationDistance? = nil,
      headingFilter: CLLocationDegrees? = nil,
      headingOrientation: CLDeviceOrientation? = nil
    ) {
      self.activityType = activityType
      self.allowsBackgroundLocationUpdates = allowsBackgroundLocationUpdates
      self.desiredAccuracy = desiredAccuracy
      self.distanceFilter = distanceFilter
      self.headingFilter = headingFilter
      self.headingOrientation = headingOrientation
    }
  }
}

extension LocationManager: DependencyKey {
  nonisolated public static var liveValue: Self {
    MainActor.assumeIsolated {
      .live
    }
  }
}

extension LocationManager: TestDependencyKey {
  public static var testValue: Self {
    .failing
  }
}

extension DependencyValues {
  public var locationManager: LocationManager {
    get { self[LocationManager.self] }
    set { self[LocationManager.self] = newValue }
  }
}
