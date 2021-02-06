// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Wormhole",
    platforms: [
        .iOS(.v9),
        .macOS(.v10_10),
        .watchOS(.v2),
    ],
    products: [
        .library(
            name: "Wormhole",
            targets: ["Wormhole"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/Flight-School/AnyCodable",
            from: "0.4.0"
        ),
    ],
    targets: [
        .target(
            name: "Wormhole",
            dependencies: ["AnyCodable"],
            path: "Sources"
        ),
    ]
)
