// DungeonKit Library Contract
// Manages dungeon and boss encounter data access

import Foundation
import CoreData

// MARK: - Public Interface

protocol DungeonDataProviding {
    /// Fetch all dungeons for active season, ordered by display order
    func fetchDungeonsForActiveSeason() async throws -> [DungeonEntity]

    /// Fetch specific dungeon by ID with all boss encounters
    func fetchDungeon(id: UUID) async throws -> DungeonEntity?

    /// Search dungeons by name or short name (case-insensitive)
    func searchDungeons(query: String) async throws -> [DungeonEntity]

    /// Fetch boss encounters for dungeon, ordered by encounter order
    func fetchBossEncounters(for dungeonId: UUID) async throws -> [BossEncounterEntity]
}

protocol SeasonDataProviding {
    /// Get currently active season
    func getActiveSeason() async throws -> SeasonEntity?

    /// Fetch all seasons ordered by creation date
    func fetchAllSeasons() async throws -> [SeasonEntity]

    /// Update season data from major patch content bundle
    func updateSeasonData(_ seasonData: SeasonUpdateData) async throws
}

// MARK: - Data Transfer Objects

struct DungeonEntity {
    let id: UUID
    let name: String
    let shortName: String
    let difficultyLevel: String
    let displayOrder: Int
    let estimatedDuration: TimeInterval
    let healerNotes: String?
    let bossCount: Int  // For UI display optimization
}

struct BossEncounterEntity {
    let id: UUID
    let name: String
    let encounterOrder: Int
    let healerSummary: String
    let difficultyRating: Int
    let estimatedDuration: TimeInterval
    let keyMechanics: [String]
    let abilityCount: Int  // For lazy loading decision
}

struct SeasonEntity {
    let id: UUID
    let name: String
    let majorPatchVersion: String
    let isActive: Bool
    let dungeonCount: Int
    let createdAt: Date
    let updatedAt: Date
}

struct SeasonUpdateData {
    let seasonInfo: SeasonEntity
    let dungeons: [DungeonUpdateData]
}

struct DungeonUpdateData {
    let dungeonInfo: DungeonEntity
    let bossEncounters: [BossEncounterUpdateData]
}

struct BossEncounterUpdateData {
    let encounterInfo: BossEncounterEntity
    let abilities: [AbilityUpdateData]
}

struct AbilityUpdateData {
    let id: UUID
    let name: String
    let type: String
    let targets: String
    let damageProfile: String
    let healerAction: String
    let criticalInsight: String
    let cooldown: TimeInterval?
    let displayOrder: Int
    let isKeyMechanic: Bool
}

// MARK: - Error Handling

enum DungeonDataError: LocalizedError {
    case noActiveSeason
    case dungeonNotFound(UUID)
    case dataCorruption(String)
    case storageError(Error)

    var errorDescription: String? {
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

// MARK: - CLI Interface

protocol DungeonKitCLI {
    /// Validate dungeon data integrity
    /// Usage: dungeonkit validate --format json
    func validate(format: OutputFormat) async -> CLIResult

    /// Import dungeon data from bundle
    /// Usage: dungeonkit import --file season_data.json --validate
    func importData(file: URL, validate: Bool) async -> CLIResult

    /// Export current dungeon data
    /// Usage: dungeonkit export --season active --format json
    func exportData(season: String, format: OutputFormat) async -> CLIResult

    /// Performance diagnostics
    /// Usage: dungeonkit diagnose --performance
    func diagnose(performance: Bool) async -> CLIResult
}

enum OutputFormat: String, CaseIterable {
    case json, human, csv
}

struct CLIResult {
    let success: Bool
    let output: String
    let errorDetails: String?
}

// MARK: - Performance Contracts

protocol DungeonPerformanceOptimization {
    /// Preload frequently accessed dungeons into memory
    func preloadFrequentDungeons() async

    /// Clear cache and free memory for low-memory conditions
    func clearCacheForMemoryPressure() async

    /// Get memory usage statistics for monitoring
    func getMemoryUsage() -> MemoryUsageStats
}

struct MemoryUsageStats {
    let totalCacheSize: Int64      // bytes
    let entityCount: Int
    let lastCacheClean: Date
    let recommendedAction: CacheAction?
}

enum CacheAction {
    case none
    case clearOldEntries
    case fullClear
}