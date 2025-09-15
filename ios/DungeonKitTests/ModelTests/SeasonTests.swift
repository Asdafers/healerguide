//
//  SeasonTests.swift
//  DungeonKitTests
//
//  Unit tests for Season CoreData model - Task T033
//  iOS 13.1+ compatible - First generation iPad Pro support
//

import XCTest
import CoreData
@testable import DungeonKit

final class SeasonTests: XCTestCase {

    // MARK: - Test Infrastructure

    var persistentContainer: NSPersistentContainer!
    var context: NSManagedObjectContext!

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
    }

    override func tearDownWithError() throws {
        context = nil
        persistentContainer = nil
        try super.tearDownWithError()
    }

    // MARK: - Initialization Tests

    func testSeasonInitialization() {
        // Arrange
        let name = "The War Within Season 1"
        let patchVersion = "11.0"

        // Act
        let season = Season(context: context, name: name, majorPatchVersion: patchVersion, isActive: true)

        // Assert
        XCTAssertNotNil(season.id)
        XCTAssertEqual(season.name, name)
        XCTAssertEqual(season.majorPatchVersion, patchVersion)
        XCTAssertTrue(season.isActive)
        XCTAssertNotNil(season.createdAt)
        XCTAssertNotNil(season.updatedAt)
        XCTAssertEqual(season.dungeons?.count, 0)
    }

    func testSeasonInitializationDefaults() {
        // Act
        let season = Season(context: context, name: "Test Season", majorPatchVersion: "11.1")

        // Assert
        XCTAssertFalse(season.isActive) // Default should be false
        XCTAssertNotNil(season.createdAt)
        XCTAssertNotNil(season.updatedAt)
    }

    // MARK: - Validation Tests

    func testValidSeasonInsert() throws {
        // Arrange
        let season = Season(context: context, name: "Valid Season", majorPatchVersion: "11.2")

        // Act & Assert - Should not throw
        try context.save()
        XCTAssertFalse(context.hasChanges)
    }

    func testEmptySeasonNameValidation() {
        // Arrange
        let season = Season(context: context, name: "", majorPatchVersion: "11.0")

        // Act & Assert
        XCTAssertThrowsError(try context.save()) { error in
            guard let validationError = error as? ValidationError else {
                XCTFail("Expected ValidationError, got \(error)")
                return
            }

            if case .emptySeasonName = validationError {
                // Expected error type
            } else {
                XCTFail("Expected emptySeasonName, got \(validationError)")
            }
        }
    }

    func testWhitespaceOnlySeasonNameValidation() {
        // Arrange
        let season = Season(context: context, name: "   \n\t   ", majorPatchVersion: "11.0")

        // Act & Assert
        XCTAssertThrowsError(try context.save()) { error in
            guard let validationError = error as? ValidationError else {
                XCTFail("Expected ValidationError, got \(error)")
                return
            }

            if case .emptySeasonName = validationError {
                // Expected error type
            } else {
                XCTFail("Expected emptySeasonName, got \(validationError)")
            }
        }
    }

    func testDuplicateSeasonNameValidation() throws {
        // Arrange
        let season1 = Season(context: context, name: "Duplicate Name", majorPatchVersion: "11.0")
        try context.save()

        let season2 = Season(context: context, name: "Duplicate Name", majorPatchVersion: "11.1")

        // Act & Assert
        XCTAssertThrowsError(try context.save()) { error in
            guard let validationError = error as? ValidationError else {
                XCTFail("Expected ValidationError, got \(error)")
                return
            }

            if case .duplicateSeasonName(let name) = validationError {
                XCTAssertEqual(name, "Duplicate Name")
            } else {
                XCTFail("Expected duplicateSeasonName, got \(validationError)")
            }
        }
    }

    func testEmptyPatchVersionValidation() {
        // Arrange
        let season = Season(context: context, name: "Test Season", majorPatchVersion: "")

        // Act & Assert
        XCTAssertThrowsError(try context.save()) { error in
            guard let validationError = error as? ValidationError else {
                XCTFail("Expected ValidationError, got \(error)")
                return
            }

            if case .emptyPatchVersion = validationError {
                // Expected error type
            } else {
                XCTFail("Expected emptyPatchVersion, got \(validationError)")
            }
        }
    }

    func testInvalidPatchVersionFormatValidation() {
        let invalidVersions = ["11", "11.0.1", "v11.0", "11.x", "invalid", "11.", ".0"]

        for invalidVersion in invalidVersions {
            // Arrange
            let season = Season(context: context, name: "Test Season \(invalidVersion)", majorPatchVersion: invalidVersion)

            // Act & Assert
            XCTAssertThrowsError(try context.save(), "Version \(invalidVersion) should be invalid") { error in
                guard let validationError = error as? ValidationError else {
                    XCTFail("Expected ValidationError for version \(invalidVersion), got \(error)")
                    return
                }

                if case .invalidPatchVersionFormat(let version) = validationError {
                    XCTAssertEqual(version, invalidVersion)
                } else {
                    XCTFail("Expected invalidPatchVersionFormat for version \(invalidVersion), got \(validationError)")
                }
            }

            // Clean up for next iteration
            context.rollback()
        }
    }

    func testValidPatchVersionFormats() throws {
        let validVersions = ["11.0", "11.1", "12.0", "10.2", "99.99"]

        for validVersion in validVersions {
            // Arrange
            let season = Season(context: context, name: "Test Season \(validVersion)", majorPatchVersion: validVersion)

            // Act & Assert - Should not throw
            try context.save()

            // Clean up for next iteration
            context.delete(season)
            try context.save()
        }
    }

    func testMultipleActiveSeasonsValidation() throws {
        // Arrange
        let season1 = Season(context: context, name: "Active Season 1", majorPatchVersion: "11.0", isActive: true)
        try context.save()

        let season2 = Season(context: context, name: "Active Season 2", majorPatchVersion: "11.1", isActive: true)

        // Act & Assert
        XCTAssertThrowsError(try context.save()) { error in
            guard let validationError = error as? ValidationError else {
                XCTFail("Expected ValidationError, got \(error)")
                return
            }

            if case .multipleActiveSeasons = validationError {
                // Expected error type
            } else {
                XCTFail("Expected multipleActiveSeasons, got \(validationError)")
            }
        }
    }

    func testUpdateValidationWithTimestamp() throws {
        // Arrange
        let season = Season(context: context, name: "Test Season", majorPatchVersion: "11.0")
        try context.save()

        let originalUpdateTime = season.updatedAt

        // Wait a bit to ensure timestamp difference
        Thread.sleep(forTimeInterval: 0.01)

        // Act
        season.name = "Updated Season"
        try context.save()

        // Assert
        XCTAssertNotNil(season.updatedAt)
        XCTAssertGreaterThan(season.updatedAt!, originalUpdateTime!)
    }

    // MARK: - Business Logic Tests

    func testActivateSeasonDeactivatesOthers() throws {
        // Arrange
        let season1 = Season(context: context, name: "Season 1", majorPatchVersion: "11.0", isActive: true)
        let season2 = Season(context: context, name: "Season 2", majorPatchVersion: "11.1", isActive: false)
        try context.save()

        // Act
        try season2.activate()
        try context.save()

        // Assert
        context.refreshAllObjects()
        XCTAssertFalse(season1.isActive)
        XCTAssertTrue(season2.isActive)
    }

    func testActivateSeasonUpdatesTimestamp() throws {
        // Arrange
        let season = Season(context: context, name: "Test Season", majorPatchVersion: "11.0")
        try context.save()

        let originalUpdateTime = season.updatedAt
        Thread.sleep(forTimeInterval: 0.01)

        // Act
        try season.activate()

        // Assert
        XCTAssertTrue(season.isActive)
        XCTAssertNotNil(season.updatedAt)
        XCTAssertGreaterThan(season.updatedAt!, originalUpdateTime!)
    }

    func testActivateWithoutContextThrowsError() {
        // Arrange
        let season = Season()
        season.name = "Test Season"
        season.majorPatchVersion = "11.0"

        // Act & Assert
        XCTAssertThrowsError(try season.activate()) { error in
            guard let validationError = error as? ValidationError else {
                XCTFail("Expected ValidationError, got \(error)")
                return
            }

            if case .noManagedObjectContext = validationError {
                // Expected error type
            } else {
                XCTFail("Expected noManagedObjectContext, got \(validationError)")
            }
        }
    }

    func testHasMinimumDungeonsEmpty() {
        // Arrange
        let season = Season(context: context, name: "Empty Season", majorPatchVersion: "11.0")

        // Act & Assert
        XCTAssertFalse(season.hasMinimumDungeons)
    }

    func testHasMinimumDungeonsWithOne() throws {
        // Arrange
        let season = Season(context: context, name: "Season With Dungeon", majorPatchVersion: "11.0")
        let dungeon = Dungeon(context: context, name: "Test Dungeon", shortName: "TD", difficultyLevel: .mythicPlus, displayOrder: 1)
        season.addToDungeons(dungeon)
        try context.save()

        // Act & Assert
        XCTAssertTrue(season.hasMinimumDungeons)
    }

    func testOrderedDungeonsEmpty() {
        // Arrange
        let season = Season(context: context, name: "Empty Season", majorPatchVersion: "11.0")

        // Act
        let orderedDungeons = season.orderedDungeons

        // Assert
        XCTAssertTrue(orderedDungeons.isEmpty)
    }

    func testOrderedDungeonsSortedByDisplayOrder() throws {
        // Arrange
        let season = Season(context: context, name: "Season With Dungeons", majorPatchVersion: "11.0")

        let dungeon3 = Dungeon(context: context, name: "Third Dungeon", shortName: "TD3", difficultyLevel: .mythicPlus, displayOrder: 3)
        let dungeon1 = Dungeon(context: context, name: "First Dungeon", shortName: "TD1", difficultyLevel: .mythicPlus, displayOrder: 1)
        let dungeon2 = Dungeon(context: context, name: "Second Dungeon", shortName: "TD2", difficultyLevel: .mythicPlus, displayOrder: 2)

        season.addToDungeons(dungeon3)
        season.addToDungeons(dungeon1)
        season.addToDungeons(dungeon2)

        try context.save()

        // Act
        let orderedDungeons = season.orderedDungeons

        // Assert
        XCTAssertEqual(orderedDungeons.count, 3)
        XCTAssertEqual(orderedDungeons[0].displayOrder, 1)
        XCTAssertEqual(orderedDungeons[1].displayOrder, 2)
        XCTAssertEqual(orderedDungeons[2].displayOrder, 3)
        XCTAssertEqual(orderedDungeons[0].name, "First Dungeon")
        XCTAssertEqual(orderedDungeons[1].name, "Second Dungeon")
        XCTAssertEqual(orderedDungeons[2].name, "Third Dungeon")
    }

    // MARK: - Fetch Request Tests

    func testFetchActiveSeasonNone() throws {
        // Arrange
        let _ = Season(context: context, name: "Inactive Season", majorPatchVersion: "11.0", isActive: false)
        try context.save()

        // Act
        let activeSeason = try Season.fetchActiveSeason(context: context)

        // Assert
        XCTAssertNil(activeSeason)
    }

    func testFetchActiveSeasonFound() throws {
        // Arrange
        let _ = Season(context: context, name: "Inactive Season", majorPatchVersion: "11.0", isActive: false)
        let activeSeason = Season(context: context, name: "Active Season", majorPatchVersion: "11.1", isActive: true)
        try context.save()

        // Act
        let fetchedSeason = try Season.fetchActiveSeason(context: context)

        // Assert
        XCTAssertNotNil(fetchedSeason)
        XCTAssertEqual(fetchedSeason?.id, activeSeason.id)
        XCTAssertEqual(fetchedSeason?.name, "Active Season")
        XCTAssertTrue(fetchedSeason?.isActive ?? false)
    }

    func testFetchAllSeasonsOrderedByCreation() throws {
        // Arrange - Create seasons with small delays to ensure different creation times
        let season1 = Season(context: context, name: "First Season", majorPatchVersion: "11.0")
        try context.save()

        Thread.sleep(forTimeInterval: 0.01)

        let season2 = Season(context: context, name: "Second Season", majorPatchVersion: "11.1")
        try context.save()

        Thread.sleep(forTimeInterval: 0.01)

        let season3 = Season(context: context, name: "Third Season", majorPatchVersion: "11.2")
        try context.save()

        // Act
        let allSeasons = try Season.fetchAllSeasons(context: context)

        // Assert - Should be ordered by creation date (newest first)
        XCTAssertEqual(allSeasons.count, 3)
        XCTAssertEqual(allSeasons[0].name, "Third Season")   // Most recent
        XCTAssertEqual(allSeasons[1].name, "Second Season")
        XCTAssertEqual(allSeasons[2].name, "First Season")   // Oldest
    }

    func testFetchAllSeasonsEmpty() throws {
        // Act
        let allSeasons = try Season.fetchAllSeasons(context: context)

        // Assert
        XCTAssertTrue(allSeasons.isEmpty)
    }

    // MARK: - Relationship Tests

    func testSeasonDungeonRelationshipIntegrity() throws {
        // Arrange
        let season = Season(context: context, name: "Test Season", majorPatchVersion: "11.0")
        let dungeon = Dungeon(context: context, name: "Test Dungeon", shortName: "TD", difficultyLevel: .mythicPlus, displayOrder: 1)

        // Act
        season.addToDungeons(dungeon)
        try context.save()

        // Assert
        XCTAssertEqual(season.dungeons?.count, 1)
        XCTAssertTrue(season.dungeons?.contains(dungeon) ?? false)
        XCTAssertEqual(dungeon.season, season)
    }

    func testRemoveDungeonFromSeason() throws {
        // Arrange
        let season = Season(context: context, name: "Test Season", majorPatchVersion: "11.0")
        let dungeon = Dungeon(context: context, name: "Test Dungeon", shortName: "TD", difficultyLevel: .mythicPlus, displayOrder: 1)
        season.addToDungeons(dungeon)
        try context.save()

        // Act
        season.removeFromDungeons(dungeon)
        try context.save()

        // Assert
        XCTAssertEqual(season.dungeons?.count, 0)
        XCTAssertNil(dungeon.season)
    }

    // MARK: - Edge Cases and Error Conditions

    func testSeasonWithNilManagedObjectContext() {
        // Arrange
        let season = Season()

        // Act & Assert
        XCTAssertNil(season.managedObjectContext)
        XCTAssertFalse(season.hasMinimumDungeons)
        XCTAssertTrue(season.orderedDungeons.isEmpty)
    }

    func testValidationErrorDescriptions() {
        // Test all validation error descriptions
        let errors: [ValidationError] = [
            .emptySeasonName,
            .duplicateSeasonName("Test Name"),
            .emptyPatchVersion,
            .invalidPatchVersionFormat("invalid"),
            .multipleActiveSeasons,
            .noManagedObjectContext
        ]

        for error in errors {
            XCTAssertNotNil(error.errorDescription)
            XCTAssertFalse(error.errorDescription!.isEmpty)
        }
    }

    func testIdentifiableConformance() {
        // Arrange
        let season = Season(context: context, name: "Test Season", majorPatchVersion: "11.0")

        // Act & Assert
        XCTAssertNotNil(season.id)

        // Test that season conforms to Identifiable
        let identifiableSeason: any Identifiable = season
        XCTAssertEqual(identifiableSeason.id as? UUID, season.id)
    }

    func testCoreDataPropertiesAccessibility() {
        // Arrange
        let season = Season(context: context, name: "Test Season", majorPatchVersion: "11.0")
        let testUUID = UUID()
        let testDate = Date()

        // Act & Assert - Test all Core Data properties are accessible
        season.id = testUUID
        XCTAssertEqual(season.id, testUUID)

        season.name = "Updated Name"
        XCTAssertEqual(season.name, "Updated Name")

        season.majorPatchVersion = "12.0"
        XCTAssertEqual(season.majorPatchVersion, "12.0")

        season.isActive = true
        XCTAssertTrue(season.isActive)

        season.createdAt = testDate
        XCTAssertEqual(season.createdAt, testDate)

        season.updatedAt = testDate
        XCTAssertEqual(season.updatedAt, testDate)

        XCTAssertNotNil(season.dungeons) // NSSet should be initialized
    }
}