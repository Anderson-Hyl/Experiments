// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Base",
    platforms: [
        .iOS(.v14),
        .watchOS(.v4)
    ],
    products: [
        .library(
            name: "Base",
            targets: ["Base"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/ReactiveX/RxSwift.git", exact: "6.8.0")
    ],
    targets: [
        .target(
            name: "Base",
            dependencies: [
                "RxSwift",
                .product(name: "RxRelay", package: "RxSwift"),
                .product(name: "RxCocoa", package: "RxSwift", condition: .when(platforms: [.iOS]))
            ]
        ),
        .testTarget(
            name: "BaseTests",
            dependencies: ["Base"]
        )
    ]
)
