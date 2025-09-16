-- HealerKit Database Schema
-- PostgreSQL schema for Chrome web app and iPad shared data store

-- Extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Seasons table
CREATE TABLE IF NOT EXISTS seasons (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    major_version VARCHAR(10) NOT NULL,
    name VARCHAR(100) NOT NULL UNIQUE,
    is_active BOOLEAN NOT NULL DEFAULT false,
    release_date TIMESTAMP NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),

    -- Constraints
    CONSTRAINT seasons_major_version_format CHECK (major_version ~ '^\d+\.\d+$'),
    CONSTRAINT seasons_release_date_check CHECK (release_date <= NOW())
);

-- Ensure only one active season
CREATE UNIQUE INDEX IF NOT EXISTS idx_seasons_active ON seasons(is_active) WHERE is_active = true;

-- Dungeons table
CREATE TABLE IF NOT EXISTS dungeons (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    season_id UUID NOT NULL REFERENCES seasons(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    short_name VARCHAR(20) NOT NULL,
    healer_notes TEXT,
    estimated_duration INTEGER NOT NULL,
    difficulty_rating INTEGER NOT NULL CHECK (difficulty_rating BETWEEN 1 AND 5),
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),

    -- Constraints
    UNIQUE(season_id, name),
    CONSTRAINT dungeons_duration_check CHECK (estimated_duration BETWEEN 15 AND 60)
);

-- Boss encounters table
CREATE TABLE IF NOT EXISTS boss_encounters (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    dungeon_id UUID NOT NULL REFERENCES dungeons(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    healing_summary TEXT,
    positioning TEXT,
    cooldown_priority TEXT,
    order_index INTEGER NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),

    -- Constraints
    UNIQUE(dungeon_id, name),
    UNIQUE(dungeon_id, order_index),
    CONSTRAINT boss_order_positive CHECK (order_index > 0)
);

-- Abilities table
CREATE TABLE IF NOT EXISTS abilities (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
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

    -- Constraints
    UNIQUE(boss_encounter_id, name),
    CONSTRAINT abilities_cast_time_check CHECK (cast_time >= 0),
    CONSTRAINT abilities_cooldown_check CHECK (cooldown >= 0),
    CONSTRAINT abilities_targets_check CHECK (affected_targets BETWEEN 1 AND 40)
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_dungeons_season_id ON dungeons(season_id);
CREATE INDEX IF NOT EXISTS idx_boss_encounters_dungeon_id ON boss_encounters(dungeon_id);
CREATE INDEX IF NOT EXISTS idx_abilities_boss_encounter_id ON abilities(boss_encounter_id);
CREATE INDEX IF NOT EXISTS idx_abilities_damage_profile ON abilities(damage_profile);
CREATE INDEX IF NOT EXISTS idx_seasons_is_active ON seasons(is_active);

-- Update timestamp triggers
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply triggers
DROP TRIGGER IF EXISTS update_seasons_updated_at ON seasons;
CREATE TRIGGER update_seasons_updated_at
    BEFORE UPDATE ON seasons
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_dungeons_updated_at ON dungeons;
CREATE TRIGGER update_dungeons_updated_at
    BEFORE UPDATE ON dungeons
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_boss_encounters_updated_at ON boss_encounters;
CREATE TRIGGER update_boss_encounters_updated_at
    BEFORE UPDATE ON boss_encounters
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_abilities_updated_at ON abilities;
CREATE TRIGGER update_abilities_updated_at
    BEFORE UPDATE ON abilities
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();