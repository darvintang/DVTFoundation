// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DVTFoundation",

    platforms: [
        .macOS(.v10_14),
        .iOS(.v12)
    ],

    products: [
        .library(
            name: "DVTFoundation",
            targets: ["DVTFoundation"]
        )
    ],

    targets: [
        .target(
            name: "DVTFoundation",
            dependencies: [],
            path: "Sources"
        ),
        .testTarget(
            name: "DVTFoundationTests",
            dependencies: ["DVTFoundation"]
        )
    ]
)
