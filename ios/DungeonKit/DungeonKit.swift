//
//  DungeonKit.swift
//  DungeonKit
//
//  Created by HealerKit on 2025-09-14.
//

import Foundation
#if canImport(CoreData)
import CoreData
#endif

// MARK: - Public Interface

/// Protocol for providing dungeon data access
public protocol DungeonDataProviding {
    /// Fetch all dungeons for active season, ordered by display order
    func fetchDungeonsForActiveSeason() async throws -> [DungeonEntity]

    /// Fetch specific dungeon by ID with all boss encounters
    func fetchDungeon(id: UUID) async throws -> DungeonEntity?

    /// Search dungeons by name or short name (case-insensitive)
    func searchDungeons(query: String) async throws -> [DungeonEntity]

    /// Fetch boss encounters for dungeon, ordered by encounter order
    func fetchBossEncounters(for dungeonId: UUID) async throws -> [BossEncounterEntity]
}

/// Protocol for providing season data access
public protocol SeasonDataProviding {
    /// Get currently active season
    func getActiveSeason() async throws -> SeasonEntity?

    /// Fetch all seasons ordered by creation date
    func fetchAllSeasons() async throws -> [SeasonEntity]

    /// Update season data from major patch content bundle
    func updateSeasonData(_ seasonData: SeasonUpdateData) async throws
}

// MARK: - Data Transfer Objects

/// Dungeon entity representing a single dungeon
public struct DungeonEntity {
    public let id: UUID
    public let name: String
    public let shortName: String
    public let difficultyLevel: String
    public let displayOrder: Int
    public let estimatedDuration: TimeInterval
    public let healerNotes: String?
    public let bossCount: Int  // For UI display optimization

    public init(id: UUID, name: String, shortName: String, difficultyLevel: String,
                displayOrder: Int, estimatedDuration: TimeInterval, healerNotes: String?, bossCount: Int) {
        self.id = id
        self.name = name
        self.shortName = shortName
        self.difficultyLevel = difficultyLevel
        self.displayOrder = displayOrder
        self.estimatedDuration = estimatedDuration
        self.healerNotes = healerNotes
        self.bossCount = bossCount
    }
}

/// Boss encounter entity representing a single boss fight
public struct BossEncounterEntity {
    public let id: UUID
    public let name: String
    public let encounterOrder: Int
    public let healerSummary: String
    public let difficultyRating: Int
    public let estimatedDuration: TimeInterval
    public let keyMechanics: [String]
    public let abilityCount: Int  // For lazy loading decision

    public init(id: UUID, name: String, encounterOrder: Int, healerSummary: String,
                difficultyRating: Int, estimatedDuration: TimeInterval, keyMechanics: [String], abilityCount: Int) {
        self.id = id
        self.name = name
        self.encounterOrder = encounterOrder
        self.healerSummary = healerSummary
        self.difficultyRating = difficultyRating
        self.estimatedDuration = estimatedDuration
        self.keyMechanics = keyMechanics
        self.abilityCount = abilityCount
    }
}

/// Season entity representing a content season
public struct SeasonEntity {
    public let id: UUID
    public let name: String
    public let majorPatchVersion: String
    public let isActive: Bool
    public let dungeonCount: Int
    public let createdAt: Date
    public let updatedAt: Date

    public init(id: UUID, name: String, majorPatchVersion: String, isActive: Bool,
                dungeonCount: Int, createdAt: Date, updatedAt: Date) {
        self.id = id
        self.name = name
        self.majorPatchVersion = majorPatchVersion
        self.isActive = isActive
        self.dungeonCount = dungeonCount
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

/// Season update data for content patches
public struct SeasonUpdateData {
    public let seasonInfo: SeasonEntity
    public let dungeons: [DungeonUpdateData]

    public init(seasonInfo: SeasonEntity, dungeons: [DungeonUpdateData]) {
        self.seasonInfo = seasonInfo
        self.dungeons = dungeons
    }
}

/// Dungeon update data for content patches
public struct DungeonUpdateData {
    public let dungeonInfo: DungeonEntity
    public let bossEncounters: [BossEncounterUpdateData]

    public init(dungeonInfo: DungeonEntity, bossEncounters: [BossEncounterUpdateData]) {
        self.dungeonInfo = dungeonInfo
        self.bossEncounters = bossEncounters
    }
}

/// Boss encounter update data for content patches
public struct BossEncounterUpdateData {
    public let encounterInfo: BossEncounterEntity
    public let abilities: [AbilityUpdateData]

    public init(encounterInfo: BossEncounterEntity, abilities: [AbilityUpdateData]) {
        self.encounterInfo = encounterInfo
        self.abilities = abilities
    }
}

/// Ability update data for content patches
public struct AbilityUpdateData {
    public let id: UUID
    public let name: String
    public let type: String
    public let targets: String
    public let damageProfile: String
    public let healerAction: String
    public let criticalInsight: String
    public let cooldown: TimeInterval?
    public let displayOrder: Int
    public let isKeyMechanic: Bool

    public init(id: UUID, name: String, type: String, targets: String, damageProfile: String,
                healerAction: String, criticalInsight: String, cooldown: TimeInterval?, displayOrder: Int, isKeyMechanic: Bool) {
        self.id = id
        self.name = name
        self.type = type
        self.targets = targets
        self.damageProfile = damageProfile
        self.healerAction = healerAction
        self.criticalInsight = criticalInsight
        self.cooldown = cooldown
        self.displayOrder = displayOrder
        self.isKeyMechanic = isKeyMechanic
    }
}

// MARK: - Error Handling

/// Errors that can occur when accessing dungeon data
public enum DungeonDataError: LocalizedError {
    case noActiveSeason
    case dungeonNotFound(UUID)
    case dataCorruption(String)
    case storageError(Error)

    public var errorDescription: String? {
        switch self {
        case .noActiveSeason:
            return "No active season found. Please update the app."
        case .dungeonNotFound(let id):
            return "Dungeon with ID \(id) not found."
        case .dataCorruption(let details):
            return "Data corruption detected: \(details)"
        case .storageError(let error):
            return "Storage error: \(error.localizedDescription)"
        }
    }
}

/// DungeonKit - Framework for managing dungeon and boss encounter data
/// Provides offline access to World of Warcraft Mythic+ dungeon information
public final class DungeonKit {

    /// Shared instance
    public static let shared = DungeonKit()

    private init() {}

    /// Framework version
    public static let version = "1.0.0"

    // MARK: - Service Factory Methods

#if canImport(CoreData)
    /// Create a DungeonDataProvider with CoreData context
    /// - Parameters:
    ///   - context: NSManagedObjectContext for data operations
    ///   - seasonProvider: SeasonDataProvider for season operations
    /// - Returns: Configured DungeonDataProvider instance
    public static func createDungeonDataProvider(
        managedObjectContext context: NSManagedObjectContext,
        seasonDataProvider: SeasonDataProviding
    ) -> DungeonDataProviding {
        return DungeonDataProvider(
            managedObjectContext: context,
            seasonDataProvider: seasonDataProvider
        )
    }

    /// Create a SeasonDataProvider with CoreData context
    /// - Parameter context: NSManagedObjectContext for data operations
    /// - Returns: Configured SeasonDataProvider instance
    public static func createSeasonDataProvider(
        managedObjectContext context: NSManagedObjectContext
    ) -> SeasonDataProviding {
        return SeasonDataProvider(managedObjectContext: context)
    }
#endif
}