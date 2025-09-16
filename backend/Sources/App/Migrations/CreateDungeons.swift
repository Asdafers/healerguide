import Fluent

struct CreateDungeons: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("dungeons")
            .id()
            .field("season_id", .uuid, .required, .references("seasons", "id", onDelete: .cascade))
            .field("name", .string, .required)
            .field("short_name", .string, .required)
            .field("healer_notes", .string)
            .field("estimated_duration", .int, .required)
            .field("difficulty_rating", .int, .required)
            .field("created_at", .datetime, .required)
            .field("updated_at", .datetime, .required)
            .unique(on: "season_id", "name")
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("dungeons").delete()
    }
}