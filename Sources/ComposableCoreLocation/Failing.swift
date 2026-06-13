import CoreLocation
import IssueReporting

extension LocationManager {
  /// A failing implementation of the `LocationManager` interface for tests.
  ///
  /// Override only the endpoints a test expects to use. Any unexpected endpoint records a test
  /// failure and returns a harmless default value.
  public static let failing = Self(
    accuracyAuthorization: {
      reportUnimplemented("LocationManager.accuracyAuthorization")
      return nil
    },
    authorizationStatus: {
      reportUnimplemented("LocationManager.authorizationStatus")
      return .notDetermined
    },
    delegate: {
      reportUnimplemented("LocationManager.delegate")
      return AsyncStream { $0.finish() }
    },
    dismissHeadingCalibrationDisplay: {
      reportUnimplemented("LocationManager.dismissHeadingCalibrationDisplay")
    },
    heading: {
      reportUnimplemented("LocationManager.heading")
      return nil
    },
    headingAvailable: {
      reportUnimplemented("LocationManager.headingAvailable")
      return false
    },
    isRangingAvailable: {
      reportUnimplemented("LocationManager.isRangingAvailable")
      return false
    },
    location: {
      reportUnimplemented("LocationManager.location")
      return nil
    },
    locationServicesEnabled: {
      reportUnimplemented("LocationManager.locationServicesEnabled")
      return false
    },
    maximumRegionMonitoringDistance: {
      reportUnimplemented("LocationManager.maximumRegionMonitoringDistance")
      return CLLocationDistanceMax
    },
    monitoredRegions: {
      reportUnimplemented("LocationManager.monitoredRegions")
      return []
    },
    requestAlwaysAuthorization: {
      reportUnimplemented("LocationManager.requestAlwaysAuthorization")
    },
    requestLocation: {
      reportUnimplemented("LocationManager.requestLocation")
    },
    requestWhenInUseAuthorization: {
      reportUnimplemented("LocationManager.requestWhenInUseAuthorization")
    },
    requestTemporaryFullAccuracyAuthorization: { _ in
      reportUnimplemented("LocationManager.requestTemporaryFullAccuracyAuthorization")
    },
    set: { _ in
      reportUnimplemented("LocationManager.set")
    },
    significantLocationChangeMonitoringAvailable: {
      reportUnimplemented("LocationManager.significantLocationChangeMonitoringAvailable")
      return false
    },
    startMonitoringForRegion: { _ in
      reportUnimplemented("LocationManager.startMonitoringForRegion")
    },
    startMonitoringSignificantLocationChanges: {
      reportUnimplemented("LocationManager.startMonitoringSignificantLocationChanges")
    },
    startMonitoringVisits: {
      reportUnimplemented("LocationManager.startMonitoringVisits")
    },
    startUpdatingHeading: {
      reportUnimplemented("LocationManager.startUpdatingHeading")
    },
    startUpdatingLocation: {
      reportUnimplemented("LocationManager.startUpdatingLocation")
    },
    stopMonitoringForRegion: { _ in
      reportUnimplemented("LocationManager.stopMonitoringForRegion")
    },
    stopMonitoringSignificantLocationChanges: {
      reportUnimplemented("LocationManager.stopMonitoringSignificantLocationChanges")
    },
    stopMonitoringVisits: {
      reportUnimplemented("LocationManager.stopMonitoringVisits")
    },
    stopUpdatingHeading: {
      reportUnimplemented("LocationManager.stopUpdatingHeading")
    },
    stopUpdatingLocation: {
      reportUnimplemented("LocationManager.stopUpdatingLocation")
    }
  )
}

private func reportUnimplemented(
  _ name: StaticString,
  fileID: StaticString = #fileID,
  filePath: StaticString = #filePath,
  line: UInt = #line,
  column: UInt = #column
) {
  reportIssue(
    "A failing endpoint was accessed: '\(name)'",
    fileID: fileID,
    filePath: filePath,
    line: line,
    column: column
  )
}
