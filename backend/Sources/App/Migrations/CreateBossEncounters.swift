import Fluent

struct CreateBossEncounters: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("boss_encounters")
            .id()
            .field("dungeon_id", .uuid, .required, .references("dungeons", "id", onDelete: .cascade))
            .field("name", .string, .required)
            .field("healing_summary", .string)
            .field("positioning", .string)
            .field("cooldown_priority", .string)
            .field("order_index", .int, .required)
            .field("created_at", .datetime, .required)
            .field("updated_at", .datetime, .required)
            .unique(on: "dungeon_id", "name")
            .unique(on: "dungeon_id", "order_index")
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("boss_encounters").delete()
    }
}