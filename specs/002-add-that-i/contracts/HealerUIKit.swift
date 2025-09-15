// HealerUIKit Library Contract
// iPad-optimized UI components for healer-focused encounter display

import Foundation
import UIKit
import SwiftUI

// MARK: - Public Interface

protocol HealerDisplayProviding {
    /// Render dungeon list optimized for iPad screen and touch
    func createDungeonListView(dungeons: [DungeonEntity]) -> UIViewController

    /// Render boss encounter detail with healer summary and abilities
    func createBossEncounterView(encounter: BossEncounterEntity, abilities: [AbilityEntity]) -> UIViewController

    /// Render search interface optimized for iPad keyboard and touch
    func createSearchView(delegate: SearchDelegate) -> UIViewController

    /// Render settings/preferences for healer customization
    func createSettingsView() -> UIViewController
}

protocol AbilityCardProviding {
    /// Create color-coded ability card for tablet display
    func createAbilityCard(ability: AbilityEntity, classification: AbilityClassification) -> UIView

    /// Create compact ability row for list displays
    func createAbilityRow(ability: AbilityEntity) -> UIView

    /// Create key mechanics summary card
    func createKeyMechanicsCard(mechanics: [AbilityEntity]) -> UIView
}

protocol NavigationProviding {
    /// iPad-optimized navigation controller with proper split view support
    func createMainNavigationController() -> UISplitViewController

    /// Breadcrumb navigation for deep linking between encounters
    func createBreadcrumbNavigation(path: NavigationPath) -> UIView

    /// Quick action toolbar for common healer tasks
    func createQuickActionToolbar(actions: [QuickAction]) -> UIToolbar
}

protocol SearchDelegate: AnyObject {
    func searchDidUpdate(query: String)
    func searchDidSelectDungeon(_ dungeon: DungeonEntity)
    func searchDidSelectBoss(_ boss: BossEncounterEntity)
    func searchDidSelectAbility(_ ability: AbilityEntity)
}

// MARK: - Data Transfer Objects

struct NavigationPath {
    let season: String
    let dungeon: String?
    let boss: String?
}

struct QuickAction {
    let identifier: String
    let title: String
    let icon: UIImage?
    let action: () -> Void
}

// MARK: - UI Configuration

protocol HealerUIConfiguration {
    /// Get iPad-optimized typography settings
    var typography: TypographySettings { get }

    /// Get color scheme for damage profile visualization
    var colorScheme: HealerColorScheme { get }

    /// Get layout settings for various iPad orientations
    var layout: LayoutSettings { get }

    /// Get accessibility settings for healer-focused usage
    var accessibility: AccessibilitySettings { get }
}

struct TypographySettings {
    let dungeonNameFont: UIFont
    let bossNameFont: UIFont
    let abilityNameFont: UIFont
    let healerActionFont: UIFont
    let insightFont: UIFont
    let summaryFont: UIFont

    // Dynamic type support for accessibility
    let supportsDynamicType: Bool
    let maximumPointSize: CGFloat    // For gameplay readability
    let minimumPointSize: CGFloat
}

struct HealerColorScheme {
    // Damage profile colors optimized for iPad display
    let criticalDamageColor: UIColor     // High contrast red
    let highDamageColor: UIColor         // Orange
    let moderateDamageColor: UIColor     // Yellow
    let mechanicColor: UIColor           // Blue

    // Background colors for readability
    let primaryBackgroundColor: UIColor
    let secondaryBackgroundColor: UIColor
    let cardBackgroundColor: UIColor

    // Text colors for various contexts
    let primaryTextColor: UIColor
    let secondaryTextColor: UIColor
    let accentTextColor: UIColor

    // Interactive element colors
    let buttonTintColor: UIColor
    let selectionColor: UIColor
    let separatorColor: UIColor
}

struct LayoutSettings {
    // iPad-specific spacing and sizing
    let cardCornerRadius: CGFloat
    let standardMargin: CGFloat
    let compactMargin: CGFloat
    let minimumTouchTarget: CGFloat      // 44pt minimum for accessibility

    // Grid and list configurations
    let dungeonGridColumns: Int          // Varies by orientation
    let abilityCardMinimumWidth: CGFloat
    let maximumContentWidth: CGFloat     // For readability on large screens

    // Split view configurations
    let masterViewMinimumWidth: CGFloat
    let detailViewMinimumWidth: CGFloat
}

struct AccessibilitySettings {
    let supportsDarkMode: Bool
    let supportsHighContrast: Bool
    let supportsLargeText: Bool
    let supportsVoiceOver: Bool
    let supportsReduceMotion: Bool

    // Healer-specific accessibility features
    let colorBlindFriendlyMode: Bool     // Alternative to color coding
    let simplifiedUIMode: Bool           // Reduced visual complexity
    let hapticFeedbackEnabled: Bool      // For critical ability alerts
}

// MARK: - View Controllers

protocol DungeonListViewControllerProtocol: UIViewController {
    var dungeons: [DungeonEntity] { get set }
    var delegate: DungeonListDelegate? { get set }

    func refreshDungeonData()
    func selectDungeon(_ dungeon: DungeonEntity)
    func updateLayout(for orientation: UIInterfaceOrientation)
}

protocol DungeonListDelegate: AnyObject {
    func dungeonListDidSelectDungeon(_ dungeon: DungeonEntity)
    func dungeonListDidRequestRefresh()
    func dungeonListDidRequestSearch()
}

protocol BossEncounterViewControllerProtocol: UIViewController {
    var encounter: BossEncounterEntity { get set }
    var abilities: [AbilityEntity] { get set }
    var delegate: BossEncounterDelegate? { get set }

    func updateAbilities(_ abilities: [AbilityEntity])
    func highlightAbility(_ abilityId: UUID)
    func filterAbilities(by damageProfile: DamageProfile?)
}

protocol BossEncounterDelegate: AnyObject {
    func bossEncounterDidSelectAbility(_ ability: AbilityEntity)
    func bossEncounterDidRequestAbilityDetails(_ ability: AbilityEntity)
    func bossEncounterDidToggleFilter(_ damageProfile: DamageProfile?)
}

// MARK: - Custom Views

protocol AbilityCardViewProtocol: UIView {
    var ability: AbilityEntity { get set }
    var classification: AbilityClassification { get set }
    var delegate: AbilityCardDelegate? { get set }

    func updateDisplayMode(_ mode: AbilityDisplayMode)
    func animateAttention()  // For critical abilities
}

protocol AbilityCardDelegate: AnyObject {
    func abilityCardDidTap(_ ability: AbilityEntity)
    func abilityCardDidRequestDetails(_ ability: AbilityEntity)
    func abilityCardDidLongPress(_ ability: AbilityEntity)
}

enum AbilityDisplayMode {
    case full       // Complete information display
    case compact    // Condensed for list views
    case minimal    // Name and damage profile only
}

// MARK: - Performance Optimization

protocol HealerUIPerformance {
    /// Optimize view rendering for first-generation iPad Pro
    func optimizeForHardware()

    /// Preload and cache commonly used views
    func preloadViewComponents()

    /// Clean up views and free memory during low memory conditions
    func handleMemoryPressure()

    /// Get performance metrics for UI responsiveness
    func getPerformanceMetrics() -> UIPerformanceMetrics
}

struct UIPerformanceMetrics {
    let averageFrameRate: Double
    let memoryUsage: Int64
    let viewCacheSize: Int
    let lastOptimization: Date
    let recommendedActions: [PerformanceAction]
}

enum PerformanceAction {
    case reduceViewComplexity
    case clearViewCache
    case simplifyAnimations
    case enableLowPowerMode
}

// MARK: - Error Handling

enum HealerUIError: LocalizedError {
    case viewControllerCreationFailed(String)
    case layoutConstraintConflict(String)
    case performanceThresholdExceeded(String)
    case accessibilityConfigurationError(String)

    var errorDescription: String? {
        switch self {
        case .viewControllerCreationFailed(let details):
            return "Failed to create view controller: \(details)"
        case .layoutConstraintConflict(let details):
            return "Layout constraint conflict: \(details)"
        case .performanceThresholdExceeded(let details):
            return "Performance threshold exceeded: \(details)"
        case .accessibilityConfigurationError(let details):
            return "Accessibility configuration error: \(details)"
        }
    }
}

// MARK: - CLI Interface

protocol HealerUIKitCLI {
    /// Test UI component rendering performance
    /// Usage: healeruikit benchmark --component ability-card --iterations 100
    func benchmarkComponent(component: String, iterations: Int) async -> CLIResult

    /// Validate UI layouts for different iPad orientations
    /// Usage: healeruikit validate-layouts --device ipad-pro-gen1
    func validateLayouts(device: String) async -> CLIResult

    /// Generate accessibility report
    /// Usage: healeruikit accessibility-audit --output report.json
    func auditAccessibility(outputFile: URL?) async -> CLIResult

    /// Test color contrast ratios for damage profiles
    /// Usage: healeruikit test-colors --standard wcag-aa
    func testColorContrast(standard: String) async -> CLIResult
}

struct CLIResult {
    let success: Bool
    let output: String
    let errorDetails: String?
}

// MARK: - SwiftUI Integration

protocol SwiftUIBridging {
    /// Bridge UIKit navigation with SwiftUI views for hybrid approach
    func bridgeToSwiftUI<Content: View>(view: Content) -> UIViewController

    /// Create SwiftUI representable from UIKit components
    func createRepresentable<T: UIView>(view: T) -> UIViewRepresentable

    /// Handle data binding between UIKit and SwiftUI
    func bindData<T>(_ binding: Binding<T>, to keyPath: WritableKeyPath<Self, T>)
}