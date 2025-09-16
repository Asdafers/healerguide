//
//  DataIntegrityValidationTests.swift
//  DungeonKitTests
//
//  Integration tests for complete dungeon-encounter data integrity
//  Validates relationships and cross-references between all content
//

import XCTest
import CoreData
@testable import DungeonKit

final class DataIntegrityValidationTests: XCTestCase {

    var persistentContainer: NSPersistentContainer!
    var context: NSManagedObjectContext!
    var testSeason: Season!

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
        testSeason = Season(context: context, name: "Integration Test Season", majorPatchVersion: "11.0", isActive: true)
        try createCompleteTestDataset()
    }

    override func tearDownWithError() throws {
        testSeason = nil
        context = nil
        persistentContainer = nil
        try super.tearDownWithError()
    }

    // MARK: - Complete Dataset Validation

    func testCompleteSeasonDataIntegrity() throws {
        let dungeons = try Dungeon.fetchDungeonsForActiveSeason(context: context)

        // Verify complete dataset
        XCTAssertEqual(dungeons.count, 8, "Should have exactly 8 dungeons for mythic+ season")

        var totalBosses = 0
        for dungeon in dungeons {
            let bosses = try BossEncounter.fetchBossEncounters(for: dungeon, context: context)
            totalBosses += bosses.count

            // Each dungeon must have 3-4 bosses
            XCTAssertTrue((3...4).contains(bosses.count),
                         "Dungeon \(dungeon.name ?? "") should have 3-4 bosses")

            // Verify all boss relationships
            for boss in bosses {
                XCTAssertEqual(boss.dungeon, dungeon, "Boss-dungeon relationship integrity failed")
            }
        }

        // Total boss count should be reasonable (24-32 bosses across 8 dungeons)
        XCTAssertTrue((24...32).contains(totalBosses), "Total boss count should be 24-32")
    }

    func testCrossReferenceIntegrity() throws {
        let dungeons = try Dungeon.fetchDungeonsForActiveSeason(context: context)

        for dungeon in dungeons {
            // Test dungeon->boss relationship
            let bossesFromDungeon = dungeon.orderedBossEncounters
            let bossesFromQuery = try BossEncounter.fetchBossEncounters(for: dungeon, context: context)

            XCTAssertEqual(bossesFromDungeon.count, bossesFromQuery.count,
                          "Dungeon relationship and query results should match")

            // Test boss->dungeon back-reference
            for boss in bossesFromDungeon {
                XCTAssertEqual(boss.dungeon, dungeon, "Boss back-reference failed")
            }
        }
    }

    func testDataConsistencyAcrossQueries() throws {
        // Test different query methods return consistent data
        let allDungeons = try Dungeon.fetchDungeonsForActiveSeason(context: context)
        let seasonDungeons = try Dungeon.fetchDungeons(for: testSeason, context: context)

        XCTAssertEqual(allDungeons.count, seasonDungeons.count, "Different fetch methods should return same count")

        // Verify same dungeons returned
        let allIds = Set(allDungeons.compactMap { $0.id })
        let seasonIds = Set(seasonDungeons.compactMap { $0.id })
        XCTAssertEqual(allIds, seasonIds, "Different fetch methods should return same dungeons")
    }

    // MARK: - Helper Methods

    private func createCompleteTestDataset() throws {
        let dungeonSpecs = [
            ("The Dawnbreaker", "DB", 3, [.easy, .moderate, .hard]),
            ("Ara-Kara", "AK", 3, [.moderate, .hard, .extreme]),
            ("City of Threads", "COT", 3, [.easy, .moderate, .moderate]),
            ("The Stonevault", "SV", 4, [.moderate, .hard, .hard, .extreme]),
            ("Mists of Tirna Scithe", "MOTS", 3, [.easy, .easy, .moderate]),
            ("The Necrotic Wake", "NW", 4, [.moderate, .moderate, .hard, .extreme]),
            ("Siege of Boralus", "SOB", 4, [.hard, .hard, .extreme, .extreme]),
            ("Grim Batol", "GB", 4, [.moderate, .hard, .hard, .extreme])
        ]

        for (index, (name, shortName, bossCount, difficulties)) in dungeonSpecs.enumerated() {
            let dungeon = Dungeon(
                context: context,
                name: name,
                shortName: shortName,
                difficultyLevel: .mythicPlus,
                displayOrder: Int16(index + 1),
                estimatedDuration: TimeInterval((20 + index * 3) * 60)
            )

            testSeason.addToDungeons(dungeon)

            for (bossIndex, difficulty) in difficulties.enumerated() {
                let boss = BossEncounter(
                    context: context,
                    name: "\(name) Boss \(bossIndex + 1)",
                    encounterOrder: Int16(bossIndex + 1),
                    healerSummary: "Complete healer guide for boss \(bossIndex + 1) in \(name). Focus on positioning and cooldown management during key phases.",
                    difficultyRating: difficulty,
                    estimatedDuration: TimeInterval(90 + bossIndex * 30),
                    keyMechanics: ["Key Mechanic 1", "Key Mechanic 2"]
                )

                dungeon.addToBossEncounters(boss)
            }
        }

        try context.save()
    }
}