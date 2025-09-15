//
//  AbilityCardView.swift
//  HealerUIKit
//
//  Created by HealerKit on 2025-09-15.
//  Task T025: AbilityCardView Implementation
//

import UIKit
import AbilityKit

/// iPad-optimized ability card view for healer workflow
/// Displays ability information with color-coded damage profiles and touch optimization
public class AbilityCardView: UIView, AbilityCardViewProtocol {

    // MARK: - Protocol Properties

    public var ability: AbilityEntity {
        didSet {
            updateContent()
        }
    }

    public var classification: AbilityClassification {
        didSet {
            updateClassificationDisplay()
        }
    }

    public weak var delegate: AbilityCardDelegate?

    // MARK: - UI Components

    private let containerView = UIView()
    private let abilityNameLabel = UILabel()
    private let damageProfileIndicator = UIView()
    private let healerActionLabel = UILabel()
    private let criticalInsightLabel = UILabel()
    private let cooldownLabel = UILabel()
    private let urgencyBadge = UIView()
    private let urgencyBadgeLabel = UILabel()

    // MARK: - Display Mode

    private var currentDisplayMode: AbilityDisplayMode = .full

    // MARK: - Animation Properties

    private var attentionAnimationTimer: Timer?
    private let pulseLayer = CALayer()

    // MARK: - Constants

    private struct Constants {
        static let cornerRadius: CGFloat = 12.0
        static let minimumTouchTarget: CGFloat = 44.0
        static let standardMargin: CGFloat = 16.0
        static let compactMargin: CGFloat = 8.0
        static let animationDuration: TimeInterval = 0.3
        static let pulseAnimationDuration: TimeInterval = 1.5
        static let shadowOpacity: Float = 0.1
        static let shadowOffset = CGSize(width: 0, height: 2)
        static let shadowRadius: CGFloat = 4.0
    }

    // MARK: - Initialization

    public init(ability: AbilityEntity, classification: AbilityClassification) {
        self.ability = ability
        self.classification = classification
        super.init(frame: .zero)
        setupView()
        setupConstraints()
        setupGestures()
        updateContent()
        updateClassificationDisplay()

        // Cache this view for performance optimization
        let cacheKey = "abilityCard_\(ability.id?.uuidString ?? "")"
        let estimatedCost = 1024 // Estimate memory cost
        PerformanceManager.shared.cacheView(self, forKey: cacheKey, cost: estimatedCost)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        attentionAnimationTimer?.invalidate()
    }

    // MARK: - Setup Methods

    private func setupView() {
        backgroundColor = .clear

        // Container view setup with AppConfiguration
        let config = AppConfiguration.shared
        containerView.backgroundColor = config.color(for: .background("abilityCard"))
        containerView.layer.cornerRadius = AppConfiguration.Layout.CornerRadius.abilityCard
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = Constants.shadowOpacity
        containerView.layer.shadowOffset = Constants.shadowOffset
        containerView.layer.shadowRadius = Constants.shadowRadius
        containerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(containerView)

        // Ability name label setup with AppConfiguration
        abilityNameLabel.font = config.font(for: .abilityName, textStyle: .headline)
        abilityNameLabel.textColor = config.color(for: .text("primary"))
        abilityNameLabel.numberOfLines = 2
        abilityNameLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(abilityNameLabel)

        // Damage profile indicator setup
        damageProfileIndicator.layer.cornerRadius = 4.0
        damageProfileIndicator.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(damageProfileIndicator)

        // Healer action label setup with AppConfiguration
        healerActionLabel.font = config.font(for: .healerAction, textStyle: .body)
        healerActionLabel.textColor = config.color(for: .text("secondary"))
        healerActionLabel.numberOfLines = 0
        healerActionLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(healerActionLabel)

        // Critical insight label setup with AppConfiguration
        criticalInsightLabel.font = config.font(for: .criticalInsight, textStyle: .footnote)
        criticalInsightLabel.textColor = config.color(for: .text("critical"))
        criticalInsightLabel.numberOfLines = 0
        criticalInsightLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(criticalInsightLabel)

        // Cooldown label setup with AppConfiguration
        cooldownLabel.font = config.font(for: .secondaryText, textStyle: .caption1)
        cooldownLabel.textColor = config.color(for: .text("secondary"))
        cooldownLabel.textAlignment = .right
        cooldownLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(cooldownLabel)

        // Urgency badge setup
        urgencyBadge.backgroundColor = .systemRed
        urgencyBadge.layer.cornerRadius = 10.0
        urgencyBadge.isHidden = true
        urgencyBadge.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(urgencyBadge)

        urgencyBadgeLabel.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        urgencyBadgeLabel.textColor = .white
        urgencyBadgeLabel.textAlignment = .center
        urgencyBadgeLabel.translatesAutoresizingMaskIntoConstraints = false
        urgencyBadge.addSubview(urgencyBadgeLabel)

        // Setup pulse layer for attention animation
        pulseLayer.backgroundColor = UIColor.systemRed.withAlphaComponent(0.3).cgColor
        pulseLayer.cornerRadius = Constants.cornerRadius
        pulseLayer.isHidden = true
        containerView.layer.insertSublayer(pulseLayer, at: 0)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Container view constraints
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            containerView.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.minimumTouchTarget),

            // Ability name label constraints
            abilityNameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: Constants.standardMargin),
            abilityNameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constants.standardMargin),
            abilityNameLabel.trailingAnchor.constraint(equalTo: urgencyBadge.leadingAnchor, constant: -Constants.compactMargin),

            // Damage profile indicator constraints
            damageProfileIndicator.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constants.standardMargin),
            damageProfileIndicator.topAnchor.constraint(equalTo: abilityNameLabel.bottomAnchor, constant: Constants.compactMargin),
            damageProfileIndicator.widthAnchor.constraint(equalToConstant: 8),
            damageProfileIndicator.heightAnchor.constraint(equalToConstant: 20),

            // Healer action label constraints
            healerActionLabel.topAnchor.constraint(equalTo: abilityNameLabel.bottomAnchor, constant: Constants.compactMargin),
            healerActionLabel.leadingAnchor.constraint(equalTo: damageProfileIndicator.trailingAnchor, constant: Constants.compactMargin),
            healerActionLabel.trailingAnchor.constraint(equalTo: cooldownLabel.leadingAnchor, constant: -Constants.compactMargin),

            // Critical insight label constraints (will be shown/hidden based on display mode)
            criticalInsightLabel.topAnchor.constraint(equalTo: healerActionLabel.bottomAnchor, constant: Constants.compactMargin),
            criticalInsightLabel.leadingAnchor.constraint(equalTo: healerActionLabel.leadingAnchor),
            criticalInsightLabel.trailingAnchor.constraint(equalTo: healerActionLabel.trailingAnchor),
            criticalInsightLabel.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -Constants.standardMargin),

            // Cooldown label constraints
            cooldownLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: Constants.standardMargin),
            cooldownLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constants.standardMargin),
            cooldownLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 60),

            // Urgency badge constraints
            urgencyBadge.topAnchor.constraint(equalTo: containerView.topAnchor, constant: Constants.compactMargin),
            urgencyBadge.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constants.compactMargin),
            urgencyBadge.widthAnchor.constraint(equalToConstant: 20),
            urgencyBadge.heightAnchor.constraint(equalToConstant: 20),

            // Urgency badge label constraints
            urgencyBadgeLabel.centerXAnchor.constraint(equalTo: urgencyBadge.centerXAnchor),
            urgencyBadgeLabel.centerYAnchor.constraint(equalTo: urgencyBadge.centerYAnchor)
        ])
    }

    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGesture)

        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        longPressGesture.minimumPressDuration = 0.5
        addGestureRecognizer(longPressGesture)

        isUserInteractionEnabled = true
    }

    // MARK: - Content Update Methods

    private func updateContent() {
        abilityNameLabel.text = ability.name
        healerActionLabel.text = ability.healerAction
        criticalInsightLabel.text = ability.criticalInsight

        // Update cooldown display
        if let cooldown = ability.cooldown, cooldown > 0 {
            let minutes = Int(cooldown / 60)
            let seconds = Int(cooldown.truncatingRemainder(dividingBy: 60))
            if minutes > 0 {
                cooldownLabel.text = "\(minutes)m \(seconds)s"
            } else {
                cooldownLabel.text = "\(seconds)s"
            }
            cooldownLabel.isHidden = false
        } else {
            cooldownLabel.isHidden = true
        }

        updateDamageProfileDisplay()
    }

    private func updateDamageProfileDisplay() {
        let damageProfile = ability.damageProfile

        // Update damage profile indicator color using AppConfiguration
        let config = AppConfiguration.shared
        switch damageProfile {
        case .critical:
            damageProfileIndicator.backgroundColor = config.color(for: .damageProfile("critical"))
        case .high:
            damageProfileIndicator.backgroundColor = config.color(for: .damageProfile("high"))
        case .moderate:
            damageProfileIndicator.backgroundColor = config.color(for: .damageProfile("moderate"))
        case .mechanic:
            damageProfileIndicator.backgroundColor = config.color(for: .damageProfile("mechanic"))
        }
    }

    private func updateClassificationDisplay() {
        // Update urgency badge based on classification
        switch classification.urgency {
        case .immediate:
            urgencyBadge.isHidden = false
            urgencyBadge.backgroundColor = .systemRed
            urgencyBadgeLabel.text = "!"
        case .high:
            urgencyBadge.isHidden = false
            urgencyBadge.backgroundColor = .systemOrange
            urgencyBadgeLabel.text = "H"
        default:
            urgencyBadge.isHidden = true
        }

        // Update card emphasis based on healer impact
        switch classification.healerImpact {
        case .critical:
            containerView.layer.borderWidth = 2.0
            containerView.layer.borderColor = HealerColorScheme.shared.criticalDamageColor.cgColor
        case .high:
            containerView.layer.borderWidth = 1.0
            containerView.layer.borderColor = HealerColorScheme.shared.highDamageColor.cgColor
        default:
            containerView.layer.borderWidth = 0.0
        }
    }

    // MARK: - AbilityCardViewProtocol Implementation

    public func updateDisplayMode(_ mode: AbilityDisplayMode) {
        currentDisplayMode = mode

        let animationDuration = AppConfiguration.shared.animationDuration(for: .cardTransition)
        UIView.animate(withDuration: animationDuration) { [weak self] in
            self?.applyDisplayMode(mode)
        }
    }

    private func applyDisplayMode(_ mode: AbilityDisplayMode) {
        switch mode {
        case .full:
            healerActionLabel.isHidden = false
            criticalInsightLabel.isHidden = false
            cooldownLabel.isHidden = ability.cooldown == nil

        case .compact:
            healerActionLabel.isHidden = false
            criticalInsightLabel.isHidden = true
            cooldownLabel.isHidden = ability.cooldown == nil

        case .minimal:
            healerActionLabel.isHidden = true
            criticalInsightLabel.isHidden = true
            cooldownLabel.isHidden = true
        }

        setNeedsLayout()
        layoutIfNeeded()
    }

    public func animateAttention() {
        // Stop any existing animation
        attentionAnimationTimer?.invalidate()
        pulseLayer.removeAllAnimations()

        // Only animate for critical abilities
        guard classification.urgency == .immediate || classification.healerImpact == .critical else {
            return
        }

        pulseLayer.isHidden = false
        pulseLayer.frame = containerView.bounds

        // Create pulsing animation
        let pulseAnimation = CAAnimationGroup()
        pulseAnimation.duration = Constants.pulseAnimationDuration
        pulseAnimation.repeatCount = .infinity

        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.fromValue = 1.0
        scaleAnimation.toValue = 1.1
        scaleAnimation.autoreverses = true

        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = 0.3
        opacityAnimation.toValue = 0.7
        opacityAnimation.autoreverses = true

        pulseAnimation.animations = [scaleAnimation, opacityAnimation]
        pulseLayer.add(pulseAnimation, forKey: "pulse")

        // Auto-stop after 10 seconds to avoid battery drain
        attentionAnimationTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: false) { [weak self] _ in
            self?.stopAttentionAnimation()
        }
    }

    private func stopAttentionAnimation() {
        attentionAnimationTimer?.invalidate()
        attentionAnimationTimer = nil

        UIView.animate(withDuration: Constants.animationDuration) { [weak self] in
            self?.pulseLayer.opacity = 0
        } completion: { [weak self] _ in
            self?.pulseLayer.isHidden = true
            self?.pulseLayer.removeAllAnimations()
        }
    }

    // MARK: - Gesture Handlers

    @objc private func handleTap() {
        // Provide haptic feedback for critical abilities
        if classification.urgency == .immediate {
            let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
            impactFeedback.impactOccurred()
        }

        delegate?.abilityCardDidTap(ability)
    }

    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            // Provide haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()

            delegate?.abilityCardDidLongPress(ability)
        }
    }

    // MARK: - Layout

    public override func layoutSubviews() {
        super.layoutSubviews()
        pulseLayer.frame = containerView.bounds
    }

    // MARK: - Accessibility

    public override var accessibilityLabel: String? {
        get {
            let damageLevel = ability.damageProfile.rawValue
            let urgencyText = classification.urgency == .immediate ? "Critical" : ""
            return "\(urgencyText) \(ability.name), \(damageLevel) damage, \(ability.healerAction)"
        }
        set { }
    }

    public override var accessibilityTraits: UIAccessibilityTraits {
        get { [.button, classification.urgency == .immediate ? .startsMediaSession : []] }
        set { }
    }
}

// MARK: - AbilityCardDelegate Protocol

public protocol AbilityCardDelegate: AnyObject {
    func abilityCardDidTap(_ ability: AbilityEntity)
    func abilityCardDidRequestDetails(_ ability: AbilityEntity)
    func abilityCardDidLongPress(_ ability: AbilityEntity)
}

// MARK: - Display Mode Enum

public enum AbilityDisplayMode {
    case full       // Complete information display
    case compact    // Condensed for list views
    case minimal    // Name and damage profile only
}

// MARK: - Color and Typography Extensions

private extension HealerColorScheme {
    static let shared = HealerColorScheme(
        criticalDamageColor: UIColor(red: 0.96, green: 0.42, blue: 0.42, alpha: 1.0), // #F56B6B
        highDamageColor: UIColor(red: 1.0, green: 0.65, blue: 0.31, alpha: 1.0),     // #FFA64F
        moderateDamageColor: UIColor(red: 1.0, green: 0.86, blue: 0.35, alpha: 1.0), // #FFDC59
        mechanicColor: UIColor(red: 0.35, green: 0.67, blue: 1.0, alpha: 1.0),       // #59ABFF
        primaryBackgroundColor: UIColor.systemBackground,
        secondaryBackgroundColor: UIColor.secondarySystemBackground,
        cardBackgroundColor: UIColor.systemBackground,
        primaryTextColor: UIColor.label,
        secondaryTextColor: UIColor.secondaryLabel,
        accentTextColor: UIColor.systemBlue,
        buttonTintColor: UIColor.systemBlue,
        selectionColor: UIColor.systemBlue.withAlphaComponent(0.2),
        separatorColor: UIColor.separator
    )
}

private extension HealerTypography {
    static let shared = HealerTypography(
        dungeonNameFont: UIFont.preferredFont(forTextStyle: .title2),
        bossNameFont: UIFont.preferredFont(forTextStyle: .title3),
        abilityNameFont: UIFont.preferredFont(forTextStyle: .headline),
        healerActionFont: UIFont.preferredFont(forTextStyle: .body),
        insightFont: UIFont.preferredFont(forTextStyle: .footnote),
        summaryFont: UIFont.preferredFont(forTextStyle: .body),
        supportsDynamicType: true,
        maximumPointSize: 28.0,
        minimumPointSize: 12.0
    )
}

// MARK: - Helper Structs (temporary implementation for compilation)

private struct HealerColorScheme {
    let criticalDamageColor: UIColor
    let highDamageColor: UIColor
    let moderateDamageColor: UIColor
    let mechanicColor: UIColor
    let primaryBackgroundColor: UIColor
    let secondaryBackgroundColor: UIColor
    let cardBackgroundColor: UIColor
    let primaryTextColor: UIColor
    let secondaryTextColor: UIColor
    let accentTextColor: UIColor
    let buttonTintColor: UIColor
    let selectionColor: UIColor
    let separatorColor: UIColor
}

private struct HealerTypography {
    let dungeonNameFont: UIFont
    let bossNameFont: UIFont
    let abilityNameFont: UIFont
    let healerActionFont: UIFont
    let insightFont: UIFont
    let summaryFont: UIFont
    let supportsDynamicType: Bool
    let maximumPointSize: CGFloat
    let minimumPointSize: CGFloat
}