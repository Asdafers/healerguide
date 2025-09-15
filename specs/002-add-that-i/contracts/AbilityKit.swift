// AbilityKit Library Contract
// Manages boss abilities, damage profiles, and healer action classification

import Foundation

// MARK: - Public Interface

protocol AbilityDataProviding {
    /// Fetch all abilities for a boss encounter, ordered by display priority
    func fetchAbilities(for bossEncounterId: UUID) async throws -> [AbilityEntity]

    /// Search abilities by name across all encounters
    func searchAbilities(query: String) async throws -> [AbilityEntity]

    /// Fetch abilities filtered by damage profile (for color-coded display)
    func fetchAbilities(for bossEncounterId: UUID, damageProfile: DamageProfile) async throws -> [AbilityEntity]

    /// Fetch only key mechanics for quick reference display
    func fetchKeyMechanics(for bossEncounterId: UUID) async throws -> [AbilityEntity]
}

protocol AbilityClassificationService {
    /// Classify ability based on healer impact and urgency
    func classifyAbility(_ ability: AbilityEntity) -> AbilityClassification

    /// Get recommended healer actions for damage profile
    func getRecommendedActions(for damageProfile: DamageProfile) -> [HealerAction]

    /// Validate ability data for healer relevance
    func validateHealerRelevance(_ ability: AbilityEntity) -> ValidationResult
}

protocol DamageProfileAnalyzer {
    /// Analyze damage patterns for encounter planning
    func analyzeDamageProfile(for bossEncounterId: UUID) async throws -> DamageAnalysis

    /// Get color coding for UI display based on damage profile
    func getUIColorScheme(for damageProfile: DamageProfile) -> AbilityColorScheme

    /// Prioritize abilities for healer attention during encounter
    func prioritizeForHealer(_ abilities: [AbilityEntity]) -> [PrioritizedAbility]
}

// MARK: - Data Transfer Objects

struct AbilityEntity {
    let id: UUID
    let name: String
    let type: AbilityType
    let bossEncounterId: UUID
    let targets: TargetType
    let damageProfile: DamageProfile
    let healerAction: String
    let criticalInsight: String
    let cooldown: TimeInterval?
    let displayOrder: Int
    let isKeyMechanic: Bool
}

enum AbilityType: String, CaseIterable {
    case damage = "damage"
    case heal = "heal"
    case mechanic = "mechanic"
    case movement = "movement"
    case interrupt = "interrupt"
}

enum TargetType: String, CaseIterable {
    case tank = "tank"
    case randomPlayer = "random_player"
    case group = "group"
    case healers = "healers"
    case location = "location"
}

enum DamageProfile: String, CaseIterable {
    case critical = "critical"          // Red - immediate action required
    case high = "high"                  // Orange - significant concern
    case moderate = "moderate"          // Yellow - notable but manageable
    case mechanic = "mechanic"          // Blue - non-damage mechanic

    var priority: Int {
        switch self {
        case .critical: return 4
        case .high: return 3
        case .moderate: return 2
        case .mechanic: return 1
        }
    }
}

struct AbilityClassification {
    let urgency: UrgencyLevel
    let complexity: ComplexityLevel
    let healerImpact: ImpactLevel
    let recommendedPreparation: String
}

enum UrgencyLevel: Int, CaseIterable {
    case immediate = 4      // Must react within 1-2 seconds
    case high = 3          // React within 3-5 seconds
    case moderate = 2      // Can plan response (5-10 seconds)
    case low = 1           // Passive monitoring
}

enum ComplexityLevel: Int, CaseIterable {
    case simple = 1        // Single button press/target
    case moderate = 2      // Requires positioning + healing
    case complex = 3       // Multi-step response required
    case extreme = 4       // Coordination with team required
}

enum ImpactLevel: Int, CaseIterable {
    case critical = 4      // Encounter-ending if mishandled
    case high = 3          // Significant damage/death risk
    case moderate = 2      // Manageable but notable impact
    case low = 1           // Minor impact on encounter
}

struct HealerAction {
    let actionType: HealerActionType
    let timing: ActionTiming
    let description: String
    let keyBindSuggestion: String?
}

enum HealerActionType: String, CaseIterable {
    case preHeal = "pre_heal"
    case reactiveHeal = "reactive_heal"
    case cooldownUse = "cooldown_use"
    case positioning = "positioning"
    case dispel = "dispel"
    case interrupt = "interrupt"
}

enum ActionTiming: String, CaseIterable {
    case immediate = "immediate"        // <1 second
    case fast = "fast"                 // 1-3 seconds
    case planned = "planned"           // 3+ seconds advance notice
}

// MARK: - Analysis Results

struct DamageAnalysis {
    let bossEncounterId: UUID
    let totalAbilities: Int
    let damageProfileDistribution: [DamageProfile: Int]
    let predictedHealingLoad: HealingLoad
    let keyTimings: [AbilityTiming]
    let recommendedCooldownPlan: [CooldownRecommendation]
}

enum HealingLoad: String, CaseIterable {
    case light = "light"       // Minimal healing requirements
    case moderate = "moderate" // Standard healing pattern
    case heavy = "heavy"       // High sustained healing needed
    case burst = "burst"       // Intense periods with breaks
}

struct AbilityTiming {
    let abilityId: UUID
    let estimatedCastTime: TimeInterval
    let frequency: TimingFrequency
    let overlapsWithOthers: Bool
}

enum TimingFrequency: String, CaseIterable {
    case once = "once"                 // Single cast per encounter
    case periodic = "periodic"         // Regular intervals
    case conditional = "conditional"   // Based on encounter state
    case random = "random"            // Unpredictable timing
}

struct CooldownRecommendation {
    let cooldownName: String
    let suggestedTiming: String
    let targetAbilities: [UUID]
    let rationale: String
}

struct PrioritizedAbility {
    let ability: AbilityEntity
    let priority: Int
    let reasoning: String
    let uiDisplayHint: UIDisplayHint
}

enum UIDisplayHint: String, CaseIterable {
    case highlight = "highlight"       // Prominent display
    case emphasize = "emphasize"       // Bold/larger text
    case standard = "standard"         // Normal display
    case muted = "muted"              // De-emphasized display
}

// MARK: - UI Color Schemes

struct AbilityColorScheme {
    let primaryColor: ColorHex
    let backgroundColor: ColorHex
    let textColor: ColorHex
    let borderColor: ColorHex
}

typealias ColorHex = String  // e.g., "#FF6B6B" for red

// MARK: - Validation

struct ValidationResult {
    let isValid: Bool
    let issues: [ValidationIssue]
    let recommendations: [String]
}

struct ValidationIssue {
    let severity: IssueSeverity
    let message: String
    let field: String?
}

enum IssueSeverity: String, CaseIterable {
    case error = "error"
    case warning = "warning"
    case info = "info"
}

// MARK: - Error Handling

enum AbilityDataError: LocalizedError {
    case bossEncounterNotFound(UUID)
    case invalidDamageProfile(String)
    case classificationFailed(String)
    case analysisError(Error)

    var errorDescription: String? {
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

// MARK: - CLI Interface

protocol AbilityKitCLI {
    /// Classify and analyze abilities for encounter
    /// Usage: abilitykit analyze --boss <uuid> --format json
    func analyzeAbilities(bossId: UUID, format: OutputFormat) async -> CLIResult

    /// Validate ability data for healer relevance
    /// Usage: abilitykit validate --encounter <uuid>
    func validateAbilities(encounterId: UUID) async -> CLIResult

    /// Export ability classifications for external tools
    /// Usage: abilitykit export --format csv --damage-profile critical
    func exportClassifications(format: OutputFormat, damageProfile: DamageProfile?) async -> CLIResult

    /// Performance test ability queries
    /// Usage: abilitykit benchmark --queries 1000
    func benchmark(queryCount: Int) async -> CLIResult
}

struct CLIResult {
    let success: Bool
    let output: String
    let errorDetails: String?
}