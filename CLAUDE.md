# HealerKit - Claude Code Context

## Project Overview
Native iPad application for World of Warcraft Mythic+ healers targeting first-generation iPad Pro. Provides offline access to encounter-specific healing information with healer-focused content for The War Within Season dungeons.

## Technology Stack

### Core Technologies
- **Language**: Swift 5.9 (iOS 13.1+ compatibility)
- **UI Framework**: UIKit + SwiftUI hybrid approach
- **Storage**: CoreData with SQLite backing
- **Testing**: XCTest (unit/integration), XCUITest (UI testing)
- **Target**: First-generation iPad Pro (iOS 13.1+ maximum support)

### Architecture Pattern
- **Library-First**: Each feature implemented as standalone Swift framework
- **Offline-First**: All data stored locally, no network dependencies during gameplay
- **Performance-Optimized**: 60fps target on first-gen iPad Pro hardware

### Core Libraries
- **DungeonKit**: Dungeon and boss encounter data management
- **AbilityKit**: Boss ability classification and damage profile analysis
- **HealerUIKit**: iPad-optimized UI components for healer workflow

## Current Feature: Mythic+ Healer's Field Manual iPad Application

### Requirements Summary
- Display 8 dungeons from The War Within Season with boss encounters
- Color-coded ability cards based on damage severity (Critical/High/Moderate/Mechanic)
- Healer-specific encounter data with required actions and critical insights
- Offline functionality for use during gameplay
- Touch-optimized navigation for iPad Pro form factor
- Content updates only with major WoW patches (11.1 to 11.2)

### Performance Constraints
- < 3 second data load times on first-gen iPad Pro
- 60fps rendering performance target
- < 500MB total storage footprint
- Memory-efficient for 4GB RAM limitation

### User Stories Implemented
1. **Dungeon Selection**: Browse dungeons in organized grid/list with boss counts
2. **Boss Encounter Details**: View healer summary and color-coded ability cards
3. **Critical Ability Recognition**: Identify immediate-action abilities with visual emphasis
4. **Offline Access**: Full functionality without internet connectivity
5. **iPad Navigation**: Touch-friendly navigation between screens
6. **Major Patch Updates**: Content refresh with App Store updates

## Development Patterns

### Test-Driven Development (Constitutional Requirement)
- RED-GREEN-Refactor cycle strictly enforced
- Tests written before implementation
- Contract tests for library interfaces
- Integration tests with real CoreData stack
- Performance tests on actual iPad Pro hardware

### Library Structure
```
DungeonKit/
├── Models/ (Season, Dungeon, BossEncounter)
├── Services/ (Data access, search, caching)
├── CLI/ (Validation, import/export tools)
└── Tests/

AbilityKit/
├── Models/ (Ability, DamageProfile, Classification)
├── Services/ (Classification, analysis, prioritization)
├── CLI/ (Analysis, validation, benchmarking)
└── Tests/

HealerUIKit/
├── ViewControllers/ (Dungeon list, boss detail, search)
├── Views/ (Ability cards, navigation components)
├── CLI/ (UI validation, accessibility audit)
└── Tests/
```

### Code Quality Standards
- SwiftLint for style consistency
- 80%+ code coverage requirement
- Accessibility compliance (VoiceOver, Dynamic Type)
- Performance profiling for first-gen hardware

## Recent Changes

### Phase 0: Research Completed
- iOS compatibility strategy for first-gen iPad Pro
- UI framework selection (UIKit + SwiftUI hybrid)
- Local storage architecture (CoreData + SQLite)
- Performance optimization approach

### Phase 1: Design & Contracts Completed
- Data model with Season/Dungeon/BossEncounter/Ability entities
- Library contracts defining public interfaces
- API contracts for cross-library communication
- Quickstart guide with user story validation tests

### Current Phase: Ready for Task Generation
- Implementation plan complete through Phase 1
- All constitutional requirements validated
- Library architecture designed and documented
- Ready for /tasks command execution

## File Structure
```
specs/002-add-that-i/
├── spec.md              # Feature specification
├── plan.md              # Implementation plan (this phase)
├── research.md          # Technology research findings
├── data-model.md        # Entity relationship design
├── quickstart.md        # Development and testing guide
└── contracts/           # Library interface definitions
    ├── DungeonKit.swift
    ├── AbilityKit.swift
    └── HealerUIKit.swift
```

## Development Commands

### Library Testing
```bash
# Test individual libraries
cd DungeonKit && swift test
cd AbilityKit && swift test
cd HealerUIKit && swift test

# CLI tool testing
dungeonkit validate --format json
abilitykit analyze --boss <uuid> --format json
healeruikit benchmark --component ability-card --iterations 100
```

### Performance Validation
```bash
# iPad Pro performance testing
healeruikit validate-layouts --device ipad-pro-gen1
dungeonkit diagnose --performance
abilitykit benchmark --queries 1000

# Accessibility compliance
healeruikit accessibility-audit --output report.json
```

### Content Management
```bash
# Validate new season data
dungeonkit import --file season_data.json --validate
dungeonkit export --season active --format human
abilitykit validate --encounter <uuid>
```

## Key Constraints & Considerations

### First-Generation iPad Pro Limitations
- iOS 13.1 maximum supported version
- 4GB RAM memory constraints
- A9X processor performance limits
- Touch interface optimization requirements

### Healer-Specific Design
- Focus on damage profiles and required actions
- Color-coded visual hierarchy for quick recognition
- Critical ability emphasis for time-sensitive decisions
- Filtering out non-healer relevant information

### Content Update Strategy
- Bundle-based updates through App Store
- Major patch alignment (11.1 → 11.2)
- No real-time content synchronization
- Static data validation during import

This context provides Claude Code with comprehensive understanding of the HealerKit project architecture, current development phase, and implementation requirements.