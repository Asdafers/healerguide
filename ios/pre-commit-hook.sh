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