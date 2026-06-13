import ComposableArchitecture

public struct LocalSearchClient: Sendable {
  public var search: @Sendable (LocalSearchRequest) async throws -> LocalSearchResponse

  public init(
    search: @escaping @Sendable (LocalSearchRequest) async throws -> LocalSearchResponse
  ) {
    self.search = search
  }

  public struct Error: Swift.Error, Equatable, Sendable {
    public init() {}
  }
}

extension LocalSearchClient: DependencyKey {
  public static let liveValue = Self.live
}

extension LocalSearchClient: TestDependencyKey {
  public static let testValue = Self(
    search: { _ in throw Error() }
  )
}

extension DependencyValues {
  public var localSearch: LocalSearchClient {
    get { self[LocalSearchClient.self] }
    set { self[LocalSearchClient.self] = newValue }
  }
}
