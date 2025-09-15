# Healer Workflow Guide

This guide provides comprehensive documentation for the healer-focused design patterns, color coding system, and priority structures that form the core of HealerKit's user experience. All patterns are optimized for high-pressure Mythic+ encounters and quick decision-making.

## Healer-Centric Design Philosophy

### Core Principles

1. **Information Hierarchy**: Critical healing information gets visual priority
2. **Glanceable Interface**: Key decisions visible within 2-second scan
3. **Color-Coded Priority**: Immediate visual classification of threat levels
4. **Action-Oriented**: Focus on what healers need to do, not just what abilities do
5. **Context Aware**: Information relevance changes based on encounter phase and role

### Design for High-Pressure Scenarios

HealerKit recognizes that Mythic+ healers operate under extreme time pressure where:
- Decisions must be made within 1-3 seconds
- Visual information must be processed instantly
- Interface complexity can cause fatal delays
- Consistency across encounters reduces cognitive load

## Color Coding System

### Damage Profile Classification

The color coding system provides instant visual priority classification for healer decision-making:

```swift
enum DamageProfile: String, CaseIterable {
    case critical = "critical"      // Red - immediate action required
    case high = "high"             // Orange - significant concern
    case moderate = "moderate"     // Yellow - notable but manageable
    case mechanic = "mechanic"     // Blue - non-damage mechanic

    var healerPriority: Int {
        switch self {
        case .critical: return 4    // Drop everything else
        case .high: return 3        // Major healing response required
        case .moderate: return 2    // Standard healing protocols
        case .mechanic: return 1    // Awareness, minimal healing impact
        }
    }
}
```

### Visual Color Specifications

#### Critical Damage (Red)
- **Primary Color**: `#FF6B6B` (255, 107, 107)
- **Background**: `#FFF5F5` (255, 245, 245)
- **Border**: `#DC2626` (220, 38, 38)
- **Text**: `#B91C1C` (185, 28, 28)

**Usage Criteria:**
- Abilities that can one-shot players if not healed immediately
- Group-wide damage exceeding 70% of player health
- Debuffs requiring immediate dispel or players die
- Mechanics with <2 second response window

**Healer Actions:**
- Use major cooldowns (Spirit Guardian, Divine Hymn, etc.)
- Interrupt current cast to respond
- Pre-cast group healing abilities
- Coordinate with defensive cooldowns

#### High Damage (Orange)
- **Primary Color**: `#F59E0B` (245, 158, 11)
- **Background**: `#FFFBEB` (255, 251, 235)
- **Border**: `#D97706` (217, 119, 6)
- **Text**: `#B45309` (180, 83, 9)

**Usage Criteria:**
- Significant damage requiring focused healing response
- Tank damage spikes needing immediate attention
- DoT effects that will kill without healing intervention
- Abilities with 3-5 second response window

**Healer Actions:**
- Use targeted healing cooldowns
- Switch healing priority to affected targets
- Pre-cast healing abilities when possible
- Monitor for ability combinations

#### Moderate Damage (Yellow)
- **Primary Color**: `#EAB308` (234, 179, 8)
- **Background**: `#FEFCE8` (254, 252, 232)
- **Border**: `#CA8A04` (202, 138, 4)
- **Text**: `#A16207` (161, 98, 7)

**Usage Criteria:**
- Standard damage that fits normal healing rotation
- Predictable damage patterns healers can plan around
- Abilities that don't threaten immediate death
- Mechanics with 5+ second response window

**Healer Actions:**
- Include in normal healing rotation
- Top off affected players when convenient
- Use efficient healing spells (not cooldowns)
- Monitor for overlapping damage sources

#### Mechanic (Blue)
- **Primary Color**: `#3B82F6` (59, 130, 246)
- **Background**: `#EFF6FF` (239, 246, 255)
- **Border**: `#2563EB` (37, 99, 235)
- **Text**: `#1E40AF` (30, 64, 175)

**Usage Criteria:**
- Non-damage mechanics requiring awareness
- Positioning requirements affecting healing
- Crowd control effects on group members
- Interruptible casts that don't directly damage

**Healer Actions:**
- Maintain awareness for positioning
- Prepare for indirect healing impacts
- Coordinate interrupts if capable
- Adjust positioning for optimal healing range

### Color Accessibility Features

#### Colorblind-Friendly Alternatives
```swift
enum AccessibilityPattern {
    case solid           // Standard solid color
    case diagonal        // Diagonal stripes for critical
    case dotted         // Dotted border for high
    case dashed         // Dashed border for moderate
    case doubleStroke   // Double border for mechanic

    func apply(to layer: CALayer, profile: DamageProfile) {
        switch self {
        case .diagonal:
            addDiagonalPattern(layer: layer, color: profile.primaryColor)
        case .dotted:
            layer.borderStyle = .dotted
        case .dashed:
            layer.borderStyle = .dashed
        case .doubleStroke:
            addDoubleBorder(layer: layer, color: profile.primaryColor)
        default:
            // Standard solid color application
            break
        }
    }
}
```

#### High Contrast Mode Support
- **Enhanced Borders**: 3pt minimum border width in high contrast mode
- **Pattern Overlays**: Geometric patterns supplement color coding
- **Text Weight**: Increased font weight for better readability
- **Background Contrast**: Enhanced contrast ratios (7:1 minimum)

## Priority System Architecture

### Information Hierarchy Model

```
Level 1: Critical Abilities (Red)
├── Immediate threat to life
├── Requires major cooldown response
└── Must interrupt current action

Level 2: High Priority (Orange)
├── Significant healing requirement
├── Tank survival dependent
└── 3-5 second response window

Level 3: Standard Priority (Yellow)
├── Normal healing rotation
├── Manageable with efficient spells
└── 5+ second planning window

Level 4: Awareness Level (Blue)
├── Non-damage mechanics
├── Positioning considerations
└── Indirect healing impact
```

### Dynamic Priority Adjustment

#### Contextual Priority Factors
```swift
struct PriorityContext {
    let encounterPhase: EncounterPhase      // Changes ability relevance
    let groupHealthStatus: GroupHealth      // Affects urgency
    let availableCooldowns: [Cooldown]      // Influences response options
    let healerMana: ManaLevel              // Affects spell choices
    let keyLevel: Int                      // Scales damage values
}

enum EncounterPhase {
    case opening        // First 30 seconds
    case sustained      // Steady state mechanics
    case transition     // Phase changes
    case burn           // Final phase/enrage
}
```

#### Adaptive Prioritization Algorithm
```swift
class HealerPriorityCalculator {
    func calculateDisplayPriority(_ ability: AbilityEntity,
                                context: PriorityContext) -> Int {
        var basePriority = ability.damageProfile.healerPriority

        // Phase-based adjustments
        switch context.encounterPhase {
        case .opening:
            // Emphasize setup abilities
            if ability.type == .preparation {
                basePriority += 1
            }
        case .burn:
            // Critical abilities become even more critical
            if ability.damageProfile == .critical {
                basePriority += 1
            }
        default:
            break
        }

        // Group health adjustments
        if context.groupHealthStatus == .critical &&
           ability.targets == .group {
            basePriority += 2
        }

        // Cooldown availability
        let requiredCooldown = ability.recommendedCooldown
        if !context.availableCooldowns.contains(requiredCooldown) {
            basePriority -= 1  // Lower priority if can't execute optimal response
        }

        return min(basePriority, 5)  // Cap at maximum priority
    }
}
```

## Healer Workflow Patterns

### Pre-Encounter Planning Workflow

#### Strategic Overview Process
```
1. Encounter Analysis
   ├── Identify critical abilities (red items)
   ├── Plan cooldown usage timeline
   ├── Note positioning requirements
   └── Review key mechanic timings

2. Cooldown Planning
   ├── Map major cooldowns to critical windows
   ├── Identify backup options for failures
   ├── Plan mana management around burst phases
   └── Coordinate with other healers/defensives

3. Positioning Strategy
   ├── Optimal healing range positions
   ├── Movement patterns for mechanics
   ├── Line of sight considerations
   └── Emergency escape routes
```

#### Pre-Planning Interface Design
```swift
class EncounterPlanningViewController: UIViewController {
    @IBOutlet weak var criticalAbilitiesSection: UIStackView!
    @IBOutlet weak var cooldownPlanningView: CooldownTimelineView!
    @IBOutlet weak var positioningMapView: PositioningMapView!

    func loadEncounterPlan(for boss: BossEncounterEntity) {
        // Display critical abilities at top
        let criticalAbilities = boss.abilities.filter {
            $0.damageProfile == .critical
        }.sorted {
            $0.estimatedCastTime < $1.estimatedCastTime
        }

        displayCriticalAbilities(criticalAbilities)

        // Generate recommended cooldown timeline
        let cooldownPlan = CooldownPlanner.generatePlan(for: boss)
        cooldownPlanningView.displayPlan(cooldownPlan)

        // Show positioning recommendations
        let positioningGuide = PositioningAnalyzer.analyze(boss)
        positioningMapView.displayGuide(positioningGuide)
    }
}
```

### In-Combat Reference Workflow

#### Quick Reference Interface
```swift
class CombatReferenceView: UIView {
    private let criticalAbilitiesBar = CriticalAbilitiesBar()
    private let nextAbilityPreview = NextAbilityPreview()
    private let cooldownTracker = CooldownTrackerView()

    func setupCombatLayout() {
        // Top priority: Critical abilities always visible
        addSubview(criticalAbilitiesBar)
        criticalAbilitiesBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            criticalAbilitiesBar.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            criticalAbilitiesBar.leadingAnchor.constraint(equalTo: leadingAnchor),
            criticalAbilitiesBar.trailingAnchor.constraint(equalTo: trailingAnchor),
            criticalAbilitiesBar.heightAnchor.constraint(equalToConstant: 60)
        ])

        // Secondary: Next ability preview
        addSubview(nextAbilityPreview)
        nextAbilityPreview.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nextAbilityPreview.topAnchor.constraint(equalTo: criticalAbilitiesBar.bottomAnchor, constant: 8),
            nextAbilityPreview.leadingAnchor.constraint(equalTo: leadingAnchor),
            nextAbilityPreview.trailingAnchor.constraint(equalTo: trailingAnchor),
            nextAbilityPreview.heightAnchor.constraint(equalToConstant: 40)
        ])

        // Utility: Cooldown tracker
        addSubview(cooldownTracker)
        cooldownTracker.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cooldownTracker.topAnchor.constraint(equalTo: nextAbilityPreview.bottomAnchor, constant: 8),
            cooldownTracker.leadingAnchor.constraint(equalTo: leadingAnchor),
            cooldownTracker.trailingAnchor.constraint(equalTo: trailingAnchor),
            cooldownTracker.heightAnchor.constraint(lessThanOrEqualToConstant: 120)
        ])
    }
}
```

### Post-Encounter Analysis Workflow

#### Performance Review Interface
```swift
class EncounterAnalysisViewController: UIViewController {
    func displayEncounterResults(_ results: EncounterResults) {
        // Show performance against each critical ability
        let criticalAbilityResults = results.criticalAbilityHandling
        displayCriticalAbilityAnalysis(criticalAbilityResults)

        // Cooldown usage efficiency
        let cooldownAnalysis = results.cooldownUsageAnalysis
        displayCooldownEfficiency(cooldownAnalysis)

        // Improvement recommendations
        let recommendations = PerformanceAnalyzer.generateRecommendations(results)
        displayRecommendations(recommendations)
    }
}

struct EncounterResults {
    let criticalAbilityHandling: [AbilityPerformance]
    let cooldownUsageAnalysis: CooldownAnalysis
    let overallRating: PerformanceRating
    let improvementAreas: [ImprovementArea]
}

struct AbilityPerformance {
    let ability: AbilityEntity
    let responseTime: TimeInterval
    let effectiveness: EffectivenessRating
    let recommendedImprovement: String?
}
```

## Specialized Healer Interfaces

### Role-Specific Customizations

#### Discipline Priest Interface
```swift
class DisciplinePriestInterface: HealerInterface {
    override func configurePriorityDisplay() {
        // Emphasize damage abilities that can be pre-shielded
        let damageAbilities = abilities.filter {
            $0.canBePrevented && $0.damageProfile != .mechanic
        }

        // Highlight power word: shield opportunities
        damageAbilities.forEach { ability in
            if ability.estimatedCastTime > 2.0 {
                ability.addTag(.preshieldOpportunity)
            }
        }

        // Show atonement coverage recommendations
        displayAtonementCoverage(for: abilities)
    }
}
```

#### Restoration Druid Interface
```swift
class RestorationDruidInterface: HealerInterface {
    override func configurePriorityDisplay() {
        // Emphasize HoT ramp up timing
        let sustainedDamageAbilities = abilities.filter {
            $0.sustainedDamage == true
        }

        sustainedDamageAbilities.forEach { ability in
            let rampTime = calculateHoTRampTime(for: ability)
            ability.addTiming(.hotRampRequired(rampTime))
        }

        // Highlight movement-friendly abilities
        let movementAbilities = abilities.filter { $0.requiresMovement }
        displayMovementFriendlyOptions(movementAbilities)
    }
}
```

### Interface Customization System

#### Configurable Information Display
```swift
struct HealerDisplayPreferences {
    let showCooldownTimers: Bool
    let emphasizeGroupDamage: Bool
    let showManaCosts: Bool
    let displayPositioningHints: Bool
    let useCompactMode: Bool

    // Role-specific preferences
    let priestPreferences: PriestDisplayPreferences?
    let druidPreferences: DruidDisplayPreferences?
    let shamanPreferences: ShamanDisplayPreferences?
    let paladinPreferences: PaladinDisplayPreferences?
}

struct PriestDisplayPreferences {
    let showPreshieldOpportunities: Bool
    let displayAtonementCoverage: Bool
    let emphasizeDispelTargets: Bool
}

struct DruidDisplayPreferences {
    let showHoTRampTiming: Bool
    let displayMovementOptions: Bool
    let emphasizeShapeshiftOpportunities: Bool
}
```

## Advanced Workflow Features

### Predictive Ability Timeline

#### Timeline Visualization
```swift
class AbilityTimelineView: UIView {
    private var timelineItems: [TimelineItem] = []

    func displayPredictiveTimeline(_ abilities: [AbilityEntity]) {
        let sortedAbilities = abilities.sorted {
            $0.estimatedCastTime < $1.estimatedCastTime
        }

        timelineItems = sortedAbilities.enumerated().map { index, ability in
            TimelineItem(
                ability: ability,
                estimatedTime: ability.estimatedCastTime,
                priority: ability.damageProfile.healerPriority,
                recommendedPreparation: ability.healerPreparation
            )
        }

        layoutTimeline()
    }

    private func layoutTimeline() {
        // Visual timeline with color-coded priority markers
        timelineItems.forEach { item in
            let marker = TimelineMarker(item: item)
            addSubview(marker)

            // Position based on estimated timing
            let xPosition = CGFloat(item.estimatedTime / maxEncounterTime) * bounds.width
            marker.center.x = xPosition

            // Y position based on priority (critical abilities at top)
            let yPosition = CGFloat(5 - item.priority) * 30 + 20
            marker.center.y = yPosition
        }
    }
}
```

### Smart Recommendations Engine

#### Contextual Suggestions
```swift
class HealerRecommendationEngine {
    func generateRecommendations(for encounter: BossEncounterEntity,
                               healerSpec: HealerSpecialization,
                               keyLevel: Int) -> [HealerRecommendation] {

        var recommendations: [HealerRecommendation] = []

        // Analyze ability patterns
        let criticalAbilities = encounter.abilities.filter {
            $0.damageProfile == .critical
        }

        // Generate cooldown recommendations
        criticalAbilities.forEach { ability in
            if let cooldownRec = generateCooldownRecommendation(
                for: ability,
                spec: healerSpec,
                keyLevel: keyLevel
            ) {
                recommendations.append(cooldownRec)
            }
        }

        // Positioning recommendations
        let positioningRec = generatePositioningRecommendations(encounter)
        recommendations.append(contentsOf: positioningRec)

        // Talent/legendary recommendations
        let talentRec = generateTalentRecommendations(encounter, healerSpec)
        recommendations.append(contentsOf: talentRec)

        return recommendations.sorted { $0.priority > $1.priority }
    }
}
```

This comprehensive healer workflow system provides the foundation for creating interfaces that support healers in making critical decisions quickly and effectively during high-pressure Mythic+ encounters, with visual priority systems and contextual information designed specifically for healing gameplay patterns.