//
//  SeasonDataProvider.swift
//  DungeonKit
//
//  Created by HealerKit on 2025-09-15.
//

#if canImport(CoreData)
import Foundation
import CoreData

/// Implementation of SeasonDataProviding protocol
/// Provides CoreData-backed access to season data with major patch update support
/// Optimized for offline-first functionality and iPad memory constraints
public final class SeasonDataProvider: SeasonDataProviding {

    // MARK: - Properties

    private let managedObjectContext: NSManagedObjectContext
    private let performanceCache: NSCache<NSString, AnyObject>

    // MARK: - Initialization

    /// Initialize with CoreData context
    /// - Parameter context: NSManagedObjectContext for data operations
    public init(managedObjectContext: NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
        self.performanceCache = NSCache<NSString, AnyObject>()

        // Configure cache for memory efficiency
        self.performanceCache.countLimit = 20  // Seasons are relatively few
        self.performanceCache.totalCostLimit = 10 * 1024 * 1024  // 10MB cache limit for seasons
    }

    // MARK: - SeasonDataProviding Implementation

    /// Get currently active season
    public func getActiveSeason() async throws -> SeasonEntity? {
        return try await performWithContext { context in
            // Check cache first
            let cacheKey = NSString(string: "active_season")
            if let cached = self.performanceCache.object(forKey: cacheKey) as? SeasonEntity {
                return cached
            }

            // Fetch from CoreData
            let request: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "Season")
            request.predicate = NSPredicate(format: "isActive == YES")
            request.sortDescriptors = [
                NSSortDescriptor(key: "updatedAt", ascending: false)
            ]
            request.fetchLimit = 1

            let results = try context.fetch(request)
            guard let seasonMO = results.first else {
                return nil
            }

            let season = try self.convertToSeasonEntity(seasonMO)

            // Cache active season for performance
            self.performanceCache.setObject(season as AnyObject, forKey: cacheKey, cost: 2048)

            return season
        }
    }

    /// Fetch all seasons ordered by creation date
    public func fetchAllSeasons() async throws -> [SeasonEntity] {
        return try await performWithContext { context in
            // Check cache first
            let cacheKey = NSString(string: "all_seasons")
            if let cached = self.performanceCache.object(forKey: cacheKey) as? [SeasonEntity] {
                return cached
            }

            // Fetch from CoreData
            let request: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "Season")
            request.sortDescriptors = [
                NSSortDescriptor(key: "createdAt", ascending: false)
            ]

            let results = try context.fetch(request)
            let seasons = try results.map { try self.convertToSeasonEntity($0) }

            // Cache results
            let cost = seasons.count * 2048
            self.performanceCache.setObject(seasons as NSArray, forKey: cacheKey, cost: cost)

            return seasons
        }
    }

    /// Update season data from major patch content bundle
    public func updateSeasonData(_ seasonData: SeasonUpdateData) async throws {
        try await performWithContext { context in
            // We are already on the context's queue via performWithContext.
            // Perform transactional update without performAndWait (avoids iOS 15+ availability).
            do {
                try self.performSeasonUpdate(seasonData, in: context)
                if context.hasChanges {
                    try context.save()
                }

                // Clear cache after successful update
                self.clearSeasonCache()

            } catch {
                context.rollback()
                throw DungeonDataError.storageError(error)
            }
        }
    }

    // MARK: - Private Update Implementation

    /// Perform the actual season update within a transaction
    private func performSeasonUpdate(_ seasonData: SeasonUpdateData, in context: NSManagedObjectContext) throws {
        let newSeason = seasonData.seasonInfo

        // Deactivate current active season if new season should be active
        if newSeason.isActive {
            try deactivateCurrentSeason(in: context)
        }

        // Create or update season entity
        let seasonMO = try createOrUpdateSeasonManagedObject(newSeason, in: context)

        // Update dungeons for this season
        for dungeonUpdate in seasonData.dungeons {
            try createOrUpdateDungeonManagedObject(dungeonUpdate.dungeonInfo, seasonId: newSeason.id, in: context)

            // Update boss encounters for this dungeon
            for encounterUpdate in dungeonUpdate.bossEncounters {
                try createOrUpdateBossEncounterManagedObject(encounterUpdate.encounterInfo, dungeonId: dungeonUpdate.dungeonInfo.id, in: context)

                // Note: Ability updates would be handled by AbilityKit
                // This service focuses on dungeon/encounter structure
            }
        }
    }

    /// Deactivate the currently active season
    private func deactivateCurrentSeason(in context: NSManagedObjectContext) throws {
        let request: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "Season")
        request.predicate = NSPredicate(format: "isActive == YES")

        let activeSeasons = try context.fetch(request)
        for seasonMO in activeSeasons {
            seasonMO.setValue(false, forKey: "isActive")
            seasonMO.setValue(Date(), forKey: "updatedAt")
        }
    }

    /// Create or update season managed object
    private func createOrUpdateSeasonManagedObject(_ season: SeasonEntity, in context: NSManagedObjectContext) throws -> NSManagedObject {
        // Check if season already exists
        let request: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "Season")
        request.predicate = NSPredicate(format: "id == %@", season.id as CVarArg)
        request.fetchLimit = 1

        let existingSeason = try context.fetch(request).first

        let seasonMO = existingSeason ?? NSEntityDescription.insertNewObject(forEntityName: "Season", into: context)

        // Update all properties
        seasonMO.setValue(season.id, forKey: "id")
        seasonMO.setValue(season.name, forKey: "name")
        seasonMO.setValue(season.majorPatchVersion, forKey: "majorPatchVersion")
        seasonMO.setValue(season.isActive, forKey: "isActive")
        seasonMO.setValue(season.dungeonCount, forKey: "dungeonCount")
        seasonMO.setValue(season.createdAt, forKey: "createdAt")
        seasonMO.setValue(season.updatedAt, forKey: "updatedAt")

        return seasonMO
    }

    /// Create or update dungeon managed object
    private func createOrUpdateDungeonManagedObject(_ dungeon: DungeonEntity, seasonId: UUID, in context: NSManagedObjectContext) throws -> NSManagedObject {
        // Check if dungeon already exists
        let request: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "Dungeon")
        request.predicate = NSPredicate(format: "id == %@", dungeon.id as CVarArg)
        request.fetchLimit = 1

        let existingDungeon = try context.fetch(request).first

        let dungeonMO = existingDungeon ?? NSEntityDescription.insertNewObject(forEntityName: "Dungeon", into: context)

        // Update all properties
        dungeonMO.setValue(dungeon.id, forKey: "id")
        dungeonMO.setValue(dungeon.name, forKey: "name")
        dungeonMO.setValue(dungeon.shortName, forKey: "shortName")
        dungeonMO.setValue(dungeon.difficultyLevel, forKey: "difficultyLevel")
        dungeonMO.setValue(dungeon.displayOrder, forKey: "displayOrder")
        dungeonMO.setValue(dungeon.estimatedDuration, forKey: "estimatedDuration")
        dungeonMO.setValue(dungeon.healerNotes, forKey: "healerNotes")
        dungeonMO.setValue(dungeon.bossCount, forKey: "bossCount")
        dungeonMO.setValue(seasonId, forKey: "seasonId")

        return dungeonMO
    }

    /// Create or update boss encounter managed object
    private func createOrUpdateBossEncounterManagedObject(_ encounter: BossEncounterEntity, dungeonId: UUID, in context: NSManagedObjectContext) throws -> NSManagedObject {
        // Check if encounter already exists
        let request: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "BossEncounter")
        request.predicate = NSPredicate(format: "id == %@", encounter.id as CVarArg)
        request.fetchLimit = 1

        let existingEncounter = try context.fetch(request).first

        let encounterMO = existingEncounter ?? NSEntityDescription.insertNewObject(forEntityName: "BossEncounter", into: context)

        // Update all properties
        encounterMO.setValue(encounter.id, forKey: "id")
        encounterMO.setValue(encounter.name, forKey: "name")
        encounterMO.setValue(encounter.encounterOrder, forKey: "encounterOrder")
        encounterMO.setValue(encounter.healerSummary, forKey: "healerSummary")
        encounterMO.setValue(encounter.difficultyRating, forKey: "difficultyRating")
        encounterMO.setValue(encounter.estimatedDuration, forKey: "estimatedDuration")
        encounterMO.setValue(encounter.keyMechanics, forKey: "keyMechanics")
        encounterMO.setValue(encounter.abilityCount, forKey: "abilityCount")
        encounterMO.setValue(dungeonId, forKey: "dungeonId")

        return encounterMO
    }

    // MARK: - Cache Management

    /// Clear season-specific cache entries
    public func clearSeasonCache() {
        performanceCache.removeObject(forKey: "active_season")
        performanceCache.removeObject(forKey: "all_seasons")
    }

    /// Clear all cached data for memory pressure
    public func clearCacheForMemoryPressure() {
        performanceCache.removeAllObjects()
    }

    // MARK: - Private Helpers

    /// Perform operation with proper CoreData context handling
    private func performWithContext<T>(_ operation: @escaping (NSManagedObjectContext) async throws -> T) async throws -> T {
        return try await withCheckedThrowingContinuation { continuation in
            managedObjectContext.perform {
                Task {
                    do {
                        let result = try await operation(self.managedObjectContext)
                        continuation.resume(returning: result)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }
            }
        }
    }

    /// Convert CoreData managed object to SeasonEntity
    private func convertToSeasonEntity(_ managedObject: NSManagedObject) throws -> SeasonEntity {
        guard let id = managedObject.value(forKey: "id") as? UUID,
              let name = managedObject.value(forKey: "name") as? String,
              let majorPatchVersion = managedObject.value(forKey: "majorPatchVersion") as? String,
              let isActive = managedObject.value(forKey: "isActive") as? Bool,
              let dungeonCount = managedObject.value(forKey: "dungeonCount") as? Int,
              let createdAt = managedObject.value(forKey: "createdAt") as? Date,
              let updatedAt = managedObject.value(forKey: "updatedAt") as? Date else {
            throw DungeonDataError.dataCorruption("Invalid season data structure")
        }

        return SeasonEntity(
            id: id,
            name: name,
            majorPatchVersion: majorPatchVersion,
            isActive: isActive,
            dungeonCount: dungeonCount,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}
#endif
