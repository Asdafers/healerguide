//
//  SeasonDataGenerator.swift
//  HealerKit
//
//  Created by HealerKit on 2025-09-15.
//  T041: Sample Season Data Generation for The War Within Season 1
//

import Foundation
import CoreData
@testable import DungeonKit
@testable import AbilityKit

/// Generates comprehensive sample data for The War Within Season 1
/// Provides realistic dungeon, encounter, and ability data optimized for healer workflows
public class SeasonDataGenerator {

    // MARK: - Constants

    /// The War Within Season 1 dungeon configuration
    private struct SeasonConfig {
        static let seasonName = "The War Within Season 1"
        static let dungeonCount = 8
        static let averageBossesPerDungeon = 4
        static let averageAbilitiesPerBoss = 15
        static let criticalAbilityRatio: Double = 0.25 // 25% critical abilities
        static let highAbilityRatio: Double = 0.35 // 35% high damage abilities
        static let moderateAbilityRatio: Double = 0.25 // 25% moderate abilities
        static let mechanicAbilityRatio: Double = 0.15 // 15% mechanic abilities
    }

    /// Realistic damage profile distributions for healer-focused content
    private struct DamageProfiles {
        static let burstProfiles = ["Tank Buster", "Raid-wide Burst", "Target Spike", "Unavoidable Damage"]
        static let dotProfiles = ["Poison DoT", "Disease Spread", "Bleed Effect", "Curse Damage"]
        static let aoeDamageProfiles = ["Ground Effect", "Cleave Damage", "Explosion", "Aura Damage"]
        static let mechanicProfiles = ["Dispel Required", "Positioning", "Interrupt Window", "Damage Reduction"]
    }

    // MARK: - Public Interface

    /// Generates complete War Within Season 1 data with 8 realistic dungeons
    /// - Returns: Season with full dungeon, encounter, and ability data
    /// - Throws: GenerationError if data creation fails
    public func generateWarWithinSeason() throws -> Season {
        let season = createBaseSeason()
        let dungeons = try generateAllDungeons(for: season)

        return Season(
            id: season.id,
            name: season.name,
            startDate: season.startDate,
            endDate: season.endDate,
            dungeonIds: dungeons.map { $0.id },
            metadata: [
                "total_dungeons": dungeons.count,
                "total_encounters": dungeons.flatMap { $0.bossEncounterIds }.count,
                "healer_focused": true,
                "generation_date": ISO8601DateFormatter().string(from: Date())
            ]
        )
    }

    /// Generates sample data for integration tests including "Ara-Kara, City of Echoes" and "Avanoxx"
    /// - Returns: Season with test-specific data that matches integration test expectations
    public func generateIntegrationTestSeason() throws -> Season {
        let season = createBaseSeason()
        let araKaraDungeon = try generateAraKaraDungeon()

        return Season(
            id: season.id,
            name: "Integration Test Season",
            startDate: season.startDate,
            endDate: season.endDate,
            dungeonIds: [araKaraDungeon.id],
            metadata: [
                "test_data": true,
                "ara_kara_included": true,
                "avanoxx_boss_included": true
            ]
        )
    }

    /// Exports season data to JSON format for CLI tool testing
    /// - Parameter season: Season to export
    /// - Returns: JSON string representation
    public func exportToJSON(_ season: Season) throws -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601

        let data = try encoder.encode(season)
        return String(data: data, encoding: .utf8) ?? ""
    }

    /// Loads season data from JSON format
    /// - Parameter jsonString: JSON representation of season data
    /// - Returns: Parsed Season object
    public func loadFromJSON(_ jsonString: String) throws -> Season {
        guard let data = jsonString.data(using: .utf8) else {
            throw GenerationError.invalidJSONFormat
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        return try decoder.decode(Season.self, from: data)
    }

    // MARK: - Season Generation

    private func createBaseSeason() -> Season {
        let startDate = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
        let endDate = Calendar.current.date(byAdding: .month, value: 5, to: startDate) ?? Date()

        return Season(
            id: UUID(),
            name: SeasonConfig.seasonName,
            startDate: startDate,
            endDate: endDate,
            dungeonIds: [],
            metadata: [
                "expansion": "The War Within",
                "patch_version": "11.1.0",
                "difficulty": "Mythic+",
                "healer_optimized": true
            ]
        )
    }

    private func generateAllDungeons(for season: Season) throws -> [Dungeon] {
        let dungeonData = getWarWithinDungeonData()

        return try dungeonData.map { dungeonInfo in
            try generateDungeon(
                name: dungeonInfo.name,
                description: dungeonInfo.description,
                bossNames: dungeonInfo.bossNames,
                estimatedDuration: dungeonInfo.estimatedDuration
            )
        }
    }

    // MARK: - Dungeon Generation

    private func generateDungeon(name: String, description: String, bossNames: [String], estimatedDuration: Int) throws -> Dungeon {
        let dungeonId = UUID()
        var encounters: [BossEncounter] = []

        // Generate boss encounters
        for (index, bossName) in bossNames.enumerated() {
            let encounter = try generateBossEncounter(
                name: bossName,
                dungeonId: dungeonId,
                phase: index + 1,
                isLastBoss: index == bossNames.count - 1
            )
            encounters.append(encounter)
        }

        return Dungeon(
            id: dungeonId,
            name: name,
            description: description,
            difficulty: .mythicplus,
            estimatedDuration: estimatedDuration,
            bossEncounterIds: encounters.map { $0.id },
            metadata: [
                "expansion": "The War Within",
                "boss_count": encounters.count,
                "healer_complexity": calculateHealerComplexity(for: encounters)
            ]
        )
    }

    private func generateBossEncounter(name: String, dungeonId: UUID, phase: Int, isLastBoss: Bool) throws -> BossEncounter {
        let encounterId = UUID()

        // Generate abilities based on boss type and position
        let baseAbilityCount = isLastBoss ? 18 : Int.random(in: 12...16)
        let abilities = try generateAbilities(for: encounterId, count: baseAbilityCount, bossName: name)

        let healerSummary = generateHealerSummary(for: name, abilities: abilities)

        return BossEncounter(
            id: encounterId,
            name: name,
            dungeonId: dungeonId,
            description: generateBossDescription(name: name, isLastBoss: isLastBoss),
            phase: phase,
            abilityIds: abilities.map { $0.id },
            healerSummary: healerSummary,
            metadata: [
                "is_final_boss": isLastBoss,
                "ability_count": abilities.count,
                "critical_abilities": abilities.filter { $0.classification == .critical }.count,
                "healer_intensity": calculateHealerIntensity(abilities)
            ]
        )
    }

    // MARK: - Ability Generation

    private func generateAbilities(for encounterId: UUID, count: Int, bossName: String) throws -> [BossAbility] {
        var abilities: [BossAbility] = []

        // Calculate ability distribution
        let criticalCount = Int(Double(count) * SeasonConfig.criticalAbilityRatio)
        let highCount = Int(Double(count) * SeasonConfig.highAbilityRatio)
        let moderateCount = Int(Double(count) * SeasonConfig.moderateAbilityRatio)
        let mechanicCount = count - criticalCount - highCount - moderateCount

        // Generate critical abilities (highest priority for healers)
        for i in 0..<criticalCount {
            let ability = generateCriticalAbility(for: encounterId, index: i, bossName: bossName)
            abilities.append(ability)
        }

        // Generate high damage abilities
        for i in 0..<highCount {
            let ability = generateHighDamageAbility(for: encounterId, index: i, bossName: bossName)
            abilities.append(ability)
        }

        // Generate moderate damage abilities
        for i in 0..<moderateCount {
            let ability = generateModerateAbility(for: encounterId, index: i, bossName: bossName)
            abilities.append(ability)
        }

        // Generate mechanic abilities
        for i in 0..<mechanicCount {
            let ability = generateMechanicAbility(for: encounterId, index: i, bossName: bossName)
            abilities.append(ability)
        }

        return abilities.shuffled() // Randomize order for realistic encounter flow
    }

    private func generateCriticalAbility(for encounterId: UUID, index: Int, bossName: String) -> BossAbility {
        let criticalAbilities = getCriticalAbilityTemplates(for: bossName)
        let template = criticalAbilities[index % criticalAbilities.count]

        return BossAbility(
            id: UUID(),
            name: template.name,
            description: template.description,
            classification: .critical,
            healerGuidance: template.healerGuidance,
            damageProfile: template.damageProfile,
            metadata: [
                "priority": "immediate_response",
                "healer_action": template.healerAction,
                "cooldown_required": template.requiresCooldown
            ]
        )
    }

    private func generateHighDamageAbility(for encounterId: UUID, index: Int, bossName: String) -> BossAbility {
        let highAbilities = getHighDamageAbilityTemplates(for: bossName)
        let template = highAbilities[index % highAbilities.count]

        return BossAbility(
            id: UUID(),
            name: template.name,
            description: template.description,
            classification: .high,
            healerGuidance: template.healerGuidance,
            damageProfile: template.damageProfile,
            metadata: [
                "priority": "high_healing",
                "healer_action": template.healerAction,
                "anticipate_damage": true
            ]
        )
    }

    private func generateModerateAbility(for encounterId: UUID, index: Int, bossName: String) -> BossAbility {
        let moderateAbilities = getModerateAbilityTemplates(for: bossName)
        let template = moderateAbilities[index % moderateAbilities.count]

        return BossAbility(
            id: UUID(),
            name: template.name,
            description: template.description,
            classification: .moderate,
            healerGuidance: template.healerGuidance,
            damageProfile: template.damageProfile,
            metadata: [
                "priority": "standard_healing",
                "healer_action": template.healerAction
            ]
        )
    }

    private func generateMechanicAbility(for encounterId: UUID, index: Int, bossName: String) -> BossAbility {
        let mechanicAbilities = getMechanicAbilityTemplates(for: bossName)
        let template = mechanicAbilities[index % mechanicAbilities.count]

        return BossAbility(
            id: UUID(),
            name: template.name,
            description: template.description,
            classification: .mechanic,
            healerGuidance: template.healerGuidance,
            damageProfile: template.damageProfile,
            metadata: [
                "priority": "mechanic_response",
                "healer_action": template.healerAction,
                "requires_positioning": template.requiresPositioning
            ]
        )
    }

    // MARK: - Specific Dungeon Data for "Ara-Kara, City of Echoes"

    private func generateAraKaraDungeon() throws -> Dungeon {
        let dungeonId = UUID()

        // Generate Avanoxx encounter (as used in integration tests)
        let avanoxxEncounter = try generateAvanoxxEncounter(dungeonId: dungeonId)

        // Generate other Ara-Kara bosses
        let otherEncounters = try [
            generateBossEncounter(name: "Anub'zekt", dungeonId: dungeonId, phase: 1, isLastBoss: false),
            generateBossEncounter(name: "Ki'katal the Harvester", dungeonId: dungeonId, phase: 3, isLastBoss: true)
        ]

        let allEncounters = [avanoxxEncounter] + otherEncounters

        return Dungeon(
            id: dungeonId,
            name: "Ara-Kara, City of Echoes",
            description: "An ancient nerubian city filled with intricate tunnels and deadly inhabitants. Navigate carefully through web-filled corridors while facing the city's most dangerous predators.",
            difficulty: .mythicplus,
            estimatedDuration: 1800, // 30 minutes
            bossEncounterIds: allEncounters.map { $0.id },
            metadata: [
                "expansion": "The War Within",
                "zone": "Azj-Kahet",
                "boss_count": allEncounters.count,
                "healer_complexity": "Moderate",
                "integration_test_dungeon": true
            ]
        )
    }

    private func generateAvanoxxEncounter(dungeonId: UUID) throws -> BossEncounter {
        let encounterId = UUID()

        // Generate Avanoxx-specific abilities that match integration test expectations
        let avanoxxAbilities = [
            BossAbility(
                id: UUID(),
                name: "Voracious Bite",
                description: "Avanoxx bites the current tank, dealing massive physical damage and applying a stacking debuff that increases damage taken.",
                classification: .critical,
                healerGuidance: "Tank buster - prepare for heavy damage. Use cooldowns for high stacks. Monitor tank health closely and be ready with emergency heals.",
                damageProfile: DamageProfile(
                    type: .burst,
                    severity: .critical,
                    timing: .immediate,
                    affectedPlayers: .tank,
                    estimatedDamage: 85000,
                    healingRequired: .emergency
                ),
                metadata: [
                    "mechanic_type": "tank_buster",
                    "stacks_danger": 3,
                    "cooldown_recommended": true
                ]
            ),
            BossAbility(
                id: UUID(),
                name: "Web Bolt",
                description: "Launches sticky webs at random players, dealing nature damage and reducing movement speed by 50% for 8 seconds.",
                classification: .moderate,
                healerGuidance: "Moderate damage to random targets. Cleanse if possible, otherwise heal through the DoT. Watch for multiple targets hit simultaneously.",
                damageProfile: DamageProfile(
                    type: .dot,
                    severity: .moderate,
                    timing: .delayed,
                    affectedPlayers: .random,
                    estimatedDamage: 12000,
                    healingRequired: .standard
                ),
                metadata: [
                    "dispellable": true,
                    "movement_impair": true
                ]
            ),
            BossAbility(
                id: UUID(),
                name: "Burrow Charge",
                description: "Avanoxx burrows underground and charges at a random player, emerging to deal heavy damage in a line and knocking back all affected players.",
                classification: .high,
                healerGuidance: "High damage to players in charge path. Pre-position to avoid knockback into hazards. Heal affected players quickly as they may be out of range.",
                damageProfile: DamageProfile(
                    type: .burst,
                    severity: .high,
                    timing: .telegraphed,
                    affectedPlayers: .line,
                    estimatedDamage: 45000,
                    healingRequired: .priority
                ),
                metadata: [
                    "avoidable": true,
                    "knockback_effect": true,
                    "positioning_critical": true
                ]
            ),
            BossAbility(
                id: UUID(),
                name: "Poison Nova",
                description: "Releases a wave of toxic energy that deals nature damage to all players and leaves poison pools on the ground for 20 seconds.",
                classification: .critical,
                healerGuidance: "Raid-wide damage plus persistent ground hazards. Use cooldowns for the initial burst, then focus on players standing in poison pools. Coordinate positioning.",
                damageProfile: DamageProfile(
                    type: .aoe,
                    severity: .critical,
                    timing: .immediate,
                    affectedPlayers: .all,
                    estimatedDamage: 35000,
                    healingRequired: .raid_cooldown
                ),
                metadata: [
                    "persistent_hazard": true,
                    "positioning_required": true,
                    "raid_cooldown": true
                ]
            ),
            BossAbility(
                id: UUID(),
                name: "Ensnaring Web",
                description: "Casts webs that trap players in place for 6 seconds. Trapped players take increasing damage over time until freed by other players.",
                classification: .mechanic,
                healerGuidance: "Support trapped players with heals while others break them free. Damage increases rapidly - prioritize freeing players quickly over healing.",
                damageProfile: DamageProfile(
                    type: .dot,
                    severity: .moderate,
                    timing: .escalating,
                    affectedPlayers: .random,
                    estimatedDamage: 8000,
                    healingRequired: .supportive
                ),
                metadata: [
                    "requires_team_response": true,
                    "escalating_damage": true,
                    "cc_break_mechanic": true
                ]
            )
        ]

        let healerSummary = """
        Avanoxx is a moderate-complexity encounter requiring steady healing and good positioning awareness. Key challenges:

        • **Tank Management**: Voracious Bite stacks require careful cooldown usage
        • **Raid Damage**: Poison Nova needs raid cooldowns and positioning coordination
        • **Mechanic Support**: Ensnared players need healing support while being freed
        • **Mobility**: Multiple abilities require movement and repositioning

        **Healer Priority**: Tank cooldowns > Raid positioning > Web management > Sustained healing
        """

        return BossEncounter(
            id: encounterId,
            name: "Avanoxx",
            dungeonId: dungeonId,
            description: "A massive spider that has claimed the deepest chambers of Ara-Kara as her hunting ground. Her venomous attacks and web-spinning abilities make her a formidable opponent requiring careful coordination and positioning.",
            phase: 2,
            abilityIds: avanoxxAbilities.map { $0.id },
            healerSummary: healerSummary,
            metadata: [
                "boss_type": "Spider",
                "encounter_length": "4-6 minutes",
                "healer_difficulty": "Moderate",
                "key_mechanics": ["Tank Buster", "Raid Damage", "Positioning", "CC Break"],
                "integration_test_boss": true
            ]
        )
    }

    // MARK: - War Within Dungeon Data

    private func getWarWithinDungeonData() -> [(name: String, description: String, bossNames: [String], estimatedDuration: Int)] {
        return [
            (
                name: "Ara-Kara, City of Echoes",
                description: "An ancient nerubian city filled with intricate tunnels and deadly inhabitants.",
                bossNames: ["Anub'zekt", "Avanoxx", "Ki'katal the Harvester"],
                estimatedDuration: 1800
            ),
            (
                name: "City of Threads",
                description: "A sprawling nerubian metropolis with complex web-like architecture.",
                bossNames: ["Orator Krix'vizk", "Fangs of the Queen", "The Coaglamation", "Izo, the Grand Splicer"],
                estimatedDuration: 2100
            ),
            (
                name: "The Dawnbreaker",
                description: "A majestic airship soaring through the skies of Khaz Algar.",
                bossNames: ["Speaker Shadowcrown", "Anub'ikkaj", "Rashanan"],
                estimatedDuration: 1650
            ),
            (
                name: "The Stonevault",
                description: "An ancient earthen vault containing powerful artifacts and guardians.",
                bossNames: ["E.D.N.A", "Skarmorak", "Master Machinest Brennan", "Void Speaker Eirich"],
                estimatedDuration: 2200
            ),
            (
                name: "Cinderbrew Meadery",
                description: "A bustling brewery overrun with elemental forces and corrupted beverages.",
                bossNames: ["Brew Master Aldryr", "I'pa", "Benk Buzzbee", "Goldie Baronbottom"],
                estimatedDuration: 1950
            ),
            (
                name: "Darkflame Cleft",
                description: "A volcanic fissure where kobolds have established a dangerous mining operation.",
                bossNames: ["Ol' Waxbeard", "Blazikon", "The Candle King"],
                estimatedDuration: 1500
            ),
            (
                name: "Priory of the Sacred Flame",
                description: "A sacred temple where the light has been corrupted by dark influences.",
                bossNames: ["Captain Dailcry", "Baron Braunpyke", "Prioress Murrpray"],
                estimatedDuration: 1750
            ),
            (
                name: "The Rookery",
                description: "A storm-touched peak where storm dragons nest among ancient ruins.",
                bossNames: ["Kyrioss", "Stormguard Gorren", "Voidstone Monstrosity"],
                estimatedDuration: 1600
            )
        ]
    }

    // MARK: - Ability Templates

    private func getCriticalAbilityTemplates(for bossName: String) -> [(name: String, description: String, healerGuidance: String, damageProfile: DamageProfile, healerAction: String, requiresCooldown: Bool)] {
        return [
            (
                name: "Devastating Strike",
                description: "A powerful melee attack that deals massive damage to the tank and applies a debuff increasing damage taken by 25% for 30 seconds.",
                healerGuidance: "Major tank buster - use external cooldowns immediately. Monitor tank health closely for the next 30 seconds as all damage is amplified.",
                damageProfile: DamageProfile(type: .burst, severity: .critical, timing: .immediate, affectedPlayers: .tank, estimatedDamage: 90000, healingRequired: .emergency),
                healerAction: "Emergency heal + external cooldown",
                requiresCooldown: true
            ),
            (
                name: "Soul Rend",
                description: "Targets a random player and deals shadow damage while also damaging all nearby allies within 8 yards.",
                healerGuidance: "Critical spread damage - heal the primary target immediately, then address splash damage. Encourage spread positioning to minimize impact.",
                damageProfile: DamageProfile(type: .burst, severity: .critical, timing: .immediate, affectedPlayers: .random, estimatedDamage: 65000, healingRequired: .emergency),
                healerAction: "Immediate heal + AoE healing",
                requiresCooldown: false
            ),
            (
                name: "Apocalypse",
                description: "Channel for 4 seconds, then deals catastrophic damage to all players. Can be interrupted.",
                healerGuidance: "Raid-killer if not interrupted. If interrupt fails, use all available raid cooldowns immediately. This should never complete casting.",
                damageProfile: DamageProfile(type: .aoe, severity: .critical, timing: .channeled, affectedPlayers: .all, estimatedDamage: 120000, healingRequired: .raid_cooldown),
                healerAction: "Coordinate interrupts + raid cooldowns",
                requiresCooldown: true
            )
        ]
    }

    private func getHighDamageAbilityTemplates(for bossName: String) -> [(name: String, description: String, healerGuidance: String, damageProfile: DamageProfile, healerAction: String)] {
        return [
            (
                name: "Flame Burst",
                description: "Explodes in a 15-yard radius around the boss, dealing fire damage to all nearby players.",
                healerGuidance: "High AoE damage to melee range. Pre-heal melee players and be ready with AoE heals. Encourage ranged positioning when possible.",
                damageProfile: DamageProfile(type: .aoe, severity: .high, timing: .telegraphed, affectedPlayers: .melee, estimatedDamage: 45000, healingRequired: .priority),
                healerAction: "Pre-heal + AoE healing"
            ),
            (
                name: "Shadow Bolt Volley",
                description: "Launches 5 shadow bolts at random players over 3 seconds, each dealing shadow damage.",
                healerGuidance: "Multiple high-damage hits on random targets. Spread heals across the raid and prioritize players with multiple hits.",
                damageProfile: DamageProfile(type: .burst, severity: .high, timing: .sequence, affectedPlayers: .random, estimatedDamage: 38000, healingRequired: .priority),
                healerAction: "Spread healing + priority targets"
            ),
            (
                name: "Corrosive Aura",
                description: "Applies a debuff to all players that deals nature damage every 2 seconds for 16 seconds.",
                healerGuidance: "Sustained raid-wide pressure. Use HoTs and maintain steady healing throughout duration. Consider dispelling if available.",
                damageProfile: DamageProfile(type: .dot, severity: .high, timing: .sustained, affectedPlayers: .all, estimatedDamage: 15000, healingRequired: .sustained),
                healerAction: "HoTs + sustained healing"
            )
        ]
    }

    private func getModerateAbilityTemplates(for bossName: String) -> [(name: String, description: String, healerGuidance: String, damageProfile: DamageProfile, healerAction: String)] {
        return [
            (
                name: "Poisoned Blade",
                description: "Weapon attacks apply a poison that deals nature damage over 12 seconds.",
                healerGuidance: "Tank DoT - maintain steady healing or dispel if poison removal available. Low priority unless tank has multiple stacks.",
                damageProfile: DamageProfile(type: .dot, severity: .moderate, timing: .sustained, affectedPlayers: .tank, estimatedDamage: 8000, healingRequired: .standard),
                healerAction: "Steady healing or dispel"
            ),
            (
                name: "Frost Spike",
                description: "Launches an ice projectile at a random ranged player, dealing frost damage and slowing movement by 30%.",
                healerGuidance: "Single-target damage with movement impairment. Heal the affected player and monitor positioning for subsequent mechanics.",
                damageProfile: DamageProfile(type: .burst, severity: .moderate, timing: .immediate, affectedPlayers: .ranged, estimatedDamage: 25000, healingRequired: .standard),
                healerAction: "Single-target heal"
            ),
            (
                name: "Earth Tremor",
                description: "Causes the ground to shake, dealing physical damage to all players and reducing accuracy by 15% for 8 seconds.",
                healerGuidance: "Moderate raid damage with accuracy debuff. Heal through the initial damage, accuracy reduction won't significantly impact healing.",
                damageProfile: DamageProfile(type: .aoe, severity: .moderate, timing: .immediate, affectedPlayers: .all, estimatedDamage: 18000, healingRequired: .standard),
                healerAction: "AoE healing"
            )
        ]
    }

    private func getMechanicAbilityTemplates(for bossName: String) -> [(name: String, description: String, healerGuidance: String, damageProfile: DamageProfile, healerAction: String, requiresPositioning: Bool)] {
        return [
            (
                name: "Healing Absorption Shield",
                description: "Boss gains a shield that absorbs the next 500,000 healing done to players. Must be burned through with overhealing.",
                healerGuidance: "Continue healing normally to burn through the shield. Avoid using major cooldowns until shield is removed. Focus on consistent output.",
                damageProfile: DamageProfile(type: .mechanic, severity: .moderate, timing: .persistent, affectedPlayers: .none, estimatedDamage: 0, healingRequired: .mechanic),
                healerAction: "Consistent healing to burn shield",
                requiresPositioning: false
            ),
            (
                name: "Dispel Frenzy",
                description: "Applies a magic debuff to 3 random players that increases their damage taken by 50%. Must be dispelled within 8 seconds.",
                healerGuidance: "Priority dispels required immediately. If no dispel available, focus intensive healing on affected players until debuff expires.",
                damageProfile: DamageProfile(type: .mechanic, severity: .high, timing: .immediate, affectedPlayers: .random, estimatedDamage: 0, healingRequired: .mechanic),
                healerAction: "Dispel immediately or focus heal",
                requiresPositioning: false
            ),
            (
                name: "Teleport Maze",
                description: "Randomly teleports all players to different locations in the room. Players must navigate back to safe positions within 15 seconds.",
                healerGuidance: "Maintain healing while repositioning. Use instant casts and mobile abilities. Keep players alive during movement - positioning takes priority.",
                damageProfile: DamageProfile(type: .mechanic, severity: .moderate, timing: .persistent, affectedPlayers: .all, estimatedDamage: 0, healingRequired: .mobile),
                healerAction: "Mobile healing during repositioning",
                requiresPositioning: true
            )
        ]
    }

    // MARK: - Helper Methods

    private func generateHealerSummary(for bossName: String, abilities: [BossAbility]) -> String {
        let criticalCount = abilities.filter { $0.classification == .critical }.count
        let highCount = abilities.filter { $0.classification == .high }.count
        let mechanicCount = abilities.filter { $0.classification == .mechanic }.count

        let complexity = determineHealerComplexity(critical: criticalCount, high: highCount, mechanic: mechanicCount)

        return """
        \(bossName) presents a \(complexity.lowercased()) healing challenge with \(criticalCount) critical abilities requiring immediate response.

        **Key Healing Priorities:**
        • Critical abilities: \(criticalCount) - Use cooldowns and emergency responses
        • High damage events: \(highCount) - Anticipate and pre-heal when possible
        • Mechanic management: \(mechanicCount) - Support team while maintaining healing

        **Recommended Approach:** \(generateHealingStrategy(complexity: complexity, abilities: abilities))
        """
    }

    private func generateBossDescription(name: String, isLastBoss: Bool) -> String {
        let baseDescription = "A formidable opponent within the depths of The War Within dungeons."
        let complexity = isLastBoss ? "This final encounter tests all aspects of group coordination and individual skill." : "Coordination and steady execution are key to victory."

        return "\(baseDescription) \(complexity)"
    }

    private func calculateHealerComplexity(for encounters: [BossEncounter]) -> String {
        let totalCriticalAbilities = encounters.flatMap { encounter in
            // This would normally load abilities, but for calculation we'll estimate
            return Array(0..<4) // Assume 4 critical abilities per boss on average
        }.count

        switch totalCriticalAbilities {
        case 0...8: return "Low"
        case 9...16: return "Moderate"
        case 17...24: return "High"
        default: return "Extreme"
        }
    }

    private func calculateHealerIntensity(_ abilities: [BossAbility]) -> String {
        let criticalCount = abilities.filter { $0.classification == .critical }.count
        let highCount = abilities.filter { $0.classification == .high }.count
        let totalIntensity = criticalCount * 3 + highCount * 2

        switch totalIntensity {
        case 0...5: return "Low"
        case 6...12: return "Moderate"
        case 13...20: return "High"
        default: return "Extreme"
        }
    }

    private func determineHealerComplexity(critical: Int, high: Int, mechanic: Int) -> String {
        let complexityScore = critical * 3 + high * 2 + mechanic * 1

        switch complexityScore {
        case 0...8: return "Low"
        case 9...16: return "Moderate"
        case 17...25: return "High"
        default: return "Extreme"
        }
    }

    private func generateHealingStrategy(complexity: String, abilities: [BossAbility]) -> String {
        let hasTankBusters = abilities.contains { ability in
            ability.damageProfile.affectedPlayers == .tank && ability.classification == .critical
        }

        let hasRaidDamage = abilities.contains { ability in
            ability.damageProfile.affectedPlayers == .all && ability.classification != .mechanic
        }

        let hasMechanics = abilities.contains { $0.classification == .mechanic }

        switch complexity {
        case "Low":
            return "Maintain steady healing with focus on tank health. Use cooldowns sparingly for critical moments."
        case "Moderate":
            if hasTankBusters && hasRaidDamage {
                return "Balance tank cooldowns with raid healing. Coordinate defensive cooldowns with damage events."
            } else {
                return "Steady healing output with careful cooldown management for critical abilities."
            }
        case "High":
            if hasMechanics {
                return "High-intensity encounter requiring perfect cooldown timing, mechanic awareness, and positioning. Pre-plan cooldown usage and maintain mobility."
            } else {
                return "Intensive healing phases requiring optimal cooldown usage and positioning. Prepare for sustained high output."
            }
        default:
            return "Extreme encounter requiring flawless execution. Master all mechanics before attempting higher difficulties."
        }
    }

    // MARK: - Error Handling

    enum GenerationError: LocalizedError {
        case invalidJSONFormat
        case missingRequiredData(String)
        case generationFailed(String)

        var errorDescription: String? {
            switch self {
            case .invalidJSONFormat:
                return "Invalid JSON format provided"
            case .missingRequiredData(let data):
                return "Missing required data: \(data)"
            case .generationFailed(let reason):
                return "Generation failed: \(reason)"
            }
        }
    }
}

// MARK: - Extensions for Enhanced Functionality

extension Season {
    /// Loads all dungeons associated with this season
    func loadAllDungeons() throws -> [Dungeon] {
        // This would integrate with CoreData/DungeonService in real implementation
        // For sample data generation, we return mock data
        return []
    }
}

extension Dungeon {
    /// Loads all boss encounters in this dungeon
    func loadBossEncounters() throws -> [BossEncounter] {
        // This would integrate with CoreData/DungeonService in real implementation
        return []
    }
}

extension BossEncounter {
    /// Loads all abilities for this encounter
    func loadAbilities() throws -> [BossAbility] {
        // This would integrate with CoreData/AbilityService in real implementation
        return []
    }
}

// MARK: - CLI Integration

/// Command-line interface for season data generation and validation
public struct SeasonDataCLI {

    /// Generates sample season data and exports to JSON file
    /// - Parameters:
    ///   - outputPath: File path for JSON export
    ///   - includeTestData: Whether to include integration test specific data
    public static func generateAndExport(outputPath: String, includeTestData: Bool = false) throws {
        let generator = SeasonDataGenerator()

        let season = includeTestData
            ? try generator.generateIntegrationTestSeason()
            : try generator.generateWarWithinSeason()

        let jsonString = try generator.exportToJSON(season)

        try jsonString.write(toFile: outputPath, atomically: true, encoding: .utf8)

        print("Season data exported to: \(outputPath)")
        print("Dungeons: \(season.dungeonIds.count)")
        print("Test data included: \(includeTestData)")
    }

    /// Validates existing season data from JSON file
    /// - Parameter inputPath: Path to JSON file to validate
    public static func validateFromFile(inputPath: String) throws {
        let jsonString = try String(contentsOfFile: inputPath, encoding: .utf8)
        let generator = SeasonDataGenerator()

        let season = try generator.loadFromJSON(jsonString)

        print("Validation Results:")
        print("- Season: \(season.name)")
        print("- Dungeons: \(season.dungeonIds.count)")
        print("- Date Range: \(season.startDate) to \(season.endDate)")
        print("- Status: Valid ✓")
    }
}