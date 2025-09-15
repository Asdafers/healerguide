# HealerUIKit API Documentation

HealerUIKit provides iPad-optimized UI components specifically designed for Mythic+ healer workflows. The library combines UIKit's performance with SwiftUI's declarative approach to create responsive, accessible interfaces optimized for first-generation iPad Pro hardware.

## Overview

HealerUIKit bridges the gap between data (DungeonKit/AbilityKit) and user experience, providing touch-optimized components that enable quick access to critical healer information during high-pressure encounters. All components are designed with first-generation iPad Pro performance constraints and healer workflow requirements in mind.

## Core Protocols

### HealerDisplayProviding

Primary interface for creating healer-focused view controllers.

```swift
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
```

**Performance Optimizations:**
- View controller reuse and caching for < 16ms creation times
- Lazy loading of complex views to maintain 60fps scrolling
- Memory-efficient image caching for boss/dungeon artwork
- Hardware-accelerated animations using Core Animation

### AbilityCardProviding

Specialized components for ability visualization with color coding.

```swift
protocol AbilityCardProviding {
    /// Create color-coded ability card for tablet display
    func createAbilityCard(ability: AbilityEntity, classification: AbilityClassification) -> UIView

    /// Create compact ability row for list displays
    func createAbilityRow(ability: AbilityEntity) -> UIView

    /// Create key mechanics summary card
    func createKeyMechanicsCard(mechanics: [AbilityEntity]) -> UIView
}
```

**Visual Design Principles:**
- **Color-Coded Priority**: Immediate visual hierarchy using DamageProfile colors
- **Touch-Optimized**: Minimum 44pt touch targets for iPad finger navigation
- **Information Density**: Balanced content display for glanceable information
- **Accessibility First**: VoiceOver, Dynamic Type, and high contrast support

### NavigationProviding

iPad-specific navigation optimized for split-screen and multitasking.

```swift
protocol NavigationProviding {
    /// iPad-optimized navigation controller with proper split view support
    func createMainNavigationController() -> UISplitViewController

    /// Breadcrumb navigation for deep linking between encounters
    func createBreadcrumbNavigation(path: NavigationPath) -> UIView

    /// Quick action toolbar for common healer tasks
    func createQuickActionToolbar(actions: [QuickAction]) -> UIToolbar
}
```

## UI Configuration System

### HealerUIConfiguration

Comprehensive configuration system for iPad optimization and healer preferences.

```swift
protocol HealerUIConfiguration {
    var typography: TypographySettings { get }      // Dynamic Type and readability
    var colorScheme: HealerColorScheme { get }      // Damage profile visualization
    var layout: LayoutSettings { get }              // iPad orientation handling
    var accessibility: AccessibilitySettings { get } // Inclusive design features
}
```

### TypographySettings

Typography system optimized for gameplay readability and accessibility.

```swift
struct TypographySettings {
    let dungeonNameFont: UIFont          // Large, bold for quick identification
    let bossNameFont: UIFont            // Prominent but not overwhelming
    let abilityNameFont: UIFont         // Clear, scannable in lists
    let healerActionFont: UIFont        // Action-oriented, urgent styling
    let insightFont: UIFont             // Supporting detail information
    let summaryFont: UIFont             // Readable paragraph text

    // Dynamic Type support for accessibility
    let supportsDynamicType: Bool        // Respects user's text size preferences
    let maximumPointSize: CGFloat        // Prevents unusably large text during gameplay
    let minimumPointSize: CGFloat        // Maintains readability threshold
}
```

**Typography Guidelines:**
- **Dungeon Names**: 24pt SF Pro Display Bold (scales with Dynamic Type)
- **Boss Names**: 20pt SF Pro Display Semibold
- **Ability Names**: 16pt SF Pro Text Medium (primary information)
- **Healer Actions**: 14pt SF Pro Text Semibold with color accent
- **Critical Insights**: 12pt SF Pro Text Regular (supporting detail)

### HealerColorScheme

iPad-optimized color system supporting Dark Mode and accessibility needs.

```swift
struct HealerColorScheme {
    // Damage profile colors optimized for iPad display
    let criticalDamageColor: UIColor     // High contrast red (#FF6B6B)
    let highDamageColor: UIColor         // Orange (#F59E0B)
    let moderateDamageColor: UIColor     // Yellow (#EAB308)
    let mechanicColor: UIColor           // Blue (#3B82F6)

    // Background colors for readability
    let primaryBackgroundColor: UIColor   // Main content area
    let secondaryBackgroundColor: UIColor // Cards and sections
    let cardBackgroundColor: UIColor      // Individual ability cards

    // Text colors for various contexts
    let primaryTextColor: UIColor         // Main content text
    let secondaryTextColor: UIColor       // Supporting information
    let accentTextColor: UIColor         // Highlighted actions

    // Interactive element colors
    let buttonTintColor: UIColor         // Action buttons and controls
    let selectionColor: UIColor          // Selected states
    let separatorColor: UIColor          // Visual dividers
}
```

**Accessibility Features:**
- **High Contrast Mode**: Enhanced borders and shadows for better visibility
- **Colorblind Support**: Pattern overlays and alternative indicators
- **Dark Mode**: Optimized colors maintaining contrast ratios in low light

### LayoutSettings

Adaptive layout system for iPad orientations and multitasking scenarios.

```swift
struct LayoutSettings {
    // iPad-specific spacing and sizing
    let cardCornerRadius: CGFloat        // 8pt for modern, touchable feel
    let standardMargin: CGFloat          // 16pt for comfortable spacing
    let compactMargin: CGFloat           // 8pt for dense information display
    let minimumTouchTarget: CGFloat      // 44pt minimum for accessibility

    // Grid and list configurations
    let dungeonGridColumns: Int          // 3 portrait, 4 landscape
    let abilityCardMinimumWidth: CGFloat // 280pt minimum for readability
    let maximumContentWidth: CGFloat     // 768pt to prevent excessive line lengths

    // Split view configurations
    let masterViewMinimumWidth: CGFloat   // 320pt for dungeon list
    let detailViewMinimumWidth: CGFloat   // 448pt for ability details
}
```

## View Controller Protocols

### DungeonListViewControllerProtocol

Master view controller for dungeon navigation and selection.

```swift
protocol DungeonListViewControllerProtocol: UIViewController {
    var dungeons: [DungeonEntity] { get set }
    var delegate: DungeonListDelegate? { get set }

    func refreshDungeonData()                                    // Pull-to-refresh support
    func selectDungeon(_ dungeon: DungeonEntity)                // Programmatic selection
    func updateLayout(for orientation: UIInterfaceOrientation)   // Orientation handling
}

protocol DungeonListDelegate: AnyObject {
    func dungeonListDidSelectDungeon(_ dungeon: DungeonEntity)
    func dungeonListDidRequestRefresh()
    func dungeonListDidRequestSearch()
}
```

**Features:**
- **Grid Layout**: Adaptive grid supporting portrait (3 columns) and landscape (4 columns)
- **Quick Actions**: Swipe gestures for favoriting and sharing dungeon strategies
- **Search Integration**: Built-in search bar with real-time filtering
- **Performance**: Smooth 60fps scrolling with image caching

### BossEncounterViewControllerProtocol

Detail view controller for boss encounter information and abilities.

```swift
protocol BossEncounterViewControllerProtocol: UIViewController {
    var encounter: BossEncounterEntity { get set }
    var abilities: [AbilityEntity] { get set }
    var delegate: BossEncounterDelegate? { get set }

    func updateAbilities(_ abilities: [AbilityEntity])           // Refresh ability data
    func highlightAbility(_ abilityId: UUID)                    // Focus specific ability
    func filterAbilities(by damageProfile: DamageProfile?)      // Filter by severity
}

protocol BossEncounterDelegate: AnyObject {
    func bossEncounterDidSelectAbility(_ ability: AbilityEntity)
    func bossEncounterDidRequestAbilityDetails(_ ability: AbilityEntity)
    func bossEncounterDidToggleFilter(_ damageProfile: DamageProfile?)
}
```

**Layout Structure:**
```
┌─────────────────────────────────────┐
│ Boss Name & Healer Summary          │
├─────────────────────────────────────┤
│ Filter: [All] [Critical] [High] ... │
├─────────────────────────────────────┤
│ ┌─────────┐ ┌─────────┐ ┌─────────┐│
│ │Critical │ │High     │ │Moderate ││
│ │Ability  │ │Ability  │ │Ability  ││
│ └─────────┘ └─────────┘ └─────────┘│
│ ┌─────────────────────────────────┐ │
│ │Key Mechanics Summary            │ │
│ └─────────────────────────────────┘ │
└─────────────────────────────────────┘
```

## Custom View Components

### AbilityCardViewProtocol

Color-coded ability cards with interactive functionality.

```swift
protocol AbilityCardViewProtocol: UIView {
    var ability: AbilityEntity { get set }
    var classification: AbilityClassification { get set }
    var delegate: AbilityCardDelegate? { get set }

    func updateDisplayMode(_ mode: AbilityDisplayMode)          // Adjust information density
    func animateAttention()                                     // Highlight critical abilities
}

protocol AbilityCardDelegate: AnyObject {
    func abilityCardDidTap(_ ability: AbilityEntity)           // Single tap for details
    func abilityCardDidRequestDetails(_ ability: AbilityEntity) // Long press for expanded view
    func abilityCardDidLongPress(_ ability: AbilityEntity)     // Context menu trigger
}

enum AbilityDisplayMode {
    case full       // Complete information display
    case compact    // Condensed for list views
    case minimal    // Name and damage profile only
}
```

**Card Structure:**
```
┌─────────────────────────────────┐
│ [Color Border - Damage Profile] │
│ ┌─────────────────────────────┐ │
│ │ Ability Name            🔴  │ │ ← Critical indicator
│ │ Target: Group               │ │
│ │ Action: Use group cooldown  │ │
│ │ Insight: 80% HP damage      │ │
│ └─────────────────────────────┘ │
└─────────────────────────────────┘
```

## Performance Optimization

### HealerUIPerformance

Performance monitoring and optimization specifically for first-generation iPad Pro.

```swift
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
    let averageFrameRate: Double         // Target: 60fps
    let memoryUsage: Int64              // Current UI memory footprint
    let viewCacheSize: Int              // Cached view components
    let lastOptimization: Date          // Last performance optimization
    let recommendedActions: [PerformanceAction] // Suggested improvements
}

enum PerformanceAction {
    case reduceViewComplexity           // Simplify complex layouts
    case clearViewCache                 // Free cached components
    case simplifyAnimations             // Reduce animation complexity
    case enableLowPowerMode            // iPad battery optimization
}
```

**Performance Strategies:**
- **View Recycling**: Reuse ability cards and list cells to minimize allocation
- **Layer Optimization**: Use `CALayer` optimizations for complex visual effects
- **Animation Simplification**: Reduce Core Animation complexity based on hardware capabilities
- **Memory Management**: Proactive cleanup during background transitions

## Accessibility Implementation

### AccessibilitySettings

Comprehensive accessibility support for inclusive healer experiences.

```swift
struct AccessibilitySettings {
    let supportsDarkMode: Bool           // System Dark Mode integration
    let supportsHighContrast: Bool       // Enhanced visual contrast
    let supportsLargeText: Bool          // Dynamic Type scaling
    let supportsVoiceOver: Bool          // Screen reader compatibility
    let supportsReduceMotion: Bool       // Motion sensitivity accommodation

    // Healer-specific accessibility features
    let colorBlindFriendlyMode: Bool     // Pattern/shape alternatives to color
    let simplifiedUIMode: Bool           // Reduced visual complexity option
    let hapticFeedbackEnabled: Bool      // Tactile feedback for critical alerts
}
```

**VoiceOver Implementation:**
```swift
// Ability card accessibility
abilityCard.isAccessibilityElement = true
abilityCard.accessibilityLabel = "\(ability.name), \(damageProfile.rawValue) damage"
abilityCard.accessibilityHint = "Double tap to view healer strategy details"
abilityCard.accessibilityTraits = [.button]

// Custom actions for VoiceOver users
abilityCard.accessibilityCustomActions = [
    UIAccessibilityCustomAction(name: "Filter by damage type") { _ in
        delegate?.filterByDamageProfile(ability.damageProfile)
        return true
    }
]
```

## SwiftUI Integration

### SwiftUIBridging

Hybrid UIKit/SwiftUI architecture for optimal performance and developer experience.

```swift
protocol SwiftUIBridging {
    /// Bridge UIKit navigation with SwiftUI views for hybrid approach
    func bridgeToSwiftUI<Content: View>(view: Content) -> UIViewController

    /// Create SwiftUI representable from UIKit components
    func createRepresentable<T: UIView>(view: T) -> UIViewRepresentable

    /// Handle data binding between UIKit and SwiftUI
    func bindData<T>(_ binding: Binding<T>, to keyPath: WritableKeyPath<Self, T>)
}
```

**Integration Pattern:**
```swift
// SwiftUI view for simple components
struct AbilitySummaryView: View {
    let abilities: [AbilityEntity]

    var body: some View {
        LazyVGrid(columns: gridColumns) {
            ForEach(abilities, id: \.id) { ability in
                AbilityCardRepresentable(ability: ability)
                    .frame(minHeight: 120)
            }
        }
        .padding()
    }
}

// UIKit implementation for performance-critical components
struct AbilityCardRepresentable: UIViewRepresentable {
    let ability: AbilityEntity

    func makeUIView(context: Context) -> AbilityCardView {
        return AbilityCardView(ability: ability)
    }

    func updateUIView(_ uiView: AbilityCardView, context: Context) {
        uiView.updateAbility(ability)
    }
}
```

## CLI Interface

### HealerUIKitCLI

Command-line tools for UI validation, performance testing, and accessibility auditing.

```swift
protocol HealerUIKitCLI {
    /// Test UI component rendering performance
    func benchmarkComponent(component: String, iterations: Int) async -> CLIResult

    /// Validate UI layouts for different iPad orientations
    func validateLayouts(device: String) async -> CLIResult

    /// Generate accessibility report
    func auditAccessibility(outputFile: URL?) async -> CLIResult

    /// Test color contrast ratios for damage profiles
    func testColorContrast(standard: String) async -> CLIResult
}
```

### CLI Commands

#### Performance Benchmarking
```bash
# Test ability card rendering performance
healeruikit benchmark --component ability-card --iterations 100

# Sample output:
Component Performance Results:
- Component: AbilityCardView
- Iterations: 100
- Average render time: 2.1ms
- Peak memory usage: 4.2MB
- Frame rate impact: 0.3ms (acceptable for 60fps)
- Recommendation: Performance target met for first-gen iPad Pro
```

#### Layout Validation
```bash
# Validate layouts across iPad orientations
healeruikit validate-layouts --device ipad-pro-gen1

# Sample output:
Layout Validation Results:
✓ Portrait orientation: All constraints satisfied
✓ Landscape orientation: All constraints satisfied
✓ Split View (1/3): Master view minimum width maintained
✓ Split View (2/3): Detail view optimal width achieved
⚠ Compact width: Some ability cards below minimum recommended width
```

#### Accessibility Auditing
```bash
# Generate comprehensive accessibility report
healeruikit accessibility-audit --output accessibility_report.json

# Sample output (JSON):
{
  "summary": {
    "totalElements": 156,
    "accessibleElements": 152,
    "complianceRate": 97.4
  },
  "issues": [
    {
      "severity": "warning",
      "element": "AbilityCard#critical-slam",
      "issue": "Missing accessibility hint for complex interaction",
      "recommendation": "Add hint describing long press action"
    }
  ],
  "colorContrast": {
    "wcagAACompliant": true,
    "minimumRatio": 4.67,
    "averageRatio": 7.23
  }
}
```

## Integration Examples

### Complete Healer Interface Setup

```swift
import HealerUIKit
import DungeonKit
import AbilityKit

class MainHealerViewController: UIViewController {
    private let displayProvider: HealerDisplayProviding
    private let dungeonService: DungeonDataProviding
    private let abilityService: AbilityDataProviding

    override func viewDidLoad() {
        super.viewDidLoad()
        setupHealerInterface()
    }

    private func setupHealerInterface() {
        // Create split view controller for iPad
        let navigationProvider = NavigationProvider()
        let splitViewController = navigationProvider.createMainNavigationController()

        // Setup master view (dungeon list)
        let dungeonListVC = displayProvider.createDungeonListView(dungeons: [])
        splitViewController.viewControllers = [dungeonListVC]

        // Configure for iPad optimization
        splitViewController.preferredDisplayMode = .oneBesideSecondary
        splitViewController.presentsWithGesture = true

        addChild(splitViewController)
        view.addSubview(splitViewController.view)
        splitViewController.didMove(toParent: self)
    }
}
```

### Custom Ability Card Implementation

```swift
class CustomAbilityCardView: UIView, AbilityCardViewProtocol {
    var ability: AbilityEntity {
        didSet { updateDisplay() }
    }
    var classification: AbilityClassification {
        didSet { updateClassificationDisplay() }
    }
    weak var delegate: AbilityCardDelegate?

    private let nameLabel = UILabel()
    private let actionLabel = UILabel()
    private let insightLabel = UILabel()
    private let damageIndicator = UIView()

    override init(frame: CGRect) {
        self.ability = AbilityEntity.placeholder
        self.classification = AbilityClassification.default
        super.init(frame: frame)
        setupLayout()
        setupAccessibility()
    }

    private func setupLayout() {
        // Configure visual hierarchy based on damage profile
        layer.cornerRadius = 8
        layer.borderWidth = 2
        clipsToBounds = true

        // Add tap gesture for interaction
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGesture)

        // Configure Auto Layout constraints...
    }

    private func updateDisplay() {
        nameLabel.text = ability.name
        actionLabel.text = ability.healerAction
        insightLabel.text = ability.criticalInsight

        // Apply damage profile color scheme
        let colorScheme = DamageProfileAnalyzer().getUIColorScheme(for: ability.damageProfile)
        backgroundColor = UIColor(hex: colorScheme.backgroundColor)
        layer.borderColor = UIColor(hex: colorScheme.borderColor).cgColor

        updateAccessibilityLabels()
    }

    func animateAttention() {
        // Critical ability attention animation
        UIView.animate(withDuration: 0.5, delay: 0, options: [.repeat, .autoreverse]) {
            self.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        } completion: { _ in
            self.transform = .identity
        }
    }

    @objc private func handleTap() {
        delegate?.abilityCardDidTap(ability)
    }
}
```

## Best Practices

### 1. Performance-First Design
```swift
// ✅ Good: Lazy loading for complex views
class BossEncounterViewController: UIViewController {
    private lazy var abilityCollectionView: UICollectionView = {
        // Defer expensive view creation until needed
        createOptimizedCollectionView()
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Only create essential views immediately
        setupBasicLayout()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Load ability data just before display
        loadAbilityData()
    }
}
```

### 2. Memory-Conscious Implementation
```swift
// ✅ Good: Implement memory pressure handling
class AbilityCardCache {
    private var cache: [UUID: AbilityCardView] = [:]
    private let maxCacheSize = 50 // Limit for first-gen iPad Pro

    init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleMemoryPressure),
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )
    }

    @objc private func handleMemoryPressure() {
        cache.removeAll() // Clear cache to free memory
    }
}
```

### 3. Accessibility Integration
```swift
// ✅ Good: Comprehensive accessibility implementation
extension AbilityCardView {
    private func setupAccessibility() {
        isAccessibilityElement = true
        accessibilityTraits = [.button]

        // Dynamic accessibility based on damage profile
        updateAccessibilityForDamageProfile()

        // Support for accessibility shortcuts
        setupAccessibilityActions()
    }

    private func updateAccessibilityForDamageProfile() {
        let urgencyDescription = classification.urgency == .immediate ? "Critical" : "Standard"
        accessibilityLabel = "\(ability.name), \(urgencyDescription) priority ability"
        accessibilityHint = "Double tap for healing strategy details"
    }
}
```

This comprehensive UI framework provides the foundation for creating responsive, accessible, and performance-optimized healer interfaces specifically designed for iPad workflows and first-generation iPad Pro hardware constraints.