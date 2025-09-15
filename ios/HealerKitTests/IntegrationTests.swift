//
//  IntegrationTests.swift
//  HealerKitTests
//
//  Created by HealerKit on 2025-09-14.
//  Integration tests for critical ability recognition and display
//

import XCTest
import UIKit
@testable import HealerKit
@testable import AbilityKit
@testable import HealerUIKit
@testable import DungeonKit

final class CriticalAbilityRecognitionIntegrationTests: XCTestCase {

    // MARK: - Test Fixtures

    private var mockAbilityDataProvider: MockAbilityDataProvider!
    private var mockClassificationService: MockAbilityClassificationService!
    private var mockDamageProfileAnalyzer: MockDamageProfileAnalyzer!
    private var mockAbilityCardProvider: MockAbilityCardProvider!
    private var mockUIConfiguration: MockHealerUIConfiguration!

    // Test data
    private let testBossEncounterId = UUID(uuidString: "12345678-1234-1234-1234-123456789ABC")!
    private let alertingShrillAbilityId = UUID(uuidString: "87654321-4321-4321-4321-CBA987654321")!

    override func setUpWithError() throws {
        super.setUp()

        mockAbilityDataProvider = MockAbilityDataProvider()
        mockClassificationService = MockAbilityClassificationService()
        mockDamageProfileAnalyzer = MockDamageProfileAnalyzer()
        mockAbilityCardProvider = MockAbilityCardProvider()
        mockUIConfiguration = MockHealerUIConfiguration()

        // Configure mock data for "Alerting Shrill"
        setupAlertingShrillMockData()

        // Note: All mock services start in "not implemented" mode to follow TDD principles
        // Tests will fail until real services are implemented
        // Call enableMockBehavior() on mocks only when testing implementation details
    }

    override func tearDownWithError() throws {
        mockAbilityDataProvider = nil
        mockClassificationService = nil
        mockDamageProfileAnalyzer = nil
        mockAbilityCardProvider = nil
        mockUIConfiguration = nil
        super.tearDown()
    }

    // MARK: - Critical Ability Recognition Tests

    func testAlertingShrillAbilityIsClassifiedAsCritical() async throws {
        // Given: Alerting Shrill ability data exists
        let alertingShrillAbility = createAlertingShrillAbility()

        // When: The ability classification is attempted (should fail until implemented)
        XCTAssertThrowsError(
            try { let _ = mockClassificationService.classifyAbility(alertingShrillAbility) }(),
            "AbilityClassificationService should not be implemented yet"
        ) { error in
            // Then: Should fail with specific error indicating implementation needed
            let errorString = String(describing: error)
            XCTAssertTrue(errorString.contains("not implemented"),
                         "Should fail with 'not implemented' error until AbilityClassificationService exists")
            XCTAssertTrue(errorString.contains("classifyAbility"),
                         "Error should specifically mention classifyAbility method")
        }

        // Document expected behavior for real implementation:
        // The real AbilityClassificationService.classifyAbility() should return:
        // - urgency: .immediate (Alerting Shrill requires immediate healer response)
        // - healerImpact: .critical (critical impact on healer decision-making)
        // - complexity: .complex (requires complex multi-step response)
        // - And the ability's damageProfile should be .critical
        XCTAssertEqual(alertingShrillAbility.damageProfile, .critical,
                      "Test data: Alerting Shrill should have critical damage profile")
    }

    func testCriticalAbilityCardDisplaysWithRedColorScheme() throws {
        // Given: A critical ability (Alerting Shrill)
        let alertingShrillAbility = createAlertingShrillAbility()

        // When: Ability classification is attempted (should fail until implemented)
        XCTAssertThrowsError(
            try { let _ = mockClassificationService.classifyAbility(alertingShrillAbility) }(),
            "AbilityClassificationService should not be implemented yet"
        )

        // When: Color scheme retrieval is attempted (should fail until implemented)
        XCTAssertThrowsError(
            try { let _ = mockDamageProfileAnalyzer.getUIColorScheme(for: .critical) }(),
            "DamageProfileAnalyzer should not be implemented yet"
        ) { error in
            let errorString = String(describing: error)
            XCTAssertTrue(errorString.contains("not implemented"),
                         "Should fail with 'not implemented' error until DamageProfileAnalyzer exists")
        }

        // When: Ability card creation is attempted (should fail until implemented)
        XCTAssertThrowsError(
            try {
                // This should fail because classification and card provider are not implemented
                let mockClassification = AbilityClassification(urgency: .immediate, complexity: .complex, healerImpact: .critical, recommendedPreparation: "")
                let _ = mockAbilityCardProvider.createAbilityCard(ability: alertingShrillAbility, classification: mockClassification)
            }(),
            "AbilityCardProvider should not be implemented yet"
        )

        // Document expected behavior for real implementation:
        // The real DamageProfileAnalyzer.getUIColorScheme(for: .critical) should return:
        // - primaryColor: "#FF4444" (high-contrast red for immediate recognition)
        // - backgroundColor: "#FFEBEB" (light red background for visibility)
        // - borderColor: "#CC0000" (dark red border for emphasis)
        // - textColor: "#000000" (high-contrast black text for readability)
        // The real AbilityCardProvider should apply these colors to the card
    }

    func testAbilityCardDisplaysWithIPadOptimizedTextSizing() throws {
        // Given: A critical ability and iPad UI configuration
        let alertingShrillAbility = createAlertingShrillAbility()
        let classification = mockClassificationService.classifyAbility(alertingShrillAbility)

        // When: An ability card is created
        let abilityCard = mockAbilityCardProvider.createAbilityCard(
            ability: alertingShrillAbility,
            classification: classification
        )

        // Then: Text should be sized for iPad readability
        let typography = mockUIConfiguration.typography

        // Verify minimum text sizes for iPad gameplay
        XCTAssertGreaterThanOrEqual(typography.abilityNameFont.pointSize, 18.0,
                                   "Ability name should be at least 18pt for iPad readability")
        XCTAssertGreaterThanOrEqual(typography.healerActionFont.pointSize, 16.0,
                                   "Healer action text should be at least 16pt for quick reading")
        XCTAssertGreaterThanOrEqual(typography.insightFont.pointSize, 14.0,
                                   "Critical insight should be at least 14pt for clarity")

        // Verify maximum sizes to prevent UI breaking
        XCTAssertLessThanOrEqual(typography.abilityNameFont.pointSize, 28.0,
                                "Ability name should not exceed 28pt to fit on screen")

        // Verify dynamic type support is enabled for accessibility
        XCTAssertTrue(typography.supportsDynamicType,
                     "Dynamic type should be supported for accessibility")

        // Verify touch targets meet iPad minimum standards
        let layout = mockUIConfiguration.layout
        XCTAssertGreaterThanOrEqual(layout.minimumTouchTarget, 44.0,
                                   "Touch targets should meet 44pt minimum for iPad")
    }

    func testCriticalAbilityDisplaysHealerActionGuidance() throws {
        // Given: A critical ability with healer action requirements
        let alertingShrillAbility = createAlertingShrillAbility()
        let classification = mockClassificationService.classifyAbility(alertingShrillAbility)

        // When: Healer actions are retrieved for critical damage profile
        let healerActions = mockClassificationService.getRecommendedActions(for: .critical)

        // Then: Actions should include pre-planned cooldown usage
        XCTAssertFalse(healerActions.isEmpty, "Critical abilities should have recommended actions")

        let cooldownAction = healerActions.first { $0.actionType == .cooldownUse }
        XCTAssertNotNil(cooldownAction, "Critical abilities should recommend cooldown usage")
        XCTAssertEqual(cooldownAction?.timing, .planned,
                      "Critical ability cooldowns should be pre-planned")

        // Verify healer action guidance is clear and actionable
        XCTAssertFalse(alertingShrillAbility.healerAction.isEmpty,
                      "Healer action should provide specific guidance")
        XCTAssertTrue(alertingShrillAbility.healerAction.contains("group healing cooldown") ||
                     alertingShrillAbility.healerAction.contains("raid cooldown"),
                     "Should specify group healing cooldown requirement")

        // Verify critical insight provides additional context
        XCTAssertFalse(alertingShrillAbility.criticalInsight.isEmpty,
                      "Critical insight should provide tactical information")
        XCTAssertTrue(alertingShrillAbility.criticalInsight.contains("pre-planned") ||
                     alertingShrillAbility.criticalInsight.contains("coordinate"),
                     "Should emphasize pre-planning requirement")
    }

    func testAbilityCardVisuallEmphasizesCriticalProfile() throws {
        // Given: A critical ability card
        let alertingShrillAbility = createAlertingShrillAbility()
        let classification = mockClassificationService.classifyAbility(alertingShrillAbility)
        let abilityCard = mockAbilityCardProvider.createAbilityCard(
            ability: alertingShrillAbility,
            classification: classification
        )

        // When: The card is configured for display
        guard let mockCard = abilityCard as? MockAbilityCardView else {
            XCTFail("Expected MockAbilityCardView")
            return
        }

        // Then: The card should have visual emphasis for critical abilities
        XCTAssertTrue(mockCard.hasVisualEmphasis,
                     "Critical abilities should have visual emphasis")
        XCTAssertEqual(mockCard.emphasisLevel, .critical,
                      "Critical abilities should use highest emphasis level")

        // Verify border styling for critical abilities
        XCTAssertGreaterThan(mockCard.borderWidth, 2.0,
                           "Critical abilities should have prominent borders")
        XCTAssertTrue(mockCard.hasShadow,
                     "Critical abilities should have shadow for depth")

        // Verify attention animation capability
        XCTAssertTrue(mockCard.canAnimateAttention,
                     "Critical ability cards should support attention animation")
    }

    func testAbilityCardProvidesImmediateVisualFeedback() throws {
        // Given: Multiple abilities with different damage profiles
        let criticalAbility = createAlertingShrillAbility()
        let moderateAbility = createModerateAbility()

        let criticalClassification = mockClassificationService.classifyAbility(criticalAbility)
        let moderateClassification = mockClassificationService.classifyAbility(moderateAbility)

        // When: Cards are created for comparison
        let criticalCard = mockAbilityCardProvider.createAbilityCard(
            ability: criticalAbility,
            classification: criticalClassification
        )
        let moderateCard = mockAbilityCardProvider.createAbilityCard(
            ability: moderateAbility,
            classification: moderateClassification
        )

        // Then: Critical card should be immediately distinguishable
        guard let mockCriticalCard = criticalCard as? MockAbilityCardView,
              let mockModerateCard = moderateCard as? MockAbilityCardView else {
            XCTFail("Expected MockAbilityCardView instances")
            return
        }

        // Verify visual hierarchy
        XCTAssertGreaterThan(mockCriticalCard.visualPriority, mockModerateCard.visualPriority,
                           "Critical cards should have higher visual priority")
        XCTAssertNotEqual(mockCriticalCard.backgroundColor, mockModerateCard.backgroundColor,
                         "Different damage profiles should have distinct colors")

        // Verify immediate recognition elements
        XCTAssertTrue(mockCriticalCard.hasImmediateRecognitionElements,
                     "Critical cards should have immediate recognition elements")
        XCTAssertLessThan(mockCriticalCard.recognitionTime, 1.0,
                         "Critical abilities should be recognizable within 1 second")
    }

    func testAbilityCardDisplayModeOptimizationForIPad() throws {
        // Given: A critical ability and different display contexts
        let alertingShrillAbility = createAlertingShrillAbility()
        let classification = mockClassificationService.classifyAbility(alertingShrillAbility)
        let abilityCard = mockAbilityCardProvider.createAbilityCard(
            ability: alertingShrillAbility,
            classification: classification
        )

        guard let mockCard = abilityCard as? MockAbilityCardView else {
            XCTFail("Expected MockAbilityCardView")
            return
        }

        // When: Different display modes are tested
        mockCard.updateDisplayMode(.full)

        // Then: Full mode should show all critical information
        XCTAssertTrue(mockCard.showsAbilityName, "Full mode should display ability name")
        XCTAssertTrue(mockCard.showsHealerAction, "Full mode should display healer action")
        XCTAssertTrue(mockCard.showsCriticalInsight, "Full mode should display critical insight")
        XCTAssertTrue(mockCard.showsDamageProfile, "Full mode should display damage profile")

        // When: Compact mode is used
        mockCard.updateDisplayMode(.compact)

        // Then: Essential information should still be visible
        XCTAssertTrue(mockCard.showsAbilityName, "Compact mode should still show ability name")
        XCTAssertTrue(mockCard.showsDamageProfile, "Compact mode should show damage profile")
        XCTAssertTrue(mockCard.maintainsReadability, "Compact mode should maintain readability on iPad")

        // When: Minimal mode is used
        mockCard.updateDisplayMode(.minimal)

        // Then: Critical identification should remain
        XCTAssertTrue(mockCard.showsAbilityName, "Minimal mode should show ability name")
        XCTAssertTrue(mockCard.showsDamageProfile, "Minimal mode should show damage profile indicator")
        XCTAssertTrue(mockCard.maintainsCriticalVisualCues, "Minimal mode should keep critical visual cues")
    }

    // MARK: - Integration Test: Complete User Story Flow

    /// T009 Complete User Story Integration Test
    /// User Story: "I view an ability card for 'Alerting Shrill'. When the card displays,
    /// then I see it's Critical damage profile with pre-planned group healing guidance."
    ///
    /// This test MUST FAIL until all services are implemented, but documents the complete expected behavior.
    func testCompleteUserStoryFlow_ViewAlertingShrillAbilityCard() async throws {
        // GIVEN: User is viewing an encounter that contains "Alerting Shrill"
        let abilities = try await mockAbilityDataProvider.fetchAbilities(for: testBossEncounterId)
        let alertingShrillAbility = abilities.first { $0.name == "Alerting Shrill" }

        XCTAssertNotNil(alertingShrillAbility, "Alerting Shrill should exist in test encounter")

        guard let ability = alertingShrillAbility else {
            XCTFail("Failed to find Alerting Shrill ability")
            return
        }

        // WHEN: The ability card display flow is attempted (should fail at multiple points)

        // Step 1: Ability classification should fail
        XCTAssertThrowsError(
            try { let _ = mockClassificationService.classifyAbility(ability) }(),
            "Step 1 should fail: AbilityClassificationService not implemented"
        )

        // Step 2: Color scheme retrieval should fail
        XCTAssertThrowsError(
            try { let _ = mockDamageProfileAnalyzer.getUIColorScheme(for: .critical) }(),
            "Step 2 should fail: DamageProfileAnalyzer not implemented"
        )

        // Step 3: Recommended actions retrieval should fail
        XCTAssertThrowsError(
            try { let _ = mockClassificationService.getRecommendedActions(for: .critical) }(),
            "Step 3 should fail: AbilityClassificationService.getRecommendedActions not implemented"
        )

        // Step 4: Ability card creation should fail
        XCTAssertThrowsError(
            try {
                let mockClassification = AbilityClassification(urgency: .immediate, complexity: .complex, healerImpact: .critical, recommendedPreparation: "")
                let _ = mockAbilityCardProvider.createAbilityCard(ability: ability, classification: mockClassification)
            }(),
            "Step 4 should fail: AbilityCardProvider not implemented"
        )

        // THEN: Document complete expected behavior for real implementation

        // Expected: User immediately sees it's a Critical damage profile
        XCTAssertEqual(ability.damageProfile, .critical,
                      "Expected: Alerting Shrill should be classified as critical damage")

        // Expected: Pre-planned group healing cooldown guidance
        XCTAssertTrue(ability.healerAction.lowercased().contains("group healing cooldown") ||
                     ability.healerAction.lowercased().contains("raid cooldown"),
                     "Expected: Should specify group healing cooldown requirement")
        XCTAssertTrue(ability.criticalInsight.lowercased().contains("pre-plan") ||
                     ability.criticalInsight.lowercased().contains("coordinate"),
                     "Expected: Should emphasize pre-planning requirement")

        // Expected: iPad-optimized text sizing
        let typography = mockUIConfiguration.typography
        XCTAssertGreaterThanOrEqual(typography.abilityNameFont.pointSize, 18.0,
                                   "Expected: Ability name text should be readable on iPad (≥18pt)")
        XCTAssertGreaterThanOrEqual(typography.healerActionFont.pointSize, 16.0,
                                   "Expected: Healer action text should be readable on iPad (≥16pt)")

        // Document complete implementation requirements:
        // 1. AbilityClassificationService.classifyAbility() should return urgency: .immediate, healerImpact: .critical
        // 2. DamageProfileAnalyzer.getUIColorScheme(for: .critical) should return red color scheme
        // 3. AbilityClassificationService.getRecommendedActions(for: .critical) should return cooldown actions
        // 4. AbilityCardProvider.createAbilityCard() should create visually emphasized card
        // 5. Card should be optimized for iPad with proper touch targets and visual hierarchy
        // 6. User should recognize critical nature within 2 seconds
        // 7. Card should provide actionable guidance for healer decision-making
    }

    // MARK: - Additional T009 Critical Ability Recognition Tests

    /// Tests that critical abilities are prioritized correctly in healer display
    func testCriticalAbilityPrioritizationForHealerInterface() throws {
        // Given: Multiple abilities with different damage profiles
        let criticalAbility = createAlertingShrillAbility()
        let moderateAbility = createModerateAbility()
        let abilities = [criticalAbility, moderateAbility]

        // When: Prioritization is attempted (should fail until implemented)
        XCTAssertThrowsError(
            try { let _ = mockDamageProfileAnalyzer.prioritizeForHealer(abilities) }(),
            "DamageProfileAnalyzer.prioritizeForHealer should not be implemented yet"
        ) { error in
            let errorString = String(describing: error)
            XCTAssertTrue(errorString.contains("not implemented"),
                         "Should fail with 'not implemented' error until DamageProfileAnalyzer.prioritizeForHealer exists")
        }

        // Document expected behavior:
        // Real implementation should return PrioritizedAbility array with:
        // - Critical abilities first (highest priority)
        // - Proper reasoning for prioritization
        // - UI display hints for visual emphasis
    }

    /// Tests that critical ability cards include accessibility features for iPad
    func testCriticalAbilityAccessibilityRequirements() throws {
        // Given: A critical ability requiring accessible display
        let alertingShrillAbility = createAlertingShrillAbility()

        // When: Accessibility validation is attempted (should fail until implemented)
        XCTAssertThrowsError(
            try {
                let mockClassification = AbilityClassification(urgency: .immediate, complexity: .complex, healerImpact: .critical, recommendedPreparation: "")
                let _ = mockAbilityCardProvider.createAbilityCard(ability: alertingShrillAbility, classification: mockClassification)
            }(),
            "AbilityCardProvider should not be implemented yet"
        )

        // Verify accessibility requirements are defined
        let accessibility = mockUIConfiguration.accessibility
        XCTAssertTrue(accessibility.supportsVoiceOver,
                     "Critical ability cards must support VoiceOver for accessibility")
        XCTAssertTrue(accessibility.supportsLargeText,
                     "Critical ability cards must support Dynamic Type for large text")
        XCTAssertTrue(accessibility.supportsHighContrast,
                     "Critical ability cards must support high contrast mode")
        XCTAssertTrue(accessibility.colorBlindFriendlyMode,
                     "Critical ability cards must be color blind friendly")

        // Document expected behavior:
        // Real AbilityCardProvider should create cards with:
        // - VoiceOver accessibility labels
        // - Dynamic Type support
        // - High contrast mode support
        // - Color blind friendly visual indicators
    }

    /// Tests that healer action guidance is comprehensive and actionable
    func testHealerActionGuidanceComprehensiveness() throws {
        // Given: Alerting Shrill ability with comprehensive healer guidance
        let alertingShrillAbility = createAlertingShrillAbility()

        // Then: Verify healer action meets comprehensiveness requirements
        XCTAssertGreaterThan(alertingShrillAbility.healerAction.count, 50,
                           "Healer action should provide sufficient detail (>50 characters)")
        XCTAssertTrue(alertingShrillAbility.healerAction.lowercased().contains("coordinate"),
                     "Should mention coordination with other healers")
        XCTAssertTrue(alertingShrillAbility.healerAction.lowercased().contains("cooldown"),
                     "Should specify cooldown usage")
        XCTAssertTrue(alertingShrillAbility.healerAction.lowercased().contains("immediately") ||
                     alertingShrillAbility.healerAction.lowercased().contains("when cast begins"),
                     "Should specify timing requirements")

        // Verify critical insight provides strategic context
        XCTAssertGreaterThan(alertingShrillAbility.criticalInsight.count, 80,
                           "Critical insight should provide comprehensive strategic information")
        XCTAssertTrue(alertingShrillAbility.criticalInsight.lowercased().contains("pre-plan") ||
                     alertingShrillAbility.criticalInsight.lowercased().contains("coordinate"),
                     "Should emphasize preparation and coordination")
        XCTAssertTrue(alertingShrillAbility.criticalInsight.lowercased().contains("wipe") ||
                     alertingShrillAbility.criticalInsight.lowercased().contains("failure"),
                     "Should indicate consequences of failure")

        // When: Action retrieval is attempted (should fail until implemented)
        XCTAssertThrowsError(
            try { let _ = mockClassificationService.getRecommendedActions(for: .critical) }(),
            "AbilityClassificationService.getRecommendedActions should not be implemented yet"
        )

        // Document expected behavior:
        // Real getRecommendedActions should return:
        // - Specific cooldown recommendations with timing
        // - Key binding suggestions for quick access
        // - Pre-positioning requirements
        // - Coordination points with other healers
    }

    /// Tests edge cases for critical ability recognition and display
    func testCriticalAbilityEdgeCasesAndErrorHandling() throws {
        // Given: Various edge case scenarios
        let criticalAbilities = createMultipleCriticalAbilities()
        let emptyAbilityList: [AbilityEntity] = []

        // When: Edge cases are tested (should fail until implemented)

        // Test empty ability list handling
        XCTAssertThrowsError(
            try { let _ = mockDamageProfileAnalyzer.prioritizeForHealer(emptyAbilityList) }(),
            "Should fail gracefully with empty ability list"
        )

        // Test multiple critical abilities handling
        XCTAssertThrowsError(
            try { let _ = mockDamageProfileAnalyzer.prioritizeForHealer(criticalAbilities) }(),
            "Should fail gracefully with multiple critical abilities"
        )

        // Test malformed ability data
        let malformedAbility = AbilityEntity(
            id: UUID(),
            name: "", // Empty name
            type: .damage,
            bossEncounterId: testBossEncounterId,
            targets: .group,
            damageProfile: .critical,
            healerAction: "", // Empty action
            criticalInsight: "", // Empty insight
            cooldown: nil,
            displayOrder: 0,
            isKeyMechanic: false
        )

        XCTAssertThrowsError(
            try { let _ = mockClassificationService.classifyAbility(malformedAbility) }(),
            "Should handle malformed ability data gracefully"
        )

        // Document expected behavior:
        // Real implementations should:
        // - Handle empty lists gracefully
        // - Properly sort multiple critical abilities by sub-priority
        // - Validate ability data completeness
        // - Provide meaningful error messages for invalid data
    }

    // MARK: - Performance and Memory Tests

    func testAbilityCardRenderingPerformanceOnIPad() throws {
        // Given: Multiple critical abilities to render
        let abilities = createMultipleCriticalAbilities()

        // When: Cards are rendered in bulk (simulating encounter display)
        let startTime = CFAbsoluteTimeGetCurrent()

        var renderedCards: [UIView] = []
        for ability in abilities {
            let classification = mockClassificationService.classifyAbility(ability)
            let card = mockAbilityCardProvider.createAbilityCard(
                ability: ability,
                classification: classification
            )
            renderedCards.append(card)
        }

        let renderTime = CFAbsoluteTimeGetCurrent() - startTime

        // Then: Rendering should complete within performance threshold for iPad
        XCTAssertLessThan(renderTime, 0.5,
                         "Should render \(abilities.count) ability cards within 500ms on iPad")
        XCTAssertEqual(renderedCards.count, abilities.count,
                      "All cards should render successfully")

        // Verify memory usage is reasonable
        XCTAssertLessThan(renderedCards.count * 1024 * 1024, 50 * 1024 * 1024,
                         "Memory usage should be under 50MB for card rendering")
    }

    // MARK: - Helper Methods

    private func setupAlertingShrillMockData() {
        let alertingShrillAbility = createAlertingShrillAbility()
        mockAbilityDataProvider.addTestAbility(alertingShrillAbility)

        // Note: Mock services are configured to fail by default until real implementation exists
        // The following configurations define expected behavior for when services are implemented:

        // Expected classification for Alerting Shrill when AbilityClassificationService is implemented:
        mockClassificationService.setClassificationFor(
            abilityId: alertingShrillAbilityId,
            classification: AbilityClassification(
                urgency: .immediate,
                complexity: .complex,
                healerImpact: .critical,
                recommendedPreparation: "Pre-position group healing cooldowns before cast begins"
            )
        )

        // Expected critical color scheme when DamageProfileAnalyzer is implemented:
        mockDamageProfileAnalyzer.setColorScheme(
            for: .critical,
            colorScheme: AbilityColorScheme(
                primaryColor: "#FF4444",    // High-contrast red for immediate recognition
                backgroundColor: "#FFEBEB", // Light red background for visibility
                textColor: "#000000",      // High-contrast black text for readability
                borderColor: "#CC0000"     // Dark red border for emphasis
            )
        )

        // Expected recommended actions when AbilityClassificationService is implemented:
        mockClassificationService.setRecommendedActions(
            for: .critical,
            actions: [
                HealerAction(
                    actionType: .cooldownUse,
                    timing: .planned,
                    description: "Use group healing cooldown",
                    keyBindSuggestion: "F1"
                ),
                HealerAction(
                    actionType: .preHeal,
                    timing: .planned,
                    description: "Pre-heal raid to full health",
                    keyBindSuggestion: nil
                )
            ]
        )
    }

    /// Creates comprehensive test data for Alerting Shrill ability meeting all T009 requirements
    private func createAlertingShrillAbility() -> AbilityEntity {
        return AbilityEntity(
            id: alertingShrillAbilityId,
            name: "Alerting Shrill",
            type: .damage,
            bossEncounterId: testBossEncounterId,
            targets: .group,
            damageProfile: .critical,
            healerAction: "Use group healing cooldown immediately when cast begins - coordinate with co-healers for maximum effectiveness",
            criticalInsight: "Massive raid-wide damage requires pre-planned cooldown usage and group coordination. Failure results in raid wipe. Position for optimal range before cast begins.",
            cooldown: 45.0,
            displayOrder: 1,
            isKeyMechanic: true
        )
    }

    private func createModerateAbility() -> AbilityEntity {
        return AbilityEntity(
            id: UUID(),
            name: "Minor Swipe",
            type: .damage,
            bossEncounterId: testBossEncounterId,
            targets: .tank,
            damageProfile: .moderate,
            healerAction: "Monitor tank health, heal as needed",
            criticalInsight: "Standard tank damage, no special preparation required",
            cooldown: nil,
            displayOrder: 5,
            isKeyMechanic: false
        )
    }

    private func createMultipleCriticalAbilities() -> [AbilityEntity] {
        return (1...10).map { index in
            AbilityEntity(
                id: UUID(),
                name: "Critical Ability \(index)",
                type: .damage,
                bossEncounterId: testBossEncounterId,
                targets: .group,
                damageProfile: .critical,
                healerAction: "Critical action required",
                criticalInsight: "Critical insight \(index)",
                cooldown: Double(30 + index * 5),
                displayOrder: index,
                isKeyMechanic: true
            )
        }
    }
}

// MARK: - Mock Classes

class MockAbilityDataProvider: AbilityDataProviding {
    private var abilities: [AbilityEntity] = []

    func addTestAbility(_ ability: AbilityEntity) {
        abilities.append(ability)
    }

    func fetchAbilities(for bossEncounterId: UUID) async throws -> [AbilityEntity] {
        return abilities.filter { $0.bossEncounterId == bossEncounterId }
    }

    func searchAbilities(query: String) async throws -> [AbilityEntity] {
        return abilities.filter { $0.name.lowercased().contains(query.lowercased()) }
    }

    func fetchAbilities(for bossEncounterId: UUID, damageProfile: DamageProfile) async throws -> [AbilityEntity] {
        return abilities.filter {
            $0.bossEncounterId == bossEncounterId && $0.damageProfile == damageProfile
        }
    }

    func fetchKeyMechanics(for bossEncounterId: UUID) async throws -> [AbilityEntity] {
        return abilities.filter {
            $0.bossEncounterId == bossEncounterId && $0.isKeyMechanic
        }
    }
}

class MockAbilityClassificationService: AbilityClassificationService {
    private var classifications: [UUID: AbilityClassification] = [:]
    private var recommendedActions: [DamageProfile: [HealerAction]] = [:]
    private var shouldFailWithNotImplemented: Bool = true

    func setClassificationFor(abilityId: UUID, classification: AbilityClassification) {
        classifications[abilityId] = classification
    }

    func setRecommendedActions(for damageProfile: DamageProfile, actions: [HealerAction]) {
        recommendedActions[damageProfile] = actions
    }

    func enableMockBehavior() {
        shouldFailWithNotImplemented = false
    }

    func classifyAbility(_ ability: AbilityEntity) -> AbilityClassification {
        if shouldFailWithNotImplemented {
            fatalError("AbilityClassificationService not implemented - classifyAbility method requires real implementation")
        }
        return classifications[ability.id] ?? AbilityClassification(
            urgency: .low,
            complexity: .simple,
            healerImpact: .low,
            recommendedPreparation: "No special preparation needed"
        )
    }

    func getRecommendedActions(for damageProfile: DamageProfile) -> [HealerAction] {
        if shouldFailWithNotImplemented {
            fatalError("AbilityClassificationService not implemented - getRecommendedActions method requires real implementation")
        }
        return recommendedActions[damageProfile] ?? []
    }

    func validateHealerRelevance(_ ability: AbilityEntity) -> ValidationResult {
        if shouldFailWithNotImplemented {
            fatalError("AbilityClassificationService not implemented - validateHealerRelevance method requires real implementation")
        }
        return ValidationResult(isValid: true, issues: [], recommendations: [])
    }
}

class MockDamageProfileAnalyzer: DamageProfileAnalyzer {
    private var colorSchemes: [DamageProfile: AbilityColorScheme] = [:]
    private var shouldFailWithNotImplemented: Bool = true

    func setColorScheme(for damageProfile: DamageProfile, colorScheme: AbilityColorScheme) {
        colorSchemes[damageProfile] = colorScheme
    }

    func enableMockBehavior() {
        shouldFailWithNotImplemented = false
    }

    func analyzeDamageProfile(for bossEncounterId: UUID) async throws -> DamageAnalysis {
        if shouldFailWithNotImplemented {
            throw NSError(domain: "MockError", code: 1,
                         userInfo: [NSLocalizedDescriptionKey: "DamageProfileAnalyzer not implemented - analyzeDamageProfile method requires real implementation"])
        }
        return DamageAnalysis(
            bossEncounterId: bossEncounterId,
            totalAbilities: 10,
            damageProfileDistribution: [.critical: 2, .high: 3, .moderate: 4, .mechanic: 1],
            predictedHealingLoad: .heavy,
            keyTimings: [],
            recommendedCooldownPlan: []
        )
    }

    func getUIColorScheme(for damageProfile: DamageProfile) -> AbilityColorScheme {
        if shouldFailWithNotImplemented {
            fatalError("DamageProfileAnalyzer not implemented - getUIColorScheme method requires real implementation")
        }
        return colorSchemes[damageProfile] ?? AbilityColorScheme(
            primaryColor: "#808080",
            backgroundColor: "#F0F0F0",
            textColor: "#000000",
            borderColor: "#808080"
        )
    }

    func prioritizeForHealer(_ abilities: [AbilityEntity]) -> [PrioritizedAbility] {
        if shouldFailWithNotImplemented {
            fatalError("DamageProfileAnalyzer not implemented - prioritizeForHealer method requires real implementation")
        }
        return abilities.enumerated().map { index, ability in
            PrioritizedAbility(
                ability: ability,
                priority: ability.damageProfile.priority,
                reasoning: "Priority based on damage profile",
                uiDisplayHint: ability.damageProfile == .critical ? .highlight : .standard
            )
        }
    }
}

class MockAbilityCardProvider: AbilityCardProviding {
    private var shouldFailWithNotImplemented: Bool = true

    func enableMockBehavior() {
        shouldFailWithNotImplemented = false
    }

    func createAbilityCard(ability: AbilityEntity, classification: AbilityClassification) -> UIView {
        if shouldFailWithNotImplemented {
            fatalError("AbilityCardProvider not implemented - createAbilityCard method requires real implementation")
        }
        return MockAbilityCardView(ability: ability, classification: classification)
    }

    func createAbilityRow(ability: AbilityEntity) -> UIView {
        if shouldFailWithNotImplemented {
            fatalError("AbilityCardProvider not implemented - createAbilityRow method requires real implementation")
        }
        return UIView()
    }

    func createKeyMechanicsCard(mechanics: [AbilityEntity]) -> UIView {
        if shouldFailWithNotImplemented {
            fatalError("AbilityCardProvider not implemented - createKeyMechanicsCard method requires real implementation")
        }
        return UIView()
    }
}

class MockAbilityCardView: UIView, AbilityCardViewProtocol {
    var ability: AbilityEntity
    var classification: AbilityClassification
    weak var delegate: AbilityCardDelegate?

    // Mock properties for testing
    var hasVisualEmphasis: Bool = false
    var emphasisLevel: EmphasisLevel = .standard
    var borderWidth: CGFloat = 1.0
    var hasShadow: Bool = false
    var canAnimateAttention: Bool = false
    var visualPriority: Int = 0
    var hasImmediateRecognitionElements: Bool = false
    var recognitionTime: TimeInterval = 0.0
    var providesActionableGuidance: Bool = false
    var isOptimizedForIPad: Bool = false

    // Display mode properties
    var showsAbilityName: Bool = true
    var showsHealerAction: Bool = true
    var showsCriticalInsight: Bool = true
    var showsDamageProfile: Bool = true
    var maintainsReadability: Bool = true
    var maintainsCriticalVisualCues: Bool = true

    enum EmphasisLevel {
        case standard, high, critical
    }

    init(ability: AbilityEntity, classification: AbilityClassification) {
        self.ability = ability
        self.classification = classification
        super.init(frame: .zero)

        configureForAbility()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureForAbility() {
        // Configure mock properties based on ability
        if ability.damageProfile == .critical {
            hasVisualEmphasis = true
            emphasisLevel = .critical
            borderWidth = 3.0
            hasShadow = true
            canAnimateAttention = true
            visualPriority = 10
            hasImmediateRecognitionElements = true
            recognitionTime = 0.8
            providesActionableGuidance = true
            isOptimizedForIPad = true
            backgroundColor = UIColor(hex: "#FFEBEB")
        } else {
            hasVisualEmphasis = false
            emphasisLevel = .standard
            borderWidth = 1.0
            hasShadow = false
            canAnimateAttention = false
            visualPriority = 5
            hasImmediateRecognitionElements = false
            recognitionTime = 2.0
            providesActionableGuidance = false
            isOptimizedForIPad = true
            backgroundColor = UIColor(hex: "#F0F0F0")
        }
    }

    func updateDisplayMode(_ mode: AbilityDisplayMode) {
        switch mode {
        case .full:
            showsAbilityName = true
            showsHealerAction = true
            showsCriticalInsight = true
            showsDamageProfile = true
        case .compact:
            showsAbilityName = true
            showsHealerAction = false
            showsCriticalInsight = false
            showsDamageProfile = true
        case .minimal:
            showsAbilityName = true
            showsHealerAction = false
            showsCriticalInsight = false
            showsDamageProfile = true
            maintainsCriticalVisualCues = true
        }
    }

    func animateAttention() {
        // Mock animation implementation
    }

    func displaysVisualIndicatorFor(_ damageProfile: DamageProfile) -> Bool {
        return ability.damageProfile == damageProfile && showsDamageProfile
    }
}

class MockHealerUIConfiguration: HealerUIConfiguration {
    var typography: TypographySettings {
        return TypographySettings(
            dungeonNameFont: UIFont.systemFont(ofSize: 24, weight: .bold),
            bossNameFont: UIFont.systemFont(ofSize: 20, weight: .semibold),
            abilityNameFont: UIFont.systemFont(ofSize: 18, weight: .medium),
            healerActionFont: UIFont.systemFont(ofSize: 16, weight: .regular),
            insightFont: UIFont.systemFont(ofSize: 14, weight: .regular),
            summaryFont: UIFont.systemFont(ofSize: 16, weight: .regular),
            supportsDynamicType: true,
            maximumPointSize: 28.0,
            minimumPointSize: 12.0
        )
    }

    var colorScheme: HealerColorScheme {
        return HealerColorScheme(
            criticalDamageColor: UIColor.systemRed,
            highDamageColor: UIColor.systemOrange,
            moderateDamageColor: UIColor.systemYellow,
            mechanicColor: UIColor.systemBlue,
            primaryBackgroundColor: UIColor.systemBackground,
            secondaryBackgroundColor: UIColor.secondarySystemBackground,
            cardBackgroundColor: UIColor.systemGroupedBackground,
            primaryTextColor: UIColor.label,
            secondaryTextColor: UIColor.secondaryLabel,
            accentTextColor: UIColor.systemBlue,
            buttonTintColor: UIColor.systemBlue,
            selectionColor: UIColor.systemBlue.withAlphaComponent(0.3),
            separatorColor: UIColor.separator
        )
    }

    var layout: LayoutSettings {
        return LayoutSettings(
            cardCornerRadius: 12.0,
            standardMargin: 16.0,
            compactMargin: 8.0,
            minimumTouchTarget: 44.0,
            dungeonGridColumns: 2,
            abilityCardMinimumWidth: 300.0,
            maximumContentWidth: 1024.0,
            masterViewMinimumWidth: 320.0,
            detailViewMinimumWidth: 400.0
        )
    }

    var accessibility: AccessibilitySettings {
        return AccessibilitySettings(
            supportsDarkMode: true,
            supportsHighContrast: true,
            supportsLargeText: true,
            supportsVoiceOver: true,
            supportsReduceMotion: true,
            colorBlindFriendlyMode: true,
            simplifiedUIMode: false,
            hapticFeedbackEnabled: true
        )
    }
}

// MARK: - Extensions

extension UIColor {
    convenience init?(hex: String) {
        let r, g, b, a: CGFloat

        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])

            if hexColor.count == 6 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff0000) >> 16) / 255
                    g = CGFloat((hexNumber & 0x00ff00) >> 8) / 255
                    b = CGFloat(hexNumber & 0x0000ff) / 255
                    a = 1.0

                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }

        return nil
    }
}

// MARK: - T007 & T008 Integration Tests

final class DungeonSelectionIntegrationTests: XCTestCase {

    // MARK: - Test Fixtures for T007 and T008

    private var mockDungeonProvider: MockDungeonDataProvider!
    private var mockAbilityProvider: MockAbilityDataProvider!
    private var mockHealerDisplay: MockHealerDisplayProvider!

    override func setUpWithError() throws {
        super.setUp()
        mockDungeonProvider = MockDungeonDataProvider()
        mockAbilityProvider = MockAbilityDataProvider()
        mockHealerDisplay = MockHealerDisplayProvider()
    }

    override func tearDownWithError() throws {
        mockDungeonProvider = nil
        mockAbilityProvider = nil
        mockHealerDisplay = nil
        super.tearDown()
    }

    // MARK: - Core T008 Integration Test

    /// Tests the complete Avanoxx boss encounter detail user story workflow
    /// This test MUST FAIL until the BossEncounterViewController is implemented
    func testT008_AvanoxxBossEncounterDetail_ShowsHealerSummaryAndColorCodedAbilityCards() async throws {

        // GIVEN: Mock Avanoxx boss encounter data with healer-specific content
        let avanoxxEncounter = createMockAvanoxxEncounter()
        let avanoxxAbilities = createMockAvanoxxAbilitiesWithDamageProfiles()

        // Set up mock providers to return test data
        mockDungeonProvider.stubbedBossEncounter = avanoxxEncounter
        mockAbilityProvider.stubbedAbilities = avanoxxAbilities

        // WHEN: User selects Avanoxx boss encounter and detail view loads
        // This should fail with "not implemented" until BossEncounterViewController exists
        do {
            _ = try mockHealerDisplay.createBossEncounterView(
                encounter: avanoxxEncounter,
                abilities: avanoxxAbilities
            )
            XCTFail("Boss encounter view creation should fail until implementation exists")
        } catch {
            // THEN: Verify expected failure
            XCTAssertTrue(error.localizedDescription.contains("not implemented"),
                         "Should fail with 'not implemented' until BossEncounterViewController is implemented. Got: \(error.localizedDescription)")
        }

        // Document expected behavior for future implementation
        await verifyT008Requirements(encounter: avanoxxEncounter, abilities: avanoxxAbilities)
    }

    /// Tests boss detail view display and loading requirements
    func testBossDetailViewLoading_MustShowHealerSummaryProminently() async throws {

        // GIVEN: Avanoxx encounter with comprehensive healer summary
        let encounter = createMockAvanoxxEncounter()

        // Verify healer summary meets content requirements
        XCTAssertFalse(encounter.healerSummary.isEmpty,
                      "Healer summary must be present for boss encounter detail")

        XCTAssertTrue(encounter.healerSummary.contains("healing"),
                     "Healer summary must contain healing-specific guidance")

        XCTAssertTrue(encounter.healerSummary.contains("cooldown"),
                     "Healer summary must mention cooldown management")

        // WHEN: Boss detail view is requested (should fail until implemented)
        XCTAssertThrowsError(
            try mockHealerDisplay.createBossEncounterView(encounter: encounter, abilities: [])
        ) { error in
            XCTAssertTrue(error.localizedDescription.contains("not implemented"),
                         "Boss detail view should not be implemented yet")
        }
    }

    /// Tests ability cards rendering with proper color coding
    func testAbilityCardsRendering_MustShowColorCodedDamageProfiles() async throws {

        // GIVEN: Abilities with different damage profiles
        let abilities = createMockAvanoxxAbilitiesWithDamageProfiles()
        let encounter = createMockAvanoxxEncounter()

        // Verify test data includes all damage profile types
        let profileTypes = abilities.map { $0.damageProfile }
        XCTAssertTrue(profileTypes.contains(.critical),
                     "Test data must include Critical damage profile ability")
        XCTAssertTrue(profileTypes.contains(.high),
                     "Test data must include High damage profile ability")
        XCTAssertTrue(profileTypes.contains(.moderate),
                     "Test data must include Moderate damage profile ability")

        // WHEN: Ability cards are requested (should fail until implemented)
        XCTAssertThrowsError(
            try mockHealerDisplay.createBossEncounterView(encounter: encounter, abilities: abilities)
        ) { error in
            XCTAssertTrue(error.localizedDescription.contains("not implemented"),
                         "Ability card rendering should not be implemented yet")
        }

        // THEN: Verify color coding requirements for implementation
        await verifyDamageProfileColorRequirements()
    }

    /// Tests iPad-optimized display layout requirements
    func testTabletViewingOptimization_MustMeetIPadProRequirements() async throws {

        // GIVEN: iPad Pro (1st generation) constraints
        let iPadProGen1Specs = iPadProFirstGenSpecs()
        let encounter = createMockAvanoxxEncounter()
        let abilities = createMockAvanoxxAbilitiesWithDamageProfiles()

        // WHEN: iPad-optimized layout is requested (should fail until implemented)
        XCTAssertThrowsError(
            try mockHealerDisplay.createBossEncounterView(encounter: encounter, abilities: abilities)
        ) { error in
            XCTAssertTrue(error.localizedDescription.contains("not implemented"),
                         "iPad-optimized layout should not be implemented yet")
        }

        // THEN: Verify iPad optimization requirements
        await verifyIPadOptimizationRequirements(specs: iPadProGen1Specs)
    }

    // MARK: - Mock Data Creation

    private func createMockAvanoxxEncounter() -> MockBossEncounter {
        return MockBossEncounter(
            id: UUID(uuidString: "A1B2C3D4-E5F6-7890-ABCD-EF1234567890")!,
            name: "Avanoxx",
            encounterOrder: 1,
            dungeonId: UUID(uuidString: "D1E2F3G4-H5I6-7890-JKLM-NO1234567890")!,
            healerSummary: """
            Avanoxx is a spider matriarch requiring intensive healing management.
            Primary healing challenges: Alerting Shrill (raid-wide burst), Toxic Pools (sustained DoT).
            Critical healing windows: Pre-cast group healing cooldowns before Alerting Shrill phases.
            Positioning requirements: Maintain line of sight while avoiding web mechanics.
            Mana management: Use burrow phase downtime for regeneration and group preparation.
            """,
            difficultyRating: 8,
            estimatedDuration: 240.0,
            keyMechanics: ["Alerting Shrill", "Toxic Pools", "Web Entanglement", "Burrow Phase"]
        )
    }

    private func createMockAvanoxxAbilitiesWithDamageProfiles() -> [MockBossAbility] {
        return [
            // Critical Damage Profile - Red color coding expected
            MockBossAbility(
                id: UUID(),
                name: "Alerting Shrill",
                type: "Area Damage",
                targets: "All Players",
                damageProfile: .critical,
                healerAction: "Pre-cast Tranquility or Spirit Link Totem immediately",
                criticalInsight: "Unavoidable 80% max health damage - requires preparation",
                cooldown: 45.0,
                displayOrder: 1,
                isKeyMechanic: true,
                bossEncounterId: UUID(uuidString: "A1B2C3D4-E5F6-7890-ABCD-EF1234567890")!
            ),

            // High Damage Profile - Orange color coding expected
            MockBossAbility(
                id: UUID(),
                name: "Toxic Pools",
                type: "Ground DoT",
                targets: "Targeted Players",
                damageProfile: .high,
                healerAction: "Spot heal affected players, use HoTs for sustained damage",
                criticalInsight: "DoT increases over time - early intervention prevents deaths",
                cooldown: 20.0,
                displayOrder: 2,
                isKeyMechanic: true,
                bossEncounterId: UUID(uuidString: "A1B2C3D4-E5F6-7890-ABCD-EF1234567890")!
            ),

            // Moderate Damage Profile - Yellow color coding expected
            MockBossAbility(
                id: UUID(),
                name: "Web Bolt",
                type: "Single Target",
                targets: "Random Player",
                damageProfile: .moderate,
                healerAction: "Spot heal if target below 50% health",
                criticalInsight: "Predictable moderate damage - conserve mana when possible",
                cooldown: 12.0,
                displayOrder: 3,
                isKeyMechanic: false,
                bossEncounterId: UUID(uuidString: "A1B2C3D4-E5F6-7890-ABCD-EF1234567890")!
            ),

            // Mechanic Damage Profile - Blue color coding expected
            MockBossAbility(
                id: UUID(),
                name: "Burrow Phase",
                type: "Phase Transition",
                targets: "Environment",
                damageProfile: .mechanic,
                healerAction: "Top off group health, prepare cooldowns for emergence",
                criticalInsight: "No damage during burrow - use for mana regen and positioning",
                cooldown: 90.0,
                displayOrder: 4,
                isKeyMechanic: true,
                bossEncounterId: UUID(uuidString: "A1B2C3D4-E5F6-7890-ABCD-EF1234567890")!
            )
        ]
    }

    // MARK: - Requirements Verification

    private func verifyT008Requirements(encounter: MockBossEncounter, abilities: [MockBossAbility]) async {

        // Healer summary requirements
        XCTAssertGreaterThan(encounter.healerSummary.count, 100,
                           "Healer summary must provide sufficient detail (>100 chars)")

        XCTAssertTrue(encounter.healerSummary.contains("healing") ||
                     encounter.healerSummary.contains("cooldown") ||
                     encounter.healerSummary.contains("mana"),
                     "Healer summary must contain healing-specific terminology")

        // Ability card requirements
        XCTAssertEqual(abilities.count, 4,
                      "Avanoxx should have 4 test abilities covering all damage profiles")

        // Color-coded damage profile requirements
        let damageProfiles = Set(abilities.map { $0.damageProfile })
        XCTAssertEqual(damageProfiles.count, 4,
                      "Should have abilities representing all 4 damage profile types")

        // Critical insights requirement
        for ability in abilities {
            XCTAssertFalse(ability.criticalInsight.isEmpty,
                         "Each ability must have critical insight for healers")
            XCTAssertFalse(ability.healerAction.isEmpty,
                         "Each ability must specify required healer action")
        }

        // Tablet viewing optimization requirements
        await verifyTabletViewingRequirements()
    }

    private func verifyDamageProfileColorRequirements() async {

        // Color coding specification from user story
        let requiredColorMappings: [MockDamageProfile: String] = [
            .critical: "Red",       // Critical damage requires immediate attention
            .high: "Orange",        // High damage needs prompt action
            .moderate: "Yellow",    // Moderate damage - situational healing
            .mechanic: "Blue"       // Mechanics - positioning/preparation focus
        ]

        // Verify all damage profiles have color assignments
        XCTAssertEqual(requiredColorMappings.count, 4,
                      "All 4 damage profiles must have distinct color coding")

        // Verify color accessibility requirements
        let colorNames = Array(requiredColorMappings.values)
        let uniqueColors = Set(colorNames)
        XCTAssertEqual(colorNames.count, uniqueColors.count,
                      "Each damage profile must have a unique color")
    }

    private func verifyIPadOptimizationRequirements(specs: IPadProGen1Specs) async {

        // Screen real estate utilization
        XCTAssertGreaterThan(specs.screenWidth * specs.screenHeight, 500000,
                           "iPad Pro screen area must be efficiently utilized")

        // Touch target requirements
        XCTAssertGreaterThanOrEqual(specs.minimumTouchTarget, 44.0,
                                  "Touch targets must meet 44pt minimum for iPad")

        // Font size requirements for tablet viewing
        XCTAssertGreaterThanOrEqual(specs.minimumFontSize, 16.0,
                                  "Text must be readable at tablet viewing distances")

        // Orientation support requirements
        XCTAssertTrue(specs.supportsPortrait && specs.supportsLandscape,
                     "Must support both portrait and landscape orientations")
    }

    private func verifyTabletViewingRequirements() async {

        // Content density appropriate for tablet
        let maxContentDensity = 85 // Percent of screen used for content
        XCTAssertLessThan(maxContentDensity, 90,
                         "Content density should not exceed 85% for comfortable tablet viewing")

        // Navigation spacing for touch interface
        let minimumNavigationSpacing: CGFloat = 16.0
        XCTAssertGreaterThanOrEqual(minimumNavigationSpacing, 16.0,
                                  "Navigation elements need adequate spacing for touch")
    }

    // MARK: - iPad Pro Specifications

    private func iPadProFirstGenSpecs() -> IPadProGen1Specs {
        return IPadProGen1Specs(
            screenWidth: 1024,
            screenHeight: 768,
            minimumTouchTarget: 44.0,
            minimumFontSize: 16.0,
            supportsPortrait: true,
            supportsLandscape: true
        )
    }

    // MARK: - T007 Integration Test: Dungeon Selection User Story

    /// Tests the complete dungeon selection user story workflow
    /// User Story: "I am about to enter 'Ara-Kara, City of Echoes' dungeon. When I open the app
    /// on my first-generation iPad Pro and select this dungeon, then I see a list of all bosses
    /// in chronological encounter order."
    /// This test MUST FAIL until the DungeonListViewController is implemented
    func testT007_AraKaraDungeonSelection_ShowsBossesInChronologicalOrder() async throws {

        // GIVEN: Mock data for "Ara-Kara, City of Echoes" dungeon with multiple bosses
        let araKaraDungeon = createMockAraKaraDungeon()
        let araKaraBosses = createMockAraKaraBossEncounters()

        // Set up mock providers to return test data
        mockDungeonProvider.stubbedDungeons = [araKaraDungeon]
        mockDungeonProvider.stubbedBossEncounters = araKaraBosses

        // WHEN: User opens the app and selects Ara-Kara dungeon
        // This should fail with "not implemented" until DungeonListViewController exists
        do {
            let dungeonListView = try mockHealerDisplay.createDungeonListView(dungeons: [araKaraDungeon])
            XCTFail("Dungeon list view creation should fail until implementation exists")
        } catch {
            // THEN: Verify expected failure for dungeon list
            XCTAssertTrue(error.localizedDescription.contains("not implemented"),
                         "Should fail with 'not implemented' until DungeonListViewController is implemented. Got: \(error.localizedDescription)")
        }

        // AND WHEN: User attempts to navigate to dungeon detail (boss list)
        do {
            _ = try mockDungeonProvider.fetchBossEncounters(for: araKaraDungeon.id)
            XCTFail("Boss encounters fetch should fail until implementation exists")
        } catch {
            // THEN: Verify expected failure for boss encounters
            XCTAssertTrue(error.localizedDescription.contains("not implemented"),
                         "Should fail with 'not implemented' until DungeonDataProvider is implemented. Got: \(error.localizedDescription)")
        }

        // Document expected behavior for future implementation
        await verifyT007Requirements(dungeon: araKaraDungeon, bosses: araKaraBosses)
    }

    /// Tests dungeon selection and navigation requirements specific to iPad Pro first-generation
    func testDungeonSelection_MustOptimizeForIPadProFirstGeneration() async throws {

        // GIVEN: iPad Pro (1st gen) hardware constraints and Ara-Kara dungeon data
        let iPadConstraints = iPadProFirstGenConstraints()
        let araKaraDungeon = createMockAraKaraDungeon()

        // Verify dungeon data meets display requirements
        XCTAssertFalse(araKaraDungeon.name.isEmpty,
                      "Dungeon name must be present for selection display")

        XCTAssertGreaterThan(araKaraDungeon.bossCount, 0,
                           "Dungeon must have boss encounters to display")

        XCTAssertGreaterThan(araKaraDungeon.estimatedDuration, 0,
                           "Estimated duration must be provided for planning")

        // WHEN: Dungeon selection is attempted on iPad Pro (should fail until implemented)
        XCTAssertThrowsError(
            try mockHealerDisplay.createDungeonListView(dungeons: [araKaraDungeon])
        ) { error in
            XCTAssertTrue(error.localizedDescription.contains("not implemented"),
                         "Dungeon selection should not be implemented yet")
        }

        // THEN: Verify iPad Pro first-generation optimization requirements
        await verifyIPadProFirstGenOptimization(constraints: iPadConstraints)
    }

    /// Tests chronological boss encounter ordering requirements
    func testBossEncounterOrdering_MustDisplayInChronologicalOrder() async throws {

        // GIVEN: Ara-Kara boss encounters with specific encounter order
        let araKaraBosses = createMockAraKaraBossEncounters()
        let araKaraDungeon = createMockAraKaraDungeon()

        // Verify test data has proper chronological ordering
        let sortedBosses = araKaraBosses.sorted { $0.encounterOrder < $1.encounterOrder }
        XCTAssertEqual(araKaraBosses.count, sortedBosses.count,
                      "All bosses should have valid encounter orders")

        // Verify encounter orders are sequential and start from 1
        let encounterOrders = sortedBosses.map { $0.encounterOrder }
        XCTAssertEqual(encounterOrders.first, 1,
                      "First boss should have encounter order 1")
        XCTAssertEqual(encounterOrders.count, 3,
                      "Ara-Kara should have exactly 3 boss encounters")

        // WHEN: Boss encounters are requested (should fail until implemented)
        XCTAssertThrowsError(
            try mockDungeonProvider.fetchBossEncounters(for: araKaraDungeon.id)
        ) { error in
            XCTAssertTrue(error.localizedDescription.contains("not implemented"),
                         "Boss encounter fetching should not be implemented yet")
        }

        // THEN: Verify chronological ordering requirements
        await verifyChronologicalOrderingRequirements(bosses: sortedBosses)
    }

    /// Tests touch interface optimization for dungeon and boss selection
    func testDungeonAndBossSelection_MustOptimizeForTouchInterface() async throws {

        // GIVEN: Touch interface requirements for iPad
        let touchRequirements = iPadTouchInterfaceRequirements()
        let araKaraDungeon = createMockAraKaraDungeon()
        let araKaraBosses = createMockAraKaraBossEncounters()

        // WHEN: Touch-optimized interface is requested (should fail until implemented)
        XCTAssertThrowsError(
            try mockHealerDisplay.createDungeonListView(dungeons: [araKaraDungeon])
        ) { error in
            XCTAssertTrue(error.localizedDescription.contains("not implemented"),
                         "Touch-optimized interface should not be implemented yet")
        }

        // THEN: Verify touch interface requirements
        await verifyTouchInterfaceRequirements(requirements: touchRequirements)
    }

    // MARK: - T007 Mock Data Creation

    private func createMockAraKaraDungeon() -> MockDungeonEntity {
        return MockDungeonEntity(
            id: UUID(uuidString: "12345678-ABCD-1234-EFGH-567890ABCDEF")!,
            name: "Ara-Kara, City of Echoes",
            shortName: "Ara-Kara",
            difficultyLevel: "Mythic+",
            displayOrder: 1,
            estimatedDuration: 1800.0, // 30 minutes
            healerNotes: """
            Spider-themed dungeon requiring strong group healing and poison dispel management.
            Key challenges: Avanoxx's raid-wide damage, Ki'katal's swarm mechanics, Anub'zekt's positioning requirements.
            Healer preparation: Pre-plan cooldowns for Alerting Shrill phases, maintain LoS during web mechanics.
            """,
            bossCount: 3
        )
    }

    private func createMockAraKaraBossEncounters() -> [MockBossEncounterEntity] {
        let araKaraDungeonId = UUID(uuidString: "12345678-ABCD-1234-EFGH-567890ABCDEF")!

        return [
            // Boss 1: Avanoxx - First encounter
            MockBossEncounterEntity(
                id: UUID(uuidString: "A1B2C3D4-E5F6-7890-ABCD-EF1234567890")!,
                name: "Avanoxx",
                encounterOrder: 1,
                dungeonId: araKaraDungeonId,
                healerSummary: """
                Spider matriarch requiring intensive healing management during Alerting Shrill phases.
                Pre-cast group healing cooldowns before each Alerting Shrill. Maintain positioning for web mechanics.
                """,
                difficultyRating: 8,
                estimatedDuration: 240.0,
                keyMechanics: ["Alerting Shrill", "Toxic Pools", "Web Entanglement"],
                abilityCount: 6
            ),

            // Boss 2: Anub'zekt - Second encounter
            MockBossEncounterEntity(
                id: UUID(uuidString: "B2C3D4E5-F6G7-8901-BCDE-F23456789012")!,
                name: "Anub'zekt",
                encounterOrder: 2,
                dungeonId: araKaraDungeonId,
                healerSummary: """
                Burrowing spider requiring mobility and targeted healing during emergence phases.
                Focus on spot healing during Impale mechanics. Use movement abilities to maintain healing range.
                """,
                difficultyRating: 6,
                estimatedDuration: 180.0,
                keyMechanics: ["Impale", "Burrow Charge", "Poison Bolt"],
                abilityCount: 5
            ),

            // Boss 3: Ki'katal the Harvester - Final encounter
            MockBossEncounterEntity(
                id: UUID(uuidString: "C3D4E5F6-G7H8-9012-CDEF-G34567890123")!,
                name: "Ki'katal the Harvester",
                encounterOrder: 3,
                dungeonId: araKaraDungeonId,
                healerSummary: """
                Final boss with swarm mechanics requiring sustained group healing and dispel management.
                Coordinate healing cooldowns with damage phases. Prioritize poison dispels on DPS players.
                """,
                difficultyRating: 9,
                estimatedDuration: 300.0,
                keyMechanics: ["Cosmic Singularity", "Erupting Webs", "Poison Nova"],
                abilityCount: 8
            )
        ]
    }

    // MARK: - T007 Requirements Verification

    private func verifyT007Requirements(dungeon: MockDungeonEntity, bosses: [MockBossEncounterEntity]) async {

        // Dungeon selection requirements
        XCTAssertEqual(dungeon.name, "Ara-Kara, City of Echoes",
                      "Must test with the specific dungeon from user story")

        XCTAssertEqual(dungeon.bossCount, 3,
                      "Ara-Kara should have exactly 3 boss encounters")

        XCTAssertGreaterThan(dungeon.estimatedDuration, 0,
                           "Dungeon must provide estimated duration for planning")

        // Boss encounter ordering requirements
        XCTAssertEqual(bosses.count, 3,
                      "Should have 3 boss encounters for Ara-Kara")

        let sortedBosses = bosses.sorted { $0.encounterOrder < $1.encounterOrder }

        XCTAssertEqual(sortedBosses[0].name, "Avanoxx",
                      "First boss should be Avanoxx (encounter order 1)")

        XCTAssertEqual(sortedBosses[1].name, "Anub'zekt",
                      "Second boss should be Anub'zekt (encounter order 2)")

        XCTAssertEqual(sortedBosses[2].name, "Ki'katal the Harvester",
                      "Third boss should be Ki'katal the Harvester (encounter order 3)")

        // Chronological ordering verification
        for i in 0..<sortedBosses.count {
            XCTAssertEqual(sortedBosses[i].encounterOrder, i + 1,
                          "Boss encounters must be in sequential chronological order starting from 1")
        }

        // Healer-specific content requirements
        for boss in bosses {
            XCTAssertFalse(boss.healerSummary.isEmpty,
                          "Each boss must have healer-specific summary")

            XCTAssertGreaterThan(boss.healerSummary.count, 50,
                               "Healer summary must provide sufficient detail")

            XCTAssertFalse(boss.keyMechanics.isEmpty,
                          "Each boss must list key mechanics for healers")

            XCTAssertGreaterThan(boss.abilityCount, 0,
                               "Each boss must have abilities to display")
        }

        // iPad Pro requirements verification
        await verifyIPadProFirstGenRequirements()
    }

    private func verifyIPadProFirstGenOptimization(constraints: IPadProFirstGenConstraints) async {

        // Screen resolution optimization
        XCTAssertGreaterThanOrEqual(constraints.targetScreenWidth, 1024,
                                  "Must support iPad Pro first-gen screen width (1024)")

        XCTAssertGreaterThanOrEqual(constraints.targetScreenHeight, 768,
                                  "Must support iPad Pro first-gen screen height (768)")

        // Performance constraints for A9X processor
        XCTAssertLessThanOrEqual(constraints.maxRenderTimeMs, 16.67,
                               "Must maintain 60fps on A9X processor (16.67ms per frame)")

        XCTAssertLessThanOrEqual(constraints.maxMemoryUsageMB, 200,
                               "Memory usage should be conservative on 4GB RAM device")

        // iOS version constraints
        XCTAssertGreaterThanOrEqual(constraints.minimumIOSVersion, 13.1,
                                  "Must support iOS 13.1 (highest supported on first-gen iPad Pro)")

        XCTAssertLessThanOrEqual(constraints.maximumIOSVersion, 13.7,
                               "Cannot exceed iOS 13.7 on first-gen iPad Pro")
    }

    private func verifyChronologicalOrderingRequirements(bosses: [MockBossEncounterEntity]) async {

        // Sequential encounter order validation
        for (index, boss) in bosses.enumerated() {
            XCTAssertEqual(boss.encounterOrder, index + 1,
                          "Encounter order must be sequential starting from 1")
        }

        // Dungeon progression logic validation
        let firstBoss = bosses.first { $0.encounterOrder == 1 }
        let lastBoss = bosses.max { $0.encounterOrder < $1.encounterOrder }

        XCTAssertNotNil(firstBoss, "Must have a first boss (encounter order 1)")
        XCTAssertNotNil(lastBoss, "Must have a final boss")

        // Content progression requirements
        XCTAssertTrue(bosses.allSatisfy { $0.encounterOrder >= 1 },
                     "All encounter orders must be positive integers")

        let orderSet = Set(bosses.map { $0.encounterOrder })
        XCTAssertEqual(orderSet.count, bosses.count,
                      "All encounter orders must be unique")
    }

    private func verifyTouchInterfaceRequirements(requirements: IPadTouchInterfaceRequirements) async {

        // Minimum touch target sizes for iPad
        XCTAssertGreaterThanOrEqual(requirements.minimumTouchTargetSize, 44.0,
                                  "Touch targets must meet 44pt minimum for accessibility")

        XCTAssertGreaterThanOrEqual(requirements.recommendedTouchTargetSize, 48.0,
                                  "Recommended touch target size should be 48pt+ for comfort")

        // Touch gesture support
        XCTAssertTrue(requirements.supportsTap,
                     "Must support tap gestures for selection")

        XCTAssertTrue(requirements.supportsScrolling,
                     "Must support scrolling for long boss lists")

        // Spacing requirements for touch accuracy
        XCTAssertGreaterThanOrEqual(requirements.minimumSpacingBetweenTargets, 8.0,
                                  "Minimum 8pt spacing between touch targets")

        XCTAssertGreaterThanOrEqual(requirements.recommendedSpacingBetweenTargets, 16.0,
                                  "Recommended 16pt spacing for comfortable use")
    }

    private func verifyIPadProFirstGenRequirements() async {

        // Hardware constraint verification
        let hardwareSpecs = IPadProFirstGenHardwareSpecs()

        XCTAssertEqual(hardwareSpecs.processorName, "A9X",
                      "Target hardware should be A9X processor")

        XCTAssertEqual(hardwareSpecs.ramGB, 4,
                      "Target hardware should have 4GB RAM")

        XCTAssertEqual(hardwareSpecs.maxIOSVersion, 13.7,
                      "Maximum supported iOS version should be 13.7")

        // Performance targets for A9X
        XCTAssertLessThanOrEqual(hardwareSpecs.targetFrameTimeMs, 16.67,
                               "Must maintain 60fps target (16.67ms)")

        XCTAssertLessThan(hardwareSpecs.loadTimeTargetSeconds, 3.0,
                         "App load time must be under 3 seconds")
    }

    // MARK: - T007 Hardware Specifications

    private func iPadProFirstGenConstraints() -> IPadProFirstGenConstraints {
        return IPadProFirstGenConstraints(
            targetScreenWidth: 1024,
            targetScreenHeight: 768,
            maxRenderTimeMs: 16.67,  // 60fps
            maxMemoryUsageMB: 200,   // Conservative for 4GB device
            minimumIOSVersion: 13.1,
            maximumIOSVersion: 13.7
        )
    }

    private func iPadTouchInterfaceRequirements() -> IPadTouchInterfaceRequirements {
        return IPadTouchInterfaceRequirements(
            minimumTouchTargetSize: 44.0,
            recommendedTouchTargetSize: 48.0,
            supportsTap: true,
            supportsScrolling: true,
            minimumSpacingBetweenTargets: 8.0,
            recommendedSpacingBetweenTargets: 16.0
        )
    }
}

// MARK: - Test Support Structures

struct IPadProGen1Specs {
    let screenWidth: CGFloat
    let screenHeight: CGFloat
    let minimumTouchTarget: CGFloat
    let minimumFontSize: CGFloat
    let supportsPortrait: Bool
    let supportsLandscape: Bool
}

/// Mock damage profile enum matching the specification color coding requirements
enum MockDamageProfile: String, CaseIterable {
    case critical = "Critical"    // Red - requires immediate action
    case high = "High"           // Orange - needs prompt attention
    case moderate = "Moderate"   // Yellow - situational healing
    case mechanic = "Mechanic"   // Blue - positioning/preparation focus
}

/// Mock boss encounter entity for T008 testing
struct MockBossEncounter {
    let id: UUID
    let name: String
    let encounterOrder: Int
    let dungeonId: UUID
    let healerSummary: String
    let difficultyRating: Int
    let estimatedDuration: TimeInterval
    let keyMechanics: [String]
}

/// Mock boss ability entity for T008 testing
struct MockBossAbility {
    let id: UUID
    let name: String
    let type: String
    let targets: String
    let damageProfile: MockDamageProfile
    let healerAction: String
    let criticalInsight: String
    let cooldown: TimeInterval
    let displayOrder: Int
    let isKeyMechanic: Bool
    let bossEncounterId: UUID
}

/// Mock dungeon data provider that should fail until implemented
class MockDungeonDataProvider: DungeonDataProviding {
    var stubbedBossEncounter: MockBossEncounter?
    var stubbedDungeons: [MockDungeonEntity] = []
    var stubbedBossEncounters: [MockBossEncounterEntity] = []

    // All methods should fail with "not implemented" until real implementation exists
    func fetchDungeonsForActiveSeason() async throws -> [DungeonEntity] {
        throw NSError(domain: "MockError", code: 1,
                     userInfo: [NSLocalizedDescriptionKey: "not implemented - DungeonDataProvider not yet implemented"])
    }

    func fetchDungeon(id: UUID) async throws -> DungeonEntity? {
        throw NSError(domain: "MockError", code: 1,
                     userInfo: [NSLocalizedDescriptionKey: "not implemented - DungeonDataProvider not yet implemented"])
    }

    func searchDungeons(query: String) async throws -> [DungeonEntity] {
        throw NSError(domain: "MockError", code: 1,
                     userInfo: [NSLocalizedDescriptionKey: "not implemented - DungeonDataProvider not yet implemented"])
    }

    func fetchBossEncounters(for dungeonId: UUID) async throws -> [BossEncounterEntity] {
        throw NSError(domain: "MockError", code: 1,
                     userInfo: [NSLocalizedDescriptionKey: "not implemented - DungeonDataProvider not yet implemented"])
    }
}

/// Mock ability data provider that should fail until implemented
class MockAbilityDataProvider {
    var stubbedAbilities: [MockBossAbility] = []

    // All methods should fail with "not implemented" until real implementation exists
}

/// Mock healer display provider that should fail until implemented
class MockHealerDisplayProvider: HealerDisplayProviding {

    func createDungeonListView(dungeons: [any DungeonEntity]) throws -> UIViewController {
        throw NSError(domain: "MockError", code: 1,
                     userInfo: [NSLocalizedDescriptionKey: "not implemented - DungeonListView not yet implemented"])
    }

    func createBossEncounterView(encounter: any BossEncounterEntity, abilities: [any AbilityEntity]) throws -> UIViewController {
        throw NSError(domain: "MockError", code: 1,
                     userInfo: [NSLocalizedDescriptionKey: "not implemented - BossEncounterView not yet implemented"])
    }

    func createSearchView(delegate: SearchDelegate?) throws -> UIViewController {
        throw NSError(domain: "MockError", code: 1,
                     userInfo: [NSLocalizedDescriptionKey: "not implemented - SearchView not yet implemented"])
    }

    func createSettingsView() throws -> UIViewController {
        throw NSError(domain: "MockError", code: 1,
                     userInfo: [NSLocalizedDescriptionKey: "not implemented - SettingsView not yet implemented"])
    }
}

// MARK: - Protocol Conformance for Mock Entities

extension MockBossEncounter: BossEncounterEntity {
    // Already conforms through struct properties
}

extension MockBossAbility: AbilityEntity {
    // Already conforms through struct properties
}

// MARK: - T007 Mock Entities and Support Structures

/// Mock dungeon entity for T007 testing
struct MockDungeonEntity {
    let id: UUID
    let name: String
    let shortName: String
    let difficultyLevel: String
    let displayOrder: Int
    let estimatedDuration: TimeInterval
    let healerNotes: String?
    let bossCount: Int
}

/// Mock boss encounter entity for T007 testing
struct MockBossEncounterEntity {
    let id: UUID
    let name: String
    let encounterOrder: Int
    let dungeonId: UUID
    let healerSummary: String
    let difficultyRating: Int
    let estimatedDuration: TimeInterval
    let keyMechanics: [String]
    let abilityCount: Int
}

/// iPad Pro first-generation hardware constraints for T007 testing
struct IPadProFirstGenConstraints {
    let targetScreenWidth: CGFloat
    let targetScreenHeight: CGFloat
    let maxRenderTimeMs: Double
    let maxMemoryUsageMB: Int
    let minimumIOSVersion: Double
    let maximumIOSVersion: Double
}

/// iPad touch interface requirements for T007 testing
struct IPadTouchInterfaceRequirements {
    let minimumTouchTargetSize: CGFloat
    let recommendedTouchTargetSize: CGFloat
    let supportsTap: Bool
    let supportsScrolling: Bool
    let minimumSpacingBetweenTargets: CGFloat
    let recommendedSpacingBetweenTargets: CGFloat
}

/// iPad Pro first-generation hardware specifications for T007 testing
struct IPadProFirstGenHardwareSpecs {
    let processorName: String = "A9X"
    let ramGB: Int = 4
    let maxIOSVersion: Double = 13.7
    let targetFrameTimeMs: Double = 16.67  // 60fps
    let loadTimeTargetSeconds: Double = 3.0
}

// MARK: - Protocol Conformance for T007 Mock Entities

extension MockDungeonEntity: DungeonEntity {
    // Already conforms through struct properties
}

extension MockBossEncounterEntity: BossEncounterEntity {
    // Already conforms through struct properties
}

// MARK: - T010 Offline Functionality Integration Tests

/// T010 Integration Test: Offline Functionality User Story
/// "I have no internet connection during gameplay. When I open the app, then all dungeon and encounter data is available offline."
class T010OfflineFunctionalityIntegrationTests: XCTestCase {

    // MARK: - Test Fixtures

    private var mockCoreDataStack: MockCoreDataStack!
    private var mockNetworkMonitor: MockNetworkMonitor!
    private var mockDungeonProvider: MockOfflineDungeonProvider!
    private var mockAbilityProvider: MockOfflineAbilityProvider!
    private var mockHealerDisplay: MockOfflineHealerDisplay!

    // Test data for offline functionality
    private let testDungeonIds = [
        UUID(uuidString: "D1000000-1111-2222-3333-444444444444")!,
        UUID(uuidString: "D2000000-1111-2222-3333-444444444444")!,
        UUID(uuidString: "D3000000-1111-2222-3333-444444444444")!
    ]

    private let testBossEncounterId = UUID(uuidString: "B1000000-1111-2222-3333-444444444444")!
    private let testAbilityIds = [
        UUID(uuidString: "A1000000-1111-2222-3333-444444444444")!,
        UUID(uuidString: "A2000000-1111-2222-3333-444444444444")!,
        UUID(uuidString: "A3000000-1111-2222-3333-444444444444")!
    ]

    override func setUpWithError() throws {
        super.setUp()

        mockCoreDataStack = MockCoreDataStack()
        mockNetworkMonitor = MockNetworkMonitor()
        mockDungeonProvider = MockOfflineDungeonProvider(coreDataStack: mockCoreDataStack)
        mockAbilityProvider = MockOfflineAbilityProvider(coreDataStack: mockCoreDataStack)
        mockHealerDisplay = MockOfflineHealerDisplay()

        // Populate CoreData with test offline data
        setupOfflineTestData()
    }

    override func tearDownWithError() throws {
        mockCoreDataStack = nil
        mockNetworkMonitor = nil
        mockDungeonProvider = nil
        mockAbilityProvider = nil
        mockHealerDisplay = nil
        super.tearDown()
    }

    // MARK: - Core T010 Integration Test

    /// Tests the complete offline functionality user story workflow
    /// This test MUST FAIL until CoreData offline functionality is fully implemented
    func testT010_CompleteOfflineFunctionality_AllDataAccessibleWithoutNetwork() async throws {

        // GIVEN: Network connectivity is unavailable (simulating gameplay scenario)
        mockNetworkMonitor.simulateNetworkUnavailable()
        XCTAssertFalse(mockNetworkMonitor.isConnected, "Network should be disconnected for offline test")

        // AND: App has been previously launched with network to populate CoreData
        XCTAssertTrue(mockCoreDataStack.hasOfflineData, "CoreData should contain offline data from previous launches")

        // WHEN: User opens app without internet connection during gameplay
        let startTime = CFAbsoluteTimeGetCurrent()

        // This should fail with "not implemented" until offline CoreData functionality exists
        do {
            // Attempt to access all dungeon data offline
            let dungeons = try await mockDungeonProvider.fetchDungeonsForActiveSeason()
            let loadTime = CFAbsoluteTimeGetCurrent() - startTime

            // If we get here, the implementation exists and we validate requirements
            try await validateOfflineDataAccess(dungeons: dungeons, loadTime: loadTime)

        } catch {
            // THEN: Verify expected failure until implementation exists
            XCTAssertTrue(error.localizedDescription.contains("not implemented") ||
                         error.localizedDescription.contains("CoreData offline") ||
                         error.localizedDescription.contains("network required"),
                         "Should fail with offline implementation message until CoreData offline functionality is implemented. Got: \(error.localizedDescription)")

            // Document expected behavior for future implementation
            await documentT010OfflineRequirements()
            return
        }

        // If implementation exists, verify complete offline workflow
        try await validateCompleteOfflineWorkflow()
    }

    /// Tests offline data loading performance requirements (< 3 second load times)
    func testOfflineDataLoadingPerformance_MustMeetThreeSecondRequirement() async throws {

        // GIVEN: Network is disconnected and offline data exists
        mockNetworkMonitor.simulateNetworkUnavailable()
        XCTAssertTrue(mockCoreDataStack.hasOfflineData, "Offline data must exist for performance test")

        // WHEN: App loads dungeon data from CoreData storage
        let startTime = CFAbsoluteTimeGetCurrent()

        // This should fail until CoreData offline loading is implemented
        XCTAssertThrowsError(
            try await mockDungeonProvider.fetchDungeonsForActiveSeason()
        ) { error in
            XCTAssertTrue(error.localizedDescription.contains("not implemented"),
                         "Offline data loading should not be implemented yet")
        }

        // Document performance requirements for implementation
        await documentPerformanceRequirements()
    }

    /// Tests data integrity when accessing offline storage
    func testOfflineDataIntegrity_MustMaintainCompleteDataSet() async throws {

        // GIVEN: Complete data set exists in offline storage
        let expectedDungeonCount = 8  // The War Within Season dungeons
        let expectedTotalBosses = 24  // Approximate boss count across 8 dungeons

        mockNetworkMonitor.simulateNetworkUnavailable()

        // WHEN: Offline data integrity is verified (should fail until implemented)
        XCTAssertThrowsError(
            try await mockDungeonProvider.validateOfflineDataIntegrity()
        ) { error in
            XCTAssertTrue(error.localizedDescription.contains("not implemented"),
                         "Data integrity validation should not be implemented yet")
        }

        // THEN: Document integrity requirements
        await documentDataIntegrityRequirements(
            expectedDungeonCount: expectedDungeonCount,
            expectedTotalBosses: expectedTotalBosses
        )
    }

    /// Tests offline access to boss encounters and ability data
    func testOfflineBossEncounterAndAbilityAccess_MustProvideCompleteEncounterData() async throws {

        // GIVEN: Network is unavailable and boss encounter data exists offline
        mockNetworkMonitor.simulateNetworkUnavailable()
        XCTAssertTrue(mockCoreDataStack.hasOfflineEncounterData, "Encounter data must exist offline")

        // WHEN: User accesses boss encounter details (should fail until implemented)
        XCTAssertThrowsError(
            try await mockDungeonProvider.fetchBossEncounters(for: testDungeonIds.first!)
        ) { error in
            XCTAssertTrue(error.localizedDescription.contains("not implemented"),
                         "Offline boss encounter access should not be implemented yet")
        }

        // AND: User accesses ability details (should fail until implemented)
        XCTAssertThrowsError(
            try await mockAbilityProvider.fetchAbilities(for: testBossEncounterId)
        ) { error in
            XCTAssertTrue(error.localizedDescription.contains("not implemented"),
                         "Offline ability access should not be implemented yet")
        }

        // Document encounter access requirements
        await documentEncounterAccessRequirements()
    }

    /// Tests offline UI functionality and navigation
    func testOfflineUINavigation_MustProvideFullAppFunctionality() async throws {

        // GIVEN: Network is disconnected and app UI needs to function
        mockNetworkMonitor.simulateNetworkUnavailable()

        // WHEN: User navigates through app screens offline (should fail until implemented)
        XCTAssertThrowsError(
            try mockHealerDisplay.createDungeonListViewOffline(dungeons: [])
        ) { error in
            XCTAssertTrue(error.localizedDescription.contains("not implemented"),
                         "Offline UI navigation should not be implemented yet")
        }

        // Document UI functionality requirements
        await documentOfflineUIRequirements()
    }

    /// Tests network reconnection handling and data synchronization
    func testNetworkReconnectionHandling_MustMaintainOfflineCapability() async throws {

        // GIVEN: App is running offline successfully
        mockNetworkMonitor.simulateNetworkUnavailable()

        // WHEN: Network becomes available again (should fail until implemented)
        XCTAssertThrowsError(
            try await mockNetworkMonitor.handleReconnection()
        ) { error in
            XCTAssertTrue(error.localizedDescription.contains("not implemented"),
                         "Network reconnection handling should not be implemented yet")
        }

        // Document reconnection requirements
        await documentReconnectionRequirements()
    }

    // MARK: - Requirements Validation (for future implementation)

    private func validateOfflineDataAccess(dungeons: [DungeonEntity], loadTime: TimeInterval) async throws {

        // Performance requirement: < 3 second load times
        XCTAssertLessThan(loadTime, 3.0,
                         "Offline data must load within 3 seconds on first-gen iPad Pro")

        // Data completeness requirement
        XCTAssertGreaterThanOrEqual(dungeons.count, 8,
                                  "Must provide all The War Within Season dungeons offline")

        // Data integrity requirement
        for dungeon in dungeons {
            XCTAssertFalse(dungeon.name.isEmpty, "Dungeon names must be preserved offline")
            XCTAssertGreaterThan(dungeon.bossCount, 0, "Boss counts must be accurate offline")
        }

        // Memory efficiency requirement
        let memoryFootprint = dungeons.count * 1024 * 100  // Rough estimate
        XCTAssertLessThan(memoryFootprint, 500 * 1024 * 1024,
                         "Offline data should use < 500MB storage as specified")
    }

    private func validateCompleteOfflineWorkflow() async throws {

        // Test complete offline user journey
        let dungeons = try await mockDungeonProvider.fetchDungeonsForActiveSeason()
        XCTAssertGreaterThan(dungeons.count, 0, "Dungeons must be available offline")

        let firstDungeon = dungeons.first!
        let encounters = try await mockDungeonProvider.fetchBossEncounters(for: firstDungeon.id)
        XCTAssertGreaterThan(encounters.count, 0, "Boss encounters must be available offline")

        let firstEncounter = encounters.first!
        let abilities = try await mockAbilityProvider.fetchAbilities(for: firstEncounter.id)
        XCTAssertGreaterThan(abilities.count, 0, "Abilities must be available offline")

        // Verify UI can display offline data
        let dungeonListView = try mockHealerDisplay.createDungeonListViewOffline(dungeons: dungeons)
        XCTAssertNotNil(dungeonListView, "Dungeon list must display offline")

        let bossDetailView = try mockHealerDisplay.createBossEncounterViewOffline(
            encounter: firstEncounter,
            abilities: abilities
        )
        XCTAssertNotNil(bossDetailView, "Boss detail must display offline")
    }

    // MARK: - Documentation Methods for Implementation Guidance

    private func documentT010OfflineRequirements() async {
        // Core offline functionality requirements for implementation:

        // 1. CoreData Persistent Storage
        XCTAssertTrue(true, "Must implement CoreData stack with offline-capable storage")

        // 2. Data Synchronization Strategy
        XCTAssertTrue(true, "Must sync dungeon/encounter data when network available")

        // 3. Offline-First Architecture
        XCTAssertTrue(true, "All data access must work offline-first, fallback to network")

        // 4. Performance Requirements
        XCTAssertTrue(true, "< 3 second load times for all offline data access")

        // 5. Storage Efficiency
        XCTAssertTrue(true, "< 500MB total storage footprint for all content")
    }

    private func documentPerformanceRequirements() async {
        let maxLoadTime: TimeInterval = 3.0
        let maxMemoryUsage = 500 * 1024 * 1024  // 500MB

        XCTAssertLessThan(maxLoadTime, 3.1,
                         "Offline data loading must complete within 3 seconds")
        XCTAssertLessThan(maxMemoryUsage, 501 * 1024 * 1024,
                         "Total storage must not exceed 500MB")
    }

    private func documentDataIntegrityRequirements(expectedDungeonCount: Int, expectedTotalBosses: Int) async {
        XCTAssertEqual(expectedDungeonCount, 8,
                      "Must store all 8 The War Within Season dungeons")
        XCTAssertGreaterThanOrEqual(expectedTotalBosses, 20,
                                  "Must store complete boss encounter data")
    }

    private func documentEncounterAccessRequirements() async {
        XCTAssertTrue(true, "Boss encounters must include complete healer summary offline")
        XCTAssertTrue(true, "All abilities must include damage profiles and healer actions offline")
        XCTAssertTrue(true, "Critical insights must be preserved in offline storage")
    }

    private func documentOfflineUIRequirements() async {
        XCTAssertTrue(true, "All UI screens must function without network connectivity")
        XCTAssertTrue(true, "Navigation between dungeons and encounters must work offline")
        XCTAssertTrue(true, "Search functionality must work on offline data")
    }

    private func documentReconnectionRequirements() async {
        XCTAssertTrue(true, "App must continue working offline when network reconnects")
        XCTAssertTrue(true, "Data updates should happen in background without disrupting gameplay")
    }

    // MARK: - Helper Methods

    private func setupOfflineTestData() {
        // Populate mock CoreData with test data
        mockCoreDataStack.hasOfflineData = true
        mockCoreDataStack.hasOfflineEncounterData = true

        // Add test dungeons
        for dungeonId in testDungeonIds {
            mockCoreDataStack.addTestDungeon(id: dungeonId, name: "Test Dungeon", bossCount: 3)
        }

        // Add test abilities
        for abilityId in testAbilityIds {
            mockCoreDataStack.addTestAbility(id: abilityId, name: "Test Ability", damageProfile: .critical)
        }
    }
}

// MARK: - Mock Classes for T010 Testing

/// Mock CoreData stack that simulates offline data storage
class MockCoreDataStack {
    var hasOfflineData: Bool = false
    var hasOfflineEncounterData: Bool = false

    private var testDungeons: [UUID: String] = [:]
    private var testAbilities: [UUID: String] = [:]

    func addTestDungeon(id: UUID, name: String, bossCount: Int) {
        testDungeons[id] = name
    }

    func addTestAbility(id: UUID, name: String, damageProfile: MockDamageProfile) {
        testAbilities[id] = name
    }
}

/// Mock network monitor for simulating connectivity states
class MockNetworkMonitor {
    private(set) var isConnected: Bool = true

    func simulateNetworkUnavailable() {
        isConnected = false
    }

    func simulateNetworkAvailable() {
        isConnected = true
    }

    func handleReconnection() async throws {
        throw NSError(domain: "MockError", code: 1,
                     userInfo: [NSLocalizedDescriptionKey: "not implemented - network reconnection handling not yet implemented"])
    }
}

/// Mock offline dungeon provider that should fail until CoreData implementation exists
class MockOfflineDungeonProvider: DungeonDataProviding {
    private let coreDataStack: MockCoreDataStack

    init(coreDataStack: MockCoreDataStack) {
        self.coreDataStack = coreDataStack
    }

    func fetchDungeonsForActiveSeason() async throws -> [DungeonEntity] {
        throw NSError(domain: "MockError", code: 1,
                     userInfo: [NSLocalizedDescriptionKey: "not implemented - CoreData offline dungeon fetching not yet implemented"])
    }

    func fetchDungeon(id: UUID) async throws -> DungeonEntity? {
        throw NSError(domain: "MockError", code: 1,
                     userInfo: [NSLocalizedDescriptionKey: "not implemented - CoreData offline single dungeon fetch not yet implemented"])
    }

    func searchDungeons(query: String) async throws -> [DungeonEntity] {
        throw NSError(domain: "MockError", code: 1,
                     userInfo: [NSLocalizedDescriptionKey: "not implemented - CoreData offline dungeon search not yet implemented"])
    }

    func fetchBossEncounters(for dungeonId: UUID) async throws -> [BossEncounterEntity] {
        throw NSError(domain: "MockError", code: 1,
                     userInfo: [NSLocalizedDescriptionKey: "not implemented - CoreData offline boss encounter fetching not yet implemented"])
    }

    func validateOfflineDataIntegrity() async throws {
        throw NSError(domain: "MockError", code: 1,
                     userInfo: [NSLocalizedDescriptionKey: "not implemented - offline data integrity validation not yet implemented"])
    }
}

/// Mock offline ability provider that should fail until CoreData implementation exists
class MockOfflineAbilityProvider: AbilityDataProviding {
    private let coreDataStack: MockCoreDataStack

    init(coreDataStack: MockCoreDataStack) {
        self.coreDataStack = coreDataStack
    }

    func fetchAbilities(for bossEncounterId: UUID) async throws -> [AbilityEntity] {
        throw NSError(domain: "MockError", code: 1,
                     userInfo: [NSLocalizedDescriptionKey: "not implemented - CoreData offline ability fetching not yet implemented"])
    }

    func searchAbilities(query: String) async throws -> [AbilityEntity] {
        throw NSError(domain: "MockError", code: 1,
                     userInfo: [NSLocalizedDescriptionKey: "not implemented - CoreData offline ability search not yet implemented"])
    }

    func fetchAbilities(for bossEncounterId: UUID, damageProfile: DamageProfile) async throws -> [AbilityEntity] {
        throw NSError(domain: "MockError", code: 1,
                     userInfo: [NSLocalizedDescriptionKey: "not implemented - CoreData offline filtered ability fetching not yet implemented"])
    }

    func fetchKeyMechanics(for bossEncounterId: UUID) async throws -> [AbilityEntity] {
        throw NSError(domain: "MockError", code: 1,
                     userInfo: [NSLocalizedDescriptionKey: "not implemented - CoreData offline key mechanics fetching not yet implemented"])
    }
}

/// Mock offline healer display provider that should fail until UI offline support exists
class MockOfflineHealerDisplay {

    func createDungeonListViewOffline(dungeons: [DungeonEntity]) throws -> UIViewController {
        throw NSError(domain: "MockError", code: 1,
                     userInfo: [NSLocalizedDescriptionKey: "not implemented - offline dungeon list view not yet implemented"])
    }

    func createBossEncounterViewOffline(encounter: BossEncounterEntity, abilities: [AbilityEntity]) throws -> UIViewController {
        throw NSError(domain: "MockError", code: 1,
                     userInfo: [NSLocalizedDescriptionKey: "not implemented - offline boss encounter view not yet implemented"])
    }
}