// swift-tools-version: 6.3

import PackageDescription

#if TUIST
  import ProjectDescription

  let packageSettings = PackageSettings(
    productTypes: [
      "ComposableCoreLocation": .framework
    ]
  )
#endif

let package = Package(
  name: "ComposableCoreLocationExampleDependencies",
  dependencies: [
    .package(
      url: "https://github.com/pointfreeco/swift-composable-architecture",
      .upToNextMajor(from: "1.26.0")
    ),
    .package(
      url: "https://github.com/pointfreeco/swift-dependencies",
      .upToNextMajor(from: "1.14.1")
    ),
    .package(
      url: "https://github.com/pointfreeco/swift-navigation",
      .upToNextMajor(from: "2.10.1")
    ),
    .package(path: "../.."),
  ]
)
