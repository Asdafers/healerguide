//
//  Dungeon.swift
//  DungeonKit
//
//  CoreData entity model for Mythic+ dungeons
//  iOS 13.1+ compatible - First generation iPad Pro support
//

#if canImport(CoreData)
import Foundation
import CoreData

@objc(Dungeon)
public class Dungeon: NSManagedObject {

    // MARK: - Initialization

    convenience init(context: NSManagedObjectContext,
                    name: String,
                    shortName: String,
                    difficultyLevel: DifficultyLevel,
                    displayOrder: Int16,
                    estimatedDuration: TimeInterval = 0,
                    healerNotes: String? = nil) {
        self.init(context: context)

        self.id = UUID()
        self.name = name
        self.shortName = shortName
        self.difficultyLevel = difficultyLevel.rawValue
        self.displayOrder = displayOrder
        self.estimatedDuration = estimatedDuration
        self.healerNotes = healerNotes
    }

    // MARK: - Validation

    public override func validateForInsert() throws {
        try super.validateForInsert()
        try validateDungeonData()
    }

    public override func validateForUpdate() throws {
        try super.validateForUpdate()
        try validateDungeonData()
    }

    private func validateDungeonData() throws {
        // Validate name is not empty
        guard let name = name, !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw DungeonValidationError.emptyDungeonName
        }

        // Validate shortName constraints
        guard let shortName = shortName, !shortName.isEmpty else {
            throw DungeonValidationError.emptyShortName
        }

        if shortName.count > 4 {
            throw DungeonValidationError.shortNameTooLong(shortName)
        }

        // Validate within season constraints
        if let season = season, let context = managedObjectContext {
            // Check unique name within season
            let nameRequest: NSFetchRequest<Dungeon> = Dungeon.fetchRequest()
            nameRequest.predicate = NSPredicate(
                format: "name == %@ AND season == %@ AND id != %@",
                name, season, id ?? UUID()
            )

            let nameCount = try context.count(for: nameRequest)
            if nameCount > 0 {
                throw DungeonValidationError.duplicateNameInSeason(name)
            }

            // Check unique display order within season
            let orderRequest: NSFetchRequest<Dungeon> = Dungeon.fetchRequest()
            orderRequest.predicate = NSPredicate(
                format: "displayOrder == %d AND season == %@ AND id != %@",
                displayOrder, season, id ?? UUID()
            )

            let orderCount = try context.count(for: orderRequest)
            if orderCount > 0 {
                throw DungeonValidationError.duplicateDisplayOrder(Int(displayOrder))
            }
        }

        // Validate estimated duration is non-negative
        if estimatedDuration < 0 {
            throw DungeonValidationError.invalidDuration(estimatedDuration)
        }

        // Validate difficulty level
        guard DifficultyLevel(rawValue: Int(difficultyLevel)) != nil else {
            throw DungeonValidationError.invalidDifficultyLevel(String(difficultyLevel))
        }
    }

    // MARK: - Business Logic

    /// Get difficulty level as enum
    public var difficulty: DifficultyLevel? {
        return DifficultyLevel(rawValue: Int(difficultyLevel))
    }

    /// Set difficulty level from enum
    public func setDifficulty(_ difficulty: DifficultyLevel) {
        self.difficultyLevel = Int16(difficulty.rawValue)
    }

    /// Check if dungeon has minimum required boss encounters (at least 1)
    public var hasMinimumBossEncounters: Bool {
        return (bossEncounters?.count ?? 0) >= 1
    }

    /// Get boss encounters ordered by encounter order for UI
    public var orderedBossEncounters: [BossEncounter] {
        guard let encounterSet = bossEncounters else { return [] }

        return encounterSet.allObjects
            .compactMap { $0 as? BossEncounter }
            .sorted { $0.encounterOrder < $1.encounterOrder }
    }

    /// Get boss count for UI display optimization
    public var bossCount: Int {
        return bossEncounters?.count ?? 0
    }

    /// Get formatted estimated duration for UI display
    public var formattedDuration: String {
        let minutes = Int(estimatedDuration / 60)
        if minutes < 60 {
            return "\(minutes)m"
        } else {
            let hours = minutes / 60
            let remainingMinutes = minutes % 60
            return "\(hours)h \(remainingMinutes)m"
        }
    }

    // MARK: - Fetch Requests

    @objc public class func fetchRequest() -> NSFetchRequest<Dungeon> {
        return NSFetchRequest<Dungeon>(entityName: "Dungeon")
    }

    /// Fetch dungeons for active season, ordered by display order
    public static func fetchDungeonsForActiveSeason(context: NSManagedObjectContext) throws -> [Dungeon] {
        let request: NSFetchRequest<Dungeon> = Dungeon.fetchRequest()
        request.predicate = NSPredicate(format: "season.isActive == YES")
        request.sortDescriptors = [NSSortDescriptor(key: "displayOrder", ascending: true)]

        return try context.fetch(request)
    }

    /// Fetch specific dungeon by ID with all boss encounters
    public static func fetchDungeonWithBosses(id: UUID, context: NSManagedObjectContext) throws -> Dungeon? {
        let request: NSFetchRequest<Dungeon> = Dungeon.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.relationshipKeyPathsForPrefetching = ["bossEncounters"]

        return try context.fetch(request).first
    }

    /// Search dungeons by name or short name (case-insensitive)
    public static func searchDungeons(query: String, context: NSManagedObjectContext) throws -> [Dungeon] {
        let request: NSFetchRequest<Dungeon> = Dungeon.fetchRequest()
        request.predicate = NSPredicate(
            format: "name CONTAINS[cd] %@ OR shortName CONTAINS[cd] %@",
            query, query
        )
        request.sortDescriptors = [
            NSSortDescriptor(key: "name", ascending: true)
        ]

        return try context.fetch(request)
    }

    /// Fetch dungeons for a specific season
    public static func fetchDungeons(for season: Season, context: NSManagedObjectContext) throws -> [Dungeon] {
        let request: NSFetchRequest<Dungeon> = Dungeon.fetchRequest()
        request.predicate = NSPredicate(format: "season == %@", season)
        request.sortDescriptors = [NSSortDescriptor(key: "displayOrder", ascending: true)]

        return try context.fetch(request)
    }
}

// MARK: - Generated accessors for bossEncounters

extension Dungeon {

    @objc(addBossEncountersObject:)
    @NSManaged public func addToBossEncounters(_ value: BossEncounter)

    @objc(removeBossEncountersObject:)
    @NSManaged public func removeFromBossEncounters(_ value: BossEncounter)

    @objc(addBossEncounters:)
    @NSManaged public func addToBossEncounters(_ values: NSSet)

    @objc(removeBossEncounters:)
    @NSManaged public func removeFromBossEncounters(_ values: NSSet)
}

// MARK: - Difficulty Level Enum

public enum DifficultyLevel: Int, CaseIterable {
    case mythicPlus = 0

    public var displayName: String {
        switch self {
        case .mythicPlus:
            return "Mythic+"
        }
    }
}

// MARK: - Validation Errors

public enum DungeonValidationError: LocalizedError {
    case emptyDungeonName
    case emptyShortName
    case shortNameTooLong(String)
    case duplicateNameInSeason(String)
    case duplicateDisplayOrder(Int)
    case invalidDuration(TimeInterval)
    case invalidDifficultyLevel(String)

    public var errorDescription: String? {
        switch self {
        case .emptyDungeonName:
            return "Dungeon name cannot be empty"
        case .emptyShortName:
            return "Short name cannot be empty"
        case .shortNameTooLong(let shortName):
            return "Short name '\(shortName)' exceeds maximum length of 4 characters"
        case .duplicateNameInSeason(let name):
            return "Dungeon name '\(name)' already exists in this season"
        case .duplicateDisplayOrder(let order):
            return "Display order \(order) already exists in this season"
        case .invalidDuration(let duration):
            return "Invalid duration: \(duration). Duration must be non-negative"
        case .invalidDifficultyLevel(let level):
            return "Invalid difficulty level: \(level)"
        }
    }
}

// MARK: - Core Data Properties

extension Dungeon {

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var shortName: String?
    @NSManaged public var difficultyLevel: Int16
    @NSManaged public var displayOrder: Int16
    @NSManaged public var estimatedDuration: Double
    @NSManaged public var healerNotes: String?
    @NSManaged public var bossEncounters: NSSet?
    @NSManaged public var season: Season?
}

// MARK: - Identifiable Conformance

extension Dungeon: Identifiable {
    // UUID id property already defined above
}#endif
#endif
