//
//  AbilityKit.swift
//  AbilityKit
//
//  Created by HealerKit on 2025-09-14.
//

import Foundation
import DungeonKit
import HealerKitCore

// MARK: - Public Interface Protocols

public protocol AbilityDataProviding {
    /// Fetch all abilities for a boss encounter, ordered by display priority
    func fetchAbilities(for bossEncounterId: UUID) async throws -> [AbilityEntity]

    /// Search abilities by name across all encounters
    func searchAbilities(query: String) async throws -> [AbilityEntity]

    /// Fetch abilities filtered by damage profile (for color-coded display)
    func fetchAbilities(for bossEncounterId: UUID, damageProfile: DamageProfile) async throws -> [AbilityEntity]

    /// Fetch only key mechanics for quick reference display
    func fetchKeyMechanics(for bossEncounterId: UUID) async throws -> [AbilityEntity]
}

public protocol AbilityClassificationService {
    /// Classify ability based on healer impact and urgency
    func classifyAbility(_ ability: AbilityEntity) -> AbilityClassification

    /// Get recommended healer actions for damage profile
    func getRecommendedActions(for damageProfile: DamageProfile) -> [HealerAction]

    /// Validate ability data for healer relevance
    func validateHealerRelevance(_ ability: AbilityEntity) -> ValidationResult
}

public protocol DamageProfileAnalyzer {
    /// Analyze damage patterns for encounter planning
    func analyzeDamageProfile(for bossEncounterId: UUID) async throws -> DamageAnalysis

    /// Get color coding for UI display based on damage profile
    func getUIColorScheme(for damageProfile: DamageProfile) -> AbilityColorScheme

    /// Prioritize abilities for healer attention during encounter
    func prioritizeForHealer(_ abilities: [AbilityEntity]) -> [PrioritizedAbility]
}

// MARK: - Public Data Models

public struct AbilityEntity {
    public let id: UUID
    public let name: String
    public let type: AbilityType
    public let bossEncounterId: UUID
    public let targets: TargetType
    public let damageProfile: DamageProfile
    public let healerAction: String
    public let criticalInsight: String
    public let cooldown: TimeInterval?
    public let displayOrder: Int
    public let isKeyMechanic: Bool

    public init(id: UUID, name: String, type: AbilityType, bossEncounterId: UUID, targets: TargetType, damageProfile: DamageProfile, healerAction: String, criticalInsight: String, cooldown: TimeInterval?, displayOrder: Int, isKeyMechanic: Bool) {
        self.id = id
        self.name = name
        self.type = type
        self.bossEncounterId = bossEncounterId
        self.targets = targets
        self.damageProfile = damageProfile
        self.healerAction = healerAction
        self.criticalInsight = criticalInsight
        self.cooldown = cooldown
        self.displayOrder = displayOrder
        self.isKeyMechanic = isKeyMechanic
    }
}

// MARK: - Shared Types
// AbilityType, TargetType, and DamageProfile are now provided by HealerKitCore

public struct AbilityClassification {
    public let urgency: UrgencyLevel
    public let complexity: ComplexityLevel
    public let healerImpact: ImpactLevel
    public let recommendedPreparation: String

    public init(urgency: UrgencyLevel, complexity: ComplexityLevel, healerImpact: ImpactLevel, recommendedPreparation: String) {
        self.urgency = urgency
        self.complexity = complexity
        self.healerImpact = healerImpact
        self.recommendedPreparation = recommendedPreparation
    }
}

public enum UrgencyLevel: Int, CaseIterable {
    case immediate = 4      // Must react within 1-2 seconds
    case high = 3          // React within 3-5 seconds
    case moderate = 2      // Can plan response (5-10 seconds)
    case low = 1           // Passive monitoring
}

public enum ComplexityLevel: Int, CaseIterable {
    case simple = 1        // Single button press/target
    case moderate = 2      // Requires positioning + healing
    case complex = 3       // Multi-step response required
    case extreme = 4       // Coordination with team required
}

public enum ImpactLevel: Int, CaseIterable {
    case critical = 4      // Encounter-ending if mishandled
    case high = 3          // Significant damage/death risk
    case moderate = 2      // Manageable but notable impact
    case low = 1           // Minor impact on encounter
}

public struct HealerAction {
    public let actionType: HealerActionType
    public let timing: ActionTiming
    public let description: String
    public let keyBindSuggestion: String?

    public init(actionType: HealerActionType, timing: ActionTiming, description: String, keyBindSuggestion: String?) {
        self.actionType = actionType
        self.timing = timing
        self.description = description
        self.keyBindSuggestion = keyBindSuggestion
    }
}

public enum HealerActionType: String, CaseIterable {
    case preHeal = "pre_heal"
    case reactiveHeal = "reactive_heal"
    case cooldownUse = "cooldown_use"
    case positioning = "positioning"
    case dispel = "dispel"
    case interrupt = "interrupt"
}

public enum ActionTiming: String, CaseIterable {
    case immediate = "immediate"        // <1 second
    case fast = "fast"                 // 1-3 seconds
    case planned = "planned"           // 3+ seconds advance notice
}

public struct DamageAnalysis {
    public let bossEncounterId: UUID
    public let totalAbilities: Int
    public let damageProfileDistribution: [DamageProfile: Int]
    public let predictedHealingLoad: HealingLoad
    public let keyTimings: [AbilityTiming]
    public let recommendedCooldownPlan: [CooldownRecommendation]

    public init(bossEncounterId: UUID, totalAbilities: Int, damageProfileDistribution: [DamageProfile: Int], predictedHealingLoad: HealingLoad, keyTimings: [AbilityTiming], recommendedCooldownPlan: [CooldownRecommendation]) {
        self.bossEncounterId = bossEncounterId
        self.totalAbilities = totalAbilities
        self.damageProfileDistribution = damageProfileDistribution
        self.predictedHealingLoad = predictedHealingLoad
        self.keyTimings = keyTimings
        self.recommendedCooldownPlan = recommendedCooldownPlan
    }
}

public enum HealingLoad: String, CaseIterable {
    case light = "light"       // Minimal healing requirements
    case moderate = "moderate" // Standard healing pattern
    case heavy = "heavy"       // High sustained healing needed
    case burst = "burst"       // Intense periods with breaks
}

public struct AbilityTiming {
    public let abilityId: UUID
    public let estimatedCastTime: TimeInterval
    public let frequency: TimingFrequency
    public let overlapsWithOthers: Bool

    public init(abilityId: UUID, estimatedCastTime: TimeInterval, frequency: TimingFrequency, overlapsWithOthers: Bool) {
        self.abilityId = abilityId
        self.estimatedCastTime = estimatedCastTime
        self.frequency = frequency
        self.overlapsWithOthers = overlapsWithOthers
    }
}

public enum TimingFrequency: String, CaseIterable {
    case once = "once"                 // Single cast per encounter
    case periodic = "periodic"         // Regular intervals
    case conditional = "conditional"   // Based on encounter state
    case random = "random"            // Unpredictable timing
}

public struct CooldownRecommendation {
    public let cooldownName: String
    public let suggestedTiming: String
    public let targetAbilities: [UUID]
    public let rationale: String

    public init(cooldownName: String, suggestedTiming: String, targetAbilities: [UUID], rationale: String) {
        self.cooldownName = cooldownName
        self.suggestedTiming = suggestedTiming
        self.targetAbilities = targetAbilities
        self.rationale = rationale
    }
}

public struct PrioritizedAbility {
    public let ability: AbilityEntity
    public let priority: Int
    public let reasoning: String
    public let uiDisplayHint: UIDisplayHint

    public init(ability: AbilityEntity, priority: Int, reasoning: String, uiDisplayHint: UIDisplayHint) {
        self.ability = ability
        self.priority = priority
        self.reasoning = reasoning
        self.uiDisplayHint = uiDisplayHint
    }
}

// MARK: - Shared UI Types
// UIDisplayHint and AbilityColorScheme are now provided by HealerKitCore

public struct ValidationResult {
    public let isValid: Bool
    public let issues: [ValidationIssue]
    public let recommendations: [String]

    public init(isValid: Bool, issues: [ValidationIssue], recommendations: [String]) {
        self.isValid = isValid
        self.issues = issues
        self.recommendations = recommendations
    }
}

public struct ValidationIssue {
    public let severity: IssueSeverity
    public let message: String
    public let field: String?

    public init(severity: IssueSeverity, message: String, field: String?) {
        self.severity = severity
        self.message = message
        self.field = field
    }
}

public enum IssueSeverity: String, CaseIterable {
    case error = "error"
    case warning = "warning"
    case info = "info"
}

public enum AbilityDataError: LocalizedError {
    case bossEncounterNotFound(UUID)
    case invalidDamageProfile(String)
    case classificationFailed(String)
    case analysisError(Error)

    public var errorDescription: String? {
        switch self {
        case .bossEncounterNotFound(let id):
            return "Boss encounter with ID \(id) not found."
        case .invalidDamageProfile(let profile):
            return "Invalid damage profile: \(profile)"
        case .classificationFailed(let reason):
            return "Ability classification failed: \(reason)"
        case .analysisError(let error):
            return "Analysis error: \(error.localizedDescription)"
        }
    }
}

/// AbilityKit - Framework for managing boss abilities and damage classification
/// Provides healer-focused analysis of boss abilities and damage profiles
public final class AbilityKit {

    /// Shared instance
    public static let shared = AbilityKit()

    private init() {}

    /// Framework version
    public static let version = "1.0.0"

    // MARK: - Service Factory Methods

    /// Create a new ability data provider instance
    public static func createAbilityDataProvider() -> AbilityDataProviding {
        return AbilityDataProvider()
    }

    /// Create a new ability classification service instance
    public static func createAbilityClassificationService() -> AbilityClassificationService {
        return AbilityClassificationServiceImpl()
    }

    /// Create a new damage profile analyzer instance
    public static func createDamageProfileAnalyzer() -> DamageProfileAnalyzer {
        return DamageProfileAnalyzerImpl()
    }

    /// Create a damage profile analyzer with custom data provider
    public static func createDamageProfileAnalyzer(with dataProvider: AbilityDataProviding) -> DamageProfileAnalyzer {
        return DamageProfileAnalyzerImpl(abilityDataProvider: dataProvider)
    }
}