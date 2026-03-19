// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TransactionHistory",
    platforms: [
        .iOS(.v26)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "TransactionHistory",
            targets: ["TransactionHistory"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log", from: "1.6.4"),
        .package(url: "https://github.com/apple/swift-metrics", from: "2.5.0"),
        .package(url: "https://github.com/kasianov-mikhail/scout", from: "2.0.0"),
        .package(url: "https://github.com/nalexn/ViewInspector", from: "0.10.3")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "TransactionHistory",
            dependencies: [
                .product(name: "Logging", package: "swift-log"),
                .product(name: "Metrics", package: "swift-metrics"),
                .product(name: "Scout", package: "scout")
            ]
        ),
        .testTarget(
            name: "TransactionHistoryTests",
            dependencies: [
                .byName(name: "TransactionHistory"),
                .product(name: "ViewInspector", package: "ViewInspector")
            ]
        ),
    ]
)
