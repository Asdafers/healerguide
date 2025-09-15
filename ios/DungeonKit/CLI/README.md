# DungeonKit CLI Tools

Command-line interface tools for DungeonKit - World of Warcraft Mythic+ healer data management.

## Installation

```bash
cd DungeonKit/CLI
swift build -c release
```

## Commands

### Validate

Validate dungeon data integrity, check relationships, and verify healer content:

```bash
# JSON output (default)
dungeonkit validate --format json

# Human-readable output
dungeonkit validate --format human

# CSV output
dungeonkit validate --format csv
```

**Example Output (human format):**
```
🔍 DungeonKit Validation Report
==================================================
Status: ✅ Valid
Execution Time: 0.12s
Timestamp: Sep 15, 2025 at 10:45 AM

📊 Statistics:
- Total Seasons: 1
- Total Dungeons: 8
- Total Boss Encounters: 28
- Active Season: The War Within Season 1

✅ All validation checks passed
```

### Import

Import dungeon data from major patch updates with validation:

```bash
# Basic import
dungeonkit import --file season_data.json

# Import with validation
dungeonkit import --file season_data.json --validate
```

**Example Output:**
```
🔄 Importing dungeon data from: season_data.json
🔍 Validation enabled - performing integrity checks...
✅ Import completed successfully!
📁 File: season_data.json
📊 Imported: 1 seasons, 8 dungeons, 28 encounters
⏱️ Execution Time: 0.34s
```

### Export

Export current season data in specified format:

```bash
# Export active season (human-readable)
dungeonkit export --season active --format human

# Export all seasons as JSON
dungeonkit export --season all --format json

# Export as CSV
dungeonkit export --season active --format csv
```

**Example Output (human format):**
```
# The War Within Season 1 (Patch 11.0)
Status: Active
Dungeons: 8
Created: Sep 15, 2025
Updated: Sep 15, 2025

## Dungeons

### The Stonevault (SV)
- Difficulty: Mythic+
- Duration: 30 minutes
- Bosses: 4
- Display Order: 1
- Healer Notes: High sustained damage throughout. Be ready for dispels on trash packs.

### Ara-Kara, City of Echoes (AK)
- Difficulty: Mythic+
- Duration: 28 minutes
- Bosses: 3
- Display Order: 2
- Healer Notes: Web mechanics require positioning awareness. Heavy DoT damage on several encounters.
```

### Diagnose

Performance diagnostics for CoreData operations and memory usage:

```bash
# Standard diagnostics
dungeonkit diagnose

# Detailed performance analysis
dungeonkit diagnose --performance
```

**Example Output:**
```
🔍 DungeonKit Performance Diagnostics
==================================================
Overall Status: ✅ Healthy
Analysis Level: Detailed
Execution Time: 2.15s

📊 Memory Usage:
- Current: 156 MB
- Peak: 198 MB
- Within iPad Pro Limits: ✅

⚡ Query Performance:
- Average Query Time: 0.045s
- Slowest Query: 0.089s
- Total Queries Tested: 200
- Performance Target Met: ✅

🎯 Cache Efficiency:
- Hit Rate: 85.0%
- Miss Rate: 15.0%
- Efficiency Target Met: ✅

💡 Recommendations:
  • All systems performing within optimal parameters
  • Cache hit rate exceeds target efficiency
```

## Sample Data

A sample season data file (`sample_season_data.json`) is provided with The War Within Season 1 data including:

- 8 Mythic+ dungeons
- 28+ boss encounters with healer-specific information
- Ability data with damage profiles and healer actions
- Proper data structure for testing import functionality

## Error Handling

The CLI provides comprehensive error handling:

- **Exit Code 0**: Success
- **Exit Code 1**: General failure (validation failed, import error, etc.)
- **Exit Code 2**: Warning (performance issues detected)

## Integration with HealerKit

The CLI tools integrate with the main DungeonKit library services:

- **DungeonDataProvider**: For dungeon and boss encounter operations
- **SeasonDataProvider**: For season management and updates
- **CoreData Stack**: In-memory database for CLI operations

## Performance Targets

Optimized for first-generation iPad Pro constraints:

- **Memory Usage**: < 500MB total footprint
- **Query Performance**: < 100ms average query time
- **Cache Efficiency**: > 80% hit rate target
- **Load Times**: < 3 seconds for full season data

## Development Usage

The CLI tools are designed for:

1. **Testing**: Validate data integrity during development
2. **Debugging**: Diagnose performance issues and data corruption
3. **Content Updates**: Import new season data from major WoW patches
4. **Quality Assurance**: Verify healer-specific content accuracy
5. **Performance Monitoring**: Ensure iPad Pro compatibility

## Constitutional Requirement

This CLI implementation fulfills the constitutional requirement that "Each library must have functional CLI interfaces" for the HealerKit project architecture.