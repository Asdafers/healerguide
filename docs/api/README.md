# HealerKit Library APIs

This section provides complete API documentation for all HealerKit libraries, organized by functionality and designed for iPad-optimized healer workflows.

## Library Architecture

HealerKit follows a **library-first architecture** where each major feature is implemented as a standalone Swift framework:

```
HealerKit App
├── DungeonKit     - Dungeon and boss encounter data management
├── AbilityKit     - Boss ability classification and damage analysis
└── HealerUIKit    - iPad-optimized UI components
```

## Quick Reference

### Core Protocols

| Protocol | Library | Purpose |
|----------|---------|---------|
| `DungeonDataProviding` | DungeonKit | Fetch dungeons and boss encounters |
| `SeasonDataProviding` | DungeonKit | Manage season data and updates |
| `AbilityDataProviding` | AbilityKit | Fetch and search boss abilities |
| `AbilityClassificationService` | AbilityKit | Classify abilities by healer impact |
| `DamageProfileAnalyzer` | AbilityKit | Analyze damage patterns and priorities |
| `HealerDisplayProviding` | HealerUIKit | Create main UI views for healer workflow |
| `AbilityCardProviding` | HealerUIKit | Generate color-coded ability cards |
| `NavigationProviding` | HealerUIKit | iPad-optimized navigation components |

### Key Data Types

| Type | Library | Description |
|------|---------|-------------|
| `DungeonEntity` | DungeonKit | Dungeon information with healer notes |
| `BossEncounterEntity` | DungeonKit | Boss encounter with healer summary |
| `AbilityEntity` | AbilityKit | Boss ability with damage profile |
| `DamageProfile` | AbilityKit | Color-coded severity classification |
| `AbilityClassification` | AbilityKit | Healer impact and urgency analysis |
| `HealerColorScheme` | HealerUIKit | iPad-optimized colors for damage types |

## Library Documentation

### [DungeonKit API](./DungeonKit.md)
- Complete data access layer for dungeons and encounters
- Season management and content updates
- Performance optimization for first-gen iPad Pro
- CLI tools for validation and diagnostics

### [AbilityKit API](./AbilityKit.md)
- Boss ability classification and damage analysis
- Healer action recommendations and priority systems
- Color coding system for visual hierarchy
- CLI tools for analysis and validation

### [HealerUIKit API](./HealerUIKit.md)
- iPad-optimized view controllers and components
- Color-coded ability cards and navigation
- Accessibility compliance for healer workflows
- Performance monitoring and optimization

## Design Principles

### 1. Offline-First Design
All libraries support complete offline functionality:
- No network calls during encounter viewing
- Local CoreData storage with efficient querying
- Preloaded content for immediate access

### 2. Performance-Optimized
Designed for first-generation iPad Pro limitations:
- 60fps rendering target across all components
- Memory-efficient data structures (<4GB RAM usage)
- Lazy loading and caching strategies

### 3. Healer-Focused
Interfaces designed specifically for Mythic+ healers:
- Damage profile classification (Critical/High/Moderate/Mechanic)
- Healer action prioritization and timing guidance
- Color-coded visual hierarchy for quick recognition

### 4. Constitutional Compliance
All libraries adhere to project requirements:
- Library-first architecture with clear separation
- Test-driven development with comprehensive coverage
- CLI interfaces for validation and diagnostics
- Accessibility compliance for inclusive design

## Error Handling

All libraries use consistent error handling patterns:

```swift
enum LibraryError: LocalizedError {
    case dataNotFound(UUID)
    case validationFailed(String)
    case performanceThresholdExceeded(String)

    var errorDescription: String? {
        // Localized descriptions for user display
    }
}
```

## CLI Integration

Each library provides CLI tools for development and validation:

```bash
# DungeonKit
dungeonkit validate --format json
dungeonkit import --file season_data.json --validate
dungeonkit export --season active --format human

# AbilityKit
abilitykit analyze --boss <uuid> --format json
abilitykit validate --encounter <uuid>
abilitykit benchmark --queries 1000

# HealerUIKit
healeruikit benchmark --component ability-card --iterations 100
healeruikit validate-layouts --device ipad-pro-gen1
healeruikit accessibility-audit --output report.json
```

## Next Steps

1. **Start Development**: Review individual library APIs for detailed interface contracts
2. **Performance Optimization**: See [Performance Guide](../technical/performance-optimization.md) for iPad Pro strategies
3. **Testing**: Use CLI tools for validation during development
4. **UI Implementation**: Follow [iPad Guidelines](../usage/ipad-guidelines.md) for platform-specific patterns