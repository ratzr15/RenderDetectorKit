// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RenderDetectorKit",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "RenderDetectorKit",
            targets: ["RenderDetectorKit"]),
    ],
    targets: [
        .target(
            name: "RenderDetectorKit"),
        .testTarget(
            name: "RenderDetectorKitTests",
            dependencies: ["RenderDetectorKit"]
        ),
    ]
)
