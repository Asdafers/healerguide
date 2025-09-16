@testable import App
import XCTVapor
import Fluent

final class Season3IntegrationTests: XCTestCase {
    var app: Application!

    override func setUp() async throws {
        app = try await Application.make(.testing)
        try await configure(app)
        try await app.autoMigrate()
    }

    override func tearDown() async throws {
        try await app.autoRevert()
        try await app.asyncShutdown()
    }

    // MARK: - Season 3 API Integration Tests

    func testSeason3APIEndpoints() async throws {
        // Test seasons endpoint returns Season 3
        try await app.test(.GET, "/api/v1/seasons?active_only=true") { res async in
            XCTAssertEqual(res.status, .ok)

            let seasons = try res.content.decode([SeasonResponse].self)
            XCTAssertEqual(seasons.count, 1, "Should have exactly 1 active season")

            let season = seasons.first!
            XCTAssertEqual(season.majorVersion, "11.2", "Should be Season 3 (patch 11.2)")
            XCTAssertEqual(season.name, "The War Within Season 3")
            XCTAssertEqual(season.dungeonCount, 8, "Should have 8 dungeons")
            XCTAssertTrue(season.isActive, "Season should be active")
        }
    }

    func testDungeonListAPICompleteness() async throws {
        // Get active season
        let season = try await app.test(.GET, "/api/v1/seasons?active_only=true") { res async -> SeasonResponse in
            let seasons = try res.content.decode([SeasonResponse].self)
            return seasons.first!
        }

        // Test dungeons endpoint
        try await app.test(.GET, "/api/v1/seasons/\(season.id)/dungeons") { res async in
            XCTAssertEqual(res.status, .ok)

            let dungeons = try res.content.decode([DungeonResponse].self)
            XCTAssertEqual(dungeons.count, 8, "Should have 8 dungeons")

            let expectedNames = [
                "Ara-Kara, City of Echoes",
                "The Dawnbreaker",
                "Eco-Dome Aldani",
                "Halls of Atonement",
                "Operation: Floodgate",
                "Priory of the Sacred Flame",
                "Tazavesh: Streets of Wonder",
                "Tazavesh: So'leah's Gambit"
            ]

            let dungeonNames = dungeons.map { $0.name }.sorted()
            for expectedName in expectedNames {
                XCTAssertTrue(dungeonNames.contains(expectedName),
                             "Missing dungeon: \(expectedName)")
            }

            // Test healer-specific data exists
            for dungeon in dungeons {
                XCTAssertNotNil(dungeon.healerNotes, "Dungeon should have healer notes: \(dungeon.name)")
                XCTAssertFalse(dungeon.healerNotes?.isEmpty ?? true, "Healer notes should not be empty: \(dungeon.name)")
                XCTAssertGreaterThan(dungeon.estimatedDuration, 0, "Should have duration: \(dungeon.name)")
                XCTAssertGreaterThan(dungeon.difficultyRating, 0, "Should have difficulty: \(dungeon.name)")
            }
        }
    }

    func testBossEncounterAPICompleteness() async throws {
        // Get a dungeon with boss encounters
        let season = try await app.test(.GET, "/api/v1/seasons?active_only=true") { res async -> SeasonResponse in
            let seasons = try res.content.decode([SeasonResponse].self)
            return seasons.first!
        }

        let dungeons = try await app.test(.GET, "/api/v1/seasons/\(season.id)/dungeons") { res async -> [DungeonResponse] in
            return try res.content.decode([DungeonResponse].self)
        }

        let araKara = dungeons.first { $0.name == "Ara-Kara, City of Echoes" }
        XCTAssertNotNil(araKara, "Ara-Kara should exist")

        // Test boss encounters endpoint
        try await app.test(.GET, "/api/v1/dungeons/\(araKara!.id)/bosses") { res async in
            XCTAssertEqual(res.status, .ok)

            let bosses = try res.content.decode([BossEncounterResponse].self)
            XCTAssertGreaterThan(bosses.count, 0, "Should have boss encounters")

            // Test boss encounter completeness
            for boss in bosses {
                XCTAssertFalse(boss.name.isEmpty, "Boss name should not be empty")
                XCTAssertGreaterThan(boss.orderIndex, 0, "Boss should have valid order")

                // Test healer-specific fields
                XCTAssertNotNil(boss.healingSummary, "Boss should have healing summary: \(boss.name)")
                XCTAssertNotNil(boss.positioning, "Boss should have positioning: \(boss.name)")
                XCTAssertNotNil(boss.cooldownPriority, "Boss should have cooldown priority: \(boss.name)")

                if let healingSummary = boss.healingSummary {
                    XCTAssertGreaterThan(healingSummary.count, 20, "Healing summary should be descriptive: \(boss.name)")
                }
            }

            // Test Avanoxx specifically (should be first boss)
            let avanoxx = bosses.first { $0.name == "Avanoxx" }
            XCTAssertNotNil(avanoxx, "Avanoxx should exist as first boss")
            XCTAssertEqual(avanoxx?.orderIndex, 1, "Avanoxx should be first boss")
            XCTAssertGreaterThan(avanoxx?.abilityCount ?? 0, 0, "Avanoxx should have abilities")
        }
    }

    func testAbilityAPICompleteness() async throws {
        // Get Avanoxx boss (known to have abilities)
        let season = try await app.test(.GET, "/api/v1/seasons?active_only=true") { res async -> SeasonResponse in
            let seasons = try res.content.decode([SeasonResponse].self)
            return seasons.first!
        }

        let dungeons = try await app.test(.GET, "/api/v1/seasons/\(season.id)/dungeons") { res async -> [DungeonResponse] in
            return try res.content.decode([DungeonResponse].self)
        }

        let araKara = dungeons.first { $0.name == "Ara-Kara, City of Echoes" }!

        let bosses = try await app.test(.GET, "/api/v1/dungeons/\(araKara.id)/bosses") { res async -> [BossEncounterResponse] in
            return try res.content.decode([BossEncounterResponse].self)
        }

        let avanoxx = bosses.first { $0.name == "Avanoxx" }!

        // Test abilities endpoint
        try await app.test(.GET, "/api/v1/bosses/\(avanoxx.id)/abilities") { res async in
            XCTAssertEqual(res.status, .ok)

            let abilities = try res.content.decode([AbilityResponse].self)
            XCTAssertGreaterThan(abilities.count, 0, "Avanoxx should have abilities")

            // Test ability completeness
            for ability in abilities {
                XCTAssertFalse(ability.name.isEmpty, "Ability name should not be empty")

                // Test damage profile is valid
                let validProfiles = ["Critical", "High", "Moderate", "Mechanic"]
                XCTAssertTrue(validProfiles.contains(ability.damageProfile.rawValue),
                             "Invalid damage profile: \(ability.damageProfile)")

                // Test healer action exists and is meaningful
                XCTAssertNotNil(ability.healerAction, "Ability should have healer action: \(ability.name)")
                if let healerAction = ability.healerAction {
                    XCTAssertGreaterThan(healerAction.count, 10,
                        "Healer action should be descriptive: \(ability.name)")
                }

                // Test timing data
                XCTAssertGreaterThanOrEqual(ability.castTime, 0, "Cast time should be non-negative")
                XCTAssertGreaterThanOrEqual(ability.cooldown, 0, "Cooldown should be non-negative")
                XCTAssertGreaterThan(ability.affectedTargets, 0, "Should affect at least 1 target")
            }

            // Test Alerting Shrill specifically (Critical ability)
            let alertingShrill = abilities.first { $0.name == "Alerting Shrill" }
            XCTAssertNotNil(alertingShrill, "Alerting Shrill should exist")
            XCTAssertEqual(alertingShrill?.damageProfile, .critical, "Alerting Shrill should be Critical")
            XCTAssertGreaterThan(alertingShrill?.cooldown ?? 0, 30000, "Critical ability should have significant cooldown")
        }
    }

    func testHealthEndpoint() async throws {
        try await app.test(.GET, "/health") { res async in
            XCTAssertEqual(res.status, .ok)

            let health = try res.content.decode([String: String].self)
            XCTAssertEqual(health["status"], "healthy")
            XCTAssertEqual(health["database"], "available")
            XCTAssertNotNil(health["timestamp"])
        }
    }

    func testDamageProfileFiltering() async throws {
        // Get abilities for filtering test
        let season = try await app.test(.GET, "/api/v1/seasons?active_only=true") { res async -> SeasonResponse in
            let seasons = try res.content.decode([SeasonResponse].self)
            return seasons.first!
        }

        let dungeons = try await app.test(.GET, "/api/v1/seasons/\(season.id)/dungeons") { res async -> [DungeonResponse] in
            return try res.content.decode([DungeonResponse].self)
        }

        let araKara = dungeons.first { $0.name == "Ara-Kara, City of Echoes" }!

        let bosses = try await app.test(.GET, "/api/v1/dungeons/\(araKara.id)/bosses") { res async -> [BossEncounterResponse] in
            return try res.content.decode([BossEncounterResponse].self)
        }

        let avanoxx = bosses.first { $0.name == "Avanoxx" }!

        // Test filtering by Critical damage profile
        try await app.test(.GET, "/api/v1/bosses/\(avanoxx.id)/abilities?damage_profile=Critical") { res async in
            XCTAssertEqual(res.status, .ok)

            let abilities = try res.content.decode([AbilityResponse].self)

            // Should have at least one Critical ability (Alerting Shrill)
            XCTAssertGreaterThan(abilities.count, 0, "Should have Critical abilities")

            // All returned abilities should be Critical
            for ability in abilities {
                XCTAssertEqual(ability.damageProfile, .critical,
                              "Filtered results should only contain Critical abilities")
            }
        }
    }

    func testCompleteUserWorkflow() async throws {
        // Test the complete user workflow: Season -> Dungeons -> Bosses -> Abilities

        // 1. Get active season
        let season = try await app.test(.GET, "/api/v1/seasons?active_only=true") { res async -> SeasonResponse in
            XCTAssertEqual(res.status, .ok)
            let seasons = try res.content.decode([SeasonResponse].self)
            XCTAssertEqual(seasons.count, 1, "Should have exactly 1 active season")
            return seasons.first!
        }

        // 2. Get dungeons for season
        let dungeons = try await app.test(.GET, "/api/v1/seasons/\(season.id)/dungeons") { res async -> [DungeonResponse] in
            XCTAssertEqual(res.status, .ok)
            let dungeons = try res.content.decode([DungeonResponse].self)
            XCTAssertEqual(dungeons.count, 8, "Should have 8 dungeons")
            return dungeons
        }

        // 3. Get bosses for a dungeon
        let testDungeon = dungeons.first!
        let bosses = try await app.test(.GET, "/api/v1/dungeons/\(testDungeon.id)/bosses") { res async -> [BossEncounterResponse] in
            XCTAssertEqual(res.status, .ok)
            let bosses = try res.content.decode([BossEncounterResponse].self)
            return bosses
        }

        // 4. Get abilities for a boss (if any exist)
        if let firstBoss = bosses.first, firstBoss.abilityCount > 0 {
            try await app.test(.GET, "/api/v1/bosses/\(firstBoss.id)/abilities") { res async in
                XCTAssertEqual(res.status, .ok)
                let abilities = try res.content.decode([AbilityResponse].self)
                XCTAssertGreaterThan(abilities.count, 0, "Boss with abilityCount > 0 should return abilities")

                // Validate each ability has complete healer data
                for ability in abilities {
                    XCTAssertNotNil(ability.healerAction, "Each ability should have healer action")
                    XCTAssertNotNil(ability.description, "Each ability should have description")
                }
            }
        }
    }
}