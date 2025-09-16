import Fluent
import Vapor

// MARK: - Damage Profile Enum
enum DamageProfile: String, Codable, CaseIterable {
    case critical = "Critical"
    case high = "High"
    case moderate = "Moderate"
    case mechanic = "Mechanic"
}

final class Ability: Model, Content {
    static let schema = "abilities"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "boss_encounter_id")
    var bossEncounter: BossEncounter

    @Field(key: "name")
    var name: String

    @OptionalField(key: "description")
    var description: String?

    @Enum(key: "damage_profile")
    var damageProfile: DamageProfile

    @OptionalField(key: "healer_action")
    var healerAction: String?

    @Field(key: "cast_time")
    var castTime: Int

    @Field(key: "cooldown")
    var cooldown: Int

    @Field(key: "is_channeled")
    var isChanneled: Bool

    @Field(key: "affected_targets")
    var affectedTargets: Int

    @OptionalField(key: "metadata")
    var metadata: [String: AnyCodable]?

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    init() { }

    init(id: UUID? = nil, bossEncounterID: UUID, name: String, description: String? = nil, damageProfile: DamageProfile, healerAction: String? = nil, castTime: Int = 0, cooldown: Int = 0, isChanneled: Bool = false, affectedTargets: Int = 1, metadata: [String: AnyCodable]? = nil) {
        self.id = id
        self.$bossEncounter.id = bossEncounterID
        self.name = name
        self.description = description
        self.damageProfile = damageProfile
        self.healerAction = healerAction
        self.castTime = castTime
        self.cooldown = cooldown
        self.isChanneled = isChanneled
        self.affectedTargets = affectedTargets
        self.metadata = metadata
    }
}

// MARK: - Validations
extension Ability: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("name", as: String.self, is: !.empty)
        validations.add("cast_time", as: Int.self, is: .range(0...))
        validations.add("cooldown", as: Int.self, is: .range(0...))
        validations.add("affected_targets", as: Int.self, is: .range(1...40))
        validations.add("healer_action", as: String?.self, is: .nil || .count(...200), required: false)
    }
}

// MARK: - Response DTOs
struct AbilityResponse: Content {
    let id: UUID
    let name: String
    let description: String?
    let damageProfile: DamageProfile
    let healerAction: String?
    let castTime: Int
    let cooldown: Int
    let isChanneled: Bool
    let affectedTargets: Int

    init(from ability: Ability) {
        self.id = ability.id!
        self.name = ability.name
        self.description = ability.description
        self.damageProfile = ability.damageProfile
        self.healerAction = ability.healerAction
        self.castTime = ability.castTime
        self.cooldown = ability.cooldown
        self.isChanneled = ability.isChanneled
        self.affectedTargets = ability.affectedTargets
    }
}

// MARK: - Extensions
extension Ability {
    func toResponse() -> AbilityResponse {
        return AbilityResponse(from: self)
    }
}

// MARK: - AnyCodable for flexible JSON metadata
struct AnyCodable: Codable {
    let value: Any

    init<T>(_ value: T?) {
        self.value = value ?? ()
    }
}

extension AnyCodable: ExpressibleByNilLiteral {
    init(nilLiteral _: ()) {
        self.init(nil as Any?)
    }
}

extension AnyCodable: Equatable {
    static func == (lhs: AnyCodable, rhs: AnyCodable) -> Bool {
        switch (lhs.value, rhs.value) {
        case is (Void, Void):
            return true
        case let (lhs as Bool, rhs as Bool):
            return lhs == rhs
        case let (lhs as Int, rhs as Int):
            return lhs == rhs
        case let (lhs as String, rhs as String):
            return lhs == rhs
        default:
            return false
        }
    }
}

extension AnyCodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if container.decodeNil() {
            self.init(nil as Any?)
        } else if let bool = try? container.decode(Bool.self) {
            self.init(bool)
        } else if let int = try? container.decode(Int.self) {
            self.init(int)
        } else if let string = try? container.decode(String.self) {
            self.init(string)
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "AnyCodable value cannot be decoded")
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch value {
        case is Void:
            try container.encodeNil()
        case let bool as Bool:
            try container.encode(bool)
        case let int as Int:
            try container.encode(int)
        case let string as String:
            try container.encode(string)
        default:
            try container.encodeNil()
        }
    }
}