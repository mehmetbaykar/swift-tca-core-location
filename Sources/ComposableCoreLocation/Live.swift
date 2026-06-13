import CoreLocation

extension LocationManager {
  /// The live implementation of the `LocationManager` interface.
  @MainActor public static var live: Self {
    let manager = CLLocationManager()

    return Self(
      accuracyAuthorization: {
        if #available(iOS 14.0, tvOS 14.0, watchOS 7.0, macOS 11.0, macCatalyst 14.0, *) {
          return AccuracyAuthorization(manager.accuracyAuthorization)
        }
        return nil
      },
      authorizationStatus: {
        manager.authorizationStatus
      },
      delegate: {
        AsyncStream { continuation in
          let delegate = LocationManagerDelegate { action in
            continuation.yield(action)
          }
          manager.delegate = delegate

          let retainedDelegate = UncheckedSendable(delegate)
          let retainedManager = UncheckedSendable(manager)
          continuation.onTermination = { _ in
            Task { @MainActor in
              if retainedManager.value.delegate === retainedDelegate.value {
                retainedManager.value.delegate = nil
              }
              _ = retainedDelegate.value
            }
          }
        }
      },
      dismissHeadingCalibrationDisplay: {
        #if os(iOS) || os(macOS) || os(watchOS) || targetEnvironment(macCatalyst)
          manager.dismissHeadingCalibrationDisplay()
        #endif
      },
      heading: {
        #if os(iOS) || os(watchOS) || targetEnvironment(macCatalyst)
          return manager.heading.map(Heading.init(rawValue:))
        #else
          return nil
        #endif
      },
      headingAvailable: {
        #if os(iOS) || os(macOS) || os(watchOS) || targetEnvironment(macCatalyst)
          return CLLocationManager.headingAvailable()
        #else
          return false
        #endif
      },
      isRangingAvailable: {
        #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)
          return CLLocationManager.isRangingAvailable()
        #else
          return false
        #endif
      },
      location: { manager.location.map(Location.init(rawValue:)) },
      locationServicesEnabled: CLLocationManager.locationServicesEnabled,
      maximumRegionMonitoringDistance: {
        #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)
          return manager.maximumRegionMonitoringDistance
        #else
          return CLLocationDistanceMax
        #endif
      },
      monitoredRegions: {
        #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)
          return Set(manager.monitoredRegions.map(Region.init(rawValue:)))
        #else
          return []
        #endif
      },
      requestAlwaysAuthorization: {
        #if os(iOS) || os(macOS) || os(watchOS) || targetEnvironment(macCatalyst)
          manager.requestAlwaysAuthorization()
        #endif
      },
      requestLocation: {
        manager.requestLocation()
      },
      requestWhenInUseAuthorization: {
        #if os(iOS) || os(macOS) || os(watchOS) || targetEnvironment(macCatalyst)
          manager.requestWhenInUseAuthorization()
        #endif
      },
      requestTemporaryFullAccuracyAuthorization: { purposeKey in
        try await withCheckedThrowingContinuation { continuation in
          if #available(iOS 14.0, tvOS 14.0, watchOS 7.0, macOS 11.0, macCatalyst 14.0, *) {
            manager.requestTemporaryFullAccuracyAuthorization(withPurposeKey: purposeKey) { error in
              if let error {
                continuation.resume(throwing: LocationManager.Error(error))
              } else {
                continuation.resume()
              }
            }
          } else {
            continuation.resume()
          }
        }
      },
      set: { properties in
        #if os(iOS) || os(watchOS) || targetEnvironment(macCatalyst)
          if let activityType = properties.activityType {
            manager.activityType = activityType
          }
          if let allowsBackgroundLocationUpdates = properties.allowsBackgroundLocationUpdates {
            manager.allowsBackgroundLocationUpdates = allowsBackgroundLocationUpdates
          }
        #endif
        #if os(iOS) || os(macOS) || os(tvOS) || os(watchOS) || targetEnvironment(macCatalyst)
          if let desiredAccuracy = properties.desiredAccuracy {
            manager.desiredAccuracy = desiredAccuracy
          }
          if let distanceFilter = properties.distanceFilter {
            manager.distanceFilter = distanceFilter
          }
        #endif
        #if os(iOS) || os(watchOS) || targetEnvironment(macCatalyst)
          if let headingFilter = properties.headingFilter {
            manager.headingFilter = headingFilter
          }
          if let headingOrientation = properties.headingOrientation {
            manager.headingOrientation = headingOrientation
          }
        #endif
        #if os(iOS) || targetEnvironment(macCatalyst)
          if let pausesLocationUpdatesAutomatically = properties.pausesLocationUpdatesAutomatically
          {
            manager.pausesLocationUpdatesAutomatically = pausesLocationUpdatesAutomatically
          }
          if let showsBackgroundLocationIndicator = properties.showsBackgroundLocationIndicator {
            manager.showsBackgroundLocationIndicator = showsBackgroundLocationIndicator
          }
        #endif
      },
      significantLocationChangeMonitoringAvailable: {
        #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)
          return CLLocationManager.significantLocationChangeMonitoringAvailable()
        #else
          return false
        #endif
      },
      startMonitoringForRegion: { region in
        #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)
          guard let region = region.rawValue else { return }
          manager.startMonitoring(for: region)
        #endif
      },
      startMonitoringSignificantLocationChanges: {
        #if os(iOS) || targetEnvironment(macCatalyst)
          manager.startMonitoringSignificantLocationChanges()
        #endif
      },
      startMonitoringVisits: {
        #if os(iOS) || targetEnvironment(macCatalyst)
          manager.startMonitoringVisits()
        #endif
      },
      startUpdatingHeading: {
        #if os(iOS) || os(macOS) || os(watchOS) || targetEnvironment(macCatalyst)
          manager.startUpdatingHeading()
        #endif
      },
      startUpdatingLocation: {
        #if os(iOS) || os(macOS) || os(watchOS) || targetEnvironment(macCatalyst)
          manager.startUpdatingLocation()
        #endif
      },
      stopMonitoringForRegion: { region in
        #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)
          guard let region = region.rawValue else { return }
          manager.stopMonitoring(for: region)
        #endif
      },
      stopMonitoringSignificantLocationChanges: {
        #if os(iOS) || targetEnvironment(macCatalyst)
          manager.stopMonitoringSignificantLocationChanges()
        #endif
      },
      stopMonitoringVisits: {
        #if os(iOS) || targetEnvironment(macCatalyst)
          manager.stopMonitoringVisits()
        #endif
      },
      stopUpdatingHeading: {
        #if os(iOS) || os(watchOS) || targetEnvironment(macCatalyst)
          manager.stopUpdatingHeading()
        #endif
      },
      stopUpdatingLocation: {
        #if os(iOS) || os(macOS) || os(watchOS) || targetEnvironment(macCatalyst)
          manager.stopUpdatingLocation()
        #endif
      }
    )
  }
}

private final class LocationManagerDelegate: NSObject, CLLocationManagerDelegate {
  let send: (LocationManager.Action) -> Void

  init(send: @escaping (LocationManager.Action) -> Void) {
    self.send = send
  }

  func locationManager(
    _ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus
  ) {
    send(.didChangeAuthorization(status))
  }

  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    send(.didFailWithError(LocationManager.Error(error)))
  }

  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    send(.didUpdateLocations(locations.map(Location.init(rawValue:))))
  }

  #if os(macOS)
    func locationManager(
      _ manager: CLLocationManager, didUpdateTo newLocation: CLLocation,
      from oldLocation: CLLocation
    ) {
      send(
        .didUpdateTo(
          newLocation: Location(rawValue: newLocation),
          oldLocation: Location(rawValue: oldLocation)
        )
      )
    }
  #endif

  #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)
    func locationManager(
      _ manager: CLLocationManager, didFinishDeferredUpdatesWithError error: Error?
    ) {
      send(.didFinishDeferredUpdatesWithError(error.map(LocationManager.Error.init)))
    }
  #endif

  #if os(iOS) || targetEnvironment(macCatalyst)
    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
      send(.didPauseLocationUpdates)
    }
  #endif

  #if os(iOS) || targetEnvironment(macCatalyst)
    func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
      send(.didResumeLocationUpdates)
    }
  #endif

  #if os(iOS) || os(watchOS) || targetEnvironment(macCatalyst)
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
      send(.didUpdateHeading(newHeading: Heading(rawValue: newHeading)))
    }
  #endif

  #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
      send(.didEnterRegion(Region(rawValue: region)))
    }
  #endif

  #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
      send(.didExitRegion(Region(rawValue: region)))
    }
  #endif

  #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)
    func locationManager(
      _ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion
    ) {
      send(.didDetermineState(state, region: Region(rawValue: region)))
    }
  #endif

  #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)
    func locationManager(
      _ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error
    ) {
      send(
        .monitoringDidFail(
          region: region.map(Region.init(rawValue:)), error: LocationManager.Error(error)))
    }
  #endif

  #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
      send(.didStartMonitoring(region: Region(rawValue: region)))
    }
  #endif

  #if os(iOS) || targetEnvironment(macCatalyst)
    func locationManager(
      _ manager: CLLocationManager, didRange beacons: [CLBeacon],
      satisfying beaconConstraint: CLBeaconIdentityConstraint
    ) {
      send(
        .didRangeBeacons(
          beacons.map(Beacon.init(rawValue:)), satisfyingConstraint: beaconConstraint
        )
      )
    }
  #endif

  #if os(iOS) || targetEnvironment(macCatalyst)
    func locationManager(
      _ manager: CLLocationManager, didFailRangingFor beaconConstraint: CLBeaconIdentityConstraint,
      error: Error
    ) {
      send(.didFailRanging(beaconConstraint: beaconConstraint, error: LocationManager.Error(error)))
    }
  #endif

  #if os(iOS) || targetEnvironment(macCatalyst)
    func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
      send(.didVisit(Visit(visit: visit)))
    }
  #endif
}

private struct UncheckedSendable<Value>: @unchecked Sendable {
  let value: Value

  init(_ value: Value) {
    self.value = value
  }
}
