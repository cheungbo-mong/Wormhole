// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Wormhole",
    platforms: [
        .iOS(.v10),
        .macOS(.v10_10),
        .watchOS(.v4)
    ],
    products: [
        .library(
            name: "Wormhole",
            targets: ["Wormhole"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "Wormhole",
            dependencies: [],
            path: "Sources")
    ]
)
