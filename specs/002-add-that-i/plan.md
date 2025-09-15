# Implementation Plan: Mythic+ Healer's Field Manual iPad Application


**Branch**: `002-add-that-i` | **Date**: 2025-09-14 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/002-add-that-i/spec.md`

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
Develop a native iPad application for World of Warcraft Mythic+ healers targeting first-generation iPad Pro. The app provides offline access to encounter-specific healing information, with healer-focused content for The War Within Season 3.1 dungeons. Content updates align with major WoW patches (11.1 to 11.2) rather than hotfixes. Optimized for tablet reading with touch-friendly navigation and ability cards color-coded by damage severity.

## Technical Context
**Language/Version**: Swift 5.9 (minimum for first-gen iPad Pro compatibility)
**Primary Dependencies**: UIKit, SwiftUI (iOS 13+ hybrid approach), CoreData for local storage
**Storage**: CoreData with SQLite backing for offline dungeon/encounter data (< 500MB constraint)
**Testing**: XCTest for unit/integration tests, XCUITest for iPad-specific UI testing
**Target Platform**: iOS 13.1+ (first-generation iPad Pro maximum supported iOS version)
**Project Type**: mobile - native iPad application
**Performance Goals**: 60fps on first-gen iPad Pro, < 3s data load times, smooth scrolling on large encounter lists
**Constraints**: < 500MB storage, offline-capable, first-gen iPad Pro hardware limitations, major patch update cycle only
**Scale/Scope**: 8 dungeons, ~3-5 bosses per dungeon, ~5-10 abilities per boss, healer-focused content filtering
**Arguments**: app that will run on the very first ipad pro. Content only needs to be updated with new major patches (like 11.1 to 11.2)

## Constitution Check
*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

**Simplicity**:
- Projects: 1 (iPad app only - native mobile application)
- Using framework directly? YES (UIKit/SwiftUI directly, CoreData directly)
- Single data model? YES (unified CoreData model for all game entities)
- Avoiding patterns? YES (direct Core Data access, no repository pattern needed for local-only data)

**Architecture**:
- EVERY feature as library? YES (DungeonKit, EncounterKit, AbilityKit libraries)
- Libraries listed: DungeonKit (dungeon/boss data), EncounterKit (encounter logic), AbilityKit (ability classification), UIKit (reusable UI components)
- CLI per library: YES (testing CLIs for data validation, content import)
- Library docs: llms.txt format planned? YES (for each library module)

**Testing (NON-NEGOTIABLE)**:
- RED-GREEN-Refactor cycle enforced? YES (XCTest framework, failing tests first)
- Git commits show tests before implementation? YES (TDD commits required)
- Order: Contract→Integration→E2E→Unit strictly followed? YES (XCUITest E2E, XCTest integration/unit)
- Real dependencies used? YES (actual CoreData stack, real iOS simulator testing)
- Integration tests for: new libraries, CoreData schema changes, cross-library interactions
- FORBIDDEN: Implementation before test, skipping RED phase

**Observability**:
- Structured logging included? YES (iOS unified logging system, os_log)
- Frontend logs → backend? N/A (offline-only app, local logging)
- Error context sufficient? YES (detailed error states for offline scenarios)

**Versioning**:
- Version number assigned? 1.0.0 (MAJOR.MINOR.BUILD format)
- BUILD increments on every change? YES (automated via Xcode build numbers)
- Breaking changes handled? YES (CoreData migration strategies, backward compatibility)

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

**Structure Decision**: Option 3 (Mobile + API) - Native iPad application with offline data, using iOS project structure

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
- Each contract → contract test task [P]
- Each entity → model creation task [P] 
- Each user story → integration test task
- Implementation tasks to make tests pass

**Ordering Strategy**:
- TDD order: Tests before implementation 
- Dependency order: Models before services before UI
- Mark [P] for parallel execution (independent files)

**Estimated Output**: 25-30 numbered, ordered tasks in tasks.md

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
- [x] Complexity deviations documented (none required)

---
*Based on Constitution v2.1.1 - See `/memory/constitution.md`*