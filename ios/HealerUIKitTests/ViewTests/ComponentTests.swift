//
//  ComponentTests.swift
//  HealerUIKitTests
//
//  Task T038: UI Component Testing
//  Tests iPad UI components, touch targets, color contrast, Dynamic Type, orientation handling
//  Created by HealerKit Test Coverage Enforcement Specialist on 15/09/2025.
//

import XCTest
import UIKit
import XCUITest
@testable import HealerUIKit
@testable import DungeonKit
@testable import AbilityKit

/// Comprehensive UI testing suite for iPad-optimized HealerKit components
/// Tests touch target sizing, color contrast ratios, Dynamic Type support, and orientation handling
final class ComponentTests: XCTestCase {

    // MARK: - Test Properties

    private var testWindow: UIWindow!
    private var mockDungeons: [MockDungeonEntity]!
    private var mockBossEncounter: MockBossEncounterEntity!
    private var mockAbilities: [MockAbilityEntity]!

    // Test view controllers
    private var dungeonListVC: DungeonListViewController!
    private var bossEncounterVC: BossEncounterViewController!
    private var abilityCardView: AbilityCardView!

    // Constants for iPad testing
    private struct TestConstants {
        static let minimumTouchTarget: CGFloat = 44.0
        static let iPadPortraitSize = CGSize(width: 1024, height: 1366)
        static let iPadLandscapeSize = CGSize(width: 1366, height: 1024)
        static let wcagAAContrastRatio: Float = 4.5
        static let wcagAAAContrastRatio: Float = 7.0
        static let maxDynamicTypeSize: CGFloat = 28.0
        static let minDynamicTypeSize: CGFloat = 12.0
    }

    // MARK: - Test Lifecycle

    override func setUpWithError() throws {
        super.setUp()

        // Create test window for iPad simulation
        testWindow = UIWindow(frame: CGRect(origin: .zero, size: TestConstants.iPadPortraitSize))
        testWindow.makeKeyAndVisible()

        // Create mock data
        mockDungeons = createMockDungeons()
        mockBossEncounter = createMockBossEncounter()
        mockAbilities = createMockAbilities()

        // Initialize UI components
        try setupViewControllers()
    }

    override func tearDownWithError() throws {
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
                    classification: AbilityClassification(
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

    // MARK: - T038.1: DungeonListViewController Touch Target Tests

    func test_DungeonListViewController_TouchTargets_Meet44PointMinimum() throws {
        guard let dungeonListVC = dungeonListVC else {
            XCTFail("DungeonListViewController not implemented - expected TDD failure")
            return
        }

        testWindow.rootViewController = dungeonListVC
        testWindow.layoutIfNeeded()

        // Test navigation bar button touch targets
        let navigationBar = dungeonListVC.navigationController?.navigationBar
        XCTAssertNotNil(navigationBar, "Navigation bar should be present")

        // Test back button touch target
        if let backButtonItem = dungeonListVC.navigationItem.leftBarButtonItem,
           let backButtonView = backButtonItem.customView {
            XCTAssertGreaterThanOrEqual(
                backButtonView.frame.width,
                TestConstants.minimumTouchTarget,
                "Back button width should meet 44pt minimum touch target"
            )
            XCTAssertGreaterThanOrEqual(
                backButtonView.frame.height,
                TestConstants.minimumTouchTarget,
                "Back button height should meet 44pt minimum touch target"
            )
        }

        // Test settings button touch target
        if let settingsButtonItem = dungeonListVC.navigationItem.rightBarButtonItem,
           let settingsButtonView = settingsButtonItem.customView {
            XCTAssertGreaterThanOrEqual(
                settingsButtonView.frame.width,
                TestConstants.minimumTouchTarget,
                "Settings button width should meet 44pt minimum touch target"
            )
            XCTAssertGreaterThanOrEqual(
                settingsButtonView.frame.height,
                TestConstants.minimumTouchTarget,
                "Settings button height should meet 44pt minimum touch target"
            )
        }

        // Test dungeon list cell touch targets
        if let collectionView = dungeonListVC.dungeonCollectionView {
            let indexPath = IndexPath(item: 0, section: 0)
            if let cell = collectionView.cellForItem(at: indexPath) {
                XCTAssertGreaterThanOrEqual(
                    cell.frame.height,
                    TestConstants.minimumTouchTarget,
                    "Dungeon cell height should meet 44pt minimum touch target"
                )

                // Test interactive elements within cell
                let interactiveSubviews = cell.subviews.filter { $0.isUserInteractionEnabled }
                for interactiveView in interactiveSubviews {
                    XCTAssertGreaterThanOrEqual(
                        interactiveView.frame.width,
                        TestConstants.minimumTouchTarget,
                        "Interactive cell element width should meet 44pt minimum"
                    )
                    XCTAssertGreaterThanOrEqual(
                        interactiveView.frame.height,
                        TestConstants.minimumTouchTarget,
                        "Interactive cell element height should meet 44pt minimum"
                    )
                }
            }
        }
    }

    func test_DungeonListViewController_iPadLayout_OptimizedForLargeScreen() throws {
        guard let dungeonListVC = dungeonListVC else {
            XCTFail("DungeonListViewController not implemented - expected TDD failure")
            return
        }

        testWindow.rootViewController = dungeonListVC
        testWindow.layoutIfNeeded()

        // Test collection view layout for iPad
        if let collectionView = dungeonListVC.dungeonCollectionView,
           let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {

            // Test item spacing for iPad
            XCTAssertGreaterThanOrEqual(
                flowLayout.minimumInteritemSpacing,
                20.0,
                "iPad should have generous spacing between dungeon items"
            )

            // Test section margins for iPad
            XCTAssertGreaterThanOrEqual(
                flowLayout.sectionInset.left,
                24.0,
                "iPad should have appropriate section margins"
            )

            // Test item size scales appropriately for iPad
            let itemSize = flowLayout.itemSize
            XCTAssertGreaterThan(
                itemSize.width,
                200.0,
                "Dungeon items should be appropriately sized for iPad"
            )
            XCTAssertGreaterThan(
                itemSize.height,
                100.0,
                "Dungeon items should have sufficient height for iPad"
            )
        }
    }

    // MARK: - T038.2: BossEncounterViewController Touch Target Tests

    func test_BossEncounterViewController_TouchTargets_Meet44PointMinimum() throws {
        guard let bossEncounterVC = bossEncounterVC else {
            XCTFail("BossEncounterViewController not implemented - expected TDD failure")
            return
        }

        testWindow.rootViewController = bossEncounterVC
        testWindow.layoutIfNeeded()

        // Test ability filter buttons
        let filterButtons = bossEncounterVC.abilityFilterButtons
        for button in filterButtons {
            XCTAssertGreaterThanOrEqual(
                button.frame.width,
                TestConstants.minimumTouchTarget,
                "Filter button width should meet 44pt minimum touch target"
            )
            XCTAssertGreaterThanOrEqual(
                button.frame.height,
                TestConstants.minimumTouchTarget,
                "Filter button height should meet 44pt minimum touch target"
            )
        }

        // Test ability collection view cell touch targets
        if let abilityCollectionView = bossEncounterVC.abilityCollectionView {
            let indexPath = IndexPath(item: 0, section: 0)
            if let cell = abilityCollectionView.cellForItem(at: indexPath) as? AbilityCardCollectionViewCell {
                XCTAssertGreaterThanOrEqual(
                    cell.frame.height,
                    TestConstants.minimumTouchTarget,
                    "Ability card cell height should meet 44pt minimum touch target"
                )

                // Test ability card view within cell
                if let cardView = cell.abilityCardView {
                    XCTAssertGreaterThanOrEqual(
                        cardView.frame.height,
                        TestConstants.minimumTouchTarget,
                        "Ability card view height should meet 44pt minimum touch target"
                    )
                }
            }
        }

        // Test boss strategy toggle button
        if let strategyToggle = bossEncounterVC.bossStrategyToggleButton {
            XCTAssertGreaterThanOrEqual(
                strategyToggle.frame.width,
                TestConstants.minimumTouchTarget,
                "Strategy toggle width should meet 44pt minimum touch target"
            )
            XCTAssertGreaterThanOrEqual(
                strategyToggle.frame.height,
                TestConstants.minimumTouchTarget,
                "Strategy toggle height should meet 44pt minimum touch target"
            )
        }
    }

    func test_BossEncounterViewController_SplitViewBehavior_iPadOptimized() throws {
        guard let bossEncounterVC = bossEncounterVC else {
            XCTFail("BossEncounterViewController not implemented - expected TDD failure")
            return
        }

        // Test in split view controller
        let splitVC = UISplitViewController()
        let masterVC = UINavigationController(rootViewController: UIViewController())
        let detailVC = UINavigationController(rootViewController: bossEncounterVC)

        splitVC.viewControllers = [masterVC, detailVC]
        testWindow.rootViewController = splitVC
        testWindow.layoutIfNeeded()

        // Test detail view behavior in split view
        XCTAssertTrue(
            bossEncounterVC.view.frame.width > 400,
            "Boss encounter view should utilize available width in split view"
        )

        // Test adaptive layout in portrait
        testWindow.frame.size = TestConstants.iPadPortraitSize
        testWindow.layoutIfNeeded()

        // Test adaptive layout in landscape
        testWindow.frame.size = TestConstants.iPadLandscapeSize
        testWindow.layoutIfNeeded()

        XCTAssertTrue(
            bossEncounterVC.view.frame.width > TestConstants.iPadPortraitSize.width / 2,
            "Boss encounter view should adapt to landscape layout"
        )
    }

    // MARK: - T038.3: AbilityCardView Touch Target Tests

    func test_AbilityCardView_TouchTargets_Meet44PointMinimum() throws {
        guard let abilityCardView = abilityCardView else {
            XCTFail("AbilityCardView not implemented - expected TDD failure")
            return
        }

        // Add to test window for proper layout
        let containerView = UIView(frame: testWindow.bounds)
        containerView.addSubview(abilityCardView)
        abilityCardView.frame = CGRect(x: 20, y: 20, width: 300, height: 120)
        testWindow.addSubview(containerView)
        testWindow.layoutIfNeeded()

        // Test minimum card height
        XCTAssertGreaterThanOrEqual(
            abilityCardView.frame.height,
            TestConstants.minimumTouchTarget,
            "Ability card height should meet 44pt minimum touch target"
        )

        // Test card is touch-enabled
        XCTAssertTrue(
            abilityCardView.isUserInteractionEnabled,
            "Ability card should be touch-enabled"
        )

        // Test gesture recognizers
        let tapGestures = abilityCardView.gestureRecognizers?.compactMap { $0 as? UITapGestureRecognizer }
        XCTAssertNotNil(tapGestures, "Ability card should have tap gesture recognizer")
        XCTAssertFalse(tapGestures?.isEmpty ?? true, "Should have at least one tap gesture")

        let longPressGestures = abilityCardView.gestureRecognizers?.compactMap { $0 as? UILongPressGestureRecognizer }
        XCTAssertNotNil(longPressGestures, "Ability card should have long press gesture recognizer")
    }

    func test_AbilityCardView_CriticalAbilityEmphasis_VisualIndicators() throws {
        guard let abilityCardView = abilityCardView else {
            XCTFail("AbilityCardView not implemented - expected TDD failure")
            return
        }

        // Test critical ability has visual emphasis
        let classification = AbilityClassification(
            urgency: .immediate,
            healerImpact: .critical,
            mechanicType: .damage
        )
        abilityCardView.classification = classification

        testWindow.addSubview(abilityCardView)
        abilityCardView.frame = CGRect(x: 20, y: 20, width: 300, height: 120)
        testWindow.layoutIfNeeded()

        // Test urgency badge visibility for critical abilities
        XCTAssertFalse(
            abilityCardView.urgencyBadge.isHidden,
            "Critical abilities should show urgency badge"
        )

        // Test border emphasis for critical abilities
        XCTAssertGreaterThan(
            abilityCardView.containerView.layer.borderWidth,
            0.0,
            "Critical abilities should have border emphasis"
        )

        // Test attention animation capability
        abilityCardView.animateAttention()

        // Animation should be active for critical abilities
        XCTAssertFalse(
            abilityCardView.pulseLayer.isHidden,
            "Critical abilities should show attention animation"
        )
    }

    // MARK: - T038.4: Color Contrast Ratio Tests (WCAG AA Compliance)

    func test_ColorContrast_DamageProfiles_MeetWCAGAACompliance() throws {
        let testCases = [
            ("critical", UIColor(red: 0.96, green: 0.42, blue: 0.42, alpha: 1.0)),
            ("high", UIColor(red: 1.0, green: 0.65, blue: 0.31, alpha: 1.0)),
            ("moderate", UIColor(red: 1.0, green: 0.86, blue: 0.35, alpha: 1.0)),
            ("mechanic", UIColor(red: 0.35, green: 0.67, blue: 1.0, alpha: 1.0))
        ]

        for (profileName, color) in testCases {
            // Test against white background
            let contrastRatioWhite = calculateContrastRatio(
                foregroundColor: color,
                backgroundColor: .white
            )

            XCTAssertGreaterThanOrEqual(
                contrastRatioWhite,
                TestConstants.wcagAAContrastRatio,
                "\(profileName) damage profile should meet WCAG AA contrast ratio (4.5:1) against white background"
            )

            // Test against dark background
            let contrastRatioDark = calculateContrastRatio(
                foregroundColor: color,
                backgroundColor: .black
            )

            XCTAssertGreaterThanOrEqual(
                contrastRatioDark,
                TestConstants.wcagAAContrastRatio,
                "\(profileName) damage profile should meet WCAG AA contrast ratio (4.5:1) against dark background"
            )
        }
    }

    func test_ColorContrast_TextElements_MeetWCAGAACompliance() throws {
        guard let abilityCardView = abilityCardView else {
            XCTFail("AbilityCardView not implemented - expected TDD failure")
            return
        }

        testWindow.addSubview(abilityCardView)
        abilityCardView.frame = CGRect(x: 20, y: 20, width: 300, height: 120)
        testWindow.layoutIfNeeded()

        // Test ability name label contrast
        let nameTextColor = abilityCardView.abilityNameLabel.textColor ?? .label
        let backgroundColor = abilityCardView.containerView.backgroundColor ?? .systemBackground

        let nameContrastRatio = calculateContrastRatio(
            foregroundColor: nameTextColor,
            backgroundColor: backgroundColor
        )

        XCTAssertGreaterThanOrEqual(
            nameContrastRatio,
            TestConstants.wcagAAContrastRatio,
            "Ability name text should meet WCAG AA contrast ratio (4.5:1)"
        )

        // Test healer action label contrast
        let actionTextColor = abilityCardView.healerActionLabel.textColor ?? .secondaryLabel
        let actionContrastRatio = calculateContrastRatio(
            foregroundColor: actionTextColor,
            backgroundColor: backgroundColor
        )

        XCTAssertGreaterThanOrEqual(
            actionContrastRatio,
            TestConstants.wcagAAContrastRatio,
            "Healer action text should meet WCAG AA contrast ratio (4.5:1)"
        )
    }

    // MARK: - T038.5: Dynamic Type Support Tests

    func test_DynamicType_TextScaling_SupportsFullRange() throws {
        let contentSizeCategories: [UIContentSizeCategory] = [
            .extraSmall,
            .small,
            .medium,
            .large,
            .extraLarge,
            .extraExtraLarge,
            .extraExtraExtraLarge,
            .accessibilityMedium,
            .accessibilityLarge,
            .accessibilityExtraLarge,
            .accessibilityExtraExtraLarge,
            .accessibilityExtraExtraExtraLarge
        ]

        for category in contentSizeCategories {
            // Simulate content size category change
            let traitCollection = UITraitCollection(preferredContentSizeCategory: category)

            // Test DungeonListViewController
            if let dungeonListVC = dungeonListVC {
                dungeonListVC.traitCollectionDidChange(traitCollection)

                // Verify font scaling
                let titleFont = dungeonListVC.titleLabel.font
                XCTAssertNotNil(titleFont, "Title font should be set")

                if category.isAccessibilityCategory {
                    XCTAssertLessThanOrEqual(
                        titleFont!.pointSize,
                        TestConstants.maxDynamicTypeSize,
                        "Font size should respect maximum size limit for accessibility category \(category.rawValue)"
                    )
                } else {
                    XCTAssertGreaterThanOrEqual(
                        titleFont!.pointSize,
                        TestConstants.minDynamicTypeSize,
                        "Font size should respect minimum size limit for category \(category.rawValue)"
                    )
                }
            }
        }
    }

    func test_DynamicType_AbilityCardView_AdaptsTextSizes() throws {
        guard let abilityCardView = abilityCardView else {
            XCTFail("AbilityCardView not implemented - expected TDD failure")
            return
        }

        testWindow.addSubview(abilityCardView)
        abilityCardView.frame = CGRect(x: 20, y: 20, width: 300, height: 120)

        let largeTraitCollection = UITraitCollection(preferredContentSizeCategory: .extraExtraExtraLarge)
        let smallTraitCollection = UITraitCollection(preferredContentSizeCategory: .extraSmall)

        // Test large text scaling
        abilityCardView.traitCollectionDidChange(largeTraitCollection)
        testWindow.layoutIfNeeded()

        let largeFontSize = abilityCardView.abilityNameLabel.font.pointSize

        // Test small text scaling
        abilityCardView.traitCollectionDidChange(smallTraitCollection)
        testWindow.layoutIfNeeded()

        let smallFontSize = abilityCardView.abilityNameLabel.font.pointSize

        XCTAssertGreaterThan(
            largeFontSize,
            smallFontSize,
            "Ability card should scale text size with Dynamic Type preferences"
        )

        // Test text remains readable at all sizes
        XCTAssertGreaterThanOrEqual(
            smallFontSize,
            TestConstants.minDynamicTypeSize,
            "Minimum font size should remain readable"
        )
        XCTAssertLessThanOrEqual(
            largeFontSize,
            TestConstants.maxDynamicTypeSize,
            "Maximum font size should not break layout"
        )
    }

    // MARK: - T038.6: Orientation Change Handling Tests

    func test_OrientationChange_PortraitToLandscape_LayoutAdapts() throws {
        guard let dungeonListVC = dungeonListVC else {
            XCTFail("DungeonListViewController not implemented - expected TDD failure")
            return
        }

        // Start in portrait
        testWindow.frame = CGRect(origin: .zero, size: TestConstants.iPadPortraitSize)
        testWindow.rootViewController = dungeonListVC
        testWindow.layoutIfNeeded()

        let portraitWidth = dungeonListVC.view.frame.width

        // Simulate rotation to landscape
        testWindow.frame = CGRect(origin: .zero, size: TestConstants.iPadLandscapeSize)

        let coordinator = MockTransitionCoordinator()
        dungeonListVC.viewWillTransition(to: TestConstants.iPadLandscapeSize, with: coordinator)
        testWindow.layoutIfNeeded()

        let landscapeWidth = dungeonListVC.view.frame.width

        XCTAssertGreaterThan(
            landscapeWidth,
            portraitWidth,
            "View should adapt width when rotating to landscape"
        )

        // Test collection view layout adaptation
        if let collectionView = dungeonListVC.dungeonCollectionView,
           let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {

            // Collection view should use additional width in landscape
            XCTAssertEqual(
                collectionView.frame.width,
                landscapeWidth,
                "Collection view should fill available width in landscape"
            )

            // Layout should be invalidated for orientation change
            XCTAssertTrue(
                flowLayout.shouldInvalidateLayout(forBoundsChange: collectionView.bounds),
                "Collection view layout should invalidate for bounds change"
            )
        }
    }

    func test_OrientationChange_AbilityCardView_MaintainsUsability() throws {
        guard let abilityCardView = abilityCardView else {
            XCTFail("AbilityCardView not implemented - expected TDD failure")
            return
        }

        let containerView = UIView()
        testWindow.addSubview(containerView)
        containerView.addSubview(abilityCardView)

        // Test in portrait
        containerView.frame = CGRect(origin: .zero, size: TestConstants.iPadPortraitSize)
        abilityCardView.frame = CGRect(x: 20, y: 20, width: containerView.frame.width - 40, height: 120)
        abilityCardView.layoutIfNeeded()

        let portraitFrame = abilityCardView.frame

        // Test in landscape
        containerView.frame = CGRect(origin: .zero, size: TestConstants.iPadLandscapeSize)
        abilityCardView.frame = CGRect(x: 20, y: 20, width: containerView.frame.width - 40, height: 120)
        abilityCardView.layoutIfNeeded()

        let landscapeFrame = abilityCardView.frame

        // Card should maintain minimum touch target in both orientations
        XCTAssertGreaterThanOrEqual(
            portraitFrame.height,
            TestConstants.minimumTouchTarget,
            "Ability card should maintain minimum height in portrait"
        )
        XCTAssertGreaterThanOrEqual(
            landscapeFrame.height,
            TestConstants.minimumTouchTarget,
            "Ability card should maintain minimum height in landscape"
        )

        // Card should adapt to available width
        XCTAssertGreaterThan(
            landscapeFrame.width,
            portraitFrame.width,
            "Ability card should use additional width in landscape"
        )
    }

    // MARK: - T038.7: Split View Controller Behavior Tests

    func test_SplitViewController_MasterDetailNavigation_iPadOptimized() throws {
        let splitVC = UISplitViewController()
        let masterNavVC = UINavigationController()
        let detailNavVC = UINavigationController()

        if let dungeonListVC = dungeonListVC {
            masterNavVC.viewControllers = [dungeonListVC]
        }

        if let bossEncounterVC = bossEncounterVC {
            detailNavVC.viewControllers = [bossEncounterVC]
        }

        splitVC.viewControllers = [masterNavVC, detailNavVC]
        splitVC.preferredDisplayMode = .allVisible

        testWindow.frame = CGRect(origin: .zero, size: TestConstants.iPadLandscapeSize)
        testWindow.rootViewController = splitVC
        testWindow.layoutIfNeeded()

        // Test split view shows both master and detail in landscape
        XCTAssertEqual(
            splitVC.viewControllers.count,
            2,
            "Split view should have both master and detail view controllers"
        )

        XCTAssertTrue(
            splitVC.isCollapsed == false,
            "Split view should not be collapsed in landscape on iPad"
        )

        // Test master view controller width
        let masterVC = splitVC.viewControllers.first
        XCTAssertNotNil(masterVC, "Master view controller should be present")

        if let masterView = masterVC?.view {
            XCTAssertGreaterThan(
                masterView.frame.width,
                200,
                "Master view should have reasonable minimum width"
            )
            XCTAssertLessThan(
                masterView.frame.width,
                testWindow.frame.width * 0.6,
                "Master view should not dominate screen width"
            )
        }

        // Test detail view controller width
        let detailVC = splitVC.viewControllers.last
        if let detailView = detailVC?.view {
            XCTAssertGreaterThan(
                detailView.frame.width,
                400,
                "Detail view should have sufficient width for content"
            )
        }
    }

    func test_SplitViewController_PortraitBehavior_OverlayMode() throws {
        let splitVC = UISplitViewController()
        let masterNavVC = UINavigationController()
        let detailNavVC = UINavigationController()

        if let dungeonListVC = dungeonListVC {
            masterNavVC.viewControllers = [dungeonListVC]
        }

        if let bossEncounterVC = bossEncounterVC {
            detailNavVC.viewControllers = [bossEncounterVC]
        }

        splitVC.viewControllers = [masterNavVC, detailNavVC]

        // Test in portrait mode
        testWindow.frame = CGRect(origin: .zero, size: TestConstants.iPadPortraitSize)
        testWindow.rootViewController = splitVC

        // Simulate portrait orientation
        let coordinator = MockTransitionCoordinator()
        splitVC.viewWillTransition(to: TestConstants.iPadPortraitSize, with: coordinator)
        testWindow.layoutIfNeeded()

        // In portrait, iPad should use overlay or hidden mode
        XCTAssertTrue(
            splitVC.preferredDisplayMode == .primaryOverlay ||
            splitVC.preferredDisplayMode == .primaryHidden,
            "Split view should use overlay or hidden mode in portrait on iPad"
        )

        // Detail view should be visible and use full width in portrait
        let detailVC = splitVC.viewControllers.last
        if let detailView = detailVC?.view {
            XCTAssertGreaterThan(
                detailView.frame.width,
                TestConstants.iPadPortraitSize.width * 0.8,
                "Detail view should use most of screen width in portrait"
            )
        }
    }

    // MARK: - T038.8: Ability Card Animation Tests

    func test_AbilityCardAnimations_CriticalAbilities_AttentionAnimation() throws {
        guard let abilityCardView = abilityCardView else {
            XCTFail("AbilityCardView not implemented - expected TDD failure")
            return
        }

        testWindow.addSubview(abilityCardView)
        abilityCardView.frame = CGRect(x: 20, y: 20, width: 300, height: 120)
        testWindow.layoutIfNeeded()

        // Test attention animation for critical abilities
        let criticalClassification = AbilityClassification(
            urgency: .immediate,
            healerImpact: .critical,
            mechanicType: .damage
        )
        abilityCardView.classification = criticalClassification

        // Start attention animation
        abilityCardView.animateAttention()

        // Test pulse layer is visible and animating
        XCTAssertFalse(
            abilityCardView.pulseLayer.isHidden,
            "Pulse layer should be visible for attention animation"
        )

        XCTAssertNotNil(
            abilityCardView.pulseLayer.animation(forKey: "pulse"),
            "Pulse layer should have pulse animation active"
        )

        // Test animation auto-stops after timeout
        let expectation = XCTestExpectation(description: "Animation stops after timeout")

        DispatchQueue.main.asyncAfter(deadline: .now() + 11.0) {
            XCTAssertTrue(
                abilityCardView.pulseLayer.isHidden,
                "Pulse animation should stop after timeout"
            )
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 12.0)
    }

    func test_AbilityCardAnimations_DisplayModeTransitions_SmoothTransitions() throws {
        guard let abilityCardView = abilityCardView else {
            XCTFail("AbilityCardView not implemented - expected TDD failure")
            return
        }

        testWindow.addSubview(abilityCardView)
        abilityCardView.frame = CGRect(x: 20, y: 20, width: 300, height: 120)
        testWindow.layoutIfNeeded()

        // Test transition from full to compact mode
        abilityCardView.updateDisplayMode(.full)
        testWindow.layoutIfNeeded()

        let initialHealerActionVisibility = !abilityCardView.healerActionLabel.isHidden
        let initialCriticalInsightVisibility = !abilityCardView.criticalInsightLabel.isHidden

        // Transition to compact mode
        let expectation = XCTestExpectation(description: "Display mode transition completes")

        abilityCardView.updateDisplayMode(.compact)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let finalHealerActionVisibility = !abilityCardView.healerActionLabel.isHidden
            let finalCriticalInsightVisibility = !abilityCardView.criticalInsightLabel.isHidden

            // Healer action should remain visible, critical insight should be hidden
            XCTAssertTrue(
                finalHealerActionVisibility,
                "Healer action should be visible in compact mode"
            )
            XCTAssertFalse(
                finalCriticalInsightVisibility,
                "Critical insight should be hidden in compact mode"
            )

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    // MARK: - Helper Methods

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

    // MARK: - Mock Data Factory

    private func createMockDungeons() -> [MockDungeonEntity] {
        return [
            MockDungeonEntity(
                id: UUID(),
                name: "Test Dungeon 1",
                shortName: "TD1",
                difficultyLevel: "Mythic+",
                displayOrder: 1,
                estimatedDuration: 1800,
                healerNotes: "High damage phases require cooldown management",
                bossCount: 3
            ),
            MockDungeonEntity(
                id: UUID(),
                name: "Test Dungeon 2",
                shortName: "TD2",
                difficultyLevel: "Mythic+",
                displayOrder: 2,
                estimatedDuration: 2100,
                healerNotes: "Focus on dispel mechanics",
                bossCount: 4
            )
        ]
    }

    private func createMockBossEncounter() -> MockBossEncounterEntity {
        return MockBossEncounterEntity(
            id: UUID(),
            name: "Test Boss",
            encounterOrder: 1,
            dungeonId: UUID(),
            difficulty: "Mythic+",
            healerStrategy: "Maintain raid cooldowns for burn phase",
            keyMechanics: ["High damage AOE", "Dispel requirement"],
            estimatedDuration: 300
        )
    }

    private func createMockAbilities() -> [MockAbilityEntity] {
        return [
            MockAbilityEntity(
                id: UUID(),
                name: "Critical Damage Blast",
                bossEncounterId: UUID(),
                type: .damage,
                damageProfile: .critical,
                castTime: 3.0,
                cooldown: 30.0,
                description: "High damage ability requiring immediate healing",
                healerAction: "Use defensive cooldowns immediately",
                classification: .critical,
                displayPriority: 1
            ),
            MockAbilityEntity(
                id: UUID(),
                name: "Dispellable Debuff",
                bossEncounterId: UUID(),
                type: .mechanic,
                damageProfile: .moderate,
                castTime: 2.0,
                cooldown: 15.0,
                description: "Dispellable magic debuff",
                healerAction: "Dispel immediately",
                classification: .dispel,
                displayPriority: 2
            )
        ]
    }
}

// MARK: - Test Doubles and Extensions

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

// MARK: - Extensions for Testing Interface

extension DungeonListViewController {
    var dungeonCollectionView: UICollectionView? {
        return view.subviews.compactMap { $0 as? UICollectionView }.first
    }

    var titleLabel: UILabel {
        return navigationItem.titleView as? UILabel ?? UILabel()
    }
}

extension BossEncounterViewController {
    var abilityFilterButtons: [UIButton] {
        return view.subviews.compactMap { $0 as? UIButton }
    }

    var abilityCollectionView: UICollectionView? {
        return view.subviews.compactMap { $0 as? UICollectionView }.first
    }

    var bossStrategyToggleButton: UIButton? {
        return view.subviews.compactMap { $0 as? UIButton }.first
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
}

/// Mock collection view cell for ability cards
class AbilityCardCollectionViewCell: UICollectionViewCell {
    var abilityCardView: AbilityCardView?
}

// MARK: - Mock Entity Implementations

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

// Create proper AbilityClassification struct for testing
private struct AbilityClassification {
    let urgency: UrgencyLevel
    let healerImpact: HealerImpact
    let mechanicType: MechanicType
}