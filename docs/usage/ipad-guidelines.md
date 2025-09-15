# iPad-Specific Usage Guidelines

This guide provides comprehensive guidelines for developing and using HealerKit on iPad, with specific optimizations for first-generation iPad Pro and healer-focused workflows.

## iPad Platform Overview

### Target Device: First-Generation iPad Pro

**Hardware Specifications:**
- **Processor**: A9X chip (dual-core, 2.26 GHz)
- **Memory**: 4GB RAM
- **Display**: 12.9" (2732×2048) 264 PPI Retina
- **iOS Version**: iOS 13.1 (maximum supported)
- **Graphics**: PowerVR Series 7XT (12-cluster)

**Performance Constraints:**
- 60fps rendering target with complex layouts
- 4GB memory limitation for entire system
- iOS 13.1 API limitations (no SwiftUI 2.0+ features)
- Battery optimization for extended gaming sessions

## Healer Workflow Optimization

### Touch-First Interface Design

#### Minimum Touch Targets
All interactive elements must meet accessibility standards:

```swift
// Minimum touch target dimensions
let minimumTouchTarget: CGFloat = 44.0  // Apple HIG recommendation

// Ability card minimum dimensions
let abilityCardMinSize = CGSize(width: 280, height: 120)

// Button spacing for fat finger navigation
let buttonSpacing: CGFloat = 8.0  // Minimum space between tappable elements
```

#### Gesture Patterns for Healers

**Primary Gestures:**
- **Single Tap**: Select dungeon/boss, view ability details
- **Long Press**: Context menu with healer actions (favorite, share strategy)
- **Swipe Left**: Quick filter by damage profile
- **Swipe Right**: Access quick actions (cooldown timer, notes)
- **Pinch to Zoom**: Ability card detail expansion (accessibility)

**Navigation Patterns:**
```swift
// Healer-optimized navigation flow
Dungeons List → Boss Selection → Ability Details → Healer Strategy
     ↓              ↓              ↓              ↓
Quick Search → Filter by Role → Color Priority → Action Timing
```

### Split View Architecture

#### Master-Detail Implementation

```swift
class HealerSplitViewController: UISplitViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        // Optimize for iPad healer workflow
        preferredDisplayMode = .oneBesideSecondary
        presentsWithGesture = true

        // Minimum widths for healer content
        minimumPrimaryColumnWidth = 320  // Dungeon list
        maximumPrimaryColumnWidth = 400  // Don't make too wide

        // Delegate for healer-specific navigation
        delegate = self
    }
}

extension HealerSplitViewController: UISplitViewControllerDelegate {
    func splitViewController(_ splitViewController: UISplitViewController,
                           collapseSecondary secondaryViewController: UIViewController,
                           onto primaryViewController: UIViewController) -> Bool {
        // Always show dungeon list first on iPhone-sized displays
        return true
    }
}
```

#### Orientation Handling

**Portrait Mode (Preferred for Healer Use):**
- Master: 320pt width (dungeon list)
- Detail: Remaining space (boss/ability details)
- Grid: 3 columns for dungeon display

**Landscape Mode:**
- Master: 350pt width (more breathing room)
- Detail: Remaining space for ability cards
- Grid: 4 columns for dungeon display

```swift
override func viewWillTransition(to size: CGSize,
                               with coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransition(to: size, with: coordinator)

    coordinator.animate(alongsideTransition: { _ in
        self.updateLayoutForSize(size)
    })
}

private func updateLayoutForSize(_ size: CGSize) {
    let isLandscape = size.width > size.height

    // Adjust grid columns based on orientation
    let columns = isLandscape ? 4 : 3
    dungeonGridLayout.updateColumns(columns)

    // Adjust ability card sizing
    let cardWidth = isLandscape ? 300 : 280
    abilityCardLayout.preferredCardWidth = cardWidth
}
```

## Performance Optimization Strategies

### Memory Management for 4GB Constraint

#### Efficient Data Loading

```swift
class HealerDataManager {
    // Lazy loading for memory efficiency
    private lazy var dungeonCache = LRUCache<UUID, DungeonEntity>(capacity: 10)
    private lazy var abilityCache = LRUCache<UUID, [AbilityEntity]>(capacity: 20)

    func loadDungeonData(dungeonId: UUID) async throws -> DungeonEntity {
        // Check cache first
        if let cached = dungeonCache.getValue(for: dungeonId) {
            return cached
        }

        // Load from storage and cache
        let dungeon = try await dungeonProvider.fetchDungeon(id: dungeonId)
        dungeonCache.setValue(dungeon, for: dungeonId)
        return dungeon
    }

    func handleMemoryPressure() {
        // Clear caches during low memory
        dungeonCache.removeAll()
        abilityCache.removeAll()

        // Force garbage collection
        NotificationCenter.default.post(name: .memoryPressureCleanup, object: nil)
    }
}
```

#### View Controller Memory Management

```swift
class BossEncounterViewController: UIViewController {
    private var abilityViews: [AbilityCardView] = []

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        // Clean up views when not visible to free memory
        if isMovingFromParent {
            cleanupAbilityViews()
        }
    }

    private func cleanupAbilityViews() {
        abilityViews.forEach { view in
            view.removeFromSuperview()
            // Clear image caches in ability cards
            view.clearImageCache()
        }
        abilityViews.removeAll()
    }
}
```

### Rendering Performance (60fps Target)

#### Layer Optimization

```swift
class AbilityCardView: UIView {
    override func awakeFromNib() {
        super.awakeFromNib()
        optimizeForPerformance()
    }

    private func optimizeForPerformance() {
        // Reduce layer complexity for A9X chip
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale

        // Use opaque backgrounds where possible
        backgroundColor = .systemBackground

        // Optimize shadow rendering
        if needsShadow {
            layer.shadowOpacity = 0.1
            layer.shadowRadius = 2.0
            layer.shadowOffset = CGSize(width: 0, height: 1)
            // Pre-calculate shadow path
            layer.shadowPath = UIBezierPath(
                roundedRect: bounds,
                cornerRadius: layer.cornerRadius
            ).cgPath
        }
    }
}
```

#### Animation Optimization

```swift
class HealerAnimationManager {
    // Reduce animation complexity on first-gen iPad Pro
    static let optimizedAnimationDuration: TimeInterval = 0.2
    static let simplifiedSpringDamping: CGFloat = 0.8

    static func animateAbilityHighlight(_ view: UIView) {
        // Simple, performant animation for critical abilities
        UIView.animate(
            withDuration: optimizedAnimationDuration,
            delay: 0,
            options: [.curveEaseInOut, .allowUserInteraction]
        ) {
            view.transform = CGAffineTransform(scaleX: 1.02, y: 1.02)
        } completion: { _ in
            UIView.animate(withDuration: optimizedAnimationDuration) {
                view.transform = .identity
            }
        }
    }
}
```

## Healer-Specific UI Patterns

### Color-Coded Information Hierarchy

#### Visual Priority System

```swift
enum HealerVisualPriority {
    case critical   // Red - immediate action required
    case high       // Orange - significant attention needed
    case moderate   // Yellow - standard awareness
    case mechanic   // Blue - non-damage mechanics

    var colorScheme: HealerColorScheme {
        switch self {
        case .critical:
            return HealerColorScheme(
                primary: UIColor(red: 1.0, green: 0.42, blue: 0.42, alpha: 1.0),    // #FF6B6B
                background: UIColor(red: 1.0, green: 0.96, blue: 0.96, alpha: 1.0), // #FFF5F5
                border: UIColor(red: 0.86, green: 0.15, blue: 0.15, alpha: 1.0)     // #DC2626
            )
        // ... other cases
        }
    }
}
```

#### Information Density Management

**Full Detail Cards (Primary View):**
```
┌─────────────────────────────────┐
│ [Red Border] CRITICAL           │
│ ┌─────────────────────────────┐ │
│ │ Seismic Slam            🔴  │ │
│ │ Target: Entire Group        │ │
│ │ Action: Group healing CD    │ │
│ │ Insight: 80% max HP damage  │ │
│ │ Cooldown: Every 45 seconds  │ │
│ └─────────────────────────────┘ │
└─────────────────────────────────┘
```

**Compact Cards (List View):**
```
┌───────────────────────────────┐
│ 🔴 Seismic Slam │ Group CD    │
│ 🟠 Boulder Toss │ Spot heal   │
│ 🟡 Rock Throw   │ Minor heal  │
└───────────────────────────────┘
```

### Quick Access Patterns

#### Healer Dashboard Layout

```swift
class HealerDashboardViewController: UIViewController {
    @IBOutlet weak var criticalAbilitiesSection: UIStackView!
    @IBOutlet weak var highPrioritySection: UIStackView!
    @IBOutlet weak var keyMechanicsSection: UIStackView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupHealerPriorities()
    }

    private func setupHealerPriorities() {
        // Always show critical abilities at top
        criticalAbilitiesSection.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let criticalAbilities = abilities.filter { $0.damageProfile == .critical }
        criticalAbilities.forEach { ability in
            let card = AbilityCardView(ability: ability, displayMode: .compact)
            criticalAbilitiesSection.addArrangedSubview(card)
        }
    }
}
```

#### Filter and Search Integration

```swift
class HealerSearchController: UISearchController {
    private let healerFilters = [
        "Critical Damage",
        "Group Damage",
        "Tank Damage",
        "Mechanics Only",
        "Dispellable",
        "Interruptible"
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        setupHealerFilters()
    }

    private func setupHealerFilters() {
        // Add healer-specific quick filters above search bar
        let filterStack = UIStackView()
        filterStack.axis = .horizontal
        filterStack.spacing = 8

        healerFilters.forEach { filterName in
            let filterButton = UIButton(type: .system)
            filterButton.setTitle(filterName, for: .normal)
            filterButton.backgroundColor = .systemGray6
            filterButton.layer.cornerRadius = 16
            filterButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)

            filterButton.addTarget(self, action: #selector(filterTapped), for: .touchUpInside)
            filterStack.addArrangedSubview(filterButton)
        }
    }
}
```

## Multitasking and External Displays

### iPad Multitasking Support

#### Split Screen with Other Apps

```swift
// Enable multitasking for healers using other apps simultaneously
override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    return .all  // Support all orientations for multitasking
}

override var prefersHomeIndicatorAutoHidden: Bool {
    return false  // Keep home indicator for easy app switching
}

// Handle compact width scenarios when in split screen
override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransition(to: size, with: coordinator)

    let isCompactWidth = size.width < 600
    if isCompactWidth {
        // Switch to iPhone-like navigation when space is limited
        switchToCompactLayout()
    } else {
        switchToRegularLayout()
    }
}
```

### External Display Support

```swift
class ExternalDisplayManager: NSObject {
    override init() {
        super.init()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(screenDidConnect),
            name: UIScreen.didConnectNotification,
            object: nil
        )
    }

    @objc private func screenDidConnect(_ notification: Notification) {
        guard let externalScreen = notification.object as? UIScreen else { return }

        // Create healer-optimized display for external monitor
        let externalWindow = UIWindow(frame: externalScreen.bounds)
        externalWindow.screen = externalScreen

        // Show simplified healer dashboard on external display
        let healerDashboard = HealerExternalDashboardViewController()
        externalWindow.rootViewController = healerDashboard
        externalWindow.isHidden = false
    }
}
```

## Accessibility for Healer Workflows

### VoiceOver Optimization

```swift
extension AbilityCardView {
    private func setupHealerAccessibility() {
        // Comprehensive accessibility for healer workflow
        isAccessibilityElement = true
        accessibilityTraits = [.button]

        // Dynamic labels based on healer context
        accessibilityLabel = generateHealerAccessibilityLabel()
        accessibilityHint = "Double tap to view detailed healing strategy"

        // Custom actions for common healer tasks
        accessibilityCustomActions = [
            UIAccessibilityCustomAction(
                name: "Set cooldown reminder"
            ) { _ in
                self.delegate?.setCooldownReminder(for: self.ability)
                return true
            },
            UIAccessibilityCustomAction(
                name: "Share with group"
            ) { _ in
                self.delegate?.shareWithGroup(ability: self.ability)
                return true
            }
        ]
    }

    private func generateHealerAccessibilityLabel() -> String {
        let priority = ability.damageProfile.rawValue
        let target = ability.targets.rawValue.replacingOccurrences(of: "_", with: " ")
        return "\(ability.name), \(priority) priority, targets \(target)"
    }
}
```

### Dynamic Type Support

```swift
class HealerTypographyManager {
    static func configureForDynamicType(_ label: UILabel, style: UIFont.TextStyle) {
        label.font = UIFont.preferredFont(forTextStyle: style)
        label.adjustsFontForContentSizeCategory = true

        // Limit maximum size for gameplay usability
        label.maximumContentSizeCategory = .accessibilityLarge
    }

    // Healer-specific font scaling
    static func healerActionFont() -> UIFont {
        let baseFont = UIFont.preferredFont(forTextStyle: .subheadline)
        let descriptor = baseFont.fontDescriptor.addingAttributes([
            .traits: [UIFontDescriptor.TraitKey.weight: UIFont.Weight.semibold]
        ])
        return UIFont(descriptor: descriptor, size: 0)
    }
}
```

## Best Practices for Healer iPad Development

### 1. Performance-First Approach
```swift
// ✅ Good: Profile and optimize for first-gen iPad Pro
class PerformanceMonitor {
    private var frameRate: Int = 0
    private let targetFPS: Int = 60

    func monitorPerformance() {
        let displayLink = CADisplayLink(target: self, selector: #selector(updateFrameRate))
        displayLink.add(to: .main, forMode: .common)
    }

    @objc private func updateFrameRate() {
        frameRate += 1
        // Alert if dropping below 50fps consistently
        if frameRate < 50 {
            optimizeForPerformance()
        }
    }
}
```

### 2. Memory-Conscious Design
```swift
// ✅ Good: Implement memory pressure handling
NotificationCenter.default.addObserver(
    forName: UIApplication.didReceiveMemoryWarningNotification,
    object: nil,
    queue: .main
) { _ in
    // Clear non-essential caches
    ImageCache.shared.clearCache()
    ViewControllerCache.shared.clearCache()

    // Force UI cleanup
    abilityCardCache.removeAll()
}
```

### 3. Healer-Centric Information Architecture
```swift
// ✅ Good: Prioritize information by healer relevance
struct HealerInformationPriority {
    static func prioritize(_ abilities: [AbilityEntity]) -> [AbilityEntity] {
        return abilities.sorted { ability1, ability2 in
            // Critical healing actions first
            if ability1.damageProfile.priority != ability2.damageProfile.priority {
                return ability1.damageProfile.priority > ability2.damageProfile.priority
            }

            // Group damage over single target
            if ability1.targets == .group && ability2.targets != .group {
                return true
            }

            // Dispellable effects prioritized
            if ability1.type == .dispel && ability2.type != .dispel {
                return true
            }

            return ability1.displayOrder < ability2.displayOrder
        }
    }
}
```

### 4. Touch-Optimized Interactions
```swift
// ✅ Good: Design for touch-first interaction
class TouchOptimizedButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTouchOptimization()
    }

    private func setupTouchOptimization() {
        // Ensure minimum 44pt touch target
        widthAnchor.constraint(greaterThanOrEqualToConstant: 44).isActive = true
        heightAnchor.constraint(greaterThanOrEqualToConstant: 44).isActive = true

        // Add touch feedback for healer actions
        addTarget(self, action: #selector(touchDown), for: .touchDown)
        addTarget(self, action: #selector(touchUp), for: [.touchUpInside, .touchUpOutside])
    }

    @objc private func touchDown() {
        UIView.animate(withDuration: 0.1) {
            self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }
    }

    @objc private func touchUp() {
        UIView.animate(withDuration: 0.1) {
            self.transform = .identity
        }
    }
}
```

This guide provides the foundation for creating iPad-optimized healer interfaces that work efficiently within the constraints of first-generation iPad Pro hardware while maintaining the responsiveness and accessibility required for high-pressure Mythic+ encounters.