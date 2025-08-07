// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Experiments",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .watchOS(.v10),
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
        .package(path: "../Base"),
        .package(path: "../BaseModel"),
        .package(url: "https://github.com/pointfreeco/sharing-grdb.git", from: "0.5.0"),
        .package(url: "https://github.com/Anderson-Hyl/HeatMap.git", from: "1.0.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "ChartsHub",
            dependencies: [
                "Utils",
                .product(name: "BaseModel", package: "BaseModel"),
                .product(name: "Base", package: "Base"),
            ],
        ),
        .target(
            name: "CardsHub",
            dependencies: [
                "Utils",
            ],
        ),
        .target(
            name: "Utils",
            dependencies: [
                .product(name: "BaseModel", package: "BaseModel"),
                .product(name: "Base", package: "Base"),
            ],
        ),
        .target(
            name: "SQLHub",
            dependencies: [
                "Utils",
                .product(name: "SharingGRDB", package: "sharing-grdb"),
                .product(name: "HeatMap", package: "HeatMap")
            ],
        ),
    ],
    swiftLanguageModes: [.v6]
)
