//
//  BossEncounter.swift
//  DungeonKit
//
//  CoreData entity model for Mythic+ boss encounters
//  iOS 13.1+ compatible - First generation iPad Pro support
//

#if canImport(CoreData)
import Foundation
import CoreData

// Forward declaration to avoid circular imports
@objc(BossAbility)
class BossAbility: NSManagedObject {}

@objc(BossEncounter)
public class BossEncounter: NSManagedObject {

    // MARK: - Initialization

    convenience init(context: NSManagedObjectContext,
                    name: String,
                    encounterOrder: Int16,
                    healerSummary: String,
                    difficultyRating: HealerDifficulty,
                    estimatedDuration: TimeInterval = 0,
                    keyMechanics: [String] = []) {
        self.init(context: context)

        self.id = UUID()
        self.name = name
        self.encounterOrder = encounterOrder
        self.healerSummary = healerSummary
        self.difficultyRating = Int16(difficultyRating.rawValue)
        self.estimatedDuration = estimatedDuration
        self.setKeyMechanics(keyMechanics)
    }

    // MARK: - Validation

    public override func validateForInsert() throws {
        try super.validateForInsert()
        try validateBossEncounterData()
    }

    public override func validateForUpdate() throws {
        try super.validateForUpdate()
        try validateBossEncounterData()
    }

    private func validateBossEncounterData() throws {
        // Validate name is not empty
        guard let name = name, !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw BossEncounterValidationError.emptyBossName
        }

        // Validate healer summary constraints
        guard let summary = healerSummary, !summary.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw BossEncounterValidationError.emptyHealerSummary
        }

        if summary.count > 500 {
            throw BossEncounterValidationError.healerSummaryTooLong(summary.count)
        }

        // Validate within dungeon constraints
        if let dungeon = dungeon, let context = managedObjectContext {
            // Check unique name within dungeon
            let nameRequest: NSFetchRequest<BossEncounter> = BossEncounter.fetchRequest()
            nameRequest.predicate = NSPredicate(
                format: "name == %@ AND dungeon == %@ AND id != %@",
                name, dungeon, id ?? UUID()
            )

            let nameCount = try context.count(for: nameRequest)
            if nameCount > 0 {
                throw BossEncounterValidationError.duplicateNameInDungeon(name)
            }

            // Check unique encounter order within dungeon
            let orderRequest: NSFetchRequest<BossEncounter> = BossEncounter.fetchRequest()
            orderRequest.predicate = NSPredicate(
                format: "encounterOrder == %d AND dungeon == %@ AND id != %@",
                encounterOrder, dungeon, id ?? UUID()
            )

            let orderCount = try context.count(for: orderRequest)
            if orderCount > 0 {
                throw BossEncounterValidationError.duplicateEncounterOrder(Int(encounterOrder))
            }
        }

        // Validate estimated duration is non-negative
        if estimatedDuration < 0 {
            throw BossEncounterValidationError.invalidDuration(estimatedDuration)
        }

        // Validate difficulty rating
        guard HealerDifficulty(rawValue: Int(difficultyRating)) != nil else {
            throw BossEncounterValidationError.invalidDifficultyRating(Int(difficultyRating))
        }

        // Validate key mechanics constraints
        let mechanics = getKeyMechanics()
        if mechanics.count > 3 {
            throw BossEncounterValidationError.tooManyKeyMechanics(mechanics.count)
        }
    }

    // MARK: - Business Logic

    /// Get difficulty rating as enum
    public var difficulty: HealerDifficulty? {
        return HealerDifficulty(rawValue: Int(difficultyRating))
    }

    /// Set difficulty rating from enum
    public func setDifficulty(_ difficulty: HealerDifficulty) {
        self.difficultyRating = Int16(difficulty.rawValue)
    }

    /// Get key mechanics array from stored string
    public func getKeyMechanics() -> [String] {
        guard let mechanicsString = keyMechanics else { return [] }

        if mechanicsString.isEmpty {
            return []
        }

        return mechanicsString.components(separatedBy: "|")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    /// Set key mechanics from array (max 3 items)
    public func setKeyMechanics(_ mechanics: [String]) {
        let trimmedMechanics = mechanics
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .prefix(3) // Enforce max 3 mechanics

        self.keyMechanics = Array(trimmedMechanics).joined(separator: "|")
    }

    /// Add a key mechanic (if under limit)
    public func addKeyMechanic(_ mechanic: String) throws {
        let currentMechanics = getKeyMechanics()

        if currentMechanics.count >= 3 {
            throw BossEncounterValidationError.tooManyKeyMechanics(currentMechanics.count)
        }

        let trimmedMechanic = mechanic.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedMechanic.isEmpty else {
            throw BossEncounterValidationError.emptyKeyMechanic
        }

        var updatedMechanics = currentMechanics
        updatedMechanics.append(trimmedMechanic)
        setKeyMechanics(updatedMechanics)
    }

    /// Remove a key mechanic
    public func removeKeyMechanic(_ mechanic: String) {
        let currentMechanics = getKeyMechanics()
        let updatedMechanics = currentMechanics.filter { $0 != mechanic }
        setKeyMechanics(updatedMechanics)
    }

    /// Get abilities ordered by display order for UI
    public var orderedAbilities: [BossAbility] {
        guard let abilitySet = abilities else { return [] }

        return abilitySet.allObjects
            .compactMap { $0 as? BossAbility }
            .sorted { $0.displayOrder < $1.displayOrder }
    }

    /// Get ability count for UI display optimization
    public var abilityCount: Int {
        return abilities?.count ?? 0
    }

    /// Get formatted estimated duration for UI display
    public var formattedDuration: String {
        let minutes = Int(estimatedDuration / 60)
        let seconds = Int(estimatedDuration.truncatingRemainder(dividingBy: 60))

        if minutes > 0 {
            return "\(minutes):\(String(format: "%02d", seconds))"
        } else {
            return "\(seconds)s"
        }
    }

    /// Get difficulty display info
    public var difficultyDisplayInfo: (name: String, color: String) {
        guard let difficulty = self.difficulty else {
            return (name: "Unknown", color: "gray")
        }

        return difficulty.displayInfo
    }

    // MARK: - Fetch Requests

    @objc public class func fetchRequest() -> NSFetchRequest<BossEncounter> {
        return NSFetchRequest<BossEncounter>(entityName: "BossEncounter")
    }

    /// Fetch boss encounters for dungeon, ordered by encounter order
    public static func fetchBossEncounters(for dungeon: Dungeon, context: NSManagedObjectContext) throws -> [BossEncounter] {
        let request: NSFetchRequest<BossEncounter> = BossEncounter.fetchRequest()
        request.predicate = NSPredicate(format: "dungeon == %@", dungeon)
        request.sortDescriptors = [NSSortDescriptor(key: "encounterOrder", ascending: true)]

        return try context.fetch(request)
    }

    /// Fetch boss encounters for dungeon ID, ordered by encounter order
    public static func fetchBossEncounters(for dungeonId: UUID, context: NSManagedObjectContext) throws -> [BossEncounter] {
        let request: NSFetchRequest<BossEncounter> = BossEncounter.fetchRequest()
        request.predicate = NSPredicate(format: "dungeon.id == %@", dungeonId as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(key: "encounterOrder", ascending: true)]

        return try context.fetch(request)
    }

    /// Search boss encounters by name across all dungeons
    public static func searchBossEncounters(query: String, context: NSManagedObjectContext) throws -> [BossEncounter] {
        let request: NSFetchRequest<BossEncounter> = BossEncounter.fetchRequest()
        request.predicate = NSPredicate(format: "name CONTAINS[cd] %@", query)
        request.sortDescriptors = [
            NSSortDescriptor(key: "name", ascending: true)
        ]

        return try context.fetch(request)
    }

    /// Fetch boss encounters by difficulty rating
    public static func fetchBossEncounters(difficulty: HealerDifficulty, context: NSManagedObjectContext) throws -> [BossEncounter] {
        let request: NSFetchRequest<BossEncounter> = BossEncounter.fetchRequest()
        request.predicate = NSPredicate(format: "difficultyRating == %d", difficulty.rawValue)
        request.sortDescriptors = [
            NSSortDescriptor(key: "dungeon.displayOrder", ascending: true),
            NSSortDescriptor(key: "encounterOrder", ascending: true)
        ]

        return try context.fetch(request)
    }
}

// MARK: - Generated accessors for abilities

extension BossEncounter {

    @objc(addAbilitiesObject:)
    @NSManaged public func addToAbilities(_ value: BossAbility)

    @objc(removeAbilitiesObject:)
    @NSManaged public func removeFromAbilities(_ value: BossAbility)

    @objc(addAbilities:)
    @NSManaged public func addToAbilities(_ values: NSSet)

    @objc(removeAbilities:)
    @NSManaged public func removeFromAbilities(_ values: NSSet)
}

// MARK: - Healer Difficulty Enum

public enum HealerDifficulty: Int, CaseIterable {
    case easy = 1
    case moderate = 2
    case hard = 3
    case extreme = 4

    public var displayName: String {
        switch self {
        case .easy:
            return "Easy"
        case .moderate:
            return "Moderate"
        case .hard:
            return "Hard"
        case .extreme:
            return "Extreme"
        }
    }

    public var displayInfo: (name: String, color: String) {
        switch self {
        case .easy:
            return (name: "Easy", color: "green")
        case .moderate:
            return (name: "Moderate", color: "yellow")
        case .hard:
            return (name: "Hard", color: "orange")
        case .extreme:
            return (name: "Extreme", color: "red")
        }
    }
}

// MARK: - Validation Errors

public enum BossEncounterValidationError: LocalizedError {
    case emptyBossName
    case emptyHealerSummary
    case healerSummaryTooLong(Int)
    case duplicateNameInDungeon(String)
    case duplicateEncounterOrder(Int)
    case invalidDuration(TimeInterval)
    case invalidDifficultyRating(Int)
    case tooManyKeyMechanics(Int)
    case emptyKeyMechanic

    public var errorDescription: String? {
        switch self {
        case .emptyBossName:
            return "Boss encounter name cannot be empty"
        case .emptyHealerSummary:
            return "Healer summary cannot be empty"
        case .healerSummaryTooLong(let length):
            return "Healer summary is too long (\(length) characters). Maximum 500 characters allowed"
        case .duplicateNameInDungeon(let name):
            return "Boss encounter name '\(name)' already exists in this dungeon"
        case .duplicateEncounterOrder(let order):
            return "Encounter order \(order) already exists in this dungeon"
        case .invalidDuration(let duration):
            return "Invalid duration: \(duration). Duration must be non-negative"
        case .invalidDifficultyRating(let rating):
            return "Invalid difficulty rating: \(rating). Must be 1-4"
        case .tooManyKeyMechanics(let count):
            return "Too many key mechanics (\(count)). Maximum 3 allowed for quick reference"
        case .emptyKeyMechanic:
            return "Key mechanic cannot be empty"
        }
    }
}

// MARK: - Core Data Properties

extension BossEncounter {

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var encounterOrder: Int16
    @NSManaged public var healerSummary: String?
    @NSManaged public var difficultyRating: Int16
    @NSManaged public var estimatedDuration: Double
    @NSManaged public var keyMechanics: String?
    @NSManaged public var abilities: NSSet?
    @NSManaged public var dungeon: Dungeon?
}

// MARK: - Identifiable Conformance

extension BossEncounter: Identifiable {
    // UUID id property already defined above
}#endif
#endif
