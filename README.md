# HealerKit - Chrome Web App

Chrome web application providing the same healer-focused dungeon encounter data as the existing iPad app, utilizing a shared data store for consistency. Built for World of Warcraft Mythic+ healers targeting Chrome browser exclusively with online-only operation.

## 🚀 Quick Start

### Prerequisites
- Docker and Docker Compose
- Chrome browser (latest version)

### Launch Application
```bash
# Start all services (database, backend API, frontend)
docker-compose up -d

# Check service health
curl http://localhost:8080/api/v1/health  # Backend API
curl http://localhost:3000/health         # Frontend
```

**Access the application**: http://localhost:3000

## 🏗️ Architecture

### Technology Stack
- **Backend**: Swift with Vapor framework
- **Frontend**: React with TypeScript
- **Database**: PostgreSQL with JSON columns
- **Testing**: XCTest, Jest, Playwright
- **Deployment**: Docker Compose

### Project Structure
```
healerkit/
├── backend/               # Swift/Vapor API server
│   ├── Sources/App/       # Models, Controllers, Services
│   ├── Tests/AppTests/    # Contract, Integration, Unit tests
│   └── Scripts/           # Database schema and seed data
├── frontend/              # React/TypeScript web app
│   ├── src/               # Components, Pages, Services, Hooks
│   ├── tests/             # Component and E2E tests
│   └── public/            # Static assets
├── docker-compose.yml     # Multi-service orchestration
└── specs/                 # Feature specifications and tasks
```

## 🎯 Key Features

### Functional Requirements ✅
- **Chrome Browser Exclusive**: Detection and error messaging for other browsers
- **Self-Hosted Deployment**: Docker Compose configuration for organizational networks
- **Shared Data Store**: PostgreSQL replaces iPad's CoreData for data consistency
- **Online-Only Operation**: Clear offline error handling with connectivity status
- **Performance**: < 3 second load times matching iPad app requirements
- **Visual Hierarchy**: Color-coded damage profiles (Critical/High/Moderate/Mechanic)

### User Stories Validated ✅
- **Healer views dungeon list**: DungeonGrid component with responsive layout
- **Color-coded ability cards**: AbilityCard with damage profile styling
- **Browser detection**: ErrorBoundary handles non-Chrome browsers
- **Offline handling**: Clear error messages when connectivity lost
- **Data consistency**: Shared database ensures iPad/web synchronization

## 🧪 Testing

The implementation follows Test-Driven Development (TDD) with comprehensive test coverage:

### Backend Tests
```bash
cd backend/
swift test                    # Run all Swift tests
swift test --filter ContractTests  # API contract tests only
```

### Frontend Tests
```bash
cd frontend/
npm test                     # Unit and component tests
npm run test:e2e            # End-to-end browser tests
npm run test:coverage       # Test coverage report
```

### Test Categories
- **Contract Tests**: 8 API endpoint validations
- **Component Tests**: 4 React component test suites
- **Integration Tests**: Database and user story validations
- **E2E Tests**: Chrome browser detection and offline handling

## 🛠️ Development

### Backend Development (Swift/Vapor)
```bash
cd backend/
swift run App migrate        # Apply database migrations
swift run App serve         # Start development server (localhost:8080)

# CLI tools for data management
dungeonkit validate --format json
abilitykit analyze --boss <uuid>
```

### Frontend Development (React/TypeScript)
```bash
cd frontend/
npm run dev                 # Start development server (localhost:3000)
npm run build              # Production build
npm run preview            # Preview production build
```

### Database Management
```bash
# Start PostgreSQL for development
docker run --name healerkit-postgres \
  -e POSTGRES_DB=healerkit \
  -e POSTGRES_USER=healer \
  -e POSTGRES_PASSWORD=mysecretpassword \
  -p 5432:5432 -d postgres:14

# Apply schema and seed data
psql -h localhost -U healer -d healerkit -f backend/Scripts/schema.sql
psql -h localhost -U healer -d healerkit -f backend/Scripts/seed-data.sql
```

## 📊 Sample Data

The application includes complete sample data for "The War Within Season 1":
- **8 Dungeons**: Including Ara-Kara, The Stonevault, City of Threads, etc.
- **Boss Encounters**: With healer-specific positioning and cooldown guidance
- **Abilities**: Color-coded by damage profile with healer action recommendations
- **Realistic Content**: "Alerting Shrill" (Critical), "Toxic Pools" (High), etc.

## 🚀 Production Deployment

### Self-Hosted Environment
```bash
# Production deployment
docker-compose -f docker-compose.prod.yml up -d

# Environment variables
DATABASE_HOST=your-db-host
DATABASE_PASSWORD=secure-password
VITE_API_BASE_URL=https://your-domain/api/v1
```

### Health Monitoring
- Backend: `GET /api/v1/health` - Database connectivity status
- Frontend: Built-in offline detection and error boundaries
- Logging: Structured logs with frontend → backend error streaming

## 🔧 API Reference

### Core Endpoints
```
GET /api/v1/seasons                    # List all seasons
GET /api/v1/seasons/{id}/dungeons      # Dungeons for season
GET /api/v1/dungeons/{id}/bosses       # Boss encounters
GET /api/v1/bosses/{id}/abilities      # Abilities with damage profiles
GET /api/v1/abilities/{id}             # Individual ability details
```

### Query Parameters
- `active_only=true` - Filter to active season only
- `damage_profile=Critical` - Filter abilities by damage profile

## 🎮 Usage for Healers

### Color-Coded Priority System
- **🔴 Critical**: Immediate action required (e.g., "Alerting Shrill")
- **🟠 High**: Significant healing needed (e.g., "Toxic Pools")
- **🟡 Moderate**: Standard healing response (e.g., "Web Bolt")
- **🔵 Mechanic**: Positioning/utility focus (e.g., "Entangling Webs")

### Typical Workflow
1. Select dungeon from grid view
2. Review boss encounters and healer notes
3. Study critical abilities for immediate recognition
4. Plan cooldown usage with positioning requirements
5. Reference during live Mythic+ encounters

## 📄 Constitutional Compliance

This implementation follows enterprise-grade development practices:
- **TDD Enforced**: 20+ tests written before implementation
- **Library-First**: Each feature as standalone Swift/TypeScript modules
- **Real Dependencies**: PostgreSQL database, actual Chrome browser testing
- **Performance Validated**: < 3 second load times on target hardware
- **Accessibility**: WCAG 2.1 AA compliance with VoiceOver support

## 🤝 Contributing

The codebase follows strict quality standards:
- Test-Driven Development (RED-GREEN-Refactor)
- SwiftLint and ESLint for code consistency
- Accessibility-first component design
- Performance monitoring and optimization

## 📞 Support

For deployment issues or feature requests:
- Check health endpoints for service status
- Review browser console for frontend errors
- Examine Docker logs for backend issues
- Validate database connectivity and schema

---

**Ready for immediate deployment** to Chrome browser environments with full healer workflow support for The War Within Season Mythic+ encounters
