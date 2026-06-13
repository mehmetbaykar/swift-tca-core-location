# Composable Core Location

[![CI](https://github.com/mehmetbaykar/swift-tca-core-location/actions/workflows/ci.yml/badge.svg)](https://github.com/mehmetbaykar/swift-tca-core-location/actions/workflows/ci.yml)
[![Swift 6.3](https://img.shields.io/badge/Swift-6.3-orange.svg)](https://www.swift.org)

Composable Core Location bridges [the Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture) and [Core Location](https://developer.apple.com/documentation/corelocation) with a testable dependency client.

* [Example](#example)
* [Basic usage](#basic-usage)
* [Testing](#testing)
* [Installation](#installation)
* [Documentation](#documentation)
* [Help](#help)

## Example

Check out the [LocationManager](./Examples/LocationManager) demo to see ComposableCoreLocation in practice.

The example project is generated with Tuist from [Examples/Project.swift](./Examples/Project.swift). Its Tuist package points at this package with `.package(path: "../..")`, so the example app and tests use the local sources directly.

From the repository root:

```sh
make generate-examples
make test-examples
```

## Basic Usage

Access Core Location from reducers through the `locationManager` dependency:

```swift
import ComposableArchitecture
import ComposableCoreLocation
import CoreLocation

@Reducer
struct AppFeature {
  @ObservableState
  struct State: Equatable {
    var lastLocation: Location?
  }

  enum Action: Equatable {
    case locationManager(LocationManager.Action)
    case requestAuthorizationButtonTapped
    case task
  }

  @Dependency(\.locationManager) private var locationManager

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .task:
        let delegate = locationManager.delegate
        return .run { send in
          for await action in await delegate() {
            await send(.locationManager(action))
          }
        }

      case .requestAuthorizationButtonTapped:
        let requestWhenInUseAuthorization = locationManager.requestWhenInUseAuthorization
        return .run { _ in
          await requestWhenInUseAuthorization()
        }

      case .locationManager(.didChangeAuthorization(.authorizedAlways)),
        .locationManager(.didChangeAuthorization(.authorizedWhenInUse)):
        let requestLocation = locationManager.requestLocation
        return .run { _ in
          await requestLocation()
        }

      case .locationManager(.didUpdateLocations(let locations)):
        state.lastLocation = locations.first
        return .none

      case .locationManager:
        return .none
      }
    }
  }
}
```

`LocationManager.Action` contains the delegate callbacks emitted by `CLLocationManagerDelegate`, including authorization changes, location updates, region monitoring events, heading updates, visit events, and errors.

The live dependency is installed automatically through TCA's dependency system. In application code you call async endpoints such as `requestWhenInUseAuthorization`, `requestLocation`, `startUpdatingLocation`, and `set(...)` from `.run` effects. Long-lived delegate callbacks are consumed from `locationManager.delegate()` as an `AsyncStream`.

## Testing

Tests use Swift Testing, TCA's `TestStore`, and dependency overrides. Start from `LocationManager.failing` and override only the endpoints used by the reducer under test:

```swift
import ComposableArchitecture
import ComposableCoreLocation
import CoreLocation
import Foundation
import Testing

@MainActor
@Suite
struct AppFeatureTests {
  @Test
  func receivesLocationUpdates() async {
    let location = Location(
      coordinate: CLLocationCoordinate2D(latitude: 10, longitude: 20),
      timestamp: Date(timeIntervalSince1970: 0)
    )
    let (stream, continuation) = AsyncStream.makeStream(of: LocationManager.Action.self)

    let store = TestStore(initialState: AppFeature.State()) {
      AppFeature()
    } withDependencies: {
      var manager = LocationManager.failing
      manager.delegate = { stream }
      $0.locationManager = manager
    }

    let task = await store.send(.task)
    continuation.yield(.didUpdateLocations([location]))

    await store.receive(.locationManager(.didUpdateLocations([location]))) {
      $0.lastLocation = location
    }

    continuation.finish()
    await task.cancel()
  }
}
```

See [Examples/LocationManager/CommonTests](./Examples/LocationManager/CommonTests) for complete Swift Testing coverage of authorization, current-location requests, and MapKit search behavior.

## Installation

This package uses Swift tools 6.3, Swift 6 language mode, and TCA 1.26. It supports iOS 16, macOS 13, tvOS 16, and watchOS 9 or newer.

You can add ComposableCoreLocation to an Xcode project by adding it as a package dependency:

```text
https://github.com/mehmetbaykar/swift-tca-core-location
```

For a Swift package, depend on a release tag:

```swift
.package(url: "https://github.com/mehmetbaykar/swift-tca-core-location", from: "0.4.1")
```

Then add `ComposableCoreLocation` as a dependency of the target that uses Core Location.

## Documentation

Generated documentation is published from GitHub releases to <https://mehmetbaykar.github.io/swift-tca-core-location/>. Source documentation also lives inline under [Sources/ComposableCoreLocation](./Sources/ComposableCoreLocation).

## Help

If you want to discuss Composable Core Location and the Composable Architecture, or have a question about how to use them to solve a particular problem, ask around on [the Swift forum for the Composable Architecture](https://forums.swift.org/c/related-projects/swift-composable-architecture).

## License

This library is released under the MIT license. See [LICENSE](LICENSE) for details.
