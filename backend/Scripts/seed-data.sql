-- HealerKit Sample Data
-- War Within Season 1 sample data for development and testing

-- Insert active season
INSERT INTO seasons (id, major_version, name, is_active, release_date) VALUES
    ('550e8400-e29b-41d4-a716-446655440000', '11.0', 'The War Within Season 1', true, '2024-08-26 00:00:00')
ON CONFLICT (name) DO NOTHING;

-- Insert sample dungeon: Ara-Kara, City of Echoes
INSERT INTO dungeons (id, season_id, name, short_name, healer_notes, estimated_duration, difficulty_rating) VALUES
    ('550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440000', 'Ara-Kara, City of Echoes', 'Ara-Kara', 'Focus on spread positioning for echoing abilities. Heavy raid damage during web phases requires cooldown management.', 35, 3)
ON CONFLICT (season_id, name) DO NOTHING;

-- Insert sample boss encounter: Avanoxx
INSERT INTO boss_encounters (id, dungeon_id, name, healing_summary, positioning, cooldown_priority, order_index) VALUES
    ('550e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440001', 'Avanoxx', 'Heavy raid damage during web phases requires major cooldowns. Spread damage from echoing abilities needs consistent healing.', 'Stay spread for web mechanics, center for add phases. Avoid standing in toxic pools.', 'Save major cooldowns for Alerting Shrill phases. Use damage reduction for Web Bolt volleys.', 1)
ON CONFLICT (dungeon_id, name) DO NOTHING;

-- Insert sample abilities for Avanoxx
INSERT INTO abilities (id, boss_encounter_id, name, description, damage_profile, healer_action, cast_time, cooldown, is_channeled, affected_targets, metadata) VALUES
    ('550e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440002', 'Alerting Shrill', 'Piercing scream that damages all players and increases damage taken', 'Critical', 'Use major healing cooldown immediately. Prepare for follow-up damage.', 3, 45, false, 5, '{"priority": "highest", "followUp": "Web Bolt"}'),
    ('550e8400-e29b-41d4-a716-446655440004', '550e8400-e29b-41d4-a716-446655440002', 'Toxic Pools', 'Creates pools of acid that damage players standing in them', 'High', 'Heal damage over time effects. Coordinate movement callouts.', 2, 30, false, 3, '{"avoidable": true, "duration": 15}'),
    ('550e8400-e29b-41d4-a716-446655440005', '550e8400-e29b-41d4-a716-446655440002', 'Web Bolt', 'Targeted projectile that hits random players', 'Moderate', 'Spot heal targets. Watch for multiple hits on same player.', 1, 8, false, 2, '{"random": true, "stacks": false}'),
    ('550e8400-e29b-41d4-a716-446655440006', '550e8400-e29b-41d4-a716-446655440002', 'Entangling Webs', 'Roots players in place, requiring movement abilities or dispel', 'Mechanic', 'Dispel if available. Coordinate freedom abilities with team.', 2, 25, false, 4, '{"dispellable": true, "root": true}')
ON CONFLICT (boss_encounter_id, name) DO NOTHING;

-- Insert additional dungeons (placeholder data)
INSERT INTO dungeons (id, season_id, name, short_name, healer_notes, estimated_duration, difficulty_rating) VALUES
    ('550e8400-e29b-41d4-a716-446655440007', '550e8400-e29b-41d4-a716-446655440000', 'The Stonevault', 'Stonevault', 'Heavy physical damage phases. Coordinate defensive cooldowns.', 40, 4),
    ('550e8400-e29b-41d4-a716-446655440008', '550e8400-e29b-41d4-a716-446655440000', 'City of Threads', 'Threads', 'DOT management crucial. Maintain HoTs throughout encounters.', 38, 3),
    ('550e8400-e29b-41d4-a716-446655440009', '550e8400-e29b-41d4-a716-446655440000', 'The Dawnbreaker', 'Dawnbreaker', 'Frequent dispels required. High mobility healing needed.', 42, 4),
    ('550e8400-e29b-41d4-a716-44665544000a', '550e8400-e29b-41d4-a716-446655440000', 'Mists of Tirna Scithe', 'Mists', 'Nature damage focus. Coordinate movement for maze phases.', 36, 2),
    ('550e8400-e29b-41d4-a716-44665544000b', '550e8400-e29b-41d4-a716-446655440000', 'The Necrotic Wake', 'Wake', 'Undead mechanics. Disease dispels and fear breaks needed.', 39, 3),
    ('550e8400-e29b-41d4-a716-44665544000c', '550e8400-e29b-41d4-a716-446655440000', 'Siege of Boralus', 'Boralus', 'Ship mechanics. Position for cannon phases.', 44, 4),
    ('550e8400-e29b-41d4-a716-44665544000d', '550e8400-e29b-41d4-a716-446655440000', 'Grim Batol', 'Batol', 'Dragon encounters. High burst healing requirements.', 41, 5)
ON CONFLICT (season_id, name) DO NOTHING;