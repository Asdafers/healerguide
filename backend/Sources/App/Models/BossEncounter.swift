import Fluent
import Vapor

final class BossEncounter: Model, Content {
    static let schema = "boss_encounters"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "dungeon_id")
    var dungeon: Dungeon

    @Field(key: "name")
    var name: String

    @OptionalField(key: "healing_summary")
    var healingSummary: String?

    @OptionalField(key: "positioning")
    var positioning: String?

    @OptionalField(key: "cooldown_priority")
    var cooldownPriority: String?

    @Field(key: "order_index")
    var orderIndex: Int

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    @Children(for: \.$bossEncounter)
    var abilities: [Ability]

    init() { }

    init(id: UUID? = nil, dungeonID: UUID, name: String, healingSummary: String? = nil, positioning: String? = nil, cooldownPriority: String? = nil, orderIndex: Int) {
        self.id = id
        self.$dungeon.id = dungeonID
        self.name = name
        self.healingSummary = healingSummary
        self.positioning = positioning
        self.cooldownPriority = cooldownPriority
        self.orderIndex = orderIndex
    }
}

// MARK: - Validations
extension BossEncounter: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("name", as: String.self, is: !.empty)
        validations.add("order_index", as: Int.self, is: .range(1...))
        validations.add("healing_summary", as: String?.self, is: .nil || .count(...300), required: false)
        validations.add("positioning", as: String?.self, is: .nil || .count(...200), required: false)
        validations.add("cooldown_priority", as: String?.self, is: .nil || .count(...200), required: false)
    }
}

// MARK: - Response DTOs
struct BossEncounterResponse: Content {
    let id: UUID
    let name: String
    let healingSummary: String?
    let positioning: String?
    let cooldownPriority: String?
    let orderIndex: Int
    let abilityCount: Int

    init(from bossEncounter: BossEncounter, abilityCount: Int) {
        self.id = bossEncounter.id!
        self.name = bossEncounter.name
        self.healingSummary = bossEncounter.healingSummary
        self.positioning = bossEncounter.positioning
        self.cooldownPriority = bossEncounter.cooldownPriority
        self.orderIndex = bossEncounter.orderIndex
        self.abilityCount = abilityCount
    }
}

// MARK: - Extensions
extension BossEncounter {
    func toResponse(on db: Database) async throws -> BossEncounterResponse {
        let abilityCount = try await self.$abilities.query(on: db).count()
        return BossEncounterResponse(from: self, abilityCount: abilityCount)
    }
}