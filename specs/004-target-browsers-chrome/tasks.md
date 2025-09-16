# Tasks: Chrome Web App for HealerKit

**Input**: Design documents from `/specs/004-target-browsers-chrome/`
**Prerequisites**: plan.md (required), research.md, data-model.md, contracts/

## Execution Flow (main)
```
1. Load plan.md from feature directory
   → Tech stack: Swift/Vapor backend, React/TypeScript frontend, PostgreSQL
   → Structure: Web app (backend/ and frontend/ directories)
2. Load optional design documents:
   → data-model.md: Extract entities: Season, Dungeon, BossEncounter, Ability
   → contracts/: api-specification.yaml → contract test tasks
   → research.md: Extract decisions → PostgreSQL, Docker setup
3. Generate tasks by category:
   → Setup: backend/frontend projects, database, Docker
   → Tests: API contract tests, component tests, E2E tests
   → Core: models, controllers, React components
   → Integration: database, API client, browser detection
   → Polish: performance, logging, documentation
4. Apply task rules:
   → Different files = mark [P] for parallel
   → Backend vs frontend = parallel [P]
   → Tests before implementation (TDD)
5. Number tasks sequentially (T001, T002...)
6. Generate dependency graph
7. Create parallel execution examples
8. SUCCESS: 32 tasks ready for execution
```

## Format: `[ID] [P?] Description`
- **[P]**: Can run in parallel (different files, no dependencies)
- Include exact file paths in descriptions

## Path Conventions
- **Web app**: `backend/` and `frontend/` directories
- Backend: Swift/Vapor project structure
- Frontend: React/TypeScript with Vite

## Phase 3.1: Setup
- [ ] T001 Create backend/ directory with Vapor project structure (Package.swift, Sources/App/, Tests/)
- [ ] T002 Create frontend/ directory with React/TypeScript project (package.json, src/, tests/)
- [ ] T003 [P] Configure Docker Compose for PostgreSQL database in docker-compose.yml
- [ ] T004 [P] Configure Swift Package Manager dependencies (Vapor, PostgresKit) in backend/Package.swift
- [ ] T005 [P] Configure npm dependencies (React, TypeScript, Vite, Playwright) in frontend/package.json
- [ ] T006 [P] Configure linting and formatting (SwiftLint in backend/, ESLint in frontend/)

## Phase 3.2: Database & Schema (MUST COMPLETE BEFORE 3.3)
**CRITICAL: Database schema MUST be created and validated before any data models**
- [ ] T007 Create PostgreSQL database schema in backend/Scripts/schema.sql (seasons, dungeons, boss_encounters, abilities tables)
- [ ] T008 Create database migration commands in backend/Sources/App/Migrations/
- [ ] T009 Create sample data seed script in backend/Scripts/seed-data.sql with War Within Season 1 data
- [ ] T010 Validate database schema with connection test in backend/Tests/AppTests/DatabaseTests/

## Phase 3.3: Tests First (TDD) ⚠️ MUST COMPLETE BEFORE 3.4
**CRITICAL: These tests MUST be written and MUST FAIL before ANY implementation**

### Backend API Contract Tests [P]
- [ ] T011 [P] Contract test GET /api/v1/seasons in backend/Tests/AppTests/ContractTests/SeasonsContractTests.swift
- [ ] T012 [P] Contract test GET /api/v1/seasons/{id} in backend/Tests/AppTests/ContractTests/SeasonsContractTests.swift
- [ ] T013 [P] Contract test GET /api/v1/seasons/{id}/dungeons in backend/Tests/AppTests/ContractTests/DungeonsContractTests.swift
- [ ] T014 [P] Contract test GET /api/v1/dungeons/{id} in backend/Tests/AppTests/ContractTests/DungeonsContractTests.swift
- [ ] T015 [P] Contract test GET /api/v1/dungeons/{id}/bosses in backend/Tests/AppTests/ContractTests/BossesContractTests.swift
- [ ] T016 [P] Contract test GET /api/v1/bosses/{id} in backend/Tests/AppTests/ContractTests/BossesContractTests.swift
- [ ] T017 [P] Contract test GET /api/v1/bosses/{id}/abilities in backend/Tests/AppTests/ContractTests/AbilitiesContractTests.swift
- [ ] T018 [P] Contract test GET /api/v1/abilities/{id} in backend/Tests/AppTests/ContractTests/AbilitiesContractTests.swift

### Frontend Component Tests [P]
- [ ] T019 [P] Component test DungeonGrid renders dungeon list in frontend/tests/components/DungeonGrid.test.tsx
- [ ] T020 [P] Component test AbilityCard shows correct color coding in frontend/tests/components/AbilityCard.test.tsx
- [ ] T021 [P] Component test BossDetail displays encounter information in frontend/tests/components/BossDetail.test.tsx
- [ ] T022 [P] Component test ErrorBoundary handles browser detection in frontend/tests/components/ErrorBoundary.test.tsx

### Integration Tests [P]
- [ ] T023 [P] Integration test dungeon list display user story in backend/Tests/AppTests/IntegrationTests/DungeonListIntegrationTests.swift
- [ ] T024 [P] Integration test data consistency between API calls in backend/Tests/AppTests/IntegrationTests/DataConsistencyTests.swift
- [ ] T025 [P] E2E test Chrome browser detection in frontend/tests/e2e/browser-detection.spec.ts
- [ ] T026 [P] E2E test offline error handling in frontend/tests/e2e/offline-handling.spec.ts

## Phase 3.4: Core Implementation (ONLY after tests are failing)

### Backend Data Models [P]
- [ ] T027 [P] Season model with PostgreSQL integration in backend/Sources/App/Models/Season.swift
- [ ] T028 [P] Dungeon model with foreign key relationships in backend/Sources/App/Models/Dungeon.swift
- [ ] T029 [P] BossEncounter model with validation rules in backend/Sources/App/Models/BossEncounter.swift
- [ ] T030 [P] Ability model with JSONB metadata support in backend/Sources/App/Models/Ability.swift

### Backend API Controllers
- [ ] T031 Seasons controller with CRUD operations in backend/Sources/App/Controllers/SeasonsController.swift
- [ ] T032 Dungeons controller with season filtering in backend/Sources/App/Controllers/DungeonsController.swift
- [ ] T033 Boss encounters controller with dungeon filtering in backend/Sources/App/Controllers/BossEncountersController.swift
- [ ] T034 Abilities controller with damage profile filtering in backend/Sources/App/Controllers/AbilitiesController.swift

### Frontend Components [P]
- [ ] T035 [P] DungeonGrid component with responsive layout in frontend/src/components/DungeonGrid/DungeonGrid.tsx
- [ ] T036 [P] AbilityCard component with color-coded damage profiles in frontend/src/components/AbilityCard/AbilityCard.tsx
- [ ] T037 [P] BossDetail component with healer-specific information in frontend/src/components/BossDetail/BossDetail.tsx
- [ ] T038 [P] ErrorBoundary component for Chrome browser detection in frontend/src/components/ErrorBoundary/ErrorBoundary.tsx

### Frontend API Integration
- [ ] T039 API client with TypeScript interfaces in frontend/src/services/api.ts
- [ ] T040 Data fetching hooks for React components in frontend/src/hooks/useHealerData.ts
- [ ] T041 Error handling for offline scenarios in frontend/src/services/errorHandler.ts
- [ ] T042 Loading states and optimistic updates in frontend/src/components/common/LoadingSpinner.tsx

## Phase 3.5: Integration
- [ ] T043 Connect models to PostgreSQL database in backend/Sources/App/configure.swift
- [ ] T044 CORS and security headers middleware in backend/Sources/App/Middleware/CORSMiddleware.swift
- [ ] T045 Request/response logging middleware in backend/Sources/App/Middleware/LoggingMiddleware.swift
- [ ] T046 Health check endpoint in backend/Sources/App/Controllers/HealthController.swift

## Phase 3.6: Polish
- [ ] T047 [P] Unit tests for validation rules in backend/Tests/AppTests/UnitTests/ValidationTests.swift
- [ ] T048 [P] Performance tests for < 3 second load time requirement in frontend/tests/performance/LoadTime.spec.ts
- [ ] T049 [P] Bundle size analysis and optimization in frontend/scripts/analyze-bundle.js
- [ ] T050 [P] Structured logging implementation for frontend → backend stream in frontend/src/services/logger.ts
- [ ] T051 Docker Compose production configuration in docker-compose.prod.yml
- [ ] T052 Remove code duplication and refactor shared utilities

## Dependencies
- Setup (T001-T006) before database (T007-T010)
- Database (T007-T010) before tests (T011-T026)
- Tests (T011-T026) before implementation (T027-T042)
- Models (T027-T030) before controllers (T031-T034)
- API (T031-T034) before frontend integration (T039-T042)
- Core implementation before integration (T043-T046)
- Implementation before polish (T047-T052)

## Parallel Example
```
# Launch backend contract tests together (T011-T018):
Task: "Contract test GET /api/v1/seasons in backend/Tests/AppTests/ContractTests/SeasonsContractTests.swift"
Task: "Contract test GET /api/v1/dungeons/{id} in backend/Tests/AppTests/ContractTests/DungeonsContractTests.swift"
Task: "Contract test GET /api/v1/bosses/{id}/abilities in backend/Tests/AppTests/ContractTests/AbilitiesContractTests.swift"

# Launch frontend component tests together (T019-T022):
Task: "Component test DungeonGrid renders dungeon list in frontend/tests/components/DungeonGrid.test.tsx"
Task: "Component test AbilityCard shows correct color coding in frontend/tests/components/AbilityCard.test.tsx"
Task: "Component test ErrorBoundary handles browser detection in frontend/tests/components/ErrorBoundary.test.tsx"

# Launch data models together (T027-T030):
Task: "Season model with PostgreSQL integration in backend/Sources/App/Models/Season.swift"
Task: "Dungeon model with foreign key relationships in backend/Sources/App/Models/Dungeon.swift"
Task: "Ability model with JSONB metadata support in backend/Sources/App/Models/Ability.swift"
```

## Critical User Stories Validation
Each task maps to specific user story requirements:
- T023: "Healer views dungeon list in Chrome browser"
- T025: "User attempts access from non-Chrome browser"
- T026: "User loses internet connection during raid"
- T048: "Performance meets < 3 second load time requirement"

## Constitutional Compliance
- ✅ TDD workflow: Tests (T011-T026) before implementation (T027-T042)
- ✅ Library-first: Models as standalone components with clear interfaces
- ✅ Real dependencies: PostgreSQL database, Chrome browser for E2E tests
- ✅ Structured logging: Frontend → backend unified stream (T045, T050)

## Notes
- [P] tasks = different files, no dependencies
- Verify tests fail before implementing
- Commit after each task completion
- Backend and frontend can be developed in parallel after database setup
- E2E tests require both backend and frontend running

## Task Generation Rules Applied
1. **From Contracts**: api-specification.yaml → 8 contract test tasks (T011-T018)
2. **From Data Model**: 4 entities → 4 model creation tasks (T027-T030)
3. **From User Stories**: 4 scenarios → 4 integration/E2E test tasks (T023-T026)
4. **Ordering**: Setup → Database → Tests → Models → Controllers → Components → Polish
5. **Parallel**: Different files marked [P], same file sequential

## Validation Checklist
- ✅ All API endpoints have corresponding contract tests
- ✅ All entities (Season, Dungeon, BossEncounter, Ability) have model tasks
- ✅ All tests come before implementation (T011-T026 before T027-T042)
- ✅ Parallel tasks truly independent (different files/projects)
- ✅ Each task specifies exact file path
- ✅ No [P] task modifies same file as another [P] task