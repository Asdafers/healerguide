//
//  ContractTests.swift
//  AbilityKitTests
//
//  Created by HealerKit on 2025-09-14.
//  Contract tests for AbilityDataProviding interface
//

import XCTest
import Foundation
@testable import AbilityKit

/// Contract tests for AbilityDataProviding protocol
/// These tests validate that all contract methods fail with "not implemented" errors
/// as required by TDD - they MUST FAIL initially until implementation is added
final class AbilityDataProvidingContractTests: XCTestCase {

    // MARK: - Test Setup

    private var mockProvider: MockAbilityDataProvider!
    private var testBossEncounterId: UUID!

    override func setUpWithError() throws {
        try super.setUpWithError()

        // Create fresh instances for each test to ensure isolation
        mockProvider = MockAbilityDataProvider()
        testBossEncounterId = UUID()
    }

    override func tearDownWithError() throws {
        // Clean up test instances
        mockProvider = nil
        testBossEncounterId = nil

        try super.tearDownWithError()
    }

    // MARK: - Contract Tests for fetchAbilities(for:)

    func test_fetchAbilities_forBossEncounterId_shouldFailWithNotImplemented() async throws {
        // Given: A valid boss encounter ID
        let validBossId = testBossEncounterId!

        // When & Then: Calling fetchAbilities(for:) should throw "not implemented" error
        do {
            let _ = try await mockProvider.fetchAbilities(for: validBossId)
            XCTFail("Expected 'not implemented' error but method succeeded")
        } catch let error as AbilityDataError {
            switch error {
            case .classificationFailed(let message):
                XCTAssertEqual(message, "not implemented",
                             "Expected 'not implemented' but got: \(message)")
            default:
                XCTFail("Expected classificationFailed('not implemented') but got: \(error)")
            }
        } catch {
            XCTFail("Expected AbilityDataError.classificationFailed('not implemented') but got: \(error)")
        }
    }

    func test_fetchAbilities_forBossEncounterId_withValidUUID_shouldFailWithNotImplemented() async throws {
        // Given: Multiple valid boss encounter IDs to test boundary conditions
        let testUUIDs = [
            UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
            UUID(uuidString: "FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF")!,
            UUID()
        ]

        // When & Then: Each call should fail with "not implemented"
        for bossId in testUUIDs {
            do {
                let _ = try await mockProvider.fetchAbilities(for: bossId)
                XCTFail("Expected 'not implemented' error for UUID \(bossId)")
            } catch let error as AbilityDataError {
                switch error {
                case .classificationFailed(let message):
                    XCTAssertEqual(message, "not implemented",
                                 "Expected 'not implemented' for UUID \(bossId) but got: \(message)")
                default:
                    XCTFail("Expected classificationFailed('not implemented') for UUID \(bossId) but got: \(error)")
                }
            }
        }
    }

    // MARK: - Contract Tests for searchAbilities(query:)

    func test_searchAbilities_withQuery_shouldFailWithNotImplemented() async throws {
        // Given: A valid search query
        let searchQuery = "fireball"

        // When & Then: Calling searchAbilities(query:) should throw "not implemented" error
        do {
            let _ = try await mockProvider.searchAbilities(query: searchQuery)
            XCTFail("Expected 'not implemented' error but method succeeded")
        } catch let error as AbilityDataError {
            switch error {
            case .classificationFailed(let message):
                XCTAssertEqual(message, "not implemented",
                             "Expected 'not implemented' but got: \(message)")
            default:
                XCTFail("Expected classificationFailed('not implemented') but got: \(error)")
            }
        } catch {
            XCTFail("Expected AbilityDataError.classificationFailed('not implemented') but got: \(error)")
        }
    }

    func test_searchAbilities_withVariousQueries_shouldFailWithNotImplemented() async throws {
        // Given: Various search query scenarios including edge cases
        let testQueries = [
            "heal",                    // Normal query
            "TANK BUSTER",            // Uppercase
            "fire ball spell",        // Multi-word
            "a",                      // Single character
            "",                       // Empty string
            "🔥",                     // Emoji
            String(repeating: "x", count: 100) // Long string
        ]

        // When & Then: Each query should fail with "not implemented"
        for query in testQueries {
            do {
                let _ = try await mockProvider.searchAbilities(query: query)
                XCTFail("Expected 'not implemented' error for query '\(query)'")
            } catch let error as AbilityDataError {
                switch error {
                case .classificationFailed(let message):
                    XCTAssertEqual(message, "not implemented",
                                 "Expected 'not implemented' for query '\(query)' but got: \(message)")
                default:
                    XCTFail("Expected classificationFailed('not implemented') for query '\(query)' but got: \(error)")
                }
            }
        }
    }

    // MARK: - Contract Tests for fetchAbilities(for:damageProfile:)

    func test_fetchAbilities_forBossEncounterIdWithDamageProfile_shouldFailWithNotImplemented() async throws {
        // Given: Valid boss encounter ID and damage profile
        let validBossId = testBossEncounterId!
        let damageProfile = DamageProfile.critical

        // When & Then: Calling fetchAbilities(for:damageProfile:) should throw "not implemented" error
        do {
            let _ = try await mockProvider.fetchAbilities(for: validBossId, damageProfile: damageProfile)
            XCTFail("Expected 'not implemented' error but method succeeded")
        } catch let error as AbilityDataError {
            switch error {
            case .classificationFailed(let message):
                XCTAssertEqual(message, "not implemented",
                             "Expected 'not implemented' but got: \(message)")
            default:
                XCTFail("Expected classificationFailed('not implemented') but got: \(error)")
            }
        } catch {
            XCTFail("Expected AbilityDataError.classificationFailed('not implemented') but got: \(error)")
        }
    }

    func test_fetchAbilities_withAllDamageProfiles_shouldFailWithNotImplemented() async throws {
        // Given: Valid boss encounter ID and all possible damage profiles
        let validBossId = testBossEncounterId!
        let allDamageProfiles: [DamageProfile] = [.critical, .high, .moderate, .mechanic]

        // When & Then: Each damage profile combination should fail with "not implemented"
        for profile in allDamageProfiles {
            do {
                let _ = try await mockProvider.fetchAbilities(for: validBossId, damageProfile: profile)
                XCTFail("Expected 'not implemented' error for damage profile \(profile)")
            } catch let error as AbilityDataError {
                switch error {
                case .classificationFailed(let message):
                    XCTAssertEqual(message, "not implemented",
                                 "Expected 'not implemented' for profile \(profile) but got: \(message)")
                default:
                    XCTFail("Expected classificationFailed('not implemented') for profile \(profile) but got: \(error)")
                }
            }
        }
    }

    func test_fetchAbilities_withDamageProfilePriorities_shouldFailWithNotImplemented() async throws {
        // Given: Testing damage profiles ordered by priority
        let validBossId = testBossEncounterId!
        let profilesByPriority = DamageProfile.allCases.sorted { $0.priority > $1.priority }

        // When & Then: Each priority level should fail with "not implemented"
        for profile in profilesByPriority {
            do {
                let _ = try await mockProvider.fetchAbilities(for: validBossId, damageProfile: profile)
                XCTFail("Expected 'not implemented' error for priority \(profile.priority) profile \(profile)")
            } catch let error as AbilityDataError {
                switch error {
                case .classificationFailed(let message):
                    XCTAssertEqual(message, "not implemented",
                                 "Expected 'not implemented' for priority \(profile.priority) but got: \(message)")
                default:
                    XCTFail("Expected classificationFailed('not implemented') for priority \(profile.priority) but got: \(error)")
                }
            }
        }
    }

    // MARK: - Contract Tests for fetchKeyMechanics(for:)

    func test_fetchKeyMechanics_forBossEncounterId_shouldFailWithNotImplemented() async throws {
        // Given: A valid boss encounter ID
        let validBossId = testBossEncounterId!

        // When & Then: Calling fetchKeyMechanics(for:) should throw "not implemented" error
        do {
            let _ = try await mockProvider.fetchKeyMechanics(for: validBossId)
            XCTFail("Expected 'not implemented' error but method succeeded")
        } catch let error as AbilityDataError {
            switch error {
            case .classificationFailed(let message):
                XCTAssertEqual(message, "not implemented",
                             "Expected 'not implemented' but got: \(message)")
            default:
                XCTFail("Expected classificationFailed('not implemented') but got: \(error)")
            }
        } catch {
            XCTFail("Expected AbilityDataError.classificationFailed('not implemented') but got: \(error)")
        }
    }

    func test_fetchKeyMechanics_withMultipleBossEncounters_shouldFailWithNotImplemented() async throws {
        // Given: Multiple boss encounter IDs representing different scenarios
        let testBossIds = [
            UUID(uuidString: "12345678-1234-5678-9012-123456789012")!, // Typical format
            UUID(uuidString: "00000000-0000-0000-0000-000000000000")!, // All zeros
            UUID(uuidString: "FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF")!, // All Fs
            UUID() // Random UUID
        ]

        // When & Then: Each boss encounter should fail with "not implemented"
        for bossId in testBossIds {
            do {
                let _ = try await mockProvider.fetchKeyMechanics(for: bossId)
                XCTFail("Expected 'not implemented' error for boss ID \(bossId)")
            } catch let error as AbilityDataError {
                switch error {
                case .classificationFailed(let message):
                    XCTAssertEqual(message, "not implemented",
                                 "Expected 'not implemented' for boss ID \(bossId) but got: \(message)")
                default:
                    XCTFail("Expected classificationFailed('not implemented') for boss ID \(bossId) but got: \(error)")
                }
            }
        }
    }

    // MARK: - Integration Contract Tests

    func test_allMethods_shouldFailConsistently_withSameErrorType() async throws {
        // Given: Test data for all method calls
        let validBossId = testBossEncounterId!
        let searchQuery = "test ability"
        let damageProfile = DamageProfile.high

        var caughtErrors: [AbilityDataError] = []

        // When: Calling all four contract methods

        // Test fetchAbilities(for:)
        do {
            let _ = try await mockProvider.fetchAbilities(for: validBossId)
        } catch let error as AbilityDataError {
            caughtErrors.append(error)
        }

        // Test searchAbilities(query:)
        do {
            let _ = try await mockProvider.searchAbilities(query: searchQuery)
        } catch let error as AbilityDataError {
            caughtErrors.append(error)
        }

        // Test fetchAbilities(for:damageProfile:)
        do {
            let _ = try await mockProvider.fetchAbilities(for: validBossId, damageProfile: damageProfile)
        } catch let error as AbilityDataError {
            caughtErrors.append(error)
        }

        // Test fetchKeyMechanics(for:)
        do {
            let _ = try await mockProvider.fetchKeyMechanics(for: validBossId)
        } catch let error as AbilityDataError {
            caughtErrors.append(error)
        }

        // Then: All methods should have thrown exactly 4 "not implemented" errors
        XCTAssertEqual(caughtErrors.count, 4, "Expected 4 'not implemented' errors from all contract methods")

        for (index, error) in caughtErrors.enumerated() {
            switch error {
            case .classificationFailed(let message):
                XCTAssertEqual(message, "not implemented",
                             "Method \(index + 1) expected 'not implemented' but got: \(message)")
            default:
                XCTFail("Method \(index + 1) expected classificationFailed('not implemented') but got: \(error)")
            }
        }
    }

    // MARK: - Performance Contract Tests

    func test_contractMethods_shouldFailQuickly_withinTimeLimit() async throws {
        // Given: Performance expectations for contract failures
        let maxAllowedTime: TimeInterval = 0.1 // 100ms should be more than enough for a simple error throw
        let validBossId = testBossEncounterId!

        // When & Then: Each method should fail quickly

        // Test fetchAbilities(for:) performance
        let startTime1 = CFAbsoluteTimeGetCurrent()
        do {
            let _ = try await mockProvider.fetchAbilities(for: validBossId)
        } catch {
            // Expected to throw
        }
        let elapsedTime1 = CFAbsoluteTimeGetCurrent() - startTime1
        XCTAssertLessThan(elapsedTime1, maxAllowedTime,
                         "fetchAbilities(for:) took \(elapsedTime1)s but should fail within \(maxAllowedTime)s")

        // Test searchAbilities(query:) performance
        let startTime2 = CFAbsoluteTimeGetCurrent()
        do {
            let _ = try await mockProvider.searchAbilities(query: "test")
        } catch {
            // Expected to throw
        }
        let elapsedTime2 = CFAbsoluteTimeGetCurrent() - startTime2
        XCTAssertLessThan(elapsedTime2, maxAllowedTime,
                         "searchAbilities(query:) took \(elapsedTime2)s but should fail within \(maxAllowedTime)s")

        // Test fetchAbilities(for:damageProfile:) performance
        let startTime3 = CFAbsoluteTimeGetCurrent()
        do {
            let _ = try await mockProvider.fetchAbilities(for: validBossId, damageProfile: .critical)
        } catch {
            // Expected to throw
        }
        let elapsedTime3 = CFAbsoluteTimeGetCurrent() - startTime3
        XCTAssertLessThan(elapsedTime3, maxAllowedTime,
                         "fetchAbilities(for:damageProfile:) took \(elapsedTime3)s but should fail within \(maxAllowedTime)s")

        // Test fetchKeyMechanics(for:) performance
        let startTime4 = CFAbsoluteTimeGetCurrent()
        do {
            let _ = try await mockProvider.fetchKeyMechanics(for: validBossId)
        } catch {
            // Expected to throw
        }
        let elapsedTime4 = CFAbsoluteTimeGetCurrent() - startTime4
        XCTAssertLessThan(elapsedTime4, maxAllowedTime,
                         "fetchKeyMechanics(for:) took \(elapsedTime4)s but should fail within \(maxAllowedTime)s")
    }
}

// MARK: - Mock Implementation for Contract Testing

/// Mock implementation of AbilityDataProviding for contract testing
/// This implementation is designed to fail all methods with "not implemented" errors
/// as required by TDD contract testing approach
private class MockAbilityDataProvider: AbilityDataProviding {

    func fetchAbilities(for bossEncounterId: UUID) async throws -> [AbilityEntity] {
        throw AbilityDataError.classificationFailed("not implemented")
    }

    func searchAbilities(query: String) async throws -> [AbilityEntity] {
        throw AbilityDataError.classificationFailed("not implemented")
    }

    func fetchAbilities(for bossEncounterId: UUID, damageProfile: DamageProfile) async throws -> [AbilityEntity] {
        throw AbilityDataError.classificationFailed("not implemented")
    }

    func fetchKeyMechanics(for bossEncounterId: UUID) async throws -> [AbilityEntity] {
        throw AbilityDataError.classificationFailed("not implemented")
    }
}