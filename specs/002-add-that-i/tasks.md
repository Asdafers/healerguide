# Tasks: Mythic+ Healer's Field Manual iPad Application

**Input**: Design documents from `/specs/002-add-that-i/`
**Prerequisites**: plan.md (✓), research.md (✓), data-model.md (✓), contracts/ (✓), quickstart.md (✓)

## Execution Flow (main)
```
1. Load plan.md from feature directory ✓
   → Extracted: Swift 5.9, UIKit/SwiftUI, CoreData, iOS 13.1+, iPad Pro target
   → Libraries: DungeonKit, AbilityKit, HealerUIKit
2. Load optional design documents ✓:
   → data-model.md: Season, Dungeon, BossEncounter, BossAbility entities
   → contracts/: DungeonKit.swift, AbilityKit.swift, HealerUIKit.swift
   → quickstart.md: 6 user stories, performance tests, CLI commands
3. Generate tasks by category ✓
4. Apply task rules ✓
5. Number tasks sequentially (T001, T002...) ✓
6. Generate dependency graph ✓
7. Create parallel execution examples ✓
8. Validate task completeness ✓
9. Return: SUCCESS (tasks ready for execution)
```

## Format: `[ID] [P?] Description`
- **[P]**: Can run in parallel (different files, no dependencies)
- Include exact file paths in descriptions

## Path Conventions
- **Mobile project**: `ios/` for iOS-specific code, libraries as Swift frameworks
- **Test organization**: Framework-specific test targets
- Paths assume iOS project structure per plan.md

## Phase 3.1: Setup

### T001 Create iOS project structure per implementation plan
Create Xcode project `HealerKit.xcodeproj` with:
- iOS deployment target 13.1 (first-gen iPad Pro support)
- Swift 5.9 configuration
- Library targets: DungeonKit, AbilityKit, HealerUIKit
- Main app target: HealerKit (iPad)
- Test targets for each library and main app
- CoreData model file: `HealerKit.xcdatamodeld`

### T002 Configure project dependencies and build settings
- Set up library dependencies (DungeonKit → AbilityKit → HealerUIKit → HealerKit app)
- Configure build settings for iOS 13.1+ compatibility
- Set up signing and provisioning for iPad development
- Configure Info.plist for iPad-specific settings (orientations, device family)

### T003 [P] Configure development tools and project standards
- Set up SwiftLint configuration in `.swiftlint.yml`
- Configure Xcode project settings for consistent formatting
- Set up build schemes for each library and main app
- Configure test coverage reporting

## Phase 3.2: Tests First (TDD) ⚠️ MUST COMPLETE BEFORE 3.3
**CRITICAL: These tests MUST be written and MUST FAIL before ANY implementation**

### T004 [P] Contract test for DungeonDataProviding in DungeonKitTests/ContractTests.swift
Test all methods from DungeonKit contract:
- `fetchDungeonsForActiveSeason()` → fails with "not implemented"
- `fetchDungeon(id:)` → fails with "not implemented"
- `searchDungeons(query:)` → fails with "not implemented"
- `fetchBossEncounters(for:)` → fails with "not implemented"

### T005 [P] Contract test for AbilityDataProviding in AbilityKitTests/ContractTests.swift
Test all methods from AbilityKit contract:
- `fetchAbilities(for:)` → fails with "not implemented"
- `searchAbilities(query:)` → fails with "not implemented"
- `fetchAbilities(for:damageProfile:)` → fails with "not implemented"
- `fetchKeyMechanics(for:)` → fails with "not implemented"

### T006 [P] Contract test for HealerDisplayProviding in HealerUIKitTests/ContractTests.swift
Test all methods from HealerUIKit contract:
- `createDungeonListView(dungeons:)` → fails with "not implemented"
- `createBossEncounterView(encounter:abilities:)` → fails with "not implemented"
- `createSearchView(delegate:)` → fails with "not implemented"
- `createSettingsView()` → fails with "not implemented"

### T007 [P] Integration test for dungeon selection user story in HealerKitTests/IntegrationTests.swift
Test story: "I select Ara-Kara dungeon and see boss list in chronological order"
- Create mock season data with Ara-Kara dungeon
- Test dungeon selection flow through UI
- Verify boss encounters appear in correct order
- MUST FAIL before implementation

### T008 [P] Integration test for boss encounter detail user story in HealerKitTests/IntegrationTests.swift
Test story: "I select Avanoxx boss and see healer summary with color-coded ability cards"
- Create mock boss encounter data for Avanoxx
- Test boss detail view display
- Verify healer summary and ability cards render
- Verify color coding by damage profile
- MUST FAIL before implementation

### T009 [P] Integration test for critical ability recognition user story in HealerKitTests/IntegrationTests.swift
Test story: "I view Alerting Shrill ability card and see Critical damage profile with healing guidance"
- Create mock critical ability data
- Test ability card display and classification
- Verify critical damage profile visual treatment
- MUST FAIL before implementation

### T010 [P] Integration test for offline functionality user story in HealerKitTests/IntegrationTests.swift
Test story: "I open app without internet connection and access all dungeon data"
- Simulate network disconnection
- Test full app functionality offline
- Verify all data accessible from CoreData
- MUST FAIL before implementation

### T011 [P] Integration test for iPad navigation user story in HealerKitTests/iPadNavigationTests.swift
Test story: "I navigate between dungeon list, boss detail, and home screens with iPad-optimized controls"
- Test split view controller navigation
- Verify touch targets meet 44pt minimum
- Test portrait and landscape orientations
- MUST FAIL before implementation

### T012 [P] Performance test for first-gen iPad Pro targets in HealerKitTests/PerformanceTests.swift
Test performance requirements:
- 60fps rendering during scroll operations
- < 3 second data load times from CoreData
- < 500MB memory footprint with full season data
- MUST FAIL before implementation

## Phase 3.3: Core Implementation (ONLY after tests are failing)

### T013 [P] Season entity model in DungeonKit/Models/Season.swift
Implement CoreData entity for Season:
- Properties: id, name, majorPatchVersion, isActive, createdAt, updatedAt
- Relationships: one-to-many with Dungeon
- Validation rules per data-model.md
- CoreData entity mapping

### T014 [P] Dungeon entity model in DungeonKit/Models/Dungeon.swift
Implement CoreData entity for Dungeon:
- Properties: id, name, shortName, difficultyLevel, displayOrder, estimatedDuration, healerNotes
- Relationships: many-to-one with Season, one-to-many with BossEncounter
- Validation rules per data-model.md
- CoreData entity mapping

### T015 [P] BossEncounter entity model in DungeonKit/Models/BossEncounter.swift
Implement CoreData entity for BossEncounter:
- Properties: id, name, encounterOrder, healerSummary, difficultyRating, estimatedDuration, keyMechanics
- Relationships: many-to-one with Dungeon, one-to-many with BossAbility
- Validation rules per data-model.md
- CoreData entity mapping

### T016 [P] BossAbility entity model in AbilityKit/Models/BossAbility.swift
Implement CoreData entity for BossAbility:
- Properties: id, name, type, targets, damageProfile, healerAction, criticalInsight, cooldown, displayOrder, isKeyMechanic
- Relationships: many-to-one with BossEncounter
- Validation rules per data-model.md
- CoreData entity mapping

### T017 CoreData model setup in HealerKit/HealerKit.xcdatamodeld
Configure CoreData model file:
- Define all entities with attributes and relationships
- Set up entity inheritance if needed
- Configure fetch request templates
- Set up lightweight migration options

### T018 [P] DungeonDataProvider service in DungeonKit/Services/DungeonDataProvider.swift
Implement DungeonDataProviding protocol:
- CoreData stack integration
- Fetch operations with error handling
- Search functionality with case-insensitive matching
- Performance optimization for iPad memory constraints

### T019 [P] SeasonDataProvider service in DungeonKit/Services/SeasonDataProvider.swift
Implement SeasonDataProviding protocol:
- Active season management
- Season data import from major patch updates
- CoreData operations with proper error handling
- Validation during season updates

### T020 [P] AbilityDataProvider service in AbilityKit/Services/AbilityDataProvider.swift
Implement AbilityDataProviding protocol:
- Boss ability queries with damage profile filtering
- Key mechanics extraction
- Search across all encounters
- Memory-efficient lazy loading

### T021 [P] AbilityClassificationService in AbilityKit/Services/AbilityClassificationService.swift
Implement AbilityClassificationService protocol:
- Ability impact analysis for healers
- Damage profile classification logic
- Recommended healer actions
- Validation for healer relevance

### T022 [P] DamageProfileAnalyzer service in AbilityKit/Services/DamageProfileAnalyzer.swift
Implement DamageProfileAnalyzer protocol:
- Encounter damage pattern analysis
- UI color scheme generation for damage profiles
- Ability prioritization for healer attention
- Performance metrics for encounter planning

### T023 [P] DungeonListViewController in HealerUIKit/ViewControllers/DungeonListViewController.swift
Implement DungeonListViewControllerProtocol:
- iPad-optimized grid/list layout
- Touch-friendly dungeon selection
- Search integration
- Portrait/landscape orientation support

### T024 [P] BossEncounterViewController in HealerUIKit/ViewControllers/BossEncounterViewController.swift
Implement BossEncounterViewControllerProtocol:
- Boss encounter detail display
- Healer summary presentation
- Ability card collection view
- Damage profile filtering

### T025 [P] AbilityCardView in HealerUIKit/Views/AbilityCardView.swift
Implement AbilityCardViewProtocol:
- Color-coded ability cards based on damage profile
- Touch-optimized sizing for iPad
- Critical ability attention animations
- Compact and full display modes

### T026 Navigation controller setup in HealerUIKit/Navigation/MainNavigationController.swift
Implement iPad split view navigation:
- Master/detail split view controller
- Breadcrumb navigation for deep linking
- Quick action toolbar for healer tasks
- Proper iPad multi-tasking support

## Phase 3.4: Integration

### T027 CoreData stack initialization in HealerKit/CoreData/CoreDataStack.swift
Set up CoreData persistence:
- NSPersistentContainer configuration
- Migration handling for major patch updates
- Error handling for data corruption
- Memory management for first-gen iPad Pro

### T028 DungeonKit CLI commands in DungeonKit/CLI/DungeonKitCLI.swift
Implement CLI interface per contract:
- `dungeonkit validate --format json`
- `dungeonkit import --file season_data.json --validate`
- `dungeonkit export --season active --format human`
- `dungeonkit diagnose --performance`

### T029 AbilityKit CLI commands in AbilityKit/CLI/AbilityKitCLI.swift
Implement CLI interface per contract:
- `abilitykit analyze --boss <uuid> --format json`
- `abilitykit validate --encounter <uuid>`
- `abilitykit benchmark --queries 1000`
- `abilitykit export --format csv --damage-profile critical`

### T030 HealerUIKit CLI commands in HealerUIKit/CLI/HealerUIKitCLI.swift
Implement CLI interface per contract:
- `healeruikit benchmark --component ability-card --iterations 100`
- `healeruikit validate-layouts --device ipad-pro-gen1`
- `healeruikit accessibility-audit --output report.json`
- `healeruikit test-colors --standard wcag-aa`

### T031 App configuration and settings in HealerKit/Configuration/AppConfiguration.swift
Configure iPad-specific settings:
- Typography settings for tablet readability
- Color schemes for damage profiles
- Layout settings for different orientations
- Accessibility settings and Dynamic Type support

### T032 Performance optimization for first-gen iPad Pro in HealerKit/Performance/PerformanceManager.swift
Implement performance management:
- Memory pressure handling
- View caching strategies
- Lazy loading optimization
- Frame rate monitoring and optimization

## Phase 3.5: Polish

### T033 [P] Unit tests for Season model in DungeonKitTests/ModelTests/SeasonTests.swift
Comprehensive unit tests for Season entity:
- Validation rule testing
- Relationship integrity
- CoreData mapping verification
- Edge case handling

### T034 [P] Unit tests for Dungeon model in DungeonKitTests/ModelTests/DungeonTests.swift
Comprehensive unit tests for Dungeon entity:
- Validation rule testing
- Relationship integrity with Season and BossEncounter
- Display order validation
- Short name constraints

### T035 [P] Unit tests for BossEncounter model in DungeonKitTests/ModelTests/BossEncounterTests.swift
Comprehensive unit tests for BossEncounter entity:
- Healer summary validation
- Key mechanics constraints
- Difficulty rating validation
- Relationship integrity

### T036 [P] Unit tests for BossAbility model in AbilityKitTests/ModelTests/BossAbilityTests.swift
Comprehensive unit tests for BossAbility entity:
- Damage profile validation
- Healer action constraints
- Critical insight validation
- Display order and key mechanic logic

### T037 [P] Unit tests for ability classification in AbilityKitTests/ServiceTests/ClassificationServiceTests.swift
Test ability classification logic:
- Damage profile impact analysis
- Healer action recommendations
- Urgency level calculation
- Complexity assessment

### T038 [P] Unit tests for UI components in HealerUIKitTests/ViewTests/ComponentTests.swift
Test iPad UI components:
- Touch target sizing (44pt minimum)
- Color contrast ratios for accessibility
- Dynamic Type support
- Orientation change handling

### T039 [P] Accessibility audit and compliance in HealerKitTests/AccessibilityTests.swift
Comprehensive accessibility testing:
- VoiceOver compatibility
- Dynamic Type support across all text
- Color blind friendly alternatives
- Keyboard navigation support

### T040 Performance validation on actual hardware in HealerKitTests/HardwarePerformanceTests.swift
Real device testing:
- 60fps validation during scrolling
- Memory usage under 500MB constraint
- 3-second load time validation
- Battery usage optimization

### T041 [P] Generate sample season data in HealerKit/SampleData/SeasonDataGenerator.swift
Create realistic test data:
- The War Within Season 3.1 dungeons
- Complete boss encounters with abilities
- Proper damage profile distribution
- Healer-focused content filtering

### T042 [P] Update documentation in docs/
Create comprehensive documentation:
- API documentation for all library interfaces
- iPad-specific usage guidelines
- Performance optimization guide
- Healer workflow documentation

### T043 Code quality and optimization review
Final code review and cleanup:
- SwiftLint compliance across all targets
- Remove code duplication
- Optimize performance bottlenecks identified in testing
- Ensure constitutional compliance (library-first, TDD, CLI interfaces)

## Dependencies

### Critical Path Dependencies
- **Setup (T001-T003)** blocks everything else
- **Tests (T004-T012)** MUST complete and FAIL before implementation (T013-T032)
- **Models (T013-T017)** block services (T018-T022)
- **Services (T018-T022)** block UI implementation (T023-T026)
- **Core Implementation (T013-T026)** blocks integration (T027-T032)
- **Integration (T027-T032)** blocks polish (T033-T043)

### Specific Dependencies
- T017 (CoreData model) blocks T018-T022 (services using CoreData)
- T018-T022 (services) block T023-T026 (UI using services)
- T027 (CoreData stack) required for T028-T030 (CLI testing with real data)
- T013-T016 (entities) required for T033-T036 (unit tests)

## Parallel Execution Examples

### Launch Contract Tests Together (T004-T006):
```
Task: "Contract test for DungeonDataProviding in DungeonKitTests/ContractTests.swift"
Task: "Contract test for AbilityDataProviding in AbilityKitTests/ContractTests.swift"
Task: "Contract test for HealerDisplayProviding in HealerUIKitTests/ContractTests.swift"
```

### Launch Integration Tests Together (T007-T012):
```
Task: "Integration test for dungeon selection user story in HealerKitTests/IntegrationTests.swift"
Task: "Integration test for boss encounter detail user story in HealerKitTests/IntegrationTests.swift"
Task: "Integration test for critical ability recognition user story in HealerKitTests/IntegrationTests.swift"
Task: "Integration test for offline functionality user story in HealerKitTests/IntegrationTests.swift"
Task: "Integration test for iPad navigation user story in HealerKitTests/iPadNavigationTests.swift"
Task: "Performance test for first-gen iPad Pro targets in HealerKitTests/PerformanceTests.swift"
```

### Launch Entity Models Together (T013-T016):
```
Task: "Season entity model in DungeonKit/Models/Season.swift"
Task: "Dungeon entity model in DungeonKit/Models/Dungeon.swift"
Task: "BossEncounter entity model in DungeonKit/Models/BossEncounter.swift"
Task: "BossAbility entity model in AbilityKit/Models/BossAbility.swift"
```

### Launch UI Components Together (T023-T025):
```
Task: "DungeonListViewController in HealerUIKit/ViewControllers/DungeonListViewController.swift"
Task: "BossEncounterViewController in HealerUIKit/ViewControllers/BossEncounterViewController.swift"
Task: "AbilityCardView in HealerUIKit/Views/AbilityCardView.swift"
```

## Validation Checklist

**Contract Coverage**:
- [✓] DungeonKit.swift → T004 (contract test) + T018-T019 (implementation)
- [✓] AbilityKit.swift → T005 (contract test) + T020-T022 (implementation)
- [✓] HealerUIKit.swift → T006 (contract test) + T023-T026 (implementation)

**Entity Coverage**:
- [✓] Season → T013 (model) + T033 (tests)
- [✓] Dungeon → T014 (model) + T034 (tests)
- [✓] BossEncounter → T015 (model) + T035 (tests)
- [✓] BossAbility → T016 (model) + T036 (tests)

**User Story Coverage**:
- [✓] Dungeon selection → T007 (integration test) + T023 (implementation)
- [✓] Boss encounter detail → T008 (integration test) + T024 (implementation)
- [✓] Critical ability recognition → T009 (integration test) + T025 (implementation)
- [✓] Offline functionality → T010 (integration test) + T027 (CoreData implementation)
- [✓] iPad navigation → T011 (integration test) + T026 (navigation implementation)
- [✓] Performance targets → T012 (performance test) + T032 (optimization)

**Constitutional Compliance**:
- [✓] Library-first architecture: DungeonKit, AbilityKit, HealerUIKit targets
- [✓] CLI interfaces: T028-T030 implement CLI for each library
- [✓] TDD enforced: All tests (T004-T012) before implementation (T013-T032)
- [✓] Real dependencies: T027 uses actual CoreData, T040 uses real iPad hardware

## Notes
- **[P] tasks** represent different files with no dependencies - safe for parallel execution
- **Verify all tests fail** before implementing features (constitutional TDD requirement)
- **Commit after each task** to maintain development history
- **iPad-specific considerations** included in every UI-related task
- **Performance constraints** for first-gen iPad Pro considered throughout