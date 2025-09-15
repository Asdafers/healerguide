//
//  BossEncounterTests.swift
//  DungeonKitTests
//
//  Unit tests for BossEncounter CoreData model - Task T035
//  iOS 13.1+ compatible - First generation iPad Pro support
//

import XCTest
import CoreData
@testable import DungeonKit

final class BossEncounterTests: XCTestCase {

    // MARK: - Test Infrastructure

    var persistentContainer: NSPersistentContainer!
    var context: NSManagedObjectContext!
    var testSeason: Season!
    var testDungeon: Dungeon!

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

        // Create test hierarchy
        testSeason = Season(context: context, name: "Test Season", majorPatchVersion: "11.0", isActive: true)
        testDungeon = Dungeon(context: context, name: "Test Dungeon", shortName: "TD", difficultyLevel: .mythicPlus, displayOrder: 1)
        testSeason.addToDungeons(testDungeon)
        try context.save()
    }

    override func tearDownWithError() throws {
        testDungeon = nil
        testSeason = nil
        context = nil
        persistentContainer = nil
        try super.tearDownWithError()
    }

    // MARK: - Initialization Tests

    func testBossEncounterInitialization() {
        // Arrange
        let name = "Anub'arash"
        let encounterOrder: Int16 = 1
        let healerSummary = "Focus on positioning to avoid webs while maintaining tank healing. Use cooldowns during enrage phase."
        let difficultyRating = HealerDifficulty.hard
        let estimatedDuration: TimeInterval = 180
        let keyMechanics = ["Web Blast", "Piercing Strike", "Call of the Swarm"]

        // Act
        let bossEncounter = BossEncounter(
            context: context,
            name: name,
            encounterOrder: encounterOrder,
            healerSummary: healerSummary,
            difficultyRating: difficultyRating,
            estimatedDuration: estimatedDuration,
            keyMechanics: keyMechanics
        )

        // Assert
        XCTAssertNotNil(bossEncounter.id)
        XCTAssertEqual(bossEncounter.name, name)
        XCTAssertEqual(bossEncounter.encounterOrder, encounterOrder)
        XCTAssertEqual(bossEncounter.healerSummary, healerSummary)
        XCTAssertEqual(bossEncounter.difficultyRating, Int16(difficultyRating.rawValue))
        XCTAssertEqual(bossEncounter.estimatedDuration, estimatedDuration)
        XCTAssertEqual(bossEncounter.getKeyMechanics(), keyMechanics)
        XCTAssertEqual(bossEncounter.abilities?.count, 0)
    }

    func testBossEncounterInitializationDefaults() {
        // Act
        let bossEncounter = BossEncounter(
            context: context,
            name: "Test Boss",
            encounterOrder: 1,
            healerSummary: "Test summary",
            difficultyRating: .moderate
        )

        // Assert
        XCTAssertEqual(bossEncounter.estimatedDuration, 0.0) // Default value
        XCTAssertTrue(bossEncounter.getKeyMechanics().isEmpty) // Default empty array
    }

    // MARK: - Validation Tests

    func testValidBossEncounterInsert() throws {
        // Arrange
        let bossEncounter = BossEncounter(
            context: context,
            name: "Valid Boss",
            encounterOrder: 1,
            healerSummary: "Valid healer summary for this boss encounter",
            difficultyRating: .moderate
        )
        testDungeon.addToBossEncounters(bossEncounter)

        // Act & Assert - Should not throw
        try context.save()
        XCTAssertFalse(context.hasChanges)
    }

    func testEmptyBossNameValidation() {
        // Arrange
        let bossEncounter = BossEncounter(
            context: context,
            name: "",
            encounterOrder: 1,
            healerSummary: "Test summary",
            difficultyRating: .moderate
        )
        testDungeon.addToBossEncounters(bossEncounter)

        // Act & Assert
        XCTAssertThrowsError(try context.save()) { error in
            guard let validationError = error as? BossEncounterValidationError else {
                XCTFail("Expected BossEncounterValidationError, got \(error)")
                return
            }

            if case .emptyBossName = validationError {
                // Expected error type
            } else {
                XCTFail("Expected emptyBossName, got \(validationError)")
            }
        }
    }

    func testWhitespaceOnlyBossNameValidation() {
        // Arrange
        let bossEncounter = BossEncounter(
            context: context,
            name: "   \n\t   ",
            encounterOrder: 1,
            healerSummary: "Test summary",
            difficultyRating: .moderate
        )
        testDungeon.addToBossEncounters(bossEncounter)

        // Act & Assert
        XCTAssertThrowsError(try context.save()) { error in
            guard let validationError = error as? BossEncounterValidationError else {
                XCTFail("Expected BossEncounterValidationError, got \(error)")
                return
            }

            if case .emptyBossName = validationError {
                // Expected error type
            } else {
                XCTFail("Expected emptyBossName, got \(validationError)")
            }
        }
    }

    func testEmptyHealerSummaryValidation() {
        // Arrange
        let bossEncounter = BossEncounter(
            context: context,
            name: "Test Boss",
            encounterOrder: 1,
            healerSummary: "",
            difficultyRating: .moderate
        )
        testDungeon.addToBossEncounters(bossEncounter)

        // Act & Assert
        XCTAssertThrowsError(try context.save()) { error in
            guard let validationError = error as? BossEncounterValidationError else {
                XCTFail("Expected BossEncounterValidationError, got \(error)")
                return
            }

            if case .emptyHealerSummary = validationError {
                // Expected error type
            } else {
                XCTFail("Expected emptyHealerSummary, got \(validationError)")
            }
        }
    }

    func testWhitespaceOnlyHealerSummaryValidation() {
        // Arrange
        let bossEncounter = BossEncounter(
            context: context,
            name: "Test Boss",
            encounterOrder: 1,
            healerSummary: "   \n\t   ",
            difficultyRating: .moderate
        )
        testDungeon.addToBossEncounters(bossEncounter)

        // Act & Assert
        XCTAssertThrowsError(try context.save()) { error in
            guard let validationError = error as? BossEncounterValidationError else {
                XCTFail("Expected BossEncounterValidationError, got \(error)")
                return
            }

            if case .emptyHealerSummary = validationError {
                // Expected error type
            } else {
                XCTFail("Expected emptyHealerSummary, got \(validationError)")
            }
        }
    }

    func testHealerSummaryTooLongValidation() {
        // Arrange - Create summary longer than 500 characters
        let longSummary = String(repeating: "a", count: 501)
        let bossEncounter = BossEncounter(
            context: context,
            name: "Test Boss",
            encounterOrder: 1,
            healerSummary: longSummary,
            difficultyRating: .moderate
        )
        testDungeon.addToBossEncounters(bossEncounter)

        // Act & Assert
        XCTAssertThrowsError(try context.save()) { error in
            guard let validationError = error as? BossEncounterValidationError else {
                XCTFail("Expected BossEncounterValidationError, got \(error)")
                return
            }

            if case .healerSummaryTooLong(let length) = validationError {
                XCTAssertEqual(length, 501)
            } else {
                XCTFail("Expected healerSummaryTooLong, got \(validationError)")
            }
        }
    }

    func testHealerSummaryMaxLengthAllowed() throws {
        // Arrange - Create summary exactly 500 characters
        let maxLengthSummary = String(repeating: "a", count: 500)
        let bossEncounter = BossEncounter(
            context: context,
            name: "Test Boss",
            encounterOrder: 1,
            healerSummary: maxLengthSummary,
            difficultyRating: .moderate
        )
        testDungeon.addToBossEncounters(bossEncounter)

        // Act & Assert - Should not throw
        try context.save()
    }

    func testDuplicateNameInDungeonValidation() throws {
        // Arrange
        let duplicateName = "Duplicate Boss"
        let boss1 = BossEncounter(
            context: context,
            name: duplicateName,
            encounterOrder: 1,
            healerSummary: "First boss summary",
            difficultyRating: .moderate
        )
        testDungeon.addToBossEncounters(boss1)
        try context.save()

        let boss2 = BossEncounter(
            context: context,
            name: duplicateName,
            encounterOrder: 2,
            healerSummary: "Second boss summary",
            difficultyRating: .hard
        )
        testDungeon.addToBossEncounters(boss2)

        // Act & Assert
        XCTAssertThrowsError(try context.save()) { error in
            guard let validationError = error as? BossEncounterValidationError else {
                XCTFail("Expected BossEncounterValidationError, got \(error)")
                return
            }

            if case .duplicateNameInDungeon(let name) = validationError {
                XCTAssertEqual(name, duplicateName)
            } else {
                XCTFail("Expected duplicateNameInDungeon, got \(validationError)")
            }
        }
    }

    func testDuplicateNameInDifferentDungeonsAllowed() throws {
        // Arrange
        let anotherDungeon = Dungeon(context: context, name: "Another Dungeon", shortName: "AD", difficultyLevel: .mythicPlus, displayOrder: 2)
        testSeason.addToDungeons(anotherDungeon)
        try context.save()

        let sameName = "Same Boss Name"
        let boss1 = BossEncounter(
            context: context,
            name: sameName,
            encounterOrder: 1,
            healerSummary: "First boss summary",
            difficultyRating: .moderate
        )
        let boss2 = BossEncounter(
            context: context,
            name: sameName,
            encounterOrder: 1,
            healerSummary: "Second boss summary",
            difficultyRating: .hard
        )

        testDungeon.addToBossEncounters(boss1)
        anotherDungeon.addToBossEncounters(boss2)

        // Act & Assert - Should not throw because they're in different dungeons
        try context.save()
    }

    func testDuplicateEncounterOrderInDungeonValidation() throws {
        // Arrange
        let encounterOrder: Int16 = 3
        let boss1 = BossEncounter(
            context: context,
            name: "First Boss",
            encounterOrder: encounterOrder,
            healerSummary: "First boss summary",
            difficultyRating: .moderate
        )
        testDungeon.addToBossEncounters(boss1)
        try context.save()

        let boss2 = BossEncounter(
            context: context,
            name: "Second Boss",
            encounterOrder: encounterOrder,
            healerSummary: "Second boss summary",
            difficultyRating: .hard
        )
        testDungeon.addToBossEncounters(boss2)

        // Act & Assert
        XCTAssertThrowsError(try context.save()) { error in
            guard let validationError = error as? BossEncounterValidationError else {
                XCTFail("Expected BossEncounterValidationError, got \(error)")
                return
            }

            if case .duplicateEncounterOrder(let order) = validationError {
                XCTAssertEqual(order, Int(encounterOrder))
            } else {
                XCTFail("Expected duplicateEncounterOrder, got \(validationError)")
            }
        }
    }

    func testNegativeDurationValidation() {
        // Arrange
        let bossEncounter = BossEncounter(
            context: context,
            name: "Test Boss",
            encounterOrder: 1,
            healerSummary: "Test summary",
            difficultyRating: .moderate,
            estimatedDuration: -60
        )
        testDungeon.addToBossEncounters(bossEncounter)

        // Act & Assert
        XCTAssertThrowsError(try context.save()) { error in
            guard let validationError = error as? BossEncounterValidationError else {
                XCTFail("Expected BossEncounterValidationError, got \(error)")
                return
            }

            if case .invalidDuration(let duration) = validationError {
                XCTAssertEqual(duration, -60)
            } else {
                XCTFail("Expected invalidDuration, got \(validationError)")
            }
        }
    }

    func testZeroDurationAllowed() throws {
        // Arrange
        let bossEncounter = BossEncounter(
            context: context,
            name: "Test Boss",
            encounterOrder: 1,
            healerSummary: "Test summary",
            difficultyRating: .moderate,
            estimatedDuration: 0
        )
        testDungeon.addToBossEncounters(bossEncounter)

        // Act & Assert - Should not throw
        try context.save()
    }

    func testInvalidDifficultyRatingValidation() {
        // Arrange
        let bossEncounter = BossEncounter(
            context: context,
            name: "Test Boss",
            encounterOrder: 1,
            healerSummary: "Test summary",
            difficultyRating: .moderate
        )

        // Manually set invalid difficulty rating
        bossEncounter.difficultyRating = 999 // Invalid value
        testDungeon.addToBossEncounters(bossEncounter)

        // Act & Assert
        XCTAssertThrowsError(try context.save()) { error in
            guard let validationError = error as? BossEncounterValidationError else {
                XCTFail("Expected BossEncounterValidationError, got \(error)")
                return
            }

            if case .invalidDifficultyRating(let rating) = validationError {
                XCTAssertEqual(rating, 999)
            } else {
                XCTFail("Expected invalidDifficultyRating, got \(validationError)")
            }
        }
    }

    func testValidDifficultyRatings() throws {
        let validRatings: [HealerDifficulty] = [.easy, .moderate, .hard, .extreme]

        for (index, rating) in validRatings.enumerated() {
            // Arrange
            let bossEncounter = BossEncounter(
                context: context,
                name: "Test Boss \(index)",
                encounterOrder: Int16(index + 1),
                healerSummary: "Test summary for rating \(rating.displayName)",
                difficultyRating: rating
            )
            testDungeon.addToBossEncounters(bossEncounter)

            // Act & Assert - Should not throw
            try context.save()

            // Clean up for next iteration
            context.delete(bossEncounter)
            try context.save()
        }
    }

    func testTooManyKeyMechanicsValidation() {
        // Arrange
        let tooManyMechanics = ["Mechanic 1", "Mechanic 2", "Mechanic 3", "Mechanic 4"] // More than 3
        let bossEncounter = BossEncounter(
            context: context,
            name: "Test Boss",
            encounterOrder: 1,
            healerSummary: "Test summary",
            difficultyRating: .moderate,
            keyMechanics: tooManyMechanics
        )
        testDungeon.addToBossEncounters(bossEncounter)

        // Act & Assert
        XCTAssertThrowsError(try context.save()) { error in
            guard let validationError = error as? BossEncounterValidationError else {
                XCTFail("Expected BossEncounterValidationError, got \(error)")
                return
            }

            if case .tooManyKeyMechanics(let count) = validationError {
                XCTAssertEqual(count, 3) // Should be limited to 3 in setKeyMechanics
            } else {
                XCTFail("Expected tooManyKeyMechanics, got \(validationError)")
            }
        }
    }

    func testMaxKeyMechanicsAllowed() throws {
        // Arrange - Exactly 3 key mechanics should be allowed
        let maxMechanics = ["Mechanic 1", "Mechanic 2", "Mechanic 3"]
        let bossEncounter = BossEncounter(
            context: context,
            name: "Test Boss",
            encounterOrder: 1,
            healerSummary: "Test summary",
            difficultyRating: .moderate,
            keyMechanics: maxMechanics
        )
        testDungeon.addToBossEncounters(bossEncounter)

        // Act & Assert - Should not throw
        try context.save()
        XCTAssertEqual(bossEncounter.getKeyMechanics().count, 3)
    }

    // MARK: - Business Logic Tests

    func testDifficultyEnumConversion() {
        // Test all difficulty levels
        let difficulties: [HealerDifficulty] = [.easy, .moderate, .hard, .extreme]

        for difficulty in difficulties {
            // Arrange
            let bossEncounter = BossEncounter(
                context: context,
                name: "Test Boss",
                encounterOrder: 1,
                healerSummary: "Test summary",
                difficultyRating: difficulty
            )

            // Act & Assert
            XCTAssertEqual(bossEncounter.difficulty, difficulty)

            // Test setting difficulty
            let newDifficulty: HealerDifficulty = difficulty == .easy ? .extreme : .easy
            bossEncounter.setDifficulty(newDifficulty)
            XCTAssertEqual(bossEncounter.difficulty, newDifficulty)
            XCTAssertEqual(bossEncounter.difficultyRating, Int16(newDifficulty.rawValue))
        }
    }

    func testHealerDifficultyEnum() {
        // Test enum properties
        XCTAssertEqual(HealerDifficulty.easy.rawValue, 1)
        XCTAssertEqual(HealerDifficulty.moderate.rawValue, 2)
        XCTAssertEqual(HealerDifficulty.hard.rawValue, 3)
        XCTAssertEqual(HealerDifficulty.extreme.rawValue, 4)

        XCTAssertEqual(HealerDifficulty.easy.displayName, "Easy")
        XCTAssertEqual(HealerDifficulty.moderate.displayName, "Moderate")
        XCTAssertEqual(HealerDifficulty.hard.displayName, "Hard")
        XCTAssertEqual(HealerDifficulty.extreme.displayName, "Extreme")

        // Test display info
        let easyInfo = HealerDifficulty.easy.displayInfo
        XCTAssertEqual(easyInfo.name, "Easy")
        XCTAssertEqual(easyInfo.color, "green")

        let moderateInfo = HealerDifficulty.moderate.displayInfo
        XCTAssertEqual(moderateInfo.name, "Moderate")
        XCTAssertEqual(moderateInfo.color, "yellow")

        let hardInfo = HealerDifficulty.hard.displayInfo
        XCTAssertEqual(hardInfo.name, "Hard")
        XCTAssertEqual(hardInfo.color, "orange")

        let extremeInfo = HealerDifficulty.extreme.displayInfo
        XCTAssertEqual(extremeInfo.name, "Extreme")
        XCTAssertEqual(extremeInfo.color, "red")

        // Test all cases
        let allCases = HealerDifficulty.allCases
        XCTAssertEqual(allCases.count, 4)
        XCTAssertTrue(allCases.contains(.easy))
        XCTAssertTrue(allCases.contains(.moderate))
        XCTAssertTrue(allCases.contains(.hard))
        XCTAssertTrue(allCases.contains(.extreme))
    }

    func testKeyMechanicsManagement() {
        // Arrange
        let bossEncounter = BossEncounter(
            context: context,
            name: "Test Boss",
            encounterOrder: 1,
            healerSummary: "Test summary",
            difficultyRating: .moderate
        )

        // Test empty mechanics
        XCTAssertTrue(bossEncounter.getKeyMechanics().isEmpty)

        // Test setting mechanics
        let mechanics = ["Web Blast", "Piercing Strike"]
        bossEncounter.setKeyMechanics(mechanics)
        XCTAssertEqual(bossEncounter.getKeyMechanics(), mechanics)

        // Test adding mechanics
        try? bossEncounter.addKeyMechanic("Call of the Swarm")
        XCTAssertEqual(bossEncounter.getKeyMechanics().count, 3)
        XCTAssertTrue(bossEncounter.getKeyMechanics().contains("Call of the Swarm"))

        // Test removing mechanics
        bossEncounter.removeKeyMechanic("Web Blast")
        XCTAssertEqual(bossEncounter.getKeyMechanics().count, 2)
        XCTAssertFalse(bossEncounter.getKeyMechanics().contains("Web Blast"))
        XCTAssertTrue(bossEncounter.getKeyMechanics().contains("Piercing Strike"))
        XCTAssertTrue(bossEncounter.getKeyMechanics().contains("Call of the Swarm"))
    }

    func testKeyMechanicsWithWhitespaceHandling() {
        // Arrange
        let bossEncounter = BossEncounter(
            context: context,
            name: "Test Boss",
            encounterOrder: 1,
            healerSummary: "Test summary",
            difficultyRating: .moderate
        )

        // Test mechanics with whitespace
        let mechanicsWithWhitespace = ["  Web Blast  ", " Piercing Strike", "Call of the Swarm ", ""]
        bossEncounter.setKeyMechanics(mechanicsWithWhitespace)

        let cleanedMechanics = bossEncounter.getKeyMechanics()
        XCTAssertEqual(cleanedMechanics.count, 3) // Empty string should be filtered out
        XCTAssertEqual(cleanedMechanics[0], "Web Blast") // Trimmed
        XCTAssertEqual(cleanedMechanics[1], "Piercing Strike") // Trimmed
        XCTAssertEqual(cleanedMechanics[2], "Call of the Swarm") // Trimmed
    }

    func testKeyMechanicsLimitEnforcement() {
        // Arrange
        let bossEncounter = BossEncounter(
            context: context,
            name: "Test Boss",
            encounterOrder: 1,
            healerSummary: "Test summary",
            difficultyRating: .moderate
        )

        // Add maximum mechanics
        bossEncounter.setKeyMechanics(["Mechanic 1", "Mechanic 2", "Mechanic 3"])

        // Try to add another mechanic
        XCTAssertThrowsError(try bossEncounter.addKeyMechanic("Mechanic 4")) { error in
            guard let validationError = error as? BossEncounterValidationError else {
                XCTFail("Expected BossEncounterValidationError, got \(error)")
                return
            }

            if case .tooManyKeyMechanics(let count) = validationError {
                XCTAssertEqual(count, 3)
            } else {
                XCTFail("Expected tooManyKeyMechanics, got \(validationError)")
            }
        }

        // Verify count remains at 3
        XCTAssertEqual(bossEncounter.getKeyMechanics().count, 3)
    }

    func testAddEmptyKeyMechanicValidation() {
        // Arrange
        let bossEncounter = BossEncounter(
            context: context,
            name: "Test Boss",
            encounterOrder: 1,
            healerSummary: "Test summary",
            difficultyRating: .moderate
        )

        // Try to add empty mechanic
        XCTAssertThrowsError(try bossEncounter.addKeyMechanic("   ")) { error in
            guard let validationError = error as? BossEncounterValidationError else {
                XCTFail("Expected BossEncounterValidationError, got \(error)")
                return
            }

            if case .emptyKeyMechanic = validationError {
                // Expected error type
            } else {
                XCTFail("Expected emptyKeyMechanic, got \(validationError)")
            }
        }
    }

    func testAbilityCountAndOrdering() throws {
        // Arrange
        let bossEncounter = BossEncounter(
            context: context,
            name: "Boss With Abilities",
            encounterOrder: 1,
            healerSummary: "Test summary",
            difficultyRating: .moderate
        )
        testDungeon.addToBossEncounters(bossEncounter)

        // Initially no abilities
        XCTAssertEqual(bossEncounter.abilityCount, 0)
        XCTAssertTrue(bossEncounter.orderedAbilities.isEmpty)

        // Note: Since BossAbility is in AbilityKit, we'll test the count logic
        // but can't actually create BossAbility instances in DungeonKit tests
        // This tests the relationship handling code paths
    }

    func testFormattedDurationSeconds() {
        // Test various durations in seconds
        let testCases: [(TimeInterval, String)] = [
            (0, "0s"),
            (15, "15s"),
            (30, "30s"),
            (45, "45s"),
            (59, "59s")
        ]

        for (duration, expected) in testCases {
            // Arrange
            let bossEncounter = BossEncounter(
                context: context,
                name: "Test Boss",
                encounterOrder: 1,
                healerSummary: "Test summary",
                difficultyRating: .moderate,
                estimatedDuration: duration
            )

            // Act & Assert
            XCTAssertEqual(bossEncounter.formattedDuration, expected, "Duration \(duration) should format as \(expected)")
        }
    }

    func testFormattedDurationMinutesAndSeconds() {
        // Test durations with minutes and seconds
        let testCases: [(TimeInterval, String)] = [
            (60, "1:00"),
            (75, "1:15"),
            (120, "2:00"),
            (135, "2:15"),
            (180, "3:00"),
            (195, "3:15"),
            (300, "5:00"),
            (365, "6:05")
        ]

        for (duration, expected) in testCases {
            // Arrange
            let bossEncounter = BossEncounter(
                context: context,
                name: "Test Boss",
                encounterOrder: 1,
                healerSummary: "Test summary",
                difficultyRating: .moderate,
                estimatedDuration: duration
            )

            // Act & Assert
            XCTAssertEqual(bossEncounter.formattedDuration, expected, "Duration \(duration) should format as \(expected)")
        }
    }

    func testDifficultyDisplayInfo() {
        let testCases: [(HealerDifficulty, String, String)] = [
            (.easy, "Easy", "green"),
            (.moderate, "Moderate", "yellow"),
            (.hard, "Hard", "orange"),
            (.extreme, "Extreme", "red")
        ]

        for (difficulty, expectedName, expectedColor) in testCases {
            // Arrange
            let bossEncounter = BossEncounter(
                context: context,
                name: "Test Boss",
                encounterOrder: 1,
                healerSummary: "Test summary",
                difficultyRating: difficulty
            )

            // Act
            let displayInfo = bossEncounter.difficultyDisplayInfo

            // Assert
            XCTAssertEqual(displayInfo.name, expectedName)
            XCTAssertEqual(displayInfo.color, expectedColor)
        }
    }

    func testDifficultyDisplayInfoInvalidDifficulty() {
        // Arrange
        let bossEncounter = BossEncounter(
            context: context,
            name: "Test Boss",
            encounterOrder: 1,
            healerSummary: "Test summary",
            difficultyRating: .moderate
        )

        // Manually set invalid difficulty
        bossEncounter.difficultyRating = 999

        // Act
        let displayInfo = bossEncounter.difficultyDisplayInfo

        // Assert
        XCTAssertEqual(displayInfo.name, "Unknown")
        XCTAssertEqual(displayInfo.color, "gray")
    }

    // MARK: - Fetch Request Tests

    func testFetchBossEncountersForDungeon() throws {
        // Arrange
        let boss1 = BossEncounter(context: context, name: "Boss 1", encounterOrder: 2, healerSummary: "Summary 1", difficultyRating: .easy)
        let boss2 = BossEncounter(context: context, name: "Boss 2", encounterOrder: 1, healerSummary: "Summary 2", difficultyRating: .moderate)
        let boss3 = BossEncounter(context: context, name: "Boss 3", encounterOrder: 3, healerSummary: "Summary 3", difficultyRating: .hard)

        testDungeon.addToBossEncounters(boss1)
        testDungeon.addToBossEncounters(boss2)
        testDungeon.addToBossEncounters(boss3)
        try context.save()

        // Act
        let fetchedBosses = try BossEncounter.fetchBossEncounters(for: testDungeon, context: context)

        // Assert - Should be ordered by encounter order
        XCTAssertEqual(fetchedBosses.count, 3)
        XCTAssertEqual(fetchedBosses[0].encounterOrder, 1)
        XCTAssertEqual(fetchedBosses[1].encounterOrder, 2)
        XCTAssertEqual(fetchedBosses[2].encounterOrder, 3)
        XCTAssertEqual(fetchedBosses[0].name, "Boss 2")
        XCTAssertEqual(fetchedBosses[1].name, "Boss 1")
        XCTAssertEqual(fetchedBosses[2].name, "Boss 3")
    }

    func testFetchBossEncountersForDungeonId() throws {
        // Arrange
        let boss = BossEncounter(context: context, name: "Test Boss", encounterOrder: 1, healerSummary: "Summary", difficultyRating: .moderate)
        testDungeon.addToBossEncounters(boss)
        try context.save()

        // Act
        let fetchedBosses = try BossEncounter.fetchBossEncounters(for: testDungeon.id!, context: context)

        // Assert
        XCTAssertEqual(fetchedBosses.count, 1)
        XCTAssertEqual(fetchedBosses[0].id, boss.id)
    }

    func testFetchBossEncountersForNonExistentDungeonId() throws {
        // Arrange
        let nonExistentId = UUID()

        // Act
        let fetchedBosses = try BossEncounter.fetchBossEncounters(for: nonExistentId, context: context)

        // Assert
        XCTAssertTrue(fetchedBosses.isEmpty)
    }

    func testSearchBossEncounters() throws {
        // Arrange
        let bosses = [
            BossEncounter(context: context, name: "Anub'arash", encounterOrder: 1, healerSummary: "Spider boss", difficultyRating: .hard),
            BossEncounter(context: context, name: "Skeinspinner Takazj", encounterOrder: 2, healerSummary: "Web boss", difficultyRating: .extreme),
            BossEncounter(context: context, name: "Rashanan", encounterOrder: 3, healerSummary: "Final boss", difficultyRating: .moderate),
            BossEncounter(context: context, name: "Speaker Shadowcrown", encounterOrder: 1, healerSummary: "Voice boss", difficultyRating: .easy)
        ]

        for boss in bosses {
            testDungeon.addToBossEncounters(boss)
        }
        try context.save()

        // Act & Assert - Test name search
        let anubResults = try BossEncounter.searchBossEncounters(query: "anub", context: context)
        XCTAssertEqual(anubResults.count, 1)
        XCTAssertEqual(anubResults[0].name, "Anub'arash")

        // Test partial match
        let spinnerResults = try BossEncounter.searchBossEncounters(query: "spinner", context: context)
        XCTAssertEqual(spinnerResults.count, 1)
        XCTAssertEqual(spinnerResults[0].name, "Skeinspinner Takazj")

        // Test case insensitive
        let shadowResults = try BossEncounter.searchBossEncounters(query: "SHADOW", context: context)
        XCTAssertEqual(shadowResults.count, 1)
        XCTAssertEqual(shadowResults[0].name, "Speaker Shadowcrown")

        // Test no results
        let noResults = try BossEncounter.searchBossEncounters(query: "nonexistent", context: context)
        XCTAssertTrue(noResults.isEmpty)
    }

    func testFetchBossEncountersByDifficulty() throws {
        // Arrange
        let easyBoss = BossEncounter(context: context, name: "Easy Boss", encounterOrder: 1, healerSummary: "Easy", difficultyRating: .easy)
        let moderateBoss1 = BossEncounter(context: context, name: "Moderate Boss 1", encounterOrder: 1, healerSummary: "Moderate 1", difficultyRating: .moderate)
        let moderateBoss2 = BossEncounter(context: context, name: "Moderate Boss 2", encounterOrder: 2, healerSummary: "Moderate 2", difficultyRating: .moderate)
        let hardBoss = BossEncounter(context: context, name: "Hard Boss", encounterOrder: 3, healerSummary: "Hard", difficultyRating: .hard)

        testDungeon.addToBossEncounters(easyBoss)
        testDungeon.addToBossEncounters(moderateBoss1)
        testDungeon.addToBossEncounters(moderateBoss2)
        testDungeon.addToBossEncounters(hardBoss)
        try context.save()

        // Act & Assert - Test moderate difficulty
        let moderateBosses = try BossEncounter.fetchBossEncounters(difficulty: .moderate, context: context)
        XCTAssertEqual(moderateBosses.count, 2)
        XCTAssertTrue(moderateBosses.allSatisfy { $0.difficulty == .moderate })

        // Test ordering by dungeon display order, then encounter order
        XCTAssertEqual(moderateBosses[0].encounterOrder, 1)
        XCTAssertEqual(moderateBosses[1].encounterOrder, 2)

        // Test easy difficulty
        let easyBosses = try BossEncounter.fetchBossEncounters(difficulty: .easy, context: context)
        XCTAssertEqual(easyBosses.count, 1)
        XCTAssertEqual(easyBosses[0].name, "Easy Boss")

        // Test extreme difficulty (none exist)
        let extremeBosses = try BossEncounter.fetchBossEncounters(difficulty: .extreme, context: context)
        XCTAssertTrue(extremeBosses.isEmpty)
    }

    // MARK: - Relationship Tests

    func testBossEncounterDungeonRelationshipIntegrity() throws {
        // Arrange
        let bossEncounter = BossEncounter(
            context: context,
            name: "Test Boss",
            encounterOrder: 1,
            healerSummary: "Test summary",
            difficultyRating: .moderate
        )

        // Act
        testDungeon.addToBossEncounters(bossEncounter)
        try context.save()

        // Assert
        XCTAssertEqual(bossEncounter.dungeon, testDungeon)
        XCTAssertTrue(testDungeon.bossEncounters?.contains(bossEncounter) ?? false)
    }

    func testRemoveBossEncounterFromDungeon() throws {
        // Arrange
        let bossEncounter = BossEncounter(
            context: context,
            name: "Test Boss",
            encounterOrder: 1,
            healerSummary: "Test summary",
            difficultyRating: .moderate
        )
        testDungeon.addToBossEncounters(bossEncounter)
        try context.save()

        // Act
        testDungeon.removeFromBossEncounters(bossEncounter)
        try context.save()

        // Assert
        XCTAssertEqual(testDungeon.bossEncounters?.count, 0)
        XCTAssertNil(bossEncounter.dungeon)
    }

    // MARK: - Validation Error Tests

    func testValidationErrorDescriptions() {
        // Test all validation error descriptions
        let errors: [BossEncounterValidationError] = [
            .emptyBossName,
            .emptyHealerSummary,
            .healerSummaryTooLong(501),
            .duplicateNameInDungeon("Duplicate Boss"),
            .duplicateEncounterOrder(2),
            .invalidDuration(-60),
            .invalidDifficultyRating(999),
            .tooManyKeyMechanics(4),
            .emptyKeyMechanic
        ]

        for error in errors {
            XCTAssertNotNil(error.errorDescription)
            XCTAssertFalse(error.errorDescription!.isEmpty)
        }
    }

    // MARK: - Edge Cases

    func testBossEncounterWithNilManagedObjectContext() {
        // Arrange
        let bossEncounter = BossEncounter()

        // Act & Assert
        XCTAssertNil(bossEncounter.managedObjectContext)
        XCTAssertEqual(bossEncounter.abilityCount, 0)
        XCTAssertTrue(bossEncounter.orderedAbilities.isEmpty)
        XCTAssertNil(bossEncounter.difficulty) // Should handle nil context gracefully
    }

    func testIdentifiableConformance() {
        // Arrange
        let bossEncounter = BossEncounter(
            context: context,
            name: "Test Boss",
            encounterOrder: 1,
            healerSummary: "Test summary",
            difficultyRating: .moderate
        )

        // Act & Assert
        XCTAssertNotNil(bossEncounter.id)

        // Test that bossEncounter conforms to Identifiable
        let identifiableBoss: any Identifiable = bossEncounter
        XCTAssertEqual(identifiableBoss.id as? UUID, bossEncounter.id)
    }

    func testCoreDataPropertiesAccessibility() {
        // Arrange
        let bossEncounter = BossEncounter(
            context: context,
            name: "Test Boss",
            encounterOrder: 1,
            healerSummary: "Test summary",
            difficultyRating: .moderate
        )
        let testUUID = UUID()

        // Act & Assert - Test all Core Data properties are accessible
        bossEncounter.id = testUUID
        XCTAssertEqual(bossEncounter.id, testUUID)

        bossEncounter.name = "Updated Boss Name"
        XCTAssertEqual(bossEncounter.name, "Updated Boss Name")

        bossEncounter.encounterOrder = 5
        XCTAssertEqual(bossEncounter.encounterOrder, 5)

        bossEncounter.healerSummary = "Updated summary"
        XCTAssertEqual(bossEncounter.healerSummary, "Updated summary")

        bossEncounter.difficultyRating = 3
        XCTAssertEqual(bossEncounter.difficultyRating, 3)

        bossEncounter.estimatedDuration = 300
        XCTAssertEqual(bossEncounter.estimatedDuration, 300)

        bossEncounter.keyMechanics = "mechanic1|mechanic2"
        XCTAssertEqual(bossEncounter.keyMechanics, "mechanic1|mechanic2")

        XCTAssertNotNil(bossEncounter.abilities) // NSSet should be initialized
    }
}