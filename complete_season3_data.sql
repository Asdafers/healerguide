-- Complete Season 3 Content Population
-- Adding missing boss encounters and abilities for all dungeons

-- Get the season ID for Season 3
\set season_id '550E8400-E29B-41D4-A716-446655440000'

-- Complete missing boss encounters for incomplete dungeons

-- 1. Eco-Dome Aldani bosses
INSERT INTO boss_encounters (id, dungeon_id, name, healing_summary, positioning, cooldown_priority, order_index)
VALUES
('A1B2C3D4-E5F6-7890-ABCD-EF1234567890', '7BAACB0B-9F27-4986-902A-9388ED91ABAC', 'Vx''lok', 'Environmental damage requires consistent healing. Void zones cause heavy damage.', 'Stay mobile for void zones. Position for quick healing access.', 'Use cooldowns for Toxic Eruption. Dispel environmental debuffs.', 1),
('B2C3D4E5-F6G7-8901-BCDE-F23456789012', '7BAACB0B-9F27-4986-902A-9388ED91ABAC', 'Kyrioss', 'High burst damage from nature abilities. Group healing priority.', 'Stack for group heals. Avoid lightning zones.', 'Major cooldowns for Storm Surge. Prepare for chain damage.', 2),
('C3D4E5F6-G7H8-9012-CDEF-345678901234', '7BAACB0B-9F27-4986-902A-9388ED91ABAC', 'Overgrown Ancient', 'Sustained damage phases with movement requirements.', 'Heal through root mechanics. Coordinate freedom abilities.', 'Time cooldowns for Overgrowth phases. Maintain healing during movement.', 3);

-- 2. Operation: Floodgate bosses
INSERT INTO boss_encounters (id, dungeon_id, name, healing_summary, positioning, cooldown_priority, order_index)
VALUES
('D4E5F6G7-H8I9-0123-DEFG-456789012345', '09D54086-59A6-445A-BE2C-EE90479CCD88', 'Izo the Grand Splicer', 'Mechanical damage with engineering debuffs requiring dispels.', 'Position for quick dispel access. Avoid mechanical hazards.', 'Dispel Splice debuffs immediately. Use cooldowns for Overcharge.', 1),
('E5F6G7H8-I9J0-1234-EFGH-567890123456', '09D54086-59A6-445A-BE2C-EE90479CCD88', 'Voidstone Monstrosity', 'Void damage with stacking debuffs. High tank healing required.', 'Focus tank healing. Position for void zone avoidance.', 'Stack cooldowns for Void Pulse. Prepare for tank spikes.', 2),
('F6G7H8I9-J0K1-2345-FGHI-678901234567', '09D54086-59A6-445A-BE2C-EE90479CCD88', 'Skarmorak', 'Water-based mechanics with drowning effects. Movement healing.', 'Heal during water phases. Coordinate with breathing mechanics.', 'Time heals for air phases. Use movement healing abilities.', 3);

-- 3. Priory of the Sacred Flame bosses
INSERT INTO boss_encounters (id, dungeon_id, name, healing_summary, positioning, cooldown_priority, order_index)
VALUES
('G7H8I9J0-K1L2-3456-GHIJ-789012345678', 'FDC7D9FB-5128-4CB6-8967-CDC0A92ADFA7', 'Captain Dailcry', 'Holy fire damage with burn effects. Dispel-heavy encounter.', 'Dispel burn effects quickly. Position for fire avoidance.', 'Dispel Sacred Burns. Cooldowns for Flame Burst.', 1),
('H8I9J0K1-L2M3-4567-HIJK-890123456789', 'FDC7D9FB-5128-4CB6-8967-CDC0A92ADFA7', 'Baron Braunpyke', 'Shadow and fire mix. High single-target healing phases.', 'Focus targeted players. Avoid shadow zones.', 'Major heals for Shadow Fire. Prepare for burn phases.', 2),
('I9J0K1L2-M3N4-5678-IJKL-901234567890', 'FDC7D9FB-5128-4CB6-8967-CDC0A92ADFA7', 'Prioress Murrpray', 'Healing absorption fights. Requires burst healing.', 'Stack for group healing. Coordinate absorption removal.', 'Burst heal through shields. Time cooldowns for absorption.', 3);

-- 4. Tazavesh: Streets of Wonder bosses
INSERT INTO boss_encounters (id, dungeon_id, name, healing_summary, positioning, cooldown_priority, order_index)
VALUES
('J0K1L2M3-N4O5-6789-JKLM-012345678901', '5BB8BA5C-FA03-444A-888B-1E46891ADAFD', 'Zo''phex', 'Arcane damage with portal mechanics. Movement healing required.', 'Heal through portals. Position for arcane avoidance.', 'Cooldowns for Arcane Blast. Maintain healing during teleports.', 1),
('K1L2M3N4-O5P6-7890-KLMN-123456789012', '5BB8BA5C-FA03-444A-888B-1E46891ADAFD', 'The Menagerie', 'Multi-target encounter with various damage types.', 'Spread healing priority. Quick target switching.', 'Flexible cooldown usage. Adapt to active creature.', 2),
('L2M3N4O5-P6Q7-8901-LMNO-234567890123', '5BB8BA5C-FA03-444A-888B-1E46891ADAFD', 'Mailroom Mayhem', 'Chaos damage with random target selection.', 'Quick response healing. High mobility required.', 'Instant heals priority. React to damage spikes.', 3),
('M3N4O5P6-Q7R8-9012-MNOP-345678901234', '5BB8BA5C-FA03-444A-888B-1E46891ADAFD', 'Auction House', 'Economic-themed mechanics with debuff trading.', 'Coordinate debuff management. Group healing focus.', 'Manage debuff stacks. Time cooldowns for bid phases.', 4);

-- 5. Tazavesh: So'leah's Gambit bosses
INSERT INTO boss_encounters (id, dungeon_id, name, healing_summary, positioning, cooldown_priority, order_index)
VALUES
('N4O5P6Q7-R8S9-0123-NOPQ-456789012345', '667609F7-E5A2-4CBB-AE60-6E510A5198E5', 'Myza''s Oasis', 'Nature healing with oasis mechanics. Healing over time focus.', 'Use oasis benefits. Position for nature alignment.', 'HOTs during oasis phases. Cooldowns for desert damage.', 1),
('O5P6Q7R8-S9T0-1234-OPQR-567890123456', '667609F7-E5A2-4CBB-AE60-6E510A5198E5', 'So''azmi', 'Broker magic with reality manipulation. Burst healing required.', 'Adapt to reality shifts. Focus burst healing.', 'Stack cooldowns for reality breaks. Quick response healing.', 2),
('P6Q7R8S9-T0U1-2345-PQRS-678901234567', '667609F7-E5A2-4CBB-AE60-6E510A5198E5', 'Hylbrande', 'Weapon mastery encounter with physical damage spikes.', 'Tank healing priority. Position for weapon avoidance.', 'Major cooldowns for weapon combos. Sustained tank healing.', 3),
('Q7R8S9T0-U1V2-3456-QRST-789012345678', '667609F7-E5A2-4CBB-AE60-6E510A5198E5', 'So''leah', 'Final boss with multiple phases. All healing techniques required.', 'Adapt to phase changes. Flexible positioning.', 'Phase-specific cooldowns. Master all healing styles.', 4);

-- Add missing abilities for existing bosses

-- Complete Anub'zekt abilities (currently 0/3)
INSERT INTO abilities (id, boss_encounter_id, name, description, damage_profile, healer_action, cast_time, cooldown, is_channeled, affected_targets)
VALUES
('ANUB001-ZEKT-4001-8001-ABILITY00001', '190C23F6-598F-4EAD-8026-8C43151B3443', 'Burrow Charge', 'Charges through the ground, dealing damage to players in a line', 'High', 'Heal charge victims immediately. Prepare for follow-up damage.', 2000, 25000, false, 3),
('ANUB002-ZEKT-4002-8002-ABILITY00002', '190C23F6-598F-4EAD-8026-8C43151B3443', 'Eye of the Swarm', 'Marks players for swarm attention, causing stacking damage', 'Critical', 'Major cooldown required. Focus marked targets.', 1500, 35000, false, 2),
('ANUB003-ZEKT-4003-8003-ABILITY00003', '190C23F6-598F-4EAD-8026-8C43151B3443', 'Infest', 'Applies disease that spreads if not dispelled quickly', 'Mechanic', 'Dispel immediately. Prevent spread to other players.', 3000, 20000, false, 1);

-- Complete Ki'katal abilities (currently 0/3)
INSERT INTO abilities (id, boss_encounter_id, name, description, damage_profile, healer_action, cast_time, cooldown, is_channeled, affected_targets)
VALUES
('KIKA001-TALE-4001-8001-ABILITY00001', 'D4744154-B168-4A65-A8CC-D59451662471', 'Cultivated Poison', 'Poison that requires careful dispel timing to avoid explosion', 'Critical', 'Time dispels carefully. Coordinate with team.', 2500, 30000, false, 2),
('KIKA002-TALE-4002-8002-ABILITY00002', 'D4744154-B168-4A65-A8CC-D59451662471', 'Erupting Webs', 'Web explosions that require movement while healing', 'High', 'Maintain healing during movement. Use instant casts.', 1800, 18000, false, 4),
('KIKA003-TALE-4003-8003-ABILITY00003', 'D4744154-B168-4A65-A8CC-D59451662471', 'Harvest Essence', 'Drains life force from multiple targets simultaneously', 'High', 'Group healing required. Stack healing cooldowns.', 4000, 40000, true, 5);

-- Add sample abilities for new bosses (3 per boss for validation)

-- Eco-Dome Aldani abilities
INSERT INTO abilities (id, boss_encounter_id, name, description, damage_profile, healer_action, cast_time, cooldown, is_channeled, affected_targets)
VALUES
-- Vx'lok abilities
('VX001-LOCK-4001-8001-ABILITY00001', 'A1B2C3D4-E5F6-7890-ABCD-EF1234567890', 'Toxic Eruption', 'Environmental explosion causing raid-wide damage', 'Critical', 'Major healing cooldown required for raid damage.', 3000, 45000, false, 5),
('VX002-LOCK-4002-8002-ABILITY00002', 'A1B2C3D4-E5F6-7890-ABCD-EF1234567890', 'Void Zones', 'Creates damaging zones requiring movement', 'High', 'Heal through movement. Use instant cast abilities.', 2000, 15000, false, 3),
('VX003-LOCK-4003-8003-ABILITY00003', 'A1B2C3D4-E5F6-7890-ABCD-EF1234567890', 'Environmental Debuff', 'Applies nature damage over time requiring dispel', 'Mechanic', 'Dispel nature effects quickly. Monitor DoT stacks.', 1500, 12000, false, 2),

-- Kyrioss abilities
('KYR001-IOSS-4001-8001-ABILITY00001', 'B2C3D4E5-F6G7-8901-BCDE-F23456789012', 'Storm Surge', 'Lightning damage affecting grouped players', 'Critical', 'Stack healing cooldowns for lightning burst.', 2500, 35000, false, 5),
('KYR002-IOSS-4002-8002-ABILITY00002', 'B2C3D4E5-F6G7-8901-BCDE-F23456789012', 'Chain Lightning', 'Bouncing lightning between nearby players', 'High', 'Spread healing for chain damage. Quick response needed.', 2000, 20000, false, 4),
('KYR003-IOSS-4003-8003-ABILITY00003', 'B2C3D4E5-F6G7-8901-BCDE-F23456789012', 'Lightning Field', 'Persistent area damage requiring positioning', 'Moderate', 'Steady healing for field damage. Coordinate movement.', 1000, 8000, true, 5);

-- Operation: Floodgate sample abilities (first boss)
INSERT INTO abilities (id, boss_encounter_id, name, description, damage_profile, healer_action, cast_time, cooldown, is_channeled, affected_targets)
VALUES
('IZO001-SPLI-4001-8001-ABILITY00001', 'D4E5F6G7-H8I9-0123-DEFG-456789012345', 'Overcharge', 'Mechanical burst damage to random players', 'Critical', 'Focus healing on overcharged targets immediately.', 2000, 30000, false, 3),
('IZO002-SPLI-4002-8002-ABILITY00002', 'D4E5F6G7-H8I9-0123-DEFG-456789012345', 'Splice Debuff', 'Engineering debuff requiring quick dispel', 'High', 'Dispel splice effects before they spread.', 1500, 15000, false, 1),
('IZO003-SPLI-4003-8003-ABILITY00003', 'D4E5F6G7-H8I9-0123-DEFG-456789012345', 'Mechanical Hazard', 'Persistent damage zones from machinery', 'Moderate', 'Heal through hazard damage. Guide positioning.', 500, 10000, false, 2);