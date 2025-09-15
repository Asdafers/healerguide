# Accessibility Compliance Guide

This guide provides comprehensive accessibility implementation standards and testing procedures for HealerKit, ensuring inclusive design that meets WCAG 2.1 AA standards while maintaining optimal healer workflow performance.

## Accessibility Foundation

### Design Philosophy

HealerKit's accessibility approach recognizes that:
- Healing in Mythic+ requires split-second decisions regardless of abilities
- Visual information must have non-visual alternatives
- Interface complexity can be barriers, not just visual impairments
- Healer-specific workflows need specialized accessibility considerations

### Compliance Standards

- **WCAG 2.1 Level AA**: Primary compliance target
- **Section 508**: U.S. federal accessibility requirements
- **iOS Accessibility Guidelines**: Platform-specific best practices
- **Healer-Specific Standards**: Custom requirements for gaming accessibility

## Visual Accessibility

### Color and Contrast Requirements

#### Contrast Ratios

All text and interactive elements must meet enhanced contrast standards:

```swift
struct AccessibilityColorStandards {
    // WCAG AA minimum: 4.5:1, HealerKit target: 7:1 for gaming clarity
    static let minimumContrastRatio: Double = 7.0

    // Large text (18pt+) minimum: 3:1, HealerKit target: 4.5:1
    static let largeTextMinimumRatio: Double = 4.5

    // Interactive elements: Enhanced contrast for quick recognition
    static let interactiveElementRatio: Double = 8.0
}

enum AccessibilityColorProfile {
    case standard
    case highContrast
    case colorBlindFriendly

    func damageProfileColors() -> [DamageProfile: ColorScheme] {
        switch self {
        case .standard:
            return standardDamageColors()
        case .highContrast:
            return highContrastDamageColors()
        case .colorBlindFriendly:
            return colorBlindFriendlyColors()
        }
    }
}
```

#### Color Blind Accessibility

Alternative visual indicators supplement color coding:

```swift
enum ColorBlindPattern {
    case solid           // Standard users
    case diagonalStripes // Critical abilities
    case dots           // High priority
    case dashes         // Moderate priority
    case double         // Mechanic abilities

    func apply(to view: UIView, damageProfile: DamageProfile) {
        let patternLayer = CAShapeLayer()

        switch self {
        case .diagonalStripes:
            patternLayer.path = createDiagonalStripesPath(in: view.bounds)
            patternLayer.fillColor = damageProfile.primaryColor.cgColor
            patternLayer.opacity = 0.3

        case .dots:
            patternLayer.path = createDottedBorderPath(in: view.bounds)
            patternLayer.strokeColor = damageProfile.primaryColor.cgColor
            patternLayer.lineWidth = 2.0

        case .dashes:
            patternLayer.path = createDashedBorderPath(in: view.bounds)
            patternLayer.strokeColor = damageProfile.primaryColor.cgColor
            patternLayer.lineDashPattern = [5, 3]

        case .double:
            patternLayer.path = createDoubleBorderPath(in: view.bounds)
            patternLayer.strokeColor = damageProfile.primaryColor.cgColor
            patternLayer.lineWidth = 1.5

        default:
            return
        }

        view.layer.addSublayer(patternLayer)
    }
}
```

### Dynamic Type Support

#### Scalable Typography System

```swift
class HealerTypographyManager {
    static func configureAccessibleFont(
        _ label: UILabel,
        style: UIFont.TextStyle,
        weight: UIFont.Weight = .regular,
        maxCategory: UIContentSizeCategory = .accessibilityExtraExtraLarge
    ) {
        // Base font with preferred style
        let baseFont = UIFont.preferredFont(forTextStyle: style)

        // Add weight while preserving size scaling
        let descriptor = baseFont.fontDescriptor.addingAttributes([
            .traits: [UIFontDescriptor.TraitKey.weight: weight]
        ])

        label.font = UIFont(descriptor: descriptor, size: 0)
        label.adjustsFontForContentSizeCategory = true

        // Set maximum size for gameplay usability
        label.maximumContentSizeCategory = maxCategory

        // Ensure minimum legible size
        label.minimumScaleFactor = 0.8
    }

    // Healer-specific font configurations
    static func configureAbilityNameFont(_ label: UILabel) {
        configureAccessibleFont(
            label,
            style: .headline,
            weight: .semibold,
            maxCategory: .accessibilityLarge  // Prevent interface breaking
        )
    }

    static func configureCriticalActionFont(_ label: UILabel) {
        configureAccessibleFont(
            label,
            style: .subheadline,
            weight: .bold,
            maxCategory: .accessibilityMedium  // Critical info stays readable
        )
    }
}
```

#### Adaptive Layout for Text Scaling

```swift
class AccessibilityLayoutManager {
    static func configureAdaptiveLayout(
        for view: UIView,
        contentSizeCategory: UIContentSizeCategory
    ) {
        let isAccessibilitySize = contentSizeCategory.isAccessibilityCategory

        if isAccessibilitySize {
            // Switch to vertical layout for large text
            configureVerticalLayout(view)

            // Increase spacing for easier navigation
            increaseSpacing(view, multiplier: 1.5)

            // Ensure minimum touch targets
            enforceMinimumTouchTargets(view, size: 48.0)  // Larger for accessibility
        } else {
            configureStandardLayout(view)
        }
    }

    private static func configureVerticalLayout(_ view: UIView) {
        // Convert horizontal stack views to vertical
        view.subviews.compactMap { $0 as? UIStackView }.forEach { stackView in
            if stackView.axis == .horizontal {
                stackView.axis = .vertical
                stackView.alignment = .leading
            }
        }

        // Adjust ability card layouts
        view.subviews.compactMap { $0 as? AbilityCardView }.forEach { card in
            card.switchToAccessibilityLayout()
        }
    }
}
```

## VoiceOver Support

### Comprehensive VoiceOver Implementation

#### Ability Card Accessibility

```swift
extension AbilityCardView {
    func setupVoiceOverSupport() {
        // Configure as single accessibility element
        isAccessibilityElement = true
        accessibilityTraits = [.button]

        // Dynamic label based on healer context
        accessibilityLabel = generateHealerAccessibilityLabel()

        // Action-oriented hint
        accessibilityHint = "Double tap to view detailed healing strategy and cooldown recommendations"

        // Custom actions for healer workflow
        accessibilityCustomActions = createHealerCustomActions()

        // Value for damage profile
        accessibilityValue = ability.damageProfile.accessibilityDescription

        // Update when content changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateAccessibilityInfo),
            name: .abilityContentChanged,
            object: nil
        )
    }

    private func generateHealerAccessibilityLabel() -> String {
        let priority = ability.damageProfile.accessibilityPriority
        let target = ability.targets.accessibilityDescription
        let timing = ability.estimatedCastTime > 0 ?
            "cast in \(Int(ability.estimatedCastTime)) seconds" : ""

        return "\(ability.name), \(priority) priority ability, targets \(target). \(timing)"
    }

    private func createHealerCustomActions() -> [UIAccessibilityCustomAction] {
        return [
            UIAccessibilityCustomAction(
                name: "Set cooldown reminder"
            ) { _ in
                self.delegate?.setCooldownReminder(for: self.ability)
                UIAccessibility.post(
                    notification: .announcement,
                    argument: "Cooldown reminder set for \(self.ability.name)"
                )
                return true
            },

            UIAccessibilityCustomAction(
                name: "Share healing strategy"
            ) { _ in
                self.delegate?.shareHealingStrategy(for: self.ability)
                return true
            },

            UIAccessibilityCustomAction(
                name: "Add to priority list"
            ) { _ in
                self.delegate?.addToPriorityList(self.ability)
                UIAccessibility.post(
                    notification: .announcement,
                    argument: "\(self.ability.name) added to priority list"
                )
                return true
            }
        ]
    }
}
```

#### Collection View Accessibility

```swift
extension DungeonCollectionViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionViewAccessibility()
    }

    private func setupCollectionViewAccessibility() {
        // Enable collection view accessibility
        collectionView.isAccessibilityElement = false  // Allow cell navigation
        collectionView.shouldGroupAccessibilityChildren = true

        // Provide context for screen reader users
        collectionView.accessibilityLabel = "Dungeon list"
        collectionView.accessibilityHint = "Swipe right or left to navigate between dungeons"

        // Custom rotor for quick navigation
        setupDungeonRotor()
    }

    private func setupDungeonRotor() {
        let dungeonRotor = UIAccessibilityCustomRotor(name: "Dungeons") { predicate in
            return self.findNextDungeon(from: predicate)
        }

        accessibilityCustomRotors = [dungeonRotor]
    }

    private func findNextDungeon(from predicate: UIAccessibilityCustomRotorSearchPredicate) -> UIAccessibilityCustomRotorItemResult? {
        let forward = predicate.searchDirection == .next

        // Logic to find next/previous dungeon cell
        // Implementation would navigate through collection view cells
        // and return appropriate UIAccessibilityCustomRotorItemResult

        return nil  // Placeholder
    }
}
```

### Screen Reader Optimizations

#### Efficient Navigation Patterns

```swift
class HealerAccessibilityNavigator {
    static func optimizeForScreenReader(_ viewController: UIViewController) {
        // Group related elements for efficient navigation
        groupRelatedElements(viewController.view)

        // Set up logical reading order
        establishReadingOrder(viewController.view)

        // Configure shortcuts for healer workflow
        setupHealerShortcuts(viewController)
    }

    private static func groupRelatedElements(_ view: UIView) {
        // Group ability information together
        view.subviews.compactMap { $0 as? AbilityCardView }.forEach { card in
            card.shouldGroupAccessibilityChildren = true
            card.accessibilityElements = [
                card.nameLabel,
                card.actionLabel,
                card.insightLabel
            ].compactMap { $0 }
        }
    }

    private static func setupHealerShortcuts(_ viewController: UIViewController) {
        // Magic tap for critical abilities
        viewController.view.accessibilityCustomActions = [
            UIAccessibilityCustomAction(
                name: "Show only critical abilities"
            ) { _ in
                if let healerVC = viewController as? HealerViewControllerProtocol {
                    healerVC.filterToCriticalAbilities()
                    UIAccessibility.post(
                        notification: .screenChanged,
                        argument: "Showing only critical abilities"
                    )
                }
                return true
            }
        ]
    }
}
```

## Motor Accessibility

### Touch Accommodation

#### Enhanced Touch Targets

```swift
class AccessibilityTouchManager {
    static let minimumTouchTarget: CGFloat = 48.0  // Enhanced from standard 44pt
    static let preferredTouchTarget: CGFloat = 56.0  // Comfortable for all users

    static func ensureAccessibleTouchTargets(_ view: UIView) {
        view.subviews.forEach { subview in
            if subview.isUserInteractionEnabled {
                ensureMinimumSize(subview)
                ensureAdequateSpacing(subview)
            }

            // Recursively check subviews
            ensureAccessibleTouchTargets(subview)
        }
    }

    private static func ensureMinimumSize(_ view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false

        // Ensure minimum width and height
        NSLayoutConstraint.activate([
            view.widthAnchor.constraint(greaterThanOrEqualToConstant: minimumTouchTarget),
            view.heightAnchor.constraint(greaterThanOrEqualToConstant: minimumTouchTarget)
        ])
    }

    private static func ensureAdequateSpacing(_ view: UIView) {
        guard let superview = view.superview else { return }

        // Find adjacent interactive elements
        let siblings = superview.subviews.filter {
            $0 != view && $0.isUserInteractionEnabled
        }

        // Ensure minimum spacing between interactive elements
        siblings.forEach { sibling in
            let spacing = calculateSpacing(between: view, and: sibling)
            if spacing < 8.0 {  // Minimum touch spacing
                adjustSpacing(between: view, and: sibling, minimum: 8.0)
            }
        }
    }
}
```

#### Alternative Input Methods

```swift
class AlternativeInputManager {
    // Switch control support
    func configureSwitchControl() {
        // Focus on most critical elements first
        let criticalElements = findCriticalAbilities()
        criticalElements.forEach { element in
            element.accessibilityTraits.insert(.startsMediaSession)
        }
    }

    // Voice control optimization
    func configureVoiceControl() {
        // Assign voice control names to key elements
        assignVoiceControlNames()

        // Create voice shortcuts for healer actions
        createHealerVoiceShortcuts()
    }

    private func assignVoiceControlNames() {
        // Critical abilities get number-based names for quick access
        let criticalAbilities = findCriticalAbilities()
        criticalAbilities.enumerated().forEach { index, ability in
            ability.accessibilityUserInputLabels = [
                "critical \(index + 1)",
                "emergency \(index + 1)",
                ability.name.lowercased()
            ]
        }
    }
}
```

## Cognitive Accessibility

### Simplified Interface Modes

#### Reduced Complexity Mode

```swift
class CognitiveAccessibilityManager {
    static func enableSimplifiedMode(_ viewController: UIViewController) {
        // Reduce visual complexity
        hideNonEssentialElements(viewController.view)

        // Increase information hierarchy clarity
        enhanceInformationHierarchy(viewController.view)

        // Simplify interactions
        simplifyInteractionPatterns(viewController.view)

        // Add contextual help
        addContextualHelp(viewController)
    }

    private static func hideNonEssentialElements(_ view: UIView) {
        // Hide decorative elements
        view.subviews.filter { $0.accessibilityTraits.contains(.image) }.forEach {
            $0.isHidden = true
        }

        // Simplify ability cards to essential information only
        view.subviews.compactMap { $0 as? AbilityCardView }.forEach { card in
            card.switchToSimplifiedMode()
        }
    }

    private static func enhanceInformationHierarchy(_ view: UIView) {
        // Increase contrast for primary information
        view.subviews.forEach { subview in
            if let label = subview as? UILabel {
                enhanceLabelForClarity(label)
            }
        }
    }

    private static func addContextualHelp(_ viewController: UIViewController) {
        let helpButton = UIBarButtonItem(
            title: "Help",
            style: .plain,
            target: self,
            action: #selector(showContextualHelp)
        )

        viewController.navigationItem.rightBarButtonItem = helpButton
    }
}
```

### Focus Management

#### Logical Focus Order

```swift
extension UIViewController {
    func optimizeFocusOrder() {
        // Create logical focus order for healer workflow
        let focusOrder = [
            criticalAbilitiesSection,
            highPrioritySection,
            moderatePrioritySection,
            mechanicSection,
            actionButtons
        ].compactMap { $0 }

        // Set accessibility navigation order
        view.accessibilityElements = focusOrder
    }

    func configureFocusGuides() {
        // Create focus guides for complex layouts
        let focusGuide = UIFocusGuide()
        view.addLayoutGuide(focusGuide)

        // Guide focus from critical abilities to action buttons
        focusGuide.preferredFocusEnvironments = [actionButtons]

        NSLayoutConstraint.activate([
            focusGuide.leadingAnchor.constraint(equalTo: criticalAbilitiesSection.leadingAnchor),
            focusGuide.trailingAnchor.constraint(equalTo: criticalAbilitiesSection.trailingAnchor),
            focusGuide.topAnchor.constraint(equalTo: criticalAbilitiesSection.bottomAnchor),
            focusGuide.bottomAnchor.constraint(equalTo: actionButtons.topAnchor)
        ])
    }
}
```

## Testing and Validation

### Automated Accessibility Testing

#### Unit Testing Accessibility

```swift
class AccessibilityTests: XCTestCase {
    func testAbilityCardAccessibility() {
        let ability = createTestAbility()
        let card = AbilityCardView(ability: ability)

        // Test basic accessibility setup
        XCTAssertTrue(card.isAccessibilityElement)
        XCTAssertFalse(card.accessibilityLabel?.isEmpty ?? true)
        XCTAssertNotNil(card.accessibilityHint)

        // Test custom actions
        XCTAssertGreaterThan(card.accessibilityCustomActions?.count ?? 0, 0)

        // Test VoiceOver label quality
        let label = card.accessibilityLabel!
        XCTAssertTrue(label.contains(ability.name))
        XCTAssertTrue(label.contains(ability.damageProfile.rawValue))
    }

    func testColorContrastCompliance() {
        let colorScheme = HealerColorScheme.standard

        // Test all damage profile color combinations
        DamageProfile.allCases.forEach { profile in
            let colors = colorScheme.colors(for: profile)

            let textContrast = calculateContrastRatio(
                foreground: colors.textColor,
                background: colors.backgroundColor
            )

            XCTAssertGreaterThanOrEqual(
                textContrast,
                7.0,
                "Text contrast insufficient for \(profile.rawValue)"
            )

            let borderContrast = calculateContrastRatio(
                foreground: colors.borderColor,
                background: colors.backgroundColor
            )

            XCTAssertGreaterThanOrEqual(
                borderContrast,
                3.0,
                "Border contrast insufficient for \(profile.rawValue)"
            )
        }
    }

    func testTouchTargetSizes() {
        let viewController = createTestViewController()
        let interactiveElements = findInteractiveElements(in: viewController.view)

        interactiveElements.forEach { element in
            XCTAssertGreaterThanOrEqual(
                element.frame.width,
                44.0,
                "Touch target too narrow: \(element)"
            )

            XCTAssertGreaterThanOrEqual(
                element.frame.height,
                44.0,
                "Touch target too short: \(element)"
            )
        }
    }
}
```

#### Accessibility Audit Tool

```swift
class AccessibilityAuditor {
    struct AuditResult {
        let passedTests: Int
        let failedTests: Int
        let warnings: Int
        let issues: [AccessibilityIssue]
        let complianceLevel: WCAGComplianceLevel
    }

    func auditViewController(_ viewController: UIViewController) -> AuditResult {
        var issues: [AccessibilityIssue] = []

        // Test color contrast
        issues.append(contentsOf: auditColorContrast(viewController.view))

        // Test touch targets
        issues.append(contentsOf: auditTouchTargets(viewController.view))

        // Test VoiceOver support
        issues.append(contentsOf: auditVoiceOverSupport(viewController.view))

        // Test focus order
        issues.append(contentsOf: auditFocusOrder(viewController))

        // Calculate compliance level
        let complianceLevel = calculateComplianceLevel(issues)

        return AuditResult(
            passedTests: countPassedTests(issues),
            failedTests: countFailedTests(issues),
            warnings: countWarnings(issues),
            issues: issues,
            complianceLevel: complianceLevel
        )
    }
}
```

### Manual Testing Procedures

#### Screen Reader Testing Protocol

1. **Initial Setup**
   - Enable VoiceOver in iOS Settings
   - Set speech rate to comfortable level
   - Enable rotor control for navigation

2. **Navigation Testing**
   - Navigate through all main screens using swipe gestures
   - Test custom rotor functionality
   - Verify logical reading order

3. **Interaction Testing**
   - Test all custom actions on ability cards
   - Verify button activation with double-tap
   - Test long press alternatives for complex gestures

4. **Content Testing**
   - Verify all critical information is announced
   - Test damage profile announcements
   - Confirm healer action descriptions are clear

#### Motor Accessibility Testing

1. **Switch Control Testing**
   - Enable switch control in iOS Settings
   - Navigate through interface using switch input
   - Verify all functions are accessible via switches

2. **Voice Control Testing**
   - Enable voice control
   - Test number-based navigation
   - Verify custom voice commands for healer actions

3. **Touch Accommodation Testing**
   - Test with AssistiveTouch enabled
   - Verify touch targets are easily accessible
   - Test with reduced fine motor control simulation

### Accessibility Documentation

#### User Documentation

```markdown
# HealerKit Accessibility Features

## VoiceOver Support

HealerKit provides comprehensive VoiceOver support for screen reader users:

- **Ability Cards**: Each ability is announced with priority level, target type, and healer action
- **Custom Actions**: Long press any ability card to access healing strategies and cooldown reminders
- **Navigation**: Use rotor control to jump between damage profile categories
- **Shortcuts**: Three-finger triple-tap to show only critical abilities

## Visual Accessibility

### High Contrast Mode
Enable iOS High Contrast mode for enhanced visibility:
- Enhanced borders around all interactive elements
- Increased color saturation for damage profiles
- Alternative patterns for color-blind users

### Dynamic Type
HealerKit supports all iOS text sizes:
- Text scales automatically with your preferred size
- Layout adapts for accessibility text sizes
- Critical information remains readable at all sizes

## Motor Accessibility

### Switch Control
Complete interface navigation via switch control:
- Sequential navigation through all interactive elements
- Custom switch commands for common healer actions
- Configurable timing for different motor abilities

### Voice Control
Hands-free operation via voice commands:
- "Show critical abilities" - Filter to critical damage only
- "Ability one" through "Ability eight" - Access specific abilities
- "Next dungeon" / "Previous dungeon" - Navigate between dungeons
```

This comprehensive accessibility implementation ensures HealerKit is usable by healers with diverse abilities while maintaining the performance and clarity required for high-pressure Mythic+ encounters.