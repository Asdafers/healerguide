@testable import App
import XCTVapor
import Fluent

final class DataCompletenessTests: XCTestCase {
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

    // MARK: - Season 3 Data Completeness Tests

    func testSeason3DungeonCount() async throws {
        // Ensure exactly 8 Season 3 dungeons exist
        let seasonCount = try await Season.query(on: app.db)
            .filter(\.$isActive == true)
            .filter(\.$majorVersion == "11.2")
            .count()

        XCTAssertEqual(seasonCount, 1, "Should have exactly 1 active Season 3")

        let activeSeason = try await Season.query(on: app.db)
            .filter(\.$isActive == true)
            .first()

        XCTAssertNotNil(activeSeason, "Active season should exist")

        let dungeonCount = try await activeSeason!.$dungeons.query(on: app.db).count()
        XCTAssertEqual(dungeonCount, 8, "Season 3 should have exactly 8 dungeons")
    }

    func testAllSeason3DungeonsPresent() async throws {
        let expectedDungeons = [
            "Ara-Kara, City of Echoes",
            "The Dawnbreaker",
            "Eco-Dome Aldani",
            "Halls of Atonement",
            "Operation: Floodgate",
            "Priory of the Sacred Flame",
            "Tazavesh: Streets of Wonder",
            "Tazavesh: So'leah's Gambit"
        ]

        let activeSeason = try await Season.query(on: app.db)
            .filter(\.$isActive == true)
            .first()

        XCTAssertNotNil(activeSeason, "Active season should exist")

        let dungeons = try await activeSeason!.$dungeons.query(on: app.db).all()
        let dungeonNames = dungeons.map { $0.name }.sorted()

        XCTAssertEqual(dungeonNames.count, 8, "Should have 8 dungeons")

        for expectedName in expectedDungeons {
            XCTAssertTrue(dungeonNames.contains(expectedName),
                         "Missing dungeon: \(expectedName)")
        }
    }

    func testAllDungeonsHaveBossEncounters() async throws {
        let activeSeason = try await Season.query(on: app.db)
            .filter(\.$isActive == true)
            .first()

        XCTAssertNotNil(activeSeason, "Active season should exist")

        let dungeons = try await activeSeason!.$dungeons.query(on: app.db).all()

        let expectedBossCounts = [
            "Ara-Kara, City of Echoes": 3,
            "The Dawnbreaker": 3,
            "Eco-Dome Aldani": 3,
            "Halls of Atonement": 4,
            "Operation: Floodgate": 3,
            "Priory of the Sacred Flame": 3,
            "Tazavesh: Streets of Wonder": 4,
            "Tazavesh: So'leah's Gambit": 4
        ]

        for dungeon in dungeons {
            let bossCount = try await dungeon.$bossEncounters.query(on: app.db).count()
            let expectedCount = expectedBossCounts[dungeon.name] ?? 0

            if expectedCount > 0 {
                XCTAssertGreaterThanOrEqual(bossCount, 1,
                    "\(dungeon.name) should have at least 1 boss encounter (expected \(expectedCount))")
            }
        }
    }

    func testBossEncountersHaveCompleteData() async throws {
        let bossEncounters = try await BossEncounter.query(on: app.db).all()

        XCTAssertGreaterThan(bossEncounters.count, 0, "Should have boss encounters")

        for boss in bossEncounters {
            // Test required fields
            XCTAssertFalse(boss.name.isEmpty, "Boss name should not be empty: \(boss.name)")
            XCTAssertGreaterThan(boss.orderIndex, 0, "Boss order index should be positive: \(boss.name)")

            // Test healer-specific fields exist
            XCTAssertNotNil(boss.healingSummary, "Boss should have healing summary: \(boss.name)")
            XCTAssertNotNil(boss.positioning, "Boss should have positioning info: \(boss.name)")
            XCTAssertNotNil(boss.cooldownPriority, "Boss should have cooldown priority: \(boss.name)")

            // Test healer-specific fields are not empty if present
            if let healingSummary = boss.healingSummary {
                XCTAssertFalse(healingSummary.isEmpty, "Healing summary should not be empty: \(boss.name)")
            }

            if let positioning = boss.positioning {
                XCTAssertFalse(positioning.isEmpty, "Positioning should not be empty: \(boss.name)")
            }

            if let cooldownPriority = boss.cooldownPriority {
                XCTAssertFalse(cooldownPriority.isEmpty, "Cooldown priority should not be empty: \(boss.name)")
            }
        }
    }

    func testCriticalBossesHaveAbilities() async throws {
        // Critical bosses that MUST have abilities documented
        let criticalBosses = [
            "Avanoxx", // Ara-Kara first boss - has Alerting Shrill (Critical)
            "Lord Chamberlain", // Halls final boss - has Ritual of Woe (Critical)
            "Rasha'nan" // Dawnbreaker final boss - has Erosive Spray (Critical)
        ]

        for bossName in criticalBosses {
            let boss = try await BossEncounter.query(on: app.db)
                .filter(\.$name == bossName)
                .first()

            XCTAssertNotNil(boss, "Critical boss should exist: \(bossName)")

            if let boss = boss {
                let abilityCount = try await boss.$abilities.query(on: app.db).count()
                XCTAssertGreaterThan(abilityCount, 0,
                    "Critical boss should have abilities: \(bossName)")
            }
        }
    }

    func testAbilitiesHaveCompleteHealerData() async throws {
        let abilities = try await Ability.query(on: app.db).all()

        XCTAssertGreaterThan(abilities.count, 0, "Should have abilities")

        let validDamageProfiles: Set<String> = ["Critical", "High", "Moderate", "Mechanic"]

        for ability in abilities {
            // Test required fields
            XCTAssertFalse(ability.name.isEmpty, "Ability name should not be empty")

            // Test damage profile is valid
            XCTAssertTrue(validDamageProfiles.contains(ability.damageProfile.rawValue),
                         "Invalid damage profile for \(ability.name): \(ability.damageProfile.rawValue)")

            // Test healer action exists and is meaningful
            XCTAssertNotNil(ability.healerAction, "Ability should have healer action: \(ability.name)")
            if let healerAction = ability.healerAction {
                XCTAssertGreaterThan(healerAction.count, 10,
                    "Healer action should be descriptive: \(ability.name)")
            }

            // Test timing data is reasonable
            XCTAssertGreaterThanOrEqual(ability.castTime, 0, "Cast time should be non-negative")
            XCTAssertGreaterThanOrEqual(ability.cooldown, 0, "Cooldown should be non-negative")
            XCTAssertGreaterThan(ability.affectedTargets, 0, "Should affect at least 1 target")
            XCTAssertLessThanOrEqual(ability.affectedTargets, 40, "Should not affect more than 40 targets")
        }
    }

    func testCriticalAbilitiesExist() async throws {
        // Critical abilities that MUST exist for healer gameplay
        let criticalAbilities = [
            "Alerting Shrill", // Ara-Kara Avanoxx - Critical raid damage
            "Ritual of Woe",   // Halls Lord Chamberlain - Critical sustained damage
            "Unstable Anima"   // Halls High Adjudicator - Critical dispel requirement
        ]

        for abilityName in criticalAbilities {
            let ability = try await Ability.query(on: app.db)
                .filter(\.$name == abilityName)
                .first()

            XCTAssertNotNil(ability, "Critical ability should exist: \(abilityName)")

            if let ability = ability {
                XCTAssertNotNil(ability.healerAction,
                    "Critical ability should have healer action: \(abilityName)")

                // Critical abilities should have meaningful timing
                if ability.damageProfile == .critical {
                    XCTAssertGreaterThan(ability.cooldown, 0,
                        "Critical ability should have cooldown: \(abilityName)")
                }
            }
        }
    }

    func testDamageProfileDistribution() async throws {
        let abilities = try await Ability.query(on: app.db).all()

        let profileCounts = abilities.reduce(into: [DamageProfile: Int]()) { counts, ability in
            counts[ability.damageProfile, default: 0] += 1
        }

        // Should have abilities in each category
        XCTAssertGreaterThan(profileCounts[.critical] ?? 0, 0, "Should have Critical abilities")
        XCTAssertGreaterThan(profileCounts[.high] ?? 0, 0, "Should have High damage abilities")
        XCTAssertGreaterThan(profileCounts[.mechanic] ?? 0, 0, "Should have Mechanic abilities")

        // Critical abilities should be rare but present
        let criticalCount = profileCounts[.critical] ?? 0
        let totalCount = abilities.count
        let criticalRatio = Double(criticalCount) / Double(totalCount)

        XCTAssertLessThan(criticalRatio, 0.5, "Critical abilities should be less than 50% of total")
        XCTAssertGreaterThan(criticalRatio, 0.05, "Critical abilities should be more than 5% of total")
    }
}