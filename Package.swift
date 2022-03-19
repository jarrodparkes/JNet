// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "JNet",
    platforms: [.iOS(.v12), .macOS(.v10_12), .tvOS(.v12), .watchOS(.v2)],
    products: [.library(name: "JNet", targets: ["JNet"])],
    dependencies: [],
    targets: [
        .target(name: "JNet", dependencies: []),
        .testTarget(name: "JNetTests", dependencies: ["JNet"])
    ],
    swiftLanguageVersions: [.v5]
)
