//
//  BossAbility.swift
//  AbilityKit
//
//  CoreData entity model for boss abilities with healer-specific information
//  iOS 13.1+ compatible - First generation iPad Pro support
//

import Foundation
import CoreData
import HealerKitCore

// Forward declaration to avoid circular imports
@objc(BossEncounter)
class BossEncounter: NSManagedObject {}

@objc(BossAbility)
public class BossAbility: NSManagedObject {

    // MARK: - Initialization

    convenience init(context: NSManagedObjectContext,
                    name: String,
                    type: AbilityType,
                    targets: TargetType,
                    damageProfile: DamageProfile,
                    healerAction: String,
                    criticalInsight: String,
                    cooldown: TimeInterval? = nil,
                    displayOrder: Int16,
                    isKeyMechanic: Bool = false) {
        self.init(context: context)

        self.id = UUID()
        self.name = name
        self.type = type.rawValue
        self.targets = targets.rawValue
        self.damageProfile = damageProfile.rawValue
        self.healerAction = healerAction
        self.criticalInsight = criticalInsight
        self.cooldown = cooldown ?? 0.0
        self.displayOrder = displayOrder
        self.isKeyMechanic = isKeyMechanic
    }

    // MARK: - Validation

    public override func validateForInsert() throws {
        try super.validateForInsert()
        try validateBossAbilityData()
    }

    public override func validateForUpdate() throws {
        try super.validateForUpdate()
        try validateBossAbilityData()
    }

    private func validateBossAbilityData() throws {
        // Validate name is not empty
        guard let name = name, !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw BossAbilityValidationError.emptyAbilityName
        }

        // Validate healer action constraints
        guard let action = healerAction, !action.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw BossAbilityValidationError.emptyHealerAction
        }

        if action.count > 200 {
            throw BossAbilityValidationError.healerActionTooLong(action.count)
        }

        // Validate critical insight constraints
        guard let insight = criticalInsight, !insight.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw BossAbilityValidationError.emptyCriticalInsight
        }

        if insight.count > 150 {
            throw BossAbilityValidationError.criticalInsightTooLong(insight.count)
        }

        // Validate within boss encounter constraints
        if let bossEncounter = bossEncounter, let context = managedObjectContext {
            // Check unique name within boss encounter
            let nameRequest: NSFetchRequest<BossAbility> = BossAbility.fetchRequest()
            nameRequest.predicate = NSPredicate(
                format: "name == %@ AND bossEncounter == %@ AND id != %@",
                name, bossEncounter, id ?? UUID()
            )

            let nameCount = try context.count(for: nameRequest)
            if nameCount > 0 {
                throw BossAbilityValidationError.duplicateNameInEncounter(name)
            }

            // Check unique display order within boss encounter
            let orderRequest: NSFetchRequest<BossAbility> = BossAbility.fetchRequest()
            orderRequest.predicate = NSPredicate(
                format: "displayOrder == %d AND bossEncounter == %@ AND id != %@",
                displayOrder, bossEncounter, id ?? UUID()
            )

            let orderCount = try context.count(for: orderRequest)
            if orderCount > 0 {
                throw BossAbilityValidationError.duplicateDisplayOrder(Int(displayOrder))
            }
        }

        // Validate cooldown is positive if specified
        if cooldown < 0 {
            throw BossAbilityValidationError.invalidCooldown(cooldown)
        }

        // Validate enum values
        guard let typeString = type, AbilityType(rawValue: typeString) != nil else {
            throw BossAbilityValidationError.invalidAbilityType(type ?? "nil")
        }

        guard let targetString = targets, TargetType(rawValue: targetString) != nil else {
            throw BossAbilityValidationError.invalidTargetType(targets ?? "nil")
        }

        guard let profileString = damageProfile, DamageProfile(rawValue: profileString) != nil else {
            throw BossAbilityValidationError.invalidDamageProfile(damageProfile ?? "nil")
        }
    }

    // MARK: - Business Logic

    /// Get ability type as enum
    public var abilityType: AbilityType? {
        guard let typeString = type else { return nil }
        return AbilityType(rawValue: typeString)
    }

    /// Set ability type from enum
    public func setAbilityType(_ abilityType: AbilityType) {
        self.type = abilityType.rawValue
    }

    /// Get target type as enum
    public var targetType: TargetType? {
        guard let targetString = targets else { return nil }
        return TargetType(rawValue: targetString)
    }

    /// Set target type from enum
    public func setTargetType(_ targetType: TargetType) {
        self.targets = targetType.rawValue
    }

    /// Get damage profile as enum
    public var damage: DamageProfile? {
        guard let profileString = damageProfile else { return nil }
        return DamageProfile(rawValue: profileString)
    }

    /// Set damage profile from enum
    public func setDamageProfile(_ profile: DamageProfile) {
        self.damageProfile = profile.rawValue
    }

    /// Get formatted cooldown for UI display
    public var formattedCooldown: String? {
        guard cooldown > 0 else { return nil }

        let minutes = Int(cooldown / 60)
        let seconds = Int(cooldown.truncatingRemainder(dividingBy: 60))

        if minutes > 0 {
            return "\(minutes):\(String(format: "%02d", seconds))"
        } else {
            return "\(seconds)s"
        }
    }

    /// Get color scheme for UI display based on damage profile
    public var colorScheme: AbilityColorScheme? {
        guard let damage = self.damage else { return nil }
        return damage.colorScheme
    }

    /// Get priority for sorting (higher number = higher priority)
    public var priority: Int {
        guard let damage = self.damage else { return 0 }
        return damage.priority + (isKeyMechanic ? 10 : 0)  // Boost key mechanics
    }

    /// Get display hint for UI rendering
    public var displayHint: UIDisplayHint {
        guard let damage = self.damage else { return .standard }

        if isKeyMechanic {
            return .highlight
        }

        switch damage {
        case .critical:
            return .emphasize
        case .high:
            return .standard
        case .moderate:
            return .standard
        case .mechanic:
            return .muted
        }
    }

    /// Check if this ability requires immediate healer attention
    public var requiresImmediateAttention: Bool {
        guard let damage = self.damage else { return false }
        return damage == .critical || (damage == .high && isKeyMechanic)
    }

    // MARK: - Fetch Requests

    @objc public class func fetchRequest() -> NSFetchRequest<BossAbility> {
        return NSFetchRequest<BossAbility>(entityName: "BossAbility")
    }

    /// Fetch all abilities for a boss encounter, ordered by display priority
    public static func fetchAbilities(for bossEncounterId: UUID, context: NSManagedObjectContext) throws -> [BossAbility] {
        let request: NSFetchRequest<BossAbility> = BossAbility.fetchRequest()
        request.predicate = NSPredicate(format: "bossEncounter.id == %@", bossEncounterId as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(key: "displayOrder", ascending: true)]

        return try context.fetch(request)
    }

    /// Search abilities by name across all encounters
    public static func searchAbilities(query: String, context: NSManagedObjectContext) throws -> [BossAbility] {
        let request: NSFetchRequest<BossAbility> = BossAbility.fetchRequest()
        request.predicate = NSPredicate(format: "name CONTAINS[cd] %@", query)
        request.sortDescriptors = [
            NSSortDescriptor(key: "name", ascending: true)
        ]

        return try context.fetch(request)
    }

    /// Fetch abilities filtered by damage profile
    public static func fetchAbilities(for bossEncounterId: UUID, damageProfile: DamageProfile, context: NSManagedObjectContext) throws -> [BossAbility] {
        let request: NSFetchRequest<BossAbility> = BossAbility.fetchRequest()
        request.predicate = NSPredicate(
            format: "bossEncounter.id == %@ AND damageProfile == %@",
            bossEncounterId as CVarArg, damageProfile.rawValue
        )
        request.sortDescriptors = [NSSortDescriptor(key: "displayOrder", ascending: true)]

        return try context.fetch(request)
    }

    /// Fetch only key mechanics for quick reference display
    public static func fetchKeyMechanics(for bossEncounterId: UUID, context: NSManagedObjectContext) throws -> [BossAbility] {
        let request: NSFetchRequest<BossAbility> = BossAbility.fetchRequest()
        request.predicate = NSPredicate(
            format: "bossEncounter.id == %@ AND isKeyMechanic == YES",
            bossEncounterId as CVarArg
        )
        request.sortDescriptors = [NSSortDescriptor(key: "displayOrder", ascending: true)]

        return try context.fetch(request)
    }

    /// Fetch abilities requiring immediate attention (Critical/High + Key)
    public static func fetchCriticalAbilities(for bossEncounterId: UUID, context: NSManagedObjectContext) throws -> [BossAbility] {
        let request: NSFetchRequest<BossAbility> = BossAbility.fetchRequest()
        request.predicate = NSPredicate(
            format: "bossEncounter.id == %@ AND (damageProfile == %@ OR (damageProfile == %@ AND isKeyMechanic == YES))",
            bossEncounterId as CVarArg, DamageProfile.critical.rawValue, DamageProfile.high.rawValue
        )
        request.sortDescriptors = [NSSortDescriptor(key: "displayOrder", ascending: true)]

        return try context.fetch(request)
    }

    /// Fetch abilities ordered by priority for healer attention
    public static func fetchPrioritizedAbilities(for bossEncounterId: UUID, context: NSManagedObjectContext) throws -> [BossAbility] {
        let abilities = try fetchAbilities(for: bossEncounterId, context: context)

        return abilities.sorted { ability1, ability2 in
            // First sort by priority (calculated from damage profile + key mechanic)
            if ability1.priority != ability2.priority {
                return ability1.priority > ability2.priority
            }
            // Then by display order as tiebreaker
            return ability1.displayOrder < ability2.displayOrder
        }
    }
}

// MARK: - Enums and Supporting Types are now provided by HealerKitCore
// See SharedTypes.swift for AbilityType, TargetType, DamageProfile, UIDisplayHint, and AbilityColorScheme

// MARK: - Validation Errors

public enum BossAbilityValidationError: LocalizedError {
    case emptyAbilityName
    case emptyHealerAction
    case healerActionTooLong(Int)
    case emptyCriticalInsight
    case criticalInsightTooLong(Int)
    case duplicateNameInEncounter(String)
    case duplicateDisplayOrder(Int)
    case invalidCooldown(Double)
    case invalidAbilityType(String)
    case invalidTargetType(String)
    case invalidDamageProfile(String)

    public var errorDescription: String? {
        switch self {
        case .emptyAbilityName:
            return "Ability name cannot be empty"
        case .emptyHealerAction:
            return "Healer action cannot be empty"
        case .healerActionTooLong(let length):
            return "Healer action is too long (\(length) characters). Maximum 200 characters allowed"
        case .emptyCriticalInsight:
            return "Critical insight cannot be empty"
        case .criticalInsightTooLong(let length):
            return "Critical insight is too long (\(length) characters). Maximum 150 characters allowed"
        case .duplicateNameInEncounter(let name):
            return "Ability name '\(name)' already exists in this boss encounter"
        case .duplicateDisplayOrder(let order):
            return "Display order \(order) already exists in this boss encounter"
        case .invalidCooldown(let cooldown):
            return "Invalid cooldown: \(cooldown). Cooldown must be non-negative"
        case .invalidAbilityType(let type):
            return "Invalid ability type: \(type)"
        case .invalidTargetType(let type):
            return "Invalid target type: \(type)"
        case .invalidDamageProfile(let profile):
            return "Invalid damage profile: \(profile)"
        }
    }
}

// MARK: - Core Data Properties

extension BossAbility {

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var type: String?
    @NSManaged public var targets: String?
    @NSManaged public var damageProfile: String?
    @NSManaged public var healerAction: String?
    @NSManaged public var criticalInsight: String?
    @NSManaged public var cooldown: Double
    @NSManaged public var displayOrder: Int16
    @NSManaged public var isKeyMechanic: Bool
    @NSManaged public var bossEncounter: BossEncounter?
}

// MARK: - Identifiable Conformance

extension BossAbility: Identifiable {
    // UUID id property already defined above
}