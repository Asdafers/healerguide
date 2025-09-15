//
//  ClassificationServiceTests.swift
//  AbilityKitTests
//
//  Unit tests for AbilityClassificationService - Task T037
//  iOS 13.1+ compatible - First generation iPad Pro support
//

import XCTest
@testable import AbilityKit

final class ClassificationServiceTests: XCTestCase {

    // MARK: - Test Infrastructure

    var classificationService: AbilityClassificationServiceImpl!

    override func setUpWithError() throws {
        try super.setUpWithError()
        classificationService = AbilityClassificationServiceImpl()
    }

    override func tearDownWithError() throws {
        classificationService = nil
        try super.tearDownWithError()
    }

    // MARK: - Helper Methods for Creating Test Entities

    private func createAbilityEntity(
        name: String,
        type: AbilityType = .damage,
        targets: TargetType = .tank,
        damageProfile: DamageProfile = .moderate,
        healerAction: String = "Standard healing response",
        criticalInsight: String = "Standard insight",
        cooldown: TimeInterval? = nil,
        isKeyMechanic: Bool = false
    ) -> AbilityEntity {
        return AbilityEntity(
            id: UUID(),
            name: name,
            type: type,
            bossEncounterId: UUID(),
            targets: targets,
            damageProfile: damageProfile,
            healerAction: healerAction,
            criticalInsight: criticalInsight,
            cooldown: cooldown,
            displayOrder: 1,
            isKeyMechanic: isKeyMechanic
        )
    }

    // MARK: - Ability Classification Tests

    func testClassifyAbilityCriticalGroupDamage() {
        // Arrange - Critical ability targeting group (like Alerting Shrill)
        let ability = createAbilityEntity(
            name: "Alerting Shrill",
            type: .damage,
            targets: .group,
            damageProfile: .critical,
            healerAction: "Use major defensive cooldown immediately",
            criticalInsight: "Can instantly kill players",
            cooldown: 45.0,
            isKeyMechanic: true
        )

        // Act
        let classification = classificationService.classifyAbility(ability)

        // Assert
        XCTAssertEqual(classification.urgency, .immediate)
        XCTAssertEqual(classification.complexity, .extreme) // Critical + key mechanic
        XCTAssertEqual(classification.healerImpact, .critical)
        XCTAssertFalse(classification.recommendedPreparation.isEmpty)
        XCTAssertTrue(classification.recommendedPreparation.contains("instant response"))
        XCTAssertTrue(classification.recommendedPreparation.contains("Coordinate with team"))
        XCTAssertTrue(classification.recommendedPreparation.contains("45s cooldown"))
        XCTAssertTrue(classification.recommendedPreparation.contains("priority"))
    }

    func testClassifyAbilityCriticalTankDamage() {
        // Arrange - Critical tank damage
        let ability = createAbilityEntity(
            name: "Crushing Blow",
            type: .damage,
            targets: .tank,
            damageProfile: .critical,
            healerAction: "Pre-heal tank to full and prepare emergency cooldown",
            criticalInsight: "Will kill tank if not at full health",
            cooldown: 30.0,
            isKeyMechanic: false
        )

        // Act
        let classification = classificationService.classifyAbility(ability)

        // Assert
        XCTAssertEqual(classification.urgency, .high) // Critical tank damage = high urgency
        XCTAssertEqual(classification.complexity, .complex) // Critical damage increased complexity
        XCTAssertEqual(classification.healerImpact, .critical)
        XCTAssertTrue(classification.recommendedPreparation.contains("closely"))
        XCTAssertTrue(classification.recommendedPreparation.contains("multi-step"))
        XCTAssertTrue(classification.recommendedPreparation.contains("30s cooldown"))
    }

    func testClassifyAbilityHighDamageKey() {
        // Arrange - High damage key mechanic
        let ability = createAbilityEntity(
            name: "Web Blast",
            type: .damage,
            targets: .randomPlayer,
            damageProfile: .high,
            healerAction: "Heal target immediately and watch for additional targets",
            criticalInsight: "Multiple players can be affected in sequence",
            cooldown: 15.0,
            isKeyMechanic: true
        )

        // Act
        let classification = classificationService.classifyAbility(ability)

        // Assert
        XCTAssertEqual(classification.urgency, .moderate) // High damage random player = moderate
        XCTAssertEqual(classification.complexity, .complex) // High + key mechanic
        XCTAssertEqual(classification.healerImpact, .moderate) // High damage random player = moderate impact
        XCTAssertTrue(classification.recommendedPreparation.contains("Plan response"))
        XCTAssertTrue(classification.recommendedPreparation.contains("multi-step"))
        XCTAssertTrue(classification.recommendedPreparation.contains("15s cooldown"))
        XCTAssertTrue(classification.recommendedPreparation.contains("priority"))
    }

    func testClassifyAbilityHighTankDamage() {
        // Arrange - High tank damage without key mechanic
        let ability = createAbilityEntity(
            name: "Heavy Strike",
            type: .damage,
            targets: .tank,
            damageProfile: .high,
            healerAction: "Keep tank topped off and be ready with instant heals",
            criticalInsight: "Consistent high damage requires sustained attention",
            cooldown: nil,
            isKeyMechanic: false
        )

        // Act
        let classification = classificationService.classifyAbility(ability)

        // Assert
        XCTAssertEqual(classification.urgency, .high) // High tank damage = high urgency
        XCTAssertEqual(classification.complexity, .simple) // Base damage complexity
        XCTAssertEqual(classification.healerImpact, .moderate) // High tank = moderate impact
        XCTAssertTrue(classification.recommendedPreparation.contains("Monitor closely"))
        XCTAssertTrue(classification.recommendedPreparation.contains("Single response"))
    }

    func testClassifyAbilityModerateGroupDamage() {
        // Arrange - Moderate group damage
        let ability = createAbilityEntity(
            name: "AOE Pulse",
            type: .damage,
            targets: .group,
            damageProfile: .moderate,
            healerAction: "Use group healing rotation to top off players",
            criticalInsight: "Predictable damage allows for planned healing",
            cooldown: 8.0,
            isKeyMechanic: false
        )

        // Act
        let classification = classificationService.classifyAbility(ability)

        // Assert
        XCTAssertEqual(classification.urgency, .moderate)
        XCTAssertEqual(classification.complexity, .moderate) // Group damage = moderate complexity
        XCTAssertEqual(classification.healerImpact, .moderate)
        XCTAssertTrue(classification.recommendedPreparation.contains("Plan response"))
        XCTAssertTrue(classification.recommendedPreparation.contains("positioning and healing"))
        XCTAssertTrue(classification.recommendedPreparation.contains("8s cooldown"))
    }

    func testClassifyAbilityInterruptMechanic() {
        // Arrange - Interrupt mechanic
        let ability = createAbilityEntity(
            name: "Dark Ritual",
            type: .mechanic,
            targets: .location,
            damageProfile: .mechanic,
            healerAction: "Interrupt if possible, otherwise prepare for damage spike",
            criticalInsight: "Stopping this prevents additional complications",
            cooldown: 20.0,
            isKeyMechanic: false
        )

        // Act
        let classification = classificationService.classifyAbility(ability)

        // Assert
        XCTAssertEqual(classification.urgency, .moderate) // Interrupt = moderate urgency
        XCTAssertEqual(classification.complexity, .moderate) // Mechanic = moderate complexity
        XCTAssertEqual(classification.healerImpact, .low) // Non-interrupt mechanic = low impact
        XCTAssertTrue(classification.recommendedPreparation.contains("Plan response"))
        XCTAssertTrue(classification.recommendedPreparation.contains("positioning and healing"))
        XCTAssertTrue(classification.recommendedPreparation.contains("20s cooldown"))
    }

    func testClassifyAbilityMovementMechanic() {
        // Arrange - Movement ability
        let ability = createAbilityEntity(
            name: "Phase Shift",
            type: .movement,
            targets: .location,
            damageProfile: .mechanic,
            healerAction: "Reposition to maintain healing range",
            criticalInsight: "Boss will teleport, adjust positioning accordingly",
            cooldown: nil,
            isKeyMechanic: false
        )

        // Act
        let classification = classificationService.classifyAbility(ability)

        // Assert
        XCTAssertEqual(classification.urgency, .moderate) // Movement = moderate urgency
        XCTAssertEqual(classification.complexity, .moderate) // Movement = moderate complexity
        XCTAssertEqual(classification.healerImpact, .low) // Movement mechanic = low impact
        XCTAssertTrue(classification.recommendedPreparation.contains("Plan response"))
        XCTAssertTrue(classification.recommendedPreparation.contains("positioning and healing"))
    }

    // MARK: - Critical Ability Recognition Tests

    func testCriticalAbilityRecognitionByName() {
        let criticalNames = ["Alerting Shrill", "Crushing Blow", "Death Grip", "Soul Burn", "Necrotic Strike", "Mind Control", "Fear", "Silence"]

        for name in criticalNames {
            // Arrange
            let ability = createAbilityEntity(
                name: name,
                type: .damage,
                targets: .tank,
                damageProfile: .moderate, // Even moderate profile should be recognized as critical
                healerAction: "Test action",
                criticalInsight: "Test insight"
            )

            // Act
            let classification = classificationService.classifyAbility(ability)

            // Assert
            XCTAssertEqual(classification.urgency, .immediate, "Ability '\(name)' should have immediate urgency")
            XCTAssertEqual(classification.healerImpact, .critical, "Ability '\(name)' should have critical impact")
        }
    }

    func testCriticalAbilityRecognitionByCriticalGroupDamage() {
        // Arrange - Critical group damage (not in name list)
        let ability = createAbilityEntity(
            name: "Unknown Group Blast",
            type: .damage,
            targets: .group,
            damageProfile: .critical,
            healerAction: "Emergency response required",
            criticalInsight: "Devastating group damage"
        )

        // Act
        let classification = classificationService.classifyAbility(ability)

        // Assert
        XCTAssertEqual(classification.urgency, .immediate)
        XCTAssertEqual(classification.healerImpact, .critical)
    }

    func testCriticalAbilityRecognitionByImmediateKeyword() {
        // Arrange - Ability with "immediate" in healer action
        let ability = createAbilityEntity(
            name: "Emergency Blast",
            type: .damage,
            targets: .randomPlayer,
            damageProfile: .moderate, // Even moderate should be recognized as critical due to keyword
            healerAction: "Immediate response required - use cooldown",
            criticalInsight: "Time-sensitive ability"
        )

        // Act
        let classification = classificationService.classifyAbility(ability)

        // Assert
        XCTAssertEqual(classification.urgency, .immediate)
        XCTAssertEqual(classification.healerImpact, .critical)
    }

    // MARK: - Recommended Actions Tests

    func testGetRecommendedActionsCritical() {
        // Act
        let actions = classificationService.getRecommendedActions(for: .critical)

        // Assert
        XCTAssertEqual(actions.count, 3)

        let cooldownAction = actions.first { $0.actionType == .cooldownUse }
        XCTAssertNotNil(cooldownAction)
        XCTAssertEqual(cooldownAction?.timing, .immediate)
        XCTAssertEqual(cooldownAction?.keyBindSuggestion, "F1")
        XCTAssertTrue(cooldownAction?.description.contains("major defensive") == true)

        let prehealAction = actions.first { $0.actionType == .preHeal }
        XCTAssertNotNil(prehealAction)
        XCTAssertEqual(prehealAction?.timing, .immediate)
        XCTAssertEqual(prehealAction?.keyBindSuggestion, "F2")
        XCTAssertTrue(prehealAction?.description.contains("Top off all players") == true)

        let positionAction = actions.first { $0.actionType == .positioning }
        XCTAssertNotNil(positionAction)
        XCTAssertEqual(positionAction?.timing, .fast)
        XCTAssertNil(positionAction?.keyBindSuggestion)
        XCTAssertTrue(positionAction?.description.contains("maximum healing range") == true)
    }

    func testGetRecommendedActionsHigh() {
        // Act
        let actions = classificationService.getRecommendedActions(for: .high)

        // Assert
        XCTAssertEqual(actions.count, 2)

        let prehealAction = actions.first { $0.actionType == .preHeal }
        XCTAssertNotNil(prehealAction)
        XCTAssertEqual(prehealAction?.timing, .fast)
        XCTAssertEqual(prehealAction?.keyBindSuggestion, "Shift+F1")
        XCTAssertTrue(prehealAction?.description.contains("likely targets") == true)

        let reactiveAction = actions.first { $0.actionType == .reactiveHeal }
        XCTAssertNotNil(reactiveAction)
        XCTAssertEqual(reactiveAction?.timing, .fast)
        XCTAssertEqual(reactiveAction?.keyBindSuggestion, "F3")
        XCTAssertTrue(reactiveAction?.description.contains("instant heals") == true)
    }

    func testGetRecommendedActionsModerate() {
        // Act
        let actions = classificationService.getRecommendedActions(for: .moderate)

        // Assert
        XCTAssertEqual(actions.count, 2)

        let reactiveAction = actions.first { $0.actionType == .reactiveHeal }
        XCTAssertNotNil(reactiveAction)
        XCTAssertEqual(reactiveAction?.timing, .planned)
        XCTAssertEqual(reactiveAction?.keyBindSuggestion, "F4")
        XCTAssertTrue(reactiveAction?.description.contains("healing rotation") == true)

        let positionAction = actions.first { $0.actionType == .positioning }
        XCTAssertNotNil(positionAction)
        XCTAssertEqual(positionAction?.timing, .planned)
        XCTAssertNil(positionAction?.keyBindSuggestion)
        XCTAssertTrue(positionAction?.description.contains("optimal healing") == true)
    }

    func testGetRecommendedActionsMechanic() {
        // Act
        let actions = classificationService.getRecommendedActions(for: .mechanic)

        // Assert
        XCTAssertEqual(actions.count, 2)

        let dispelAction = actions.first { $0.actionType == .dispel }
        XCTAssertNotNil(dispelAction)
        XCTAssertEqual(dispelAction?.timing, .immediate)
        XCTAssertEqual(dispelAction?.keyBindSuggestion, "F5")
        XCTAssertTrue(dispelAction?.description.contains("Dispel harmful effects") == true)

        let interruptAction = actions.first { $0.actionType == .interrupt }
        XCTAssertNotNil(interruptAction)
        XCTAssertEqual(interruptAction?.timing, .immediate)
        XCTAssertEqual(interruptAction?.keyBindSuggestion, "F6")
        XCTAssertTrue(interruptAction?.description.contains("Interrupt dangerous casts") == true)
    }

    // MARK: - Validation Tests

    func testValidateHealerRelevanceCriticalAbilityNotMarked() {
        // Arrange - Critical ability not marked as critical profile
        let ability = createAbilityEntity(
            name: "Alerting Shrill",
            type: .damage,
            targets: .group,
            damageProfile: .moderate, // Should be critical
            healerAction: "Use major cooldown",
            criticalInsight: "Deadly ability"
        )

        // Act
        let result = classificationService.validateHealerRelevance(ability)

        // Assert
        XCTAssertTrue(result.isValid) // Only warnings, not errors
        XCTAssertEqual(result.issues.count, 1)
        XCTAssertEqual(result.issues[0].severity, .warning)
        XCTAssertEqual(result.issues[0].field, "damageProfile")
        XCTAssertTrue(result.issues[0].message.contains("immediate healer response"))
        XCTAssertTrue(result.recommendations.contains("critical"))
    }

    func testValidateHealerRelevanceMissingAction() {
        // Arrange - Empty healer action
        let ability = createAbilityEntity(
            name: "Test Ability",
            healerAction: "", // Empty action
            criticalInsight: "Test insight"
        )

        // Act
        let result = classificationService.validateHealerRelevance(ability)

        // Assert
        XCTAssertFalse(result.isValid) // Error makes it invalid
        XCTAssertTrue(result.issues.contains { $0.severity == .error })
        XCTAssertTrue(result.issues.contains { $0.field == "healerAction" })
        XCTAssertTrue(result.recommendations.contains("Add specific healer action"))
    }

    func testValidateHealerRelevanceNonHealerAbility() {
        // Arrange - Movement ability targeting location (typically not healer-relevant)
        let ability = createAbilityEntity(
            name: "Phase Shift",
            type: .movement,
            targets: .location,
            damageProfile: .mechanic,
            healerAction: "Reposition as needed",
            criticalInsight: "Boss movement ability"
        )

        // Act
        let result = classificationService.validateHealerRelevance(ability)

        // Assert
        XCTAssertTrue(result.isValid) // Info issues don't make it invalid
        XCTAssertTrue(result.issues.contains { $0.severity == .info })
        XCTAssertTrue(result.issues.contains { $0.field == "type" })
        XCTAssertTrue(result.recommendations.contains("excluding from healer-focused"))
    }

    func testValidateHealerRelevanceCriticalMissingCooldown() {
        // Arrange - Critical ability without cooldown timing
        let ability = createAbilityEntity(
            name: "Critical Strike",
            damageProfile: .critical,
            healerAction: "Emergency response",
            criticalInsight: "Critical damage",
            cooldown: nil // Missing cooldown
        )

        // Act
        let result = classificationService.validateHealerRelevance(ability)

        // Assert
        XCTAssertTrue(result.isValid) // Warning doesn't invalidate
        XCTAssertTrue(result.issues.contains { $0.severity == .warning && $0.field == "cooldown" })
        XCTAssertTrue(result.recommendations.contains("cooldown information"))
    }

    func testValidateHealerRelevanceCriticalNotKeyMechanic() {
        // Arrange - Critical ability not marked as key mechanic
        let ability = createAbilityEntity(
            name: "Critical Blast",
            damageProfile: .critical,
            healerAction: "Emergency response",
            criticalInsight: "Critical damage",
            isKeyMechanic: false // Should be true for critical abilities
        )

        // Act
        let result = classificationService.validateHealerRelevance(ability)

        // Assert
        XCTAssertTrue(result.isValid) // Info doesn't invalidate
        XCTAssertTrue(result.issues.contains { $0.severity == .info && $0.field == "isKeyMechanic" })
        XCTAssertTrue(result.recommendations.contains("key mechanics for prominence"))
    }

    func testValidateHealerRelevanceValidAbility() {
        // Arrange - Properly configured ability
        let ability = createAbilityEntity(
            name: "Well Configured Ability",
            damageProfile: .high,
            healerAction: "Heal target and prepare for next",
            criticalInsight: "Significant but manageable damage",
            cooldown: 30.0,
            isKeyMechanic: false
        )

        // Act
        let result = classificationService.validateHealerRelevance(ability)

        // Assert
        XCTAssertTrue(result.isValid)
        XCTAssertTrue(result.issues.isEmpty)
        XCTAssertTrue(result.recommendations.isEmpty)
    }

    func testValidateHealerRelevanceDamageAbilityAlwaysRelevant() {
        // Arrange - Any damage ability should be relevant
        let ability = createAbilityEntity(
            name: "Standard Attack",
            type: .damage,
            targets: .tank,
            damageProfile: .moderate,
            healerAction: "Monitor tank health",
            criticalInsight: "Regular tank damage"
        )

        // Act
        let result = classificationService.validateHealerRelevance(ability)

        // Assert - Should not have irrelevance warning
        XCTAssertFalse(result.issues.contains { $0.message.contains("not be relevant for healers") })
    }

    func testValidateHealerRelevanceDispelMechanic() {
        // Arrange - Mechanic with dispel in action (healer-relevant)
        let ability = createAbilityEntity(
            name: "Curse Application",
            type: .mechanic,
            targets: .randomPlayer,
            damageProfile: .mechanic,
            healerAction: "Dispel curse immediately to prevent damage",
            criticalInsight: "Curse causes damage over time"
        )

        // Act
        let result = classificationService.validateHealerRelevance(ability)

        // Assert - Should not have irrelevance warning due to dispel mention
        XCTAssertFalse(result.issues.contains { $0.message.contains("not be relevant for healers") })
    }

    // MARK: - Complexity Assessment Tests

    func testComplexitySimpleDamage() {
        // Arrange - Simple single-target damage
        let ability = createAbilityEntity(
            name: "Basic Attack",
            type: .damage,
            targets: .tank,
            damageProfile: .moderate,
            healerAction: "Heal tank",
            criticalInsight: "Standard attack"
        )

        // Act
        let classification = classificationService.classifyAbility(ability)

        // Assert
        XCTAssertEqual(classification.complexity, .simple)
    }

    func testComplexityModerateGroupDamage() {
        // Arrange - Group damage ability
        let ability = createAbilityEntity(
            name: "Group Blast",
            type: .damage,
            targets: .group,
            damageProfile: .moderate,
            healerAction: "Heal all players",
            criticalInsight: "AOE damage"
        )

        // Act
        let classification = classificationService.classifyAbility(ability)

        // Assert
        XCTAssertEqual(classification.complexity, .moderate)
    }

    func testComplexityModerateMechanic() {
        // Arrange - Mechanic ability
        let ability = createAbilityEntity(
            name: "Phase Change",
            type: .mechanic,
            targets: .location,
            damageProfile: .mechanic,
            healerAction: "Adjust positioning",
            criticalInsight: "Boss behavior changes"
        )

        // Act
        let classification = classificationService.classifyAbility(ability)

        // Assert
        XCTAssertEqual(classification.complexity, .moderate)
    }

    func testComplexityModerateMovement() {
        // Arrange - Movement ability
        let ability = createAbilityEntity(
            name: "Teleport",
            type: .movement,
            targets: .location,
            damageProfile: .mechanic,
            healerAction: "Follow boss movement",
            criticalInsight: "Boss relocates"
        )

        // Act
        let classification = classificationService.classifyAbility(ability)

        // Assert
        XCTAssertEqual(classification.complexity, .moderate)
    }

    func testComplexitySimpleInterrupt() {
        // Arrange - Interrupt ability
        let ability = createAbilityEntity(
            name: "Interruptible Cast",
            type: .interrupt,
            targets: .location,
            damageProfile: .mechanic,
            healerAction: "Interrupt if possible",
            criticalInsight: "Can be stopped"
        )

        // Act
        let classification = classificationService.classifyAbility(ability)

        // Assert
        XCTAssertEqual(classification.complexity, .simple)
    }

    func testComplexitySimpleHeal() {
        // Arrange - Heal ability
        let ability = createAbilityEntity(
            name: "Boss Heal",
            type: .heal,
            targets: .location,
            damageProfile: .mechanic,
            healerAction: "Interrupt or dispel",
            criticalInsight: "Boss heals itself"
        )

        // Act
        let classification = classificationService.classifyAbility(ability)

        // Assert
        XCTAssertEqual(classification.complexity, .simple)
    }

    func testComplexityUpgradedByCritical() {
        // Arrange - Critical ability (should upgrade complexity)
        let ability = createAbilityEntity(
            name: "Critical Simple Attack",
            type: .damage,
            targets: .tank,
            damageProfile: .critical, // Should upgrade complexity
            healerAction: "Emergency response",
            criticalInsight: "Lethal if not handled"
        )

        // Act
        let classification = classificationService.classifyAbility(ability)

        // Assert
        XCTAssertEqual(classification.complexity, .complex) // Upgraded from simple to complex
    }

    func testComplexityUpgradedByKeyMechanic() {
        // Arrange - Key mechanic (should upgrade complexity)
        let ability = createAbilityEntity(
            name: "Key Mechanic Attack",
            type: .damage,
            targets: .tank,
            damageProfile: .moderate,
            healerAction: "Coordinated response",
            criticalInsight: "Important mechanic",
            isKeyMechanic: true // Should upgrade complexity
        )

        // Act
        let classification = classificationService.classifyAbility(ability)

        // Assert
        XCTAssertEqual(classification.complexity, .complex) // Upgraded from simple to complex
    }

    func testComplexityMaxExtreme() {
        // Arrange - Critical key mechanic (should be extreme complexity)
        let ability = createAbilityEntity(
            name: "Critical Key Mechanic",
            type: .damage,
            targets: .group, // Starts at moderate
            damageProfile: .critical, // +1 to complex
            healerAction: "Full team coordination required",
            criticalInsight: "Encounter-defining moment",
            isKeyMechanic: true // +1 to extreme
        )

        // Act
        let classification = classificationService.classifyAbility(ability)

        // Assert
        XCTAssertEqual(classification.complexity, .extreme)
    }

    // MARK: - Urgency Assessment Tests

    func testUrgencyImmediateForCriticalAbility() {
        // Arrange - Known critical ability
        let ability = createAbilityEntity(
            name: "Alerting Shrill",
            damageProfile: .moderate, // Name recognition should override profile
            healerAction: "Emergency response",
            criticalInsight: "Critical ability"
        )

        // Act
        let classification = classificationService.classifyAbility(ability)

        // Assert
        XCTAssertEqual(classification.urgency, .immediate)
    }

    func testUrgencyImmediateForCriticalGroup() {
        // Arrange - Critical group damage
        let ability = createAbilityEntity(
            name: "Unknown Group Damage",
            targets: .group,
            damageProfile: .critical,
            healerAction: "Emergency group healing",
            criticalInsight: "Devastating AOE"
        )

        // Act
        let classification = classificationService.classifyAbility(ability)

        // Assert
        XCTAssertEqual(classification.urgency, .immediate)
    }

    func testUrgencyHighForCriticalTank() {
        // Arrange - Critical tank damage
        let ability = createAbilityEntity(
            name: "Tank Buster",
            targets: .tank,
            damageProfile: .critical,
            healerAction: "Pre-heal tank",
            criticalInsight: "High tank damage"
        )

        // Act
        let classification = classificationService.classifyAbility(ability)

        // Assert
        XCTAssertEqual(classification.urgency, .high)
    }

    func testUrgencyHighForHighTank() {
        // Arrange - High tank damage
        let ability = createAbilityEntity(
            name: "Heavy Strike",
            targets: .tank,
            damageProfile: .high,
            healerAction: "Keep tank topped",
            criticalInsight: "Significant tank damage"
        )

        // Act
        let classification = classificationService.classifyAbility(ability)

        // Assert
        XCTAssertEqual(classification.urgency, .high)
    }

    func testUrgencyModerateForHighNonTank() {
        // Arrange - High damage not targeting tank
        let ability = createAbilityEntity(
            name: "Random Blast",
            targets: .randomPlayer,
            damageProfile: .high,
            healerAction: "Heal target",
            criticalInsight: "Random high damage"
        )

        // Act
        let classification = classificationService.classifyAbility(ability)

        // Assert
        XCTAssertEqual(classification.urgency, .moderate)
    }

    func testUrgencyModerateForModerate() {
        // Arrange - Moderate damage
        let ability = createAbilityEntity(
            name: "Standard Attack",
            damageProfile: .moderate,
            healerAction: "Standard healing",
            criticalInsight: "Regular damage"
        )

        // Act
        let classification = classificationService.classifyAbility(ability)

        // Assert
        XCTAssertEqual(classification.urgency, .moderate)
    }

    func testUrgencyHighForInterruptMechanic() {
        // Arrange - Interrupt mechanic
        let ability = createAbilityEntity(
            name: "Interruptible Cast",
            type: .interrupt,
            damageProfile: .mechanic,
            healerAction: "Interrupt to prevent damage",
            criticalInsight: "Preventable damage source"
        )

        // Act
        let classification = classificationService.classifyAbility(ability)

        // Assert
        XCTAssertEqual(classification.urgency, .high)
    }

    func testUrgencyModerateForNonInterruptMechanic() {
        // Arrange - Non-interrupt mechanic
        let ability = createAbilityEntity(
            name: "Phase Change",
            type: .mechanic,
            damageProfile: .mechanic,
            healerAction: "Adapt to new phase",
            criticalInsight: "Boss behavior changes"
        )

        // Act
        let classification = classificationService.classifyAbility(ability)

        // Assert
        XCTAssertEqual(classification.urgency, .moderate)
    }

    // MARK: - Healer Impact Assessment Tests

    func testHealerImpactCriticalForCriticalAbilities() {
        // Arrange - Critical ability by name
        let ability = createAbilityEntity(
            name: "Alerting Shrill",
            damageProfile: .moderate, // Should be overridden
            healerAction: "Emergency response",
            criticalInsight: "Critical ability"
        )

        // Act
        let classification = classificationService.classifyAbility(ability)

        // Assert
        XCTAssertEqual(classification.healerImpact, .critical)
    }

    func testHealerImpactCriticalForCriticalProfile() {
        // Arrange - Critical damage profile
        let ability = createAbilityEntity(
            name: "Unknown Critical",
            damageProfile: .critical,
            healerAction: "Emergency response",
            criticalInsight: "Critical damage"
        )

        // Act
        let classification = classificationService.classifyAbility(ability)

        // Assert
        XCTAssertEqual(classification.healerImpact, .critical)
    }

    func testHealerImpactHighForHighGroup() {
        // Arrange - High group damage
        let ability = createAbilityEntity(
            name: "Group Damage",
            targets: .group,
            damageProfile: .high,
            healerAction: "Group healing",
            criticalInsight: "Significant AOE"
        )

        // Act
        let classification = classificationService.classifyAbility(ability)

        // Assert
        XCTAssertEqual(classification.healerImpact, .high)
    }

    func testHealerImpactModerateForHighNonGroup() {
        // Arrange - High single-target damage
        let ability = createAbilityEntity(
            name: "Single Target",
            targets: .tank,
            damageProfile: .high,
            healerAction: "Heal tank",
            criticalInsight: "High single damage"
        )

        // Act
        let classification = classificationService.classifyAbility(ability)

        // Assert
        XCTAssertEqual(classification.healerImpact, .moderate)
    }

    func testHealerImpactModerateForModerate() {
        // Arrange - Moderate damage
        let ability = createAbilityEntity(
            name: "Standard Damage",
            damageProfile: .moderate,
            healerAction: "Standard response",
            criticalInsight: "Regular damage"
        )

        // Act
        let classification = classificationService.classifyAbility(ability)

        // Assert
        XCTAssertEqual(classification.healerImpact, .moderate)
    }

    func testHealerImpactHighForInterruptMechanic() {
        // Arrange - Interrupt mechanic
        let ability = createAbilityEntity(
            name: "Interruptible Cast",
            type: .interrupt,
            damageProfile: .mechanic,
            healerAction: "Interrupt if possible",
            criticalInsight: "Preventable damage"
        )

        // Act
        let classification = classificationService.classifyAbility(ability)

        // Assert
        XCTAssertEqual(classification.healerImpact, .high)
    }

    func testHealerImpactLowForNonInterruptMechanic() {
        // Arrange - Non-interrupt mechanic
        let ability = createAbilityEntity(
            name: "Phase Change",
            type: .mechanic,
            damageProfile: .mechanic,
            healerAction: "Adjust strategy",
            criticalInsight: "Boss behavior change"
        )

        // Act
        let classification = classificationService.classifyAbility(ability)

        // Assert
        XCTAssertEqual(classification.healerImpact, .low)
    }

    // MARK: - Preparation Recommendation Tests

    func testPreparationRecommendationComponents() {
        // Arrange - Ability with cooldown, key mechanic, immediate urgency, extreme complexity
        let ability = createAbilityEntity(
            name: "Alerting Shrill",
            type: .damage,
            targets: .group,
            damageProfile: .critical,
            healerAction: "Use major defensive cooldown immediately",
            criticalInsight: "Can instantly kill players",
            cooldown: 45.0,
            isKeyMechanic: true
        )

        // Act
        let classification = classificationService.classifyAbility(ability)

        // Assert - Check all expected components are present
        let preparation = classification.recommendedPreparation
        XCTAssertTrue(preparation.contains("instant response")) // Immediate urgency
        XCTAssertTrue(preparation.contains("Coordinate with team")) // Extreme complexity
        XCTAssertTrue(preparation.contains("45s cooldown")) // Cooldown tracking
        XCTAssertTrue(preparation.contains("priority")) // Key mechanic
    }

    func testPreparationRecommendationHighComplexity() {
        // Arrange - High urgency, complex ability
        let ability = createAbilityEntity(
            name: "Tank Buster",
            targets: .tank,
            damageProfile: .critical,
            healerAction: "Pre-heal tank to full",
            criticalInsight: "Will kill tank if not prepared",
            cooldown: 20.0,
            isKeyMechanic: false
        )

        // Act
        let classification = classificationService.classifyAbility(ability)

        // Assert
        let preparation = classification.recommendedPreparation
        XCTAssertTrue(preparation.contains("Monitor closely")) // High urgency
        XCTAssertTrue(preparation.contains("multi-step")) // Complex complexity
        XCTAssertTrue(preparation.contains("20s cooldown")) // Cooldown tracking
        XCTAssertFalse(preparation.contains("priority")) // Not key mechanic
    }

    func testPreparationRecommendationModeratePlanned() {
        // Arrange - Moderate urgency and complexity
        let ability = createAbilityEntity(
            name: "AOE Damage",
            targets: .group,
            damageProfile: .moderate,
            healerAction: "Use group healing rotation",
            criticalInsight: "Predictable AOE damage",
            cooldown: nil,
            isKeyMechanic: false
        )

        // Act
        let classification = classificationService.classifyAbility(ability)

        // Assert
        let preparation = classification.recommendedPreparation
        XCTAssertTrue(preparation.contains("Plan response")) // Moderate urgency
        XCTAssertTrue(preparation.contains("positioning and healing")) // Moderate complexity
        XCTAssertFalse(preparation.contains("cooldown")) // No cooldown
        XCTAssertFalse(preparation.contains("priority")) // Not key mechanic
    }

    func testPreparationRecommendationLowSimple() {
        // Arrange - Low urgency, simple complexity
        let ability = createAbilityEntity(
            name: "Minor Effect",
            type: .heal,
            damageProfile: .mechanic,
            healerAction: "Monitor passively",
            criticalInsight: "Minor boss heal",
            cooldown: nil,
            isKeyMechanic: false
        )

        // Act
        let classification = classificationService.classifyAbility(ability)

        // Assert
        let preparation = classification.recommendedPreparation
        XCTAssertTrue(preparation.contains("Monitor passively")) // Low urgency
        XCTAssertTrue(preparation.contains("Single response")) // Simple complexity
    }

    // MARK: - Edge Cases and Error Conditions

    func testClassificationWithNilCooldown() {
        // Arrange - Ability without cooldown
        let ability = createAbilityEntity(
            name: "No Cooldown Ability",
            cooldown: nil
        )

        // Act
        let classification = classificationService.classifyAbility(ability)

        // Assert - Should handle nil cooldown gracefully
        XCTAssertNotNil(classification)
        XCTAssertFalse(classification.recommendedPreparation.contains("cooldown"))
    }

    func testClassificationWithZeroCooldown() {
        // Arrange - Ability with zero cooldown
        let ability = createAbilityEntity(
            name: "Zero Cooldown Ability",
            cooldown: 0.0
        )

        // Act
        let classification = classificationService.classifyAbility(ability)

        // Assert - Should handle zero cooldown appropriately
        XCTAssertNotNil(classification)
        XCTAssertTrue(classification.recommendedPreparation.contains("0s cooldown"))
    }

    func testEnumConformanceAllCases() {
        // Test that all enum cases are handled properly
        XCTAssertEqual(UrgencyLevel.allCases.count, 4)
        XCTAssertEqual(ComplexityLevel.allCases.count, 4)
        XCTAssertEqual(ImpactLevel.allCases.count, 4)
        XCTAssertEqual(HealerActionType.allCases.count, 6)
        XCTAssertEqual(ActionTiming.allCases.count, 3)

        // Test raw values
        XCTAssertEqual(UrgencyLevel.immediate.rawValue, 4)
        XCTAssertEqual(ComplexityLevel.extreme.rawValue, 4)
        XCTAssertEqual(ImpactLevel.critical.rawValue, 4)
    }

    func testServiceProtocolConformance() {
        // Test that service conforms to protocol
        let service: AbilityClassificationService = classificationService

        // Should be able to call protocol methods
        let testAbility = createAbilityEntity(name: "Test")
        let classification = service.classifyAbility(testAbility)
        let actions = service.getRecommendedActions(for: .critical)
        let validation = service.validateHealerRelevance(testAbility)

        XCTAssertNotNil(classification)
        XCTAssertNotNil(actions)
        XCTAssertNotNil(validation)
    }
}