// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DungeonKit",
    platforms: [
        .iOS(.v13), // iOS 13.1+ compatibility for first-gen iPad Pro
        .macOS(.v10_15) // For CLI tool development and testing
    ],
    products: [
        // Libraries
        .library(
            name: "DungeonKit",
            targets: ["DungeonKit"]
        ),
        // CLI executable
        .executable(
            name: "dungeonkit",
            targets: ["DungeonKitCLI"]
        )
    ],
    dependencies: [
        // ArgumentParser for CLI interface
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.0"),
        // HealerKitCore for shared types and utilities
        .package(path: "../HealerKitCore")
    ],
    targets: [
        // Main DungeonKit library
        .target(
            name: "DungeonKit",
            dependencies: [
                .product(name: "HealerKitCore", package: "HealerKitCore")
            ],
            path: ".",
            exclude: [
                "CLI/DungeonKitCLI.swift",
                "CLI/Package.swift",
                "Package.swift"
            ]
        ),
        // CLI executable target
        .executableTarget(
            name: "DungeonKitCLI",
            dependencies: [
                "DungeonKit",
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ],
            path: "CLI",
            sources: ["DungeonKitCLI.swift"]
        ),
    ]
)