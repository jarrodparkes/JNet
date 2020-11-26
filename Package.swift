// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "JNet",
    products: [.library(name: "JNet", targets: ["JNet"])],
    dependencies: [],
    targets: [
        .target(name: "JNet", dependencies: []),
        .testTarget(name: "JNetTests", dependencies: ["JNet"]),
    ],
    swiftLanguageVersions: [.v5]
)
