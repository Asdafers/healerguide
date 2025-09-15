//
//  DungeonListViewController.swift
//  HealerUIKit
//
//  Created by HealerKit on 2025-09-15.
//

import UIKit
import Foundation

/// iPad-optimized dungeon list view controller for healer workflow
/// Provides grid/list layout with touch-friendly navigation and split view support
public final class DungeonListViewController: UIViewController {

    // MARK: - Properties

    /// Current dungeon data
    public var dungeons: [any DungeonEntity] = [] {
        didSet {
            updateUI()
        }
    }

    /// Delegate for handling dungeon selection events
    public weak var delegate: DungeonListDelegate?

    // MARK: - Private Properties

    private var collectionView: UICollectionView!
    private var searchController: UISearchController!
    private var filteredDungeons: [any DungeonEntity] = []
    private var isSearchActive: Bool {
        return searchController.isActive && !searchController.searchBar.text!.isEmpty
    }

    // iPad-specific layout constants
    private struct Layout {
        static let minimumTouchTarget: CGFloat = 44.0
        static let cardCornerRadius: CGFloat = 12.0
        static let standardMargin: CGFloat = 16.0
        static let compactMargin: CGFloat = 8.0
        static let cardSpacing: CGFloat = 12.0

        // Grid configuration for different orientations
        static let portraitColumns = 2
        static let landscapeColumns = 3
    }

    // MARK: - Lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupSearchController()
        updateUI()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateLayoutForCurrentOrientation()
    }

    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: { [weak self] _ in
            self?.updateLayout(for: UIDevice.current.orientation.isLandscape ? .landscapeLeft : .portrait)
        }, completion: nil)
    }

    // MARK: - Setup Methods

    private func setupUI() {
        title = "Mythic+ Dungeons"
        view.backgroundColor = .systemBackground

        setupCollectionView()
        setupNavigationBar()
    }

    private func setupCollectionView() {
        let layout = createCollectionViewLayout()
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self

        // Register cell
        collectionView.register(DungeonCardCell.self, forCellWithReuseIdentifier: DungeonCardCell.identifier)

        view.addSubview(collectionView)
    }

    private func setupNavigationBar() {
        // Refresh button
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .refresh,
            target: self,
            action: #selector(refreshButtonTapped)
        )

        // Search button for split view compatibility
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .search,
            target: self,
            action: #selector(searchButtonTapped)
        )
    }

    private func setupSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search dungeons..."

        // Configure for iPad
        searchController.searchBar.searchBarStyle = .minimal
        searchController.hidesNavigationBarDuringPresentation = false

        navigationItem.searchController = searchController
        definesPresentationContext = true
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Layout.standardMargin),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Layout.standardMargin),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func createCollectionViewLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = Layout.cardSpacing
        layout.minimumInteritemSpacing = Layout.cardSpacing
        layout.sectionInset = UIEdgeInsets(
            top: Layout.standardMargin,
            left: 0,
            bottom: Layout.standardMargin,
            right: 0
        )

        updateLayoutItemSize(layout)
        return layout
    }

    private func updateLayoutItemSize(_ layout: UICollectionViewFlowLayout) {
        let orientation = UIDevice.current.orientation
        let columns = orientation.isLandscape ? Layout.landscapeColumns : Layout.portraitColumns

        let availableWidth = view.frame.width - (Layout.standardMargin * 2)
        let totalSpacing = CGFloat(columns - 1) * Layout.cardSpacing
        let itemWidth = (availableWidth - totalSpacing) / CGFloat(columns)

        // Ensure minimum touch target compliance
        let itemHeight = max(Layout.minimumTouchTarget * 2, itemWidth * 0.6)

        layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
    }

    // MARK: - Public Methods

    public func refreshDungeonData() {
        delegate?.dungeonListDidRequestRefresh()
    }

    public func selectDungeon(_ dungeon: any DungeonEntity) {
        // Find and select the dungeon in collection view
        guard let index = getCurrentDungeons().firstIndex(where: { $0.id == dungeon.id }) else { return }

        let indexPath = IndexPath(row: index, section: 0)
        collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredVertically)

        delegate?.dungeonListDidSelectDungeon(dungeon)
    }

    public func updateLayout(for orientation: UIInterfaceOrientation) {
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        updateLayoutItemSize(layout)
        layout.invalidateLayout()
    }

    // MARK: - Private Methods

    private func updateUI() {
        DispatchQueue.main.async { [weak self] in
            self?.filteredDungeons = self?.dungeons ?? []
            self?.collectionView?.reloadData()
        }
    }

    private func updateLayoutForCurrentOrientation() {
        let orientation = UIDevice.current.orientation
        let targetOrientation: UIInterfaceOrientation = orientation.isLandscape ? .landscapeLeft : .portrait
        updateLayout(for: targetOrientation)
    }

    private func getCurrentDungeons() -> [any DungeonEntity] {
        return isSearchActive ? filteredDungeons : dungeons
    }

    private func filterDungeonsForSearchText(_ searchText: String) {
        filteredDungeons = dungeons.filter { dungeon in
            dungeon.name.localizedCaseInsensitiveContains(searchText) ||
            dungeon.shortName.localizedCaseInsensitiveContains(searchText)
        }

        DispatchQueue.main.async { [weak self] in
            self?.collectionView.reloadData()
        }
    }

    // MARK: - Actions

    @objc private func refreshButtonTapped() {
        refreshDungeonData()
    }

    @objc private func searchButtonTapped() {
        delegate?.dungeonListDidRequestSearch()
    }
}

// MARK: - UICollectionViewDataSource

extension DungeonListViewController: UICollectionViewDataSource {

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return getCurrentDungeons().count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DungeonCardCell.identifier, for: indexPath) as! DungeonCardCell

        let dungeon = getCurrentDungeons()[indexPath.row]
        cell.configure(with: dungeon)

        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension DungeonListViewController: UICollectionViewDelegate {

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let dungeon = getCurrentDungeons()[indexPath.row]
        delegate?.dungeonListDidSelectDungeon(dungeon)

        // Provide haptic feedback for iPad
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension DungeonListViewController: UICollectionViewDelegateFlowLayout {

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let layout = collectionViewLayout as? UICollectionViewFlowLayout else {
            return CGSize(width: 200, height: 120)
        }

        return layout.itemSize
    }
}

// MARK: - UISearchResultsUpdating

extension DungeonListViewController: UISearchResultsUpdating {

    public func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }

        if searchText.isEmpty {
            filteredDungeons = dungeons
        } else {
            filterDungeonsForSearchText(searchText)
        }
    }
}

// MARK: - DungeonListViewControllerProtocol Conformance

extension DungeonListViewController: DungeonListViewControllerProtocol {
    // Protocol conformance is handled by the existing implementation
}

// MARK: - Custom Cell Implementation

private class DungeonCardCell: UICollectionViewCell {
    static let identifier = "DungeonCardCell"

    // MARK: - UI Elements

    private let containerView = UIView()
    private let nameLabel = UILabel()
    private let shortNameLabel = UILabel()
    private let difficultyLabel = UILabel()
    private let bossCountLabel = UILabel()
    private let durationLabel = UILabel()
    private let notesLabel = UILabel()

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
        containerView.layer.cornerRadius = DungeonListViewController.Layout.cardCornerRadius
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowOpacity = 0.1
        containerView.layer.shadowRadius = 4

        // Configure labels
        nameLabel.font = .preferredFont(forTextStyle: .headline)
        nameLabel.adjustsFontForContentSizeCategory = true
        nameLabel.numberOfLines = 2

        shortNameLabel.font = .preferredFont(forTextStyle: .subheadline)
        shortNameLabel.textColor = .secondaryLabel

        difficultyLabel.font = .preferredFont(forTextStyle: .caption1)
        difficultyLabel.textColor = .systemOrange

        bossCountLabel.font = .preferredFont(forTextStyle: .caption1)
        bossCountLabel.textColor = .systemBlue

        durationLabel.font = .preferredFont(forTextStyle: .caption2)
        durationLabel.textColor = .tertiaryLabel

        notesLabel.font = .preferredFont(forTextStyle: .caption2)
        notesLabel.textColor = .secondaryLabel
        notesLabel.numberOfLines = 2

        // Add subviews
        contentView.addSubview(containerView)
        [nameLabel, shortNameLabel, difficultyLabel, bossCountLabel, durationLabel, notesLabel].forEach {
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

            // Name label (top)
            nameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: margin),
            nameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: margin),
            nameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -margin),

            // Short name and difficulty (second row)
            shortNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            shortNameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: margin),

            difficultyLabel.centerYAnchor.constraint(equalTo: shortNameLabel.centerYAnchor),
            difficultyLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -margin),

            // Boss count and duration (third row)
            bossCountLabel.topAnchor.constraint(equalTo: shortNameLabel.bottomAnchor, constant: 4),
            bossCountLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: margin),

            durationLabel.centerYAnchor.constraint(equalTo: bossCountLabel.centerYAnchor),
            durationLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -margin),

            // Notes (bottom, flexible)
            notesLabel.topAnchor.constraint(greaterThanOrEqualTo: bossCountLabel.bottomAnchor, constant: 4),
            notesLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: margin),
            notesLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -margin),
            notesLabel.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -margin)
        ])
    }

    // MARK: - Configuration

    func configure(with dungeon: any DungeonEntity) {
        nameLabel.text = dungeon.name
        shortNameLabel.text = dungeon.shortName
        difficultyLabel.text = dungeon.difficultyLevel
        bossCountLabel.text = "\(dungeon.bossCount) bosses"

        // Format duration
        let minutes = Int(dungeon.estimatedDuration / 60)
        durationLabel.text = "~\(minutes)m"

        // Healer notes (optional)
        notesLabel.text = dungeon.healerNotes
        notesLabel.isHidden = dungeon.healerNotes?.isEmpty ?? true
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

/// Delegate protocol for dungeon list interactions
public protocol DungeonListDelegate: AnyObject {
    func dungeonListDidSelectDungeon(_ dungeon: any DungeonEntity)
    func dungeonListDidRequestRefresh()
    func dungeonListDidRequestSearch()
}

/// Protocol defining the public interface for DungeonListViewController
public protocol DungeonListViewControllerProtocol: UIViewController {
    var dungeons: [any DungeonEntity] { get set }
    var delegate: DungeonListDelegate? { get set }

    func refreshDungeonData()
    func selectDungeon(_ dungeon: any DungeonEntity)
    func updateLayout(for orientation: UIInterfaceOrientation)
}