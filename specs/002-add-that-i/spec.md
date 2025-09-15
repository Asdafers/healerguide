# Feature Specification: Mythic+ Healer's Field Manual iPad Application

**Feature Branch**: `002-add-that-i`
**Created**: 2025-09-13
**Status**: Draft
**Input**: User description: "add that I want the app that will run on the very first ipad pro. Content only needs to be updated with new major patches (like 11.1 to 11.2)"

## Execution Flow (main)
```
1. Parse user description from Input
   ’ Extracted: Update specification for first-generation iPad Pro target platform with major patch content updates
2. Extract key concepts from description
   ’ Actors: WoW healers using first-generation iPad Pro
   ’ Actions: view encounter data, select dungeons/bosses, reference healing mechanics
   ’ Data: dungeon encounters, boss abilities, healing strategies
   ’ Constraints: first-gen iPad Pro compatibility, major patch update cycle (11.1 to 11.2)
3. For each unclear aspect:
   ’ All platform and update clarifications resolved
4. Fill User Scenarios & Testing section 
5. Generate Functional Requirements 
6. Identify Key Entities 
7. Run Review Checklist 
8. Return: SUCCESS (spec ready for planning)
```

---

## ¡ Quick Guidelines
-  Focus on WHAT users need and WHY
- L Avoid HOW to implement (no tech stack, APIs, code structure)
- =e Written for business stakeholders, not developers

---

## User Scenarios & Testing

### Primary User Story
As a World of Warcraft healer preparing for or actively participating in Mythic+ dungeons, I need quick access to encounter-specific healing information on my first-generation iPad Pro so that I can proactively manage healing cooldowns, anticipate damage patterns, and understand my role-specific responsibilities without sifting through general dungeon guides meant for all roles.

### Acceptance Scenarios
1. **Given** I am about to enter "Ara-Kara, City of Echoes" dungeon, **When** I open the app on my first-generation iPad Pro and select this dungeon, **Then** I see a list of all bosses in chronological encounter order displayed clearly on the tablet screen
2. **Given** I select the "Avanoxx" boss encounter, **When** the boss details load, **Then** I see a healer summary and color-coded ability cards showing damage profiles, my required actions, and critical insights optimized for tablet viewing
3. **Given** I am in combat and need quick reference, **When** I view an ability card for "Alerting Shrill", **Then** I immediately see it's a Critical damage profile requiring a pre-planned group healing cooldown with text large enough to read quickly on iPad
4. **Given** I have no internet connection during gameplay, **When** I open the app, **Then** all dungeon and encounter data is available offline on my iPad Pro
5. **Given** I want to return to the dungeon list, **When** I use the navigation, **Then** I can easily move between boss, dungeon, and home screens using touch-optimized controls
6. **Given** a new major patch is released (e.g., 11.1 to 11.2), **When** I open the app after the update, **Then** I see refreshed dungeon content reflecting any mechanical changes introduced in the major patch

### Edge Cases
- What happens when the app is running on older iPad Pro hardware with limited performance capabilities?
- How does the system handle content that becomes outdated mid-season due to hotfixes between major patches?
- What occurs if a user tries to use touch gestures not optimized for the iPad Pro's screen size?

## Requirements

### Functional Requirements
- **FR-001**: System MUST display all 8 dungeons from The War Within Season 3.1 in an organized grid or list format optimized for first-generation iPad Pro screen dimensions
- **FR-002**: System MUST show bosses for each dungeon in chronological encounter order with touch-friendly navigation
- **FR-003**: System MUST present healer-specific encounter data using the "Boss Ability Quick Reference" format (Ability Name & Type, Target(s), Damage Profile, Healer's Primary Action, Critical Insight) with typography optimized for tablet reading
- **FR-004**: System MUST color-code ability cards based on damage profile severity (Critical, High, Moderate, Mechanic) with sufficient contrast for iPad Pro display
- **FR-005**: System MUST provide a concise healer summary for each boss encounter formatted for tablet screen real estate
- **FR-006**: System MUST function completely offline once initial data is loaded, suitable for gaming environments with unreliable internet
- **FR-007**: System MUST provide persistent navigation allowing easy movement between home, dungeon, and boss screens using iPad-optimized touch controls
- **FR-008**: System MUST include search functionality to find specific dungeons or bosses by name with iPad-friendly search interface
- **FR-009**: System MUST filter out non-healer relevant information (tank positioning details, DPS rotations) to maintain focus on tablet display
- **FR-010**: System MUST present information optimized for quick reference during active gameplay on iPad Pro form factor
- **FR-011**: System MUST run compatibly on first-generation iPad Pro (released November 2015) including iOS version limitations and hardware constraints
- **FR-012**: System MUST update content only with major World of Warcraft patches (e.g., 11.1 to 11.2) rather than minor hotfixes or weekly updates
- **FR-013**: System MUST support portrait and landscape orientations on iPad Pro for flexible viewing during gameplay setup

### Non-Functional Requirements
- **NFR-001**: Application MUST maintain 60fps performance on first-generation iPad Pro hardware
- **NFR-002**: Application MUST load dungeon data within 3 seconds on first-generation iPad Pro storage speeds
- **NFR-003**: Application MUST consume less than 500MB of storage space to accommodate older iPad storage limitations

### Key Entities
- **Season**: Represents a specific Mythic+ season (e.g., "The War Within Season 3.1") containing a curated set of dungeons, updated only with major patches
- **Dungeon**: A game instance containing multiple boss encounters, with name, difficulty level, and chronological boss order
- **Boss Encounter**: A specific fight within a dungeon, containing healer summary and multiple abilities, formatted for tablet display
- **Boss Ability**: Individual mechanics with type classification, target information, damage profile, required healer action, and critical insights optimized for quick tablet reference
- **Damage Profile**: Severity classification system (Critical, High, Moderate, Mechanic) used for visual prioritization and healer decision-making with iPad-appropriate color coding
- **Major Patch**: World of Warcraft content updates that warrant application data refresh (e.g., 11.1 to 11.2), excluding hotfixes and minor updates

---

## Review & Acceptance Checklist

### Content Quality
- [x] No implementation details (languages, frameworks, APIs)
- [x] Focused on user value and business needs
- [x] Written for non-technical stakeholders
- [x] All mandatory sections completed

### Requirement Completeness
- [x] No [NEEDS CLARIFICATION] markers remain
- [x] Requirements are testable and unambiguous
- [x] Success criteria are measurable
- [x] Scope is clearly bounded
- [x] Dependencies and assumptions identified

---

## Execution Status

- [x] User description parsed
- [x] Key concepts extracted
- [x] Ambiguities marked (none remaining)
- [x] User scenarios defined
- [x] Requirements generated
- [x] Entities identified
- [x] Review checklist passed

---