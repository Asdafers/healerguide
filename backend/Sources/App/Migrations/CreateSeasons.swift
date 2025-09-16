import Fluent
import SQLKit

struct CreateSeasons: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("seasons")
            .id()
            .field("major_version", .string, .required)
            .field("name", .string, .required)
            .field("is_active", .bool, .required)
            .field("release_date", .datetime, .required)
            .field("created_at", .datetime, .required)
            .field("updated_at", .datetime, .required)
            .unique(on: "name")
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("seasons").delete()
    }
}