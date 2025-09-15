# Quickstart: Mythic+ Healer's Field Manual iPad Application

## Development Environment Setup

### Prerequisites
- Xcode 14.0+ (for Swift 5.9 support)
- iOS Simulator with iPad Pro (12.9-inch) 1st generation
- First-generation iPad Pro hardware for performance testing
- macOS 13.0+ (for Xcode compatibility)

### Initial Project Setup
```bash
# Clone and setup project
git clone <repository-url>
cd healerkit

# Install dependencies (if any)
# Note: Using native iOS frameworks, minimal external dependencies

# Open in Xcode
open HealerKit.xcodeproj
```

## Core Library Architecture

### DungeonKit Library
**Purpose**: Manage dungeon and boss encounter data
```bash
# Test DungeonKit functionality
cd DungeonKit
swift test

# CLI usage examples
dungeonkit validate --format json
dungeonkit import --file sample_season.json --validate
dungeonkit export --season active --format human
```

### AbilityKit Library
**Purpose**: Boss ability classification and damage profile analysis
```bash
# Test AbilityKit functionality
cd AbilityKit
swift test

# CLI usage examples
abilitykit analyze --boss <uuid> --format json
abilitykit validate --encounter <uuid>
abilitykit benchmark --queries 1000
```

### HealerUIKit Library
**Purpose**: iPad-optimized UI components for healer workflow
```bash
# Test HealerUIKit functionality
cd HealerUIKit
swift test

# CLI usage examples
healeruikit benchmark --component ability-card --iterations 100
healeruikit validate-layouts --device ipad-pro-gen1
healeruikit accessibility-audit --output accessibility_report.json
```

## User Story Validation Tests

### Story 1: Dungeon Selection on iPad Pro
**Given**: I am about to enter "Ara-Kara, City of Echoes" dungeon
**When**: I open the app on my first-generation iPad Pro and select this dungeon
**Then**: I see a list of all bosses in chronological encounter order

**Test Execution**:
```swift
// Integration test in DungeonKitTests
func testDungeonSelectionFlow() async {
    let dungeons = try await dungeonProvider.fetchDungeonsForActiveSeason()
    let araKara = dungeons.first { $0.name == "Ara-Kara, City of Echoes" }
    XCTAssertNotNil(araKara)

    let bosses = try await dungeonProvider.fetchBossEncounters(for: araKara!.id)
    XCTAssertFalse(bosses.isEmpty)
    XCTAssertEqual(bosses.sorted(by: { $0.encounterOrder < $1.encounterOrder }), bosses)
}
```

### Story 2: Boss Encounter Detail Display
**Given**: I select the "Avanoxx" boss encounter
**When**: The boss details load
**Then**: I see healer summary and color-coded ability cards

**Test Execution**:
```swift
// UI test in HealerUIKitTests
func testBossEncounterDisplay() {
    app.tables.cells.containing(.staticText, identifier: "Avanoxx").tap()

    XCTAssertTrue(app.staticTexts["healerSummary"].exists)
    XCTAssertTrue(app.collectionViews["abilityCards"].exists)

    // Verify color coding exists
    let criticalCards = app.collectionViews.cells.matching(NSPredicate(format: "identifier CONTAINS 'critical'"))
    XCTAssertGreaterThan(criticalCards.count, 0)
}
```

### Story 3: Critical Ability Recognition
**Given**: I view an ability card for "Alerting Shrill"
**When**: The card displays
**Then**: I see it's Critical damage profile with pre-planned group healing guidance

**Test Execution**:
```swift
// Unit test in AbilityKitTests
func testCriticalAbilityClassification() {
    let alertingShrill = AbilityEntity(
        name: "Alerting Shrill",
        damageProfile: .critical,
        // ... other properties
    )

    let classification = classificationService.classifyAbility(alertingShrill)
    XCTAssertEqual(classification.urgency, .immediate)
    XCTAssertEqual(classification.healerImpact, .critical)
}
```

### Story 4: Offline Functionality
**Given**: I have no internet connection during gameplay
**When**: I open the app
**Then**: All dungeon and encounter data is available offline

**Test Execution**:
```swift
// Integration test for offline capability
func testOfflineDataAccess() {
    // Simulate no network connectivity
    networkSimulator.disableNetwork()

    let dungeons = try await dungeonProvider.fetchDungeonsForActiveSeason()
    XCTAssertFalse(dungeons.isEmpty)

    let firstDungeon = dungeons[0]
    let bosses = try await dungeonProvider.fetchBossEncounters(for: firstDungeon.id)
    XCTAssertFalse(bosses.isEmpty)
}
```

### Story 5: iPad Navigation
**Given**: I want to return to the dungeon list
**When**: I use the navigation
**Then**: I can easily move between boss, dungeon, and home screens

**Test Execution**:
```swift
// UI navigation test
func testIPadNavigationFlow() {
    // Start at dungeon list
    XCTAssertTrue(app.navigationBars["Dungeons"].exists)

    // Navigate to boss
    app.tables.cells.firstMatch.tap()
    app.tables.cells.firstMatch.tap()
    XCTAssertTrue(app.navigationBars.element.identifier.contains("Boss"))

    // Navigate back via breadcrumb or back button
    app.navigationBars.buttons.element(boundBy: 0).tap()
    XCTAssertTrue(app.navigationBars.element.identifier.contains("Dungeon"))
}
```

### Story 6: Major Patch Updates
**Given**: A new major patch is released (e.g., 11.1 to 11.2)
**When**: I open the app after the update
**Then**: I see refreshed dungeon content reflecting mechanical changes

**Test Execution**:
```bash
# CLI test for content updates
dungeonkit import --file patch_11_2_data.json --validate
dungeonkit validate --format json

# Verify new season is active
echo "Checking active season after patch update..."
dungeonkit export --season active --format human | grep "11.2"
```

## Performance Validation on First-Gen iPad Pro

### Frame Rate Testing
```swift
// Performance test for 60fps target
func testFrameRatePerformance() {
    measure(metrics: [XCTCPUMetric(), XCTMemoryMetric()]) {
        // Simulate scrolling through ability list
        app.collectionViews.firstMatch.swipeUp()
        app.collectionViews.firstMatch.swipeDown()
    }
}
```

### Memory Usage Testing
```swift
// Test memory constraints (<500MB total)
func testMemoryFootprint() {
    let initialMemory = getMemoryUsage()

    // Load all season data
    loadAllSeasonData()

    let peakMemory = getMemoryUsage()
    XCTAssertLessThan(peakMemory - initialMemory, 500_000_000) // 500MB
}
```

### Data Load Time Testing
```swift
// Test 3-second load time target
func testDataLoadPerformance() {
    measure(metrics: [XCTClockMetric()]) {
        _ = try await dungeonProvider.fetchDungeonsForActiveSeason()
    }

    // Verify last measurement is under 3 seconds
    XCTAssertLessThan(lastMeasurement, 3.0)
}
```

## Development Workflow

### 1. Test-Driven Development (Constitutional Requirement)
```bash
# Write failing test first
swift test  # Should fail initially

# Implement feature to make test pass
# Implementation goes in respective library

# Verify test passes
swift test  # Should pass after implementation
```

### 2. Library-First Development
- Each feature starts as a standalone library
- Libraries must have CLI interfaces for testing
- Cross-library dependencies managed through contracts

### 3. iPad-Specific Testing
- Always test on actual first-generation iPad Pro hardware
- Validate performance under iOS 13.1 constraints
- Test both portrait and landscape orientations

### 4. Content Validation Pipeline
```bash
# Validate new dungeon content before integration
dungeonkit validate --file new_content.json
abilitykit validate --encounter <uuid>

# Performance impact assessment
healeruikit benchmark --component dungeon-list --device ipad-pro-gen1
```

## Common Issues & Solutions

### Issue: SwiftUI performance on first-gen hardware
**Solution**: Use UIKit for performance-critical views, SwiftUI for simple interfaces

### Issue: CoreData migration failures
**Solution**: Implement incremental migration strategies, maintain backward compatibility

### Issue: Memory pressure on older hardware
**Solution**: Implement aggressive caching strategies, lazy loading for ability data

### Issue: Touch targets too small for iPad
**Solution**: Minimum 44pt touch targets, optimized spacing for finger navigation

## Quick Commands Reference

```bash
# Development
swift test                           # Run all tests
swift build --configuration release  # Optimized build

# Content Management
dungeonkit import --file season.json --validate
abilitykit analyze --boss <id> --format json
healeruikit validate-layouts --device ipad-pro-gen1

# Performance Testing
healeruikit benchmark --component ability-card --iterations 100
dungeonkit diagnose --performance

# Deployment Preparation
healeruikit accessibility-audit --output report.json
swift test --enable-code-coverage    # Generate coverage report
```

This quickstart provides:
- ✅ Immediate development environment setup
- ✅ User story validation through executable tests
- ✅ Performance validation for first-gen iPad Pro
- ✅ TDD workflow aligned with constitutional requirements
- ✅ Library-first architecture validation
- ✅ Real device testing procedures