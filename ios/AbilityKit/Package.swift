// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AbilityKit",
    platforms: [
        .iOS(.v13), // iOS 13.1+ compatibility for first-gen iPad Pro
        .macOS(.v10_15) // For CLI tool development and testing
    ],
    products: [
        // Libraries
        .library(
            name: "AbilityKit",
            targets: ["AbilityKit"]
        ),
        // CLI executable
        .executable(
            name: "abilitykit",
            targets: ["AbilityKitCLI"]
        )
    ],
    dependencies: [
        // ArgumentParser for CLI interface
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.0"),
        // DungeonKit dependency (local)
        .package(path: "../DungeonKit"),
        // HealerKitCore for shared types and utilities
        .package(path: "../HealerKitCore")
    ],
    targets: [
        // Main AbilityKit library
        .target(
            name: "AbilityKit",
            dependencies: [
                .product(name: "DungeonKit", package: "DungeonKit"),
                .product(name: "HealerKitCore", package: "HealerKitCore")
            ],
            path: ".",
            exclude: [
                "CLI/AbilityKitCLI.swift",
                "CLI/test_cli.swift",
                "Package.swift"
            ]
        ),
        // CLI executable target
        .executableTarget(
            name: "AbilityKitCLI",
            dependencies: [
                "AbilityKit",
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ],
            path: "CLI",
            sources: ["AbilityKitCLI.swift"]
        ),
    ]
)