//
//  DungeonDataProvider.swift
//  DungeonKit
//
//  Created by HealerKit on 2025-09-15.
//

#if canImport(CoreData)
import Foundation
import CoreData

/// Implementation of DungeonDataProviding protocol
/// Provides CoreData-backed access to dungeon and boss encounter data
/// Optimized for iPad Pro first-generation memory constraints
public final class DungeonDataProvider: DungeonDataProviding {

    // MARK: - Properties

    private let managedObjectContext: NSManagedObjectContext
    private let performanceCache: NSCache<NSString, AnyObject>
    private let seasonDataProvider: SeasonDataProviding

    // MARK: - Initialization

    /// Initialize with CoreData context and season provider
    /// - Parameters:
    ///   - context: NSManagedObjectContext for data operations
    ///   - seasonProvider: Provider for season data access
    public init(managedObjectContext: NSManagedObjectContext, seasonDataProvider: SeasonDataProviding) {
        self.managedObjectContext = managedObjectContext
        self.seasonDataProvider = seasonDataProvider
        self.performanceCache = NSCache<NSString, AnyObject>()

        // Configure cache for iPad Pro memory constraints
        self.performanceCache.countLimit = 100  // Limit cached entities
        self.performanceCache.totalCostLimit = 50 * 1024 * 1024  // 50MB cache limit
    }

    // MARK: - DungeonDataProviding Implementation

    /// Fetch all dungeons for active season, ordered by display order
    public func fetchDungeonsForActiveSeason() async throws -> [DungeonEntity] {
        return try await performWithContext { context in
            // Get active season first
            guard let activeSeason = try await self.seasonDataProvider.getActiveSeason() else {
                throw DungeonDataError.noActiveSeason
            }

            // Check cache first for performance
            let cacheKey = NSString(string: "dungeons_active_season_\(activeSeason.id.uuidString)")
            if let cached = self.performanceCache.object(forKey: cacheKey) as? [DungeonEntity] {
                return cached
            }

            // Fetch from CoreData
            let request: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "Dungeon")
            request.predicate = NSPredicate(format: "seasonId == %@", activeSeason.id as CVarArg)
            request.sortDescriptors = [NSSortDescriptor(key: "displayOrder", ascending: true)]

            let results = try context.fetch(request)
            let dungeons = try results.map { try self.convertToDungeonEntity($0) }

            // Cache for performance (cost = rough memory estimate)
            let cost = dungeons.count * 1024  // Rough estimate per dungeon
            self.performanceCache.setObject(dungeons as NSArray, forKey: cacheKey, cost: cost)

            return dungeons
        }
    }

    /// Fetch specific dungeon by ID with all boss encounters
    public func fetchDungeon(id: UUID) async throws -> DungeonEntity? {
        return try await performWithContext { context in
            // Check cache first
            let cacheKey = NSString(string: "dungeon_\(id.uuidString)")
            if let cached = self.performanceCache.object(forKey: cacheKey) as? DungeonEntity {
                return cached
            }

            // Fetch from CoreData
            let request: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "Dungeon")
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            request.fetchLimit = 1

            let results = try context.fetch(request)
            guard let dungeonMO = results.first else {
                return nil
            }

            let dungeon = try self.convertToDungeonEntity(dungeonMO)

            // Cache result
            self.performanceCache.setObject(dungeon as AnyObject, forKey: cacheKey, cost: 1024)

            return dungeon
        }
    }

    /// Search dungeons by name or short name (case-insensitive)
    public func searchDungeons(query: String) async throws -> [DungeonEntity] {
        return try await performWithContext { context in
            // Validate search query
            let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedQuery.isEmpty else {
                return []
            }

            // Get active season for filtering
            guard let activeSeason = try await self.seasonDataProvider.getActiveSeason() else {
                throw DungeonDataError.noActiveSeason
            }

            // Check cache first
            let cacheKey = NSString(string: "search_dungeons_\(trimmedQuery.lowercased())_\(activeSeason.id.uuidString)")
            if let cached = self.performanceCache.object(forKey: cacheKey) as? [DungeonEntity] {
                return cached
            }

            // Case-insensitive search on name and shortName
            let request: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "Dungeon")
            request.predicate = NSPredicate(
                format: "seasonId == %@ AND (name CONTAINS[cd] %@ OR shortName CONTAINS[cd] %@)",
                activeSeason.id as CVarArg, trimmedQuery, trimmedQuery
            )
            request.sortDescriptors = [
                NSSortDescriptor(key: "name", ascending: true)
            ]

            let results = try context.fetch(request)
            let dungeons = try results.map { try self.convertToDungeonEntity($0) }

            // Cache results
            let cost = dungeons.count * 1024
            self.performanceCache.setObject(dungeons as NSArray, forKey: cacheKey, cost: cost)

            return dungeons
        }
    }

    /// Fetch boss encounters for dungeon, ordered by encounter order
    public func fetchBossEncounters(for dungeonId: UUID) async throws -> [BossEncounterEntity] {
        return try await performWithContext { context in
            // Check cache first
            let cacheKey = NSString(string: "boss_encounters_\(dungeonId.uuidString)")
            if let cached = self.performanceCache.object(forKey: cacheKey) as? [BossEncounterEntity] {
                return cached
            }

            // Verify dungeon exists
            guard let _ = try await self.fetchDungeon(id: dungeonId) else {
                throw DungeonDataError.dungeonNotFound(dungeonId)
            }

            // Fetch boss encounters from CoreData
            let request: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "BossEncounter")
            request.predicate = NSPredicate(format: "dungeonId == %@", dungeonId as CVarArg)
            request.sortDescriptors = [
                NSSortDescriptor(key: "encounterOrder", ascending: true)
            ]

            let results = try context.fetch(request)
            let encounters = try results.map { try self.convertToBossEncounterEntity($0) }

            // Cache results
            let cost = encounters.count * 2048  // Boss encounters are larger
            self.performanceCache.setObject(encounters as NSArray, forKey: cacheKey, cost: cost)

            return encounters
        }
    }

    // MARK: - Performance Management

    /// Clear cache for memory pressure situations
    public func clearCacheForMemoryPressure() {
        performanceCache.removeAllObjects()
    }

    /// Preload frequently accessed dungeons
    public func preloadFrequentDungeons() async throws {
        // Preload active season dungeons for better performance
        let _ = try await fetchDungeonsForActiveSeason()
    }

    // MARK: - Private Helpers

    /// Perform operation with proper CoreData context handling
    private func performWithContext<T>(_ operation: @escaping (NSManagedObjectContext) async throws -> T) async throws -> T {
        return try await withCheckedThrowingContinuation { continuation in
            managedObjectContext.perform {
                do {
                    Task {
                        let result = try await operation(self.managedObjectContext)
                        continuation.resume(returning: result)
                    }
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    /// Convert CoreData managed object to DungeonEntity
    private func convertToDungeonEntity(_ managedObject: NSManagedObject) throws -> DungeonEntity {
        guard let id = managedObject.value(forKey: "id") as? UUID,
              let name = managedObject.value(forKey: "name") as? String,
              let shortName = managedObject.value(forKey: "shortName") as? String,
              let difficultyLevel = managedObject.value(forKey: "difficultyLevel") as? String,
              let displayOrder = managedObject.value(forKey: "displayOrder") as? Int,
              let estimatedDuration = managedObject.value(forKey: "estimatedDuration") as? TimeInterval,
              let bossCount = managedObject.value(forKey: "bossCount") as? Int else {
            throw DungeonDataError.dataCorruption("Invalid dungeon data structure")
        }

        let healerNotes = managedObject.value(forKey: "healerNotes") as? String

        return DungeonEntity(
            id: id,
            name: name,
            shortName: shortName,
            difficultyLevel: difficultyLevel,
            displayOrder: displayOrder,
            estimatedDuration: estimatedDuration,
            healerNotes: healerNotes,
            bossCount: bossCount
        )
    }

    /// Convert CoreData managed object to BossEncounterEntity
    private func convertToBossEncounterEntity(_ managedObject: NSManagedObject) throws -> BossEncounterEntity {
        guard let id = managedObject.value(forKey: "id") as? UUID,
              let name = managedObject.value(forKey: "name") as? String,
              let encounterOrder = managedObject.value(forKey: "encounterOrder") as? Int,
              let healerSummary = managedObject.value(forKey: "healerSummary") as? String,
              let difficultyRating = managedObject.value(forKey: "difficultyRating") as? Int,
              let estimatedDuration = managedObject.value(forKey: "estimatedDuration") as? TimeInterval,
              let keyMechanics = managedObject.value(forKey: "keyMechanics") as? [String],
              let abilityCount = managedObject.value(forKey: "abilityCount") as? Int else {
            throw DungeonDataError.dataCorruption("Invalid boss encounter data structure")
        }

        return BossEncounterEntity(
            id: id,
            name: name,
            encounterOrder: encounterOrder,
            healerSummary: healerSummary,
            difficultyRating: difficultyRating,
            estimatedDuration: estimatedDuration,
            keyMechanics: keyMechanics,
            abilityCount: abilityCount
        )
    }
}
#endif
