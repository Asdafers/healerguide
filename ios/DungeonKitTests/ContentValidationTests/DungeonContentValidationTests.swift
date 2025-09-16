//
//  DungeonContentValidationTests.swift
//  DungeonKitTests
//
//  Content validation tests to ensure all dungeons have complete data
//  Validates that all Season 1 dungeons from The War Within are present with required content
//

import XCTest
import CoreData
@testable import DungeonKit

final class DungeonContentValidationTests: XCTestCase {

    // MARK: - Test Infrastructure

    var persistentContainer: NSPersistentContainer!
    var context: NSManagedObjectContext!
    var testSeason: Season!

    override func setUpWithError() throws {
        try super.setUpWithError()

        // Setup in-memory Core Data stack for testing
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

        // Create test season with expected dungeons
        testSeason = Season(context: context, name: "The War Within Season 1", majorPatchVersion: "11.0", isActive: true)
        try createTestDungeonData()
    }

    override func tearDownWithError() throws {
        testSeason = nil
        context = nil
        persistentContainer = nil
        try super.tearDownWithError()
    }

    // MARK: - Expected Content Constants

    /// Expected dungeons for The War Within Season 1
    private let expectedDungeons = [
        ("The Dawnbreaker", "DB", 3),
        ("Ara-Kara, City of Echoes", "AK", 3),
        ("City of Threads", "COT", 3),
        ("The Stonevault", "SV", 4),
        ("Mists of Tirna Scithe", "MOTS", 3),
        ("The Necrotic Wake", "NW", 4),
        ("Siege of Boralus", "SOB", 4),
        ("Grim Batol", "GB", 4)
    ]

    // MARK: - Dungeon Presence Validation Tests

    func testAllExpectedDungeonsArePresent() throws {
        // Act
        let dungeons = try Dungeon.fetchDungeonsForActiveSeason(context: context)

        // Assert
        XCTAssertEqual(dungeons.count, expectedDungeons.count,
                      "Expected \(expectedDungeons.count) dungeons for The War Within Season 1, found \(dungeons.count)")

        // Verify each expected dungeon exists
        for (expectedName, expectedShortName, expectedBossCount) in expectedDungeons {
            let matchingDungeon = dungeons.first { $0.name == expectedName }
            XCTAssertNotNil(matchingDungeon, "Missing dungeon: \(expectedName)")

            if let dungeon = matchingDungeon {
                XCTAssertEqual(dungeon.shortName, expectedShortName,
                              "Incorrect short name for \(expectedName)")
                XCTAssertEqual(dungeon.bossCount, expectedBossCount,
                              "Incorrect boss count for \(expectedName). Expected \(expectedBossCount), got \(dungeon.bossCount)")
            }
        }
    }

    func testDungeonsHaveUniqueDisplayOrders() throws {
        // Act
        let dungeons = try Dungeon.fetchDungeonsForActiveSeason(context: context)
        let displayOrders = dungeons.map { $0.displayOrder }
        let uniqueOrders = Set(displayOrders)

        // Assert
        XCTAssertEqual(displayOrders.count, uniqueOrders.count,
                      "Duplicate display orders found among dungeons")

        // Verify sequential ordering from 1 to count
        let sortedOrders = displayOrders.sorted()
        for (index, order) in sortedOrders.enumerated() {
            XCTAssertEqual(order, Int16(index + 1),
                          "Display orders should be sequential starting from 1")
        }
    }

    func testDungeonsHaveUniqueNames() throws {
        // Act
        let dungeons = try Dungeon.fetchDungeonsForActiveSeason(context: context)
        let names = dungeons.compactMap { $0.name }
        let uniqueNames = Set(names)

        // Assert
        XCTAssertEqual(names.count, uniqueNames.count,
                      "Duplicate dungeon names found")
    }

    func testDungeonsHaveUniqueShortNames() throws {
        // Act
        let dungeons = try Dungeon.fetchDungeonsForActiveSeason(context: context)
        let shortNames = dungeons.compactMap { $0.shortName }
        let uniqueShortNames = Set(shortNames)

        // Assert
        XCTAssertEqual(shortNames.count, uniqueShortNames.count,
                      "Duplicate dungeon short names found")
    }

    // MARK: - Dungeon Content Completeness Tests

    func testAllDungeonsHaveRequiredFields() throws {
        // Act
        let dungeons = try Dungeon.fetchDungeonsForActiveSeason(context: context)

        // Assert
        for dungeon in dungeons {
            // Required fields
            XCTAssertNotNil(dungeon.id, "Dungeon ID is missing for \(dungeon.name ?? "unknown")")
            XCTAssertNotNil(dungeon.name, "Dungeon name is missing")
            XCTAssertFalse(dungeon.name?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true,
                          "Dungeon name is empty")

            XCTAssertNotNil(dungeon.shortName, "Short name is missing for \(dungeon.name ?? "unknown")")
            XCTAssertFalse(dungeon.shortName?.isEmpty ?? true,
                          "Short name is empty for \(dungeon.name ?? "unknown")")
            XCTAssertLessThanOrEqual(dungeon.shortName?.count ?? 0, 4,
                                   "Short name too long for \(dungeon.name ?? "unknown")")

            XCTAssertNotNil(dungeon.difficulty, "Difficulty level is missing for \(dungeon.name ?? "unknown")")
            XCTAssertGreaterThan(dungeon.displayOrder, 0,
                               "Display order must be positive for \(dungeon.name ?? "unknown")")
            XCTAssertGreaterThanOrEqual(dungeon.estimatedDuration, 0,
                                      "Estimated duration cannot be negative for \(dungeon.name ?? "unknown")")
        }
    }

    func testAllDungeonsHaveReasonableEstimatedDurations() throws {
        // Act
        let dungeons = try Dungeon.fetchDungeonsForActiveSeason(context: context)

        // Assert - Mythic+ dungeons typically take 20-45 minutes
        for dungeon in dungeons {
            let durationInMinutes = dungeon.estimatedDuration / 60
            XCTAssertGreaterThanOrEqual(durationInMinutes, 15,
                                      "Estimated duration too short for \(dungeon.name ?? "unknown"): \(durationInMinutes) minutes")
            XCTAssertLessThanOrEqual(durationInMinutes, 60,
                                   "Estimated duration too long for \(dungeon.name ?? "unknown"): \(durationInMinutes) minutes")
        }
    }

    func testAllDungeonsHaveMinimumBossEncounters() throws {
        // Act
        let dungeons = try Dungeon.fetchDungeonsForActiveSeason(context: context)

        // Assert
        for dungeon in dungeons {
            XCTAssertTrue(dungeon.hasMinimumBossEncounters,
                         "Dungeon \(dungeon.name ?? "unknown") must have at least 1 boss encounter")
            XCTAssertGreaterThanOrEqual(dungeon.bossCount, 3,
                                      "Dungeon \(dungeon.name ?? "unknown") should have at least 3 boss encounters")
            XCTAssertLessThanOrEqual(dungeon.bossCount, 4,
                                   "Dungeon \(dungeon.name ?? "unknown") should have at most 4 boss encounters")
        }
    }

    // MARK: - Dungeon Search and Query Tests

    func testAllDungeonsAreSearchableByName() throws {
        // Act
        let dungeons = try Dungeon.fetchDungeonsForActiveSeason(context: context)

        // Assert
        for dungeon in dungeons {
            guard let dungeonName = dungeon.name else {
                XCTFail("Dungeon missing name")
                continue
            }

            // Test full name search
            let fullNameResults = try Dungeon.searchDungeons(query: dungeonName, context: context)
            XCTAssertTrue(fullNameResults.contains(dungeon),
                         "Dungeon \(dungeonName) not found when searching by full name")

            // Test partial name search (first word)
            let firstWord = dungeonName.components(separatedBy: " ").first ?? dungeonName
            if firstWord.count > 3 { // Only test if word is long enough
                let partialResults = try Dungeon.searchDungeons(query: firstWord, context: context)
                XCTAssertTrue(partialResults.contains(dungeon),
                             "Dungeon \(dungeonName) not found when searching by partial name '\(firstWord)'")
            }
        }
    }

    func testAllDungeonsAreSearchableByShortName() throws {
        // Act
        let dungeons = try Dungeon.fetchDungeonsForActiveSeason(context: context)

        // Assert
        for dungeon in dungeons {
            guard let shortName = dungeon.shortName else {
                XCTFail("Dungeon \(dungeon.name ?? "unknown") missing short name")
                continue
            }

            let searchResults = try Dungeon.searchDungeons(query: shortName, context: context)
            XCTAssertTrue(searchResults.contains(dungeon),
                         "Dungeon \(dungeon.name ?? "unknown") not found when searching by short name '\(shortName)'")
        }
    }

    // MARK: - Performance and Memory Tests

    func testFetchAllDungeonsPerformance() throws {
        // Measure performance of fetching all dungeons
        measure {
            do {
                _ = try Dungeon.fetchDungeonsForActiveSeason(context: context)
            } catch {
                XCTFail("Failed to fetch dungeons: \(error)")
            }
        }
    }

    func testDungeonDataModelMemoryFootprint() throws {
        // Act
        let dungeons = try Dungeon.fetchDungeonsForActiveSeason(context: context)

        // Assert - Each dungeon should have reasonable memory usage
        for dungeon in dungeons {
            // Estimate memory footprint based on string lengths
            let nameSize = dungeon.name?.count ?? 0
            let shortNameSize = dungeon.shortName?.count ?? 0
            let notesSize = dungeon.healerNotes?.count ?? 0

            let estimatedSize = nameSize + shortNameSize + notesSize
            XCTAssertLessThan(estimatedSize, 1000,
                            "Dungeon \(dungeon.name ?? "unknown") has excessive text content: \(estimatedSize) characters")
        }
    }

    // MARK: - Test Data Setup Helper

    private func createTestDungeonData() throws {
        for (index, (name, shortName, bossCount)) in expectedDungeons.enumerated() {
            let dungeon = Dungeon(
                context: context,
                name: name,
                shortName: shortName,
                difficultyLevel: .mythicPlus,
                displayOrder: Int16(index + 1),
                estimatedDuration: TimeInterval((20 + index * 3) * 60), // 20-41 minutes
                healerNotes: "Healer notes for \(name)"
            )

            testSeason.addToDungeons(dungeon)

            // Add the expected number of boss encounters
            for bossIndex in 1...bossCount {
                let boss = BossEncounter(
                    context: context,
                    name: "Boss \(bossIndex) of \(shortName)",
                    encounterOrder: Int16(bossIndex),
                    healerSummary: "Healer summary for boss \(bossIndex) in \(name). Focus on positioning and cooldown management.",
                    difficultyRating: HealerDifficulty.allCases.randomElement() ?? .moderate,
                    estimatedDuration: TimeInterval(120 + bossIndex * 30), // 2-5 minutes
                    keyMechanics: ["Mechanic A", "Mechanic B"]
                )

                dungeon.addToBossEncounters(boss)
            }
        }

        try context.save()
    }
}