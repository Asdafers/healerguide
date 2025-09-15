//
//  ServiceIntegrationTests.swift
//  DungeonKitTests
//
//  Created by HealerKit on 2025-09-15.
//  Integration tests for DungeonDataProvider and SeasonDataProvider services
//

import XCTest
import CoreData
@testable import DungeonKit

/// Integration tests verifying that T018 and T019 services work correctly
final class ServiceIntegrationTests: XCTestCase {

    // MARK: - Test Properties

    private var inMemoryContext: NSManagedObjectContext!
    private var seasonDataProvider: SeasonDataProviding!
    private var dungeonDataProvider: DungeonDataProviding!

    // Test data
    private let testSeasonId = UUID(uuidString: "11111111-2222-3333-4444-555555555555")!
    private let testDungeonId = UUID(uuidString: "AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE")!
    private let testBossId = UUID(uuidString: "BBBBBBBB-CCCC-DDDD-EEEE-FFFFFFFFFFFF")!

    override func setUpWithError() throws {
        try super.setUpWithError()

        // Create in-memory CoreData stack for testing
        inMemoryContext = createInMemoryCoreDataContext()

        // Create service instances
        seasonDataProvider = DungeonKit.createSeasonDataProvider(managedObjectContext: inMemoryContext)
        dungeonDataProvider = DungeonKit.createDungeonDataProvider(
            managedObjectContext: inMemoryContext,
            seasonDataProvider: seasonDataProvider
        )

        // Set up test data
        try setupTestData()
    }

    override func tearDownWithError() throws {
        inMemoryContext = nil
        seasonDataProvider = nil
        dungeonDataProvider = nil
        try super.tearDownWithError()
    }

    // MARK: - Season Data Provider Tests

    func testSeasonDataProvider_getActiveSeason_returnsCorrectSeason() async throws {
        // When: Getting active season
        let activeSeason = try await seasonDataProvider.getActiveSeason()

        // Then: Should return the test active season
        XCTAssertNotNil(activeSeason, "Active season should exist")
        XCTAssertEqual(activeSeason?.id, testSeasonId, "Should return correct season ID")
        XCTAssertEqual(activeSeason?.name, "The War Within Season 1", "Should return correct season name")
        XCTAssertEqual(activeSeason?.majorPatchVersion, "11.0", "Should return correct patch version")
        XCTAssertTrue(activeSeason?.isActive == true, "Season should be marked as active")
        XCTAssertEqual(activeSeason?.dungeonCount, 8, "Should have correct dungeon count")
    }

    func testSeasonDataProvider_fetchAllSeasons_returnsAllSeasons() async throws {
        // When: Fetching all seasons
        let seasons = try await seasonDataProvider.fetchAllSeasons()

        // Then: Should return all test seasons
        XCTAssertGreaterThanOrEqual(seasons.count, 1, "Should have at least one season")

        let activeSeason = seasons.first { $0.isActive }
        XCTAssertNotNil(activeSeason, "Should have an active season")
        XCTAssertEqual(activeSeason?.id, testSeasonId, "Active season should match test data")
    }

    func testSeasonDataProvider_updateSeasonData_updatesCorrectly() async throws {
        // Given: New season data for update
        let newSeason = SeasonEntity(
            id: UUID(),
            name: "Updated Season",
            majorPatchVersion: "11.1",
            isActive: true,
            dungeonCount: 10,
            createdAt: Date(),
            updatedAt: Date()
        )

        let newDungeon = DungeonEntity(
            id: UUID(),
            name: "New Test Dungeon",
            shortName: "NewDungeon",
            difficultyLevel: "Mythic+",
            displayOrder: 9,
            estimatedDuration: 1800,
            healerNotes: "New dungeon notes",
            bossCount: 4
        )

        let newBoss = BossEncounterEntity(
            id: UUID(),
            name: "New Test Boss",
            encounterOrder: 1,
            healerSummary: "New boss summary",
            difficultyRating: 7,
            estimatedDuration: 300,
            keyMechanics: ["New Mechanic"],
            abilityCount: 5
        )

        let updateData = SeasonUpdateData(
            seasonInfo: newSeason,
            dungeons: [
                DungeonUpdateData(
                    dungeonInfo: newDungeon,
                    bossEncounters: [
                        BossEncounterUpdateData(
                            encounterInfo: newBoss,
                            abilities: []
                        )
                    ]
                )
            ]
        )

        // When: Updating season data
        try await seasonDataProvider.updateSeasonData(updateData)

        // Then: Should have updated season as active
        let activeSeason = try await seasonDataProvider.getActiveSeason()
        XCTAssertEqual(activeSeason?.id, newSeason.id, "New season should be active")
        XCTAssertEqual(activeSeason?.name, "Updated Season", "Season name should be updated")

        // And: Old season should no longer be active
        let allSeasons = try await seasonDataProvider.fetchAllSeasons()
        let oldActiveSeasons = allSeasons.filter { $0.isActive && $0.id != newSeason.id }
        XCTAssertTrue(oldActiveSeasons.isEmpty, "Only one season should be active")
    }

    // MARK: - Dungeon Data Provider Tests

    func testDungeonDataProvider_fetchDungeonsForActiveSeason_returnsCorrectDungeons() async throws {
        // When: Fetching dungeons for active season
        let dungeons = try await dungeonDataProvider.fetchDungeonsForActiveSeason()

        // Then: Should return dungeons from active season
        XCTAssertGreaterThanOrEqual(dungeons.count, 1, "Should have at least one dungeon")

        let testDungeon = dungeons.first { $0.id == testDungeonId }
        XCTAssertNotNil(testDungeon, "Should contain test dungeon")
        XCTAssertEqual(testDungeon?.name, "Ara-Kara, City of Echoes", "Should have correct name")
        XCTAssertEqual(testDungeon?.shortName, "Ara-Kara", "Should have correct short name")
        XCTAssertEqual(testDungeon?.bossCount, 3, "Should have correct boss count")
    }

    func testDungeonDataProvider_fetchDungeon_returnsSpecificDungeon() async throws {
        // When: Fetching specific dungeon by ID
        let dungeon = try await dungeonDataProvider.fetchDungeon(id: testDungeonId)

        // Then: Should return correct dungeon
        XCTAssertNotNil(dungeon, "Should find dungeon by ID")
        XCTAssertEqual(dungeon?.id, testDungeonId, "Should have correct ID")
        XCTAssertEqual(dungeon?.name, "Ara-Kara, City of Echoes", "Should have correct name")
        XCTAssertEqual(dungeon?.difficultyLevel, "Mythic+", "Should have correct difficulty")
    }

    func testDungeonDataProvider_fetchDungeon_returnsNilForInvalidId() async throws {
        // Given: Invalid dungeon ID
        let invalidId = UUID()

        // When: Fetching dungeon with invalid ID
        let dungeon = try await dungeonDataProvider.fetchDungeon(id: invalidId)

        // Then: Should return nil
        XCTAssertNil(dungeon, "Should return nil for non-existent dungeon")
    }

    func testDungeonDataProvider_searchDungeons_caseInsensitiveSearch() async throws {
        // When: Searching dungeons case-insensitively
        let results1 = try await dungeonDataProvider.searchDungeons(query: "ara")
        let results2 = try await dungeonDataProvider.searchDungeons(query: "ARA")
        let results3 = try await dungeonDataProvider.searchDungeons(query: "Ara-Kara")

        // Then: All searches should return the same results
        XCTAssertGreaterThanOrEqual(results1.count, 1, "Should find dungeon with lowercase")
        XCTAssertGreaterThanOrEqual(results2.count, 1, "Should find dungeon with uppercase")
        XCTAssertGreaterThanOrEqual(results3.count, 1, "Should find dungeon with full name")

        XCTAssertEqual(results1.count, results2.count, "Case should not affect results")
        XCTAssertEqual(results2.count, results3.count, "Partial and full name should work")
    }

    func testDungeonDataProvider_searchDungeons_emptyQueryReturnsEmpty() async throws {
        // When: Searching with empty query
        let emptyResults = try await dungeonDataProvider.searchDungeons(query: "")
        let whitespaceResults = try await dungeonDataProvider.searchDungeons(query: "   ")

        // Then: Should return empty results
        XCTAssertTrue(emptyResults.isEmpty, "Empty query should return no results")
        XCTAssertTrue(whitespaceResults.isEmpty, "Whitespace query should return no results")
    }

    func testDungeonDataProvider_fetchBossEncounters_returnsCorrectEncounters() async throws {
        // When: Fetching boss encounters for test dungeon
        let encounters = try await dungeonDataProvider.fetchBossEncounters(for: testDungeonId)

        // Then: Should return boss encounters in correct order
        XCTAssertGreaterThanOrEqual(encounters.count, 1, "Should have at least one encounter")

        let testEncounter = encounters.first { $0.id == testBossId }
        XCTAssertNotNil(testEncounter, "Should contain test boss encounter")
        XCTAssertEqual(testEncounter?.name, "Avanoxx", "Should have correct boss name")
        XCTAssertEqual(testEncounter?.encounterOrder, 1, "Should have correct encounter order")
        XCTAssertEqual(testEncounter?.abilityCount, 6, "Should have correct ability count")

        // Verify encounters are ordered by encounterOrder
        for i in 1..<encounters.count {
            XCTAssertLessThanOrEqual(
                encounters[i-1].encounterOrder,
                encounters[i].encounterOrder,
                "Encounters should be ordered by encounterOrder"
            )
        }
    }

    func testDungeonDataProvider_fetchBossEncounters_invalidDungeonThrowsError() async throws {
        // Given: Invalid dungeon ID
        let invalidId = UUID()

        // When: Fetching encounters for invalid dungeon
        // Then: Should throw dungeonNotFound error
        do {
            let _ = try await dungeonDataProvider.fetchBossEncounters(for: invalidId)
            XCTFail("Should throw error for invalid dungeon ID")
        } catch DungeonDataError.dungeonNotFound(let id) {
            XCTAssertEqual(id, invalidId, "Error should contain the invalid ID")
        } catch {
            XCTFail("Should throw DungeonDataError.dungeonNotFound, got: \(error)")
        }
    }

    // MARK: - Performance Tests

    func testDungeonDataProvider_performance_fetchDungeonsUnder3Seconds() async throws {
        // Given: Performance measurement
        let startTime = CFAbsoluteTimeGetCurrent()

        // When: Fetching dungeons multiple times (simulating usage)
        for _ in 0..<5 {
            let _ = try await dungeonDataProvider.fetchDungeonsForActiveSeason()
        }

        let elapsedTime = CFAbsoluteTimeGetCurrent() - startTime

        // Then: Should complete within performance target
        XCTAssertLessThan(elapsedTime, 3.0, "Multiple dungeon fetches should complete within 3 seconds")
    }

    func testSeasonDataProvider_performance_activeSeasonCaching() async throws {
        // When: Fetching active season multiple times
        let startTime = CFAbsoluteTimeGetCurrent()

        for _ in 0..<10 {
            let _ = try await seasonDataProvider.getActiveSeason()
        }

        let elapsedTime = CFAbsoluteTimeGetCurrent() - startTime

        // Then: Should be very fast due to caching
        XCTAssertLessThan(elapsedTime, 0.5, "Cached active season fetches should be very fast")
    }

    // MARK: - Error Handling Tests

    func testDungeonDataProvider_noActiveSeasonThrowsError() async throws {
        // Given: No active season (deactivate test season)
        let seasonUpdate = SeasonUpdateData(
            seasonInfo: SeasonEntity(
                id: testSeasonId,
                name: "The War Within Season 1",
                majorPatchVersion: "11.0",
                isActive: false, // Deactivate
                dungeonCount: 8,
                createdAt: Date().addingTimeInterval(-86400),
                updatedAt: Date()
            ),
            dungeons: []
        )
        try await seasonDataProvider.updateSeasonData(seasonUpdate)

        // When: Fetching dungeons with no active season
        // Then: Should throw noActiveSeason error
        do {
            let _ = try await dungeonDataProvider.fetchDungeonsForActiveSeason()
            XCTFail("Should throw noActiveSeason error")
        } catch DungeonDataError.noActiveSeason {
            // Expected error
        } catch {
            XCTFail("Should throw DungeonDataError.noActiveSeason, got: \(error)")
        }
    }

    // MARK: - Test Data Setup

    private func createInMemoryCoreDataContext() -> NSManagedObjectContext {
        let managedObjectModel = NSManagedObjectModel()

        // Create Season entity
        let seasonEntity = NSEntityDescription()
        seasonEntity.name = "Season"
        seasonEntity.managedObjectClassName = NSStringFromClass(NSManagedObject.self)
        seasonEntity.properties = createSeasonProperties()

        // Create Dungeon entity
        let dungeonEntity = NSEntityDescription()
        dungeonEntity.name = "Dungeon"
        dungeonEntity.managedObjectClassName = NSStringFromClass(NSManagedObject.self)
        dungeonEntity.properties = createDungeonProperties()

        // Create BossEncounter entity
        let bossEntity = NSEntityDescription()
        bossEntity.name = "BossEncounter"
        bossEntity.managedObjectClassName = NSStringFromClass(NSManagedObject.self)
        bossEntity.properties = createBossEncounterProperties()

        managedObjectModel.entities = [seasonEntity, dungeonEntity, bossEntity]

        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        try! persistentStoreCoordinator.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil, options: nil)

        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = persistentStoreCoordinator

        return context
    }

    private func createSeasonProperties() -> [NSPropertyDescription] {
        return [
            createAttribute(name: "id", type: .UUIDAttributeType),
            createAttribute(name: "name", type: .stringAttributeType),
            createAttribute(name: "majorPatchVersion", type: .stringAttributeType),
            createAttribute(name: "isActive", type: .booleanAttributeType),
            createAttribute(name: "dungeonCount", type: .integer32AttributeType),
            createAttribute(name: "createdAt", type: .dateAttributeType),
            createAttribute(name: "updatedAt", type: .dateAttributeType)
        ]
    }

    private func createDungeonProperties() -> [NSPropertyDescription] {
        return [
            createAttribute(name: "id", type: .UUIDAttributeType),
            createAttribute(name: "name", type: .stringAttributeType),
            createAttribute(name: "shortName", type: .stringAttributeType),
            createAttribute(name: "difficultyLevel", type: .stringAttributeType),
            createAttribute(name: "displayOrder", type: .integer32AttributeType),
            createAttribute(name: "estimatedDuration", type: .doubleAttributeType),
            createAttribute(name: "healerNotes", type: .stringAttributeType, optional: true),
            createAttribute(name: "bossCount", type: .integer32AttributeType),
            createAttribute(name: "seasonId", type: .UUIDAttributeType)
        ]
    }

    private func createBossEncounterProperties() -> [NSPropertyDescription] {
        return [
            createAttribute(name: "id", type: .UUIDAttributeType),
            createAttribute(name: "name", type: .stringAttributeType),
            createAttribute(name: "encounterOrder", type: .integer32AttributeType),
            createAttribute(name: "healerSummary", type: .stringAttributeType),
            createAttribute(name: "difficultyRating", type: .integer32AttributeType),
            createAttribute(name: "estimatedDuration", type: .doubleAttributeType),
            createAttribute(name: "keyMechanics", type: .transformableAttributeType),
            createAttribute(name: "abilityCount", type: .integer32AttributeType),
            createAttribute(name: "dungeonId", type: .UUIDAttributeType)
        ]
    }

    private func createAttribute(name: String, type: NSAttributeType, optional: Bool = false) -> NSAttributeDescription {
        let attribute = NSAttributeDescription()
        attribute.name = name
        attribute.attributeType = type
        attribute.isOptional = optional
        return attribute
    }

    private func setupTestData() throws {
        // Create test season
        let seasonMO = NSEntityDescription.insertNewObject(forEntityName: "Season", into: inMemoryContext)
        seasonMO.setValue(testSeasonId, forKey: "id")
        seasonMO.setValue("The War Within Season 1", forKey: "name")
        seasonMO.setValue("11.0", forKey: "majorPatchVersion")
        seasonMO.setValue(true, forKey: "isActive")
        seasonMO.setValue(8, forKey: "dungeonCount")
        seasonMO.setValue(Date().addingTimeInterval(-86400), forKey: "createdAt")
        seasonMO.setValue(Date(), forKey: "updatedAt")

        // Create test dungeon
        let dungeonMO = NSEntityDescription.insertNewObject(forEntityName: "Dungeon", into: inMemoryContext)
        dungeonMO.setValue(testDungeonId, forKey: "id")
        dungeonMO.setValue("Ara-Kara, City of Echoes", forKey: "name")
        dungeonMO.setValue("Ara-Kara", forKey: "shortName")
        dungeonMO.setValue("Mythic+", forKey: "difficultyLevel")
        dungeonMO.setValue(1, forKey: "displayOrder")
        dungeonMO.setValue(1800.0, forKey: "estimatedDuration")
        dungeonMO.setValue("Spider-themed dungeon requiring strong group healing.", forKey: "healerNotes")
        dungeonMO.setValue(3, forKey: "bossCount")
        dungeonMO.setValue(testSeasonId, forKey: "seasonId")

        // Create test boss encounter
        let bossMO = NSEntityDescription.insertNewObject(forEntityName: "BossEncounter", into: inMemoryContext)
        bossMO.setValue(testBossId, forKey: "id")
        bossMO.setValue("Avanoxx", forKey: "name")
        bossMO.setValue(1, forKey: "encounterOrder")
        bossMO.setValue("Spider matriarch requiring intensive healing management.", forKey: "healerSummary")
        bossMO.setValue(8, forKey: "difficultyRating")
        bossMO.setValue(240.0, forKey: "estimatedDuration")
        bossMO.setValue(["Alerting Shrill", "Toxic Pools", "Web Entanglement"], forKey: "keyMechanics")
        bossMO.setValue(6, forKey: "abilityCount")
        bossMO.setValue(testDungeonId, forKey: "dungeonId")

        try inMemoryContext.save()
    }
}