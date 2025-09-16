//
//  BossEncounterContentValidationTests.swift
//  DungeonKitTests
//
//  Content validation tests to ensure all boss encounters have complete data
//  Validates that all bosses have required healer information and mechanics
//

import XCTest
import CoreData
@testable import DungeonKit

final class BossEncounterContentValidationTests: XCTestCase {

    // MARK: - Test Infrastructure

    var persistentContainer: NSPersistentContainer!
    var context: NSManagedObjectContext!
    var testSeason: Season!
    var testDungeons: [Dungeon] = []

    override func setUpWithError() throws {
        try super.setUpWithError()

        persistentContainer = NSPersistentContainer(name: "DungeonKit")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        description.shouldAddStoreAsynchronously = false
        persistentContainer.persistentStoreDescriptions = [description]

        persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load test store: \(error)")
            }
        }

        context = persistentContainer.viewContext
        testSeason = Season(context: context, name: "Test Season", majorPatchVersion: "11.0", isActive: true)
        try createTestData()
    }

    override func tearDownWithError() throws {
        testDungeons.removeAll()
        testSeason = nil
        context = nil
        persistentContainer = nil
        try super.tearDownWithError()
    }

    // MARK: - Boss Encounter Presence Validation Tests

    func testAllDungeonsHaveRequiredBossEncounters() throws {
        // Act
        let dungeons = try Dungeon.fetchDungeonsForActiveSeason(context: context)

        // Assert
        for dungeon in dungeons {
            XCTAssertTrue(dungeon.hasMinimumBossEncounters,
                         "Dungeon \(dungeon.name ?? "unknown") must have at least 1 boss encounter")

            let bosses = try BossEncounter.fetchBossEncounters(for: dungeon, context: context)
            XCTAssertGreaterThanOrEqual(bosses.count, 3,
                                      "Dungeon \(dungeon.name ?? "unknown") should have at least 3 bosses")
            XCTAssertLessThanOrEqual(bosses.count, 4,
                                   "Dungeon \(dungeon.name ?? "unknown") should have at most 4 bosses")
        }
    }

    func testBossEncountersHaveSequentialOrdering() throws {
        // Act
        let dungeons = try Dungeon.fetchDungeonsForActiveSeason(context: context)

        // Assert
        for dungeon in dungeons {
            let bosses = try BossEncounter.fetchBossEncounters(for: dungeon, context: context)

            // Verify sequential encounter orders starting from 1
            for (index, boss) in bosses.enumerated() {
                XCTAssertEqual(boss.encounterOrder, Int16(index + 1),
                              "Boss encounter order should be sequential in \(dungeon.name ?? "unknown")")
            }
        }
    }

    func testBossEncountersHaveUniqueNamesWithinDungeon() throws {
        // Act
        let dungeons = try Dungeon.fetchDungeonsForActiveSeason(context: context)

        // Assert
        for dungeon in dungeons {
            let bosses = try BossEncounter.fetchBossEncounters(for: dungeon, context: context)
            let names = bosses.compactMap { $0.name }
            let uniqueNames = Set(names)

            XCTAssertEqual(names.count, uniqueNames.count,
                          "Duplicate boss names found in dungeon \(dungeon.name ?? "unknown")")
        }
    }

    // MARK: - Boss Encounter Content Completeness Tests

    func testAllBossEncountersHaveRequiredFields() throws {
        // Act
        let allBosses = try fetchAllBossEncounters()

        // Assert
        for boss in allBosses {
            // Required fields
            XCTAssertNotNil(boss.id, "Boss encounter ID is missing for \(boss.name ?? "unknown")")

            XCTAssertNotNil(boss.name, "Boss encounter name is missing")
            XCTAssertFalse(boss.name?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true,
                          "Boss encounter name is empty")

            XCTAssertNotNil(boss.healerSummary, "Healer summary is missing for \(boss.name ?? "unknown")")
            XCTAssertFalse(boss.healerSummary?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true,
                          "Healer summary is empty for \(boss.name ?? "unknown")")

            XCTAssertNotNil(boss.difficulty, "Difficulty rating is missing for \(boss.name ?? "unknown")")
            XCTAssertGreaterThan(boss.encounterOrder, 0,
                               "Encounter order must be positive for \(boss.name ?? "unknown")")
            XCTAssertGreaterThanOrEqual(boss.estimatedDuration, 0,
                                      "Estimated duration cannot be negative for \(boss.name ?? "unknown")")
        }
    }

    func testAllBossEncountersHaveQualityHealerSummaries() throws {
        // Act
        let allBosses = try fetchAllBossEncounters()

        // Assert
        for boss in allBosses {
            guard let summary = boss.healerSummary else {
                XCTFail("Boss \(boss.name ?? "unknown") missing healer summary")
                continue
            }

            // Content quality checks
            XCTAssertGreaterThanOrEqual(summary.count, 50,
                                      "Healer summary too short for \(boss.name ?? "unknown"): \(summary.count) characters")
            XCTAssertLessThanOrEqual(summary.count, 500,
                                   "Healer summary too long for \(boss.name ?? "unknown"): \(summary.count) characters")

            // Check for healer-specific keywords
            let lowercaseSummary = summary.lowercased()
            let healerKeywords = ["heal", "damage", "position", "cooldown", "tank", "raid", "dispel", "interrupt"]
            let hasHealerContent = healerKeywords.contains { lowercaseSummary.contains($0) }

            XCTAssertTrue(hasHealerContent,
                         "Healer summary for \(boss.name ?? "unknown") should contain healer-specific guidance")
        }
    }

    func testAllBossEncountersHaveAppropriateKeyMechanics() throws {
        // Act
        let allBosses = try fetchAllBossEncounters()

        // Assert
        for boss in allBosses {
            let mechanics = boss.getKeyMechanics()

            // Should have at least 1 key mechanic, max 3
            XCTAssertGreaterThanOrEqual(mechanics.count, 1,
                                      "Boss \(boss.name ?? "unknown") should have at least 1 key mechanic")
            XCTAssertLessThanOrEqual(mechanics.count, 3,
                                   "Boss \(boss.name ?? "unknown") should have at most 3 key mechanics")

            // Each mechanic should be meaningful
            for mechanic in mechanics {
                XCTAssertGreaterThanOrEqual(mechanic.count, 5,
                                          "Key mechanic '\(mechanic)' too short for \(boss.name ?? "unknown")")
                XCTAssertLessThanOrEqual(mechanic.count, 50,
                                       "Key mechanic '\(mechanic)' too long for \(boss.name ?? "unknown")")
            }
        }
    }

    func testAllBossEncountersHaveReasonableDifficulties() throws {
        // Act
        let allBosses = try fetchAllBossEncounters()

        // Assert - Check difficulty distribution
        let difficultyCount = allBosses.reduce(into: [HealerDifficulty: Int]()) { counts, boss in
            if let difficulty = boss.difficulty {
                counts[difficulty, default: 0] += 1
            }
        }

        // Should have variety in difficulties
        XCTAssertGreaterThanOrEqual(difficultyCount.keys.count, 2,
                                  "Boss encounters should have variety in difficulty ratings")

        // Each boss should have valid difficulty
        for boss in allBosses {
            XCTAssertNotNil(boss.difficulty,
                           "Boss \(boss.name ?? "unknown") must have a valid difficulty rating")
        }
    }

    func testBossEncountersHaveReasonableEstimatedDurations() throws {
        // Act
        let allBosses = try fetchAllBossEncounters()

        // Assert - Boss fights typically take 2-8 minutes
        for boss in allBosses {
            let durationInMinutes = boss.estimatedDuration / 60
            XCTAssertGreaterThanOrEqual(durationInMinutes, 1,
                                      "Estimated duration too short for \(boss.name ?? "unknown"): \(durationInMinutes) minutes")
            XCTAssertLessThanOrEqual(durationInMinutes, 10,
                                   "Estimated duration too long for \(boss.name ?? "unknown"): \(durationInMinutes) minutes")
        }
    }

    // MARK: - Boss Encounter Search and Query Tests

    func testAllBossEncountersAreSearchable() throws {
        // Act
        let allBosses = try fetchAllBossEncounters()

        // Assert
        for boss in allBosses {
            guard let bossName = boss.name else {
                XCTFail("Boss missing name")
                continue
            }

            // Test full name search
            let searchResults = try BossEncounter.searchBossEncounters(query: bossName, context: context)
            XCTAssertTrue(searchResults.contains(boss),
                         "Boss \(bossName) not found when searching by full name")

            // Test partial name search (first word if long enough)
            let firstWord = bossName.components(separatedBy: " ").first ?? bossName
            if firstWord.count > 4 {
                let partialResults = try BossEncounter.searchBossEncounters(query: firstWord, context: context)
                XCTAssertTrue(partialResults.contains(boss),
                             "Boss \(bossName) not found when searching by partial name '\(firstWord)'")
            }
        }
    }

    func testBossEncountersByDifficultyRetrieval() throws {
        // Act & Assert for each difficulty level
        for difficulty in HealerDifficulty.allCases {
            let bosses = try BossEncounter.fetchBossEncounters(difficulty: difficulty, context: context)

            for boss in bosses {
                XCTAssertEqual(boss.difficulty, difficulty,
                              "Boss \(boss.name ?? "unknown") should have difficulty \(difficulty.displayName)")
            }
        }
    }

    // MARK: - Performance Tests

    func testFetchAllBossEncountersPerformance() throws {
        measure {
            do {
                _ = try fetchAllBossEncounters()
            } catch {
                XCTFail("Failed to fetch boss encounters: \(error)")
            }
        }
    }

    // MARK: - Helper Methods

    private func fetchAllBossEncounters() throws -> [BossEncounter] {
        let request: NSFetchRequest<BossEncounter> = BossEncounter.fetchRequest()
        return try context.fetch(request)
    }

    private func createTestData() throws {
        let dungeonData = [
            ("Test Dungeon 1", "TD1", 3),
            ("Test Dungeon 2", "TD2", 4),
            ("Test Dungeon 3", "TD3", 3)
        ]

        for (index, (name, shortName, bossCount)) in dungeonData.enumerated() {
            let dungeon = Dungeon(
                context: context,
                name: name,
                shortName: shortName,
                difficultyLevel: .mythicPlus,
                displayOrder: Int16(index + 1),
                estimatedDuration: TimeInterval((25 + index * 5) * 60)
            )

            testSeason.addToDungeons(dungeon)
            testDungeons.append(dungeon)

            // Create boss encounters with realistic data
            for bossIndex in 1...bossCount {
                let difficulties: [HealerDifficulty] = [.easy, .moderate, .hard, .extreme]
                let difficulty = difficulties[bossIndex % difficulties.count]

                let boss = BossEncounter(
                    context: context,
                    name: "\(name) Boss \(bossIndex)",
                    encounterOrder: Int16(bossIndex),
                    healerSummary: "Focus on tank healing during phase 1. Use cooldowns for heavy damage phases. Position away from cleave mechanics. Dispel magic debuffs quickly.",
                    difficultyRating: difficulty,
                    estimatedDuration: TimeInterval(120 + bossIndex * 60),
                    keyMechanics: ["Cleave Attack", "Magic Debuff", "Heavy Damage Phase"]
                )

                dungeon.addToBossEncounters(boss)
            }
        }

        try context.save()
    }
}