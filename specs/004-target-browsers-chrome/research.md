# Phase 0: Research & Technology Decisions

**Date**: 2025-09-15
**Feature**: Chrome Web App for HealerKit
**Purpose**: Resolve all NEEDS CLARIFICATION items from Technical Context

## Research Areas

### 1. Backend Language/Framework for Shared Data Store API

**Decision**: Swift with Vapor framework
**Rationale**:
- Maintains consistency with existing iPad codebase (Swift)
- Vapor provides robust web framework capabilities for self-hosted deployment
- Can reuse existing data models from DungeonKit, AbilityKit without translation layer
- Strong type safety and performance characteristics match project requirements

**Alternatives Considered**:
- Python/FastAPI: Would require data model translation, additional complexity
- Node.js/Express: JavaScript type safety concerns, unfamiliar to team
- Go/Gin: High performance but would require complete model rewrite

### 2. Frontend Framework for Chrome Web App

**Decision**: React with TypeScript
**Rationale**:
- TypeScript provides type safety similar to Swift
- React component model maps well to existing HealerUIKit patterns
- Chrome optimization capabilities (Chrome DevTools, modern JS features)
- Strong ecosystem for testing and build tools
- Familiar patterns for web developers joining project

**Alternatives Considered**:
- Vue.js: Smaller ecosystem, less TypeScript integration
- Angular: Too heavyweight for focused healer tool
- Vanilla JavaScript: Would require building component system from scratch

### 3. Shared Data Store Format

**Decision**: PostgreSQL with JSON columns for ability data
**Rationale**:
- Relational structure matches existing CoreData entity relationships
- JSON columns handle flexible ability metadata efficiently
- ACID transactions ensure data consistency between iPad and web
- Self-hosted deployment requirement satisfied
- Strong Swift/Vapor integration via PostgresKit

**Alternatives Considered**:
- SQLite: File-based, doesn't support concurrent iPad/web access well
- MongoDB: NoSQL flexibility but loses type safety benefits
- Redis: In-memory, not suitable for persistent shared data store

### 4. API Design Pattern

**Decision**: RESTful API with OpenAPI specification
**Rationale**:
- Maps directly to existing CRUD operations on Season/Dungeon/BossEncounter/Ability
- OpenAPI enables contract-first development (constitutional requirement)
- Standard HTTP semantics for GET/POST/PUT/DELETE operations
- Easy to document and test with existing tools

**Alternatives Considered**:
- GraphQL: Overkill for simple CRUD operations, adds complexity
- RPC: Less web-standard, harder to debug and document

### 5. Testing Framework Selection

**Decision**:
- Backend: XCTest (Swift) for API tests
- Frontend: Jest + React Testing Library for component tests
- Integration: Playwright for Chrome browser automation

**Rationale**:
- XCTest maintains consistency with existing project testing
- Jest provides excellent TypeScript support and mocking
- Playwright specifically optimized for Chrome automation testing
- All frameworks support TDD red-green-refactor cycle

**Alternatives Considered**:
- Cypress: Good but Playwright has better Chrome-specific features
- Selenium: Older, less reliable than Playwright
- Mocha/Chai: Jest has better React integration

### 6. Build and Deployment Tools

**Decision**:
- Backend: Swift Package Manager + Docker for containerization
- Frontend: Vite + TypeScript for build tooling
- Deployment: Docker Compose for self-hosted environment

**Rationale**:
- Swift Package Manager already used in project
- Vite provides fast development builds and Chrome optimization
- Docker Compose simplifies self-hosted deployment requirement
- All tools support development/production environment consistency

**Alternatives Considered**:
- Webpack: Slower builds than Vite, more complex configuration
- Kubernetes: Overkill for single-org self-hosted deployment

## Architecture Decisions

### Data Synchronization Strategy
- **Approach**: Single source of truth in PostgreSQL database
- **iPad App**: Migrate from CoreData to API calls to shared database
- **Web App**: Direct API calls to same database
- **Consistency**: Database constraints and transactions ensure data integrity

### Performance Optimization
- **Backend**: Response caching for dungeon/ability data (infrequently changed)
- **Frontend**: React.memo for ability card components, lazy loading for dungeons
- **Network**: HTTP/2 for efficient multiple resource loading
- **Target**: < 3 second load time maintained from existing iPad app

### Browser Compatibility Strategy
- **Primary**: Chrome latest (matches requirement)
- **Detection**: User-agent checking with clear messaging for unsupported browsers
- **Features**: Modern JavaScript (ES2022), CSS Grid, Fetch API without polyfills

## Risk Assessment

### High Priority Risks
1. **Data Migration**: Moving iPad app from CoreData to shared API
   - **Mitigation**: Parallel testing, gradual rollout, rollback plan

2. **Performance Regression**: Web app slower than native iPad
   - **Mitigation**: Performance benchmarking, Chrome-specific optimizations

### Medium Priority Risks
1. **Self-hosted Deployment**: Organization network/security constraints
   - **Mitigation**: Docker containerization, configuration documentation

2. **Chrome-only Limitation**: Users attempting access from other browsers
   - **Mitigation**: Clear error messaging, browser detection

## Implementation Dependencies

### Prerequisites
1. PostgreSQL database setup in self-hosted environment
2. Docker infrastructure for backend deployment
3. Web server configuration for frontend hosting

### External Dependencies
- PostgresKit (Swift database connector)
- Vapor (Swift web framework)
- React 18+ with TypeScript support
- Playwright for browser testing

## Success Criteria Validation

All research decisions align with functional requirements:
- ✅ Chrome browser exclusive support
- ✅ Self-hosted deployment capability
- ✅ Shared data store for consistency
- ✅ Online-only operation (no offline storage)
- ✅ Performance matching iPad app (< 3 seconds)
- ✅ Visual hierarchy preservation in web UI

## Next Phase Prerequisites

All NEEDS CLARIFICATION items resolved:
- ✅ Backend: Swift/Vapor with PostgreSQL
- ✅ Frontend: React/TypeScript for Chrome
- ✅ Testing: XCTest/Jest/Playwright combination
- ✅ Deployment: Docker-based self-hosted solution

Ready for Phase 1: Design & Contracts