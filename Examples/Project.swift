import ProjectDescription

let swiftSettings: Settings = .settings(
  base: [
    "SWIFT_VERSION": "6.0"
  ]
)

let project = Project(
  name: "ComposableCoreLocationExamples",
  targets: [
    .target(
      name: "LocationManagerFeature",
      destinations: [.iPhone, .iPad, .mac],
      product: .framework,
      bundleId: "co.pointfree.examples.location-manager.feature",
      deploymentTargets: .multiplatform(iOS: "16.0", macOS: "13.0"),
      infoPlist: .default,
      sources: [
        "LocationManager/Common/**/*.swift"
      ],
      dependencies: [
        .external(name: "ComposableCoreLocation")
      ],
      settings: swiftSettings
    ),
    .target(
      name: "LocationManagerMobile",
      destinations: [.iPhone, .iPad],
      product: .app,
      bundleId: "co.pointfree.examples.location-manager.mobile",
      deploymentTargets: .iOS("16.0"),
      infoPlist: .extendingDefault(
        with: [
          "NSLocationWhenInUseUsageDescription":
            "The example uses your location to search nearby points of interest.",
          "UILaunchScreen": [:],
        ]
      ),
      sources: [
        "LocationManager/Mobile/**/*.swift"
      ],
      resources: [
        "LocationManager/Mobile/Assets.xcassets"
      ],
      dependencies: [
        .target(name: "LocationManagerFeature")
      ],
      settings: swiftSettings
    ),
    .target(
      name: "LocationManagerDesktop",
      destinations: [.mac],
      product: .app,
      bundleId: "co.pointfree.examples.location-manager.desktop",
      deploymentTargets: .macOS("13.0"),
      infoPlist: .extendingDefault(
        with: [
          "NSLocationWhenInUseUsageDescription":
            "The example uses your location to search nearby points of interest."
        ]
      ),
      sources: [
        "LocationManager/Desktop/**/*.swift"
      ],
      resources: [
        "LocationManager/Desktop/Assets.xcassets"
      ],
      dependencies: [
        .target(name: "LocationManagerFeature")
      ],
      settings: swiftSettings
    ),
    .target(
      name: "LocationManagerFeatureTests",
      destinations: [.iPhone, .iPad, .mac],
      product: .unitTests,
      bundleId: "co.pointfree.examples.location-manager.feature-tests",
      deploymentTargets: .multiplatform(iOS: "16.0", macOS: "14.0"),
      infoPlist: .default,
      sources: [
        "LocationManager/CommonTests/**/*.swift"
      ],
      dependencies: [
        .target(name: "LocationManagerFeature")
      ],
      settings: swiftSettings
    ),
  ]
)
