import Fluent

struct CreateAbilities: AsyncMigration {
    func prepare(on database: Database) async throws {
        let damageProfileEnum = try await database.enum("damage_profile")
            .case("Critical")
            .case("High")
            .case("Moderate")
            .case("Mechanic")
            .create()

        try await database.schema("abilities")
            .id()
            .field("boss_encounter_id", .uuid, .required, .references("boss_encounters", "id", onDelete: .cascade))
            .field("name", .string, .required)
            .field("description", .string)
            .field("damage_profile", damageProfileEnum, .required)
            .field("healer_action", .string)
            .field("cast_time", .int, .required)
            .field("cooldown", .int, .required)
            .field("is_channeled", .bool, .required)
            .field("affected_targets", .int, .required)
            .field("metadata", .json)
            .field("created_at", .datetime, .required)
            .field("updated_at", .datetime, .required)
            .unique(on: "boss_encounter_id", "name")
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("abilities").delete()
        try await database.enum("damage_profile").delete()
    }
}