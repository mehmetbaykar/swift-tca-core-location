import CoreLocation
import MapKit

public struct Coordinate: Equatable, Hashable, Sendable {
  public var latitude: CLLocationDegrees
  public var longitude: CLLocationDegrees

  public init(latitude: CLLocationDegrees = 0, longitude: CLLocationDegrees = 0) {
    self.latitude = latitude
    self.longitude = longitude
  }

  public init(_ coordinate: CLLocationCoordinate2D) {
    self.init(latitude: coordinate.latitude, longitude: coordinate.longitude)
  }

  public var coreLocationCoordinate: CLLocationCoordinate2D {
    CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
  }
}

public struct CoordinateSpan: Equatable, Sendable {
  public var latitudeDelta: CLLocationDegrees
  public var longitudeDelta: CLLocationDegrees

  public init(latitudeDelta: CLLocationDegrees = 0, longitudeDelta: CLLocationDegrees = 0) {
    self.latitudeDelta = latitudeDelta
    self.longitudeDelta = longitudeDelta
  }

  public init(_ span: MKCoordinateSpan) {
    self.init(latitudeDelta: span.latitudeDelta, longitudeDelta: span.longitudeDelta)
  }

  public var mapKitSpan: MKCoordinateSpan {
    MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
  }
}

public struct CoordinateRegion: Equatable, Sendable {
  public var center: Coordinate
  public var span: CoordinateSpan

  public init(
    center: Coordinate = Coordinate(),
    span: CoordinateSpan = CoordinateSpan()
  ) {
    self.center = center
    self.span = span
  }

  public init(coordinateRegion: MKCoordinateRegion) {
    self.center = Coordinate(coordinateRegion.center)
    self.span = CoordinateSpan(coordinateRegion.span)
  }

  public var mapKitRegion: MKCoordinateRegion {
    MKCoordinateRegion(center: center.coreLocationCoordinate, span: span.mapKitSpan)
  }
}

public struct LocalSearchRequest: Equatable, Sendable {
  public var category: PointOfInterestCategory
  public var region: CoordinateRegion?

  public init(category: PointOfInterestCategory, region: CoordinateRegion?) {
    self.category = category
    self.region = region
  }
}

public struct LocalSearchResponse: Equatable, Sendable {
  public var pointsOfInterest: [PointOfInterest]

  public init(pointsOfInterest: [PointOfInterest]) {
    self.pointsOfInterest = pointsOfInterest
  }

  public init(response: MKLocalSearch.Response) {
    self.pointsOfInterest = response.mapItems.map { item in
      PointOfInterest(
        coordinate: Coordinate(item.placemark.coordinate),
        subtitle: item.placemark.subtitle,
        title: item.name
      )
    }
  }
}
