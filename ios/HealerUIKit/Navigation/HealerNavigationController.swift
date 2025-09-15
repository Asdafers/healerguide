//
//  HealerNavigationController.swift
//  HealerUIKit
//
//  Created by HealerKit on 2025-09-15.
//  Bridge for MainNavigationController to match test expectations
//

import UIKit
import DungeonKit

/// Type alias to bridge MainNavigationController with test expectations
public typealias HealerNavigationController = MainNavigationController

/// Type alias for split view controller tests
public typealias HealerSplitViewController = MainNavigationController

// MARK: - Protocol Extensions for Testing Compatibility

extension MainNavigationController {

    // MARK: - Test-Compatible Properties

    public var currentScreenForTesting: NavigationScreen {
        return currentScreen
    }

    public var navigationStackForTesting: [UIViewController] {
        return detailNavigationController.viewControllers
    }

    public var lastErrorForTesting: Error? {
        return lastError
    }

    public var dungeonListViewControllerForTesting: UIViewController? {
        return masterNavigationController.viewControllers.first
    }

    // MARK: - Split View Controller Properties for Testing

    public var masterViewController: UIViewController? {
        return viewControllers.first
    }

    public var detailViewController: UIViewController? {
        return viewControllers.count > 1 ? viewControllers[1] : nil
    }

    // MARK: - Gesture Recognition for Testing

    public override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        // Allow right swipe for back navigation
        if let swipeGesture = gestureRecognizer as? UISwipeGestureRecognizer {
            return swipeGesture.direction == .right && !navigationStackForTesting.isEmpty
        }

        // Allow edge pan gesture for interactive navigation
        if gestureRecognizer is UIScreenEdgePanGestureRecognizer {
            return !navigationStackForTesting.isEmpty
        }

        return super.gestureRecognizerShouldBegin(gestureRecognizer)
    }

    // MARK: - Interactive Pop Gesture for Testing

    public var interactivePopGestureRecognizer: UIScreenEdgePanGestureRecognizer? {
        // Return a configured edge pan gesture recognizer
        return view.gestureRecognizers?.compactMap { $0 as? UIScreenEdgePanGestureRecognizer }.first
    }
}

// MARK: - DungeonServiceProtocol Implementation

/// Protocol for dungeon data service
public protocol DungeonServiceProtocol {
    func getAllDungeons() -> [Dungeon]
    func getMockDungeon() -> Dungeon
}

// MARK: - Dungeon Entity Implementations

/// Concrete implementation of DungeonEntity for testing
public struct Dungeon: DungeonEntity {
    public let id: UUID
    public let name: String
    public let shortName: String
    public let difficultyLevel: String
    public let displayOrder: Int
    public let estimatedDuration: TimeInterval
    public let healerNotes: String?
    public let bossCount: Int
    public let seasonId: UUID
    public let bossEncounters: [BossEncounter]

    public init(id: UUID, name: String, seasonId: UUID, bossEncounters: [BossEncounter]) {
        self.id = id
        self.name = name
        self.seasonId = seasonId
        self.bossEncounters = bossEncounters

        // Set default values for protocol requirements
        self.shortName = String(name.prefix(10))
        self.difficultyLevel = "Mythic+"
        self.displayOrder = 0
        self.estimatedDuration = 1800 // 30 minutes
        self.healerNotes = nil
        self.bossCount = bossEncounters.count
    }
}

/// Concrete implementation of BossEncounterEntity for testing
public struct BossEncounter: BossEncounterEntity {
    public let id: UUID
    public let name: String
    public let encounterOrder: Int
    public let dungeonId: UUID
    public let abilities: [Ability]

    public init(id: UUID, name: String, abilities: [Ability]) {
        self.id = id
        self.name = name
        self.abilities = abilities

        // Set default values
        self.encounterOrder = 0
        self.dungeonId = UUID()
    }
}

/// Concrete implementation of AbilityEntity for testing
public struct Ability: AbilityEntity {
    public let id: UUID
    public let name: String
    public let bossEncounterId: UUID
    public let type: AbilityType
    public let targets: TargetType
    public let damageProfile: DamageProfile
    public let healerAction: String
    public let criticalInsight: String
    public let cooldown: TimeInterval?
    public let displayOrder: Int
    public let isKeyMechanic: Bool

    public init(id: UUID, name: String, bossEncounterId: UUID, healerAction: String) {
        self.id = id
        self.name = name
        self.bossEncounterId = bossEncounterId
        self.healerAction = healerAction

        // Set default values
        self.type = .damage
        self.targets = .group
        self.damageProfile = .moderate
        self.criticalInsight = "Monitor and respond as needed"
        self.cooldown = nil
        self.displayOrder = 0
        self.isKeyMechanic = false
    }
}

// MARK: - Shared Types
// AbilityType, TargetType, DamageProfile, and related classification enums are now provided by HealerKitCore
