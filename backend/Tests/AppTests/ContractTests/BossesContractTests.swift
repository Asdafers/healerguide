import XCTVapor
@testable import App

final class BossesContractTests: XCTestCase {
    var app: Application!

    override func setUpWithError() throws {
        app = Application(.testing)
        try configure(app)
    }

    override func tearDownWithError() throws {
        app.shutdown()
    }

    // T015: Contract test GET /api/v1/dungeons/{id}/bosses
    func testGetBossesByDungeon_WithValidDungeonId_ReturnsBossesList() throws {
        let dungeonId = "550e8400-e29b-41d4-a716-446655440001"

        try app.test(.GET, "/api/v1/dungeons/\(dungeonId)/bosses") { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(res.headers.contentType, .json)

            let bosses = try res.content.decode([BossEncounterResponse].self)
            XCTAssertGreaterThanOrEqual(bosses.count, 0)

            // Validate boss encounter structure if bosses exist
            if let firstBoss = bosses.first {
                XCTAssertFalse(firstBoss.id.isEmpty)
                XCTAssertFalse(firstBoss.name.isEmpty)
                XCTAssertGreaterThan(firstBoss.orderIndex, 0)
                XCTAssertGreaterThanOrEqual(firstBoss.abilityCount, 0)
            }

            // Validate order indices are sequential if multiple bosses
            if bosses.count > 1 {
                let sortedBosses = bosses.sorted { $0.orderIndex < $1.orderIndex }
                for (index, boss) in sortedBosses.enumerated() {
                    XCTAssertEqual(boss.orderIndex, index + 1)
                }
            }
        }
    }

    func testGetBossesByDungeon_WithInvalidDungeonId_Returns404() throws {
        let invalidDungeonId = "00000000-0000-0000-0000-000000000000"

        try app.test(.GET, "/api/v1/dungeons/\(invalidDungeonId)/bosses") { res in
            XCTAssertEqual(res.status, .notFound)

            let error = try res.content.decode(ErrorResponse.self)
            XCTAssertEqual(error.error, "not_found")
        }
    }

    // T016: Contract test GET /api/v1/bosses/{id}
    func testGetBossById_WithValidId_ReturnsBossDetails() throws {
        let bossId = "550e8400-e29b-41d4-a716-446655440002"

        try app.test(.GET, "/api/v1/bosses/\(bossId)") { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(res.headers.contentType, .json)

            let boss = try res.content.decode(BossEncounterResponse.self)
            XCTAssertEqual(boss.id, bossId)
            XCTAssertFalse(boss.name.isEmpty)
            XCTAssertGreaterThan(boss.orderIndex, 0)

            // Validate healer-specific fields
            if let healingSummary = boss.healingSummary {
                XCTAssertFalse(healingSummary.isEmpty)
                XCTAssertLessThanOrEqual(healingSummary.count, 300)
            }

            if let positioning = boss.positioning {
                XCTAssertLessThanOrEqual(positioning.count, 200)
            }

            if let cooldownPriority = boss.cooldownPriority {
                XCTAssertLessThanOrEqual(cooldownPriority.count, 200)
            }
        }
    }

    func testGetBossById_WithInvalidId_Returns404() throws {
        let invalidId = "00000000-0000-0000-0000-000000000000"

        try app.test(.GET, "/api/v1/bosses/\(invalidId)") { res in
            XCTAssertEqual(res.status, .notFound)

            let error = try res.content.decode(ErrorResponse.self)
            XCTAssertEqual(error.error, "not_found")
        }
    }

    func testGetBossById_WithMalformedId_Returns400() throws {
        let malformedId = "not-a-uuid"

        try app.test(.GET, "/api/v1/bosses/\(malformedId)") { res in
            XCTAssertEqual(res.status, .badRequest)
        }
    }
}

struct BossEncounterResponse: Codable {
    let id: String
    let name: String
    let healingSummary: String?
    let positioning: String?
    let cooldownPriority: String?
    let orderIndex: Int
    let abilityCount: Int
}