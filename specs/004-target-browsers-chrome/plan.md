# Implementation Plan: Chrome Web App for HealerKit

**Branch**: `004-target-browsers-chrome` | **Date**: 2025-09-15 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/004-target-browsers-chrome/spec.md`

## Execution Flow (/plan command scope)
```
1. Load feature spec from Input path
   → If not found: ERROR "No feature spec at {path}"
2. Fill Technical Context (scan for NEEDS CLARIFICATION)
   → Detect Project Type from context (web=frontend+backend, mobile=app+api)
   → Set Structure Decision based on project type
3. Evaluate Constitution Check section below
   → If violations exist: Document in Complexity Tracking
   → If no justification possible: ERROR "Simplify approach first"
   → Update Progress Tracking: Initial Constitution Check
4. Execute Phase 0 → research.md
   → If NEEDS CLARIFICATION remain: ERROR "Resolve unknowns"
5. Execute Phase 1 → contracts, data-model.md, quickstart.md, agent-specific template file (e.g., `CLAUDE.md` for Claude Code, `.github/copilot-instructions.md` for GitHub Copilot, or `GEMINI.md` for Gemini CLI).
6. Re-evaluate Constitution Check section
   → If new violations: Refactor design, return to Phase 1
   → Update Progress Tracking: Post-Design Constitution Check
7. Plan Phase 2 → Describe task generation approach (DO NOT create tasks.md)
8. STOP - Ready for /tasks command
```

**IMPORTANT**: The /plan command STOPS at step 7. Phases 2-4 are executed by other commands:
- Phase 2: /tasks command creates tasks.md
- Phase 3-4: Implementation execution (manual or via tools)

## Summary
Chrome web application providing the same healer-focused dungeon encounter data as the existing iPad app, utilizing a shared data store for consistency. Self-hosted deployment targeting Chrome browser exclusively with online-only operation and identical visual hierarchy for critical ability recognition.

## Technical Context
**Language/Version**: NEEDS CLARIFICATION (backend for shared data store API, frontend for Chrome web app)
**Primary Dependencies**: NEEDS CLARIFICATION (web framework, database connector, frontend build tools)
**Storage**: Shared data store (replaces iPad's CoreData, format NEEDS CLARIFICATION - SQL/NoSQL/API)
**Testing**: NEEDS CLARIFICATION (web testing framework, API testing, browser automation)
**Target Platform**: Chrome browser + self-hosted server environment
**Project Type**: web (frontend Chrome app + backend shared data store API)
**Performance Goals**: < 3 second load times (matching iPad app requirement)
**Constraints**: Chrome-only, online-only, self-hosted deployment within organization network
**Scale/Scope**: Same 8 dungeons as iPad app, shared data consistency, healer-focused UI

## Constitution Check
*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

**Simplicity**:
- Projects: 2 (frontend, backend) ✓ (under max 3)
- Using framework directly? TBD in research - no wrapper classes planned
- Single data model? ✓ (shared entities from existing iPad app)
- Avoiding patterns? ✓ (direct API access, no Repository pattern unless proven necessary)

**Architecture**:
- EVERY feature as library? ✓ (will extend existing DungeonKit, AbilityKit, HealerUIKit)
- Libraries listed: WebDungeonKit (web data access), WebHealerUIKit (Chrome UI components), SharedAPIKit (API communication)
- CLI per library: ✓ (following existing pattern from project)
- Library docs: ✓ (will extend existing llms.txt format)

**Testing (NON-NEGOTIABLE)**:
- RED-GREEN-Refactor cycle enforced? ✓ (constitutional requirement)
- Git commits show tests before implementation? ✓ (will follow existing project TDD)
- Order: Contract→Integration→E2E→Unit strictly followed? ✓
- Real dependencies used? ✓ (shared data store, actual Chrome browser)
- Integration tests for: ✓ (new web libraries, API contracts, data store schema)
- FORBIDDEN: Implementation before test, skipping RED phase ✓

**Observability**:
- Structured logging included? ✓ (frontend logs to backend)
- Frontend logs → backend? ✓ (unified stream planned)
- Error context sufficient? ✓ (Chrome dev tools + backend logs)

**Versioning**:
- Version number assigned? TBD (will align with existing project versioning)
- BUILD increments on every change? ✓ (following project convention)
- Breaking changes handled? ✓ (parallel tests, shared data store migration)

## Project Structure

### Documentation (this feature)
```
specs/[###-feature]/
├── plan.md              # This file (/plan command output)
├── research.md          # Phase 0 output (/plan command)
├── data-model.md        # Phase 1 output (/plan command)
├── quickstart.md        # Phase 1 output (/plan command)
├── contracts/           # Phase 1 output (/plan command)
└── tasks.md             # Phase 2 output (/tasks command - NOT created by /plan)
```

### Source Code (repository root)
```
# Option 1: Single project (DEFAULT)
src/
├── models/
├── services/
├── cli/
└── lib/

tests/
├── contract/
├── integration/
└── unit/

# Option 2: Web application (when "frontend" + "backend" detected)
backend/
├── src/
│   ├── models/
│   ├── services/
│   └── api/
└── tests/

frontend/
├── src/
│   ├── components/
│   ├── pages/
│   └── services/
└── tests/

# Option 3: Mobile + API (when "iOS/Android" detected)
api/
└── [same as backend above]

ios/ or android/
└── [platform-specific structure]
```

**Structure Decision**: Option 2 - Web application (frontend Chrome app + backend shared data store API)

## Phase 0: Outline & Research
1. **Extract unknowns from Technical Context** above:
   - For each NEEDS CLARIFICATION → research task
   - For each dependency → best practices task
   - For each integration → patterns task

2. **Generate and dispatch research agents**:
   ```
   For each unknown in Technical Context:
     Task: "Research {unknown} for {feature context}"
   For each technology choice:
     Task: "Find best practices for {tech} in {domain}"
   ```

3. **Consolidate findings** in `research.md` using format:
   - Decision: [what was chosen]
   - Rationale: [why chosen]
   - Alternatives considered: [what else evaluated]

**Output**: research.md with all NEEDS CLARIFICATION resolved

## Phase 1: Design & Contracts
*Prerequisites: research.md complete*

1. **Extract entities from feature spec** → `data-model.md`:
   - Entity name, fields, relationships
   - Validation rules from requirements
   - State transitions if applicable

2. **Generate API contracts** from functional requirements:
   - For each user action → endpoint
   - Use standard REST/GraphQL patterns
   - Output OpenAPI/GraphQL schema to `/contracts/`

3. **Generate contract tests** from contracts:
   - One test file per endpoint
   - Assert request/response schemas
   - Tests must fail (no implementation yet)

4. **Extract test scenarios** from user stories:
   - Each story → integration test scenario
   - Quickstart test = story validation steps

5. **Update agent file incrementally** (O(1) operation):
   - Run `/scripts/bash/update-agent-context.sh claude` for your AI assistant
   - If exists: Add only NEW tech from current plan
   - Preserve manual additions between markers
   - Update recent changes (keep last 3)
   - Keep under 150 lines for token efficiency
   - Output to repository root

**Output**: data-model.md, /contracts/*, failing tests, quickstart.md, agent-specific file

## Phase 2: Task Planning Approach
*This section describes what the /tasks command will do - DO NOT execute during /plan*

**Task Generation Strategy**:
- Load `/templates/tasks-template.md` as base
- Generate tasks from Phase 1 design docs (contracts, data model, quickstart)
- Backend tasks: API contract tests → models → controllers → services
- Frontend tasks: Component tests → API client → UI components → pages
- Integration tasks: E2E tests → data sync validation → performance tests
- Infrastructure tasks: Database setup → Docker configuration → deployment

**Specific Task Categories**:

1. **Contract Tests** (Backend) [P]:
   - Task: Write API contract tests for /seasons endpoint
   - Task: Write API contract tests for /dungeons endpoint
   - Task: Write API contract tests for /bosses endpoint
   - Task: Write API contract tests for /abilities endpoint

2. **Data Models** (Backend) [P]:
   - Task: Create Season model with PostgreSQL integration
   - Task: Create Dungeon model with foreign key relationships
   - Task: Create BossEncounter model with validation rules
   - Task: Create Ability model with JSONB metadata support

3. **API Controllers** (Backend):
   - Task: Implement seasons controller with CRUD operations
   - Task: Implement dungeons controller with season filtering
   - Task: Implement boss encounters controller with dungeon filtering
   - Task: Implement abilities controller with damage profile filtering

4. **Frontend Components** [P]:
   - Task: Create DungeonGrid component with responsive layout
   - Task: Create AbilityCard component with color-coded damage profiles
   - Task: Create BossDetail component with healer-specific information
   - Task: Create ErrorBoundary component for Chrome browser detection

5. **API Integration** (Frontend):
   - Task: Create API client with TypeScript interfaces
   - Task: Implement data fetching hooks for React components
   - Task: Add error handling for offline scenarios
   - Task: Add loading states and optimistic updates

6. **E2E Tests**:
   - Task: Write Playwright test for dungeon list display
   - Task: Write Playwright test for ability card color coding
   - Task: Write Playwright test for browser detection
   - Task: Write Playwright test for data consistency validation

7. **Performance & Infrastructure**:
   - Task: Create Docker Compose configuration for development
   - Task: Set up database migrations and seed data
   - Task: Implement performance monitoring for < 3 second requirement
   - Task: Add structured logging for frontend → backend stream

**Ordering Strategy**:
- TDD order: Contract tests → Implementation → Integration tests
- Dependency order: Database → Backend API → Frontend → E2E tests
- Mark [P] for parallel execution (independent components)
- Critical path: Shared data store → API endpoints → Web UI → Integration

**Constitutional Compliance**:
- Every task follows RED-GREEN-Refactor cycle
- Tests written before implementation in every task
- Real dependencies used (PostgreSQL, Chrome browser)
- Library-first approach maintained (WebDungeonKit, WebHealerUIKit)

**Estimated Output**: 28-32 numbered, ordered tasks in tasks.md with clear dependencies and parallel execution markers

**IMPORTANT**: This phase is executed by the /tasks command, NOT by /plan

## Phase 3+: Future Implementation
*These phases are beyond the scope of the /plan command*

**Phase 3**: Task execution (/tasks command creates tasks.md)  
**Phase 4**: Implementation (execute tasks.md following constitutional principles)  
**Phase 5**: Validation (run tests, execute quickstart.md, performance validation)

## Complexity Tracking
*Fill ONLY if Constitution Check has violations that must be justified*

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| [e.g., 4th project] | [current need] | [why 3 projects insufficient] |
| [e.g., Repository pattern] | [specific problem] | [why direct DB access insufficient] |


## Progress Tracking
*This checklist is updated during execution flow*

**Phase Status**:
- [x] Phase 0: Research complete (/plan command)
- [x] Phase 1: Design complete (/plan command)
- [x] Phase 2: Task planning complete (/plan command - describe approach only)
- [ ] Phase 3: Tasks generated (/tasks command)
- [ ] Phase 4: Implementation complete
- [ ] Phase 5: Validation passed

**Gate Status**:
- [x] Initial Constitution Check: PASS
- [x] Post-Design Constitution Check: PASS
- [x] All NEEDS CLARIFICATION resolved
- [ ] Complexity deviations documented

---
*Based on Constitution v2.1.1 - See `/memory/constitution.md`*