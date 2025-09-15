// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "HealerUIKitCLI",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15)
    ],
    products: [
        .executable(
            name: "healeruikit",
            targets: ["HealerUIKitCLI"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.2.0"),
    ],
    targets: [
        .executableTarget(
            name: "HealerUIKitCLI",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ],
            path: "."
        ),
    ]
)