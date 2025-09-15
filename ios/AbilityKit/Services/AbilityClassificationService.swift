//
//  AbilityClassificationService.swift
//  AbilityKit
//
//  Created by HealerKit on 2025-09-15.
//

import Foundation

/// Service for classifying abilities based on healer impact and providing action recommendations
public class AbilityClassificationServiceImpl {

    public init() {}

    // MARK: - AbilityClassificationService Implementation

    /// Classify ability based on healer impact and urgency
    public func classifyAbility(_ ability: AbilityEntity) -> AbilityClassification {
        let urgency = determineUrgency(for: ability)
        let complexity = determineComplexity(for: ability)
        let healerImpact = determineHealerImpact(for: ability)
        let preparation = generatePreparationRecommendation(for: ability, urgency: urgency, complexity: complexity)

        return AbilityClassification(
            urgency: urgency,
            complexity: complexity,
            healerImpact: healerImpact,
            recommendedPreparation: preparation
        )
    }

    /// Get recommended healer actions for damage profile
    public func getRecommendedActions(for damageProfile: DamageProfile) -> [HealerAction] {
        switch damageProfile {
        case .critical:
            return [
                HealerAction(
                    actionType: .cooldownUse,
                    timing: .immediate,
                    description: "Use major defensive cooldown immediately",
                    keyBindSuggestion: "F1"
                ),
                HealerAction(
                    actionType: .preHeal,
                    timing: .immediate,
                    description: "Top off all players before ability hits",
                    keyBindSuggestion: "F2"
                ),
                HealerAction(
                    actionType: .positioning,
                    timing: .fast,
                    description: "Position for maximum healing range",
                    keyBindSuggestion: nil
                )
            ]

        case .high:
            return [
                HealerAction(
                    actionType: .preHeal,
                    timing: .fast,
                    description: "Pre-heal likely targets",
                    keyBindSuggestion: "Shift+F1"
                ),
                HealerAction(
                    actionType: .reactiveHeal,
                    timing: .fast,
                    description: "Prepare instant heals for quick response",
                    keyBindSuggestion: "F3"
                )
            ]

        case .moderate:
            return [
                HealerAction(
                    actionType: .reactiveHeal,
                    timing: .planned,
                    description: "Plan healing rotation for sustained damage",
                    keyBindSuggestion: "F4"
                ),
                HealerAction(
                    actionType: .positioning,
                    timing: .planned,
                    description: "Adjust position for optimal healing",
                    keyBindSuggestion: nil
                )
            ]

        case .mechanic:
            return [
                HealerAction(
                    actionType: .dispel,
                    timing: .immediate,
                    description: "Dispel harmful effects quickly",
                    keyBindSuggestion: "F5"
                ),
                HealerAction(
                    actionType: .interrupt,
                    timing: .immediate,
                    description: "Interrupt dangerous casts if possible",
                    keyBindSuggestion: "F6"
                )
            ]
        }
    }

    /// Validate ability data for healer relevance
    public func validateHealerRelevance(_ ability: AbilityEntity) -> ValidationResult {
        var issues: [ValidationIssue] = []
        var recommendations: [String] = []

        // Check for critical abilities that require immediate healer response
        if isCriticalHealerAbility(ability) && ability.damageProfile != .critical {
            issues.append(ValidationIssue(
                severity: .warning,
                message: "Ability requires immediate healer response but not marked as critical",
                field: "damageProfile"
            ))
            recommendations.append("Consider upgrading damage profile to 'critical'")
        }

        // Validate healer action completeness
        if ability.healerAction.isEmpty {
            issues.append(ValidationIssue(
                severity: .error,
                message: "Missing healer action guidance",
                field: "healerAction"
            ))
            recommendations.append("Add specific healer action instructions")
        }

        // Check for abilities that don't require healer attention
        if !requiresHealerAttention(ability) {
            issues.append(ValidationIssue(
                severity: .info,
                message: "Ability may not be relevant for healers",
                field: "type"
            ))
            recommendations.append("Consider excluding from healer-focused displays")
        }

        // Validate cooldown information for planning
        if ability.damageProfile == .critical && ability.cooldown == nil {
            issues.append(ValidationIssue(
                severity: .warning,
                message: "Critical ability missing cooldown timing",
                field: "cooldown"
            ))
            recommendations.append("Add cooldown information for encounter planning")
        }

        // Check key mechanic designation
        if ability.damageProfile == .critical && !ability.isKeyMechanic {
            issues.append(ValidationIssue(
                severity: .info,
                message: "Critical ability should be marked as key mechanic",
                field: "isKeyMechanic"
            ))
            recommendations.append("Mark critical abilities as key mechanics for prominence")
        }

        return ValidationResult(
            isValid: issues.filter { $0.severity == .error }.isEmpty,
            issues: issues,
            recommendations: recommendations
        )
    }

    // MARK: - Private Classification Methods

    private func determineUrgency(for ability: AbilityEntity) -> UrgencyLevel {
        // Special handling for critical abilities like "Alerting Shrill"
        if isCriticalHealerAbility(ability) {
            return .immediate
        }

        switch ability.damageProfile {
        case .critical:
            return ability.targets == .group ? .immediate : .high
        case .high:
            return ability.targets == .tank ? .high : .moderate
        case .moderate:
            return .moderate
        case .mechanic:
            return ability.type == .interrupt ? .high : .moderate
        }
    }

    private func determineComplexity(for ability: AbilityEntity) -> ComplexityLevel {
        var complexity: ComplexityLevel = .simple

        // Base complexity on ability type
        switch ability.type {
        case .damage:
            complexity = ability.targets == .group ? .moderate : .simple
        case .heal:
            complexity = .simple
        case .mechanic:
            complexity = .moderate
        case .movement:
            complexity = .moderate
        case .interrupt:
            complexity = .simple
        }

        // Increase complexity for critical abilities
        if ability.damageProfile == .critical {
            complexity = ComplexityLevel(rawValue: min(complexity.rawValue + 1, ComplexityLevel.extreme.rawValue)) ?? .extreme
        }

        // Increase complexity for key mechanics
        if ability.isKeyMechanic {
            complexity = ComplexityLevel(rawValue: min(complexity.rawValue + 1, ComplexityLevel.extreme.rawValue)) ?? .extreme
        }

        return complexity
    }

    private func determineHealerImpact(for ability: AbilityEntity) -> ImpactLevel {
        // Critical abilities always have critical impact
        if isCriticalHealerAbility(ability) {
            return .critical
        }

        switch ability.damageProfile {
        case .critical:
            return .critical
        case .high:
            return ability.targets == .group ? .high : .moderate
        case .moderate:
            return .moderate
        case .mechanic:
            return ability.type == .interrupt ? .high : .low
        }
    }

    private func generatePreparationRecommendation(for ability: AbilityEntity, urgency: UrgencyLevel, complexity: ComplexityLevel) -> String {
        var recommendations: [String] = []

        // Urgency-based recommendations
        switch urgency {
        case .immediate:
            recommendations.append("Pre-position for instant response")
        case .high:
            recommendations.append("Monitor closely and prepare cooldowns")
        case .moderate:
            recommendations.append("Plan response in healing rotation")
        case .low:
            recommendations.append("Monitor passively")
        }

        // Complexity-based recommendations
        switch complexity {
        case .extreme:
            recommendations.append("Coordinate with team beforehand")
        case .complex:
            recommendations.append("Practice multi-step response")
        case .moderate:
            recommendations.append("Prepare positioning and healing combo")
        case .simple:
            recommendations.append("Single response action required")
        }

        // Ability-specific recommendations
        if ability.cooldown != nil {
            recommendations.append("Track \(Int(ability.cooldown!))s cooldown for timing")
        }

        if ability.isKeyMechanic {
            recommendations.append("Mark as priority in encounter planning")
        }

        return recommendations.joined(separator: ". ")
    }

    private func isCriticalHealerAbility(_ ability: AbilityEntity) -> Bool {
        // Define abilities that require immediate healer response
        let criticalAbilityNames = [
            "Alerting Shrill",
            "Crushing Blow",
            "Death Grip",
            "Soul Burn",
            "Necrotic Strike",
            "Mind Control",
            "Fear",
            "Silence"
        ]

        return criticalAbilityNames.contains(ability.name) ||
               (ability.damageProfile == .critical && ability.targets == .group) ||
               (ability.type == .damage && ability.healerAction.lowercased().contains("immediate"))
    }

    private func requiresHealerAttention(_ ability: AbilityEntity) -> Bool {
        // Abilities that don't typically require healer attention
        let nonHealerTypes: [AbilityType] = [.movement]
        let nonHealerTargets: [TargetType] = [.location]

        // Movement abilities targeting locations are typically not healer-relevant
        if nonHealerTypes.contains(ability.type) && nonHealerTargets.contains(ability.targets) {
            return false
        }

        // All damage abilities require some healer attention
        if ability.type == .damage {
            return true
        }

        // Mechanics that affect healing
        if ability.type == .mechanic && (ability.healerAction.contains("dispel") || ability.healerAction.contains("heal")) {
            return true
        }

        // Default to requiring attention for safety
        return true
    }
}

// MARK: - Protocol Conformance

extension AbilityClassificationServiceImpl: AbilityClassificationService {
    // All methods are already implemented in the class body above
}