//
//  iPadNavigationTests.swift
//  HealerKitTests
//
//  Integration Test T011: iPad Navigation User Story
//  "I want to return to the dungeon list. When I use the navigation,
//   then I can easily move between boss, dungeon, and home screens."
//
//  Created by HealerKit TDD Generator on 15/09/2025.
//  Copyright © 2025 HealerKit. All rights reserved.
//

import XCTest
import UIKit
@testable import HealerUIKit
@testable import DungeonKit

class iPadNavigationTests: XCTestCase {

    // MARK: - Test Properties

    var navigationController: HealerNavigationController!
    var splitViewController: HealerSplitViewController!
    var mockWindow: UIWindow!
    var mockDungeonService: MockDungeonService!

    // MARK: - Test Lifecycle

    override func setUp() {
        super.setUp()

        // Create mock services first
        mockDungeonService = MockDungeonService()

        // Initialize navigation components - these will fail until implemented
        do {
            navigationController = try HealerNavigationController(dungeonService: mockDungeonService)
            splitViewController = try HealerSplitViewController(navigationController: navigationController)
        } catch {
            // Expected to fail in TDD - navigation controllers not implemented yet
            XCTFail("Navigation controllers not implemented yet - this is expected in TDD phase")
        }

        // Create test window for iPad simulation
        mockWindow = UIWindow(frame: CGRect(x: 0, y: 0, width: 1024, height: 768)) // iPad Pro dimensions
    }

    override func tearDown() {
        navigationController = nil
        splitViewController = nil
        mockWindow = nil
        mockDungeonService = nil
        super.tearDown()
    }

    // MARK: - Navigation Flow Tests

    func testNavigationFlow_HomeToListToDetail_SuccessfulTransitions() {
        // Given: App starts at home screen
        guard let navController = navigationController else {
            XCTFail("Navigation controller not implemented - expected TDD failure")
            return
        }

        let expectation = XCTestExpectation(description: "Navigation flow completes")

        // When: Navigate from Home → Dungeon List → Boss Detail
        navController.navigateToHome { [weak self] in
            XCTAssertEqual(navController.currentScreen, .home, "Should be on home screen")

            navController.navigateToDungeonList {
                XCTAssertEqual(navController.currentScreen, .dungeonList, "Should be on dungeon list")

                let mockDungeon = self?.mockDungeonService.getMockDungeon()
                navController.navigateToBossDetail(dungeon: mockDungeon!, bossIndex: 0) {
                    XCTAssertEqual(navController.currentScreen, .bossDetail, "Should be on boss detail")
                    expectation.fulfill()
                }
            }
        }

        wait(for: [expectation], timeout: 5.0)
    }

    func testBackNavigation_FromBossDetailToList_SuccessfulReturn() {
        // Given: User is on boss detail screen
        guard let navController = navigationController else {
            XCTFail("Navigation controller not implemented - expected TDD failure")
            return
        }

        let expectation = XCTestExpectation(description: "Back navigation completes")

        // Setup: Navigate to boss detail first
        let mockDungeon = mockDungeonService.getMockDungeon()
        navController.navigateToBossDetail(dungeon: mockDungeon, bossIndex: 0) { [weak navController] in

            // When: Navigate back to dungeon list
            navController?.navigateBack { [weak navController] in
                // Then: Should be back on dungeon list
                XCTAssertEqual(navController?.currentScreen, .dungeonList,
                              "Should return to dungeon list from boss detail")
                XCTAssertEqual(navController?.navigationStack.count, 1,
                              "Navigation stack should have one item after back navigation")
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 5.0)
    }

    func testBreadcrumbNavigation_DirectJumpToHome_SuccessfulNavigation() {
        // Given: User is deep in navigation (Home → List → Detail)
        guard let navController = navigationController else {
            XCTFail("Navigation controller not implemented - expected TDD failure")
            return
        }

        let expectation = XCTestExpectation(description: "Breadcrumb navigation completes")

        // Setup deep navigation
        let mockDungeon = mockDungeonService.getMockDungeon()
        navController.navigateToBossDetail(dungeon: mockDungeon, bossIndex: 0) { [weak navController] in

            // When: Use breadcrumb to jump directly to home
            navController?.navigateToHome { [weak navController] in
                // Then: Should be on home screen with cleared stack
                XCTAssertEqual(navController?.currentScreen, .home, "Should be on home screen")
                XCTAssertEqual(navController?.navigationStack.count, 0,
                              "Navigation stack should be empty after breadcrumb to home")
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 5.0)
    }

    // MARK: - iPad Split View Tests

    func testSplitViewController_iPadLayout_CorrectMasterDetailSetup() {
        // Given: iPad in landscape orientation
        guard let splitVC = splitViewController else {
            XCTFail("Split view controller not implemented - expected TDD failure")
            return
        }

        mockWindow.frame = CGRect(x: 0, y: 0, width: 1366, height: 1024) // iPad Pro landscape

        // When: Split view loads
        mockWindow.rootViewController = splitVC
        mockWindow.makeKeyAndVisible()

        // Then: Should have master and detail view controllers
        XCTAssertNotNil(splitVC.masterViewController, "Master view controller should be set")
        XCTAssertNotNil(splitVC.detailViewController, "Detail view controller should be set")
        XCTAssertTrue(splitVC.preferredDisplayMode == .allVisible,
                     "Should show both master and detail in landscape")
    }

    func testSplitViewController_iPadPortrait_CorrectOverlayBehavior() {
        // Given: iPad in portrait orientation
        guard let splitVC = splitViewController else {
            XCTFail("Split view controller not implemented - expected TDD failure")
            return
        }

        mockWindow.frame = CGRect(x: 0, y: 0, width: 1024, height: 1366) // iPad Pro portrait

        // When: Split view rotates to portrait
        splitVC.viewWillTransition(to: mockWindow.frame.size,
                                  with: MockTransitionCoordinator())

        // Then: Should use overlay mode in portrait
        XCTAssertTrue(splitVC.preferredDisplayMode == .primaryOverlay ||
                     splitVC.preferredDisplayMode == .primaryHidden,
                     "Should use overlay or hidden mode in portrait")
    }

    // MARK: - Touch Target Accessibility Tests

    func testTouchTargets_NavigationButtons_Meet44PointMinimum() {
        // Given: Navigation interface with buttons
        guard let navController = navigationController else {
            XCTFail("Navigation controller not implemented - expected TDD failure")
            return
        }

        let dungeonListVC = navController.dungeonListViewController

        // When: Measuring touch targets
        let backButton = dungeonListVC?.navigationItem.leftBarButtonItem
        let homeButton = dungeonListVC?.navigationItem.rightBarButtonItem

        // Then: Touch targets should meet 44pt minimum
        if let backButtonView = backButton?.customView {
            XCTAssertGreaterThanOrEqual(backButtonView.frame.width, 44.0,
                                      "Back button width should be at least 44 points")
            XCTAssertGreaterThanOrEqual(backButtonView.frame.height, 44.0,
                                      "Back button height should be at least 44 points")
        }

        if let homeButtonView = homeButton?.customView {
            XCTAssertGreaterThanOrEqual(homeButtonView.frame.width, 44.0,
                                      "Home button width should be at least 44 points")
            XCTAssertGreaterThanOrEqual(homeButtonView.frame.height, 44.0,
                                      "Home button height should be at least 44 points")
        }
    }

    func testNavigationBar_iPadOptimized_AppropriateHeight() {
        // Given: iPad navigation bar
        guard let navController = navigationController else {
            XCTFail("Navigation controller not implemented - expected TDD failure")
            return
        }

        // When: Navigation bar is displayed on iPad
        let navigationBar = navController.navigationBar

        // Then: Should use iPad-appropriate height (50pt vs 44pt on iPhone)
        XCTAssertGreaterThanOrEqual(navigationBar.frame.height, 50.0,
                                   "iPad navigation bar should be at least 50 points tall")
    }

    // MARK: - Gesture Support Tests

    func testSwipeGesture_BackNavigation_SuccessfulGestureRecognition() {
        // Given: User is on boss detail screen
        guard let navController = navigationController else {
            XCTFail("Navigation controller not implemented - expected TDD failure")
            return
        }

        let mockDungeon = mockDungeonService.getMockDungeon()
        navController.navigateToBossDetail(dungeon: mockDungeon, bossIndex: 0) { [weak self] in

            // When: User performs swipe gesture
            let swipeGesture = UISwipeGestureRecognizer()
            swipeGesture.direction = .right

            let gestureRecognized = navController.gestureRecognizerShouldBegin(swipeGesture)

            // Then: Gesture should be recognized for back navigation
            XCTAssertTrue(gestureRecognized, "Right swipe should be recognized for back navigation")
        }
    }

    func testPanGesture_InteractiveNavigation_ProperEdgeRecognition() {
        // Given: Navigation controller with edge pan gesture
        guard let navController = navigationController else {
            XCTFail("Navigation controller not implemented - expected TDD failure")
            return
        }

        // When: Creating pan gesture from left edge
        let panGesture = UIScreenEdgePanGestureRecognizer()
        panGesture.edges = .left

        // Then: Should be configured for interactive back navigation
        XCTAssertTrue(navController.interactivePopGestureRecognizer?.isEnabled == true,
                     "Interactive pop gesture should be enabled")
        XCTAssertEqual(navController.interactivePopGestureRecognizer?.edges, .left,
                      "Should recognize left edge pan gesture")
    }

    // MARK: - Orientation Support Tests

    func testOrientationSupport_AllOrientations_ProperHandling() {
        // Given: Navigation controller
        guard let navController = navigationController else {
            XCTFail("Navigation controller not implemented - expected TDD failure")
            return
        }

        // When: Testing supported orientations
        let supportedOrientations = navController.supportedInterfaceOrientations

        // Then: Should support all iPad orientations
        XCTAssertTrue(supportedOrientations.contains(.portrait),
                     "Should support portrait orientation")
        XCTAssertTrue(supportedOrientations.contains(.portraitUpsideDown),
                     "Should support upside down portrait")
        XCTAssertTrue(supportedOrientations.contains(.landscapeLeft),
                     "Should support landscape left")
        XCTAssertTrue(supportedOrientations.contains(.landscapeRight),
                     "Should support landscape right")
    }

    func testOrientationChange_NavigationLayout_AdaptsCorrectly() {
        // Given: Navigation in portrait
        guard let navController = navigationController else {
            XCTFail("Navigation controller not implemented - expected TDD failure")
            return
        }

        mockWindow.rootViewController = navController
        mockWindow.frame = CGRect(x: 0, y: 0, width: 1024, height: 1366) // Portrait

        // When: Rotating to landscape
        let newSize = CGSize(width: 1366, height: 1024)
        navController.viewWillTransition(to: newSize, with: MockTransitionCoordinator())

        // Then: Layout should adapt
        XCTAssertEqual(navController.view.frame.width, 1366,
                      "Should adapt to landscape width")
        XCTAssertEqual(navController.view.frame.height, 1024,
                      "Should adapt to landscape height")
    }

    // MARK: - Error Handling Tests

    func testNavigationError_InvalidDungeon_ProperErrorHandling() {
        // Given: Navigation controller
        guard let navController = navigationController else {
            XCTFail("Navigation controller not implemented - expected TDD failure")
            return
        }

        // When: Attempting to navigate with invalid dungeon
        let expectation = XCTestExpectation(description: "Error handling completes")

        navController.navigateToBossDetail(dungeon: nil, bossIndex: 0) { [weak navController] in
            // Then: Should handle error gracefully
            XCTAssertEqual(navController?.currentScreen, .dungeonList,
                          "Should remain on dungeon list after error")
            XCTAssertNotNil(navController?.lastError, "Should capture navigation error")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5.0)
    }

    func testNavigationError_MemoryWarning_RecoveryBehavior() {
        // Given: Navigation controller under memory pressure
        guard let navController = navigationController else {
            XCTFail("Navigation controller not implemented - expected TDD failure")
            return
        }

        // When: Simulating memory warning
        navController.didReceiveMemoryWarning()

        // Then: Should maintain navigation state
        XCTAssertNotNil(navController.currentScreen, "Should maintain current screen after memory warning")
        XCTAssertFalse(navController.navigationStack.isEmpty,
                      "Should preserve essential navigation state")
    }

    // MARK: - Performance Tests

    func testNavigationPerformance_TransitionSpeed_MeetsTarget() {
        // Given: Navigation controller
        guard let navController = navigationController else {
            XCTFail("Navigation controller not implemented - expected TDD failure")
            return
        }

        let expectation = XCTestExpectation(description: "Performance test completes")

        // When: Measuring navigation transition time
        let startTime = CFAbsoluteTimeGetCurrent()

        navController.navigateToDungeonList {
            let endTime = CFAbsoluteTimeGetCurrent()
            let transitionTime = endTime - startTime

            // Then: Should complete within 0.3 seconds for 60fps target
            XCTAssertLessThan(transitionTime, 0.3,
                            "Navigation transition should complete within 300ms")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testMemoryUsage_NavigationStack_StaysWithinLimits() {
        // Given: Navigation controller
        guard let navController = navigationController else {
            XCTFail("Navigation controller not implemented - expected TDD failure")
            return
        }

        // When: Performing multiple navigations
        let initialMemory = getMemoryUsage()

        for i in 0..<10 {
            let mockDungeon = mockDungeonService.getMockDungeon()
            navController.navigateToBossDetail(dungeon: mockDungeon, bossIndex: i % 3) { }
            navController.navigateBack { }
        }

        let finalMemory = getMemoryUsage()
        let memoryIncrease = finalMemory - initialMemory

        // Then: Memory increase should be minimal (< 10MB for navigation stack)
        XCTAssertLessThan(memoryIncrease, 10 * 1024 * 1024,
                         "Navigation should not leak significant memory")
    }
}

// MARK: - Mock Classes

class MockDungeonService: DungeonServiceProtocol {
    func getMockDungeon() -> Dungeon {
        return Dungeon(
            id: UUID(),
            name: "Test Dungeon",
            seasonId: UUID(),
            bossEncounters: [
                BossEncounter(id: UUID(), name: "Test Boss 1", abilities: []),
                BossEncounter(id: UUID(), name: "Test Boss 2", abilities: []),
                BossEncounter(id: UUID(), name: "Test Boss 3", abilities: [])
            ]
        )
    }

    func getAllDungeons() -> [Dungeon] {
        return [getMockDungeon()]
    }
}

class MockTransitionCoordinator: NSObject, UIViewControllerTransitionCoordinator {
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

    func animate(alongsideTransition animation: ((UIViewControllerTransitionCoordinatorContext) -> Void)?,
                completion: ((UIViewControllerTransitionCoordinatorContext) -> Void)?) -> Bool {
        animation?(self)
        completion?(self)
        return true
    }

    func animateAlongsideTransition(in view: UIView?,
                                  animation: ((UIViewControllerTransitionCoordinatorContext) -> Void)?,
                                  completion: ((UIViewControllerTransitionCoordinatorContext) -> Void)?) -> Bool {
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

// MARK: - Helper Functions

private func getMemoryUsage() -> UInt64 {
    var info = mach_task_basic_info()
    var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4

    let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
        $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
            task_info(mach_task_self_,
                     task_flavor_t(MACH_TASK_BASIC_INFO),
                     $0,
                     &count)
        }
    }

    if kerr == KERN_SUCCESS {
        return info.resident_size
    } else {
        return 0
    }
}

// MARK: - Protocol Extensions for Testing

extension HealerNavigationController {
    enum NavigationScreen {
        case home
        case dungeonList
        case bossDetail
    }

    var currentScreen: NavigationScreen {
        // This will fail until implemented - expected in TDD
        fatalError("Navigation controller currentScreen not implemented")
    }

    var navigationStack: [UIViewController] {
        // This will fail until implemented - expected in TDD
        fatalError("Navigation controller navigationStack not implemented")
    }

    var lastError: Error? {
        // This will fail until implemented - expected in TDD
        fatalError("Navigation controller lastError not implemented")
    }

    var dungeonListViewController: UIViewController? {
        // This will fail until implemented - expected in TDD
        fatalError("Navigation controller dungeonListViewController not implemented")
    }

    func navigateToHome(completion: @escaping () -> Void) {
        // This will fail until implemented - expected in TDD
        fatalError("Navigation controller navigateToHome not implemented")
    }

    func navigateToDungeonList(completion: @escaping () -> Void) {
        // This will fail until implemented - expected in TDD
        fatalError("Navigation controller navigateToDungeonList not implemented")
    }

    func navigateToBossDetail(dungeon: Dungeon?, bossIndex: Int, completion: @escaping () -> Void) {
        // This will fail until implemented - expected in TDD
        fatalError("Navigation controller navigateToBossDetail not implemented")
    }

    func navigateBack(completion: @escaping () -> Void) {
        // This will fail until implemented - expected in TDD
        fatalError("Navigation controller navigateBack not implemented")
    }
}

extension HealerSplitViewController {
    var masterViewController: UIViewController? {
        // This will fail until implemented - expected in TDD
        fatalError("Split view controller masterViewController not implemented")
    }

    var detailViewController: UIViewController? {
        // This will fail until implemented - expected in TDD
        fatalError("Split view controller detailViewController not implemented")
    }
}