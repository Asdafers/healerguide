# DungeonKit API Documentation

DungeonKit provides the core data access layer for dungeon and boss encounter information, optimized for offline healer workflows on iPad.

## Overview

DungeonKit manages all dungeon-related data using CoreData with SQLite backing, ensuring fast access to encounter information during gameplay. The library is designed for complete offline functionality with efficient caching and memory management for first-generation iPad Pro.

## Core Protocols

### DungeonDataProviding

Primary interface for accessing dungeon and boss encounter data.

```swift
protocol DungeonDataProviding {
    /// Fetch all dungeons for active season, ordered by display order
    func fetchDungeonsForActiveSeason() async throws -> [DungeonEntity]

    /// Fetch specific dungeon by ID with all boss encounters
    func fetchDungeon(id: UUID) async throws -> DungeonEntity?

    /// Search dungeons by name or short name (case-insensitive)
    func searchDungeons(query: String) async throws -> [DungeonEntity]

    /// Fetch boss encounters for dungeon, ordered by encounter order
    func fetchBossEncounters(for dungeonId: UUID) async throws -> [BossEncounterEntity]
}
```

**Performance Characteristics:**
- `fetchDungeonsForActiveSeason()`: < 100ms on first-gen iPad Pro
- `fetchDungeon(id:)`: < 50ms with CoreData optimizations
- `searchDungeons(query:)`: < 200ms with indexed search
- `fetchBossEncounters(for:)`: < 75ms with relationship preloading

### SeasonDataProviding

Manages season information and content updates.

```swift
protocol SeasonDataProviding {
    /// Get currently active season
    func getActiveSeason() async throws -> SeasonEntity?

    /// Fetch all seasons ordered by creation date
    func fetchAllSeasons() async throws -> [SeasonEntity]

    /// Update season data from major patch content bundle
    func updateSeasonData(_ seasonData: SeasonUpdateData) async throws
}
```

**Usage Pattern:**
```swift
let dataProvider = DungeonDataProvider()
let activeSeason = try await dataProvider.getActiveSeason()
let dungeons = try await dataProvider.fetchDungeonsForActiveSeason()
```

## Data Models

### DungeonEntity

Represents a complete dungeon with healer-focused metadata.

```swift
struct DungeonEntity {
    let id: UUID                        // Unique identifier
    let name: String                    // Display name (e.g., "The Stonevault")
    let shortName: String               // Abbreviation (e.g., "SV")
    let difficultyLevel: String         // Recommended keystone level
    let displayOrder: Int               // UI sorting order
    let estimatedDuration: TimeInterval // Average completion time
    let healerNotes: String?           // Healer-specific strategy notes
    let bossCount: Int                 // For UI optimization
}
```

**Healer-Specific Fields:**
- `healerNotes`: Critical insights for healers (cooldown planning, positioning tips)
- `estimatedDuration`: Helps with cooldown management planning
- `difficultyLevel`: Indicates expected healing intensity

### BossEncounterEntity

Individual boss encounter with healer summary and mechanics overview.

```swift
struct BossEncounterEntity {
    let id: UUID                    // Unique identifier
    let name: String               // Boss name
    let encounterOrder: Int        // Order within dungeon
    let healerSummary: String      // Concise healer strategy
    let difficultyRating: Int      // 1-5 scale for healer complexity
    let estimatedDuration: TimeInterval // Fight duration for planning
    let keyMechanics: [String]     // Critical mechanics names
    let abilityCount: Int          // For lazy loading decisions
}
```

**Difficulty Rating Scale:**
- 1: Minimal healing requirements, tank-and-spank
- 2: Standard damage patterns, predictable healing
- 3: Moderate complexity, some burst damage windows
- 4: High complexity, requires cooldown planning
- 5: Extreme difficulty, precise execution required

### SeasonEntity

Season metadata for content versioning and updates.

```swift
struct SeasonEntity {
    let id: UUID                    // Unique identifier
    let name: String               // Season name (e.g., "The War Within Season 1")
    let majorPatchVersion: String  // WoW patch version (e.g., "11.0.5")
    let isActive: Bool             // Currently active season
    let dungeonCount: Int          // Total dungeons in season
    let createdAt: Date           // Import timestamp
    let updatedAt: Date           // Last modification
}
```

## Update Data Structures

### SeasonUpdateData

Complete season data package for major patch updates.

```swift
struct SeasonUpdateData {
    let seasonInfo: SeasonEntity
    let dungeons: [DungeonUpdateData]
}

struct DungeonUpdateData {
    let dungeonInfo: DungeonEntity
    let bossEncounters: [BossEncounterUpdateData]
}

struct BossEncounterUpdateData {
    let encounterInfo: BossEncounterEntity
    let abilities: [AbilityUpdateData]
}

struct AbilityUpdateData {
    let id: UUID
    let name: String
    let type: String                // Damage, mechanic, heal, etc.
    let targets: String            // Tank, random, group, etc.
    let damageProfile: String      // Critical, high, moderate, mechanic
    let healerAction: String       // Required healer response
    let criticalInsight: String    // Key tactical information
    let cooldown: TimeInterval?    // Ability cooldown if applicable
    let displayOrder: Int          // UI sorting priority
    let isKeyMechanic: Bool       // Highlight for quick reference
}
```

## Error Handling

### DungeonDataError

Comprehensive error handling for data access scenarios.

```swift
enum DungeonDataError: LocalizedError {
    case noActiveSeason
    case dungeonNotFound(UUID)
    case dataCorruption(String)
    case storageError(Error)

    var errorDescription: String? {
        switch self {
        case .noActiveSeason:
            return "No active season found. Please update the app."
        case .dungeonNotFound(let id):
            return "Dungeon with ID \(id) not found."
        case .dataCorruption(let details):
            return "Data corruption detected: \(details)"
        case .storageError(let error):
            return "Storage error: \(error.localizedDescription)"
        }
    }
}
```

**Recovery Strategies:**
- `noActiveSeason`: Prompt user to update app from App Store
- `dungeonNotFound`: Refresh local data or fall back to last known good data
- `dataCorruption`: Trigger data re-import from bundle
- `storageError`: Attempt CoreData recovery or reset to defaults

## Performance Optimization

### DungeonPerformanceOptimization

Performance monitoring and optimization for iPad hardware constraints.

```swift
protocol DungeonPerformanceOptimization {
    /// Preload frequently accessed dungeons into memory
    func preloadFrequentDungeons() async

    /// Clear cache and free memory for low-memory conditions
    func clearCacheForMemoryPressure() async

    /// Get memory usage statistics for monitoring
    func getMemoryUsage() -> MemoryUsageStats
}

struct MemoryUsageStats {
    let totalCacheSize: Int64          // bytes
    let entityCount: Int               // cached entities
    let lastCacheClean: Date          // last cleanup
    let recommendedAction: CacheAction? // suggested optimization
}
```

**Optimization Strategies:**
- **Preloading**: Popular dungeons (Mythic+ meta) cached on app launch
- **Memory Management**: Automatic cleanup when iOS reports memory pressure
- **Lazy Loading**: Boss encounters and abilities loaded on-demand
- **Query Optimization**: Indexed searches with CoreData fetch request optimization

## CLI Interface

### DungeonKitCLI

Command-line tools for development, validation, and diagnostics.

```swift
protocol DungeonKitCLI {
    /// Validate dungeon data integrity
    func validate(format: OutputFormat) async -> CLIResult

    /// Import dungeon data from bundle
    func importData(file: URL, validate: Bool) async -> CLIResult

    /// Export current dungeon data
    func exportData(season: String, format: OutputFormat) async -> CLIResult

    /// Performance diagnostics
    func diagnose(performance: Bool) async -> CLIResult
}
```

### CLI Commands

#### Data Validation
```bash
# Comprehensive data validation
dungeonkit validate --format json

# Sample output:
{
  "success": true,
  "validationResults": {
    "dungeons": 8,
    "bossEncounters": 32,
    "abilities": 156,
    "errors": [],
    "warnings": ["Missing healer notes for 2 dungeons"],
    "performance": {
      "queryTime": "45ms",
      "memoryUsage": "12MB"
    }
  }
}
```

#### Data Import/Export
```bash
# Import new season data with validation
dungeonkit import --file /path/to/season_11_1.json --validate

# Export active season for backup or analysis
dungeonkit export --season active --format human
dungeonkit export --season active --format csv --output dungeons.csv
```

#### Performance Diagnostics
```bash
# Performance analysis
dungeonkit diagnose --performance

# Sample output:
Performance Diagnostics:
- Average query time: 67ms
- Cache hit rate: 94%
- Memory usage: 18.2MB / 128MB allocated
- Recommendation: Preload 3 additional frequent dungeons
- Bottlenecks: BossEncounter relationship queries (12ms avg)
```

## Integration Examples

### Basic Usage Pattern

```swift
import DungeonKit

class HealerDungeonService {
    private let dataProvider: DungeonDataProviding
    private let performanceOptimizer: DungeonPerformanceOptimization

    init() {
        self.dataProvider = DungeonDataProvider()
        self.performanceOptimizer = DungeonPerformanceOptimizer()

        // Preload for optimal performance
        Task {
            await performanceOptimizer.preloadFrequentDungeons()
        }
    }

    func loadHealerDashboard() async throws -> HealerDashboardData {
        let dungeons = try await dataProvider.fetchDungeonsForActiveSeason()

        // Filter to current Mythic+ rotation or user preferences
        let activeDungeons = dungeons.filter { dungeon in
            // Apply healer-specific filtering logic
            return dungeon.difficultyLevel != "N/A"
        }

        return HealerDashboardData(
            dungeons: activeDungeons,
            season: try await dataProvider.getActiveSeason()
        )
    }
}
```

### Memory Management

```swift
class MemoryAwareDungeonCache {
    private let dataProvider: DungeonDataProviding
    private let performanceOptimizer: DungeonPerformanceOptimization

    init(dataProvider: DungeonDataProviding,
         performanceOptimizer: DungeonPerformanceOptimization) {
        self.dataProvider = dataProvider
        self.performanceOptimizer = performanceOptimizer

        // Monitor memory warnings
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleMemoryPressure),
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )
    }

    @objc private func handleMemoryPressure() {
        Task {
            await performanceOptimizer.clearCacheForMemoryPressure()
        }
    }
}
```

## Best Practices

### 1. Efficient Data Loading
```swift
// ✅ Good: Load dungeons first, then boss encounters on-demand
let dungeons = try await dataProvider.fetchDungeonsForActiveSeason()
// Load encounters only when user selects dungeon
let encounters = try await dataProvider.fetchBossEncounters(for: selectedDungeon.id)

// ❌ Avoid: Loading all data upfront
// This can exceed memory limits on first-gen iPad Pro
```

### 2. Search Optimization
```swift
// ✅ Good: Use debounced search with minimum query length
func search(query: String) async {
    guard query.count >= 2 else { return }

    // Debounce rapid typing
    try? await Task.sleep(nanoseconds: 300_000_000) // 300ms

    let results = try await dataProvider.searchDungeons(query: query)
    await updateUI(with: results)
}
```

### 3. Error Recovery
```swift
// ✅ Good: Graceful degradation with fallback data
func loadDungeons() async {
    do {
        let dungeons = try await dataProvider.fetchDungeonsForActiveSeason()
        await updateUI(with: dungeons)
    } catch DungeonDataError.noActiveSeason {
        // Show update prompt with cached data if available
        await showUpdatePromptWithFallback()
    } catch {
        // Log error and show offline mode
        logger.error("Dungeon loading failed: \(error)")
        await showOfflineMode()
    }
}
```

## Testing

### Unit Testing
```swift
class DungeonDataProviderTests: XCTestCase {
    var dataProvider: DungeonDataProviding!
    var testContext: NSManagedObjectContext!

    override func setUp() {
        super.setUp()
        // Use in-memory Core Data for testing
        testContext = createInMemoryContext()
        dataProvider = DungeonDataProvider(context: testContext)
    }

    func testFetchDungeonsPerformance() async {
        // Measure performance on simulated first-gen iPad Pro
        let startTime = CFAbsoluteTimeGetCurrent()
        let dungeons = try await dataProvider.fetchDungeonsForActiveSeason()
        let duration = CFAbsoluteTimeGetCurrent() - startTime

        XCTAssertLessThan(duration, 0.1, "Dungeon loading should be under 100ms")
        XCTAssertFalse(dungeons.isEmpty, "Should return dungeons for active season")
    }
}
```

### CLI Testing
```bash
# Automated testing in CI/CD
dungeonkit validate --format json | jq '.success' # Should return true
dungeonkit diagnose --performance | grep "query time" # Should be < 100ms
```

## Migration and Updates

### Season Data Updates
```swift
// Handle major patch updates (11.0 -> 11.1)
func updateToNewSeason(_ newSeasonData: SeasonUpdateData) async throws {
    // Validate new data first
    let validationResult = try await validateSeasonData(newSeasonData)
    guard validationResult.isValid else {
        throw DungeonDataError.dataCorruption(validationResult.summary)
    }

    // Backup current data
    let backup = try await exportCurrentSeason()

    do {
        // Import new season
        try await dataProvider.updateSeasonData(newSeasonData)

        // Clear caches to ensure fresh data
        await performanceOptimizer.clearCacheForMemoryPressure()

        // Preload popular dungeons
        await performanceOptimizer.preloadFrequentDungeons()

    } catch {
        // Restore from backup if update fails
        try await restoreFromBackup(backup)
        throw error
    }
}
```

This API provides the foundation for all dungeon and encounter data access in HealerKit, optimized specifically for iPad healer workflows with comprehensive performance monitoring and error handling.