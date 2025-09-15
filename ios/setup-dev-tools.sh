#!/bin/bash
# Setup script for HealerKit development tools
# This script configures SwiftLint, build schemes, and other development tools

set -e

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
XCODE_PROJECT="$PROJECT_DIR/HealerKit.xcodeproj"

echo "🔧 Setting up HealerKit development tools..."

# Check if Xcode project exists
if [ ! -d "$XCODE_PROJECT" ]; then
    echo "❌ Error: HealerKit.xcodeproj not found"
    exit 1
fi

# Create xcshareddata directory if it doesn't exist
SHARED_DATA_DIR="$XCODE_PROJECT/project.xcworkspace/xcshareddata"
mkdir -p "$SHARED_DATA_DIR"

# Check if SwiftLint is installed
if ! command -v swiftlint &> /dev/null; then
    echo "⚠️  SwiftLint not found. Installing via Homebrew..."
    if command -v brew &> /dev/null; then
        brew install swiftlint
    else
        echo "❌ Homebrew not found. Please install SwiftLint manually:"
        echo "   https://github.com/realm/SwiftLint#installation"
        exit 1
    fi
fi

echo "✅ SwiftLint found: $(swiftlint version)"

# Validate SwiftLint configuration
echo "🔍 Validating SwiftLint configuration..."
cd "$PROJECT_DIR"
if swiftlint lint --config .swiftlint.yml --quiet --reporter emoji; then
    echo "✅ SwiftLint configuration is valid"
else
    echo "⚠️  SwiftLint found issues. Run 'swiftlint lint' to see details."
fi

# Create build schemes directory
SCHEMES_DIR="$XCODE_PROJECT/xcshareddata/xcschemes"
mkdir -p "$SCHEMES_DIR"

echo "📋 Creating shared build schemes..."

# Function to create a scheme file
create_scheme() {
    local scheme_name="$1"
    local target_name="$2"
    local is_app="$3"

    cat > "$SCHEMES_DIR/$scheme_name.xcscheme" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<Scheme
   LastUpgradeVersion = "1500"
   version = "1.7">
   <BuildAction
      parallelizeBuildables = "YES"
      buildImplicitDependencies = "YES">
      <BuildActionEntries>
         <BuildActionEntry
            buildForTesting = "YES"
            buildForRunning = "YES"
            buildForProfiling = "YES"
            buildForArchiving = "YES"
            buildForAnalyzing = "YES">
            <BuildableReference
               BuildableIdentifier = "primary"
               BlueprintIdentifier = "1A000FFB"
               BuildableName = "$target_name$([ "$is_app" = "true" ] && echo ".app" || echo ".framework")"
               BlueprintName = "$target_name"
               ReferencedContainer = "container:HealerKit.xcodeproj">
            </BuildableReference>
         </BuildActionEntry>
      </BuildActionEntries>
   </BuildAction>
   <TestAction
      buildConfiguration = "Debug"
      selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
      selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
      shouldUseLaunchSchemeArgsEnv = "YES"
      codeCoverageEnabled = "YES">
      <Testables>
         <TestableReference
            skipped = "NO">
            <BuildableReference
               BuildableIdentifier = "primary"
               BlueprintIdentifier = "$([ "$target_name" = "HealerKit" ] && echo "1A001044" ||
                                      [ "$target_name" = "DungeonKit" ] && echo "1A001054" ||
                                      [ "$target_name" = "AbilityKit" ] && echo "1A001064" ||
                                      [ "$target_name" = "HealerUIKit" ] && echo "1A001074")"
               BuildableName = "${target_name}Tests.xctest"
               BlueprintName = "${target_name}Tests"
               ReferencedContainer = "container:HealerKit.xcodeproj">
            </BuildableReference>
         </TestableReference>
      </Testables>
   </TestAction>
   <LaunchAction
      buildConfiguration = "Debug"
      selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
      selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
      launchStyle = "0"
      useCustomWorkingDirectory = "NO"
      ignoresPersistentStateOnLaunch = "NO"
      debugDocumentVersioning = "YES"
      debugServiceExtension = "internal"
      allowLocationSimulation = "YES">$([ "$is_app" = "true" ] && cat <<LAUNCH_SECTION
      <BuildableProductRunnable
         runnableDebuggingMode = "0">
         <BuildableReference
            BuildableIdentifier = "primary"
            BlueprintIdentifier = "1A000FFB"
            BuildableName = "HealerKit.app"
            BlueprintName = "HealerKit"
            ReferencedContainer = "container:HealerKit.xcodeproj">
         </BuildableReference>
      </BuildableProductRunnable>
LAUNCH_SECTION
)
   </LaunchAction>
   <ProfileAction
      buildConfiguration = "Release"
      shouldUseLaunchSchemeArgsEnv = "YES"
      savedToolIdentifier = ""
      useCustomWorkingDirectory = "NO"
      debugDocumentVersioning = "YES">$([ "$is_app" = "true" ] && cat <<PROFILE_SECTION
      <BuildableProductRunnable
         runnableDebuggingMode = "0">
         <BuildableReference
            BuildableIdentifier = "primary"
            BlueprintIdentifier = "1A000FFB"
            BuildableName = "HealerKit.app"
            BlueprintName = "HealerKit"
            ReferencedContainer = "container:HealerKit.xcodeproj">
         </BuildableReference>
      </BuildableProductRunnable>
PROFILE_SECTION
)
   </ProfileAction>
   <AnalyzeAction
      buildConfiguration = "Debug">
   </AnalyzeAction>
   <ArchiveAction
      buildConfiguration = "Release"
      revealArchiveInOrganizer = "YES">
   </ArchiveAction>
</Scheme>
EOF
}

# Create schemes for all targets
create_scheme "HealerKit" "HealerKit" "true"
create_scheme "DungeonKit" "DungeonKit" "false"
create_scheme "AbilityKit" "AbilityKit" "false"
create_scheme "HealerUIKit" "HealerUIKit" "false"

echo "✅ Build schemes created"

# Create a Makefile for common development tasks
cat > "$PROJECT_DIR/Makefile" <<'EOF'
# HealerKit Development Makefile
# Provides common tasks for development workflow

.PHONY: help lint fix build test clean setup install-deps

help: ## Show this help
	@echo "HealerKit Development Tasks:"
	@echo ""
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

setup: ## Setup development environment
	@./setup-dev-tools.sh

install-deps: ## Install development dependencies
	@echo "Installing development dependencies..."
	@command -v brew >/dev/null 2>&1 || { echo "Please install Homebrew first"; exit 1; }
	@brew install swiftlint

lint: ## Run SwiftLint
	@echo "Running SwiftLint..."
	@swiftlint lint --config .swiftlint.yml

fix: ## Auto-fix SwiftLint issues
	@echo "Auto-fixing SwiftLint issues..."
	@swiftlint --fix --config .swiftlint.yml

build: ## Build all targets
	@echo "Building HealerKit..."
	@xcodebuild -project HealerKit.xcodeproj -scheme HealerKit -configuration Debug build

build-frameworks: ## Build all framework targets
	@echo "Building frameworks..."
	@xcodebuild -project HealerKit.xcodeproj -scheme DungeonKit -configuration Debug build
	@xcodebuild -project HealerKit.xcodeproj -scheme AbilityKit -configuration Debug build
	@xcodebuild -project HealerKit.xcodeproj -scheme HealerUIKit -configuration Debug build

test: ## Run all tests
	@echo "Running tests..."
	@xcodebuild -project HealerKit.xcodeproj -scheme HealerKit -configuration Debug test

test-coverage: ## Run tests with coverage report
	@echo "Running tests with coverage..."
	@xcodebuild -project HealerKit.xcodeproj -scheme HealerKit -configuration Debug -enableCodeCoverage YES test

clean: ## Clean build artifacts
	@echo "Cleaning build artifacts..."
	@xcodebuild -project HealerKit.xcodeproj clean
	@rm -rf DerivedData/

archive: ## Create release archive
	@echo "Creating archive..."
	@xcodebuild -project HealerKit.xcodeproj -scheme HealerKit -configuration Release archive -archivePath ./build/HealerKit.xcarchive
EOF

echo "✅ Makefile created"

# Create pre-commit hook script
mkdir -p "$PROJECT_DIR/.git/hooks" 2>/dev/null || true

cat > "$PROJECT_DIR/pre-commit-hook.sh" <<'EOF'
#!/bin/bash
# Pre-commit hook for SwiftLint

echo "Running SwiftLint..."

# Run SwiftLint on staged files
staged_swift_files=$(git diff --cached --name-only --diff-filter=ACM | grep "\.swift$")

if [ -n "$staged_swift_files" ]; then
    # Check if SwiftLint is installed
    if command -v swiftlint >/dev/null 2>&1; then
        # Run SwiftLint on staged files
        echo "$staged_swift_files" | xargs swiftlint lint --config .swiftlint.yml --strict

        if [ $? -ne 0 ]; then
            echo "❌ SwiftLint found issues. Please fix them before committing."
            echo "💡 Tip: Run 'make fix' to auto-fix some issues"
            exit 1
        fi

        echo "✅ SwiftLint passed"
    else
        echo "⚠️  SwiftLint not installed. Skipping lint check."
        echo "💡 Install with: brew install swiftlint"
    fi
fi
EOF

chmod +x "$PROJECT_DIR/pre-commit-hook.sh"

echo "📝 Created pre-commit hook script (not installed by default)"

# Create development tools documentation
cat > "$PROJECT_DIR/DEVELOPMENT.md" <<'EOF'
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
- **HealerKit** - Main application
- **DungeonKit** - Core dungeon mechanics framework
- **AbilityKit** - Character abilities and skills framework
- **HealerUIKit** - UI components framework

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

Test coverage is enabled by default in Debug builds. To generate coverage reports:

```bash
make test-coverage
```

Coverage reports will be available in Xcode's Report Navigator.

### Project Structure

```
ios/
├── HealerKit/           # Main iOS application
├── DungeonKit/          # Core dungeon mechanics
├── AbilityKit/          # Character abilities system
├── HealerUIKit/         # Shared UI components
├── *Tests/              # Test suites
├── .swiftlint.yml       # SwiftLint configuration
├── Makefile             # Development tasks
└── setup-dev-tools.sh   # Setup script
```

### Code Quality Standards

1. **SwiftLint Rules**: Follow the configured SwiftLint rules
2. **Test Coverage**: Aim for >80% code coverage
3. **Documentation**: Document public APIs with ///
4. **Naming**: Use clear, descriptive names for game components

### CI/CD Integration

The project is configured for continuous integration:
- SwiftLint checks run on all builds
- Test coverage is tracked
- Build schemes are shared for consistent CI builds

For questions or issues with the development setup, please refer to the project documentation or open an issue.
EOF

echo "📚 Created development documentation"

echo ""
echo "✅ Development tools setup completed!"
echo ""
echo "📋 Next steps:"
echo "   1. Run 'make lint' to check code quality"
echo "   2. Run 'make test' to verify everything works"
echo "   3. Consider installing the pre-commit hook:"
echo "      ln -s ../../pre-commit-hook.sh .git/hooks/pre-commit"
echo ""
echo "📚 See DEVELOPMENT.md for detailed information"