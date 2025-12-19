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
        .package(url: "https://github.com/apple/swift-collections.git", revision: "9bf03ff58ce34478e66aaee630e491823326fd06"),
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
