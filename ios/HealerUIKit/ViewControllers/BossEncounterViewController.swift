//
//  BossEncounterViewController.swift
//  HealerUIKit
//
//  Created by HealerKit on 2025-09-15.
//

import UIKit
import Foundation

/// iPad-optimized boss encounter view controller for healer workflow
/// Displays encounter details with color-coded ability cards and filtering capabilities
public final class BossEncounterViewController: UIViewController {

    // MARK: - Properties

    /// Current boss encounter data
    public var encounter: any BossEncounterEntity {
        didSet {
            updateEncounterUI()
        }
    }

    /// Current ability data
    public var abilities: [any AbilityEntity] = [] {
        didSet {
            updateAbilitiesUI()
        }
    }

    /// Delegate for handling encounter interactions
    public weak var delegate: BossEncounterDelegate?

    // MARK: - Private Properties

    private var scrollView: UIScrollView!
    private var contentView: UIView!
    private var headerView: UIView!
    private var encounterNameLabel: UILabel!
    private var encounterSummaryLabel: UILabel!
    private var filterSegmentedControl: UISegmentedControl!
    private var abilitiesCollectionView: UICollectionView!

    private var filteredAbilities: [any AbilityEntity] = []
    private var currentDamageProfileFilter: DamageProfile?

    // iPad-specific layout constants
    private struct Layout {
        static let minimumTouchTarget: CGFloat = 44.0
        static let cardCornerRadius: CGFloat = 12.0
        static let standardMargin: CGFloat = 16.0
        static let compactMargin: CGFloat = 8.0
        static let cardSpacing: CGFloat = 12.0
        static let headerHeight: CGFloat = 200.0

        // Grid configuration for ability cards
        static let portraitColumns = 2
        static let landscapeColumns = 3
    }

    // Color scheme for damage profiles
    private struct Colors {
        static let criticalColor = UIColor.systemRed
        static let highColor = UIColor.systemOrange
        static let moderateColor = UIColor.systemYellow
        static let mechanicColor = UIColor.systemBlue
    }

    // MARK: - Initialization

    public init(encounter: any BossEncounterEntity, abilities: [any AbilityEntity]) {
        self.encounter = encounter
        self.abilities = abilities
        self.filteredAbilities = abilities
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        updateEncounterUI()
        updateAbilitiesUI()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateLayoutForCurrentOrientation()
    }

    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: { [weak self] _ in
            self?.updateLayoutForCurrentOrientation()
        }, completion: nil)
    }

    // MARK: - Setup Methods

    private func setupUI() {
        title = encounter.name
        view.backgroundColor = .systemBackground

        setupScrollView()
        setupHeaderView()
        setupFilterControls()
        setupAbilitiesCollectionView()
        setupNavigationBar()
    }

    private func setupScrollView() {
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)

        contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
    }

    private func setupHeaderView() {
        headerView = UIView()
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.backgroundColor = .secondarySystemBackground
        headerView.layer.cornerRadius = Layout.cardCornerRadius
        contentView.addSubview(headerView)

        // Encounter name label
        encounterNameLabel = UILabel()
        encounterNameLabel.translatesAutoresizingMaskIntoConstraints = false
        encounterNameLabel.font = .preferredFont(forTextStyle: .largeTitle)
        encounterNameLabel.adjustsFontForContentSizeCategory = true
        encounterNameLabel.numberOfLines = 0
        headerView.addSubview(encounterNameLabel)

        // Encounter summary label
        encounterSummaryLabel = UILabel()
        encounterSummaryLabel.translatesAutoresizingMaskIntoConstraints = false
        encounterSummaryLabel.font = .preferredFont(forTextStyle: .body)
        encounterSummaryLabel.adjustsFontForContentSizeCategory = true
        encounterSummaryLabel.numberOfLines = 0
        encounterSummaryLabel.textColor = .secondaryLabel
        headerView.addSubview(encounterSummaryLabel)
    }

    private func setupFilterControls() {
        filterSegmentedControl = UISegmentedControl(items: [
            "All", "Critical", "High", "Moderate", "Mechanic"
        ])
        filterSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        filterSegmentedControl.selectedSegmentIndex = 0
        filterSegmentedControl.addTarget(self, action: #selector(filterChanged(_:)), for: .valueChanged)

        // Configure for iPad
        filterSegmentedControl.apportionsSegmentWidthsByContent = true
        contentView.addSubview(filterSegmentedControl)
    }

    private func setupAbilitiesCollectionView() {
        let layout = createAbilitiesCollectionViewLayout()
        abilitiesCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        abilitiesCollectionView.translatesAutoresizingMaskIntoConstraints = false
        abilitiesCollectionView.backgroundColor = .clear
        abilitiesCollectionView.delegate = self
        abilitiesCollectionView.dataSource = self
        abilitiesCollectionView.showsVerticalScrollIndicator = false

        // Register cells
        abilitiesCollectionView.register(AbilityCardCell.self, forCellWithReuseIdentifier: AbilityCardCell.identifier)

        contentView.addSubview(abilitiesCollectionView)
    }

    private func setupNavigationBar() {
        // Share/export button
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .action,
            target: self,
            action: #selector(shareButtonTapped)
        )
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Scroll view
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // Content view
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            // Header view
            headerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Layout.standardMargin),
            headerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Layout.standardMargin),
            headerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Layout.standardMargin),

            // Encounter name label
            encounterNameLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: Layout.standardMargin),
            encounterNameLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: Layout.standardMargin),
            encounterNameLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -Layout.standardMargin),

            // Encounter summary label
            encounterSummaryLabel.topAnchor.constraint(equalTo: encounterNameLabel.bottomAnchor, constant: Layout.compactMargin),
            encounterSummaryLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: Layout.standardMargin),
            encounterSummaryLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -Layout.standardMargin),
            encounterSummaryLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -Layout.standardMargin),

            // Filter controls
            filterSegmentedControl.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: Layout.standardMargin),
            filterSegmentedControl.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Layout.standardMargin),
            filterSegmentedControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Layout.standardMargin),
            filterSegmentedControl.heightAnchor.constraint(equalToConstant: Layout.minimumTouchTarget),

            // Abilities collection view
            abilitiesCollectionView.topAnchor.constraint(equalTo: filterSegmentedControl.bottomAnchor, constant: Layout.standardMargin),
            abilitiesCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Layout.standardMargin),
            abilitiesCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Layout.standardMargin),
            abilitiesCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Layout.standardMargin),
            abilitiesCollectionView.heightAnchor.constraint(greaterThanOrEqualToConstant: 400) // Minimum height for abilities
        ])
    }

    private func createAbilitiesCollectionViewLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = Layout.cardSpacing
        layout.minimumInteritemSpacing = Layout.cardSpacing

        updateAbilitiesLayoutItemSize(layout)
        return layout
    }

    private func updateAbilitiesLayoutItemSize(_ layout: UICollectionViewFlowLayout) {
        let orientation = UIDevice.current.orientation
        let columns = orientation.isLandscape ? Layout.landscapeColumns : Layout.portraitColumns

        let availableWidth = view.frame.width - (Layout.standardMargin * 4) // Extra margin for scroll view
        let totalSpacing = CGFloat(columns - 1) * Layout.cardSpacing
        let itemWidth = (availableWidth - totalSpacing) / CGFloat(columns)

        // Ability cards need more height for content
        let itemHeight = max(Layout.minimumTouchTarget * 3, itemWidth * 0.8)

        layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
    }

    // MARK: - Public Methods

    public func updateAbilities(_ abilities: [any AbilityEntity]) {
        self.abilities = abilities
        applyCurrentFilter()
    }

    public func highlightAbility(_ abilityId: UUID) {
        guard let index = filteredAbilities.firstIndex(where: { $0.id == abilityId }) else { return }

        let indexPath = IndexPath(row: index, section: 0)
        abilitiesCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredVertically)

        // Flash the cell to draw attention
        if let cell = abilitiesCollectionView.cellForItem(at: indexPath) as? AbilityCardCell {
            cell.flashAttention()
        }
    }

    public func filterAbilities(by damageProfile: DamageProfile?) {
        currentDamageProfileFilter = damageProfile

        // Update segmented control
        let segmentIndex: Int
        switch damageProfile {
        case .none:
            segmentIndex = 0
        case .critical:
            segmentIndex = 1
        case .high:
            segmentIndex = 2
        case .moderate:
            segmentIndex = 3
        case .mechanic:
            segmentIndex = 4
        }

        filterSegmentedControl.selectedSegmentIndex = segmentIndex
        applyCurrentFilter()
    }

    // MARK: - Private Methods

    private func updateEncounterUI() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.title = self.encounter.name
            self.encounterNameLabel.text = self.encounter.name

            // Use healerSummary if available, otherwise use a placeholder
            let summaryText: String
            if let bossWithSummary = self.encounter as? BossWithSummaryEntity {
                summaryText = bossWithSummary.healerSummary
            } else {
                summaryText = "Boss encounter \(self.encounter.encounterOrder) in the dungeon. Prepare for challenging mechanics requiring healer coordination."
            }
            self.encounterSummaryLabel.text = summaryText
        }
    }

    private func updateAbilitiesUI() {
        applyCurrentFilter()
    }

    private func updateLayoutForCurrentOrientation() {
        guard let layout = abilitiesCollectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        updateAbilitiesLayoutItemSize(layout)
        layout.invalidateLayout()
    }

    private func applyCurrentFilter() {
        let filtered: [any AbilityEntity]

        if let damageProfile = currentDamageProfileFilter {
            filtered = abilities.filter { ability in
                if let abilityWithProfile = ability as? AbilityWithProfileEntity {
                    return abilityWithProfile.damageProfile == damageProfile
                }
                return false
            }
        } else {
            filtered = abilities
        }

        filteredAbilities = filtered

        DispatchQueue.main.async { [weak self] in
            self?.abilitiesCollectionView.reloadData()
        }

        // Notify delegate of filter change
        delegate?.bossEncounterDidToggleFilter(currentDamageProfileFilter)
    }

    private func colorForDamageProfile(_ damageProfile: DamageProfile) -> UIColor {
        switch damageProfile {
        case .critical:
            return Colors.criticalColor
        case .high:
            return Colors.highColor
        case .moderate:
            return Colors.moderateColor
        case .mechanic:
            return Colors.mechanicColor
        }
    }

    // MARK: - Actions

    @objc private func filterChanged(_ sender: UISegmentedControl) {
        let damageProfile: DamageProfile?

        switch sender.selectedSegmentIndex {
        case 0:
            damageProfile = nil
        case 1:
            damageProfile = .critical
        case 2:
            damageProfile = .high
        case 3:
            damageProfile = .moderate
        case 4:
            damageProfile = .mechanic
        default:
            damageProfile = nil
        }

        currentDamageProfileFilter = damageProfile
        applyCurrentFilter()
    }

    @objc private func shareButtonTapped() {
        // Future implementation for sharing encounter details
        let alert = UIAlertController(title: "Share Encounter", message: "Export encounter details for team coordination", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        if let popover = alert.popoverPresentationController {
            popover.barButtonItem = navigationItem.rightBarButtonItem
        }

        present(alert, animated: true)
    }
}

// MARK: - UICollectionViewDataSource

extension BossEncounterViewController: UICollectionViewDataSource {

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredAbilities.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AbilityCardCell.identifier, for: indexPath) as! AbilityCardCell

        let ability = filteredAbilities[indexPath.row]
        cell.configure(with: ability)

        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension BossEncounterViewController: UICollectionViewDelegate {

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let ability = filteredAbilities[indexPath.row]
        delegate?.bossEncounterDidSelectAbility(ability)

        // Provide haptic feedback for iPad
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension BossEncounterViewController: UICollectionViewDelegateFlowLayout {

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let layout = collectionViewLayout as? UICollectionViewFlowLayout else {
            return CGSize(width: 200, height: 160)
        }

        return layout.itemSize
    }
}

// MARK: - BossEncounterViewControllerProtocol Conformance

extension BossEncounterViewController: BossEncounterViewControllerProtocol {
    // Protocol conformance is handled by the existing implementation
}

// MARK: - Ability Card Cell Implementation

private class AbilityCardCell: UICollectionViewCell {
    static let identifier = "AbilityCardCell"

    // MARK: - UI Elements

    private let containerView = UIView()
    private let nameLabel = UILabel()
    private let damageProfileIndicator = UIView()
    private let healerActionLabel = UILabel()
    private let criticalInsightLabel = UILabel()
    private let cooldownLabel = UILabel()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupUI() {
        // Container view styling
        containerView.backgroundColor = .secondarySystemBackground
        containerView.layer.cornerRadius = BossEncounterViewController.Layout.cardCornerRadius
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowOpacity = 0.15
        containerView.layer.shadowRadius = 4

        // Damage profile indicator
        damageProfileIndicator.layer.cornerRadius = 4
        damageProfileIndicator.translatesAutoresizingMaskIntoConstraints = false

        // Configure labels
        nameLabel.font = .preferredFont(forTextStyle: .headline)
        nameLabel.adjustsFontForContentSizeCategory = true
        nameLabel.numberOfLines = 2

        healerActionLabel.font = .preferredFont(forTextStyle: .subheadline)
        healerActionLabel.textColor = .label
        healerActionLabel.numberOfLines = 2

        criticalInsightLabel.font = .preferredFont(forTextStyle: .caption1)
        criticalInsightLabel.textColor = .secondaryLabel
        criticalInsightLabel.numberOfLines = 3

        cooldownLabel.font = .preferredFont(forTextStyle: .caption2)
        cooldownLabel.textColor = .tertiaryLabel

        // Add subviews
        contentView.addSubview(containerView)
        [damageProfileIndicator, nameLabel, healerActionLabel, criticalInsightLabel, cooldownLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview($0)
        }

        containerView.translatesAutoresizingMaskIntoConstraints = false
    }

    private func setupConstraints() {
        let margin: CGFloat = 12

        NSLayoutConstraint.activate([
            // Container view
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            // Damage profile indicator
            damageProfileIndicator.topAnchor.constraint(equalTo: containerView.topAnchor, constant: margin),
            damageProfileIndicator.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: margin),
            damageProfileIndicator.widthAnchor.constraint(equalToConstant: 24),
            damageProfileIndicator.heightAnchor.constraint(equalToConstant: 8),

            // Name label
            nameLabel.topAnchor.constraint(equalTo: damageProfileIndicator.bottomAnchor, constant: 4),
            nameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: margin),
            nameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -margin),

            // Healer action label
            healerActionLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            healerActionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: margin),
            healerActionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -margin),

            // Critical insight label
            criticalInsightLabel.topAnchor.constraint(equalTo: healerActionLabel.bottomAnchor, constant: 4),
            criticalInsightLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: margin),
            criticalInsightLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -margin),

            // Cooldown label
            cooldownLabel.topAnchor.constraint(greaterThanOrEqualTo: criticalInsightLabel.bottomAnchor, constant: 4),
            cooldownLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -margin),
            cooldownLabel.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -margin)
        ])
    }

    // MARK: - Configuration

    func configure(with ability: any AbilityEntity) {
        nameLabel.text = ability.name

        // Configure based on available properties
        if let abilityWithDetails = ability as? AbilityWithDetailsEntity {
            healerActionLabel.text = abilityWithDetails.healerAction
            criticalInsightLabel.text = abilityWithDetails.criticalInsight

            if let cooldown = abilityWithDetails.cooldown, cooldown > 0 {
                cooldownLabel.text = String(format: "%.0fs CD", cooldown)
            } else {
                cooldownLabel.text = ""
            }

            // Set damage profile color
            let color = colorForDamageProfile(abilityWithDetails.damageProfile)
            damageProfileIndicator.backgroundColor = color
        } else {
            // Fallback for basic ability entities
            healerActionLabel.text = "Healer action required"
            criticalInsightLabel.text = "Review ability details"
            cooldownLabel.text = ""
            damageProfileIndicator.backgroundColor = .systemGray
        }
    }

    private func colorForDamageProfile(_ damageProfile: DamageProfile) -> UIColor {
        switch damageProfile {
        case .critical:
            return .systemRed
        case .high:
            return .systemOrange
        case .moderate:
            return .systemYellow
        case .mechanic:
            return .systemBlue
        }
    }

    func flashAttention() {
        UIView.animate(withDuration: 0.3, animations: {
            self.containerView.backgroundColor = .systemBlue.withAlphaComponent(0.3)
        }) { _ in
            UIView.animate(withDuration: 0.3) {
                self.containerView.backgroundColor = .secondarySystemBackground
            }
        }
    }

    // MARK: - Selection Handling

    override var isSelected: Bool {
        didSet {
            UIView.animate(withDuration: 0.2) {
                self.containerView.backgroundColor = self.isSelected ? .systemBlue.withAlphaComponent(0.1) : .secondarySystemBackground
                self.containerView.layer.borderWidth = self.isSelected ? 2 : 0
                self.containerView.layer.borderColor = self.isSelected ? UIColor.systemBlue.cgColor : UIColor.clear.cgColor
            }
        }
    }

    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.1) {
                self.containerView.alpha = self.isHighlighted ? 0.8 : 1.0
            }
        }
    }
}

// MARK: - Protocol Definitions

/// Delegate protocol for boss encounter interactions
public protocol BossEncounterDelegate: AnyObject {
    func bossEncounterDidSelectAbility(_ ability: any AbilityEntity)
    func bossEncounterDidRequestAbilityDetails(_ ability: any AbilityEntity)
    func bossEncounterDidToggleFilter(_ damageProfile: DamageProfile?)
}

/// Protocol defining the public interface for BossEncounterViewController
public protocol BossEncounterViewControllerProtocol: UIViewController {
    var encounter: any BossEncounterEntity { get set }
    var abilities: [any AbilityEntity] { get set }
    var delegate: BossEncounterDelegate? { get set }

    func updateAbilities(_ abilities: [any AbilityEntity])
    func highlightAbility(_ abilityId: UUID)
    func filterAbilities(by damageProfile: DamageProfile?)
}

// MARK: - Extended Entity Protocols

/// Extended protocol for boss entities with healer summary
public protocol BossWithSummaryEntity: BossEncounterEntity {
    var healerSummary: String { get }
}

/// Extended protocol for abilities with detailed information
public protocol AbilityWithDetailsEntity: AbilityEntity {
    var healerAction: String { get }
    var criticalInsight: String { get }
    var cooldown: TimeInterval? { get }
}

/// Extended protocol for abilities with damage profile information
public protocol AbilityWithProfileEntity: AbilityEntity {
    var damageProfile: DamageProfile { get }
}

// MARK: - Shared Types
// DamageProfile is now provided by HealerKitCore
