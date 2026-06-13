import MapKit

extension LocalSearchClient {
  public static let live = Self { request in
    let searchRequest = MKLocalSearch.Request()
    searchRequest.pointOfInterestFilter = MKPointOfInterestFilter(
      including: [request.category.mapKitCategory]
    )
    if let region = request.region {
      searchRequest.region = region.mapKitRegion
    }

    do {
      let response = try await MKLocalSearch(request: searchRequest).start()
      return LocalSearchResponse(response: response)
    } catch {
      throw LocalSearchClient.Error()
    }
  }
}
