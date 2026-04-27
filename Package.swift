// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "JSONCKit",
    platforms: [
        .iOS(.v13),
        .macCatalyst(.v13),
        .macOS(.v10_15),
        .tvOS(.v13),
        .visionOS(.v1),
        .watchOS(.v6),
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
