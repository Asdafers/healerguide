//
//  DamageProfileAnalyzer.swift
//  AbilityKit
//
//  Created by HealerKit on 2025-09-15.
//

import Foundation

/// Service for analyzing damage profiles and providing iPad-optimized color schemes for healer UI
public class DamageProfileAnalyzerImpl {

    private let abilityDataProvider: AbilityDataProviding

    public init(abilityDataProvider: AbilityDataProviding = AbilityDataProvider()) {
        self.abilityDataProvider = abilityDataProvider
    }

    // MARK: - DamageProfileAnalyzer Implementation

    /// Analyze damage patterns for encounter planning
    public func analyzeDamageProfile(for bossEncounterId: UUID) async throws -> DamageAnalysis {
        let abilities = try await abilityDataProvider.fetchAbilities(for: bossEncounterId)

        // Calculate damage profile distribution
        var profileDistribution: [DamageProfile: Int] = [:]
        for profile in DamageProfile.allCases {
            profileDistribution[profile] = abilities.filter { $0.damageProfile == profile }.count
        }

        // Determine healing load based on ability composition
        let healingLoad = determineHealingLoad(from: abilities)

        // Analyze key timings
        let keyTimings = generateKeyTimings(from: abilities)

        // Generate cooldown recommendations
        let cooldownRecommendations = generateCooldownRecommendations(from: abilities)

        return DamageAnalysis(
            bossEncounterId: bossEncounterId,
            totalAbilities: abilities.count,
            damageProfileDistribution: profileDistribution,
            predictedHealingLoad: healingLoad,
            keyTimings: keyTimings,
            recommendedCooldownPlan: cooldownRecommendations
        )
    }

    /// Get color coding for UI display based on damage profile - optimized for iPad Pro first-gen display
    public func getUIColorScheme(for damageProfile: DamageProfile) -> AbilityColorScheme {
        switch damageProfile {
        case .critical:
            return AbilityColorScheme(
                primaryColor: "#FF4444",      // Bright red - high visibility on iPad
                backgroundColor: "#FFEBEE",   // Light red background for contrast
                textColor: "#FFFFFF",        // White text for readability
                borderColor: "#D32F2F"       // Darker red border for definition
            )

        case .high:
            return AbilityColorScheme(
                primaryColor: "#FF8A00",      // Orange - attention-grabbing
                backgroundColor: "#FFF3E0",   // Light orange background
                textColor: "#FFFFFF",        // White text for contrast
                borderColor: "#F57700"       // Darker orange border
            )

        case .moderate:
            return AbilityColorScheme(
                primaryColor: "#FFD600",      // Yellow - noticeable but not alarming
                backgroundColor: "#FFFDE7",   // Very light yellow background
                textColor: "#333333",        // Dark text for contrast on light background
                borderColor: "#FBC02D"       // Darker yellow border
            )

        case .mechanic:
            return AbilityColorScheme(
                primaryColor: "#2196F3",      // Blue - calm but informative
                backgroundColor: "#E3F2FD",   // Light blue background
                textColor: "#FFFFFF",        // White text for readability
                borderColor: "#1976D2"       // Darker blue border
            )
        }
    }

    /// Prioritize abilities for healer attention during encounter
    public func prioritizeForHealer(_ abilities: [AbilityEntity]) -> [PrioritizedAbility] {
        return abilities
            .enumerated()
            .map { index, ability in
                let priority = calculateHealerPriority(for: ability)
                let reasoning = generatePriorityReasoning(for: ability)
                let displayHint = determineDisplayHint(for: ability, priority: priority)

                return PrioritizedAbility(
                    ability: ability,
                    priority: priority,
                    reasoning: reasoning,
                    uiDisplayHint: displayHint
                )
            }
            .sorted { $0.priority > $1.priority }
    }

    // MARK: - Private Analysis Methods

    private func determineHealingLoad(from abilities: [AbilityEntity]) -> HealingLoad {
        let criticalCount = abilities.filter { $0.damageProfile == .critical }.count
        let highCount = abilities.filter { $0.damageProfile == .high }.count
        let groupDamageCount = abilities.filter { $0.targets == .group && $0.type == .damage }.count
        let totalDamageAbilities = abilities.filter { $0.type == .damage }.count

        // Calculate healing intensity score
        let healingScore = (criticalCount * 4) + (highCount * 3) + (groupDamageCount * 2)

        // Determine load based on score and ability composition
        switch healingScore {
        case 0...2:
            return .light
        case 3...6:
            return .moderate
        case 7...12:
            return .heavy
        default:
            // High critical ability count suggests burst healing patterns
            return criticalCount >= 2 ? .burst : .heavy
        }
    }

    private func generateKeyTimings(from abilities: [AbilityEntity]) -> [AbilityTiming] {
        return abilities.compactMap { ability in
            guard let cooldown = ability.cooldown else { return nil }

            let frequency: TimingFrequency
            if ability.isKeyMechanic {
                frequency = .periodic
            } else if ability.damageProfile == .critical {
                frequency = .conditional
            } else {
                frequency = .random
            }

            let overlaps = checkForOverlaps(ability: ability, allAbilities: abilities)

            return AbilityTiming(
                abilityId: ability.id,
                estimatedCastTime: cooldown,
                frequency: frequency,
                overlapsWithOthers: overlaps
            )
        }
    }

    private func generateCooldownRecommendations(from abilities: [AbilityEntity]) -> [CooldownRecommendation] {
        var recommendations: [CooldownRecommendation] = []

        let criticalAbilities = abilities.filter { $0.damageProfile == .critical }
        let groupDamageAbilities = abilities.filter { $0.targets == .group && $0.type == .damage }

        // Major defensive cooldown for critical abilities
        if !criticalAbilities.isEmpty {
            recommendations.append(CooldownRecommendation(
                cooldownName: "Major Defensive Cooldown",
                suggestedTiming: "Use for first critical ability, then on cooldown",
                targetAbilities: criticalAbilities.map { $0.id },
                rationale: "Critical abilities can cause raid wipes if not mitigated"
            ))
        }

        // Group healing cooldowns for AoE damage
        if groupDamageAbilities.count >= 2 {
            recommendations.append(CooldownRecommendation(
                cooldownName: "Group Healing Cooldown",
                suggestedTiming: "Rotate for each group damage ability",
                targetAbilities: groupDamageAbilities.map { $0.id },
                rationale: "Multiple group damage abilities require sustained healing capability"
            ))
        }

        // External defensive for tank abilities
        let tankAbilities = abilities.filter { $0.targets == .tank && $0.damageProfile == .critical }
        if !tankAbilities.isEmpty {
            recommendations.append(CooldownRecommendation(
                cooldownName: "External Tank Defensive",
                suggestedTiming: "Pre-cast before tank ability",
                targetAbilities: tankAbilities.map { $0.id },
                rationale: "Tank-targeted critical abilities require external mitigation"
            ))
        }

        return recommendations
    }

    private func checkForOverlaps(ability: AbilityEntity, allAbilities: [AbilityEntity]) -> Bool {
        guard let cooldown = ability.cooldown else { return false }

        // Check if other abilities have similar cooldowns (within 10 seconds)
        let similarCooldowns = allAbilities.filter { otherAbility in
            otherAbility.id != ability.id &&
            otherAbility.cooldown != nil &&
            abs((otherAbility.cooldown! - cooldown)) <= 10.0
        }

        return !similarCooldowns.isEmpty
    }

    private func calculateHealerPriority(for ability: AbilityEntity) -> Int {
        var priority = 0

        // Base priority on damage profile
        priority += ability.damageProfile.priority * 25

        // Increase priority for group-targeting abilities
        if ability.targets == .group {
            priority += 20
        }

        // Increase priority for tank abilities
        if ability.targets == .tank {
            priority += 15
        }

        // Key mechanics get additional priority
        if ability.isKeyMechanic {
            priority += 30
        }

        // Critical abilities with immediate action requirements
        if ability.healerAction.lowercased().contains("immediate") {
            priority += 25
        }

        // Dispel mechanics are high priority
        if ability.healerAction.lowercased().contains("dispel") {
            priority += 20
        }

        // Cooldown abilities that need timing
        if ability.cooldown != nil {
            priority += 10
        }

        return priority
    }

    private func generatePriorityReasoning(for ability: AbilityEntity) -> String {
        var reasons: [String] = []

        switch ability.damageProfile {
        case .critical:
            reasons.append("Critical damage profile requires immediate attention")
        case .high:
            reasons.append("High damage impact needs prompt response")
        case .moderate:
            reasons.append("Moderate damage manageable with planning")
        case .mechanic:
            reasons.append("Non-damage mechanic requiring healer intervention")
        }

        if ability.targets == .group {
            reasons.append("Affects entire group")
        }

        if ability.isKeyMechanic {
            reasons.append("Key encounter mechanic")
        }

        if ability.healerAction.lowercased().contains("immediate") {
            reasons.append("Requires immediate healer response")
        }

        if ability.cooldown != nil {
            reasons.append("Predictable timing enables preparation")
        }

        return reasons.joined(separator: ". ")
    }

    private func determineDisplayHint(for ability: AbilityEntity, priority: Int) -> UIDisplayHint {
        switch priority {
        case 100...:
            return .highlight
        case 70..<100:
            return .emphasize
        case 40..<70:
            return .standard
        default:
            return .muted
        }
    }
}

// MARK: - Protocol Conformance

extension DamageProfileAnalyzerImpl: DamageProfileAnalyzer {
    // All methods are already implemented in the class body above
}