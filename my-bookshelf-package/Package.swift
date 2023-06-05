// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "my-bookshelf-package",
    platforms: [.iOS(.v16)],
    products: [
        .library(name: "HomeView",targets: ["HomeView"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", from: "0.53.2"),
        .package(url: "https://github.com/tkoehlerlg/SwiftCodeScanner.git", from: "2.3.3"),
        .package(url: "https://github.com/carson-katri/swift-request.git", from: "1.4.0"),
        .package(url: "https://github.com/SwiftUIX/SwiftUIX.git", from: "0.1.4"),
        .package(url: "https://github.com/Mobelux/ImageFetcher.git", from: "1.1.4")

    ],
    targets: [
        .target(
            name: "HomeView",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "CodeScanner", package: "SwiftCodeScanner"),
                .product(name: "SwiftUIX", package: "SwiftUIX"),
                "BookFinder",
                "Utils",
                "StateManager",
                "BookDetailView"
            ]
        ),
        .target(
            name: "BookDetailView",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "CodeScanner", package: "SwiftCodeScanner"),
                .product(name: "SwiftUIX", package: "SwiftUIX"),
                "BookFinder",
                "Utils"
            ],
            resources: [.process("Resources")]
        ),
        .target(
            name: "BookFinder",
            dependencies: [
                .product(name: "Request", package: "swift-request"),
                .product(name: "ImageFetcher", package: "ImageFetcher"),
                "Utils"
            ],
            resources: [.process("Resources")]
        ),
        .target(
            name: "Utils",
            dependencies: [.product(name: "SwiftUIX", package: "SwiftUIX")]
        ),
        .target(
            name: "StateManager",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "BookFinder"
            ]
        ),
        .testTarget(
            name: "HomeViewTests",
            dependencies: ["HomeView"]),
    ]
)
