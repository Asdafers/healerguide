# Research: Mythic+ Healer's Field Manual iPad Application

## Technical Decisions

### iOS Version Compatibility for First-Generation iPad Pro
**Decision**: Target iOS 13.1+ with Swift 5.9
**Rationale**:
- First-generation iPad Pro (Nov 2015) supports up to iOS 16.7.10
- iOS 13.1 provides SwiftUI support while maintaining broad compatibility
- Swift 5.9 provides modern language features while supporting older iOS versions
**Alternatives considered**:
- iOS 16+ (rejected: unnecessarily excludes some first-gen devices)
- Pure UIKit (rejected: more complex UI development)

### UI Framework Selection
**Decision**: UIKit + SwiftUI hybrid approach
**Rationale**:
- SwiftUI for rapid UI development and modern declarative syntax
- UIKit for performance-critical table views and complex navigation
- Hybrid approach leverages strengths of both frameworks
- Better performance on older hardware compared to pure SwiftUI
**Alternatives considered**:
- Pure SwiftUI (rejected: performance concerns on first-gen hardware)
- Pure UIKit (rejected: slower development, more boilerplate)

### Local Storage Strategy
**Decision**: CoreData with SQLite backing
**Rationale**:
- Native iOS framework with excellent offline capabilities
- Built-in relationship management for complex dungeon/boss/ability data
- Automatic data migration support for patch updates
- Memory-efficient for large datasets on constrained hardware
**Alternatives considered**:
- SQLite directly (rejected: more complex relationship management)
- JSON files (rejected: poor query performance, no relationships)
- UserDefaults (rejected: not suitable for large datasets)

### Performance Architecture for First-Gen iPad Pro
**Decision**: Lazy loading with pagination and aggressive caching
**Rationale**:
- First-gen iPad Pro has 4GB RAM and A9X processor limitations
- Large encounter datasets require memory-efficient access patterns
- Precomputed indexes for search functionality
- Image assets optimized for device resolution
**Alternatives considered**:
- Load all data at startup (rejected: memory constraints)
- Network-based data (rejected: offline requirement)

### Content Update Strategy
**Decision**: Bundle-based major patch updates through App Store
**Rationale**:
- Aligns with requirement for major patch updates only (11.1 to 11.2)
- Ensures data integrity and consistency
- Leverages App Store distribution for reliable updates
- No complex sync mechanisms needed
**Alternatives considered**:
- In-app content downloads (rejected: complexity, offline requirements)
- Frequent hotfix updates (rejected: against requirements)

### Library Architecture
**Decision**: Domain-specific Swift frameworks
**Rationale**:
- DungeonKit: Dungeon and boss data models and logic
- EncounterKit: Encounter mechanics and state management
- AbilityKit: Ability classification and damage profile logic
- HealerUIKit: Reusable iPad-optimized UI components
- Each library independently testable with CLI tools
**Alternatives considered**:
- Monolithic app structure (rejected: violates constitution)
- Single shared library (rejected: violates separation of concerns)

### Testing Strategy for iPad-Specific Features
**Decision**: Multi-layer testing with real device validation
**Rationale**:
- XCTest unit tests for business logic in each library
- XCUITest integration tests for iPad-specific gestures and layouts
- Performance tests on actual first-gen iPad Pro hardware
- Contract tests for CoreData model relationships
**Alternatives considered**:
- Simulator-only testing (rejected: hardware performance differs)
- Mock-based testing (rejected: constitutional requirement for real dependencies)

## Implementation Constraints

### Hardware Performance Boundaries
- Maximum 60fps rendering target
- < 3 second data load times from CoreData
- < 500MB total storage footprint including assets
- Touch responsiveness within 100ms on first-gen hardware

### iOS Version Limitations
- No SwiftUI 3.0+ features (requires iOS 15+)
- Limited async/await usage (requires iOS 15+)
- Must support legacy navigation patterns for iOS 13

### Content Management Constraints
- Static data bundled with app updates
- No real-time content synchronization
- Manual curation process for major patch content
- Asset optimization for older device storage speeds

## Research Validation

All technical decisions align with:
- ✅ First-generation iPad Pro hardware capabilities
- ✅ iOS 13.1+ compatibility requirements
- ✅ Offline-first operational constraints
- ✅ Major patch update cycle requirements
- ✅ Performance targets for older hardware
- ✅ Constitutional library-first architecture
- ✅ TDD testing requirements with real dependencies