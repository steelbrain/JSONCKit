// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "JSONCKit",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6),
        .visionOS(.v1),
    ],
    products: [
        .library(
            name: "JSONCKit",
            targets: ["JSONCKit"]
        ),
    ],
    targets: [
        .target(
            name: "JSONCKit"
        ),
        .testTarget(
            name: "JSONCKitTests",
            dependencies: ["JSONCKit"]
        ),
    ]
)
