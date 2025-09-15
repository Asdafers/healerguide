# Data Structure Guide

This guide provides comprehensive documentation for HealerKit's data structures, content guidelines, and season data management. All structures are optimized for healer workflows and first-generation iPad Pro performance constraints.

## Overview

HealerKit uses a hierarchical data model designed around WoW Mythic+ content structure while optimizing for healer-specific information and efficient iPad data access patterns.

### Data Hierarchy

```
Season
├── Dungeons (8 per season)
│   ├── Boss Encounters (3-5 per dungeon)
│   │   ├── Abilities (5-15 per boss)
│   │   │   ├── Damage Profile Classification
│   │   │   ├── Healer Action Requirements
│   │   │   └── Timing Information
│   │   └── Healer Summary
│   └── Dungeon Metadata
└── Season Metadata
```

## Core Data Models

### SeasonEntity

The root container for all content within a major WoW patch cycle.

```swift
struct SeasonEntity {
    let id: UUID                    // Unique season identifier
    let name: String               // Display name (e.g., "The War Within Season 1")
    let majorPatchVersion: String  // WoW patch (e.g., "11.0.5")
    let isActive: Bool             // Currently active season flag
    let dungeonCount: Int          // Total dungeons (performance optimization)
    let createdAt: Date           // Import timestamp
    let updatedAt: Date           // Last modification timestamp

    // Healer-specific metadata
    let healerContentVersion: String    // Healer content iteration (e.g., "1.2.3")
    let averageDifficultyRating: Double // 1.0-5.0 scale for healer complexity
    let recommendedIlevel: Int          // Suggested item level for content
}
```

**Usage Guidelines:**
- One active season at a time per app installation
- `majorPatchVersion` follows WoW's semantic versioning (e.g., 11.0.5, 11.1.0)
- `healerContentVersion` tracks healer-specific updates independent of WoW patches
- `averageDifficultyRating` helps healers assess overall season complexity

### DungeonEntity

Individual dungeon information with healer-focused metadata.

```swift
struct DungeonEntity {
    let id: UUID                        // Unique dungeon identifier
    let name: String                   // Full dungeon name
    let shortName: String              // Abbreviation for UI (3-4 chars)
    let difficultyLevel: String        // Recommended M+ level range
    let displayOrder: Int              // Sorting order in season
    let estimatedDuration: TimeInterval // Average completion time (minutes)
    let bossCount: Int                 // Number of boss encounters

    // Healer-specific information
    let healerNotes: String?           // Strategic overview for healers
    let healingIntensity: HealingIntensity // Overall healing requirement
    let keyMechanics: [String]         // Critical mechanics affecting healers
    let recommendedCooldowns: [String] // Suggested major cooldowns
    let positioningNotes: String?      // Healer positioning guidance

    // Performance metadata
    let lastUpdated: Date              // Content freshness tracking
    let contentCompleteness: Double    // 0.0-1.0 healer content coverage
}

enum HealingIntensity: String, CaseIterable {
    case light = "light"       // Minimal healing requirements
    case moderate = "moderate" // Standard healing patterns
    case heavy = "heavy"       // High sustained healing
    case burst = "burst"       // Intense periods with recovery
    case extreme = "extreme"   // Constant high-pressure healing
}
```

**Content Guidelines:**
- `shortName` should be community-recognized abbreviations (e.g., "SV" for Stonevault)
- `healerNotes` focus on strategic overview, not detailed mechanics
- `difficultyLevel` reflects recommended keystone levels for average groups
- `positioningNotes` highlight healer-specific positioning considerations

### BossEncounterEntity

Individual boss encounter with healer summary and tactical information.

```swift
struct BossEncounterEntity {
    let id: UUID                    // Unique boss identifier
    let dungeonId: UUID            // Parent dungeon reference
    let name: String               // Boss name
    let encounterOrder: Int        // Position in dungeon (1-based)
    let estimatedDuration: TimeInterval // Fight length for planning
    let abilityCount: Int          // Total abilities (performance hint)

    // Healer-specific content
    let healerSummary: String      // Concise tactical overview
    let difficultyRating: Int      // 1-5 scale for healer complexity
    let keyMechanics: [String]     // Critical mechanics list
    let preparationNotes: String?  // Pre-fight preparation advice
    let phaseInformation: [PhaseInfo]? // Multi-phase encounter data

    // Performance optimization
    let criticalAbilityCount: Int  // Count of critical damage abilities
    let lastValidated: Date        // Content validation timestamp
}

struct PhaseInfo {
    let phaseNumber: Int           // Phase identifier
    let description: String        // Phase mechanics summary
    let healerFocus: String       // Healer-specific phase strategy
    let estimatedDuration: TimeInterval // Phase duration
}
```

**Difficulty Rating Scale:**
- **1**: Tank-and-spank, minimal healer mechanics
- **2**: Standard damage patterns with predictable healing windows
- **3**: Moderate complexity requiring some cooldown planning
- **4**: High complexity with overlapping mechanics and burst windows
- **5**: Extreme difficulty requiring precise execution and coordination

### AbilityEntity

Individual boss ability with comprehensive healer information.

```swift
struct AbilityEntity {
    let id: UUID                    // Unique ability identifier
    let bossEncounterId: UUID      // Parent boss reference
    let name: String               // Ability name
    let displayOrder: Int          // UI sorting priority
    let isKeyMechanic: Bool        // Highlight for critical mechanics

    // Ability classification
    let type: AbilityType          // Categorization for filtering
    let targets: TargetType        // Who gets affected
    let damageProfile: DamageProfile // Healer priority classification

    // Timing information
    let cooldown: TimeInterval?     // Boss ability cooldown
    let castTime: TimeInterval?     // Cast duration
    let estimatedCastTime: TimeInterval // When in fight it occurs

    // Healer-specific information
    let healerAction: String        // Required healer response
    let criticalInsight: String     // Key tactical information
    let manaCost: ManaCostLevel?    // Expected mana expenditure
    let positioningRequirement: String? // Movement/positioning needs

    // Advanced healer data
    let preHealOpportunity: Bool    // Can be pre-healed/mitigated
    let dispellable: Bool          // Can be dispelled
    let interruptible: Bool        // Can be interrupted by healers
    let cooldownRecommendation: [String] // Suggested cooldown usage
}

enum AbilityType: String, CaseIterable {
    case damage = "damage"          // Direct damage ability
    case heal = "heal"             // Boss healing ability
    case mechanic = "mechanic"     // Non-damage mechanic
    case movement = "movement"     // Forced movement mechanic
    case interrupt = "interrupt"   // Interruptible cast
    case dispel = "dispel"        // Requires dispelling
    case positioning = "positioning" // Positioning requirement
}

enum TargetType: String, CaseIterable {
    case tank = "tank"              // Tank-targeted ability
    case randomPlayer = "random_player" // Random group member
    case group = "group"            // Entire group affected
    case healers = "healers"        // Healer-targeted ability
    case location = "location"      // Ground/area effect
    case self = "self"             // Boss self-buff/ability
}

enum DamageProfile: String, CaseIterable {
    case critical = "critical"      // Red - immediate action required
    case high = "high"             // Orange - significant concern
    case moderate = "moderate"     // Yellow - manageable damage
    case mechanic = "mechanic"     // Blue - non-damage mechanic

    var healerPriority: Int {
        switch self {
        case .critical: return 4
        case .high: return 3
        case .moderate: return 2
        case .mechanic: return 1
        }
    }
}

enum ManaCostLevel: String, CaseIterable {
    case minimal = "minimal"       // <10% mana expenditure
    case low = "low"              // 10-25% mana expenditure
    case moderate = "moderate"     // 25-50% mana expenditure
    case high = "high"            // 50-75% mana expenditure
    case extreme = "extreme"      // >75% mana expenditure
}
```

## Season Data Format

### Complete Season JSON Structure

```json
{
  "season": {
    "id": "12345678-1234-1234-1234-123456789012",
    "name": "The War Within Season 1",
    "majorPatchVersion": "11.0.5",
    "isActive": true,
    "healerContentVersion": "1.2.3",
    "averageDifficultyRating": 3.2,
    "recommendedIlevel": 610,
    "createdAt": "2024-09-15T00:00:00Z",
    "updatedAt": "2024-09-15T10:30:00Z"
  },
  "dungeons": [
    {
      "id": "87654321-4321-4321-4321-210987654321",
      "name": "The Stonevault",
      "shortName": "SV",
      "difficultyLevel": "12-18",
      "displayOrder": 1,
      "estimatedDuration": 1800,
      "bossCount": 4,
      "healerNotes": "High sustained damage throughout. Save major cooldowns for E.D.N.A. overlaps. Position centrally for optimal healing range during Seismic Slam.",
      "healingIntensity": "heavy",
      "keyMechanics": [
        "Seismic Slam group damage",
        "Boulder Toss positioning",
        "Earthquake movement"
      ],
      "recommendedCooldowns": [
        "Spirit Guardian",
        "Divine Hymn",
        "Apotheosis"
      ],
      "positioningNotes": "Stay central for E.D.N.A., hug walls for Skarmorak charges",
      "lastUpdated": "2024-09-15T10:30:00Z",
      "contentCompleteness": 0.95,
      "bossEncounters": [
        {
          "id": "11111111-1111-1111-1111-111111111111",
          "name": "E.D.N.A.",
          "encounterOrder": 1,
          "estimatedDuration": 300,
          "healerSummary": "Heavy group damage encounter requiring cooldown coordination. Pre-cast group heals before Seismic Slam. Use major cooldowns for overlapping Slam + Boulder Toss windows.",
          "difficultyRating": 4,
          "keyMechanics": [
            "Seismic Slam",
            "Boulder Toss",
            "Earthquake"
          ],
          "preparationNotes": "Pre-cast Renew on group. Position centrally. Communicate cooldown timing with other healers.",
          "phaseInformation": [
            {
              "phaseNumber": 1,
              "description": "Standard rotation with individual mechanics",
              "healerFocus": "Maintain group health above 80% for slam preparation",
              "estimatedDuration": 180
            },
            {
              "phaseNumber": 2,
              "description": "Overlapping mechanics at 30% health",
              "healerFocus": "Use major cooldowns for overlapping damage windows",
              "estimatedDuration": 120
            }
          ],
          "criticalAbilityCount": 2,
          "lastValidated": "2024-09-15T10:30:00Z",
          "abilities": [
            {
              "id": "22222222-2222-2222-2222-222222222222",
              "name": "Seismic Slam",
              "displayOrder": 1,
              "isKeyMechanic": true,
              "type": "damage",
              "targets": "group",
              "damageProfile": "critical",
              "cooldown": 45,
              "castTime": 2.5,
              "estimatedCastTime": 30,
              "healerAction": "Use group healing cooldown immediately after cast completes",
              "criticalInsight": "Hits entire group for 80% max HP. Must pre-heal or use major cooldown.",
              "manaCost": "high",
              "positioningRequirement": "Stay in central position for optimal group healing range",
              "preHealOpportunity": true,
              "dispellable": false,
              "interruptible": false,
              "cooldownRecommendation": [
                "Spirit Guardian",
                "Divine Hymn",
                "Apotheosis + Circle of Healing"
              ]
            },
            {
              "id": "33333333-3333-3333-3333-333333333333",
              "name": "Boulder Toss",
              "displayOrder": 2,
              "isKeyMechanic": true,
              "type": "damage",
              "targets": "random_player",
              "damageProfile": "high",
              "cooldown": 20,
              "castTime": 1.5,
              "estimatedCastTime": 15,
              "healerAction": "Spot heal affected player, prepare group healing if overlaps with Slam",
              "criticalInsight": "Targets random player for 60% HP. Dangerous when combined with Seismic Slam.",
              "manaCost": "moderate",
              "positioningRequirement": null,
              "preHealOpportunity": false,
              "dispellable": false,
              "interruptible": false,
              "cooldownRecommendation": [
                "Guardian Spirit (if target low)",
                "Flash Heal spam"
              ]
            }
          ]
        }
      ]
    }
  ],
  "metadata": {
    "formatVersion": "1.0.0",
    "generatedBy": "HealerKit Content Tools v1.2.3",
    "generatedAt": "2024-09-15T10:30:00Z",
    "validationLevel": "strict",
    "contentSources": [
      "Wowhead dungeon guides",
      "Method dungeon route analysis",
      "Community healer feedback",
      "Live gameplay testing"
    ],
    "qualityMetrics": {
      "healerContentCompleteness": 0.94,
      "abilityClassificationAccuracy": 0.97,
      "contentFreshness": 0.98
    }
  }
}
```

## Content Creation Guidelines

### Healer Content Standards

#### Writing Guidelines

**Healer Action Descriptions:**
- Use active, imperative language ("Use major cooldown", not "Should use cooldown")
- Specify timing when critical ("immediately after cast", "during 2-second window")
- Include mana considerations for sustained fights
- Reference specific healing spells when helpful

**Critical Insights:**
- Lead with most important information (damage amounts, timing)
- Include context for decision making (why this is dangerous)
- Mention interactions with other abilities
- Keep under 100 characters for UI optimization

**Positioning Notes:**
- Describe optimal healer positioning relative to group
- Mention range considerations for healing spells
- Include movement patterns during mechanics
- Reference visual cues in the encounter space

#### Content Validation Checklist

**Dungeon Level:**
- [ ] Healer summary provides strategic overview
- [ ] Difficulty rating reflects actual healer complexity
- [ ] Key mechanics list includes all healing-relevant abilities
- [ ] Positioning notes address healer-specific requirements
- [ ] Recommended cooldowns match encounter demands

**Boss Encounter Level:**
- [ ] Healer summary is concise but complete (2-3 sentences)
- [ ] Difficulty rating matches ability complexity and timing
- [ ] Phase information includes healer-specific strategies
- [ ] Preparation notes cover pre-fight setup

**Ability Level:**
- [ ] Damage profile classification is accurate
- [ ] Healer action is specific and actionable
- [ ] Critical insight explains the "why" behind the action
- [ ] Timing information is precise
- [ ] Cooldown recommendations are realistic and helpful

### Data Quality Standards

#### Accuracy Requirements

**Damage Profile Classification:**
- **Critical**: Abilities requiring immediate major cooldown or causing death
- **High**: Significant damage requiring focused healing response
- **Moderate**: Standard damage manageable with efficient healing
- **Mechanic**: Non-damage effects requiring awareness

**Timing Accuracy:**
- Cast times accurate to ±0.5 seconds
- Cooldown durations accurate to ±2 seconds
- Encounter duration estimates within ±30 seconds
- Phase timing accurate to ±15 seconds

#### Content Completeness Metrics

```swift
struct ContentQualityMetrics {
    let healerNotesCompleteness: Double      // % of dungeons with healer notes
    let abilityClassificationAccuracy: Double // % of abilities correctly classified
    let healerActionCompleteness: Double     // % of abilities with healer actions
    let timingDataAccuracy: Double          // % of timing data within tolerance
    let contentFreshness: Double            // Currency of content (0-1 scale)

    var overallQuality: Double {
        return (healerNotesCompleteness +
                abilityClassificationAccuracy +
                healerActionCompleteness +
                timingDataAccuracy +
                contentFreshness) / 5.0
    }
}
```

## Performance Optimization

### Data Structure Efficiency

#### Core Data Model Optimization

```swift
// Optimized Core Data model for first-gen iPad Pro
@objc(SeasonManagedObject)
class SeasonManagedObject: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var name: String
    @NSManaged var isActive: Bool
    @NSManaged var dungeons: NSSet  // Relationship to dungeons

    // Performance optimization: denormalized counts
    @NSManaged var dungeonCount: Int32
    @NSManaged var totalBossCount: Int32
    @NSManaged var criticalAbilityCount: Int32
}

@objc(DungeonManagedObject)
class DungeonManagedObject: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var name: String
    @NSManaged var shortName: String
    @NSManaged var displayOrder: Int32

    // Healer-specific indexed fields for fast querying
    @NSManaged var healingIntensity: String
    @NSManaged var difficultyRating: Double

    // Relationships
    @NSManaged var season: SeasonManagedObject
    @NSManaged var bossEncounters: NSSet
}

@objc(AbilityManagedObject)
class AbilityManagedObject: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var name: String

    // Indexed for fast filtering
    @NSManaged var damageProfile: String
    @NSManaged var healerPriority: Int32
    @NSManaged var isKeyMechanic: Bool

    // Relationships
    @NSManaged var bossEncounter: BossEncounterManagedObject
}
```

#### Fetch Request Optimization

```swift
class OptimizedDataQueries {
    static func fetchCriticalAbilities(for bossId: UUID,
                                     context: NSManagedObjectContext) -> NSFetchRequest<AbilityManagedObject> {
        let request: NSFetchRequest<AbilityManagedObject> = AbilityManagedObject.fetchRequest()

        // Efficient predicate using indexed fields
        request.predicate = NSPredicate(format:
            "bossEncounter.id == %@ AND damageProfile == %@",
            bossId as CVarArg, "critical")

        // Limit results for memory efficiency
        request.fetchBatchSize = 20
        request.returnsObjectsAsFaults = false  // Prefetch data

        // Sort by healer priority (indexed field)
        request.sortDescriptors = [
            NSSortDescriptor(key: "healerPriority", ascending: false),
            NSSortDescriptor(key: "displayOrder", ascending: true)
        ]

        return request
    }
}
```

### Memory Management

#### Efficient Entity Conversion

```swift
extension DungeonManagedObject {
    func toEntity() -> DungeonEntity {
        return DungeonEntity(
            id: self.id,
            name: self.name,
            shortName: self.shortName,
            difficultyLevel: self.difficultyLevel ?? "Unknown",
            displayOrder: Int(self.displayOrder),
            estimatedDuration: self.estimatedDuration,
            bossCount: Int(self.bossCount),
            healerNotes: self.healerNotes,
            healingIntensity: HealingIntensity(rawValue: self.healingIntensity) ?? .moderate,
            keyMechanics: self.keyMechanicsArray,  // Cached array conversion
            recommendedCooldowns: self.recommendedCooldownsArray,
            positioningNotes: self.positioningNotes,
            lastUpdated: self.lastUpdated ?? Date(),
            contentCompleteness: self.contentCompleteness
        )
    }

    // Cached array conversions for performance
    private var keyMechanicsArray: [String] {
        if let cached = self.primitiveValue(forKey: "cachedKeyMechanics") as? [String] {
            return cached
        }

        let array = self.keyMechanics?.components(separatedBy: "|") ?? []
        self.setPrimitiveValue(array, forKey: "cachedKeyMechanics")
        return array
    }
}
```

This comprehensive data structure system provides the foundation for efficient, healer-focused content management while maintaining performance requirements for first-generation iPad Pro hardware.