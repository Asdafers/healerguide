//
//  SharedTypes.swift
//  HealerKitCore
//
//  Created by HealerKit on 2025-09-15.
//  Shared types and utilities used across all HealerKit libraries
//

import Foundation

// MARK: - Core Enums

/// Damage profile classification for healer priority and color coding
public enum DamageProfile: String, CaseIterable, Codable {
    case critical = "critical"      // Red - immediate action required
    case high = "high"             // Orange - significant concern
    case moderate = "moderate"     // Yellow - notable but manageable
    case mechanic = "mechanic"     // Blue - non-damage mechanic

    public var priority: Int {
        switch self {
        case .critical: return 4
        case .high: return 3
        case .moderate: return 2
        case .mechanic: return 1
        }
    }

    public var displayName: String {
        switch self {
        case .critical: return "Critical"
        case .high: return "High"
        case .moderate: return "Moderate"
        case .mechanic: return "Mechanic"
        }
    }

    public var accessibilityDescription: String {
        switch self {
        case .critical: return "Critical priority - immediate action required"
        case .high: return "High priority - prompt action needed"
        case .moderate: return "Moderate priority - standard healing response"
        case .mechanic: return "Mechanic - awareness and positioning focus"
        }
    }

    public var accessibilityPriority: String {
        switch self {
        case .critical: return "Critical"
        case .high: return "High"
        case .moderate: return "Moderate"
        case .mechanic: return "Mechanic"
        }
    }
}

/// Ability type classification for filtering and display
public enum AbilityType: String, CaseIterable, Codable {
    case damage = "damage"
    case heal = "heal"
    case mechanic = "mechanic"
    case movement = "movement"
    case interrupt = "interrupt"
    case dispel = "dispel"
    case positioning = "positioning"

    public var displayName: String {
        switch self {
        case .damage: return "Damage"
        case .heal: return "Heal"
        case .mechanic: return "Mechanic"
        case .movement: return "Movement"
        case .interrupt: return "Interrupt"
        case .dispel: return "Dispel"
        case .positioning: return "Positioning"
        }
    }

    public var iconName: String {
        switch self {
        case .damage: return "bolt.fill"
        case .heal: return "cross.fill"
        case .mechanic: return "gear.circle.fill"
        case .movement: return "arrow.triangle.2.circlepath"
        case .interrupt: return "stop.circle.fill"
        case .dispel: return "sparkles"
        case .positioning: return "location.circle.fill"
        }
    }
}

/// Target type for abilities
public enum TargetType: String, CaseIterable, Codable {
    case tank = "tank"
    case randomPlayer = "random_player"
    case group = "group"
    case healers = "healers"
    case location = "location"
    case selfTarget = "self"

    public var displayName: String {
        switch self {
        case .tank: return "Tank"
        case .randomPlayer: return "Random Player"
        case .group: return "Group"
        case .healers: return "Healers"
        case .location: return "Location"
        case .selfTarget: return "Boss Self"
        }
    }

    public var accessibilityDescription: String {
        switch self {
        case .tank: return "targets tank player"
        case .randomPlayer: return "targets random group member"
        case .group: return "affects entire group"
        case .healers: return "targets healing players"
        case .location: return "affects ground area"
        case .selfTarget: return "boss self-cast ability"
        }
    }
}

/// UI display hint for visual emphasis
public enum UIDisplayHint: String, CaseIterable, Codable {
    case highlight = "highlight"   // Prominent display
    case emphasize = "emphasize"   // Bold/larger text
    case standard = "standard"     // Normal display
    case muted = "muted"          // De-emphasized display

    public var visualWeight: CGFloat {
        switch self {
        case .highlight: return 1.0
        case .emphasize: return 0.8
        case .standard: return 0.6
        case .muted: return 0.4
        }
    }
}

/// Urgency level for ability response timing
public enum UrgencyLevel: Int, CaseIterable, Codable {
    case immediate = 4    // Must react within 1-2 seconds
    case high = 3        // React within 3-5 seconds
    case moderate = 2    // Can plan response (5-10 seconds)
    case low = 1         // Passive monitoring

    public var displayName: String {
        switch self {
        case .immediate: return "Immediate"
        case .high: return "High"
        case .moderate: return "Moderate"
        case .low: return "Low"
        }
    }

    public var responseTimeDescription: String {
        switch self {
        case .immediate: return "1-2 seconds"
        case .high: return "3-5 seconds"
        case .moderate: return "5-10 seconds"
        case .low: return "Monitor passively"
        }
    }
}

/// Complexity level for healer response
public enum ComplexityLevel: Int, CaseIterable, Codable {
    case simple = 1      // Single button press/target
    case moderate = 2    // Requires positioning + healing
    case complex = 3     // Multi-step response required
    case extreme = 4     // Coordination with team required

    public var displayName: String {
        switch self {
        case .simple: return "Simple"
        case .moderate: return "Moderate"
        case .complex: return "Complex"
        case .extreme: return "Extreme"
        }
    }
}

/// Impact level on encounter outcome
public enum ImpactLevel: Int, CaseIterable, Codable {
    case critical = 4    // Encounter-ending if mishandled
    case high = 3        // Significant damage/death risk
    case moderate = 2    // Manageable but notable impact
    case low = 1         // Minor impact on encounter

    public var displayName: String {
        switch self {
        case .critical: return "Critical"
        case .high: return "High"
        case .moderate: return "Moderate"
        case .low: return "Low"
        }
    }
}

// MARK: - Shared Structures

/// Color scheme for ability display
public struct AbilityColorScheme: Codable, Equatable {
    public let primaryColor: String    // Hex color for primary elements
    public let backgroundColor: String // Hex color for background
    public let textColor: String      // Hex color for text
    public let borderColor: String    // Hex color for borders

    public init(primaryColor: String, backgroundColor: String, textColor: String, borderColor: String) {
        self.primaryColor = primaryColor
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        self.borderColor = borderColor
    }
}

/// Ability classification result
public struct AbilityClassification: Codable, Equatable {
    public let urgency: UrgencyLevel
    public let complexity: ComplexityLevel
    public let healerImpact: ImpactLevel
    public let recommendedPreparation: String

    public init(urgency: UrgencyLevel, complexity: ComplexityLevel, healerImpact: ImpactLevel, recommendedPreparation: String) {
        self.urgency = urgency
        self.complexity = complexity
        self.healerImpact = healerImpact
        self.recommendedPreparation = recommendedPreparation
    }
}

/// Healer action recommendation
public struct HealerAction: Codable, Equatable {
    public let actionType: HealerActionType
    public let timing: ActionTiming
    public let description: String
    public let keyBindSuggestion: String?

    public init(actionType: HealerActionType, timing: ActionTiming, description: String, keyBindSuggestion: String?) {
        self.actionType = actionType
        self.timing = timing
        self.description = description
        self.keyBindSuggestion = keyBindSuggestion
    }
}

/// Healer action type enumeration
public enum HealerActionType: String, CaseIterable, Codable {
    case preHeal = "pre_heal"
    case reactiveHeal = "reactive_heal"
    case cooldownUse = "cooldown_use"
    case positioning = "positioning"
    case dispel = "dispel"
    case interrupt = "interrupt"

    public var displayName: String {
        switch self {
        case .preHeal: return "Pre-heal"
        case .reactiveHeal: return "Reactive Heal"
        case .cooldownUse: return "Use Cooldown"
        case .positioning: return "Position"
        case .dispel: return "Dispel"
        case .interrupt: return "Interrupt"
        }
    }
}

/// Action timing specification
public enum ActionTiming: String, CaseIterable, Codable {
    case immediate = "immediate"    // <1 second
    case fast = "fast"             // 1-3 seconds
    case planned = "planned"       // 3+ seconds advance notice

    public var displayName: String {
        switch self {
        case .immediate: return "Immediate"
        case .fast: return "Fast"
        case .planned: return "Planned"
        }
    }
}

// MARK: - Extensions

extension DamageProfile {
    /// Get iPad-optimized color scheme for this damage profile
    public var colorScheme: AbilityColorScheme {
        switch self {
        case .critical:
            return AbilityColorScheme(
                primaryColor: "#FF6B6B",
                backgroundColor: "#FFF5F5",
                textColor: "#B91C1C",
                borderColor: "#DC2626"
            )
        case .high:
            return AbilityColorScheme(
                primaryColor: "#F59E0B",
                backgroundColor: "#FFFBEB",
                textColor: "#B45309",
                borderColor: "#D97706"
            )
        case .moderate:
            return AbilityColorScheme(
                primaryColor: "#EAB308",
                backgroundColor: "#FEFCE8",
                textColor: "#A16207",
                borderColor: "#CA8A04"
            )
        case .mechanic:
            return AbilityColorScheme(
                primaryColor: "#3B82F6",
                backgroundColor: "#EFF6FF",
                textColor: "#1E40AF",
                borderColor: "#2563EB"
            )
        }
    }

    /// High contrast color scheme for accessibility
    public var highContrastColorScheme: AbilityColorScheme {
        switch self {
        case .critical:
            return AbilityColorScheme(
                primaryColor: "#DC143C",
                backgroundColor: "#FFFFFF",
                textColor: "#8B0000",
                borderColor: "#B22222"
            )
        case .high:
            return AbilityColorScheme(
                primaryColor: "#FF8C00",
                backgroundColor: "#FFFAF0",
                textColor: "#CC6600",
                borderColor: "#FF7F00"
            )
        case .moderate:
            return AbilityColorScheme(
                primaryColor: "#FFD700",
                backgroundColor: "#FFFFF0",
                textColor: "#B8860B",
                borderColor: "#DAA520"
            )
        case .mechanic:
            return AbilityColorScheme(
                primaryColor: "#0000FF",
                backgroundColor: "#F0F8FF",
                textColor: "#000080",
                borderColor: "#4169E1"
            )
        }
    }
}

// MARK: - Utility Extensions

#if canImport(UIKit)
import UIKit

extension UIColor {
    /// Initialize UIColor from hex string
    public convenience init?(hex: String) {
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
#endif

// MARK: - Performance Utilities

/// Memory usage tracking for iPad Pro optimization
public struct MemoryUsageStats: Codable {
    public let totalCacheSize: Int64      // bytes
    public let entityCount: Int
    public let lastCacheClean: Date
    public let recommendedAction: CacheAction?

    public init(totalCacheSize: Int64, entityCount: Int, lastCacheClean: Date, recommendedAction: CacheAction?) {
        self.totalCacheSize = totalCacheSize
        self.entityCount = entityCount
        self.lastCacheClean = lastCacheClean
        self.recommendedAction = recommendedAction
    }
}

/// Cache management actions for memory pressure
public enum CacheAction: String, CaseIterable, Codable {
    case none
    case clearOldEntries
    case fullClear

    public var displayName: String {
        switch self {
        case .none: return "No Action Needed"
        case .clearOldEntries: return "Clear Old Entries"
        case .fullClear: return "Full Cache Clear"
        }
    }
}

// MARK: - Error Handling

/// Base error protocol for HealerKit libraries
public protocol HealerKitError: LocalizedError {
    var category: ErrorCategory { get }
    var severity: ErrorSeverity { get }
}

/// Error category classification
public enum ErrorCategory: String, CaseIterable {
    case dataAccess = "data_access"
    case validation = "validation"
    case performance = "performance"
    case ui = "ui"
    case network = "network"
}

/// Error severity levels
public enum ErrorSeverity: Int, CaseIterable {
    case low = 1
    case medium = 2
    case high = 3
    case critical = 4

    public var displayName: String {
        switch self {
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        case .critical: return "Critical"
        }
    }
}

// MARK: - Constants

/// iPad Pro (1st generation) specifications and constraints
public enum IPadProFirstGenSpec {
    public static let maxMemoryUsage: Int64 = 512 * 1024 * 1024  // 512MB
    public static let targetFrameRate: Int = 60
    public static let maxFrameTime: Double = 16.67  // milliseconds
    public static let maxLoadTime: Double = 3.0     // seconds
    public static let screenWidth: CGFloat = 1024
    public static let screenHeight: CGFloat = 768
    public static let minimumTouchTarget: CGFloat = 44.0
    public static let recommendedTouchTarget: CGFloat = 48.0
}

/// Color accessibility constants
public enum AccessibilityColor {
    public static let minimumContrastRatio: Double = 4.5  // WCAG AA
    public static let preferredContrastRatio: Double = 7.0  // WCAG AAA
    public static let largeTextMinimumRatio: Double = 3.0   // WCAG AA Large
}