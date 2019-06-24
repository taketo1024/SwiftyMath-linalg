// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftyLinearAlgebra",
    products: [
        .library(
            name: "SwiftyLinearAlgebra",
            targets: ["SwiftyLinearAlgebra"]),
    ],
    dependencies: [
        .package(url: "https://github.com/taketo1024/SwiftyMath.git", .exact("1.0.10")),
    ],
    targets: [
        .target(
            name: "SwiftyLinearAlgebra",
            dependencies: ["SwiftyMath"],
			path: "Sources/SwiftyLinearAlgebra"),
        .testTarget(
            name: "SwiftyLinearAlgebraTests",
            dependencies: ["SwiftyLinearAlgebra"]),
    ]
)
