#!/usr/bin/env swift

import Foundation

// MARK: - Data Validation Script for Season 3 Completeness

struct DataValidationReport {
    var errors: [String] = []
    var warnings: [String] = []
    var successes: [String] = []

    mutating func addError(_ message: String) {
        errors.append("❌ ERROR: \(message)")
    }

    mutating func addWarning(_ message: String) {
        warnings.append("⚠️  WARNING: \(message)")
    }

    mutating func addSuccess(_ message: String) {
        successes.append("✅ SUCCESS: \(message)")
    }

    func printReport() {
        print("\n" + "="*60)
        print("📊 SEASON 3 DATA VALIDATION REPORT")
        print("="*60)

        if !successes.isEmpty {
            print("\n🎉 SUCCESSES (\(successes.count)):")
            for success in successes {
                print("  \(success)")
            }
        }

        if !warnings.isEmpty {
            print("\n⚠️  WARNINGS (\(warnings.count)):")
            for warning in warnings {
                print("  \(warning)")
            }
        }

        if !errors.isEmpty {
            print("\n❌ ERRORS (\(errors.count)):")
            for error in errors {
                print("  \(error)")
            }
        }

        print("\n" + "="*60)
        print("📈 SUMMARY:")
        print("  ✅ Successes: \(successes.count)")
        print("  ⚠️  Warnings: \(warnings.count)")
        print("  ❌ Errors: \(errors.count)")

        if errors.isEmpty && warnings.count <= 2 {
            print("  🎯 OVERALL STATUS: ✅ PASS")
        } else if errors.isEmpty {
            print("  🎯 OVERALL STATUS: ⚠️  PASS WITH WARNINGS")
        } else {
            print("  🎯 OVERALL STATUS: ❌ FAIL")
        }
        print("="*60 + "\n")
    }
}

// MARK: - API Client for Validation

class ValidationAPIClient {
    private let baseURL = "http://localhost:8080/api/v1"

    func validateSeason3Data() async -> DataValidationReport {
        var report = DataValidationReport()

        // 1. Validate Season 3 exists
        await validateSeason3Exists(&report)

        // 2. Validate all 8 dungeons exist
        let dungeons = await validateDungeonCompleteness(&report)

        // 3. Validate boss encounters for key dungeons
        await validateBossEncounters(&report, dungeons: dungeons)

        // 4. Validate abilities for critical bosses
        await validateCriticalAbilities(&report, dungeons: dungeons)

        return report
    }

    private func validateSeason3Exists(_ report: inout DataValidationReport) async {
        guard let url = URL(string: "\(baseURL)/seasons?active_only=true") else {
            report.addError("Invalid seasons URL")
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let seasons = try JSONDecoder().decode([Season].self, from: data)

            if seasons.count == 1 {
                let season = seasons[0]
                if season.majorVersion == "11.2" && season.name == "The War Within Season 3" {
                    report.addSuccess("Season 3 (11.2) correctly configured and active")
                    report.addSuccess("Season has \(season.dungeonCount) dungeons")

                    if season.dungeonCount == 8 {
                        report.addSuccess("Correct dungeon count (8) for Season 3")
                    } else {
                        report.addError("Expected 8 dungeons, found \(season.dungeonCount)")
                    }
                } else {
                    report.addError("Active season is not Season 3: \(season.name) v\(season.majorVersion)")
                }
            } else {
                report.addError("Expected exactly 1 active season, found \(seasons.count)")
            }
        } catch {
            report.addError("Failed to fetch seasons: \(error.localizedDescription)")
        }
    }

    private func validateDungeonCompleteness(_ report: inout DataValidationReport) async -> [Dungeon] {
        guard let url = URL(string: "\(baseURL)/seasons") else {
            report.addError("Invalid seasons URL")
            return []
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let seasons = try JSONDecoder().decode([Season].self, from: data)

            guard let activeSeason = seasons.first(where: { $0.isActive }) else {
                report.addError("No active season found")
                return []
            }

            // Get dungeons for active season
            let dungeonsURL = URL(string: "\(baseURL)/seasons/\(activeSeason.id)/dungeons")!
            let (dungeonData, _) = try await URLSession.shared.data(from: dungeonsURL)
            let dungeons = try JSONDecoder().decode([Dungeon].self, from: dungeonData)

            let expectedDungeons = [
                "Ara-Kara, City of Echoes",
                "The Dawnbreaker",
                "Eco-Dome Aldani",
                "Halls of Atonement",
                "Operation: Floodgate",
                "Priory of the Sacred Flame",
                "Tazavesh: Streets of Wonder",
                "Tazavesh: So'leah's Gambit"
            ]

            let dungeonNames = dungeons.map { $0.name }.sorted()

            for expectedName in expectedDungeons {
                if dungeonNames.contains(expectedName) {
                    report.addSuccess("Found dungeon: \(expectedName)")
                } else {
                    report.addError("Missing dungeon: \(expectedName)")
                }
            }

            // Validate healer-specific data
            for dungeon in dungeons {
                if let healerNotes = dungeon.healerNotes, !healerNotes.isEmpty {
                    report.addSuccess("\(dungeon.shortName): Has healer notes")
                } else {
                    report.addWarning("\(dungeon.shortName): Missing or empty healer notes")
                }

                if dungeon.estimatedDuration > 0 {
                    report.addSuccess("\(dungeon.shortName): Has duration (\(dungeon.estimatedDuration)min)")
                } else {
                    report.addWarning("\(dungeon.shortName): Missing duration")
                }
            }

            return dungeons

        } catch {
            report.addError("Failed to fetch dungeons: \(error.localizedDescription)")
            return []
        }
    }

    private func validateBossEncounters(_ report: inout DataValidationReport, dungeons: [Dungeon]) async {
        let criticalDungeons = [
            "Ara-Kara, City of Echoes",
            "Halls of Atonement",
            "The Dawnbreaker"
        ]

        for dungeonName in criticalDungeons {
            guard let dungeon = dungeons.first(where: { $0.name == dungeonName }) else {
                report.addError("Critical dungeon not found: \(dungeonName)")
                continue
            }

            do {
                let url = URL(string: "\(baseURL)/dungeons/\(dungeon.id)/bosses")!
                let (data, _) = try await URLSession.shared.data(from: url)
                let bosses = try JSONDecoder().decode([BossEncounter].self, from: data)

                if bosses.isEmpty {
                    report.addError("\(dungeonName): No boss encounters found")
                } else {
                    report.addSuccess("\(dungeonName): Found \(bosses.count) boss encounters")

                    // Validate boss data completeness
                    for boss in bosses {
                        if boss.healingSummary != nil && boss.positioning != nil && boss.cooldownPriority != nil {
                            report.addSuccess("\(boss.name): Complete healer data")
                        } else {
                            report.addWarning("\(boss.name): Incomplete healer data")
                        }
                    }
                }
            } catch {
                report.addError("Failed to fetch bosses for \(dungeonName): \(error.localizedDescription)")
            }
        }
    }

    private func validateCriticalAbilities(_ report: inout DataValidationReport, dungeons: [Dungeon]) async {
        let criticalTests = [
            ("Ara-Kara, City of Echoes", "Avanoxx", "Alerting Shrill"),
            ("Halls of Atonement", "Lord Chamberlain", "Ritual of Woe"),
            ("Halls of Atonement", "High Adjudicator Aleez", "Unstable Anima")
        ]

        for (dungeonName, bossName, abilityName) in criticalTests {
            await validateSpecificAbility(&report,
                                        dungeons: dungeons,
                                        dungeonName: dungeonName,
                                        bossName: bossName,
                                        abilityName: abilityName)
        }
    }

    private func validateSpecificAbility(_ report: inout DataValidationReport,
                                       dungeons: [Dungeon],
                                       dungeonName: String,
                                       bossName: String,
                                       abilityName: String) async {
        guard let dungeon = dungeons.first(where: { $0.name == dungeonName }) else {
            report.addError("Dungeon not found for ability test: \(dungeonName)")
            return
        }

        do {
            // Get bosses
            let bossURL = URL(string: "\(baseURL)/dungeons/\(dungeon.id)/bosses")!
            let (bossData, _) = try await URLSession.shared.data(from: bossURL)
            let bosses = try JSONDecoder().decode([BossEncounter].self, from: bossData)

            guard let boss = bosses.first(where: { $0.name == bossName }) else {
                report.addError("Boss not found: \(bossName) in \(dungeonName)")
                return
            }

            // Get abilities
            let abilityURL = URL(string: "\(baseURL)/bosses/\(boss.id)/abilities")!
            let (abilityData, _) = try await URLSession.shared.data(from: abilityURL)
            let abilities = try JSONDecoder().decode([Ability].self, from: abilityData)

            if let ability = abilities.first(where: { $0.name == abilityName }) {
                report.addSuccess("Found critical ability: \(abilityName)")

                // Validate ability data
                if ability.healerAction != nil && !ability.healerAction!.isEmpty {
                    report.addSuccess("\(abilityName): Has healer action")
                } else {
                    report.addError("\(abilityName): Missing healer action")
                }

                if ability.damageProfile.rawValue != "Critical" && abilityName == "Alerting Shrill" {
                    report.addError("\(abilityName): Should be Critical damage profile")
                } else if abilityName == "Alerting Shrill" {
                    report.addSuccess("\(abilityName): Correctly marked as Critical")
                }
            } else {
                report.addError("Missing critical ability: \(abilityName) for \(bossName)")
            }

        } catch {
            report.addError("Failed to validate \(abilityName): \(error.localizedDescription)")
        }
    }
}

// MARK: - Data Models

struct Season: Codable {
    let id: String
    let majorVersion: String
    let name: String
    let isActive: Bool
    let dungeonCount: Int
}

struct Dungeon: Codable {
    let id: String
    let name: String
    let shortName: String
    let healerNotes: String?
    let estimatedDuration: Int
    let difficultyRating: Int
    let bossCount: Int
}

struct BossEncounter: Codable {
    let id: String
    let name: String
    let healingSummary: String?
    let positioning: String?
    let cooldownPriority: String?
    let orderIndex: Int
    let abilityCount: Int
}

struct Ability: Codable {
    let id: String
    let name: String
    let description: String?
    let damageProfile: DamageProfile
    let healerAction: String?
    let castTime: Int
    let cooldown: Int
    let isChanneled: Bool
    let affectedTargets: Int
}

enum DamageProfile: String, Codable {
    case critical = "Critical"
    case high = "High"
    case moderate = "Moderate"
    case mechanic = "Mechanic"
}

// MARK: - Main Execution

@main
struct ValidationScript {
    static func main() async {
        print("🔍 Starting Season 3 Data Validation...")
        print("📡 Checking API at http://localhost:8080/api/v1")

        let client = ValidationAPIClient()
        let report = await client.validateSeason3Data()

        report.printReport()

        // Exit with error code if validation failed
        if !report.errors.isEmpty {
            exit(1)
        }
    }
}