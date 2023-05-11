// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "ARPersistence",
    platforms: [
            .iOS(.v15),
        ],
    products: [
        .library(
            name: "ARPersistence",
            targets: ["ARPersistence"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "ARPersistence",
            dependencies: []
        )
    ]
)
