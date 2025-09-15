//
//  Season.swift
//  DungeonKit
//
//  CoreData entity model for Mythic+ seasons
//  iOS 13.1+ compatible - First generation iPad Pro support
//

#if canImport(CoreData)
import Foundation
import CoreData

@objc(Season)
public class Season: NSManagedObject {

    // MARK: - Initialization

    convenience init(context: NSManagedObjectContext,
                    name: String,
                    majorPatchVersion: String,
                    isActive: Bool = false) {
        self.init(context: context)

        self.id = UUID()
        self.name = name
        self.majorPatchVersion = majorPatchVersion
        self.isActive = isActive
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    // MARK: - Validation

    public override func validateForInsert() throws {
        try super.validateForInsert()
        try validateSeasonData()
    }

    public override func validateForUpdate() throws {
        try super.validateForUpdate()
        try validateSeasonData()

        // Update timestamp on modification
        self.updatedAt = Date()
    }

    private func validateSeasonData() throws {
        // Validate name is not empty
        guard let name = name, !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw ValidationError.emptySeasonName
        }

        // Validate unique name constraint
        if let context = managedObjectContext {
            let request: NSFetchRequest<Season> = Season.fetchRequest()
            request.predicate = NSPredicate(format: "name == %@ AND id != %@", name, id ?? UUID())

            let count = try context.count(for: request)
            if count > 0 {
                throw ValidationError.duplicateSeasonName(name)
            }
        }

        // Validate patch version format (X.Y)
        guard let patchVersion = majorPatchVersion else {
            throw ValidationError.emptyPatchVersion
        }

        let versionComponents = patchVersion.components(separatedBy: ".")
        guard versionComponents.count == 2,
              versionComponents.allSatisfy({ Int($0) != nil }) else {
            throw ValidationError.invalidPatchVersionFormat(patchVersion)
        }

        // Validate only one active season constraint
        if isActive, let context = managedObjectContext {
            let request: NSFetchRequest<Season> = Season.fetchRequest()
            request.predicate = NSPredicate(format: "isActive == YES AND id != %@", id ?? UUID())

            let activeSeasonsCount = try context.count(for: request)
            if activeSeasonsCount > 0 {
                throw ValidationError.multipleActiveSeasons
            }
        }
    }

    // MARK: - Business Logic

    /// Activates this season and deactivates all others
    public func activate() throws {
        guard let context = managedObjectContext else {
            throw ValidationError.noManagedObjectContext
        }

        // Deactivate all other seasons
        let request: NSFetchRequest<Season> = Season.fetchRequest()
        request.predicate = NSPredicate(format: "isActive == YES AND id != %@", id ?? UUID())

        let activeSeasons = try context.fetch(request)
        for season in activeSeasons {
            season.isActive = false
        }

        // Activate this season
        self.isActive = true
        self.updatedAt = Date()
    }

    /// Check if season has minimum required dungeons (at least 1)
    public var hasMinimumDungeons: Bool {
        return (dungeons?.count ?? 0) >= 1
    }

    /// Get dungeons ordered by display order for UI
    public var orderedDungeons: [Dungeon] {
        guard let dungeonSet = dungeons else { return [] }

        return dungeonSet.allObjects
            .compactMap { $0 as? Dungeon }
            .sorted { $0.displayOrder < $1.displayOrder }
    }

    // MARK: - Fetch Requests

    @objc public class func fetchRequest() -> NSFetchRequest<Season> {
        return NSFetchRequest<Season>(entityName: "Season")
    }

    /// Fetch the currently active season
    public static func fetchActiveSeason(context: NSManagedObjectContext) throws -> Season? {
        let request: NSFetchRequest<Season> = Season.fetchRequest()
        request.predicate = NSPredicate(format: "isActive == YES")
        request.fetchLimit = 1

        return try context.fetch(request).first
    }

    /// Fetch all seasons ordered by creation date (newest first)
    public static func fetchAllSeasons(context: NSManagedObjectContext) throws -> [Season] {
        let request: NSFetchRequest<Season> = Season.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]

        return try context.fetch(request)
    }
}

// MARK: - Generated accessors for dungeons

extension Season {

    @objc(addDungeonsObject:)
    @NSManaged public func addToDungeons(_ value: Dungeon)

    @objc(removeDungeonsObject:)
    @NSManaged public func removeFromDungeons(_ value: Dungeon)

    @objc(addDungeons:)
    @NSManaged public func addToDungeons(_ values: NSSet)

    @objc(removeDungeons:)
    @NSManaged public func removeFromDungeons(_ values: NSSet)
}

// MARK: - Validation Errors

public enum ValidationError: LocalizedError {
    case emptySeasonName
    case duplicateSeasonName(String)
    case emptyPatchVersion
    case invalidPatchVersionFormat(String)
    case multipleActiveSeasons
    case noManagedObjectContext

    public var errorDescription: String? {
        switch self {
        case .emptySeasonName:
            return "Season name cannot be empty"
        case .duplicateSeasonName(let name):
            return "Season name '\(name)' already exists"
        case .emptyPatchVersion:
            return "Major patch version cannot be empty"
        case .invalidPatchVersionFormat(let version):
            return "Invalid patch version format '\(version)'. Expected format: X.Y (e.g., '11.2')"
        case .multipleActiveSeasons:
            return "Only one season can be active at a time"
        case .noManagedObjectContext:
            return "No managed object context available"
        }
    }
}

// MARK: - Core Data Properties

extension Season {

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var majorPatchVersion: String?
    @NSManaged public var isActive: Bool
    @NSManaged public var createdAt: Date?
    @NSManaged public var updatedAt: Date?
    @NSManaged public var dungeons: NSSet?
}

// MARK: - Identifiable Conformance

extension Season: Identifiable {
    // UUID id property already defined above
}#endif
#endif
