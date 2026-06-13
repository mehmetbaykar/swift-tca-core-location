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
    .package(path: "../..")
  ]
)
