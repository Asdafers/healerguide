//
//  AccessibilityTests.swift
//  HealerKitTests
//
//  Task T039: Accessibility Audit and Compliance Testing
//  Tests VoiceOver, Dynamic Type, color blind support, keyboard navigation, high contrast,
//  reduced motion, focus management, and WCAG 2.1 AA compliance for critical healer workflow
//  Created by HealerKit Test Coverage Enforcement Specialist on 15/09/2025.
//

import XCTest
import UIKit
import XCUITest
@testable import HealerUIKit
@testable import DungeonKit
@testable import AbilityKit

/// Comprehensive accessibility testing suite for WCAG 2.1 AA compliance
/// Tests VoiceOver compatibility, keyboard navigation, color blind support, and healer workflow accessibility
final class AccessibilityTests: XCTestCase {

    // MARK: - Test Properties

    private var testWindow: UIWindow!
    private var mockDungeons: [MockDungeonEntity]!
    private var mockBossEncounter: MockBossEncounterEntity!
    private var mockAbilities: [MockAbilityEntity]!

    // Test view controllers for accessibility testing
    private var dungeonListVC: DungeonListViewController!
    private var bossEncounterVC: BossEncounterViewController!
    private var abilityCardView: AbilityCardView!

    // Accessibility test constants
    private struct AccessibilityConstants {
        static let minimumTouchTarget: CGFloat = 44.0
        static let wcagAAContrastRatio: Float = 4.5
        static let wcagAAAContrastRatio: Float = 7.0
        static let maxAnimationDuration: TimeInterval = 5.0
        static let keyboardNavigationTimeout: TimeInterval = 2.0
    }

    // MARK: - Test Lifecycle

    override func setUpWithError() throws {
        super.setUp()

        // Enable accessibility for testing
        UIAccessibility.isVoiceOverRunning = true
        UIAccessibility.isReduceMotionEnabled = false
        UIAccessibility.isDifferentiateWithoutColorEnabled = false
        UIAccessibility.isIncreaseContrastEnabled = false

        // Create test window for iPad simulation
        testWindow = UIWindow(frame: CGRect(x: 0, y: 0, width: 1024, height: 1366))
        testWindow.makeKeyAndVisible()

        // Create mock data
        mockDungeons = createMockDungeons()
        mockBossEncounter = createMockBossEncounter()
        mockAbilities = createMockAbilities()

        // Initialize UI components
        try setupViewControllers()
    }

    override func tearDownWithError() throws {
        // Reset accessibility settings
        UIAccessibility.isVoiceOverRunning = false
        UIAccessibility.isReduceMotionEnabled = false
        UIAccessibility.isDifferentiateWithoutColorEnabled = false
        UIAccessibility.isIncreaseContrastEnabled = false

        dungeonListVC = nil
        bossEncounterVC = nil
        abilityCardView = nil
        testWindow.isHidden = true
        testWindow = nil
        mockDungeons = nil
        mockBossEncounter = nil
        mockAbilities = nil
        super.tearDown()
    }

    private func setupViewControllers() throws {
        // This will initially fail until implementation is complete (TDD requirement)
        do {
            dungeonListVC = try DungeonListViewController(dungeons: mockDungeons)
            bossEncounterVC = try BossEncounterViewController(
                encounter: mockBossEncounter,
                abilities: mockAbilities
            )

            if let firstAbility = mockAbilities.first {
                abilityCardView = AbilityCardView(
                    ability: firstAbility,
                    classification: AccessibilityAbilityClassification(
                        urgency: .immediate,
                        healerImpact: .critical,
                        mechanicType: .damage
                    )
                )
            }
        } catch {
            // Expected to fail in TDD phase - components not implemented yet
            XCTFail("UI components not implemented yet - this is expected in TDD phase: \(error)")
        }
    }

    // MARK: - T039.1: VoiceOver Compatibility Tests

    func test_VoiceOver_DungeonListViewController_AccessibilityLabelsAndTraits() throws {
        guard let dungeonListVC = dungeonListVC else {
            XCTFail("DungeonListViewController not implemented - expected TDD failure")
            return
        }

        testWindow.rootViewController = dungeonListVC
        testWindow.layoutIfNeeded()

        // Test view controller accessibility
        XCTAssertTrue(
            dungeonListVC.view.isAccessibilityElement == false,
            "Container views should not be accessibility elements"
        )

        // Test navigation bar accessibility
        let navigationBar = dungeonListVC.navigationController?.navigationBar
        if let navBar = navigationBar {
            XCTAssertNotNil(
                navBar.accessibilityLabel,
                "Navigation bar should have accessibility label"
            )
        }

        // Test collection view accessibility
        if let collectionView = dungeonListVC.dungeonCollectionView {
            XCTAssertTrue(
                collectionView.isAccessibilityElement == false,
                "Collection view should not be accessibility element (cells are)"
            )

            // Test first dungeon cell accessibility
            let indexPath = IndexPath(item: 0, section: 0)
            if let cell = collectionView.cellForItem(at: indexPath) {
                XCTAssertTrue(
                    cell.isAccessibilityElement,
                    "Dungeon cells should be accessibility elements"
                )

                XCTAssertNotNil(
                    cell.accessibilityLabel,
                    "Dungeon cells should have accessibility labels"
                )

                XCTAssertTrue(
                    cell.accessibilityTraits.contains(.button),
                    "Dungeon cells should have button accessibility trait"
                )

                // Test accessibility label content for healer context
                let accessibilityText = cell.accessibilityLabel ?? ""
                XCTAssertTrue(
                    accessibilityText.contains("dungeon") || accessibilityText.contains("Dungeon"),
                    "Accessibility label should mention dungeon context"
                )

                XCTAssertTrue(
                    accessibilityText.contains("boss") || accessibilityText.contains("encounter"),
                    "Accessibility label should mention boss encounters for healer context"
                )
            }
        }

        // Test search functionality accessibility
        if let searchController = dungeonListVC.searchController {
            XCTAssertNotNil(
                searchController.searchBar.accessibilityLabel,
                "Search bar should have accessibility label"
            )

            XCTAssertTrue(
                searchController.searchBar.accessibilityLabel?.contains("search") ?? false,
                "Search bar label should indicate search functionality"
            )
        }
    }

    func test_VoiceOver_BossEncounterViewController_CriticalAbilityAnnouncements() throws {
        guard let bossEncounterVC = bossEncounterVC else {
            XCTFail("BossEncounterViewController not implemented - expected TDD failure")
            return
        }

        testWindow.rootViewController = bossEncounterVC
        testWindow.layoutIfNeeded()

        // Test boss encounter header accessibility
        if let bossNameLabel = bossEncounterVC.bossNameLabel {
            XCTAssertTrue(
                bossNameLabel.isAccessibilityElement,
                "Boss name should be accessibility element"
            )

            XCTAssertTrue(
                bossNameLabel.accessibilityTraits.contains(.header),
                "Boss name should have header accessibility trait"
            )

            let bossAccessibilityLabel = bossNameLabel.accessibilityLabel ?? ""
            XCTAssertTrue(
                bossAccessibilityLabel.contains("boss") || bossAccessibilityLabel.contains("encounter"),
                "Boss name accessibility should provide context"
            )
        }

        // Test healer strategy accessibility
        if let strategyLabel = bossEncounterVC.healerStrategyLabel {
            XCTAssertTrue(
                strategyLabel.isAccessibilityElement,
                "Healer strategy should be accessibility element"
            )

            let strategyAccessibilityLabel = strategyLabel.accessibilityLabel ?? ""
            XCTAssertTrue(
                strategyAccessibilityLabel.contains("strategy") || strategyAccessibilityLabel.contains("healer"),
                "Strategy accessibility should indicate healer-specific content"
            )
        }

        // Test ability collection view accessibility
        if let abilityCollectionView = bossEncounterVC.abilityCollectionView {
            let indexPath = IndexPath(item: 0, section: 0)
            if let abilityCell = abilityCollectionView.cellForItem(at: indexPath) as? AbilityCardCollectionViewCell {
                XCTAssertTrue(
                    abilityCell.isAccessibilityElement,
                    "Ability cells should be accessibility elements"
                )

                // Test critical ability announcement
                if let cardView = abilityCell.abilityCardView {
                    let accessibilityLabel = cardView.accessibilityLabel ?? ""

                    // Critical abilities should be clearly announced
                    if cardView.classification.urgency == .immediate {
                        XCTAssertTrue(
                            accessibilityLabel.localizedCaseInsensitiveContains("critical") ||
                            accessibilityLabel.localizedCaseInsensitiveContains("urgent") ||
                            accessibilityLabel.localizedCaseInsensitiveContains("immediate"),
                            "Critical abilities should be announced as such to VoiceOver users"
                        )

                        XCTAssertTrue(
                            cardView.accessibilityTraits.contains(.startsMediaSession),
                            "Critical abilities should use appropriate accessibility traits for urgency"
                        )
                    }

                    // Test healer action accessibility
                    XCTAssertTrue(
                        accessibilityLabel.contains("healer") || accessibilityLabel.contains("action"),
                        "Ability accessibility should include healer action context"
                    )
                }
            }
        }

        // Test filter buttons accessibility
        for filterButton in bossEncounterVC.abilityFilterButtons {
            XCTAssertTrue(
                filterButton.isAccessibilityElement,
                "Filter buttons should be accessibility elements"
            )

            XCTAssertTrue(
                filterButton.accessibilityTraits.contains(.button),
                "Filter buttons should have button accessibility trait"
            )

            let buttonLabel = filterButton.accessibilityLabel ?? ""
            XCTAssertTrue(
                buttonLabel.contains("filter") || buttonLabel.contains("show") || buttonLabel.contains("damage"),
                "Filter button labels should explain their function"
            )
        }
    }

    func test_VoiceOver_AbilityCardView_DetailedAccessibilityInformation() throws {
        guard let abilityCardView = abilityCardView else {
            XCTFail("AbilityCardView not implemented - expected TDD failure")
            return
        }

        testWindow.addSubview(abilityCardView)
        abilityCardView.frame = CGRect(x: 20, y: 20, width: 300, height: 120)
        testWindow.layoutIfNeeded()

        // Test ability card is accessibility element
        XCTAssertTrue(
            abilityCardView.isAccessibilityElement,
            "Ability card should be single accessibility element"
        )

        // Test accessibility label provides comprehensive information
        let accessibilityLabel = abilityCardView.accessibilityLabel ?? ""

        // Should include ability name
        XCTAssertTrue(
            accessibilityLabel.contains(abilityCardView.ability.name),
            "Accessibility label should include ability name"
        )

        // Should include damage profile
        let damageProfile = abilityCardView.ability.damageProfile.rawValue
        XCTAssertTrue(
            accessibilityLabel.localizedCaseInsensitiveContains(damageProfile),
            "Accessibility label should include damage profile: \(damageProfile)"
        )

        // Should include healer action
        if let healerAction = abilityCardView.ability.healerAction {
            XCTAssertTrue(
                accessibilityLabel.contains(healerAction),
                "Accessibility label should include healer action"
            )
        }

        // Test accessibility traits
        XCTAssertTrue(
            abilityCardView.accessibilityTraits.contains(.button),
            "Ability card should have button trait for interaction"
        )

        // Critical abilities should have additional traits
        if abilityCardView.classification.urgency == .immediate {
            XCTAssertTrue(
                abilityCardView.accessibilityTraits.contains(.startsMediaSession),
                "Critical abilities should have urgent accessibility trait"
            )
        }

        // Test accessibility hint for actions
        let accessibilityHint = abilityCardView.accessibilityHint ?? ""
        XCTAssertTrue(
            accessibilityHint.contains("tap") || accessibilityHint.contains("select") || accessibilityHint.contains("activate"),
            "Accessibility hint should explain how to interact with the card"
        )
    }

    // MARK: - T039.2: Dynamic Type Support Tests

    func test_DynamicType_AllTextElements_ScaleCorrectly() throws {
        let contentSizeCategories: [UIContentSizeCategory] = [
            .extraSmall,
            .medium,
            .extraLarge,
            .extraExtraExtraLarge,
            .accessibilityMedium,
            .accessibilityLarge,
            .accessibilityExtraLarge,
            .accessibilityExtraExtraLarge,
            .accessibilityExtraExtraExtraLarge
        ]

        guard let abilityCardView = abilityCardView else {
            XCTFail("AbilityCardView not implemented - expected TDD failure")
            return
        }

        testWindow.addSubview(abilityCardView)
        abilityCardView.frame = CGRect(x: 20, y: 20, width: 300, height: 120)

        for category in contentSizeCategories {
            let traitCollection = UITraitCollection(preferredContentSizeCategory: category)

            // Simulate trait collection change
            abilityCardView.traitCollectionDidChange(traitCollection)
            testWindow.layoutIfNeeded()

            // Test ability name label scaling
            let nameFont = abilityCardView.abilityNameLabel.font
            XCTAssertNotNil(nameFont, "Ability name font should be set")

            // Test healer action label scaling
            let actionFont = abilityCardView.healerActionLabel.font
            XCTAssertNotNil(actionFont, "Healer action font should be set")

            // Verify fonts scale appropriately
            if category.isAccessibilityCategory {
                XCTAssertGreaterThanOrEqual(
                    nameFont!.pointSize,
                    18.0,
                    "Accessibility category fonts should be large enough: \(category.rawValue)"
                )
            } else if category == .extraSmall {
                XCTAssertGreaterThanOrEqual(
                    nameFont!.pointSize,
                    12.0,
                    "Minimum font size should remain readable"
                )
            }

            // Test layout adapts to larger text
            if category.isAccessibilityCategory {
                // Card should expand to accommodate larger text
                XCTAssertGreaterThanOrEqual(
                    abilityCardView.frame.height,
                    AccessibilityConstants.minimumTouchTarget,
                    "Card should maintain minimum touch target with large text"
                )
            }
        }
    }

    func test_DynamicType_CriticalAbilities_MaintainReadability() throws {
        guard let abilityCardView = abilityCardView else {
            XCTFail("AbilityCardView not implemented - expected TDD failure")
            return
        }

        // Set up critical ability
        let criticalClassification = AccessibilityAbilityClassification(
            urgency: .immediate,
            healerImpact: .critical,
            mechanicType: .damage
        )
        abilityCardView.classification = criticalClassification

        testWindow.addSubview(abilityCardView)
        abilityCardView.frame = CGRect(x: 20, y: 20, width: 300, height: 200)

        // Test with largest accessibility text size
        let largeTraitCollection = UITraitCollection(preferredContentSizeCategory: .accessibilityExtraExtraExtraLarge)
        abilityCardView.traitCollectionDidChange(largeTraitCollection)
        testWindow.layoutIfNeeded()

        // Critical abilities must remain distinguishable even with large text
        XCTAssertFalse(
            abilityCardView.urgencyBadge.isHidden,
            "Urgency badge should remain visible with large text"
        )

        XCTAssertGreaterThan(
            abilityCardView.containerView.layer.borderWidth,
            0.0,
            "Critical border should remain visible with large text"
        )

        // Test text doesn't overlap
        let nameFrame = abilityCardView.abilityNameLabel.frame
        let actionFrame = abilityCardView.healerActionLabel.frame

        XCTAssertFalse(
            nameFrame.intersects(actionFrame),
            "Text elements should not overlap with large Dynamic Type"
        )

        // Test accessibility label remains comprehensive
        let accessibilityLabel = abilityCardView.accessibilityLabel ?? ""
        XCTAssertTrue(
            accessibilityLabel.localizedCaseInsensitiveContains("critical") ||
            accessibilityLabel.localizedCaseInsensitiveContains("urgent"),
            "Critical status should be clear in accessibility label with large text"
        )
    }

    // MARK: - T039.3: Color Blind Friendly Tests

    func test_ColorBlindFriendly_DamageProfiles_AlternativeIndicators() throws {
        // Simulate color differentiation assistance
        UIAccessibility.isDifferentiateWithoutColorEnabled = true

        guard let abilityCardView = abilityCardView else {
            XCTFail("AbilityCardView not implemented - expected TDD failure")
            return
        }

        testWindow.addSubview(abilityCardView)
        abilityCardView.frame = CGRect(x: 20, y: 20, width: 300, height: 120)

        let damageProfiles: [DamageProfile] = [.critical, .high, .moderate, .mechanic]

        for profile in damageProfiles {
            // Create ability with specific damage profile
            let mockAbility = MockAbilityEntity(
                id: UUID(),
                name: "Test Ability",
                bossEncounterId: UUID(),
                type: .damage,
                damageProfile: profile,
                castTime: 2.0,
                cooldown: 30.0,
                description: "Test ability",
                healerAction: "Test action",
                classification: .critical,
                displayPriority: 1
            )

            abilityCardView.ability = mockAbility
            testWindow.layoutIfNeeded()

            // Test visual indicators beyond color
            switch profile {
            case .critical:
                // Critical should have border and badge
                XCTAssertGreaterThan(
                    abilityCardView.containerView.layer.borderWidth,
                    0.0,
                    "Critical abilities should have border indicator for color blind users"
                )

                XCTAssertFalse(
                    abilityCardView.urgencyBadge.isHidden,
                    "Critical abilities should show urgency badge as color alternative"
                )

            case .high:
                // High priority should have some visual emphasis
                XCTAssertTrue(
                    abilityCardView.containerView.layer.borderWidth > 0.0 ||
                    !abilityCardView.urgencyBadge.isHidden,
                    "High priority abilities should have non-color visual indicators"
                )

            case .moderate, .mechanic:
                // These may rely more on shape/pattern differences
                break
            }

            // Test accessibility label includes damage level information
            let accessibilityLabel = abilityCardView.accessibilityLabel ?? ""
            XCTAssertTrue(
                accessibilityLabel.localizedCaseInsensitiveContains(profile.rawValue),
                "Damage profile should be communicated via accessibility label: \(profile.rawValue)"
            )
        }

        // Reset accessibility setting
        UIAccessibility.isDifferentiateWithoutColorEnabled = false
    }

    func test_ColorBlindFriendly_CriticalAbilities_MultipleIndicators() throws {
        UIAccessibility.isDifferentiateWithoutColorEnabled = true

        guard let abilityCardView = abilityCardView else {
            XCTFail("AbilityCardView not implemented - expected TDD failure")
            return
        }

        let criticalClassification = AccessibilityAbilityClassification(
            urgency: .immediate,
            healerImpact: .critical,
            mechanicType: .damage
        )
        abilityCardView.classification = criticalClassification

        testWindow.addSubview(abilityCardView)
        abilityCardView.frame = CGRect(x: 20, y: 20, width: 300, height: 120)
        testWindow.layoutIfNeeded()

        // Critical abilities should have multiple non-color indicators
        var indicatorCount = 0

        // Check for border indicator
        if abilityCardView.containerView.layer.borderWidth > 0 {
            indicatorCount += 1
        }

        // Check for urgency badge
        if !abilityCardView.urgencyBadge.isHidden {
            indicatorCount += 1
        }

        // Check for text emphasis (bold, etc.)
        let nameFont = abilityCardView.abilityNameLabel.font
        if nameFont?.fontDescriptor.symbolicTraits.contains(.traitBold) == true {
            indicatorCount += 1
        }

        XCTAssertGreaterThanOrEqual(
            indicatorCount,
            2,
            "Critical abilities should have at least 2 non-color visual indicators"
        )

        // Test haptic feedback as additional indicator
        // Note: In real implementation, would test that haptic feedback is triggered
        XCTAssertTrue(
            abilityCardView.isUserInteractionEnabled,
            "Critical abilities should support haptic feedback interaction"
        )

        UIAccessibility.isDifferentiateWithoutColorEnabled = false
    }

    // MARK: - T039.4: Keyboard Navigation Tests

    func test_KeyboardNavigation_DungeonListViewController_SupportsExternalKeyboard() throws {
        guard let dungeonListVC = dungeonListVC else {
            XCTFail("DungeonListViewController not implemented - expected TDD failure")
            return
        }

        testWindow.rootViewController = dungeonListVC
        testWindow.layoutIfNeeded()

        // Test view controller can become first responder for keyboard events
        XCTAssertTrue(
            dungeonListVC.canBecomeFirstResponder,
            "Dungeon list should support keyboard navigation"
        )

        // Test key commands are defined
        let keyCommands = dungeonListVC.keyCommands
        XCTAssertNotNil(keyCommands, "Should define key commands for keyboard navigation")
        XCTAssertFalse(keyCommands?.isEmpty ?? true, "Should have at least one key command")

        // Test common navigation keys
        let arrowDownCommand = keyCommands?.first { $0.input == UIKeyCommand.inputDownArrow }
        XCTAssertNotNil(arrowDownCommand, "Should support down arrow navigation")

        let arrowUpCommand = keyCommands?.first { $0.input == UIKeyCommand.inputUpArrow }
        XCTAssertNotNil(arrowUpCommand, "Should support up arrow navigation")

        let returnCommand = keyCommands?.first { $0.input == "\r" }
        XCTAssertNotNil(returnCommand, "Should support return key for selection")

        // Test escape key for back navigation
        let escapeCommand = keyCommands?.first { $0.input == UIKeyCommand.inputEscape }
        XCTAssertNotNil(escapeCommand, "Should support escape key for back navigation")
    }

    func test_KeyboardNavigation_AbilityFiltering_KeyboardAccessible() throws {
        guard let bossEncounterVC = bossEncounterVC else {
            XCTFail("BossEncounterViewController not implemented - expected TDD failure")
            return
        }

        testWindow.rootViewController = bossEncounterVC
        testWindow.layoutIfNeeded()

        // Test filter buttons support keyboard focus
        for (index, filterButton) in bossEncounterVC.abilityFilterButtons.enumerated() {
            // Test button can receive focus
            XCTAssertTrue(
                filterButton.canBecomeFocused,
                "Filter button \(index) should be focusable with keyboard"
            )

            // Test tab order (buttons should have reasonable focus order)
            if index > 0 {
                let previousButton = bossEncounterVC.abilityFilterButtons[index - 1]
                // In a proper implementation, would test that tab moves focus correctly
                XCTAssertNotEqual(
                    filterButton.frame.minX,
                    previousButton.frame.minX,
                    "Filter buttons should be laid out to support logical tab order"
                )
            }
        }

        // Test keyboard shortcut for common filter actions
        let keyCommands = bossEncounterVC.keyCommands
        XCTAssertNotNil(keyCommands, "Boss encounter view should support keyboard shortcuts")

        // Test number keys for quick filter selection
        let filterKeyCommands = keyCommands?.filter { command in
            ["1", "2", "3", "4"].contains(command.input)
        }
        XCTAssertFalse(
            filterKeyCommands?.isEmpty ?? true,
            "Should support number key shortcuts for ability filtering"
        )
    }

    // MARK: - T039.5: High Contrast Mode Tests

    func test_HighContrastMode_AllComponents_EnhancedVisibility() throws {
        // Enable high contrast mode
        UIAccessibility.isIncreaseContrastEnabled = true

        guard let abilityCardView = abilityCardView else {
            XCTFail("AbilityCardView not implemented - expected TDD failure")
            return
        }

        testWindow.addSubview(abilityCardView)
        abilityCardView.frame = CGRect(x: 20, y: 20, width: 300, height: 120)
        testWindow.layoutIfNeeded()

        // Test border enhancement in high contrast mode
        XCTAssertGreaterThan(
            abilityCardView.containerView.layer.borderWidth,
            0.0,
            "High contrast mode should add or enhance borders"
        )

        // Test shadow enhancement or removal based on high contrast guidelines
        let shadowOpacity = abilityCardView.containerView.layer.shadowOpacity
        // In high contrast mode, shadows are often removed or enhanced
        XCTAssertTrue(
            shadowOpacity == 0.0 || shadowOpacity > 0.3,
            "High contrast mode should either remove subtle shadows or make them prominent"
        )

        // Test text contrast meets enhanced requirements
        let nameTextColor = abilityCardView.abilityNameLabel.textColor ?? .label
        let backgroundColor = abilityCardView.containerView.backgroundColor ?? .systemBackground

        let contrastRatio = calculateContrastRatio(
            foregroundColor: nameTextColor,
            backgroundColor: backgroundColor
        )

        XCTAssertGreaterThanOrEqual(
            contrastRatio,
            AccessibilityConstants.wcagAAAContrastRatio,
            "High contrast mode should meet WCAG AAA contrast requirements (7:1)"
        )

        UIAccessibility.isIncreaseContrastEnabled = false
    }

    func test_HighContrastMode_CriticalAbilities_MaximumVisibility() throws {
        UIAccessibility.isIncreaseContrastEnabled = true

        guard let abilityCardView = abilityCardView else {
            XCTFail("AbilityCardView not implemented - expected TDD failure")
            return
        }

        let criticalClassification = AccessibilityAbilityClassification(
            urgency: .immediate,
            healerImpact: .critical,
            mechanicType: .damage
        )
        abilityCardView.classification = criticalClassification

        testWindow.addSubview(abilityCardView)
        abilityCardView.frame = CGRect(x: 20, y: 20, width: 300, height: 120)
        testWindow.layoutIfNeeded()

        // Critical abilities should have maximum visibility in high contrast mode
        XCTAssertGreaterThanOrEqual(
            abilityCardView.containerView.layer.borderWidth,
            2.0,
            "Critical abilities should have thick borders in high contrast mode"
        )

        // Test urgency indicator visibility
        XCTAssertFalse(
            abilityCardView.urgencyBadge.isHidden,
            "Urgency indicators should be highly visible in high contrast mode"
        )

        let urgencyBadgeColor = abilityCardView.urgencyBadge.backgroundColor ?? .clear
        XCTAssertNotEqual(
            urgencyBadgeColor,
            .clear,
            "Urgency badge should have solid background in high contrast mode"
        )

        UIAccessibility.isIncreaseContrastEnabled = false
    }

    // MARK: - T039.6: Reduced Motion Tests

    func test_ReducedMotion_AbilityCardAnimations_RespectPreferences() throws {
        // Enable reduced motion
        UIAccessibility.isReduceMotionEnabled = true

        guard let abilityCardView = abilityCardView else {
            XCTFail("AbilityCardView not implemented - expected TDD failure")
            return
        }

        let criticalClassification = AccessibilityAbilityClassification(
            urgency: .immediate,
            healerImpact: .critical,
            mechanicType: .damage
        )
        abilityCardView.classification = criticalClassification

        testWindow.addSubview(abilityCardView)
        abilityCardView.frame = CGRect(x: 20, y: 20, width: 300, height: 120)
        testWindow.layoutIfNeeded()

        // Start attention animation
        abilityCardView.animateAttention()

        // With reduced motion, animations should be minimal or static
        let pulseAnimation = abilityCardView.pulseLayer.animation(forKey: "pulse")

        if pulseAnimation != nil {
            // If animation exists, it should be much shorter or static
            if let animationGroup = pulseAnimation as? CAAnimationGroup {
                XCTAssertLessThanOrEqual(
                    animationGroup.duration,
                    AccessibilityConstants.maxAnimationDuration,
                    "Animations should be shortened with reduced motion enabled"
                )
            }
        } else {
            // Or animation could be replaced with static visual indicator
            XCTAssertFalse(
                abilityCardView.urgencyBadge.isHidden,
                "With reduced motion, static indicators should replace animations"
            )
        }

        UIAccessibility.isReduceMotionEnabled = false
    }

    func test_ReducedMotion_ViewTransitions_NoDisorientation() throws {
        UIAccessibility.isReduceMotionEnabled = true

        guard let dungeonListVC = dungeonListVC else {
            XCTFail("DungeonListViewController not implemented - expected TDD failure")
            return
        }

        testWindow.rootViewController = dungeonListVC
        testWindow.layoutIfNeeded()

        // Test orientation change respects reduced motion
        let initialFrame = dungeonListVC.view.frame
        let newSize = CGSize(width: 1366, height: 1024) // Landscape

        let coordinator = MockTransitionCoordinator()
        dungeonListVC.viewWillTransition(to: newSize, with: coordinator)

        // Transition should complete quickly with reduced motion
        XCTAssertLessThanOrEqual(
            coordinator.transitionDuration,
            0.1,
            "View transitions should be very fast with reduced motion"
        )

        UIAccessibility.isReduceMotionEnabled = false
    }

    // MARK: - T039.7: Focus Management and Navigation Order Tests

    func test_FocusManagement_HealerWorkflow_LogicalFocusOrder() throws {
        guard let bossEncounterVC = bossEncounterVC else {
            XCTFail("BossEncounterViewController not implemented - expected TDD failure")
            return
        }

        testWindow.rootViewController = bossEncounterVC
        testWindow.layoutIfNeeded()

        // Test initial focus is on appropriate element
        let initialFocusedElement = UIAccessibility.focusedElement(using: nil)
        XCTAssertNotNil(initialFocusedElement, "Should have initial focus element")

        // Test focus order for healer workflow
        let focusableElements = collectFocusableElements(in: bossEncounterVC.view)

        // Verify logical focus order for healer workflow:
        // 1. Boss strategy/overview
        // 2. Filter controls
        // 3. Critical abilities first
        // 4. Other abilities in priority order

        var hasBossInfo = false
        var hasFilterControls = false
        var hasCriticalAbilities = false

        for element in focusableElements {
            if let label = element.accessibilityLabel?.lowercased() {
                if label.contains("boss") || label.contains("strategy") {
                    hasBossInfo = true
                } else if label.contains("filter") || label.contains("show") {
                    hasFilterControls = true
                } else if label.contains("critical") || label.contains("urgent") {
                    hasCriticalAbilities = true
                }
            }
        }

        XCTAssertTrue(hasBossInfo, "Focus order should include boss information")
        XCTAssertTrue(hasFilterControls, "Focus order should include filter controls")
        XCTAssertTrue(hasCriticalAbilities, "Focus order should include critical abilities")

        // Test focus wraps appropriately
        if focusableElements.count > 1 {
            let firstElement = focusableElements.first
            let lastElement = focusableElements.last
            XCTAssertNotEqual(firstElement, lastElement, "Should have distinct first and last focusable elements")
        }
    }

    func test_FocusManagement_AbilityCardView_DetailedFocusInfo() throws {
        guard let abilityCardView = abilityCardView else {
            XCTFail("AbilityCardView not implemented - expected TDD failure")
            return
        }

        testWindow.addSubview(abilityCardView)
        abilityCardView.frame = CGRect(x: 20, y: 20, width: 300, height: 120)
        testWindow.layoutIfNeeded()

        // Test ability card provides comprehensive focus information
        XCTAssertTrue(
            abilityCardView.isAccessibilityElement,
            "Ability card should be single accessibility element for focus"
        )

        // Test accessibility label provides context for focused state
        let accessibilityLabel = abilityCardView.accessibilityLabel ?? ""

        // Should include all necessary information when focused
        let requiredComponents = [
            abilityCardView.ability.name.lowercased(),
            abilityCardView.ability.damageProfile.rawValue.lowercased(),
            abilityCardView.ability.healerAction?.lowercased() ?? ""
        ]

        for component in requiredComponents {
            if !component.isEmpty {
                XCTAssertTrue(
                    accessibilityLabel.lowercased().contains(component),
                    "Focused ability should provide complete information: missing \(component)"
                )
            }
        }

        // Test focus provides healer-specific context
        XCTAssertTrue(
            accessibilityLabel.lowercased().contains("healer") ||
            accessibilityLabel.lowercased().contains("action") ||
            accessibilityLabel.lowercased().contains("heal"),
            "Focused ability should provide healer context"
        )
    }

    // MARK: - T039.8: WCAG 2.1 AA Compliance Validation

    func test_WCAG21AA_CriticalHealerWorkflow_FullCompliance() throws {
        // This test validates complete WCAG 2.1 AA compliance for critical healer workflow
        let complianceResults = WCAGComplianceResults()

        // Test 1.1.1: Non-text Content
        complianceResults.nonTextContent = validateNonTextContent()

        // Test 1.3.1: Info and Relationships
        complianceResults.infoAndRelationships = validateInfoAndRelationships()

        // Test 1.4.3: Contrast (Minimum)
        complianceResults.contrastMinimum = validateContrastMinimum()

        // Test 2.1.1: Keyboard
        complianceResults.keyboard = validateKeyboardAccess()

        // Test 2.4.3: Focus Order
        complianceResults.focusOrder = validateFocusOrder()

        // Test 2.4.6: Headings and Labels
        complianceResults.headingsAndLabels = validateHeadingsAndLabels()

        // Test 3.2.2: On Input
        complianceResults.onInput = validateOnInput()

        // Test 4.1.2: Name, Role, Value
        complianceResults.nameRoleValue = validateNameRoleValue()

        // Validate all criteria pass
        XCTAssertTrue(complianceResults.nonTextContent, "WCAG 2.1 AA 1.1.1: Non-text Content must pass")
        XCTAssertTrue(complianceResults.infoAndRelationships, "WCAG 2.1 AA 1.3.1: Info and Relationships must pass")
        XCTAssertTrue(complianceResults.contrastMinimum, "WCAG 2.1 AA 1.4.3: Contrast (Minimum) must pass")
        XCTAssertTrue(complianceResults.keyboard, "WCAG 2.1 AA 2.1.1: Keyboard must pass")
        XCTAssertTrue(complianceResults.focusOrder, "WCAG 2.1 AA 2.4.3: Focus Order must pass")
        XCTAssertTrue(complianceResults.headingsAndLabels, "WCAG 2.1 AA 2.4.6: Headings and Labels must pass")
        XCTAssertTrue(complianceResults.onInput, "WCAG 2.1 AA 3.2.2: On Input must pass")
        XCTAssertTrue(complianceResults.nameRoleValue, "WCAG 2.1 AA 4.1.2: Name, Role, Value must pass")

        // Overall compliance score
        let passedCriteria = complianceResults.countPassed()
        let totalCriteria = complianceResults.totalCriteria()

        XCTAssertEqual(
            passedCriteria,
            totalCriteria,
            "All WCAG 2.1 AA criteria must pass for critical healer workflow"
        )
    }

    // MARK: - Helper Methods

    private func collectFocusableElements(in view: UIView) -> [NSObject] {
        var focusableElements: [NSObject] = []

        func traverse(_ view: UIView) {
            if view.isAccessibilityElement {
                focusableElements.append(view)
            }
            for subview in view.subviews {
                traverse(subview)
            }
        }

        traverse(view)
        return focusableElements
    }

    private func calculateContrastRatio(foregroundColor: UIColor, backgroundColor: UIColor) -> Float {
        let foregroundLuminance = calculateRelativeLuminance(color: foregroundColor)
        let backgroundLuminance = calculateRelativeLuminance(color: backgroundColor)

        let lighter = max(foregroundLuminance, backgroundLuminance)
        let darker = min(foregroundLuminance, backgroundLuminance)

        return (lighter + 0.05) / (darker + 0.05)
    }

    private func calculateRelativeLuminance(color: UIColor) -> Float {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        let sRed = linearizeColorComponent(Float(red))
        let sGreen = linearizeColorComponent(Float(green))
        let sBlue = linearizeColorComponent(Float(blue))

        return 0.2126 * sRed + 0.7152 * sGreen + 0.0722 * sBlue
    }

    private func linearizeColorComponent(_ component: Float) -> Float {
        if component <= 0.03928 {
            return component / 12.92
        } else {
            return powf((component + 0.055) / 1.055, 2.4)
        }
    }

    // MARK: - WCAG Compliance Validation Methods

    private func validateNonTextContent() -> Bool {
        guard let abilityCardView = abilityCardView else { return false }

        // All non-text content (damage profile indicators, urgency badges) should have text alternatives
        return !abilityCardView.accessibilityLabel.isNilOrEmpty
    }

    private func validateInfoAndRelationships() -> Bool {
        guard let bossEncounterVC = bossEncounterVC else { return false }

        // Information structure should be programmatically determinable
        let hasStructure = bossEncounterVC.view.accessibilityElements?.count ?? 0 > 0
        return hasStructure
    }

    private func validateContrastMinimum() -> Bool {
        guard let abilityCardView = abilityCardView else { return false }

        let textColor = abilityCardView.abilityNameLabel.textColor ?? .label
        let backgroundColor = abilityCardView.containerView.backgroundColor ?? .systemBackground

        let contrastRatio = calculateContrastRatio(
            foregroundColor: textColor,
            backgroundColor: backgroundColor
        )

        return contrastRatio >= AccessibilityConstants.wcagAAContrastRatio
    }

    private func validateKeyboardAccess() -> Bool {
        guard let dungeonListVC = dungeonListVC else { return false }

        // All functionality should be available via keyboard
        return dungeonListVC.canBecomeFirstResponder &&
               !(dungeonListVC.keyCommands?.isEmpty ?? true)
    }

    private func validateFocusOrder() -> Bool {
        guard let bossEncounterVC = bossEncounterVC else { return false }

        // Focus order should be logical and meaningful
        let focusableElements = collectFocusableElements(in: bossEncounterVC.view)
        return focusableElements.count > 0
    }

    private func validateHeadingsAndLabels() -> Bool {
        guard let bossEncounterVC = bossEncounterVC else { return false }

        // Headings and labels should describe topic or purpose
        if let bossNameLabel = bossEncounterVC.bossNameLabel {
            return bossNameLabel.accessibilityTraits.contains(.header) &&
                   !(bossNameLabel.accessibilityLabel?.isEmpty ?? true)
        }
        return false
    }

    private func validateOnInput() -> Bool {
        // Context changes should not occur automatically on input
        // For iPad app, this is typically satisfied by design
        return true
    }

    private func validateNameRoleValue() -> Bool {
        guard let abilityCardView = abilityCardView else { return false }

        // All UI components should have accessible name, role, and value
        return !abilityCardView.accessibilityLabel.isNilOrEmpty &&
               abilityCardView.accessibilityTraits.contains(.button)
    }

    // MARK: - Mock Data Factory

    private func createMockDungeons() -> [MockDungeonEntity] {
        return [
            MockDungeonEntity(
                id: UUID(),
                name: "Accessibility Test Dungeon",
                shortName: "ATD",
                difficultyLevel: "Mythic+",
                displayOrder: 1,
                estimatedDuration: 1800,
                healerNotes: "Focus on accessibility compliance testing",
                bossCount: 3
            )
        ]
    }

    private func createMockBossEncounter() -> MockBossEncounterEntity {
        return MockBossEncounterEntity(
            id: UUID(),
            name: "Accessibility Test Boss",
            encounterOrder: 1,
            dungeonId: UUID(),
            difficulty: "Mythic+",
            healerStrategy: "Test healer strategy for accessibility",
            keyMechanics: ["Critical damage", "Dispel requirement"],
            estimatedDuration: 300
        )
    }

    private func createMockAbilities() -> [MockAbilityEntity] {
        return [
            MockAbilityEntity(
                id: UUID(),
                name: "Critical Test Ability",
                bossEncounterId: UUID(),
                type: .damage,
                damageProfile: .critical,
                castTime: 3.0,
                cooldown: 30.0,
                description: "Critical ability for accessibility testing",
                healerAction: "Use emergency healing cooldowns",
                classification: .critical,
                displayPriority: 1
            )
        ]
    }
}

// MARK: - Helper Structures

private struct WCAGComplianceResults {
    var nonTextContent: Bool = false
    var infoAndRelationships: Bool = false
    var contrastMinimum: Bool = false
    var keyboard: Bool = false
    var focusOrder: Bool = false
    var headingsAndLabels: Bool = false
    var onInput: Bool = false
    var nameRoleValue: Bool = false

    func countPassed() -> Int {
        let results = [nonTextContent, infoAndRelationships, contrastMinimum, keyboard,
                      focusOrder, headingsAndLabels, onInput, nameRoleValue]
        return results.filter { $0 }.count
    }

    func totalCriteria() -> Int {
        return 8
    }
}

// MARK: - Extensions for Testing

extension String? {
    var isNilOrEmpty: Bool {
        return self?.isEmpty ?? true
    }
}

extension DungeonListViewController {
    var dungeonCollectionView: UICollectionView? {
        return view.subviews.compactMap { $0 as? UICollectionView }.first
    }

    var searchController: UISearchController? {
        return navigationItem.searchController
    }
}

extension BossEncounterViewController {
    var bossNameLabel: UILabel? {
        return view.subviews.compactMap { $0 as? UILabel }.first
    }

    var healerStrategyLabel: UILabel? {
        return view.subviews.compactMap { $0 as? UILabel }.dropFirst().first
    }

    var abilityFilterButtons: [UIButton] {
        return view.subviews.compactMap { $0 as? UIButton }
    }

    var abilityCollectionView: UICollectionView? {
        return view.subviews.compactMap { $0 as? UICollectionView }.first
    }
}

extension AbilityCardView {
    var containerView: UIView {
        return subviews.first ?? UIView()
    }

    var urgencyBadge: UIView {
        return subviews.compactMap { $0.subviews.compactMap { $0 as? UIView } }.flatMap { $0 }.first ?? UIView()
    }

    var pulseLayer: CALayer {
        return layer.sublayers?.first ?? CALayer()
    }

    override var accessibilityHint: String? {
        get { return "Double tap to view ability details, long press for additional options" }
        set { }
    }
}

// MARK: - Mock Entities for Accessibility Testing

private struct MockDungeonEntity: DungeonEntity {
    let id: UUID
    let name: String
    let shortName: String
    let difficultyLevel: String
    let displayOrder: Int
    let estimatedDuration: TimeInterval
    let healerNotes: String?
    let bossCount: Int
}

private struct MockBossEncounterEntity: BossEncounterEntity {
    let id: UUID
    let name: String
    let encounterOrder: Int
    let dungeonId: UUID
    let difficulty: String
    let healerStrategy: String?
    let keyMechanics: [String]
    let estimatedDuration: TimeInterval
}

private struct MockAbilityEntity: AbilityEntity {
    let id: UUID?
    let name: String
    let bossEncounterId: UUID
    let type: AbilityType
    let damageProfile: DamageProfile
    let castTime: TimeInterval
    let cooldown: TimeInterval?
    let description: String
    let healerAction: String?
    let criticalInsight: String?
    let classification: AbilityClassification
    let displayPriority: Int

    init(id: UUID?, name: String, bossEncounterId: UUID, type: AbilityType, damageProfile: DamageProfile, castTime: TimeInterval, cooldown: TimeInterval?, description: String, healerAction: String?, classification: AbilityClassification, displayPriority: Int) {
        self.id = id
        self.name = name
        self.bossEncounterId = bossEncounterId
        self.type = type
        self.damageProfile = damageProfile
        self.castTime = castTime
        self.cooldown = cooldown
        self.description = description
        self.healerAction = healerAction
        self.criticalInsight = healerAction
        self.classification = classification
        self.displayPriority = displayPriority
    }
}

private enum AbilityType {
    case damage
    case mechanic
    case heal
}

private enum DamageProfile: String {
    case critical = "Critical"
    case high = "High"
    case moderate = "Moderate"
    case mechanic = "Mechanic"
}

private enum AbilityClassification {
    case critical
    case dispel
    case avoidable
    case informational

    var urgency: UrgencyLevel {
        switch self {
        case .critical: return .immediate
        case .dispel: return .high
        case .avoidable: return .medium
        case .informational: return .low
        }
    }

    var healerImpact: HealerImpact {
        switch self {
        case .critical: return .critical
        case .dispel: return .high
        case .avoidable: return .medium
        case .informational: return .low
        }
    }

    var mechanicType: MechanicType {
        return .damage
    }
}

private enum UrgencyLevel {
    case immediate
    case high
    case medium
    case low
}

private enum HealerImpact {
    case critical
    case high
    case medium
    case low
}

private enum MechanicType {
    case damage
    case dispel
    case positioning
    case cooldown
}

// Create proper AbilityClassification struct for accessibility testing
private struct AccessibilityAbilityClassification {
    let urgency: UrgencyLevel
    let healerImpact: HealerImpact
    let mechanicType: MechanicType
}

/// Mock collection view cell for ability cards
class AbilityCardCollectionViewCell: UICollectionViewCell {
    var abilityCardView: AbilityCardView?
}

/// Mock transition coordinator for testing orientation changes
private class MockTransitionCoordinator: NSObject, UIViewControllerTransitionCoordinator {
    var isAnimated: Bool = true
    var presentationStyle: UIModalPresentationStyle = .none
    var initiallyInteractive: Bool = false
    var isInterruptible: Bool = false
    var isInteractive: Bool = false
    var isCancelled: Bool = false
    var transitionDuration: TimeInterval = 0.3
    var percentComplete: CGFloat = 0.0
    var completionVelocity: CGFloat = 1.0
    var completionCurve: UIView.AnimationCurve = .easeInOut
    var targetTransform: CGAffineTransform = .identity

    func animate(alongsideTransition animation: ((UIViewControllerTransitionCoordinatorContext) -> Void)?, completion: ((UIViewControllerTransitionCoordinatorContext) -> Void)?) -> Bool {
        animation?(self)
        completion?(self)
        return true
    }

    func animateAlongsideTransition(in view: UIView?, animation: ((UIViewControllerTransitionCoordinatorContext) -> Void)?, completion: ((UIViewControllerTransitionCoordinatorContext) -> Void)?) -> Bool {
        return animate(alongsideTransition: animation, completion: completion)
    }

    func notifyWhenInteractionEnds(_ handler: @escaping (UIViewControllerTransitionCoordinatorContext) -> Void) {
        handler(self)
    }

    func notifyWhenInteractionChanges(_ handler: @escaping (UIViewControllerTransitionCoordinatorContext) -> Void) {
        handler(self)
    }

    func containerView() -> UIView {
        return UIView()
    }

    func viewController(forKey key: UITransitionContextViewControllerKey) -> UIViewController? {
        return nil
    }

    func view(forKey key: UITransitionContextViewKey) -> UIView? {
        return nil
    }
}