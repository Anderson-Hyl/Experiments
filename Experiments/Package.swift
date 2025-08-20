// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Experiments",
    platforms: [
        .iOS(.v18),
        .macOS(.v15),
        .watchOS(.v11),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "ChartsHub",
            targets: ["ChartsHub"]
        ),
        .library(
            name: "CardsHub",
            targets: ["CardsHub"]
        ),
        .library(
            name: "Utils",
            targets: ["Utils"]
        ),
        .library(
            name: "SQLHub",
            targets: ["SQLHub"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/pointfreeco/sharing-grdb.git",
            from: "0.5.0"
        ),
        .package(
            url: "https://github.com/Anderson-Hyl/HeatMap.git",
            from: "1.0.0"
        ),
        .package(
            url:
                "https://github.com/pointfreeco/swift-composable-architecture.git",
            from: "1.17.1"
        ),
        .package(
            url: "https://github.com/onevcat/Kingfisher.git",
            from: "8.5.0"
        ),
        .package(
            url: "https://github.com/pointfreeco/swift-sharing.git",
            exact: "2.6.0"
        ),
        .package(
            url: "https://github.com/SAP/cloud-sdk-ios-fiori.git",
            from: "25.4.5"
        ),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "ChartsHub",
            dependencies: [
                "Utils"
            ],
        ),
        .target(
            name: "CardsHub",
            dependencies: [
                "Utils"
            ],
        ),
        .target(
            name: "Utils",
            dependencies: [
                .product(name: "Sharing", package: "swift-sharing")
            ],
        ),
        .target(
            name: "SQLHub",
            dependencies: [
                "Utils",
                .product(name: "SharingGRDB", package: "sharing-grdb"),
                .product(name: "HeatMap", package: "HeatMap"),
                .product(
                    name: "ComposableArchitecture",
                    package: "swift-composable-architecture"
                ),
                .product(name: "Kingfisher", package: "Kingfisher"),
                .product(name: "FioriSwiftUI", package: "cloud-sdk-ios-fiori"),
            ],
        ),
    ],
    swiftLanguageModes: [.v6]
)
