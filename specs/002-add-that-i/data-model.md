# Data Model: Mythic+ Healer's Field Manual iPad Application

## Core Entities

### Season
**Purpose**: Represents a specific Mythic+ season with curated dungeon set
```swift
class Season {
    var id: UUID
    var name: String                    // "The War Within Season 3.1"
    var majorPatchVersion: String       // "11.2"
    var isActive: Bool
    var dungeons: [Dungeon]
    var createdAt: Date
    var updatedAt: Date
}
```

**Validation Rules**:
- `name` must be unique across seasons
- `majorPatchVersion` follows semantic versioning (X.Y format)
- Only one season can be active at a time
- Must contain at least 1 dungeon

**Relationships**:
- One-to-many with Dungeon (cascade delete)

---

### Dungeon
**Purpose**: Game instance containing multiple boss encounters
```swift
class Dungeon {
    var id: UUID
    var name: String                    // "Ara-Kara, City of Echoes"
    var shortName: String               // "AK" (for UI space constraints)
    var difficultyLevel: DifficultyLevel
    var seasonId: UUID
    var bosses: [BossEncounter]
    var displayOrder: Int               // Chronological order in season
    var estimatedDuration: TimeInterval // For healer planning
    var healerNotes: String?            // Season-specific healing overview
}

enum DifficultyLevel: String, CaseIterable {
    case mythicPlus = "mythic_plus"
}
```

**Validation Rules**:
- `name` must be unique within a season
- `displayOrder` must be unique within a season
- `shortName` maximum 4 characters for iPad display
- Must contain at least 1 boss encounter

**Relationships**:
- Many-to-one with Season
- One-to-many with BossEncounter (cascade delete)

---

### BossEncounter
**Purpose**: Specific fight within a dungeon with healer summary and abilities
```swift
class BossEncounter {
    var id: UUID
    var name: String                    // "Avanoxx"
    var dungeonId: UUID
    var encounterOrder: Int             // Order within dungeon (1, 2, 3...)
    var healerSummary: String           // Tablet-optimized healer overview
    var abilities: [BossAbility]
    var difficultyRating: HealerDifficulty
    var estimatedDuration: TimeInterval
    var keyMechanics: [String]          // Top 3 mechanics healers must track
}

enum HealerDifficulty: Int, CaseIterable {
    case easy = 1
    case moderate = 2
    case hard = 3
    case extreme = 4
}
```

**Validation Rules**:
- `name` must be unique within a dungeon
- `encounterOrder` must be unique within a dungeon
- `healerSummary` maximum 500 characters for tablet display
- `keyMechanics` maximum 3 items for quick reference

**Relationships**:
- Many-to-one with Dungeon
- One-to-many with BossAbility (cascade delete)

---

### BossAbility
**Purpose**: Individual mechanics with healer-specific information and actions
```swift
class BossAbility {
    var id: UUID
    var name: String                    // "Alerting Shrill"
    var type: AbilityType
    var bossEncounterId: UUID
    var targets: TargetType
    var damageProfile: DamageProfile    // For color coding and prioritization
    var healerAction: String            // Required healer response
    var criticalInsight: String         // Key tactical information
    var cooldown: TimeInterval?         // If applicable, for timing planning
    var displayOrder: Int               // Order of importance for healers
    var isKeyMechanic: Bool            // Highlighted for quick reference
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
}
```

**Validation Rules**:
- `name` must be unique within a boss encounter
- `healerAction` maximum 200 characters for tablet display
- `criticalInsight` maximum 150 characters for quick reading
- `displayOrder` must be unique within a boss encounter
- `cooldown` must be positive if specified

**Relationships**:
- Many-to-one with BossEncounter

---

## State Transitions

### Season Lifecycle
```
Draft → Active → Archived
```
- **Draft**: Season created but not yet active
- **Active**: Current season with live dungeon data
- **Archived**: Previous season data retained for reference

### Content Update Lifecycle
```
Bundled → Loaded → Validated → Active
```
- **Bundled**: Content packaged with app update
- **Loaded**: Content imported into CoreData during app launch
- **Validated**: Content integrity verified against schema
- **Active**: Content available for user access

## Indexes and Performance

### Search Optimization
```swift
// Primary search indexes for iPad performance
- Season.name (for season selection)
- Dungeon.name + Dungeon.shortName (for dungeon search)
- BossEncounter.name (for boss search)
- BossAbility.name (for ability lookup)

// Composite indexes for common queries
- (Dungeon.seasonId, Dungeon.displayOrder) (for season dungeon lists)
- (BossEncounter.dungeonId, BossEncounter.encounterOrder) (for boss lists)
- (BossAbility.bossEncounterId, BossAbility.displayOrder) (for ability lists)
- (BossAbility.damageProfile, BossAbility.isKeyMechanic) (for filtering)
```

### Memory Management for First-Gen iPad Pro
- Lazy loading of boss abilities until encounter selected
- Image assets loaded on-demand and cached
- Automatic cleanup of unused entity relationships
- Batch loading limits (10 abilities max per query)

## Data Validation Schema

### Content Integrity Rules
1. **Referential Integrity**: All foreign keys must reference existing entities
2. **Display Constraints**: Text lengths optimized for iPad screen real estate
3. **Performance Limits**: Maximum entities per relationship to ensure smooth scrolling
4. **Healer Focus**: Content filtering ensures only healer-relevant information included

### Import Validation
```swift
// Validation rules for major patch content updates
struct ContentValidator {
    func validateSeason(_ season: Season) -> ValidationResult
    func validateDungeonSet(_ dungeons: [Dungeon]) -> ValidationResult
    func validateEncounterData(_ encounters: [BossEncounter]) -> ValidationResult
    func validateAbilityData(_ abilities: [BossAbility]) -> ValidationResult
}
```

This data model provides:
- ✅ Optimized for first-generation iPad Pro performance
- ✅ Healer-specific content organization
- ✅ Efficient search and filtering capabilities
- ✅ Major patch update workflow support
- ✅ Offline-first data access patterns
- ✅ Memory-conscious design for older hardware