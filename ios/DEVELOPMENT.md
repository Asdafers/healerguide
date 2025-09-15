# HealerKit Development Guide

This document outlines the development tools and workflows for the HealerKit project.

## Quick Start

1. Run the setup script:
   ```bash
   ./setup-dev-tools.sh
   ```

2. Install dependencies:
   ```bash
   make install-deps
   ```

3. Run tests to verify setup:
   ```bash
   make test
   ```

## Development Tools

### SwiftLint

SwiftLint is configured to enforce code quality and consistency. Configuration is in `.swiftlint.yml`.

**Commands:**
- `make lint` - Run SwiftLint checks
- `make fix` - Auto-fix SwiftLint issues

**Integration:**
- SwiftLint runs automatically during builds (when properly configured)
- Pre-commit hook available: `ln -s ../../pre-commit-hook.sh .git/hooks/pre-commit`

### Build Schemes

The project includes shared build schemes for:
- **HealerKit** - Main application with comprehensive test coverage
- **DungeonKit** - Core dungeon mechanics framework
- **AbilityKit** - Character abilities and skills framework
- **HealerUIKit** - UI components framework

Each scheme is configured with:
- Code coverage enabled by default
- All relevant test suites included
- Proper build dependencies
- Debug and Release configurations

### Common Tasks

Use the Makefile for common development tasks:

```bash
make help           # Show available commands
make build          # Build all targets
make test           # Run tests
make test-coverage  # Run tests with coverage
make clean          # Clean build artifacts
make lint           # Run SwiftLint
make fix            # Auto-fix lint issues
```

### Code Coverage

Test coverage is enabled by default in all build schemes. Coverage includes:

- **HealerKit scheme**: Tracks coverage for all frameworks and the main app
- **Individual framework schemes**: Track coverage for specific frameworks
- Coverage reports available in Xcode's Report Navigator
- Minimum coverage targets should be 80% for production code

To generate coverage reports:

```bash
make test-coverage
```

### Project Structure

```
ios/
├── HealerKit/              # Main iOS application
├── DungeonKit/             # Core dungeon mechanics
├── AbilityKit/             # Character abilities system
├── HealerUIKit/            # Shared UI components
├── *Tests/                 # Test suites for each framework
├── .swiftlint.yml          # SwiftLint configuration
├── Makefile                # Development tasks
├── setup-dev-tools.sh      # Setup script
├── pre-commit-hook.sh      # Git pre-commit hook
└── DEVELOPMENT.md          # This file
```

### Code Quality Standards

1. **SwiftLint Rules**: Follow the configured SwiftLint rules in `.swiftlint.yml`
2. **Test Coverage**: Aim for >80% code coverage on all frameworks
3. **Documentation**: Document public APIs with `///` comments
4. **Naming**: Use clear, descriptive names for game components
5. **Game-Specific Rules**:
   - Proper naming for game components (Character, Monster, Spell, etc.)
   - Descriptive error handling for game logic
   - Avoid force unwrapping in production code

### Build Configuration

**Compiler Settings:**
- Swift 5.9 language version
- iOS 13.1 minimum deployment target
- Comprehensive warning flags enabled
- Code coverage enabled in Debug builds

**Framework Configuration:**
- All frameworks use dynamic linking
- Proper module maps and headers
- Consistent bundle identifiers (`com.healerkit.*`)

### Test Configuration

**Test Coverage Targets:**
- All frameworks included in main app test scheme
- Individual framework test schemes for isolated testing
- Code coverage tracking enabled by default
- Test results available in Xcode Report Navigator

**Test Organization:**
- Unit tests for each framework in separate test bundles
- Integration tests in main app test bundle
- Performance tests where appropriate

### CI/CD Integration

The project is configured for continuous integration:
- SwiftLint checks run on all builds
- Test coverage is tracked and reported
- Build schemes are shared for consistent CI builds
- Pre-commit hooks available for local development

**Recommended CI Pipeline:**
1. SwiftLint validation
2. Build all schemes
3. Run all tests with coverage
4. Archive for distribution (Release builds)

### Git Workflow

**Pre-commit Hook:**
Install the pre-commit hook to ensure code quality:
```bash
ln -s ../../pre-commit-hook.sh .git/hooks/pre-commit
```

**Commit Standards:**
- All Swift code must pass SwiftLint checks
- Tests must pass for all affected frameworks
- Maintain code coverage standards

### Troubleshooting

**Common Issues:**

1. **SwiftLint not found:**
   ```bash
   brew install swiftlint
   ```

2. **Build scheme not found:**
   - Ensure schemes are shared: Product → Scheme → Manage Schemes → Check "Shared"
   - Run `./setup-dev-tools.sh` to recreate schemes

3. **Coverage not working:**
   - Verify code coverage is enabled in scheme settings
   - Check that all targets are included in coverage

4. **Test failures:**
   - Run individual framework tests to isolate issues
   - Check test dependencies and mock data

For questions or issues with the development setup, please refer to the project documentation or open an issue.