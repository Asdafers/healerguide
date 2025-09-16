#!/bin/bash

# Script to fix DungeonKitTests target by adding missing test files to the project

set -euo pipefail

PROJECT_FILE="HealerKit.xcodeproj/project.pbxproj"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if project file exists
if [ ! -f "$PROJECT_FILE" ]; then
    print_error "Project file $PROJECT_FILE not found"
    exit 1
fi

print_status "Backing up project file..."
cp "$PROJECT_FILE" "${PROJECT_FILE}.backup"

print_status "Adding missing test files to DungeonKitTests target..."

# Generate unique IDs for new entries (using timestamp-based approach for uniqueness)
TIMESTAMP=$(date +%s | tail -c 8)
DUNGEON_TESTS_FILEREF="DD${TIMESTAMP}001"
DUNGEON_TESTS_BUILDFILE="DD${TIMESTAMP}002"
BOSS_TESTS_FILEREF="DD${TIMESTAMP}003"
BOSS_TESTS_BUILDFILE="DD${TIMESTAMP}004"
SEASON_TESTS_FILEREF="DD${TIMESTAMP}005"
SEASON_TESTS_BUILDFILE="DD${TIMESTAMP}006"

print_status "Generated IDs: $DUNGEON_TESTS_FILEREF, $BOSS_TESTS_FILEREF, $SEASON_TESTS_FILEREF"

# Create temporary file for modifications
TEMP_FILE=$(mktemp)

# Step 1: Add PBXBuildFile entries
print_status "Adding PBXBuildFile entries..."
sed "/\/\* End PBXBuildFile section \*\//i\\
\\t\\t$DUNGEON_TESTS_BUILDFILE /* DungeonTests.swift in Sources */ = {isa = PBXBuildFile; fileRef = $DUNGEON_TESTS_FILEREF /* DungeonTests.swift */; };\\
\\t\\t$BOSS_TESTS_BUILDFILE /* BossEncounterTests.swift in Sources */ = {isa = PBXBuildFile; fileRef = $BOSS_TESTS_FILEREF /* BossEncounterTests.swift */; };\\
\\t\\t$SEASON_TESTS_BUILDFILE /* SeasonTests.swift in Sources */ = {isa = PBXBuildFile; fileRef = $SEASON_TESTS_FILEREF /* SeasonTests.swift */; };" "$PROJECT_FILE" > "$TEMP_FILE"

# Step 2: Add PBXFileReference entries
print_status "Adding PBXFileReference entries..."
sed "/\/\* End PBXFileReference section \*\//i\\
\\t\\t$DUNGEON_TESTS_FILEREF /* DungeonTests.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = DungeonTests.swift; sourceTree = \"<group>\"; };\\
\\t\\t$BOSS_TESTS_FILEREF /* BossEncounterTests.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = BossEncounterTests.swift; sourceTree = \"<group>\"; };\\
\\t\\t$SEASON_TESTS_FILEREF /* SeasonTests.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = SeasonTests.swift; sourceTree = \"<group>\"; };" "$TEMP_FILE" > "${TEMP_FILE}.tmp" && mv "${TEMP_FILE}.tmp" "$TEMP_FILE"

# Step 3: Add files to DungeonKitTests Sources build phase (1A001051)
print_status "Adding files to DungeonKitTests Sources build phase..."
sed "/1A001051 \/\* Sources \*\/ = {/,/files = (/c\\
\\t\\t1A001051 /* Sources */ = {\\
\\t\\t\\tisa = PBXSourcesBuildPhase;\\
\\t\\t\\tbuildActionMask = 2147483647;\\
\\t\\t\\tfiles = (\\
\\t\\t\\t\\t1AFFB048 /* HealerKitTests.swift in Sources */,\\
\\t\\t\\t\\t1A001094 /* IntegrationTests.swift in Sources */,\\
\\t\\t\\t\\t$DUNGEON_TESTS_BUILDFILE /* DungeonTests.swift in Sources */,\\
\\t\\t\\t\\t$BOSS_TESTS_BUILDFILE /* BossEncounterTests.swift in Sources */,\\
\\t\\t\\t\\t$SEASON_TESTS_BUILDFILE /* SeasonTests.swift in Sources */," "$TEMP_FILE" > "${TEMP_FILE}.tmp" && mv "${TEMP_FILE}.tmp" "$TEMP_FILE"

# Step 4: Create ModelTests group and add files to DungeonKitTests group
print_status "Adding files to project groups..."

# First, let's add a ModelTests group reference ID
MODELTESTS_GROUP="DD${TIMESTAMP}100"

# Add ModelTests group to PBXGroup section
sed "/\/\* End PBXGroup section \*\//i\\
\\t\\t$MODELTESTS_GROUP /* ModelTests */ = {\\
\\t\\t\\tisa = PBXGroup;\\
\\t\\t\\tchildren = (\\
\\t\\t\\t\\t$DUNGEON_TESTS_FILEREF /* DungeonTests.swift */,\\
\\t\\t\\t\\t$BOSS_TESTS_FILEREF /* BossEncounterTests.swift */,\\
\\t\\t\\t\\t$SEASON_TESTS_FILEREF /* SeasonTests.swift */,\\
\\t\\t\\t);\\
\\t\\t\\tpath = ModelTests;\\
\\t\\t\\tsourceTree = \"<group>\";\\
\\t\\t};" "$TEMP_FILE" > "${TEMP_FILE}.tmp" && mv "${TEMP_FILE}.tmp" "$TEMP_FILE"

# Add ModelTests group to DungeonKitTests group (find and modify existing DungeonKitTests group)
sed "/1A001056 \/\* DungeonKitTests \*\/ = {/,/children = (/c\\
\\t\\t1A001056 /* DungeonKitTests */ = {\\
\\t\\t\\tisa = PBXGroup;\\
\\t\\t\\tchildren = (\\
\\t\\t\\t\\t1A001057 /* DungeonKitTests.swift */,\\
\\t\\t\\t\\t$MODELTESTS_GROUP /* ModelTests */," "$TEMP_FILE" > "${TEMP_FILE}.tmp" && mv "${TEMP_FILE}.tmp" "$TEMP_FILE"

# Copy the modified file back
cp "$TEMP_FILE" "$PROJECT_FILE"
rm "$TEMP_FILE"

print_success "Project file updated successfully!"

# Verify the changes
print_status "Verifying changes..."
if grep -q "DungeonTests.swift" "$PROJECT_FILE" && \
   grep -q "BossEncounterTests.swift" "$PROJECT_FILE" && \
   grep -q "SeasonTests.swift" "$PROJECT_FILE"; then
    print_success "✅ All test files added to project!"
    print_status "Test files that will now be compiled:"
    echo "  - DungeonTests.swift"
    echo "  - BossEncounterTests.swift"
    echo "  - SeasonTests.swift"
    echo "  - DungeonKitTests.swift (existing)"
    echo "  - IntegrationTests.swift (existing)"
else
    print_error "❌ Some test files may not have been added correctly"
    print_status "Restoring backup..."
    cp "${PROJECT_FILE}.backup" "$PROJECT_FILE"
    exit 1
fi

print_success "🎉 DungeonKitTests target fixed!"
print_status "💡 Run 'xcodebuild clean build test' to verify the fix"

# Clean up backup
rm "${PROJECT_FILE}.backup"