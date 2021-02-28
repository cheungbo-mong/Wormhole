// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Wormhole",
    platforms: [
        .iOS(.v10),
        .macOS(.v10_10),
        .watchOS(.v3),
    ],
    products: [
        .library(
            name: "Wormhole",
            targets: ["Wormhole"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Wormhole",
            path: "Sources"
        ),
    ]
)
