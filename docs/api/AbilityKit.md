# AbilityKit API Documentation

AbilityKit provides boss ability classification, damage analysis, and healer action prioritization for optimal Mythic+ healing strategies. The library implements the color-coded damage profile system that forms the visual foundation of the healer interface.

## Overview

AbilityKit processes boss abilities through sophisticated classification algorithms to provide healers with immediately actionable information. The library's core strength is transforming raw ability data into healer-focused insights with visual priority indicators optimized for iPad display during high-pressure encounters.

## Core Protocols

### AbilityDataProviding

Primary interface for accessing and filtering boss abilities.

```swift
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
```

**Performance Characteristics:**
- `fetchAbilities(for:)`: < 50ms with up to 20 abilities per boss
- `searchAbilities(query:)`: < 150ms across all encounters
- Filtered queries: < 30ms with indexed damage profile lookups
- Key mechanics: < 25ms for priority mechanic extraction

### AbilityClassificationService

Intelligent classification system for healer impact assessment.

```swift
protocol AbilityClassificationService {
    /// Classify ability based on healer impact and urgency
    func classifyAbility(_ ability: AbilityEntity) -> AbilityClassification

    /// Get recommended healer actions for damage profile
    func getRecommendedActions(for damageProfile: DamageProfile) -> [HealerAction]

    /// Validate ability data for healer relevance
    func validateHealerRelevance(_ ability: AbilityEntity) -> ValidationResult
}
```

**Classification Algorithm:**
The service analyzes multiple factors to determine healer priority:
1. **Damage Output**: Raw damage numbers and healing requirements
2. **Timing**: How quickly healers must respond
3. **Target Pattern**: Who gets hit and how it affects group healing
4. **Encounter Context**: Position in fight timeline and overlap with other mechanics

### DamageProfileAnalyzer

Advanced analysis for encounter-level healing strategy.

```swift
protocol DamageProfileAnalyzer {
    /// Analyze damage patterns for encounter planning
    func analyzeDamageProfile(for bossEncounterId: UUID) async throws -> DamageAnalysis

    /// Get color coding for UI display based on damage profile
    func getUIColorScheme(for damageProfile: DamageProfile) -> AbilityColorScheme

    /// Prioritize abilities for healer attention during encounter
    func prioritizeForHealer(_ abilities: [AbilityEntity]) -> [PrioritizedAbility]
}
```

## Data Models

### AbilityEntity

Complete boss ability information with healer-focused metadata.

```swift
struct AbilityEntity {
    let id: UUID                        // Unique identifier
    let name: String                   // Ability name (e.g., "Seismic Slam")
    let type: AbilityType              // Categorization for filtering
    let bossEncounterId: UUID          // Parent boss reference
    let targets: TargetType           // Who gets hit
    let damageProfile: DamageProfile  // Color-coded severity
    let healerAction: String          // Required healer response
    let criticalInsight: String       // Key tactical information
    let cooldown: TimeInterval?       // Ability cooldown if applicable
    let displayOrder: Int             // UI priority sorting
    let isKeyMechanic: Bool          // Highlight for quick reference
}
```

### Damage Profile System

The color-coded damage profile system provides immediate visual priority indicators:

```swift
enum DamageProfile: String, CaseIterable {
    case critical = "critical"      // Red - immediate action required
    case high = "high"             // Orange - significant concern
    case moderate = "moderate"     // Yellow - notable but manageable
    case mechanic = "mechanic"     // Blue - non-damage mechanic

    var priority: Int {
        switch self {
        case .critical: return 4    // Highest priority
        case .high: return 3
        case .moderate: return 2
        case .mechanic: return 1    // Lowest priority
        }
    }
}
```

**Color Coding Guidelines:**
- **Critical (Red)**: Abilities that can end the encounter if not handled immediately
- **High (Orange)**: Significant damage requiring prompt healer response
- **Moderate (Yellow)**: Notable damage that's manageable with standard healing
- **Mechanic (Blue)**: Non-damage effects requiring awareness but not immediate healing

### AbilityClassification

Comprehensive classification result for healer decision-making.

```swift
struct AbilityClassification {
    let urgency: UrgencyLevel          // How quickly to respond
    let complexity: ComplexityLevel    // Difficulty of proper response
    let healerImpact: ImpactLevel     // Consequence of mishandling
    let recommendedPreparation: String // Strategic guidance
}

enum UrgencyLevel: Int, CaseIterable {
    case immediate = 4    // Must react within 1-2 seconds
    case high = 3        // React within 3-5 seconds
    case moderate = 2    // Can plan response (5-10 seconds)
    case low = 1         // Passive monitoring
}

enum ComplexityLevel: Int, CaseIterable {
    case simple = 1      // Single button press/target
    case moderate = 2    // Requires positioning + healing
    case complex = 3     // Multi-step response required
    case extreme = 4     // Coordination with team required
}

enum ImpactLevel: Int, CaseIterable {
    case critical = 4    // Encounter-ending if mishandled
    case high = 3        // Significant damage/death risk
    case moderate = 2    // Manageable but notable impact
    case low = 1         // Minor impact on encounter
}
```

### HealerAction

Actionable guidance for specific healer responses.

```swift
struct HealerAction {
    let actionType: HealerActionType    // What kind of action to take
    let timing: ActionTiming           // When to execute the action
    let description: String            // Detailed explanation
    let keyBindSuggestion: String?     // Recommended keybinding
}

enum HealerActionType: String, CaseIterable {
    case preHeal = "pre_heal"          // Anticipatory healing
    case reactiveHeal = "reactive_heal" // Response healing
    case cooldownUse = "cooldown_use"   // Major cooldown usage
    case positioning = "positioning"    // Movement/positioning
    case dispel = "dispel"             // Dispel magic/disease
    case interrupt = "interrupt"        // Interrupt casting
}

enum ActionTiming: String, CaseIterable {
    case immediate = "immediate"        // <1 second response
    case fast = "fast"                 // 1-3 seconds response
    case planned = "planned"           // 3+ seconds advance notice
}
```

## Analysis Results

### DamageAnalysis

Comprehensive encounter-level analysis for strategic planning.

```swift
struct DamageAnalysis {
    let bossEncounterId: UUID                           // Target boss
    let totalAbilities: Int                            // Total ability count
    let damageProfileDistribution: [DamageProfile: Int] // Distribution by severity
    let predictedHealingLoad: HealingLoad              // Overall intensity
    let keyTimings: [AbilityTiming]                    // Critical timing windows
    let recommendedCooldownPlan: [CooldownRecommendation] // Strategic cooldown usage
}

enum HealingLoad: String, CaseIterable {
    case light = "light"       // Minimal healing requirements
    case moderate = "moderate" // Standard healing pattern
    case heavy = "heavy"       // High sustained healing needed
    case burst = "burst"       // Intense periods with breaks
}

struct CooldownRecommendation {
    let cooldownName: String      // Specific healer cooldown
    let suggestedTiming: String   // When to use during encounter
    let targetAbilities: [UUID]   // Which abilities it should cover
    let rationale: String        // Why this timing is optimal
}
```

### PrioritizedAbility

Sorted ability list with display hints for UI optimization.

```swift
struct PrioritizedAbility {
    let ability: AbilityEntity     // The ability data
    let priority: Int              // Calculated priority score
    let reasoning: String          // Why this priority was assigned
    let uiDisplayHint: UIDisplayHint // How to display in UI
}

enum UIDisplayHint: String, CaseIterable {
    case highlight = "highlight"   // Prominent display with border/shadow
    case emphasize = "emphasize"   // Bold/larger text
    case standard = "standard"     // Normal display
    case muted = "muted"          // De-emphasized display
}
```

## Color Scheme System

### AbilityColorScheme

iPad-optimized color schemes for damage profile visualization.

```swift
struct AbilityColorScheme {
    let primaryColor: ColorHex      // Main color for damage profile
    let backgroundColor: ColorHex   // Card background color
    let textColor: ColorHex        // Readable text color
    let borderColor: ColorHex      // Border/accent color
}

typealias ColorHex = String  // e.g., "#FF6B6B" for critical red
```

**Default Color Schemes:**

| Damage Profile | Primary | Background | Text | Border |
|---------------|---------|------------|------|--------|
| Critical | `#FF6B6B` | `#FFF5F5` | `#B91C1C` | `#DC2626` |
| High | `#F59E0B` | `#FFFBEB` | `#B45309` | `#D97706` |
| Moderate | `#EAB308` | `#FEFCE8` | `#A16207` | `#CA8A04` |
| Mechanic | `#3B82F6` | `#EFF6FF` | `#1E40AF` | `#2563EB` |

**Accessibility Compliance:**
- All color combinations meet WCAG AA contrast requirements (4.5:1 minimum)
- Alternative indicators provided for colorblind users
- High contrast mode support with enhanced borders and patterns

## Error Handling

### AbilityDataError

Comprehensive error handling for ability data and analysis operations.

```swift
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
```

## CLI Interface

### AbilityKitCLI

Command-line tools for analysis, validation, and performance testing.

```swift
protocol AbilityKitCLI {
    /// Classify and analyze abilities for encounter
    func analyzeAbilities(bossId: UUID, format: OutputFormat) async -> CLIResult

    /// Validate ability data for healer relevance
    func validateAbilities(encounterId: UUID) async -> CLIResult

    /// Export ability classifications for external tools
    func exportClassifications(format: OutputFormat, damageProfile: DamageProfile?) async -> CLIResult

    /// Performance test ability queries
    func benchmark(queryCount: Int) async -> CLIResult
}
```

### CLI Commands

#### Ability Analysis
```bash
# Analyze abilities for specific boss encounter
abilitykit analyze --boss 12345678-1234-1234-1234-123456789012 --format json

# Sample output:
{
  "bossEncounterId": "12345678-1234-1234-1234-123456789012",
  "totalAbilities": 8,
  "damageProfileDistribution": {
    "critical": 2,
    "high": 3,
    "moderate": 2,
    "mechanic": 1
  },
  "healingLoad": "heavy",
  "recommendations": [
    {
      "cooldownName": "Spirit Guardian",
      "timing": "Phase 2 transition (60% HP)",
      "targetAbilities": ["Seismic Slam", "Boulder Toss"],
      "rationale": "Covers overlapping high-damage window"
    }
  ]
}
```

#### Data Validation
```bash
# Validate all abilities for encounter
abilitykit validate --encounter 12345678-1234-1234-1234-123456789012

# Sample output:
Ability Validation Results:
✓ 8 abilities found for encounter
✓ All damage profiles are valid
✓ Healer actions are complete
⚠ 2 abilities missing cooldown information
⚠ 1 ability has unclear healer action description

Recommendations:
- Review cooldown data for "Crushing Blow" and "Stone Spike"
- Clarify healer action for "Earthquake" (currently: "heal group")
```

#### Performance Testing
```bash
# Benchmark ability classification performance
abilitykit benchmark --queries 1000

# Sample output:
Performance Benchmark Results:
- Total queries: 1000
- Average classification time: 2.3ms
- Peak memory usage: 8.4MB
- Cache hit rate: 89%
- Recommendation: Performance target met for first-gen iPad Pro
```

## Integration Examples

### Basic Classification Workflow

```swift
import AbilityKit

class HealerAbilityService {
    private let abilityProvider: AbilityDataProviding
    private let classifier: AbilityClassificationService
    private let analyzer: DamageProfileAnalyzer

    init() {
        self.abilityProvider = AbilityDataProvider()
        self.classifier = AbilityClassificationService()
        self.analyzer = DamageProfileAnalyzer()
    }

    func loadBossAbilities(for bossId: UUID) async throws -> [PrioritizedAbility] {
        // Fetch raw abilities
        let abilities = try await abilityProvider.fetchAbilities(for: bossId)

        // Classify each ability for healer relevance
        let classifiedAbilities = abilities.map { ability in
            let classification = classifier.classifyAbility(ability)
            return (ability, classification)
        }

        // Prioritize for healer display
        let prioritizedAbilities = analyzer.prioritizeForHealer(abilities)

        return prioritizedAbilities.sorted { $0.priority > $1.priority }
    }
}
```

### Color-Coded UI Integration

```swift
class AbilityCardRenderer {
    private let analyzer: DamageProfileAnalyzer

    init(analyzer: DamageProfileAnalyzer) {
        self.analyzer = analyzer
    }

    func renderAbilityCard(ability: AbilityEntity) -> UIView {
        let colorScheme = analyzer.getUIColorScheme(for: ability.damageProfile)

        let cardView = UIView()
        cardView.backgroundColor = UIColor(hex: colorScheme.backgroundColor)
        cardView.layer.borderColor = UIColor(hex: colorScheme.borderColor).cgColor
        cardView.layer.borderWidth = 2.0
        cardView.layer.cornerRadius = 8.0

        // Configure text colors based on damage profile
        let titleLabel = UILabel()
        titleLabel.text = ability.name
        titleLabel.textColor = UIColor(hex: colorScheme.textColor)
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)

        let actionLabel = UILabel()
        actionLabel.text = ability.healerAction
        actionLabel.textColor = UIColor(hex: colorScheme.primaryColor)
        actionLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)

        // Layout configuration...
        return cardView
    }
}
```

### Strategic Analysis Integration

```swift
class EncounterPreparationService {
    private let analyzer: DamageProfileAnalyzer

    init(analyzer: DamageProfileAnalyzer) {
        self.analyzer = analyzer
    }

    func generateEncounterStrategy(for bossId: UUID) async throws -> EncounterStrategy {
        let analysis = try await analyzer.analyzeDamageProfile(for: bossId)

        let strategy = EncounterStrategy(
            healingIntensity: analysis.predictedHealingLoad,
            criticalWindows: extractCriticalWindows(from: analysis),
            cooldownPlan: analysis.recommendedCooldownPlan,
            positioning: generatePositioningGuidance(from: analysis)
        )

        return strategy
    }

    private func extractCriticalWindows(from analysis: DamageAnalysis) -> [CriticalWindow] {
        return analysis.keyTimings
            .filter { $0.estimatedCastTime < 3.0 } // Quick reaction required
            .map { timing in
                CriticalWindow(
                    timeFrame: timing.estimatedCastTime,
                    severity: determineSeverity(for: timing),
                    recommendedActions: getActionsFor(timing)
                )
            }
    }
}
```

## Best Practices

### 1. Efficient Classification
```swift
// ✅ Good: Batch classify abilities for better performance
func classifyAbilities(_ abilities: [AbilityEntity]) -> [AbilityClassification] {
    return abilities.map { classifier.classifyAbility($0) }
}

// ❌ Avoid: Individual database queries for each ability
// This creates unnecessary overhead and slower response times
```

### 2. Memory-Conscious Analysis
```swift
// ✅ Good: Stream processing for large ability sets
func analyzeBossAbilities(bossId: UUID) async throws -> DamageAnalysis {
    let abilities = try await abilityProvider.fetchAbilities(for: bossId)

    // Process in chunks to manage memory usage
    let analysis = abilities.chunked(into: 10).reduce(into: DamageAnalysis()) { result, chunk in
        let chunkAnalysis = analyzeChunk(chunk)
        result.merge(with: chunkAnalysis)
    }

    return analysis
}
```

### 3. Color Scheme Caching
```swift
// ✅ Good: Cache color schemes to avoid repeated calculations
class ColorSchemeCache {
    private var cache: [DamageProfile: AbilityColorScheme] = [:]

    func getColorScheme(for profile: DamageProfile) -> AbilityColorScheme {
        if let cached = cache[profile] {
            return cached
        }

        let scheme = generateColorScheme(for: profile)
        cache[profile] = scheme
        return scheme
    }
}
```

## Testing

### Unit Testing
```swift
class AbilityClassificationTests: XCTestCase {
    var classifier: AbilityClassificationService!

    override func setUp() {
        super.setUp()
        classifier = AbilityClassificationService()
    }

    func testCriticalAbilityClassification() {
        let criticalAbility = AbilityEntity(
            id: UUID(),
            name: "Seismic Slam",
            type: .damage,
            bossEncounterId: UUID(),
            targets: .group,
            damageProfile: .critical,
            healerAction: "Use group healing cooldown immediately",
            criticalInsight: "Hits entire group for 80% HP",
            cooldown: nil,
            displayOrder: 1,
            isKeyMechanic: true
        )

        let classification = classifier.classifyAbility(criticalAbility)

        XCTAssertEqual(classification.urgency, .immediate)
        XCTAssertEqual(classification.healerImpact, .critical)
        XCTAssertEqual(classification.complexity, .moderate)
    }

    func testDamageProfilePriorityOrdering() {
        let profiles: [DamageProfile] = [.moderate, .critical, .mechanic, .high]
        let sortedProfiles = profiles.sorted { $0.priority > $1.priority }

        XCTAssertEqual(sortedProfiles, [.critical, .high, .moderate, .mechanic])
    }
}
```

### Performance Testing
```swift
class AbilityPerformanceTests: XCTestCase {
    func testClassificationPerformance() {
        let abilities = generateTestAbilities(count: 100)
        let classifier = AbilityClassificationService()

        measure {
            abilities.forEach { ability in
                _ = classifier.classifyAbility(ability)
            }
        }
        // Should complete 100 classifications in < 100ms on first-gen iPad Pro
    }
}
```

This API provides the intelligent classification and analysis foundation for healer-focused encounter preparation, with performance optimizations specifically designed for first-generation iPad Pro constraints.