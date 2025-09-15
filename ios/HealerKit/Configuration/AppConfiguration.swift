//
//  AppConfiguration.swift
//  HealerKit
//
//  App configuration and settings for iPad Pro healer interface
//  Optimized for readability and accessibility on first-generation iPad Pro
//

import UIKit
import Foundation

/// Configuration manager for HealerKit app settings
/// Provides typography, color schemes, layout settings, and accessibility configuration
public final class AppConfiguration {

    // MARK: - Singleton

    public static let shared = AppConfiguration()

    // MARK: - Typography Settings

    /// Typography configuration optimized for iPad readability
    public struct Typography {

        /// Font sizes optimized for iPad reading distances
        public enum FontSize {
            /// Ability names - 18pt+ for quick recognition
            public static let abilityName: CGFloat = 20.0

            /// Healer actions - 16pt+ for detailed instructions
            public static let healerAction: CGFloat = 18.0

            /// Critical insights - emphasized for importance
            public static let criticalInsight: CGFloat = 16.0

            /// Boss encounter titles
            public static let encounterTitle: CGFloat = 24.0

            /// Dungeon names
            public static let dungeonName: CGFloat = 22.0

            /// Secondary text (cooldowns, targets)
            public static let secondaryText: CGFloat = 14.0

            /// Navigation titles
            public static let navigationTitle: CGFloat = 28.0

            /// Section headers
            public static let sectionHeader: CGFloat = 16.0
        }

        /// Font weights for hierarchical content
        public enum FontWeight {
            public static let abilityName: UIFont.Weight = .semibold
            public static let healerAction: UIFont.Weight = .medium
            public static let criticalInsight: UIFont.Weight = .bold
            public static let encounterTitle: UIFont.Weight = .bold
            public static let dungeonName: UIFont.Weight = .semibold
            public static let secondaryText: UIFont.Weight = .regular
            public static let navigationTitle: UIFont.Weight = .bold
            public static let sectionHeader: UIFont.Weight = .semibold
        }

        /// Line spacing for optimal readability
        public enum LineSpacing {
            public static let abilityCard: CGFloat = 4.0
            public static let healerAction: CGFloat = 6.0
            public static let criticalInsight: CGFloat = 4.0
            public static let paragraph: CGFloat = 8.0
        }
    }

    // MARK: - Color Schemes

    /// Color configuration for damage profiles and UI elements
    public struct Colors {

        /// Damage profile color coding for quick recognition
        public enum DamageProfile {
            /// Critical damage - immediate action required
            public static let critical = UIColor.systemRed

            /// High damage - priority healing
            public static let high = UIColor.systemOrange

            /// Moderate damage - standard healing
            public static let moderate = UIColor.systemYellow

            /// Mechanic - positional/utility response
            public static let mechanic = UIColor.systemBlue

            /// Get color for damage profile string
            /// - Parameter profile: Damage profile identifier
            /// - Returns: Corresponding color
            public static func color(for profile: String) -> UIColor {
                switch profile.lowercased() {
                case "critical":
                    return critical
                case "high":
                    return high
                case "moderate":
                    return moderate
                case "mechanic":
                    return mechanic
                default:
                    return UIColor.systemGray
                }
            }
        }

        /// Background colors optimized for extended use
        public enum Background {
            public static let primary = UIColor.systemBackground
            public static let secondary = UIColor.secondarySystemBackground
            public static let tertiary = UIColor.tertiarySystemBackground
            public static let abilityCard = UIColor.secondarySystemGroupedBackground
            public static let criticalAbilityCard = UIColor.systemRed.withAlphaComponent(0.1)
        }

        /// Text colors with proper contrast ratios
        public enum Text {
            public static let primary = UIColor.label
            public static let secondary = UIColor.secondaryLabel
            public static let tertiary = UIColor.tertiaryLabel
            public static let critical = UIColor.systemRed
            public static let warning = UIColor.systemOrange
            public static let success = UIColor.systemGreen
            public static let onDark = UIColor.white
        }

        /// Interactive element colors
        public enum Interactive {
            public static let tint = UIColor.systemBlue
            public static let buttonBackground = UIColor.systemBlue
            public static let buttonText = UIColor.white
            public static let selectedBackground = UIColor.systemBlue.withAlphaComponent(0.2)
            public static let highlightBackground = UIColor.systemGray5
        }

        /// Border and separator colors
        public enum Border {
            public static let light = UIColor.separator
            public static let medium = UIColor.opaqueSeparator
            public static let abilityCard = UIColor.systemGray4
            public static let criticalAbilityCard = UIColor.systemRed.withAlphaComponent(0.3)
        }
    }

    // MARK: - Layout Settings

    /// Layout configuration for iPad orientations and touch targets
    public struct Layout {

        /// Touch target sizes for iPad interaction
        public enum TouchTarget {
            /// Minimum touch target size - 44pt Apple guideline
            public static let minimum: CGFloat = 44.0

            /// Preferred touch target for primary actions
            public static let preferred: CGFloat = 56.0

            /// Large touch target for accessibility
            public static let large: CGFloat = 64.0
        }

        /// Spacing and margins optimized for iPad
        public enum Spacing {
            public static let extraSmall: CGFloat = 4.0
            public static let small: CGFloat = 8.0
            public static let medium: CGFloat = 16.0
            public static let large: CGFloat = 24.0
            public static let extraLarge: CGFloat = 32.0

            /// Ability card internal padding
            public static let abilityCardPadding: CGFloat = 16.0

            /// Section spacing
            public static let sectionSpacing: CGFloat = 24.0

            /// Content margins for readability zones
            public static let contentMargin: CGFloat = 20.0

            /// Safe area padding for navigation
            public static let safeAreaPadding: CGFloat = 16.0
        }

        /// Corner radius values for consistent UI
        public enum CornerRadius {
            public static let small: CGFloat = 8.0
            public static let medium: CGFloat = 12.0
            public static let large: CGFloat = 16.0
            public static let abilityCard: CGFloat = 12.0
            public static let button: CGFloat = 8.0
        }

        /// Border widths for visual hierarchy
        public enum BorderWidth {
            public static let thin: CGFloat = 0.5
            public static let standard: CGFloat = 1.0
            public static let thick: CGFloat = 2.0
            public static let abilityCard: CGFloat = 1.0
            public static let criticalAbilityCard: CGFloat = 2.0
        }

        /// Animation durations for smooth interactions
        public enum AnimationDuration {
            public static let fast: TimeInterval = 0.2
            public static let standard: TimeInterval = 0.3
            public static let slow: TimeInterval = 0.5
            public static let cardTransition: TimeInterval = 0.25
            public static let navigationTransition: TimeInterval = 0.35
        }
    }

    // MARK: - Accessibility Settings

    /// Accessibility configuration for inclusive design
    public struct Accessibility {

        /// VoiceOver labels and hints
        public enum VoiceOver {
            public static let abilityCardHint = "Double tap to view detailed healing information"
            public static let criticalAbilityHint = "Critical ability requiring immediate action"
            public static let dungeonSelectionHint = "Double tap to view dungeon encounters"
            public static let backButtonLabel = "Back to previous screen"
            public static let closeButtonLabel = "Close current view"
        }

        /// Dynamic Type scaling factors
        public enum DynamicType {
            /// Maximum scale factor for readability without breaking layout
            public static let maximumScaleFactor: CGFloat = 1.5

            /// Minimum scale factor to maintain usability
            public static let minimumScaleFactor: CGFloat = 0.8

            /// Check if large text sizes are enabled
            public static var isLargeTextEnabled: Bool {
                return UIApplication.shared.preferredContentSizeCategory.isAccessibilityCategory
            }

            /// Get scaled font size for content size category
            /// - Parameter baseSize: Base font size
            /// - Returns: Scaled font size
            public static func scaledFontSize(_ baseSize: CGFloat) -> CGFloat {
                let scaleFactor = min(maximumScaleFactor, max(minimumScaleFactor,
                    UIFontMetrics.default.scaledValue(for: baseSize) / baseSize))
                return baseSize * scaleFactor
            }
        }

        /// High contrast mode support
        public enum HighContrast {
            /// Check if high contrast is enabled
            public static var isEnabled: Bool {
                return UIAccessibility.isDarkerSystemColorsEnabled
            }

            /// Enhanced colors for high contrast mode
            public static let enhancedTextColor = UIColor.label
            public static let enhancedBackgroundColor = UIColor.systemBackground
            public static let enhancedBorderColor = UIColor.label

            /// Minimum contrast ratio for text readability
            public static let minimumContrastRatio: Double = 4.5
        }

        /// Reduced motion settings
        public enum ReducedMotion {
            /// Check if reduced motion is enabled
            public static var isEnabled: Bool {
                return UIAccessibility.isReduceMotionEnabled
            }

            /// Animation duration when reduced motion is enabled
            public static let reducedAnimationDuration: TimeInterval = 0.1

            /// Get appropriate animation duration based on accessibility settings
            /// - Parameter standardDuration: Standard animation duration
            /// - Returns: Accessibility-appropriate duration
            public static func animationDuration(_ standardDuration: TimeInterval) -> TimeInterval {
                return isEnabled ? reducedAnimationDuration : standardDuration
            }
        }
    }

    // MARK: - Device Optimization

    /// Device-specific optimizations for first-generation iPad Pro
    public struct DeviceOptimization {

        /// Screen dimensions and safe areas
        public enum Screen {
            /// iPad Pro 12.9" first generation dimensions
            public static let iPadProWidth: CGFloat = 1024.0
            public static let iPadProHeight: CGFloat = 1366.0

            /// Optimal content width for reading
            public static let optimalReadingWidth: CGFloat = 680.0

            /// Check if device is iPad Pro
            public static var isIPadPro: Bool {
                let screenSize = UIScreen.main.bounds.size
                return max(screenSize.width, screenSize.height) >= iPadProHeight
            }
        }

        /// Memory optimization settings for 4GB RAM
        public enum Memory {
            /// Maximum cached ability cards
            public static let maxCachedAbilityCards = 50

            /// Maximum cached images
            public static let maxCachedImages = 20

            /// Memory warning threshold (MB)
            public static let memoryWarningThreshold = 512

            /// Low memory cleanup interval (seconds)
            public static let cleanupInterval: TimeInterval = 30.0
        }

        /// Performance settings for A9X processor
        public enum Performance {
            /// Target frame rate
            public static let targetFrameRate = 60

            /// Maximum concurrent background operations
            public static let maxConcurrentOperations = 2

            /// Image loading queue priority
            public static let imageLoadingQoS = DispatchQoS.userInitiated

            /// Data processing queue priority
            public static let dataProcessingQoS = DispatchQoS.userInteractive
        }
    }

    // MARK: - Initialization

    private init() {
        setupAccessibilityObservers()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Public Methods

    /// Get font for specific content type with Dynamic Type support
    /// - Parameters:
    ///   - type: Content type requiring font
    ///   - textStyle: UIFont.TextStyle for Dynamic Type
    /// - Returns: Configured font
    public func font(for type: ContentType, textStyle: UIFont.TextStyle = .body) -> UIFont {
        let baseSize: CGFloat
        let weight: UIFont.Weight

        switch type {
        case .abilityName:
            baseSize = Typography.FontSize.abilityName
            weight = Typography.FontWeight.abilityName
        case .healerAction:
            baseSize = Typography.FontSize.healerAction
            weight = Typography.FontWeight.healerAction
        case .criticalInsight:
            baseSize = Typography.FontSize.criticalInsight
            weight = Typography.FontWeight.criticalInsight
        case .encounterTitle:
            baseSize = Typography.FontSize.encounterTitle
            weight = Typography.FontWeight.encounterTitle
        case .dungeonName:
            baseSize = Typography.FontSize.dungeonName
            weight = Typography.FontWeight.dungeonName
        case .secondaryText:
            baseSize = Typography.FontSize.secondaryText
            weight = Typography.FontWeight.secondaryText
        case .navigationTitle:
            baseSize = Typography.FontSize.navigationTitle
            weight = Typography.FontWeight.navigationTitle
        case .sectionHeader:
            baseSize = Typography.FontSize.sectionHeader
            weight = Typography.FontWeight.sectionHeader
        }

        let scaledSize = Accessibility.DynamicType.scaledFontSize(baseSize)
        return UIFont.systemFont(ofSize: scaledSize, weight: weight)
    }

    /// Get color with high contrast support
    /// - Parameter colorType: Type of color needed
    /// - Returns: Color with accessibility considerations
    public func color(for colorType: ColorType) -> UIColor {
        if Accessibility.HighContrast.isEnabled {
            return enhancedColor(for: colorType)
        }
        return standardColor(for: colorType)
    }

    /// Get animation duration with reduced motion support
    /// - Parameter durationType: Type of animation
    /// - Returns: Appropriate animation duration
    public func animationDuration(for durationType: AnimationType) -> TimeInterval {
        let standardDuration: TimeInterval

        switch durationType {
        case .cardTransition:
            standardDuration = Layout.AnimationDuration.cardTransition
        case .navigation:
            standardDuration = Layout.AnimationDuration.navigationTransition
        case .fast:
            standardDuration = Layout.AnimationDuration.fast
        case .standard:
            standardDuration = Layout.AnimationDuration.standard
        case .slow:
            standardDuration = Layout.AnimationDuration.slow
        }

        return Accessibility.ReducedMotion.animationDuration(standardDuration)
    }

    // MARK: - Private Methods

    private func setupAccessibilityObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(accessibilitySettingsChanged),
            name: UIContentSizeCategory.didChangeNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(accessibilitySettingsChanged),
            name: UIAccessibility.darkerSystemColorsStatusDidChangeNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(accessibilitySettingsChanged),
            name: UIAccessibility.reduceMotionStatusDidChangeNotification,
            object: nil
        )
    }

    @objc private func accessibilitySettingsChanged() {
        // Notify the app that accessibility settings changed
        NotificationCenter.default.post(
            name: .HealerKitAccessibilitySettingsChanged,
            object: self
        )
    }

    private func standardColor(for colorType: ColorType) -> UIColor {
        switch colorType {
        case .damageProfile(let profile):
            return Colors.DamageProfile.color(for: profile)
        case .background(let type):
            return backgroundColorForType(type)
        case .text(let type):
            return textColorForType(type)
        case .interactive(let type):
            return interactiveColorForType(type)
        case .border(let type):
            return borderColorForType(type)
        }
    }

    private func enhancedColor(for colorType: ColorType) -> UIColor {
        // Return high contrast versions of colors
        switch colorType {
        case .text:
            return Accessibility.HighContrast.enhancedTextColor
        case .background:
            return Accessibility.HighContrast.enhancedBackgroundColor
        case .border:
            return Accessibility.HighContrast.enhancedBorderColor
        default:
            return standardColor(for: colorType)
        }
    }

    // Helper methods for color resolution
    private func backgroundColorForType(_ type: String) -> UIColor {
        switch type {
        case "primary": return Colors.Background.primary
        case "secondary": return Colors.Background.secondary
        case "tertiary": return Colors.Background.tertiary
        case "abilityCard": return Colors.Background.abilityCard
        case "criticalAbilityCard": return Colors.Background.criticalAbilityCard
        default: return Colors.Background.primary
        }
    }

    private func textColorForType(_ type: String) -> UIColor {
        switch type {
        case "primary": return Colors.Text.primary
        case "secondary": return Colors.Text.secondary
        case "tertiary": return Colors.Text.tertiary
        case "critical": return Colors.Text.critical
        case "warning": return Colors.Text.warning
        case "success": return Colors.Text.success
        case "onDark": return Colors.Text.onDark
        default: return Colors.Text.primary
        }
    }

    private func interactiveColorForType(_ type: String) -> UIColor {
        switch type {
        case "tint": return Colors.Interactive.tint
        case "buttonBackground": return Colors.Interactive.buttonBackground
        case "buttonText": return Colors.Interactive.buttonText
        case "selectedBackground": return Colors.Interactive.selectedBackground
        case "highlightBackground": return Colors.Interactive.highlightBackground
        default: return Colors.Interactive.tint
        }
    }

    private func borderColorForType(_ type: String) -> UIColor {
        switch type {
        case "light": return Colors.Border.light
        case "medium": return Colors.Border.medium
        case "abilityCard": return Colors.Border.abilityCard
        case "criticalAbilityCard": return Colors.Border.criticalAbilityCard
        default: return Colors.Border.light
        }
    }
}

// MARK: - Enums for Type Safety

public enum ContentType {
    case abilityName
    case healerAction
    case criticalInsight
    case encounterTitle
    case dungeonName
    case secondaryText
    case navigationTitle
    case sectionHeader
}

public enum ColorType {
    case damageProfile(String)
    case background(String)
    case text(String)
    case interactive(String)
    case border(String)
}

public enum AnimationType {
    case cardTransition
    case navigation
    case fast
    case standard
    case slow
}

// MARK: - Notifications

extension Notification.Name {
    public static let HealerKitAccessibilitySettingsChanged = Notification.Name("HealerKitAccessibilitySettingsChanged")
}