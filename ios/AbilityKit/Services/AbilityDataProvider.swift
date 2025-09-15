//
//  AbilityDataProvider.swift
//  AbilityKit
//
//  Created by HealerKit on 2025-09-15.
//

import Foundation
import DungeonKit

/// Service for providing boss ability data with healer-focused filtering and search
public class AbilityDataProvider: AbilityDataProviding {

    /// Mock data store for abilities - in production this would connect to CoreData
    private var abilities: [AbilityEntity] = []

    public init() {
        // Initialize with sample healer-focused ability data
        // This represents critical abilities like "Alerting Shrill" mentioned in requirements
        initializeSampleData()
    }

    // MARK: - AbilityDataProviding Implementation

    /// Fetch all abilities for a boss encounter, ordered by display priority
    public func fetchAbilities(for bossEncounterId: UUID) async throws -> [AbilityEntity] {
        let bossAbilities = abilities.filter { $0.bossEncounterId == bossEncounterId }

        if bossAbilities.isEmpty {
            throw AbilityDataError.bossEncounterNotFound(bossEncounterId)
        }

        // Sort by damage profile priority (critical first) then by display order
        return bossAbilities.sorted { lhs, rhs in
            if lhs.damageProfile.priority != rhs.damageProfile.priority {
                return lhs.damageProfile.priority > rhs.damageProfile.priority
            }
            return lhs.displayOrder < rhs.displayOrder
        }
    }

    /// Search abilities by name across all encounters
    public func searchAbilities(query: String) async throws -> [AbilityEntity] {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return []
        }

        let searchQuery = query.lowercased()
        return abilities.filter { ability in
            ability.name.lowercased().contains(searchQuery) ||
            ability.healerAction.lowercased().contains(searchQuery) ||
            ability.criticalInsight.lowercased().contains(searchQuery)
        }.sorted { lhs, rhs in
            // Prioritize exact matches, then by damage profile
            let lhsExact = lhs.name.lowercased() == searchQuery
            let rhsExact = rhs.name.lowercased() == searchQuery

            if lhsExact != rhsExact {
                return lhsExact
            }

            return lhs.damageProfile.priority > rhs.damageProfile.priority
        }
    }

    /// Fetch abilities filtered by damage profile (for color-coded display)
    public func fetchAbilities(for bossEncounterId: UUID, damageProfile: DamageProfile) async throws -> [AbilityEntity] {
        let bossAbilities = try await fetchAbilities(for: bossEncounterId)
        return bossAbilities.filter { $0.damageProfile == damageProfile }
    }

    /// Fetch only key mechanics for quick reference display
    public func fetchKeyMechanics(for bossEncounterId: UUID) async throws -> [AbilityEntity] {
        let bossAbilities = try await fetchAbilities(for: bossEncounterId)
        return bossAbilities.filter { $0.isKeyMechanic }
    }

    // MARK: - Private Methods

    private func initializeSampleData() {
        // Sample boss encounter IDs
        let sampleBossId1 = UUID()
        let sampleBossId2 = UUID()

        // Critical abilities like "Alerting Shrill" that require immediate healer response
        abilities = [
            AbilityEntity(
                id: UUID(),
                name: "Alerting Shrill",
                type: .damage,
                bossEncounterId: sampleBossId1,
                targets: .group,
                damageProfile: .critical,
                healerAction: "Immediate group healing cooldown required",
                criticalInsight: "This ability can one-shot players - use defensive cooldowns",
                cooldown: 45.0,
                displayOrder: 1,
                isKeyMechanic: true
            ),
            AbilityEntity(
                id: UUID(),
                name: "Sonic Boom",
                type: .damage,
                bossEncounterId: sampleBossId1,
                targets: .group,
                damageProfile: .high,
                healerAction: "Pre-heal group and prepare instant heals",
                criticalInsight: "Follows predictable pattern - can be anticipated",
                cooldown: 30.0,
                displayOrder: 2,
                isKeyMechanic: true
            ),
            AbilityEntity(
                id: UUID(),
                name: "Shadow Bolt",
                type: .damage,
                bossEncounterId: sampleBossId1,
                targets: .randomPlayer,
                damageProfile: .moderate,
                healerAction: "Spot heal affected player",
                criticalInsight: "Random target - watch health bars closely",
                cooldown: nil,
                displayOrder: 3,
                isKeyMechanic: false
            ),
            AbilityEntity(
                id: UUID(),
                name: "Dispel Magic",
                type: .mechanic,
                bossEncounterId: sampleBossId1,
                targets: .randomPlayer,
                damageProfile: .mechanic,
                healerAction: "Dispel harmful magic effects immediately",
                criticalInsight: "Must dispel within 5 seconds or player takes massive damage",
                cooldown: nil,
                displayOrder: 4,
                isKeyMechanic: true
            ),
            // Second boss abilities
            AbilityEntity(
                id: UUID(),
                name: "Crushing Blow",
                type: .damage,
                bossEncounterId: sampleBossId2,
                targets: .tank,
                damageProfile: .critical,
                healerAction: "Tank external defensive cooldown + big heal",
                criticalInsight: "Tank can die if not topped off beforehand",
                cooldown: 25.0,
                displayOrder: 1,
                isKeyMechanic: true
            ),
            AbilityEntity(
                id: UUID(),
                name: "Poison Cloud",
                type: .damage,
                bossEncounterId: sampleBossId2,
                targets: .group,
                damageProfile: .high,
                healerAction: "Sustained healing over time required",
                criticalInsight: "DoT effect - maintain steady healing throughout",
                cooldown: nil,
                displayOrder: 2,
                isKeyMechanic: false
            )
        ]
    }
}

// MARK: - Extensions for Testing

#if DEBUG
extension AbilityDataProvider {
    /// Add ability for testing purposes
    func addTestAbility(_ ability: AbilityEntity) {
        abilities.append(ability)
    }

    /// Clear all abilities for testing
    func clearAbilities() {
        abilities.removeAll()
    }

    /// Get all abilities for testing
    func getAllAbilities() -> [AbilityEntity] {
        return abilities
    }
}
#endif