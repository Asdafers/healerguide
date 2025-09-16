import Vapor

func routes(_ app: Application) throws {
    // Health check endpoint
    app.get("health") { req async throws in
        // Simple health check
        return [
            "status": "healthy",
            "timestamp": Date().ISO8601Format(),
            "database": "available"
        ]
    }

    // Register API controllers
    try app.register(collection: SeasonsController())
    try app.register(collection: DungeonsController())
    try app.register(collection: BossEncountersController())
    try app.register(collection: AbilitiesController())
}