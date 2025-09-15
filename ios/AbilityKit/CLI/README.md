# AbilityKit CLI

Command-line interface for AbilityKit - Boss ability analysis and validation for World of Warcraft healers.

## Overview

The AbilityKit CLI provides powerful command-line tools for analyzing boss abilities, validating healer relevance, benchmarking performance, and exporting ability data. Designed specifically for healers targeting first-generation iPad Pro devices with iOS 13.1+ compatibility.

## Installation

```bash
# Build the CLI tool
swift build -c release

# Run directly
swift run abilitykit --help
```

## Available Commands

### 1. Analyze Command

Analyze abilities for a boss encounter with healer-focused recommendations.

```bash
abilitykit analyze --boss <uuid> --format json [--verbose]
```

**Options:**
- `--boss, -b`: Boss encounter UUID to analyze (required)
- `--format, -f`: Output format - `json` or `human` (default: `human`)
- `--verbose, -v`: Include detailed healer action recommendations

**Example:**
```bash
abilitykit analyze --boss 123e4567-e89b-12d3-a456-426614174000 --format json --verbose
```

**Sample Output:**
```json
{
  "boss_encounter_id": "123e4567-e89b-12d3-a456-426614174000",
  "total_abilities": 6,
  "healing_load": "heavy",
  "damage_profile_distribution": {
    "critical": 2,
    "high": 2,
    "moderate": 1,
    "mechanic": 1
  },
  "abilities": [
    {
      "name": "Alerting Shrill",
      "damage_profile": "critical",
      "urgency": 4,
      "healer_action": "Immediate group healing cooldown required",
      "color_scheme": {
        "primary": "#FF4444",
        "background": "#FFEBEE",
        "text": "#FFFFFF",
        "border": "#D32F2F"
      }
    }
  ]
}
```

### 2. Validate Command

Validate ability data for healer relevance and completeness.

```bash
abilitykit validate --encounter <uuid> [--errors-only] [--verbose]
```

**Options:**
- `--encounter, -e`: Boss encounter UUID to validate (required)
- `--errors-only`: Show only validation errors
- `--verbose, -v`: Detailed validation output with recommendations

**Example:**
```bash
abilitykit validate --encounter 123e4567-e89b-12d3-a456-426614174000 --verbose
```

**Sample Output:**
```
✅ AbilityKit Validation Report
═══════════════════════════════
Encounter: 123e4567-e89b-12d3-a456-426614174000
Total Abilities: 6
Valid Abilities: 5
Total Issues: 3
Errors: 1

Validation Status: ❌ FAIL (83.3% success rate)

📋 Detailed Results:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Ability: Shadow Bolt
Status: ⚠️  WARNING (1 warnings)
  ⚠️ [WARNING] Critical ability missing cooldown timing
      Field: cooldown
  💡 Recommendations:
    • Add cooldown information for encounter planning
```

### 3. Export Command

Export ability classifications with filtering and format options.

```bash
abilitykit export --format <format> [--damage-profile <profile>] [--output <path>] [--include-colors] [--include-actions]
```

**Options:**
- `--format, -f`: Output format - `json`, `csv`, or `human` (default: `csv`)
- `--damage-profile`: Filter by damage profile - `critical`, `high`, `moderate`, `mechanic`
- `--output, -o`: Output file path (default: stdout)
- `--include-colors`: Include UI color scheme information
- `--include-actions`: Include healer action recommendations

**Examples:**
```bash
# Export critical abilities to CSV with colors
abilitykit export --format csv --damage-profile critical --include-colors --output critical_abilities.csv

# Export all abilities to JSON
abilitykit export --format json --include-actions --output all_abilities.json

# Human-readable format to terminal
abilitykit export --format human --damage-profile high
```

**Sample CSV Output:**
```csv
id,name,type,damage_profile,urgency,complexity,healer_impact,healer_action,primary_color
uuid-1,Alerting Shrill,damage,critical,4,3,4,"Immediate group healing cooldown required",#FF4444
uuid-2,Crushing Blow,damage,critical,4,4,4,"Tank external defensive cooldown + big heal",#FF4444
```

### 4. Benchmark Command

Performance test ability queries and classification operations.

```bash
abilitykit benchmark --queries <count> [--memory] [--verbose]
```

**Options:**
- `--queries, -q`: Number of queries to benchmark (default: 1000)
- `--memory, -m`: Include memory usage measurements
- `--verbose, -v`: Detailed timing breakdown

**Example:**
```bash
abilitykit benchmark --queries 1000 --memory --verbose
```

**Sample Output:**
```
🚀 AbilityKit Performance Benchmark
═══════════════════════════════════
Iterations: 1000
Total Time: 0.234s
Average Time per Operation: 0.000234s

📊 Performance Breakdown:
┌─────────────────┬──────────┬──────────┬──────────┬──────────┐
│ Operation       │ Total    │ Average  │ Min      │ Max      │
├─────────────────┼──────────┼──────────┼──────────┼──────────┤
│ Query           │    0.156s │ 0.000156s │ 0.000142s │ 0.000298s │
│ Classification  │    0.078s │ 0.000078s │ 0.000071s │ 0.000145s │
│ Analysis        │    0.234s │ 0.002340s │ 0.002187s │ 0.003421s │
└─────────────────┴──────────┴──────────┴──────────┴──────────┘

📈 Performance Assessment:
  Query Performance: 🟢 Excellent
  Classification Performance: 🟢 Excellent

💾 Memory Usage:
  Initial: 42.3 MB
  Peak: 45.1 MB
  Final: 43.7 MB
  Growth: 1.4 MB
```

## Key Features

### Healer-Specific Analysis
- **Damage Profile Classification**: Critical, High, Moderate, Mechanic
- **Urgency Levels**: Immediate (1-2s), High (3-5s), Moderate (5-10s), Low (passive)
- **Complexity Assessment**: Simple, Moderate, Complex, Extreme
- **Healer Impact Rating**: Critical, High, Moderate, Low

### iPad Pro Optimization
- **Color Schemes**: Optimized for first-generation iPad Pro display
- **Performance Validation**: Ensures <3 second load times and 60fps capability
- **Memory Efficiency**: Designed for 4GB RAM constraints

### Sample Data

The CLI includes sample abilities for testing:

- **Alerting Shrill**: Critical group ability requiring immediate healing cooldown
- **Sonic Boom**: High damage with predictable pattern
- **Shadow Bolt**: Moderate random-target damage
- **Dispel Magic**: Mechanic requiring immediate dispel action
- **Crushing Blow**: Critical tank ability needing external defensive
- **Poison Cloud**: High sustained group damage over time

### Output Formats

1. **JSON**: Machine-readable format for integration
2. **CSV**: Spreadsheet-compatible for data analysis
3. **Human-readable**: Terminal-friendly format for quick review

### Validation Rules

The CLI validates abilities for healer relevance:

- **Completeness**: Healer action and critical insight fields
- **Relevance**: Abilities that require healer attention
- **Consistency**: Damage profile matches actual impact
- **Timing**: Cooldown information for critical abilities

### Performance Benchmarks

Targets for first-generation iPad Pro:
- Query operations: < 0.01s average
- Classification: < 0.001s average
- Memory growth: < 50MB per session
- Data load times: < 3 seconds total

## Integration

The CLI integrates with all AbilityKit services:

- **AbilityDataProvider**: Fetch and search ability data
- **AbilityClassificationService**: Classify abilities and validate healer relevance
- **DamageProfileAnalyzer**: Analyze damage patterns and generate UI color schemes

## Constitutional Compliance

This CLI implementation fulfills the constitutional requirement that "Each library must have functional CLI interfaces" by providing:

✅ Complete command-line interface for all AbilityKit functionality
✅ Performance validation for target hardware constraints
✅ Healer-specific analysis and recommendations
✅ Integration with all library services
✅ Support for multiple output formats
✅ Comprehensive validation and benchmarking capabilities

## Error Handling

The CLI provides clear error messages and validation:

```bash
# Invalid UUID
❌ Error: Invalid boss UUID: not-a-uuid

# Missing encounter
❌ Error: No abilities found for boss encounter 123e4567-e89b-12d3-a456-426614174000

# Invalid damage profile
❌ Error: Invalid damage profile: invalid. Valid options: critical, high, moderate, mechanic
```

## Development

Run tests and validate functionality:

```bash
# Run CLI tests
swift run test_cli

# Run demonstration
swift run demo

# Build for release
swift build -c release --product abilitykit
```