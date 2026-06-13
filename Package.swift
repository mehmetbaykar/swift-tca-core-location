// swift-tools-version:6.3

import PackageDescription

let package = Package(
  name: "composable-core-location",
  platforms: [
    .iOS(.v16),
    .macOS(.v13),
    .tvOS(.v16),
    .watchOS(.v9),
  ],
  products: [
    .library(
      name: "ComposableCoreLocation",
      targets: ["ComposableCoreLocation"]
    )
  ],
  dependencies: [
    .package(
      url: "https://github.com/pointfreeco/swift-composable-architecture",
      .upToNextMajor(from: "1.26.0")
    ),
    .package(
      url: "https://github.com/pointfreeco/xctest-dynamic-overlay",
      .upToNextMajor(from: "1.3.0")
    ),
  ],
  targets: [
    .target(
      name: "ComposableCoreLocation",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "IssueReporting", package: "xctest-dynamic-overlay"),
      ]
    ),
    .testTarget(
      name: "ComposableCoreLocationTests",
      dependencies: ["ComposableCoreLocation"]
    ),
  ],
  swiftLanguageModes: [.v6]
)
