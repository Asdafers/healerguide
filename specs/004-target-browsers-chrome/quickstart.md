# Quickstart Guide: Chrome Web App for HealerKit

**Date**: 2025-09-15
**Feature**: Chrome Web App for HealerKit
**Purpose**: Development setup and user story validation tests

## Prerequisites

### Development Environment
- Swift 5.9+ with Vapor framework
- Node.js 18+ with npm/yarn
- PostgreSQL 14+ database
- Docker and Docker Compose
- Chrome browser (latest version)

### Database Setup
```bash
# Start PostgreSQL with Docker
docker run --name healerkit-postgres \
  -e POSTGRES_DB=healerkit \
  -e POSTGRES_USER=healer \
  -e POSTGRES_PASSWORD=mysecretpassword \
  -p 5432:5432 \
  -d postgres:14

# Apply database schema
psql -h localhost -U healer -d healerkit -f scripts/schema.sql
```

## Backend Development (Swift/Vapor)

### Project Structure
```
backend/
├── Sources/
│   ├── App/
│   │   ├── Models/          # Season, Dungeon, BossEncounter, Ability
│   │   ├── Controllers/     # API endpoints
│   │   ├── Services/        # Business logic
│   │   └── configure.swift  # App configuration
│   └── Run/
│       └── main.swift
├── Tests/
│   ├── AppTests/
│   │   ├── ContractTests/   # API contract validation
│   │   ├── IntegrationTests/ # Database integration
│   │   └── UnitTests/       # Service unit tests
├── Package.swift
└── docker-compose.yml
```

### Quick Start Commands
```bash
# Clone and setup backend
cd backend/
swift package resolve
swift build

# Run database migrations
swift run App migrate

# Import sample data
swift run App seed-data --file ../sample-data/war-within-season-1.json

# Start development server
swift run App serve --hostname 0.0.0.0 --port 8080
```

### Backend Testing
```bash
# Run all tests
swift test

# Run contract tests only
swift test --filter ContractTests

# Run with coverage
swift test --enable-code-coverage
```

## Frontend Development (React/TypeScript)

### Project Structure
```
frontend/
├── src/
│   ├── components/
│   │   ├── DungeonGrid/     # Dungeon selection grid
│   │   ├── BossDetail/      # Boss encounter details
│   │   ├── AbilityCard/     # Color-coded ability cards
│   │   └── common/          # Shared UI components
│   ├── services/
│   │   └── api.ts           # API client
│   ├── types/
│   │   └── index.ts         # TypeScript interfaces
│   ├── pages/
│   │   ├── HomePage.tsx     # Landing page
│   │   ├── DungeonPage.tsx  # Dungeon detail view
│   │   └── BossPage.tsx     # Boss encounter view
│   └── App.tsx
├── tests/
│   ├── components/          # Component tests
│   ├── integration/         # Page integration tests
│   └── e2e/                 # Playwright browser tests
├── public/
├── package.json
└── vite.config.ts
```

### Quick Start Commands
```bash
# Clone and setup frontend
cd frontend/
npm install

# Start development server
npm run dev

# Build for production
npm run build

# Preview production build
npm run preview
```

### Frontend Testing
```bash
# Run unit tests
npm run test

# Run component tests with coverage
npm run test:coverage

# Run integration tests
npm run test:integration

# Run E2E tests (requires backend running)
npm run test:e2e
```

## User Story Validation Tests

### Test 1: Dungeon List Display
**User Story**: Healer views dungeon list in Chrome browser
**Validation**: See same 8 War Within Season dungeons as iPad app

```bash
# Backend test
cd backend/
swift test --filter "testDungeonListEndpoint"

# Frontend test
cd frontend/
npm run test -- --testNamePattern="DungeonGrid displays all dungeons"

# E2E test
npx playwright test tests/e2e/dungeon-list.spec.ts
```

### Test 2: Color-Coded Ability Cards
**User Story**: Healer views ability cards with color coding
**Validation**: Critical abilities show red, High orange, etc.

```bash
# Backend test - ability classification
swift test --filter "testAbilityDamageProfileEndpoint"

# Frontend test - color mapping
npm run test -- --testNamePattern="AbilityCard renders correct color"

# E2E test - visual validation
npx playwright test tests/e2e/ability-colors.spec.ts
```

### Test 3: Data Consistency
**User Story**: Content updated in shared data store appears in web app
**Validation**: Web app shows latest data matching iPad app

```bash
# Integration test
swift test --filter "testDataConsistencyBetweenClients"

# E2E test with data refresh
npx playwright test tests/e2e/data-sync.spec.ts
```

### Test 4: Chrome Browser Detection
**User Story**: User attempts access from non-Chrome browser
**Validation**: Clear error message displayed

```bash
# E2E test with different browsers
npx playwright test tests/e2e/browser-detection.spec.ts --project=firefox
npx playwright test tests/e2e/browser-detection.spec.ts --project=safari
```

### Test 5: Offline Error Handling
**User Story**: User loses internet connection during raid
**Validation**: Appropriate error message displayed

```bash
# E2E test with network offline
npx playwright test tests/e2e/offline-handling.spec.ts
```

## Sample Data

### War Within Season 1 Sample Data
```json
{
  "season": {
    "majorVersion": "11.0",
    "name": "The War Within Season 1",
    "isActive": true,
    "dungeons": [
      {
        "name": "Ara-Kara, City of Echoes",
        "shortName": "Ara-Kara",
        "healerNotes": "Focus on spread positioning for echoing abilities",
        "estimatedDuration": 35,
        "difficultyRating": 3,
        "bossEncounters": [
          {
            "name": "Avanoxx",
            "healingSummary": "Heavy raid damage during web phases",
            "positioning": "Stay spread for web mechanics",
            "cooldownPriority": "Save major cooldowns for Alerting Shrill",
            "orderIndex": 1,
            "abilities": [
              {
                "name": "Alerting Shrill",
                "description": "Piercing scream that damages all players",
                "damageProfile": "Critical",
                "healerAction": "Use major healing cooldown immediately",
                "castTime": 3,
                "cooldown": 45,
                "isChanneled": false,
                "affectedTargets": 5
              }
            ]
          }
        ]
      }
    ]
  }
}
```

## Development Workflow

### TDD Cycle (Constitutional Requirement)
1. **RED**: Write failing test first
2. **GREEN**: Implement minimal code to pass
3. **REFACTOR**: Improve code quality

```bash
# Example TDD workflow for new API endpoint
cd backend/

# 1. Write failing contract test
echo "Test for new endpoint" >> Tests/AppTests/ContractTests/NewEndpointTests.swift
swift test --filter "NewEndpointTests" # Should fail

# 2. Implement endpoint
echo "Minimal implementation" >> Sources/App/Controllers/NewController.swift
swift test --filter "NewEndpointTests" # Should pass

# 3. Refactor if needed
# Improve code quality, run tests again
```

### Git Commit Pattern
```bash
# Tests first, then implementation
git add Tests/
git commit -m "Add contract tests for boss abilities endpoint"

git add Sources/App/Controllers/
git commit -m "Implement boss abilities endpoint to pass contract tests"
```

## Performance Validation

### Backend Performance Tests
```bash
# Load testing with sample data
cd backend/
swift run App performance-test --endpoint /api/v1/seasons --requests 1000
```

### Frontend Performance Tests
```bash
# Chrome DevTools performance auditing
cd frontend/
npm run audit-performance

# Bundle size analysis
npm run analyze-bundle
```

### E2E Performance Tests
```bash
# Page load time validation (< 3 seconds requirement)
npx playwright test tests/e2e/performance.spec.ts
```

## Deployment

### Docker Compose Development
```yaml
# docker-compose.yml
version: '3.8'
services:
  database:
    image: postgres:14
    environment:
      POSTGRES_DB: healerkit
      POSTGRES_USER: healer
      POSTGRES_PASSWORD: mysecretpassword
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data

  backend:
    build: ./backend
    ports:
      - "8080:8080"
    depends_on:
      - database
    environment:
      DATABASE_URL: postgres://healer:mysecretpassword@database:5432/healerkit

  frontend:
    build: ./frontend
    ports:
      - "3000:80"
    depends_on:
      - backend

volumes:
  postgres_data:
```

### Quick Deploy
```bash
# Start all services
docker-compose up -d

# Check health
curl http://localhost:8080/api/v1/health
curl http://localhost:3000

# View logs
docker-compose logs -f backend
docker-compose logs -f frontend
```

## Troubleshooting

### Common Issues

1. **Database Connection Failed**
   ```bash
   # Check PostgreSQL is running
   docker ps | grep postgres

   # Test connection
   psql -h localhost -U healer -d healerkit -c "SELECT 1;"
   ```

2. **API Endpoint Not Found**
   ```bash
   # Verify backend is running
   curl http://localhost:8080/api/v1/health

   # Check route registration
   swift run App routes
   ```

3. **Chrome Browser Detection Issues**
   ```bash
   # Test user agent detection
   curl -H "User-Agent: Chrome/120.0.0.0" http://localhost:3000
   ```

4. **Frontend Build Errors**
   ```bash
   # Clear node modules and reinstall
   rm -rf node_modules package-lock.json
   npm install
   ```

## Success Criteria Checklist

- ✅ Backend API serves all required endpoints
- ✅ Frontend displays dungeons in Chrome browser
- ✅ Color-coded ability cards render correctly
- ✅ Data consistency between web and iPad versions
- ✅ Browser detection works for non-Chrome browsers
- ✅ Offline error handling displays appropriate messages
- ✅ Performance meets < 3 second load time requirement
- ✅ All user story validation tests pass
- ✅ TDD workflow followed with tests before implementation

This quickstart guide ensures rapid development setup and validates all functional requirements through automated testing.