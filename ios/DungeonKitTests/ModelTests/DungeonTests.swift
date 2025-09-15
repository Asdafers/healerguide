//
//  DungeonTests.swift
//  DungeonKitTests
//
//  Unit tests for Dungeon CoreData model - Task T034
//  iOS 13.1+ compatible - First generation iPad Pro support
//

import XCTest
import CoreData
@testable import DungeonKit

final class DungeonTests: XCTestCase {

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

        // Create a test season for dungeons
        testSeason = Season(context: context, name: "Test Season", majorPatchVersion: "11.0", isActive: true)
        try context.save()
    }

    override func tearDownWithError() throws {
        testSeason = nil
        context = nil
        persistentContainer = nil
        try super.tearDownWithError()
    }

    // MARK: - Initialization Tests

    func testDungeonInitialization() {
        // Arrange
        let name = "The Dawnbreaker"
        let shortName = "DB"
        let difficultyLevel = DifficultyLevel.mythicPlus
        let displayOrder: Int16 = 1
        let estimatedDuration: TimeInterval = 1800 // 30 minutes
        let healerNotes = "Focus on tank healing during first boss"

        // Act
        let dungeon = Dungeon(
            context: context,
            name: name,
            shortName: shortName,
            difficultyLevel: difficultyLevel,
            displayOrder: displayOrder,
            estimatedDuration: estimatedDuration,
            healerNotes: healerNotes
        )

        // Assert
        XCTAssertNotNil(dungeon.id)
        XCTAssertEqual(dungeon.name, name)
        XCTAssertEqual(dungeon.shortName, shortName)
        XCTAssertEqual(dungeon.difficultyLevel, Int16(difficultyLevel.rawValue))
        XCTAssertEqual(dungeon.displayOrder, displayOrder)
        XCTAssertEqual(dungeon.estimatedDuration, estimatedDuration)
        XCTAssertEqual(dungeon.healerNotes, healerNotes)
        XCTAssertEqual(dungeon.bossEncounters?.count, 0)
    }

    func testDungeonInitializationDefaults() {
        // Act
        let dungeon = Dungeon(
            context: context,
            name: "Test Dungeon",
            shortName: "TD",
            difficultyLevel: .mythicPlus,
            displayOrder: 1
        )

        // Assert
        XCTAssertEqual(dungeon.estimatedDuration, 0.0) // Default value
        XCTAssertNil(dungeon.healerNotes) // Default value
    }

    // MARK: - Validation Tests

    func testValidDungeonInsert() throws {
        // Arrange
        let dungeon = Dungeon(
            context: context,
            name: "Valid Dungeon",
            shortName: "VD",
            difficultyLevel: .mythicPlus,
            displayOrder: 1
        )
        testSeason.addToDungeons(dungeon)

        // Act & Assert - Should not throw
        try context.save()
        XCTAssertFalse(context.hasChanges)
    }

    func testEmptyDungeonNameValidation() {
        // Arrange
        let dungeon = Dungeon(
            context: context,
            name: "",
            shortName: "ED",
            difficultyLevel: .mythicPlus,
            displayOrder: 1
        )
        testSeason.addToDungeons(dungeon)

        // Act & Assert
        XCTAssertThrowsError(try context.save()) { error in
            guard let validationError = error as? DungeonValidationError else {
                XCTFail("Expected DungeonValidationError, got \(error)")
                return
            }

            if case .emptyDungeonName = validationError {
                // Expected error type
            } else {
                XCTFail("Expected emptyDungeonName, got \(validationError)")
            }
        }
    }

    func testWhitespaceOnlyDungeonNameValidation() {
        // Arrange
        let dungeon = Dungeon(
            context: context,
            name: "   \n\t   ",
            shortName: "WD",
            difficultyLevel: .mythicPlus,
            displayOrder: 1
        )
        testSeason.addToDungeons(dungeon)

        // Act & Assert
        XCTAssertThrowsError(try context.save()) { error in
            guard let validationError = error as? DungeonValidationError else {
                XCTFail("Expected DungeonValidationError, got \(error)")
                return
            }

            if case .emptyDungeonName = validationError {
                // Expected error type
            } else {
                XCTFail("Expected emptyDungeonName, got \(validationError)")
            }
        }
    }

    func testEmptyShortNameValidation() {
        // Arrange
        let dungeon = Dungeon(
            context: context,
            name: "Test Dungeon",
            shortName: "",
            difficultyLevel: .mythicPlus,
            displayOrder: 1
        )
        testSeason.addToDungeons(dungeon)

        // Act & Assert
        XCTAssertThrowsError(try context.save()) { error in
            guard let validationError = error as? DungeonValidationError else {
                XCTFail("Expected DungeonValidationError, got \(error)")
                return
            }

            if case .emptyShortName = validationError {
                // Expected error type
            } else {
                XCTFail("Expected emptyShortName, got \(validationError)")
            }
        }
    }

    func testShortNameTooLongValidation() {
        // Arrange
        let longShortName = "TOOLONG" // More than 4 characters
        let dungeon = Dungeon(
            context: context,
            name: "Test Dungeon",
            shortName: longShortName,
            difficultyLevel: .mythicPlus,
            displayOrder: 1
        )
        testSeason.addToDungeons(dungeon)

        // Act & Assert
        XCTAssertThrowsError(try context.save()) { error in
            guard let validationError = error as? DungeonValidationError else {
                XCTFail("Expected DungeonValidationError, got \(error)")
                return
            }

            if case .shortNameTooLong(let shortName) = validationError {
                XCTAssertEqual(shortName, longShortName)
            } else {
                XCTFail("Expected shortNameTooLong, got \(validationError)")
            }
        }
    }

    func testValidShortNameLengths() throws {
        let validShortNames = ["A", "AB", "ABC", "ABCD"] // 1-4 characters

        for (index, shortName) in validShortNames.enumerated() {
            // Arrange
            let dungeon = Dungeon(
                context: context,
                name: "Test Dungeon \(index)",
                shortName: shortName,
                difficultyLevel: .mythicPlus,
                displayOrder: Int16(index + 1)
            )
            testSeason.addToDungeons(dungeon)

            // Act & Assert - Should not throw
            try context.save()

            // Clean up for next iteration
            context.delete(dungeon)
            try context.save()
        }
    }

    func testDuplicateNameInSeasonValidation() throws {
        // Arrange
        let duplicateName = "Duplicate Dungeon"
        let dungeon1 = Dungeon(
            context: context,
            name: duplicateName,
            shortName: "DD1",
            difficultyLevel: .mythicPlus,
            displayOrder: 1
        )
        testSeason.addToDungeons(dungeon1)
        try context.save()

        let dungeon2 = Dungeon(
            context: context,
            name: duplicateName,
            shortName: "DD2",
            difficultyLevel: .mythicPlus,
            displayOrder: 2
        )
        testSeason.addToDungeons(dungeon2)

        // Act & Assert
        XCTAssertThrowsError(try context.save()) { error in
            guard let validationError = error as? DungeonValidationError else {
                XCTFail("Expected DungeonValidationError, got \(error)")
                return
            }

            if case .duplicateNameInSeason(let name) = validationError {
                XCTAssertEqual(name, duplicateName)
            } else {
                XCTFail("Expected duplicateNameInSeason, got \(validationError)")
            }
        }
    }

    func testDuplicateNameInDifferentSeasonsAllowed() throws {
        // Arrange
        let anotherSeason = Season(context: context, name: "Another Season", majorPatchVersion: "11.1")
        try context.save()

        let sameName = "Same Dungeon Name"
        let dungeon1 = Dungeon(
            context: context,
            name: sameName,
            shortName: "SD1",
            difficultyLevel: .mythicPlus,
            displayOrder: 1
        )
        testSeason.addToDungeons(dungeon1)

        let dungeon2 = Dungeon(
            context: context,
            name: sameName,
            shortName: "SD2",
            difficultyLevel: .mythicPlus,
            displayOrder: 1
        )
        anotherSeason.addToDungeons(dungeon2)

        // Act & Assert - Should not throw because they're in different seasons
        try context.save()
    }

    func testDuplicateDisplayOrderInSeasonValidation() throws {
        // Arrange
        let displayOrder: Int16 = 5
        let dungeon1 = Dungeon(
            context: context,
            name: "First Dungeon",
            shortName: "FD",
            difficultyLevel: .mythicPlus,
            displayOrder: displayOrder
        )
        testSeason.addToDungeons(dungeon1)
        try context.save()

        let dungeon2 = Dungeon(
            context: context,
            name: "Second Dungeon",
            shortName: "SD",
            difficultyLevel: .mythicPlus,
            displayOrder: displayOrder
        )
        testSeason.addToDungeons(dungeon2)

        // Act & Assert
        XCTAssertThrowsError(try context.save()) { error in
            guard let validationError = error as? DungeonValidationError else {
                XCTFail("Expected DungeonValidationError, got \(error)")
                return
            }

            if case .duplicateDisplayOrder(let order) = validationError {
                XCTAssertEqual(order, Int(displayOrder))
            } else {
                XCTFail("Expected duplicateDisplayOrder, got \(validationError)")
            }
        }
    }

    func testNegativeDurationValidation() {
        // Arrange
        let dungeon = Dungeon(
            context: context,
            name: "Test Dungeon",
            shortName: "TD",
            difficultyLevel: .mythicPlus,
            displayOrder: 1,
            estimatedDuration: -100
        )
        testSeason.addToDungeons(dungeon)

        // Act & Assert
        XCTAssertThrowsError(try context.save()) { error in
            guard let validationError = error as? DungeonValidationError else {
                XCTFail("Expected DungeonValidationError, got \(error)")
                return
            }

            if case .invalidDuration(let duration) = validationError {
                XCTAssertEqual(duration, -100)
            } else {
                XCTFail("Expected invalidDuration, got \(validationError)")
            }
        }
    }

    func testZeroDurationAllowed() throws {
        // Arrange
        let dungeon = Dungeon(
            context: context,
            name: "Test Dungeon",
            shortName: "TD",
            difficultyLevel: .mythicPlus,
            displayOrder: 1,
            estimatedDuration: 0
        )
        testSeason.addToDungeons(dungeon)

        // Act & Assert - Should not throw
        try context.save()
    }

    func testInvalidDifficultyLevelValidation() {
        // Arrange
        let dungeon = Dungeon(
            context: context,
            name: "Test Dungeon",
            shortName: "TD",
            difficultyLevel: .mythicPlus,
            displayOrder: 1
        )

        // Manually set invalid difficulty level
        dungeon.difficultyLevel = 999 // Invalid value
        testSeason.addToDungeons(dungeon)

        // Act & Assert
        XCTAssertThrowsError(try context.save()) { error in
            guard let validationError = error as? DungeonValidationError else {
                XCTFail("Expected DungeonValidationError, got \(error)")
                return
            }

            if case .invalidDifficultyLevel(let level) = validationError {
                XCTAssertEqual(level, "999")
            } else {
                XCTFail("Expected invalidDifficultyLevel, got \(validationError)")
            }
        }
    }

    // MARK: - Business Logic Tests

    func testDifficultyEnumConversion() {
        // Arrange
        let dungeon = Dungeon(
            context: context,
            name: "Test Dungeon",
            shortName: "TD",
            difficultyLevel: .mythicPlus,
            displayOrder: 1
        )

        // Act & Assert
        XCTAssertEqual(dungeon.difficulty, .mythicPlus)

        // Test setting difficulty
        dungeon.setDifficulty(.mythicPlus)
        XCTAssertEqual(dungeon.difficulty, .mythicPlus)
        XCTAssertEqual(dungeon.difficultyLevel, Int16(DifficultyLevel.mythicPlus.rawValue))
    }

    func testDifficultyLevelEnum() {
        // Test enum properties
        let mythicPlus = DifficultyLevel.mythicPlus
        XCTAssertEqual(mythicPlus.rawValue, 0)
        XCTAssertEqual(mythicPlus.displayName, "Mythic+")

        // Test all cases
        let allCases = DifficultyLevel.allCases
        XCTAssertEqual(allCases.count, 1)
        XCTAssertTrue(allCases.contains(.mythicPlus))
    }

    func testHasMinimumBossEncountersEmpty() {
        // Arrange
        let dungeon = Dungeon(
            context: context,
            name: "Empty Dungeon",
            shortName: "ED",
            difficultyLevel: .mythicPlus,
            displayOrder: 1
        )

        // Act & Assert
        XCTAssertFalse(dungeon.hasMinimumBossEncounters)
    }

    func testHasMinimumBossEncountersWithOne() throws {
        // Arrange
        let dungeon = Dungeon(
            context: context,
            name: "Dungeon With Boss",
            shortName: "DWB",
            difficultyLevel: .mythicPlus,
            displayOrder: 1
        )
        let bossEncounter = BossEncounter(
            context: context,
            name: "Test Boss",
            encounterOrder: 1,
            healerSummary: "Test healer summary",
            difficultyRating: .moderate
        )
        dungeon.addToBossEncounters(bossEncounter)
        try context.save()

        // Act & Assert
        XCTAssertTrue(dungeon.hasMinimumBossEncounters)
    }

    func testOrderedBossEncountersEmpty() {
        // Arrange
        let dungeon = Dungeon(
            context: context,
            name: "Empty Dungeon",
            shortName: "ED",
            difficultyLevel: .mythicPlus,
            displayOrder: 1
        )

        // Act
        let orderedEncounters = dungeon.orderedBossEncounters

        // Assert
        XCTAssertTrue(orderedEncounters.isEmpty)
    }

    func testOrderedBossEncountersSortedByEncounterOrder() throws {
        // Arrange
        let dungeon = Dungeon(
            context: context,
            name: "Dungeon With Bosses",
            shortName: "DWB",
            difficultyLevel: .mythicPlus,
            displayOrder: 1
        )

        let boss3 = BossEncounter(
            context: context,
            name: "Third Boss",
            encounterOrder: 3,
            healerSummary: "Third boss summary",
            difficultyRating: .hard
        )
        let boss1 = BossEncounter(
            context: context,
            name: "First Boss",
            encounterOrder: 1,
            healerSummary: "First boss summary",
            difficultyRating: .easy
        )
        let boss2 = BossEncounter(
            context: context,
            name: "Second Boss",
            encounterOrder: 2,
            healerSummary: "Second boss summary",
            difficultyRating: .moderate
        )

        dungeon.addToBossEncounters(boss3)
        dungeon.addToBossEncounters(boss1)
        dungeon.addToBossEncounters(boss2)

        try context.save()

        // Act
        let orderedEncounters = dungeon.orderedBossEncounters

        // Assert
        XCTAssertEqual(orderedEncounters.count, 3)
        XCTAssertEqual(orderedEncounters[0].encounterOrder, 1)
        XCTAssertEqual(orderedEncounters[1].encounterOrder, 2)
        XCTAssertEqual(orderedEncounters[2].encounterOrder, 3)
        XCTAssertEqual(orderedEncounters[0].name, "First Boss")
        XCTAssertEqual(orderedEncounters[1].name, "Second Boss")
        XCTAssertEqual(orderedEncounters[2].name, "Third Boss")
    }

    func testBossCount() throws {
        // Arrange
        let dungeon = Dungeon(
            context: context,
            name: "Test Dungeon",
            shortName: "TD",
            difficultyLevel: .mythicPlus,
            displayOrder: 1
        )

        // Act & Assert - Initially empty
        XCTAssertEqual(dungeon.bossCount, 0)

        // Add boss encounters
        let boss1 = BossEncounter(
            context: context,
            name: "Boss 1",
            encounterOrder: 1,
            healerSummary: "Boss 1 summary",
            difficultyRating: .easy
        )
        let boss2 = BossEncounter(
            context: context,
            name: "Boss 2",
            encounterOrder: 2,
            healerSummary: "Boss 2 summary",
            difficultyRating: .moderate
        )

        dungeon.addToBossEncounters(boss1)
        dungeon.addToBossEncounters(boss2)
        try context.save()

        XCTAssertEqual(dungeon.bossCount, 2)
    }

    func testFormattedDurationMinutes() {
        // Test various durations
        let testCases: [(TimeInterval, String)] = [
            (0, "0m"),
            (60, "1m"),
            (300, "5m"),
            (900, "15m"),
            (1800, "30m"),
            (2700, "45m"),
            (3599, "59m") // Just under 1 hour
        ]

        for (duration, expected) in testCases {
            // Arrange
            let dungeon = Dungeon(
                context: context,
                name: "Test Dungeon",
                shortName: "TD",
                difficultyLevel: .mythicPlus,
                displayOrder: 1,
                estimatedDuration: duration
            )

            // Act & Assert
            XCTAssertEqual(dungeon.formattedDuration, expected, "Duration \(duration) should format as \(expected)")
        }
    }

    func testFormattedDurationHoursAndMinutes() {
        // Test durations with hours
        let testCases: [(TimeInterval, String)] = [
            (3600, "1h 0m"),
            (3660, "1h 1m"),
            (3900, "1h 5m"),
            (5400, "1h 30m"),
            (7200, "2h 0m"),
            (7320, "2h 2m")
        ]

        for (duration, expected) in testCases {
            // Arrange
            let dungeon = Dungeon(
                context: context,
                name: "Test Dungeon",
                shortName: "TD",
                difficultyLevel: .mythicPlus,
                displayOrder: 1,
                estimatedDuration: duration
            )

            // Act & Assert
            XCTAssertEqual(dungeon.formattedDuration, expected, "Duration \(duration) should format as \(expected)")
        }
    }

    // MARK: - Fetch Request Tests

    func testFetchDungeonsForActiveSeasonEmpty() throws {
        // Arrange - testSeason is already active but has no dungeons

        // Act
        let dungeons = try Dungeon.fetchDungeonsForActiveSeason(context: context)

        // Assert
        XCTAssertTrue(dungeons.isEmpty)
    }

    func testFetchDungeonsForActiveSeasonFound() throws {
        // Arrange
        let dungeon1 = Dungeon(
            context: context,
            name: "Dungeon 1",
            shortName: "D1",
            difficultyLevel: .mythicPlus,
            displayOrder: 2
        )
        let dungeon2 = Dungeon(
            context: context,
            name: "Dungeon 2",
            shortName: "D2",
            difficultyLevel: .mythicPlus,
            displayOrder: 1
        )

        testSeason.addToDungeons(dungeon1)
        testSeason.addToDungeons(dungeon2)
        try context.save()

        // Act
        let dungeons = try Dungeon.fetchDungeonsForActiveSeason(context: context)

        // Assert - Should be ordered by display order
        XCTAssertEqual(dungeons.count, 2)
        XCTAssertEqual(dungeons[0].displayOrder, 1)
        XCTAssertEqual(dungeons[1].displayOrder, 2)
        XCTAssertEqual(dungeons[0].name, "Dungeon 2")
        XCTAssertEqual(dungeons[1].name, "Dungeon 1")
    }

    func testFetchDungeonsForActiveSeasonIgnoresInactive() throws {
        // Arrange
        let inactiveSeason = Season(context: context, name: "Inactive Season", majorPatchVersion: "10.0", isActive: false)

        let activeDungeon = Dungeon(
            context: context,
            name: "Active Dungeon",
            shortName: "AD",
            difficultyLevel: .mythicPlus,
            displayOrder: 1
        )
        let inactiveDungeon = Dungeon(
            context: context,
            name: "Inactive Dungeon",
            shortName: "ID",
            difficultyLevel: .mythicPlus,
            displayOrder: 1
        )

        testSeason.addToDungeons(activeDungeon)
        inactiveSeason.addToDungeons(inactiveDungeon)
        try context.save()

        // Act
        let dungeons = try Dungeon.fetchDungeonsForActiveSeason(context: context)

        // Assert
        XCTAssertEqual(dungeons.count, 1)
        XCTAssertEqual(dungeons[0].name, "Active Dungeon")
    }

    func testFetchDungeonWithBosses() throws {
        // Arrange
        let dungeon = Dungeon(
            context: context,
            name: "Dungeon With Bosses",
            shortName: "DWB",
            difficultyLevel: .mythicPlus,
            displayOrder: 1
        )
        testSeason.addToDungeons(dungeon)

        let boss = BossEncounter(
            context: context,
            name: "Test Boss",
            encounterOrder: 1,
            healerSummary: "Test summary",
            difficultyRating: .moderate
        )
        dungeon.addToBossEncounters(boss)
        try context.save()

        // Act
        let fetchedDungeon = try Dungeon.fetchDungeonWithBosses(id: dungeon.id!, context: context)

        // Assert
        XCTAssertNotNil(fetchedDungeon)
        XCTAssertEqual(fetchedDungeon?.id, dungeon.id)
        XCTAssertEqual(fetchedDungeon?.bossEncounters?.count, 1)
    }

    func testFetchDungeonWithBossesNotFound() throws {
        // Arrange
        let nonExistentId = UUID()

        // Act
        let fetchedDungeon = try Dungeon.fetchDungeonWithBosses(id: nonExistentId, context: context)

        // Assert
        XCTAssertNil(fetchedDungeon)
    }

    func testSearchDungeons() throws {
        // Arrange
        let dungeons = [
            Dungeon(context: context, name: "The Dawnbreaker", shortName: "DB", difficultyLevel: .mythicPlus, displayOrder: 1),
            Dungeon(context: context, name: "City of Threads", shortName: "COT", difficultyLevel: .mythicPlus, displayOrder: 2),
            Dungeon(context: context, name: "Ara-Kara", shortName: "AK", difficultyLevel: .mythicPlus, displayOrder: 3),
            Dungeon(context: context, name: "The Stonevault", shortName: "SV", difficultyLevel: .mythicPlus, displayOrder: 4)
        ]

        for dungeon in dungeons {
            testSeason.addToDungeons(dungeon)
        }
        try context.save()

        // Act & Assert - Test name search
        let dawnResults = try Dungeon.searchDungeons(query: "dawn", context: context)
        XCTAssertEqual(dawnResults.count, 1)
        XCTAssertEqual(dawnResults[0].name, "The Dawnbreaker")

        // Test short name search
        let cotResults = try Dungeon.searchDungeons(query: "cot", context: context)
        XCTAssertEqual(cotResults.count, 1)
        XCTAssertEqual(cotResults[0].name, "City of Threads")

        // Test partial match
        let stoneResults = try Dungeon.searchDungeons(query: "stone", context: context)
        XCTAssertEqual(stoneResults.count, 1)
        XCTAssertEqual(stoneResults[0].name, "The Stonevault")

        // Test case insensitive
        let cityResults = try Dungeon.searchDungeons(query: "CITY", context: context)
        XCTAssertEqual(cityResults.count, 1)
        XCTAssertEqual(cityResults[0].name, "City of Threads")

        // Test no results
        let noResults = try Dungeon.searchDungeons(query: "nonexistent", context: context)
        XCTAssertTrue(noResults.isEmpty)
    }

    func testFetchDungeonsForSpecificSeason() throws {
        // Arrange
        let anotherSeason = Season(context: context, name: "Another Season", majorPatchVersion: "11.1")

        let dungeon1 = Dungeon(context: context, name: "Season 1 Dungeon", shortName: "S1D", difficultyLevel: .mythicPlus, displayOrder: 2)
        let dungeon2 = Dungeon(context: context, name: "Season 2 Dungeon", shortName: "S2D", difficultyLevel: .mythicPlus, displayOrder: 1)
        let dungeon3 = Dungeon(context: context, name: "Another Season 1 Dungeon", shortName: "AS1", difficultyLevel: .mythicPlus, displayOrder: 1)

        testSeason.addToDungeons(dungeon1)
        testSeason.addToDungeons(dungeon3)
        anotherSeason.addToDungeons(dungeon2)

        try context.save()

        // Act
        let testSeasonDungeons = try Dungeon.fetchDungeons(for: testSeason, context: context)
        let anotherSeasonDungeons = try Dungeon.fetchDungeons(for: anotherSeason, context: context)

        // Assert - Test season dungeons ordered by display order
        XCTAssertEqual(testSeasonDungeons.count, 2)
        XCTAssertEqual(testSeasonDungeons[0].displayOrder, 1)
        XCTAssertEqual(testSeasonDungeons[1].displayOrder, 2)
        XCTAssertEqual(testSeasonDungeons[0].name, "Another Season 1 Dungeon")
        XCTAssertEqual(testSeasonDungeons[1].name, "Season 1 Dungeon")

        // Another season dungeons
        XCTAssertEqual(anotherSeasonDungeons.count, 1)
        XCTAssertEqual(anotherSeasonDungeons[0].name, "Season 2 Dungeon")
    }

    // MARK: - Relationship Tests

    func testDungeonSeasonRelationshipIntegrity() throws {
        // Arrange
        let dungeon = Dungeon(
            context: context,
            name: "Test Dungeon",
            shortName: "TD",
            difficultyLevel: .mythicPlus,
            displayOrder: 1
        )

        // Act
        testSeason.addToDungeons(dungeon)
        try context.save()

        // Assert
        XCTAssertEqual(dungeon.season, testSeason)
        XCTAssertTrue(testSeason.dungeons?.contains(dungeon) ?? false)
    }

    func testDungeonBossEncounterRelationshipIntegrity() throws {
        // Arrange
        let dungeon = Dungeon(
            context: context,
            name: "Test Dungeon",
            shortName: "TD",
            difficultyLevel: .mythicPlus,
            displayOrder: 1
        )
        let bossEncounter = BossEncounter(
            context: context,
            name: "Test Boss",
            encounterOrder: 1,
            healerSummary: "Test summary",
            difficultyRating: .moderate
        )

        // Act
        dungeon.addToBossEncounters(bossEncounter)
        try context.save()

        // Assert
        XCTAssertEqual(dungeon.bossEncounters?.count, 1)
        XCTAssertTrue(dungeon.bossEncounters?.contains(bossEncounter) ?? false)
        XCTAssertEqual(bossEncounter.dungeon, dungeon)
    }

    func testRemoveBossEncounterFromDungeon() throws {
        // Arrange
        let dungeon = Dungeon(
            context: context,
            name: "Test Dungeon",
            shortName: "TD",
            difficultyLevel: .mythicPlus,
            displayOrder: 1
        )
        let bossEncounter = BossEncounter(
            context: context,
            name: "Test Boss",
            encounterOrder: 1,
            healerSummary: "Test summary",
            difficultyRating: .moderate
        )
        dungeon.addToBossEncounters(bossEncounter)
        try context.save()

        // Act
        dungeon.removeFromBossEncounters(bossEncounter)
        try context.save()

        // Assert
        XCTAssertEqual(dungeon.bossEncounters?.count, 0)
        XCTAssertNil(bossEncounter.dungeon)
    }

    // MARK: - Validation Error Tests

    func testValidationErrorDescriptions() {
        // Test all validation error descriptions
        let errors: [DungeonValidationError] = [
            .emptyDungeonName,
            .emptyShortName,
            .shortNameTooLong("TOOLONG"),
            .duplicateNameInSeason("Duplicate Name"),
            .duplicateDisplayOrder(5),
            .invalidDuration(-100),
            .invalidDifficultyLevel("999")
        ]

        for error in errors {
            XCTAssertNotNil(error.errorDescription)
            XCTAssertFalse(error.errorDescription!.isEmpty)
        }
    }

    // MARK: - Edge Cases

    func testDungeonWithNilManagedObjectContext() {
        // Arrange
        let dungeon = Dungeon()

        // Act & Assert
        XCTAssertNil(dungeon.managedObjectContext)
        XCTAssertFalse(dungeon.hasMinimumBossEncounters)
        XCTAssertTrue(dungeon.orderedBossEncounters.isEmpty)
        XCTAssertEqual(dungeon.bossCount, 0)
        XCTAssertNil(dungeon.difficulty) // Should handle nil context gracefully
    }

    func testIdentifiableConformance() {
        // Arrange
        let dungeon = Dungeon(
            context: context,
            name: "Test Dungeon",
            shortName: "TD",
            difficultyLevel: .mythicPlus,
            displayOrder: 1
        )

        // Act & Assert
        XCTAssertNotNil(dungeon.id)

        // Test that dungeon conforms to Identifiable
        let identifiableDungeon: any Identifiable = dungeon
        XCTAssertEqual(identifiableDungeon.id as? UUID, dungeon.id)
    }

    func testCoreDataPropertiesAccessibility() {
        // Arrange
        let dungeon = Dungeon(
            context: context,
            name: "Test Dungeon",
            shortName: "TD",
            difficultyLevel: .mythicPlus,
            displayOrder: 1
        )
        let testUUID = UUID()

        // Act & Assert - Test all Core Data properties are accessible
        dungeon.id = testUUID
        XCTAssertEqual(dungeon.id, testUUID)

        dungeon.name = "Updated Name"
        XCTAssertEqual(dungeon.name, "Updated Name")

        dungeon.shortName = "UN"
        XCTAssertEqual(dungeon.shortName, "UN")

        dungeon.difficultyLevel = 0
        XCTAssertEqual(dungeon.difficultyLevel, 0)

        dungeon.displayOrder = 99
        XCTAssertEqual(dungeon.displayOrder, 99)

        dungeon.estimatedDuration = 3600
        XCTAssertEqual(dungeon.estimatedDuration, 3600)

        dungeon.healerNotes = "Updated notes"
        XCTAssertEqual(dungeon.healerNotes, "Updated notes")

        XCTAssertNotNil(dungeon.bossEncounters) // NSSet should be initialized
    }
}