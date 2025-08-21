// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "UniPassSDK",
    platforms: [
        .iOS(.v15),
        .macOS(.v10_15),
        .tvOS(.v15),
        .watchOS(.v8)
    ],
    products: [
        .library(
            name: "UniPassSDK",
            targets: ["UniPassSDK"]),
    ],
    dependencies: [
        .package(url: "https://github.com/SnapKit/SnapKit.git", from: "5.7.1")
    ],
    targets: [
        .target(
            name: "UniPassSDK",
            dependencies: ["SnapKit"]
        ),
        .testTarget(
            name: "UniPassSDKTests",
            dependencies: ["UniPassSDK"]
        ),
    ]
)
