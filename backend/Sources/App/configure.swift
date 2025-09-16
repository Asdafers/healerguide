import Vapor
import Fluent
import FluentPostgresDriver

// Configure your application
public func configure(_ app: Application) throws {
    // Configure database
    let hostname = Environment.get("DATABASE_HOST") ?? "localhost"
    let port = Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? 5432
    let username = Environment.get("DATABASE_USERNAME") ?? "healer"
    let password = Environment.get("DATABASE_PASSWORD") ?? "mysecretpassword"
    let database = Environment.get("DATABASE_NAME") ?? "healerkit"

    try app.databases.use(.postgres(
        hostname: hostname,
        port: port,
        username: username,
        password: password,
        database: database
    ), as: .psql)

    // Add migrations
    app.migrations.add(CreateSeasons())
    app.migrations.add(CreateDungeons())
    app.migrations.add(CreateBossEncounters())
    app.migrations.add(CreateAbilities())

    // Configure middleware
    app.middleware.use(ErrorMiddleware())
    app.middleware.use(CORSMiddleware(configuration: .init(
        allowedOrigin: .all,
        allowedMethods: [.GET, .POST, .PUT, .DELETE, .OPTIONS],
        allowedHeaders: [.accept, .authorization, .contentType, .origin, .xRequestedWith]
    )))

    // Register routes
    try routes(app)
}