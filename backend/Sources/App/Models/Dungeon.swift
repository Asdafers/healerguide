import Fluent
import Vapor

final class Dungeon: Model, Content {
    static let schema = "dungeons"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "season_id")
    var season: Season

    @Field(key: "name")
    var name: String

    @Field(key: "short_name")
    var shortName: String

    @OptionalField(key: "healer_notes")
    var healerNotes: String?

    @Field(key: "estimated_duration")
    var estimatedDuration: Int

    @Field(key: "difficulty_rating")
    var difficultyRating: Int

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    @Children(for: \.$dungeon)
    var bossEncounters: [BossEncounter]

    init() { }

    init(id: UUID? = nil, seasonID: UUID, name: String, shortName: String, healerNotes: String? = nil, estimatedDuration: Int, difficultyRating: Int) {
        self.id = id
        self.$season.id = seasonID
        self.name = name
        self.shortName = shortName
        self.healerNotes = healerNotes
        self.estimatedDuration = estimatedDuration
        self.difficultyRating = difficultyRating
    }
}

// MARK: - Validations
extension Dungeon: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("name", as: String.self, is: !.empty)
        validations.add("short_name", as: String.self, is: .count(...20) && !.empty)
        validations.add("estimated_duration", as: Int.self, is: .range(15...60))
        validations.add("difficulty_rating", as: Int.self, is: .range(1...5))
        validations.add("healer_notes", as: String?.self, is: .nil || .count(...500), required: false)
    }
}

// MARK: - Response DTOs
struct DungeonResponse: Content {
    let id: UUID
    let name: String
    let shortName: String
    let healerNotes: String?
    let estimatedDuration: Int
    let difficultyRating: Int
    let bossCount: Int

    init(from dungeon: Dungeon, bossCount: Int) {
        self.id = dungeon.id!
        self.name = dungeon.name
        self.shortName = dungeon.shortName
        self.healerNotes = dungeon.healerNotes
        self.estimatedDuration = dungeon.estimatedDuration
        self.difficultyRating = dungeon.difficultyRating
        self.bossCount = bossCount
    }
}

// MARK: - Extensions
extension Dungeon {
    func toResponse(on db: Database) async throws -> DungeonResponse {
        let bossCount = try await self.$bossEncounters.query(on: db).count()
        return DungeonResponse(from: self, bossCount: bossCount)
    }
}