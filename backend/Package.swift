// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "healerkit-backend",
    platforms: [
        .macOS(.v13)
    ],
    dependencies: [
        // Vapor framework
        .package(url: "https://github.com/vapor/vapor.git", from: "4.89.0"),
        // Fluent ORM
        .package(url: "https://github.com/vapor/fluent.git", from: "4.8.0"),
        // PostgreSQL driver
        .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.7.0"),
        // JWT for future auth if needed
        .package(url: "https://github.com/vapor/jwt.git", from: "4.2.0")
    ],
    targets: [
        .executableTarget(
            name: "App",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "Fluent", package: "fluent"),
                .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),
                .product(name: "JWT", package: "jwt")
            ],
            path: "Sources/App"
        )
    ]
)