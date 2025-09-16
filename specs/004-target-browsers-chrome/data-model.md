# Data Model: Chrome Web App for HealerKit

**Date**: 2025-09-15
**Feature**: Chrome Web App for HealerKit
**Purpose**: Define shared data model for web and iPad consistency

## Entity Overview

The web app uses the same core entities as the existing iPad app, accessed through a shared PostgreSQL database instead of local CoreData.

## Core Entities

### Season
**Purpose**: Container for major WoW patch versions and associated dungeons

```typescript
interface Season {
  id: string;              // UUID primary key
  majorVersion: string;    // "11.0", "11.1", "11.2"
  name: string;           // "The War Within Season 1"
  isActive: boolean;      // Current active season flag
  releaseDate: Date;      // Season launch date
  dungeons: Dungeon[];    // Associated dungeons
  createdAt: Date;
  updatedAt: Date;
}
```

**Validation Rules**:
- majorVersion must match pattern `\d+\.\d+`
- Only one season can be active at a time
- name must be non-empty and unique
- releaseDate cannot be in future

**State Transitions**:
- Draft → Active (when season launches)
- Active → Archived (when new season activates)

### Dungeon
**Purpose**: Individual dungeon with healer-specific metadata

```typescript
interface Dungeon {
  id: string;                    // UUID primary key
  seasonId: string;              // Foreign key to Season
  name: string;                  // "Ara-Kara, City of Echoes"
  shortName: string;             // "Ara-Kara" for UI display
  healerNotes: string;           // Healer-specific guidance
  estimatedDuration: number;     // Minutes for completion
  difficultyRating: number;      // 1-5 healer difficulty scale
  bossEncounters: BossEncounter[]; // Associated bosses
  createdAt: Date;
  updatedAt: Date;
}
```

**Validation Rules**:
- name must be unique within season
- shortName max 20 characters
- estimatedDuration between 15-60 minutes
- difficultyRating between 1-5
- healerNotes max 500 characters

**Relationships**:
- belongsTo Season (seasonId foreign key)
- hasMany BossEncounters

### BossEncounter
**Purpose**: Individual boss fight with healing summary

```typescript
interface BossEncounter {
  id: string;              // UUID primary key
  dungeonId: string;       // Foreign key to Dungeon
  name: string;           // "Avanoxx"
  healingSummary: string; // Key healing requirements
  positioning: string;    // Healer positioning notes
  cooldownPriority: string; // Cooldown usage guidance
  abilities: Ability[];   // Boss abilities
  orderIndex: number;     // Boss order in dungeon (1, 2, 3)
  createdAt: Date;
  updatedAt: Date;
}
```

**Validation Rules**:
- name must be unique within dungeon
- orderIndex must be sequential within dungeon
- healingSummary max 300 characters
- positioning max 200 characters
- cooldownPriority max 200 characters

**Relationships**:
- belongsTo Dungeon (dungeonId foreign key)
- hasMany Abilities

### Ability
**Purpose**: Individual boss ability with damage profile and healer actions

```typescript
interface Ability {
  id: string;                  // UUID primary key
  bossEncounterId: string;     // Foreign key to BossEncounter
  name: string;               // "Alerting Shrill"
  description: string;        // Ability mechanics description
  damageProfile: DamageProfile; // Critical/High/Moderate/Mechanic
  healerAction: string;       // Required healer response
  castTime: number;           // Seconds (0 for instant)
  cooldown: number;           // Seconds between casts
  isChanneled: boolean;       // Whether ability channels
  affectedTargets: number;    // Number of players affected
  metadata: Record<string, any>; // JSON column for flexible data
  createdAt: Date;
  updatedAt: Date;
}
```

**Validation Rules**:
- name must be unique within boss encounter
- damageProfile must be valid enum value
- healerAction max 200 characters
- castTime >= 0, cooldown >= 0
- affectedTargets between 1-40

**Relationships**:
- belongsTo BossEncounter (bossEncounterId foreign key)

### DamageProfile (Enum)
**Purpose**: Color-coded damage classification for healer prioritization

```typescript
enum DamageProfile {
  CRITICAL = "Critical",     // Red - immediate action required
  HIGH = "High",            // Orange - significant healing needed
  MODERATE = "Moderate",    // Yellow - standard healing response
  MECHANIC = "Mechanic"     // Blue - positioning/utility focus
}
```

**Color Mapping**:
- Critical: #DC2626 (red-600)
- High: #EA580C (orange-600)
- Moderate: #CA8A04 (yellow-600)
- Mechanic: #2563EB (blue-600)

## Database Schema

### PostgreSQL Tables

```sql
-- Seasons table
CREATE TABLE seasons (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  major_version VARCHAR(10) NOT NULL,
  name VARCHAR(100) NOT NULL UNIQUE,
  is_active BOOLEAN NOT NULL DEFAULT false,
  release_date TIMESTAMP NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Dungeons table
CREATE TABLE dungeons (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  season_id UUID NOT NULL REFERENCES seasons(id) ON DELETE CASCADE,
  name VARCHAR(100) NOT NULL,
  short_name VARCHAR(20) NOT NULL,
  healer_notes TEXT,
  estimated_duration INTEGER NOT NULL,
  difficulty_rating INTEGER NOT NULL CHECK (difficulty_rating BETWEEN 1 AND 5),
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
  UNIQUE(season_id, name)
);

-- Boss encounters table
CREATE TABLE boss_encounters (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  dungeon_id UUID NOT NULL REFERENCES dungeons(id) ON DELETE CASCADE,
  name VARCHAR(100) NOT NULL,
  healing_summary TEXT,
  positioning TEXT,
  cooldown_priority TEXT,
  order_index INTEGER NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
  UNIQUE(dungeon_id, name),
  UNIQUE(dungeon_id, order_index)
);

-- Abilities table
CREATE TABLE abilities (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  boss_encounter_id UUID NOT NULL REFERENCES boss_encounters(id) ON DELETE CASCADE,
  name VARCHAR(100) NOT NULL,
  description TEXT,
  damage_profile VARCHAR(20) NOT NULL CHECK (damage_profile IN ('Critical', 'High', 'Moderate', 'Mechanic')),
  healer_action TEXT,
  cast_time INTEGER NOT NULL DEFAULT 0,
  cooldown INTEGER NOT NULL DEFAULT 0,
  is_channeled BOOLEAN NOT NULL DEFAULT false,
  affected_targets INTEGER NOT NULL DEFAULT 1,
  metadata JSONB,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
  UNIQUE(boss_encounter_id, name)
);

-- Indexes for performance
CREATE INDEX idx_dungeons_season_id ON dungeons(season_id);
CREATE INDEX idx_boss_encounters_dungeon_id ON boss_encounters(dungeon_id);
CREATE INDEX idx_abilities_boss_encounter_id ON abilities(boss_encounter_id);
CREATE INDEX idx_abilities_damage_profile ON abilities(damage_profile);
CREATE INDEX idx_seasons_is_active ON seasons(is_active);
```

### Constraints and Triggers

```sql
-- Ensure only one active season
CREATE UNIQUE INDEX idx_seasons_active ON seasons(is_active) WHERE is_active = true;

-- Update timestamps trigger
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_seasons_updated_at BEFORE UPDATE ON seasons FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_dungeons_updated_at BEFORE UPDATE ON dungeons FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_boss_encounters_updated_at BEFORE UPDATE ON boss_encounters FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_abilities_updated_at BEFORE UPDATE ON abilities FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
```

## API Response Models

### Simplified Response Models for Frontend

```typescript
// Lightweight models for API responses
interface SeasonResponse {
  id: string;
  majorVersion: string;
  name: string;
  isActive: boolean;
  dungeonCount: number;
}

interface DungeonResponse {
  id: string;
  name: string;
  shortName: string;
  healerNotes: string;
  estimatedDuration: number;
  difficultyRating: number;
  bossCount: number;
}

interface BossEncounterResponse {
  id: string;
  name: string;
  healingSummary: string;
  positioning: string;
  cooldownPriority: string;
  orderIndex: number;
  abilityCount: number;
}

interface AbilityResponse {
  id: string;
  name: string;
  description: string;
  damageProfile: DamageProfile;
  healerAction: string;
  castTime: number;
  cooldown: number;
  isChanneled: boolean;
  affectedTargets: number;
}
```

## Data Migration Strategy

### From iPad CoreData to Shared Database

1. **Export Phase**: Extract existing iPad data to JSON format
2. **Transform Phase**: Convert CoreData relationships to PostgreSQL foreign keys
3. **Import Phase**: Bulk load data into PostgreSQL with validation
4. **Verification Phase**: Compare record counts and sample data integrity

### Sample Migration Command
```bash
# Export from iPad app
dungeonkit export --format json --output migration-data.json

# Import to shared database
webdungeonkit import --file migration-data.json --validate --dry-run
webdungeonkit import --file migration-data.json --execute
```

## Performance Considerations

### Database Optimization
- Indexed foreign keys for join performance
- JSONB metadata column for flexible ability data
- Materialized views for complex aggregations if needed

### API Optimization
- Response pagination for large result sets
- Selective field loading (GraphQL-style field selection)
- Response caching for infrequently changed data

### Frontend Optimization
- Local state management for UI interactions
- Optimistic updates for better perceived performance
- Component memoization for expensive renders

This data model ensures consistency between iPad and web versions while optimizing for web-specific performance requirements.