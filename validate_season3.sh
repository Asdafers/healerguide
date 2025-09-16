#!/bin/bash

# Season 3 Data Validation Script
# Validates all dungeons have complete boss encounters and abilities

set -e

echo "🔍 Season 3 Data Validation Starting..."
echo "=" | head -c 60 | tr '\n' '='
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

SUCCESS_COUNT=0
WARNING_COUNT=0
ERROR_COUNT=0

log_success() {
    echo -e "${GREEN}✅ SUCCESS: $1${NC}"
    ((SUCCESS_COUNT++))
}

log_warning() {
    echo -e "${YELLOW}⚠️  WARNING: $1${NC}"
    ((WARNING_COUNT++))
}

log_error() {
    echo -e "${RED}❌ ERROR: $1${NC}"
    ((ERROR_COUNT++))
}

# Check if API is running
echo "📡 Checking API connectivity..."
if curl -s -f http://localhost:8080/health > /dev/null; then
    log_success "API is responding at localhost:8080"
else
    log_error "API is not responding at localhost:8080"
    exit 1
fi

# 1. Validate Season 3 exists and is correct
echo ""
echo "🎯 Validating Season 3 Configuration..."

SEASON_DATA=$(curl -s "http://localhost:8080/api/v1/seasons?active_only=true")
SEASON_COUNT=$(echo "$SEASON_DATA" | python3 -c "import sys, json; data=json.load(sys.stdin); print(len(data))")

if [ "$SEASON_COUNT" -eq 1 ]; then
    log_success "Exactly 1 active season found"

    SEASON_VERSION=$(echo "$SEASON_DATA" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data[0]['majorVersion'])")
    SEASON_NAME=$(echo "$SEASON_DATA" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data[0]['name'])")
    DUNGEON_COUNT=$(echo "$SEASON_DATA" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data[0]['dungeonCount'])")

    if [ "$SEASON_VERSION" = "11.2" ]; then
        log_success "Season version is correct (11.2)"
    else
        log_error "Expected season version 11.2, got $SEASON_VERSION"
    fi

    if [ "$SEASON_NAME" = "The War Within Season 3" ]; then
        log_success "Season name is correct"
    else
        log_error "Expected 'The War Within Season 3', got '$SEASON_NAME'"
    fi

    if [ "$DUNGEON_COUNT" -eq 8 ]; then
        log_success "Dungeon count is correct (8)"
    else
        log_error "Expected 8 dungeons, got $DUNGEON_COUNT"
    fi
else
    log_error "Expected exactly 1 active season, found $SEASON_COUNT"
fi

# 2. Validate all 8 Season 3 dungeons exist
echo ""
echo "🏰 Validating Season 3 Dungeons..."

SEASON_ID=$(echo "$SEASON_DATA" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data[0]['id'])")
DUNGEONS_DATA=$(curl -s "http://localhost:8080/api/v1/seasons/$SEASON_ID/dungeons")

EXPECTED_DUNGEONS=(
    "Ara-Kara, City of Echoes"
    "The Dawnbreaker"
    "Eco-Dome Aldani"
    "Halls of Atonement"
    "Operation: Floodgate"
    "Priory of the Sacred Flame"
    "Tazavesh: Streets of Wonder"
    "Tazavesh: So'leah's Gambit"
)

for dungeon in "${EXPECTED_DUNGEONS[@]}"; do
    if echo "$DUNGEONS_DATA" | grep -q "\"$dungeon\""; then
        log_success "Found dungeon: $dungeon"
    else
        log_error "Missing dungeon: $dungeon"
    fi
done

# 3. Validate healer-specific dungeon data
echo ""
echo "🩺 Validating Healer-Specific Data..."

DUNGEON_NAMES=$(echo "$DUNGEONS_DATA" | python3 -c "
import sys, json
data = json.load(sys.stdin)
for dungeon in data:
    print(dungeon['name'] + '|' + dungeon['shortName'] + '|' + str(bool(dungeon.get('healerNotes'))))
")

while IFS='|' read -r name short_name has_notes; do
    if [ "$has_notes" = "True" ]; then
        log_success "$short_name: Has healer notes"
    else
        log_warning "$short_name: Missing healer notes"
    fi
done <<< "$DUNGEON_NAMES"

# 4. Validate critical boss encounters exist
echo ""
echo "👑 Validating Critical Boss Encounters..."

# Test Ara-Kara (should have Avanoxx)
ARA_KARA_ID=$(echo "$DUNGEONS_DATA" | python3 -c "
import sys, json
data = json.load(sys.stdin)
for dungeon in data:
    if dungeon['name'] == 'Ara-Kara, City of Echoes':
        print(dungeon['id'])
        break
")

if [ -n "$ARA_KARA_ID" ]; then
    ARA_KARA_BOSSES=$(curl -s "http://localhost:8080/api/v1/dungeons/$ARA_KARA_ID/bosses")
    BOSS_COUNT=$(echo "$ARA_KARA_BOSSES" | python3 -c "import sys, json; data=json.load(sys.stdin); print(len(data))")

    if [ "$BOSS_COUNT" -gt 0 ]; then
        log_success "Ara-Kara has $BOSS_COUNT boss encounters"

        # Check if Avanoxx exists
        if echo "$ARA_KARA_BOSSES" | grep -q "Avanoxx"; then
            log_success "Found Avanoxx boss in Ara-Kara"

            # Get Avanoxx abilities
            AVANOXX_ID=$(echo "$ARA_KARA_BOSSES" | python3 -c "
import sys, json
data = json.load(sys.stdin)
for boss in data:
    if boss['name'] == 'Avanoxx':
        print(boss['id'])
        break
")

            if [ -n "$AVANOXX_ID" ]; then
                AVANOXX_ABILITIES=$(curl -s "http://localhost:8080/api/v1/bosses/$AVANOXX_ID/abilities")
                ABILITY_COUNT=$(echo "$AVANOXX_ABILITIES" | python3 -c "import sys, json; data=json.load(sys.stdin); print(len(data))")

                if [ "$ABILITY_COUNT" -gt 0 ]; then
                    log_success "Avanoxx has $ABILITY_COUNT abilities"

                    # Check for Alerting Shrill (Critical ability)
                    if echo "$AVANOXX_ABILITIES" | grep -q "Alerting Shrill"; then
                        log_success "Found critical ability: Alerting Shrill"

                        # Validate it's marked as Critical
                        DAMAGE_PROFILE=$(echo "$AVANOXX_ABILITIES" | python3 -c "
import sys, json
data = json.load(sys.stdin)
for ability in data:
    if ability['name'] == 'Alerting Shrill':
        print(ability['damageProfile'])
        break
")
                        if [ "$DAMAGE_PROFILE" = "Critical" ]; then
                            log_success "Alerting Shrill correctly marked as Critical"
                        else
                            log_error "Alerting Shrill should be Critical, got $DAMAGE_PROFILE"
                        fi
                    else
                        log_error "Missing critical ability: Alerting Shrill"
                    fi
                else
                    log_error "Avanoxx has no abilities"
                fi
            fi
        else
            log_error "Avanoxx boss not found in Ara-Kara"
        fi
    else
        log_error "Ara-Kara has no boss encounters"
    fi
fi

# 5. Database-level validation
echo ""
echo "🗄️  Database Validation..."

# Check database connectivity and key counts
DB_RESULT=$(docker exec healerkit-postgres psql -U healer -d healerkit -t -c "
SELECT
    (SELECT COUNT(*) FROM seasons WHERE is_active = true) as active_seasons,
    (SELECT COUNT(*) FROM dungeons) as total_dungeons,
    (SELECT COUNT(*) FROM boss_encounters) as total_bosses,
    (SELECT COUNT(*) FROM abilities) as total_abilities;
")

read -r ACTIVE_SEASONS TOTAL_DUNGEONS TOTAL_BOSSES TOTAL_ABILITIES <<< "$DB_RESULT"

if [ "$ACTIVE_SEASONS" -eq 1 ]; then
    log_success "Database: 1 active season"
else
    log_error "Database: Expected 1 active season, got $ACTIVE_SEASONS"
fi

if [ "$TOTAL_DUNGEONS" -eq 8 ]; then
    log_success "Database: 8 dungeons total"
else
    log_error "Database: Expected 8 dungeons, got $TOTAL_DUNGEONS"
fi

if [ "$TOTAL_BOSSES" -gt 0 ]; then
    log_success "Database: $TOTAL_BOSSES boss encounters total"
else
    log_error "Database: No boss encounters found"
fi

if [ "$TOTAL_ABILITIES" -gt 0 ]; then
    log_success "Database: $TOTAL_ABILITIES abilities total"
else
    log_error "Database: No abilities found"
fi

# 6. Summary Report
echo ""
echo "=" | head -c 60 | tr '\n' '='
echo ""
echo "📊 VALIDATION SUMMARY"
echo "=" | head -c 60 | tr '\n' '='
echo ""
echo "✅ Successes: $SUCCESS_COUNT"
echo "⚠️  Warnings: $WARNING_COUNT"
echo "❌ Errors: $ERROR_COUNT"
echo ""

if [ "$ERROR_COUNT" -eq 0 ] && [ "$WARNING_COUNT" -le 2 ]; then
    echo -e "${GREEN}🎯 OVERALL STATUS: ✅ PASS${NC}"
    exit 0
elif [ "$ERROR_COUNT" -eq 0 ]; then
    echo -e "${YELLOW}🎯 OVERALL STATUS: ⚠️  PASS WITH WARNINGS${NC}"
    exit 0
else
    echo -e "${RED}🎯 OVERALL STATUS: ❌ FAIL${NC}"
    exit 1
fi