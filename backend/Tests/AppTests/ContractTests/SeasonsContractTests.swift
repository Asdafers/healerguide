import XCTVapor
@testable import App

final class SeasonsContractTests: XCTestCase {
    var app: Application!

    override func setUpWithError() throws {
        app = Application(.testing)
        try configure(app)
    }

    override func tearDownWithError() throws {
        app.shutdown()
    }

    // T011: Contract test GET /api/v1/seasons
    func testGetSeasons_ReturnsSeasonsList() throws {
        try app.test(.GET, "/api/v1/seasons") { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(res.headers.contentType, .json)

            let seasons = try res.content.decode([SeasonResponse].self)
            XCTAssertGreaterThanOrEqual(seasons.count, 0)

            // If seasons exist, validate structure
            if let firstSeason = seasons.first {
                XCTAssertFalse(firstSeason.id.isEmpty)
                XCTAssertFalse(firstSeason.name.isEmpty)
                XCTAssertTrue(firstSeason.majorVersion.matches(regex: "^\\d+\\.\\d+$"))
                XCTAssertGreaterThanOrEqual(firstSeason.dungeonCount, 0)
            }
        }
    }

    func testGetSeasons_WithActiveOnlyParameter_ReturnsActiveSeason() throws {
        try app.test(.GET, "/api/v1/seasons?active_only=true") { res in
            XCTAssertEqual(res.status, .ok)

            let seasons = try res.content.decode([SeasonResponse].self)

            // Should return at most one active season
            XCTAssertLessThanOrEqual(seasons.count, 1)

            // If active season exists, it should be marked as active
            if let activeSeason = seasons.first {
                XCTAssertTrue(activeSeason.isActive)
            }
        }
    }

    // T012: Contract test GET /api/v1/seasons/{id}
    func testGetSeasonById_WithValidId_ReturnsSeasonDetails() throws {
        // This test will initially fail - we need to implement the endpoint
        let seasonId = "550e8400-e29b-41d4-a716-446655440000" // Sample season ID

        try app.test(.GET, "/api/v1/seasons/\(seasonId)") { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(res.headers.contentType, .json)

            let season = try res.content.decode(SeasonResponse.self)
            XCTAssertEqual(season.id, seasonId)
            XCTAssertFalse(season.name.isEmpty)
            XCTAssertTrue(season.majorVersion.matches(regex: "^\\d+\\.\\d+$"))
        }
    }

    func testGetSeasonById_WithInvalidId_Returns404() throws {
        let invalidId = "00000000-0000-0000-0000-000000000000"

        try app.test(.GET, "/api/v1/seasons/\(invalidId)") { res in
            XCTAssertEqual(res.status, .notFound)

            let error = try res.content.decode(ErrorResponse.self)
            XCTAssertEqual(error.error, "not_found")
            XCTAssertFalse(error.message.isEmpty)
        }
    }

    func testGetSeasonById_WithMalformedId_Returns400() throws {
        let malformedId = "not-a-uuid"

        try app.test(.GET, "/api/v1/seasons/\(malformedId)") { res in
            XCTAssertEqual(res.status, .badRequest)
        }
    }
}

// Response models for contract testing
struct SeasonResponse: Codable {
    let id: String
    let majorVersion: String
    let name: String
    let isActive: Bool
    let dungeonCount: Int
}

struct ErrorResponse: Codable {
    let error: String
    let message: String
    let details: [String: String]?
}

// Helper extension for regex matching
extension String {
    func matches(regex: String) -> Bool {
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: self)
    }
}