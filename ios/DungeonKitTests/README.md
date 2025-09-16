# DungeonKit Content Validation Tests

This directory contains comprehensive tests to validate that all dungeons and boss encounters have complete, high-quality content for the HealerKit application.

## Test Structure

### Content Validation Tests
Located in `ContentValidationTests/`:

- **`DungeonContentValidationTests.swift`** - Validates all Season 1 dungeons are present with complete data
- **`BossEncounterContentValidationTests.swift`** - Validates all boss encounters have quality healer content
- **`DataIntegrityValidationTests.swift`** - Validates relationships and cross-references between data

### What These Tests Validate

#### Dungeon Content
- ✅ All 8 expected War Within Season 1 dungeons are present
- ✅ Unique display orders, names, and short names
- ✅ Required fields completeness (name, shortName, difficulty, etc.)
- ✅ Reasonable estimated durations (15-60 minutes)
- ✅ Each dungeon has minimum required boss encounters (3-4)
- ✅ Search functionality by name and short name

#### Boss Encounter Content
- ✅ Sequential boss encounter ordering within dungeons
- ✅ Required fields completeness (name, healer summary, difficulty)
- ✅ Quality healer summaries (50-500 characters with healer-specific content)
- ✅ Key mechanics (1-3 per boss with meaningful descriptions)
- ✅ Reasonable difficulty distribution and durations
- ✅ Search functionality across all encounters

#### Data Integrity
- ✅ Complete season data integrity (8 dungeons, 24-32 total bosses)
- ✅ Cross-reference integrity between dungeons and bosses
- ✅ Consistency across different query methods
- ✅ Bidirectional relationship integrity

## Running Tests

### Local Development (macOS + Xcode)

```bash
# Navigate to iOS project directory
cd ios

# Run specific content validation test suites
xcodebuild test \
  -project HealerKit.xcodeproj \
  -scheme DungeonKit \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  -only-testing:DungeonKitTests/DungeonContentValidationTests

# Run all content validation tests
xcodebuild test \
  -project HealerKit.xcodeproj \
  -scheme DungeonKit \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  -only-testing:DungeonKitTests/DungeonContentValidationTests \
  -only-testing:DungeonKitTests/BossEncounterContentValidationTests \
  -only-testing:DungeonKitTests/DataIntegrityValidationTests

# Use the helper script (recommended)
./scripts/run-content-validation-tests.sh
```

### Using the Test Script

The `scripts/run-content-validation-tests.sh` script provides additional features:

```bash
# Run all content validation tests
./scripts/run-content-validation-tests.sh

# Generate detailed test report
./scripts/run-content-validation-tests.sh --report

# Build only (no tests)
./scripts/run-content-validation-tests.sh --build-only

# Show help
./scripts/run-content-validation-tests.sh --help
```

### GitHub Actions (CI/CD)

Tests automatically run on:
- Push to `main` or `develop` branches
- Pull requests to `main`
- Manual workflow dispatch

The workflow file: `.github/workflows/ios-content-validation.yml`

#### Manual Trigger
1. Go to the Actions tab in your GitHub repository
2. Select "iOS Content Validation Tests"
3. Click "Run workflow"

## Test Results

### Success Criteria
- All 8 War Within Season 1 dungeons present
- Each dungeon has 3-4 boss encounters
- All content meets quality standards (meaningful descriptions, proper relationships)
- Performance requirements met (reasonable test execution times)

### What Failures Indicate
- **Missing dungeons**: Core content incomplete
- **Missing boss encounters**: Dungeon data incomplete
- **Empty summaries**: Content quality issues
- **Relationship failures**: Data integrity problems
- **Search failures**: Query functionality broken

## Expected Content

### The War Within Season 1 Dungeons
1. **The Dawnbreaker** (DB) - 3 bosses
2. **Ara-Kara, City of Echoes** (AK) - 3 bosses
3. **City of Threads** (COT) - 3 bosses
4. **The Stonevault** (SV) - 4 bosses
5. **Mists of Tirna Scithe** (MOTS) - 3 bosses
6. **The Necrotic Wake** (NW) - 4 bosses
7. **Siege of Boralus** (SOB) - 4 bosses
8. **Grim Batol** (GB) - 4 bosses

**Total**: 8 dungeons, 27 boss encounters

### Content Quality Standards
- **Healer Summaries**: 50-500 characters, healer-specific guidance
- **Key Mechanics**: 1-3 per boss, 5-50 characters each
- **Difficulty Ratings**: Easy, Moderate, Hard, Extreme
- **Duration Estimates**: Dungeons 15-60 minutes, Bosses 1-10 minutes

## Troubleshooting

### Common Issues

#### Build Failures
- Ensure Xcode 15.2+ is installed
- Check iOS Simulator is available
- Verify CoreData model is up to date

#### Test Failures
- Check if test data matches expected content
- Verify CoreData relationships are properly configured
- Ensure all required fields are populated

#### CI Failures
- Check GitHub Actions runner has correct Xcode version
- Verify all test files are committed to repository
- Check for iOS Simulator availability in CI environment

### Getting Help

If tests fail unexpectedly:
1. Check the test output for specific error messages
2. Verify your local data matches expected content structure
3. Run individual test methods to isolate issues
4. Check the generated test reports for detailed information

## Contributing

When adding new content or modifying existing data:
1. Run content validation tests locally first
2. Update expected content constants if adding new dungeons/bosses
3. Ensure all tests pass before submitting pull requests
4. Add new test cases for new content validation requirements