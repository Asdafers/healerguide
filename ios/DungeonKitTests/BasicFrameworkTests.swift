//
//  BasicFrameworkTests.swift
//  DungeonKitTests
//
//  Basic framework functionality tests
//  iOS 13.1+ compatible - First generation iPad Pro support
//

import XCTest
@testable import DungeonKit

final class BasicFrameworkTests: XCTestCase {

    func testFrameworkVersion() {
        // Test that we can access the framework version
        XCTAssertEqual(DungeonKit.version, "1.0.0")
    }

    func testDungeonEntityCreation() {
        // Test that we can create DungeonEntity DTOs
        let dungeon = DungeonEntity(
            id: UUID(),
            name: "Test Dungeon",
            shortName: "TD",
            difficultyLevel: "Mythic+",
            displayOrder: 1,
            estimatedDuration: 1800.0,
            healerNotes: "Test notes",
            bossCount: 3
        )

        XCTAssertEqual(dungeon.name, "Test Dungeon")
        XCTAssertEqual(dungeon.shortName, "TD")
        XCTAssertEqual(dungeon.bossCount, 3)
    }

    func testSeasonEntityCreation() {
        // Test that we can create SeasonEntity DTOs
        let season = SeasonEntity(
            id: UUID(),
            name: "The War Within Season 1",
            majorPatchVersion: "11.0",
            isActive: true,
            dungeonCount: 8,
            createdAt: Date(),
            updatedAt: Date()
        )

        XCTAssertEqual(season.name, "The War Within Season 1")
        XCTAssertEqual(season.majorPatchVersion, "11.0")
        XCTAssertTrue(season.isActive)
        XCTAssertEqual(season.dungeonCount, 8)
    }

    func testBossEncounterEntityCreation() {
        // Test that we can create BossEncounterEntity DTOs
        let boss = BossEncounterEntity(
            id: UUID(),
            name: "Test Boss",
            encounterOrder: 1,
            healerSummary: "Test healing summary",
            difficultyRating: 3,
            estimatedDuration: 300.0,
            keyMechanics: ["Mechanic 1", "Mechanic 2"],
            abilityCount: 5
        )

        XCTAssertEqual(boss.name, "Test Boss")
        XCTAssertEqual(boss.encounterOrder, 1)
        XCTAssertEqual(boss.keyMechanics.count, 2)
        XCTAssertEqual(boss.abilityCount, 5)
    }

    func testDungeonDataError() {
        // Test that we can work with framework error types
        let error = DungeonDataError.noActiveSeason
        XCTAssertEqual(error.errorDescription, "No active season found. Please update the app.")

        let dungeonId = UUID()
        let notFoundError = DungeonDataError.dungeonNotFound(dungeonId)
        XCTAssertTrue(notFoundError.errorDescription?.contains(dungeonId.uuidString) == true)
    }
}