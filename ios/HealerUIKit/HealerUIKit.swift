//
//  HealerUIKit.swift
//  HealerUIKit
//
//  Created by HealerKit on 2025-09-14.
//

import UIKit
import AbilityKit

/// HealerUIKit - Framework for iPad-optimized UI components
/// Provides reusable UI components optimized for healer workflows on iPad
public final class HealerUIKit: HealerDisplayProviding {

    /// Shared instance
    public static let shared = HealerUIKit()

    private init() {}

    /// Framework version
    public static let version = "1.0.0"

    // MARK: - HealerDisplayProviding Implementation

    /// Render dungeon list optimized for iPad screen and touch
    public func createDungeonListView(dungeons: [any DungeonEntity]) throws -> UIViewController {
        let controller = DungeonListViewController()
        controller.dungeons = dungeons
        return controller
    }

    /// Render boss encounter detail with healer summary and abilities
    public func createBossEncounterView(encounter: any BossEncounterEntity, abilities: [any AbilityEntity]) throws -> UIViewController {
        let controller = BossEncounterViewController(encounter: encounter, abilities: abilities)
        return controller
    }

    /// Render search interface optimized for iPad keyboard and touch
    public func createSearchView(delegate: SearchDelegate?) throws -> UIViewController {
        // Create a basic search view controller for now
        let controller = UIViewController()
        controller.title = "Search"
        controller.view.backgroundColor = .systemBackground

        // Add a label indicating this is a placeholder
        let label = UILabel()
        label.text = "Search functionality\n(To be implemented)"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        controller.view.addSubview(label)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: controller.view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: controller.view.centerYAnchor)
        ])

        return controller
    }

    /// Render settings/preferences for healer customization
    public func createSettingsView() throws -> UIViewController {
        // Create a basic settings view controller for now
        let controller = UIViewController()
        controller.title = "Settings"
        controller.view.backgroundColor = .systemBackground

        // Add a label indicating this is a placeholder
        let label = UILabel()
        label.text = "Settings panel\n(To be implemented)"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        controller.view.addSubview(label)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: controller.view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: controller.view.centerYAnchor)
        ])

        return controller
    }
}

// MARK: - Contract Protocols for TDD

/// Main contract interface for healer-focused UI components
public protocol HealerDisplayProviding {
    /// Render dungeon list optimized for iPad screen and touch
    func createDungeonListView(dungeons: [any DungeonEntity]) throws -> UIViewController

    /// Render boss encounter detail with healer summary and abilities
    func createBossEncounterView(encounter: any BossEncounterEntity, abilities: [any AbilityEntity]) throws -> UIViewController

    /// Render search interface optimized for iPad keyboard and touch
    func createSearchView(delegate: SearchDelegate?) throws -> UIViewController

    /// Render settings/preferences for healer customization
    func createSettingsView() throws -> UIViewController
}

/// Search delegate protocol for handling search interactions
public protocol SearchDelegate: AnyObject {
    func searchDidUpdate(query: String)
    func searchDidSelectDungeon(_ dungeon: any DungeonEntity)
    func searchDidSelectBoss(_ boss: any BossEncounterEntity)
    func searchDidSelectAbility(_ ability: any AbilityEntity)
}

// MARK: - Entity Protocols for Contract Testing

/// Protocol for dungeon entities used in contract
public protocol DungeonEntity {
    var id: UUID { get }
    var name: String { get }
    var shortName: String { get }
    var difficultyLevel: String { get }
    var displayOrder: Int { get }
    var estimatedDuration: TimeInterval { get }
    var healerNotes: String? { get }
    var bossCount: Int { get }
}

/// Protocol for boss encounter entities used in contract
public protocol BossEncounterEntity {
    var id: UUID { get }
    var name: String { get }
    var encounterOrder: Int { get }
    var dungeonId: UUID { get }
}

/// Protocol for ability entities used in contract
public protocol AbilityEntity {
    var id: UUID { get }
    var name: String { get }
    var bossEncounterId: UUID { get }
}

// MARK: - AbilityCardView Protocol

/// Protocol for ability card views with color-coded damage profiles
public protocol AbilityCardViewProtocol: UIView {
    var ability: AbilityEntity { get set }
    var classification: AbilityClassification { get set }
    var delegate: AbilityCardDelegate? { get set }

    func updateDisplayMode(_ mode: AbilityDisplayMode)
    func animateAttention()
}

/// Delegate protocol for ability card interactions
public protocol AbilityCardDelegate: AnyObject {
    func abilityCardDidTap(_ ability: AbilityEntity)
    func abilityCardDidRequestDetails(_ ability: AbilityEntity)
    func abilityCardDidLongPress(_ ability: AbilityEntity)
}

/// Display modes for ability cards
public enum AbilityDisplayMode {
    case full       // Complete information display
    case compact    // Condensed for list views
    case minimal    // Name and damage profile only
}