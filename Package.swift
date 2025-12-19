// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "swift-fickling",
    products: [
        .library(
            name: "Fickling",
            targets: ["Fickling"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-collections.git", from: "1.1.3")
    ],
    targets: [
        .target(
            name: "Fickling",
            dependencies: [
                .product(name: "Collections", package: "swift-collections"),
            ],
            path: "Sources"
        ),
    ]
)
