import XCTVapor
@testable import App

final class AbilitiesContractTests: XCTestCase {
    var app: Application!

    override func setUpWithError() throws {
        app = Application(.testing)
        try configure(app)
    }

    override func tearDownWithError() throws {
        app.shutdown()
    }

    // T017: Contract test GET /api/v1/bosses/{id}/abilities
    func testGetAbilitiesByBoss_WithValidBossId_ReturnsAbilitiesList() throws {
        let bossId = "550e8400-e29b-41d4-a716-446655440002"

        try app.test(.GET, "/api/v1/bosses/\(bossId)/abilities") { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(res.headers.contentType, .json)

            let abilities = try res.content.decode([AbilityResponse].self)
            XCTAssertGreaterThanOrEqual(abilities.count, 0)

            // Validate ability structure if abilities exist
            if let firstAbility = abilities.first {
                XCTAssertFalse(firstAbility.id.isEmpty)
                XCTAssertFalse(firstAbility.name.isEmpty)
                XCTAssertTrue(DamageProfile.allCases.map(\.rawValue).contains(firstAbility.damageProfile.rawValue))
                XCTAssertGreaterThanOrEqual(firstAbility.castTime, 0)
                XCTAssertGreaterThanOrEqual(firstAbility.cooldown, 0)
                XCTAssertTrue((1...40).contains(firstAbility.affectedTargets))
            }
        }
    }

    func testGetAbilitiesByBoss_WithDamageProfileFilter_ReturnsFilteredAbilities() throws {
        let bossId = "550e8400-e29b-41d4-a716-446655440002"

        try app.test(.GET, "/api/v1/bosses/\(bossId)/abilities?damage_profile=Critical") { res in
            XCTAssertEqual(res.status, .ok)

            let abilities = try res.content.decode([AbilityResponse].self)

            // All returned abilities should have Critical damage profile
            for ability in abilities {
                XCTAssertEqual(ability.damageProfile, .critical)
            }
        }
    }

    func testGetAbilitiesByBoss_WithInvalidBossId_Returns404() throws {
        let invalidBossId = "00000000-0000-0000-0000-000000000000"

        try app.test(.GET, "/api/v1/bosses/\(invalidBossId)/abilities") { res in
            XCTAssertEqual(res.status, .notFound)

            let error = try res.content.decode(ErrorResponse.self)
            XCTAssertEqual(error.error, "not_found")
        }
    }

    // T018: Contract test GET /api/v1/abilities/{id}
    func testGetAbilityById_WithValidId_ReturnsAbilityDetails() throws {
        let abilityId = "550e8400-e29b-41d4-a716-446655440003"

        try app.test(.GET, "/api/v1/abilities/\(abilityId)") { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(res.headers.contentType, .json)

            let ability = try res.content.decode(AbilityResponse.self)
            XCTAssertEqual(ability.id, abilityId)
            XCTAssertFalse(ability.name.isEmpty)
            XCTAssertTrue(DamageProfile.allCases.map(\.rawValue).contains(ability.damageProfile.rawValue))

            // Validate healer-specific fields
            if let healerAction = ability.healerAction {
                XCTAssertFalse(healerAction.isEmpty)
                XCTAssertLessThanOrEqual(healerAction.count, 200)
            }

            // Validate constraints
            XCTAssertGreaterThanOrEqual(ability.castTime, 0)
            XCTAssertGreaterThanOrEqual(ability.cooldown, 0)
            XCTAssertTrue((1...40).contains(ability.affectedTargets))
        }
    }

    func testGetAbilityById_WithInvalidId_Returns404() throws {
        let invalidId = "00000000-0000-0000-0000-000000000000"

        try app.test(.GET, "/api/v1/abilities/\(invalidId)") { res in
            XCTAssertEqual(res.status, .notFound)

            let error = try res.content.decode(ErrorResponse.self)
            XCTAssertEqual(error.error, "not_found")
        }
    }

    func testGetAbilityById_WithMalformedId_Returns400() throws {
        let malformedId = "not-a-uuid"

        try app.test(.GET, "/api/v1/abilities/\(malformedId)") { res in
            XCTAssertEqual(res.status, .badRequest)
        }
    }
}

struct AbilityResponse: Codable {
    let id: String
    let name: String
    let description: String?
    let damageProfile: DamageProfile
    let healerAction: String?
    let castTime: Int
    let cooldown: Int
    let isChanneled: Bool
    let affectedTargets: Int
}

enum DamageProfile: String, Codable, CaseIterable {
    case critical = "Critical"
    case high = "High"
    case moderate = "Moderate"
    case mechanic = "Mechanic"
}