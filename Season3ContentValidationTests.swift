//
//  Season3ContentValidationTests.swift
//  Season 3 Content Completeness Validation
//
//  Tests that verify Season 3 dungeons have complete boss encounters and abilities
//

import XCTest
import Foundation

final class Season3ContentValidationTests: XCTestCase {

    // MARK: - Season 3 Expected Content Baseline

    /// Season 3 dungeons with required boss counts and ability expectations
    private let expectedSeason3Content = [
        ("Ara-Kara, City of Echoes", "Ara-Kara", 3, ["Avanoxx": 3, "Anub'zekt": 3, "Ki'katal the Harvester": 3]),
        ("The Dawnbreaker", "Dawnbreaker", 3, ["Speaker Shadowcrown": 3, "Anub'ikkaj": 3, "Rashok": 3]),
        ("Eco-Dome Aldani", "Eco-Dome", 3, ["Vx'lok": 3, "Kyrioss": 3, "Overgrown Ancient": 3]),
        ("Halls of Atonement", "Halls", 4, ["Halkias": 3, "Echelon": 3, "High Adjudicator Aleez": 3, "Lord Chamberlain": 3]),
        ("Operation: Floodgate", "Floodgate", 3, ["Izo the Grand Splicer": 3, "Voidstone Monstrosity": 3, "Skarmorak": 3]),
        ("Priory of the Sacred Flame", "Priory", 3, ["Captain Dailcry": 3, "Baron Braunpyke": 3, "Prioress Murrpray": 3]),
        ("Tazavesh: Streets of Wonder", "Tazavesh SW", 4, ["Zo'phex": 3, "The Menagerie": 3, "Mailroom Mayhem": 3, "Auction House": 3]),
        ("Tazavesh: So'leah's Gambit", "Tazavesh SG", 4, ["Myza's Oasis": 3, "So'azmi": 3, "Hylbrande": 3, "So'leah": 3])
    ]

    // MARK: - Content Completeness Tests

    func testAllDungeonsHaveRequiredBossEncounters() {
        let apiURL = "http://localhost:8081/api/v1/seasons/550E8400-E29B-41D4-A716-446655440000/dungeons"

        guard let data = fetchAPIData(from: apiURL),
              let dungeons = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
            XCTFail("Failed to fetch dungeon data from API")
            return
        }

        var failedDungeons: [String] = []

        for (expectedName, expectedShortName, expectedBossCount, _) in expectedSeason3Content {
            guard let dungeon = dungeons.first(where: { $0["name"] as? String == expectedName }) else {
                XCTFail("Missing dungeon: \(expectedName)")
                continue
            }

            let actualBossCount = dungeon["bossCount"] as? Int ?? 0
            if actualBossCount < expectedBossCount {
                failedDungeons.append("\(expectedName): has \(actualBossCount)/\(expectedBossCount) bosses")
            }
        }

        XCTAssertTrue(failedDungeons.isEmpty,
                     "Dungeons with incomplete boss encounters:\n" + failedDungeons.joined(separator: "\n"))
    }

    func testAllBossesHaveRequiredAbilities() {
        let seasonsURL = "http://localhost:8081/api/v1/seasons/550E8400-E29B-41D4-A716-446655440000/dungeons"

        guard let data = fetchAPIData(from: seasonsURL),
              let dungeons = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
            XCTFail("Failed to fetch dungeon data")
            return
        }

        var failedBosses: [String] = []

        for dungeon in dungeons {
            guard let dungeonId = dungeon["id"] as? String,
                  let dungeonName = dungeon["name"] as? String else { continue }

            let bossesURL = "http://localhost:8081/api/v1/dungeons/\(dungeonId)/bosses"
            guard let bossData = fetchAPIData(from: bossesURL),
                  let bosses = try? JSONSerialization.jsonObject(with: bossData) as? [[String: Any]] else {
                continue
            }

            for boss in bosses {
                guard let bossName = boss["name"] as? String else { continue }
                let abilityCount = boss["abilityCount"] as? Int ?? 0

                if abilityCount < 3 {
                    failedBosses.append("\(dungeonName) - \(bossName): has \(abilityCount)/3 abilities")
                }
            }
        }

        XCTAssertTrue(failedBosses.isEmpty,
                     "Bosses with incomplete abilities:\n" + failedBosses.joined(separator: "\n"))
    }

    // MARK: - Helper Methods

    private func fetchAPIData(from urlString: String) -> Data? {
        guard let url = URL(string: urlString) else { return nil }

        let semaphore = DispatchSemaphore(value: 0)
        var result: Data?

        URLSession.shared.dataTask(with: url) { data, _, _ in
            result = data
            semaphore.signal()
        }.resume()

        semaphore.wait()
        return result
    }
}