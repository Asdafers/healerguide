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