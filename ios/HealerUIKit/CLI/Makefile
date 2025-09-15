# HealerUIKit CLI Makefile
# Build and test the CLI tools for iPad healer UI validation

.PHONY: build test clean install help benchmark validate audit colors

# Default target
all: build

# Build the CLI executable
build:
	@echo "🔨 Building HealerUIKit CLI..."
	swift build -c release
	@echo "✅ Build complete: .build/release/healeruikit"

# Run tests
test:
	@echo "🧪 Running CLI tests..."
	swift test
	@echo "✅ Tests complete"

# Clean build artifacts
clean:
	@echo "🧹 Cleaning build artifacts..."
	swift package clean
	rm -rf .build
	@echo "✅ Clean complete"

# Install CLI to system path
install: build
	@echo "📦 Installing healeruikit CLI..."
	sudo cp .build/release/healeruikit /usr/local/bin/
	@echo "✅ Installation complete: /usr/local/bin/healeruikit"

# Development commands for testing

# Test benchmark command
benchmark: build
	@echo "📊 Testing benchmark command..."
	.build/release/healeruikit benchmark --component ability-card --iterations 10
	@echo ""
	@echo "💾 Testing with memory analysis..."
	.build/release/healeruikit benchmark --component ability-card --iterations 5 --include-memory

# Test layout validation
validate: build
	@echo "📱 Testing layout validation..."
	.build/release/healeruikit validate-layouts --device ipad-pro-gen1
	@echo ""
	@echo "👆 Testing with touch targets..."
	.build/release/healeruikit validate-layouts --device ipad-pro-gen1 --validate-touch-targets

# Test accessibility audit
audit: build
	@echo "♿ Testing accessibility audit..."
	.build/release/healeruikit accessibility-audit
	@echo ""
	@echo "🔍 Testing comprehensive audit..."
	.build/release/healeruikit accessibility-audit --test-voice-over --test-dynamic-type --test-high-contrast

# Test color contrast
colors: build
	@echo "🎨 Testing color contrast..."
	.build/release/healeruikit test-colors --standard wcag-aa
	@echo ""
	@echo "🎯 Testing WCAG AAA standard..."
	.build/release/healeruikit test-colors --standard wcag-aaa --test-high-contrast

# Run all CLI commands for validation
demo: build
	@echo "🚀 HealerUIKit CLI Demo"
	@echo "======================"
	@echo ""
	@echo "📊 Performance Benchmarking:"
	.build/release/healeruikit benchmark --component ability-card --iterations 20
	@echo ""
	@echo "📱 Layout Validation:"
	.build/release/healeruikit validate-layouts --device ipad-pro-gen1 --validate-touch-targets
	@echo ""
	@echo "♿ Accessibility Audit:"
	.build/release/healeruikit accessibility-audit --test-dynamic-type
	@echo ""
	@echo "🎨 Color Contrast Testing:"
	.build/release/healeruikit test-colors --standard wcag-aa
	@echo ""
	@echo "✅ Demo complete!"

# JSON output testing
json-test: build
	@echo "📄 Testing JSON output formats..."
	@echo "Benchmark JSON:"
	.build/release/healeruikit benchmark --component ability-card --iterations 3 --format json
	@echo ""
	@echo "Layout JSON:"
	.build/release/healeruikit validate-layouts --device ipad-pro-gen1 --format json
	@echo ""
	@echo "Colors JSON:"
	.build/release/healeruikit test-colors --standard wcag-aa --format json

# Help target
help:
	@echo "HealerUIKit CLI Makefile"
	@echo "======================="
	@echo ""
	@echo "Build Commands:"
	@echo "  build      Build the CLI executable"
	@echo "  test       Run CLI tests"
	@echo "  clean      Clean build artifacts"
	@echo "  install    Install CLI to /usr/local/bin/"
	@echo ""
	@echo "Testing Commands:"
	@echo "  benchmark  Test performance benchmarking"
	@echo "  validate   Test layout validation"
	@echo "  audit      Test accessibility audit"
	@echo "  colors     Test color contrast"
	@echo "  demo       Run all commands for demonstration"
	@echo "  json-test  Test JSON output formats"
	@echo ""
	@echo "Usage Examples:"
	@echo "  make build && make demo"
	@echo "  make install"
	@echo "  make test"