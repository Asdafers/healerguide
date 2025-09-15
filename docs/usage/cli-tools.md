# CLI Tools Usage Guide

This guide provides comprehensive documentation for the command-line interfaces available across all HealerKit libraries. CLI tools are essential for development, validation, testing, and content management workflows.

## Overview

Each HealerKit library provides a dedicated CLI tool:

- **`dungeonkit`**: Dungeon and season data management
- **`abilitykit`**: Ability classification and analysis
- **`healeruikit`**: UI component validation and performance testing

All CLI tools follow consistent patterns for output formats, error handling, and integration with CI/CD workflows.

## DungeonKit CLI

### Installation and Setup

```bash
# Build CLI tool from source
cd ios/DungeonKit
swift build -c release --product dungeonkit-cli

# Install to system PATH
cp .build/release/dungeonkit-cli /usr/local/bin/dungeonkit

# Verify installation
dungeonkit --version
# Output: DungeonKit CLI v1.0.0
```

### Core Commands

#### Data Validation

Validate dungeon data integrity and healer content completeness.

```bash
# Basic validation with human-readable output
dungeonkit validate

# JSON output for CI/CD integration
dungeonkit validate --format json

# Validate specific season
dungeonkit validate --season "The War Within Season 1"

# Verbose output with detailed analysis
dungeonkit validate --verbose
```

**Sample JSON Output:**
```json
{
  "success": true,
  "timestamp": "2024-09-15T10:30:00Z",
  "validation": {
    "dungeons": {
      "total": 8,
      "valid": 8,
      "invalid": 0
    },
    "bossEncounters": {
      "total": 32,
      "valid": 31,
      "invalid": 1,
      "issues": [
        {
          "dungeonId": "12345678-1234-1234-1234-123456789012",
          "bossName": "Void Speaker Eirich",
          "issue": "Missing healer summary",
          "severity": "warning"
        }
      ]
    },
    "healerContent": {
      "completeness": 96.8,
      "missingHealerNotes": 1,
      "missingKeymechanics": 0
    }
  },
  "performance": {
    "queryTime": "45ms",
    "memoryUsage": "12MB"
  },
  "recommendations": [
    "Add healer summary for Void Speaker Eirich",
    "Consider adding positioning notes for The Stonevault"
  ]
}
```

#### Data Import/Export

Import new season data and export existing data for backup or analysis.

```bash
# Import new season data with validation
dungeonkit import --file season_11_1.json --validate

# Import without validation (faster, use for trusted sources)
dungeonkit import --file season_data.json --no-validate

# Import with backup of existing data
dungeonkit import --file new_season.json --backup

# Export active season data
dungeonkit export --season active --format json

# Export all seasons for backup
dungeonkit export --all --format json --output backup.json

# Export human-readable format for content review
dungeonkit export --season active --format human --output season_review.txt

# Export CSV for spreadsheet analysis
dungeonkit export --format csv --output dungeons.csv
```

**Sample Import Result:**
```bash
$ dungeonkit import --file season_11_1.json --validate

Importing season data: The War Within Season 1 (v11.0.5)
✓ Validating data structure
✓ Checking healer content completeness
✓ Verifying ability classifications
✓ Testing performance implications

Import Results:
- Dungeons: 8 imported successfully
- Boss Encounters: 32 imported successfully
- Abilities: 156 imported successfully
- Healer Notes: 95% complete (missing 4 notes)
- Performance: Import completed in 1.2s

Warnings:
- The Stonevault: Missing healer positioning notes
- Ara-Kara, City of Echoes: Consider adding interrupt priorities

Success: Season data imported and validated
```

#### Performance Diagnostics

Monitor and diagnose performance issues with dungeon data access.

```bash
# Basic performance check
dungeonkit diagnose --performance

# Memory usage analysis
dungeonkit diagnose --memory

# Query performance breakdown
dungeonkit diagnose --queries

# Full diagnostic report
dungeonkit diagnose --full --output diagnostics.json
```

**Sample Performance Output:**
```bash
$ dungeonkit diagnose --performance

DungeonKit Performance Diagnostics
================================

Query Performance:
- fetchDungeonsForActiveSeason(): 67ms (target: <100ms) ✓
- fetchBossEncounters(): 45ms (target: <75ms) ✓
- searchDungeons(): 123ms (target: <200ms) ✓

Memory Usage:
- Cache size: 18.2MB / 32MB allocated
- Entity count: 1,248 cached objects
- Cache hit rate: 94%

Bottlenecks Identified:
- BossEncounter relationship queries: 12ms average (acceptable)
- Search indexing: Could benefit from optimization

Recommendations:
- Current performance meets targets for first-gen iPad Pro
- Consider preloading 3 additional frequent dungeons
- Search performance good but could cache popular queries

Overall Status: ✓ Performance targets met
```

### Advanced Usage

#### Batch Operations

```bash
# Validate multiple season files
for file in seasons/*.json; do
  dungeonkit validate --file "$file" --format json >> validation_results.json
done

# Import with custom validation rules
dungeonkit import --file season.json --validation-config healer_strict.yaml

# Export with custom filtering
dungeonkit export --filter "difficultyLevel >= 15" --format json
```

#### Integration with CI/CD

```bash
#!/bin/bash
# CI validation script

# Validate data integrity
if ! dungeonkit validate --format json | jq -e '.success'; then
  echo "Data validation failed"
  exit 1
fi

# Check performance requirements
QUERY_TIME=$(dungeonkit diagnose --performance --format json | jq -r '.queryPerformance.averageTime')
if (( $(echo "$QUERY_TIME > 100" | bc -l) )); then
  echo "Performance requirements not met: ${QUERY_TIME}ms > 100ms"
  exit 1
fi

echo "All DungeonKit validations passed"
```

## AbilityKit CLI

### Installation and Setup

```bash
# Build and install AbilityKit CLI
cd ios/AbilityKit
swift build -c release --product abilitykit-cli
cp .build/release/abilitykit-cli /usr/local/bin/abilitykit

# Verify installation
abilitykit --version
```

### Core Commands

#### Ability Analysis

Analyze and classify abilities for healer relevance and priority.

```bash
# Analyze abilities for specific boss encounter
abilitykit analyze --boss 12345678-1234-1234-1234-123456789012 --format json

# Analyze with healer specialization context
abilitykit analyze --boss <uuid> --healer-spec discipline-priest

# Analyze encounter difficulty scaling
abilitykit analyze --boss <uuid> --key-level 20

# Generate healer strategy recommendations
abilitykit analyze --boss <uuid> --strategy --format human
```

**Sample Analysis Output:**
```json
{
  "bossEncounterId": "12345678-1234-1234-1234-123456789012",
  "bossName": "E.D.N.A.",
  "totalAbilities": 8,
  "analysisTimestamp": "2024-09-15T10:30:00Z",
  "damageProfileDistribution": {
    "critical": 2,
    "high": 3,
    "moderate": 2,
    "mechanic": 1
  },
  "healingLoad": "heavy",
  "criticalAbilities": [
    {
      "name": "Seismic Slam",
      "damageProfile": "critical",
      "urgency": "immediate",
      "healerAction": "Use group healing cooldown",
      "responseWindow": "1.5s",
      "recommendedCooldowns": ["Spirit Guardian", "Divine Hymn"]
    }
  ],
  "cooldownRecommendations": [
    {
      "cooldownName": "Spirit Guardian",
      "timing": "Phase 2 transition (60% HP)",
      "targetAbilities": ["Seismic Slam", "Boulder Toss"],
      "rationale": "Covers overlapping high-damage window with 45s duration"
    }
  ],
  "healerStrategy": {
    "preparationPhase": "Pre-cast renew on group before pull",
    "sustainedPhase": "Maintain group health above 80% for slam",
    "burstPhase": "Save major cooldowns for overlapping damage windows",
    "recoveryPhase": "Efficient spot healing during safe windows"
  }
}
```

#### Data Validation

Validate ability data for healer relevance and content completeness.

```bash
# Validate all abilities for encounter
abilitykit validate --encounter 12345678-1234-1234-1234-123456789012

# Validate healer action completeness
abilitykit validate --encounter <uuid> --check healer-actions

# Validate damage profile consistency
abilitykit validate --encounter <uuid> --check damage-profiles

# Full validation with recommendations
abilitykit validate --encounter <uuid> --full --format json
```

**Sample Validation Output:**
```bash
$ abilitykit validate --encounter 12345678-1234-1234-1234-123456789012

Ability Validation Results for E.D.N.A.
=======================================

✓ 8 abilities found for encounter
✓ All abilities have valid damage profiles
✓ All abilities have healer actions defined
✓ Classification consistency verified

Warnings:
⚠ 2 abilities missing cooldown information
  - "Crushing Blow": Consider adding boss cooldown data
  - "Stone Spike": Add cast frequency information
⚠ 1 ability has unclear healer action
  - "Earthquake": Current action "heal group" could be more specific

Recommendations:
- Add specific cooldown suggestions for critical abilities
- Include positioning requirements in healer actions
- Consider adding mana efficiency notes for sustained damage

Content Completeness: 94% (excellent)
Healer Relevance Score: 96% (excellent)

Status: ✓ Ready for production use
```

#### Performance Benchmarking

Test ability classification and analysis performance.

```bash
# Benchmark ability classification
abilitykit benchmark --queries 1000

# Benchmark with specific encounter data
abilitykit benchmark --encounter <uuid> --iterations 500

# Memory usage benchmarking
abilitykit benchmark --memory --duration 60s

# Full performance suite
abilitykit benchmark --full --output benchmark_results.json
```

#### Export and Analysis

Export classified abilities for external analysis or integration.

```bash
# Export all critical abilities
abilitykit export --damage-profile critical --format csv

# Export abilities with healer actions
abilitykit export --include healer-actions --format json

# Export encounter analysis for specific boss
abilitykit export --encounter <uuid> --analysis --format human

# Export cooldown recommendations
abilitykit export --cooldown-recommendations --format json --output cooldowns.json
```

## HealerUIKit CLI

### Installation and Setup

```bash
# Build and install HealerUIKit CLI
cd ios/HealerUIKit
swift build -c release --product healeruikit-cli
cp .build/release/healeruikit-cli /usr/local/bin/healeruikit

# Verify installation
healeruikit --version
```

### Core Commands

#### Component Performance Testing

Test UI component rendering performance for first-generation iPad Pro.

```bash
# Benchmark ability card rendering
healeruikit benchmark --component ability-card --iterations 100

# Benchmark with specific data sets
healeruikit benchmark --component dungeon-list --data-size large

# Test memory usage during rendering
healeruikit benchmark --component boss-encounter-view --memory

# Full performance suite
healeruikit benchmark --all --device ipad-pro-gen1 --output performance.json
```

**Sample Performance Output:**
```bash
$ healeruikit benchmark --component ability-card --iterations 100

HealerUIKit Performance Benchmark
================================

Component: AbilityCardView
Test Device: iPad Pro (1st generation) simulation
Iterations: 100

Rendering Performance:
- Average render time: 2.1ms
- Peak render time: 4.3ms
- 95th percentile: 2.8ms
- Memory per card: 42KB

Frame Rate Impact:
- 60fps budget: 16.67ms per frame
- Cards renderable per frame: ~7 cards
- Recommended max visible: 20 cards

Memory Usage:
- Peak memory usage: 4.2MB for 100 cards
- Memory per card: 42KB (within target)
- GC pressure: Minimal

Performance Analysis:
✓ Meets first-gen iPad Pro targets
✓ 60fps rendering achievable
✓ Memory usage within acceptable limits

Recommendations:
- Current performance excellent for production use
- Consider view recycling for > 50 cards
- Image caching effective, maintain current strategy
```

#### Layout Validation

Validate UI layouts across different iPad orientations and configurations.

```bash
# Validate layouts for iPad Pro first generation
healeruikit validate-layouts --device ipad-pro-gen1

# Test specific orientations
healeruikit validate-layouts --orientation portrait --device ipad-pro-gen1

# Test split-screen scenarios
healeruikit validate-layouts --split-screen --device ipad-pro-gen1

# Validate with different content sizes
healeruikit validate-layouts --content-size large --device ipad-pro-gen1
```

**Sample Layout Validation:**
```bash
$ healeruikit validate-layouts --device ipad-pro-gen1

Layout Validation Results
========================

Device: iPad Pro (1st generation) - 2732×2048
Test Scenarios: 12

Portrait Orientation (768×1024 points):
✓ Master view: 320pt width maintained
✓ Detail view: 448pt width achieved
✓ Touch targets: All ≥44pt minimum
✓ Content readability: Text within optimal line lengths
✓ Ability cards: 280pt minimum width maintained

Landscape Orientation (1024×768 points):
✓ Master view: 350pt width optimal
✓ Detail view: Remaining space utilized effectively
✓ Grid layout: 4 columns displayed correctly
✓ Touch targets: Adequate spacing maintained

Split Screen Scenarios:
✓ 1/3 split: Compact layout activated correctly
✓ 2/3 split: Regular layout maintained
✓ Slide over: Content adapts to narrow width

Multitasking:
✓ App backgrounding: Views cleanup properly
✓ External display: Secondary display support works
✓ Keyboard accommodation: Layout adjusts correctly

Content Size Categories:
✓ Standard: All layouts optimal
✓ Large: Text scales appropriately
✓ Extra Large: Some cards may need adjustment
⚠ Accessibility sizes: Consider reducing content density

Overall Status: ✓ All critical layouts pass validation
Recommendations: Test with accessibility text sizes in production
```

#### Accessibility Auditing

Generate comprehensive accessibility compliance reports.

```bash
# Full accessibility audit
healeruikit accessibility-audit --output accessibility_report.json

# Test specific accessibility features
healeruikit accessibility-audit --voiceover --high-contrast

# Color contrast testing
healeruikit test-colors --standard wcag-aa

# Dynamic Type testing
healeruikit accessibility-audit --dynamic-type --output dynamic_type_results.json
```

**Sample Accessibility Report:**
```json
{
  "auditTimestamp": "2024-09-15T10:30:00Z",
  "overallCompliance": {
    "wcagLevel": "AA",
    "complianceRate": 97.4,
    "totalElements": 156,
    "accessibleElements": 152,
    "issuesFound": 4
  },
  "colorContrast": {
    "testStandard": "WCAG-AA",
    "minimumRatio": 4.5,
    "results": {
      "critical": { "ratio": 7.23, "status": "pass" },
      "high": { "ratio": 6.81, "status": "pass" },
      "moderate": { "ratio": 5.92, "status": "pass" },
      "mechanic": { "ratio": 6.45, "status": "pass" }
    }
  },
  "voiceOverSupport": {
    "labeledElements": 152,
    "unlabeledElements": 4,
    "customActionsSupported": 23,
    "navigationEfficiency": "excellent"
  },
  "issues": [
    {
      "severity": "warning",
      "element": "AbilityCard#critical-slam",
      "issue": "Missing accessibility hint for long press action",
      "recommendation": "Add hint: 'Long press for detailed healing strategy'",
      "wcagCriterion": "3.3.2"
    },
    {
      "severity": "info",
      "element": "DungeonGrid",
      "issue": "Could benefit from collection view accessibility",
      "recommendation": "Implement UIAccessibilityContainerDataTable",
      "wcagCriterion": "1.3.1"
    }
  ],
  "dynamicType": {
    "supportsScaling": true,
    "maxCategory": "accessibilityExtraExtraLarge",
    "layoutBreakpoints": [
      {
        "category": "accessibilityExtraLarge",
        "issue": "Ability cards become cramped",
        "recommendation": "Switch to single column layout"
      }
    ]
  },
  "recommendations": [
    "Add accessibility hints for complex interactions",
    "Implement collection view accessibility protocols",
    "Test with screen reader users for real-world validation",
    "Consider audio cues for critical ability alerts"
  ]
}
```

## Integration and Automation

### CI/CD Integration

#### Validation Pipeline

```yaml
# .github/workflows/healerkit-validation.yml
name: HealerKit Validation

on: [push, pull_request]

jobs:
  validate:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v2

      - name: Build CLI Tools
        run: |
          cd ios/DungeonKit && swift build -c release
          cd ../AbilityKit && swift build -c release
          cd ../HealerUIKit && swift build -c release

      - name: Validate Dungeon Data
        run: |
          ./ios/DungeonKit/.build/release/dungeonkit-cli validate --format json > dungeon_validation.json
          if ! jq -e '.success' dungeon_validation.json; then
            echo "Dungeon validation failed"
            exit 1
          fi

      - name: Validate Ability Classifications
        run: |
          for encounter in $(jq -r '.encounters[].id' test_data.json); do
            ./ios/AbilityKit/.build/release/abilitykit-cli validate --encounter $encounter --format json
          done

      - name: Test UI Performance
        run: |
          ./ios/HealerUIKit/.build/release/healeruikit-cli benchmark --all --device ipad-pro-gen1 --format json > ui_performance.json

      - name: Archive Results
        uses: actions/upload-artifact@v2
        with:
          name: validation-results
          path: |
            dungeon_validation.json
            ui_performance.json
```

#### Content Validation Script

```bash
#!/bin/bash
# validate_content.sh - Comprehensive content validation

set -e

echo "🔍 Starting HealerKit Content Validation"

# Validate dungeon data
echo "📊 Validating dungeon data..."
if ! dungeonkit validate --format json | jq -e '.success'; then
  echo "❌ Dungeon validation failed"
  exit 1
fi

# Check all ability classifications
echo "⚔️  Validating ability classifications..."
ENCOUNTERS=$(dungeonkit export --format json | jq -r '.encounters[].id')
for encounter in $ENCOUNTERS; do
  if ! abilitykit validate --encounter "$encounter" --format json | jq -e '.success'; then
    echo "❌ Ability validation failed for encounter $encounter"
    exit 1
  fi
done

# Verify UI performance targets
echo "🎨 Testing UI performance..."
PERFORMANCE=$(healeruikit benchmark --all --device ipad-pro-gen1 --format json)
AVG_RENDER_TIME=$(echo "$PERFORMANCE" | jq -r '.averageRenderTime')

if (( $(echo "$AVG_RENDER_TIME > 16" | bc -l) )); then
  echo "❌ UI performance below target: ${AVG_RENDER_TIME}ms > 16ms"
  exit 1
fi

# Check accessibility compliance
echo "♿ Auditing accessibility..."
ACCESSIBILITY=$(healeruikit accessibility-audit --format json)
COMPLIANCE_RATE=$(echo "$ACCESSIBILITY" | jq -r '.overallCompliance.complianceRate')

if (( $(echo "$COMPLIANCE_RATE < 95" | bc -l) )); then
  echo "❌ Accessibility compliance below target: ${COMPLIANCE_RATE}% < 95%"
  exit 1
fi

echo "✅ All HealerKit validations passed successfully"
echo "📊 Performance: ${AVG_RENDER_TIME}ms average render time"
echo "♿ Accessibility: ${COMPLIANCE_RATE}% WCAG compliance"
```

### Development Workflows

#### Content Creation Workflow

```bash
#!/bin/bash
# create_new_season.sh - Workflow for adding new season content

SEASON_NAME="$1"
SEASON_VERSION="$2"

if [[ -z "$SEASON_NAME" || -z "$SEASON_VERSION" ]]; then
  echo "Usage: $0 <season-name> <version>"
  exit 1
fi

echo "🎮 Creating new season: $SEASON_NAME ($SEASON_VERSION)"

# 1. Create season data template
dungeonkit export --template --season-name "$SEASON_NAME" --version "$SEASON_VERSION" > "season_${SEASON_VERSION}.json"

echo "📝 Season template created: season_${SEASON_VERSION}.json"

# 2. Validate template structure
if ! dungeonkit validate --file "season_${SEASON_VERSION}.json" --template-mode; then
  echo "❌ Season template validation failed"
  exit 1
fi

# 3. Create ability analysis workspace
mkdir -p "content/${SEASON_VERSION}"
cd "content/${SEASON_VERSION}"

# 4. Generate ability classification templates for each encounter
ENCOUNTERS=$(jq -r '.encounters[].id' "../../season_${SEASON_VERSION}.json")
for encounter in $ENCOUNTERS; do
  abilitykit analyze --encounter "$encounter" --template-mode > "${encounter}_abilities.json"
done

echo "✅ Season creation workflow completed"
echo "📁 Content directory: content/${SEASON_VERSION}/"
echo "📝 Next steps:"
echo "   1. Fill in healer-specific content in JSON files"
echo "   2. Run: dungeonkit validate --file season_${SEASON_VERSION}.json"
echo "   3. Import: dungeonkit import --file season_${SEASON_VERSION}.json --validate"
```

This comprehensive CLI tools guide enables efficient development, validation, and maintenance workflows for all HealerKit libraries, with robust automation support for continuous integration and content management.