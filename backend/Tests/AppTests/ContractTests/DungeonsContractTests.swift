import XCTVapor
@testable import App

final class DungeonsContractTests: XCTestCase {
    var app: Application!

    override func setUpWithError() throws {
        app = Application(.testing)
        try configure(app)
    }

    override func tearDownWithError() throws {
        app.shutdown()
    }

    // T013: Contract test GET /api/v1/seasons/{id}/dungeons
    func testGetDungeonsBySeason_WithValidSeasonId_ReturnsDungeonsList() throws {
        let seasonId = "550e8400-e29b-41d4-a716-446655440000"

        try app.test(.GET, "/api/v1/seasons/\(seasonId)/dungeons") { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(res.headers.contentType, .json)

            let dungeons = try res.content.decode([DungeonResponse].self)
            XCTAssertGreaterThanOrEqual(dungeons.count, 0)

            // Validate dungeon structure if dungeons exist
            if let firstDungeon = dungeons.first {
                XCTAssertFalse(firstDungeon.id.isEmpty)
                XCTAssertFalse(firstDungeon.name.isEmpty)
                XCTAssertFalse(firstDungeon.shortName.isEmpty)
                XCTAssertGreaterThan(firstDungeon.estimatedDuration, 0)
                XCTAssertTrue((1...5).contains(firstDungeon.difficultyRating))
                XCTAssertGreaterThanOrEqual(firstDungeon.bossCount, 0)
            }
        }
    }

    func testGetDungeonsBySeason_WithInvalidSeasonId_Returns404() throws {
        let invalidSeasonId = "00000000-0000-0000-0000-000000000000"

        try app.test(.GET, "/api/v1/seasons/\(invalidSeasonId)/dungeons") { res in
            XCTAssertEqual(res.status, .notFound)

            let error = try res.content.decode(ErrorResponse.self)
            XCTAssertEqual(error.error, "not_found")
        }
    }

    // T014: Contract test GET /api/v1/dungeons/{id}
    func testGetDungeonById_WithValidId_ReturnsDungeonDetails() throws {
        let dungeonId = "550e8400-e29b-41d4-a716-446655440001"

        try app.test(.GET, "/api/v1/dungeons/\(dungeonId)") { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(res.headers.contentType, .json)

            let dungeon = try res.content.decode(DungeonResponse.self)
            XCTAssertEqual(dungeon.id, dungeonId)
            XCTAssertFalse(dungeon.name.isEmpty)
            XCTAssertFalse(dungeon.shortName.isEmpty)
            XCTAssertLessThanOrEqual(dungeon.shortName.count, 20)
            XCTAssertTrue((15...60).contains(dungeon.estimatedDuration))
            XCTAssertTrue((1...5).contains(dungeon.difficultyRating))
        }
    }

    func testGetDungeonById_WithInvalidId_Returns404() throws {
        let invalidId = "00000000-0000-0000-0000-000000000000"

        try app.test(.GET, "/api/v1/dungeons/\(invalidId)") { res in
            XCTAssertEqual(res.status, .notFound)

            let error = try res.content.decode(ErrorResponse.self)
            XCTAssertEqual(error.error, "not_found")
        }
    }

    func testGetDungeonById_WithMalformedId_Returns400() throws {
        let malformedId = "not-a-uuid"

        try app.test(.GET, "/api/v1/dungeons/\(malformedId)") { res in
            XCTAssertEqual(res.status, .badRequest)
        }
    }
}

struct DungeonResponse: Codable {
    let id: String
    let name: String
    let shortName: String
    let healerNotes: String?
    let estimatedDuration: Int
    let difficultyRating: Int
    let bossCount: Int
}