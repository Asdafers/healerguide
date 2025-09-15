//
//  MainNavigationController.swift
//  HealerUIKit
//
//  Created by HealerKit on 2025-09-15.
//  Task T026: Navigation controller setup with iPad split view
//

import UIKit
import DungeonKit
import AbilityKit

/// iPad-optimized navigation controller with split view support for healer workflow
public class MainNavigationController: UISplitViewController {

    // MARK: - Navigation Components

    private var masterNavigationController: UINavigationController
    private var detailNavigationController: UINavigationController
    private var homeViewController: UIViewController
    private var dungeonListViewController: UIViewController
    private var currentBossDetailViewController: UIViewController?

    // MARK: - Quick Action Toolbar

    private var quickActionToolbar: UIToolbar
    private var quickActions: [QuickAction] = []

    // MARK: - Breadcrumb Navigation

    private var breadcrumbNavigationView: BreadcrumbNavigationView
    private var currentNavigationPath: NavigationPath

    // MARK: - State Management

    private var navigationStack: [NavigationState] = []
    private var currentScreen: NavigationScreen = .home
    private var lastError: Error?

    // MARK: - Services

    private let dungeonService: DungeonServiceProtocol

    // MARK: - Constants

    private struct Constants {
        static let masterViewMinimumWidth: CGFloat = 320.0
        static let detailViewMinimumWidth: CGFloat = 500.0
        static let animationDuration: TimeInterval = 0.3
        static let quickActionHeight: CGFloat = 44.0
        static let breadcrumbHeight: CGFloat = 40.0
    }

    // MARK: - Initialization

    public init(dungeonService: DungeonServiceProtocol) throws {
        self.dungeonService = dungeonService

        // Initialize navigation controllers
        self.masterNavigationController = UINavigationController()
        self.detailNavigationController = UINavigationController()

        // Initialize view controllers
        self.homeViewController = HomeViewController()
        let displayProvider = HealerDisplayProvider()
        self.dungeonListViewController = try displayProvider.createDungeonListView(dungeons: [])

        // Initialize toolbar and breadcrumb
        self.quickActionToolbar = UIToolbar()
        self.breadcrumbNavigationView = BreadcrumbNavigationView()
        self.currentNavigationPath = NavigationPath(season: "The War Within", dungeon: nil, boss: nil)

        super.init(nibName: nil, bundle: nil)

        setupSplitViewController()
        setupQuickActions()
        setupBreadcrumbNavigation()
        configureForIPad()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup Methods

    private func setupSplitViewController() {
        // Configure split view controller
        preferredDisplayMode = .allVisible
        presentsWithGesture = true

        // Set minimum widths for iPad
        minimumPrimaryColumnWidth = Constants.masterViewMinimumWidth
        maximumPrimaryColumnWidth = 400.0
        preferredPrimaryColumnWidthFraction = 0.3

        // Setup master navigation
        masterNavigationController.navigationBar.prefersLargeTitles = true
        masterNavigationController.setViewControllers([dungeonListViewController], animated: false)

        // Setup detail navigation
        detailNavigationController.setViewControllers([homeViewController], animated: false)

        // Set view controllers
        viewControllers = [masterNavigationController, detailNavigationController]

        // Set delegate
        delegate = self
    }

    private func setupQuickActions() {
        quickActions = [
            QuickAction(
                identifier: "home",
                title: "Home",
                icon: UIImage(systemName: "house.fill"),
                action: { [weak self] in self?.navigateToHome {} }
            ),
            QuickAction(
                identifier: "dungeons",
                title: "Dungeons",
                icon: UIImage(systemName: "list.bullet"),
                action: { [weak self] in self?.navigateToDungeonList {} }
            ),
            QuickAction(
                identifier: "search",
                title: "Search",
                icon: UIImage(systemName: "magnifyingglass"),
                action: { [weak self] in self?.presentSearch() }
            ),
            QuickAction(
                identifier: "settings",
                title: "Settings",
                icon: UIImage(systemName: "gear"),
                action: { [weak self] in self?.presentSettings() }
            )
        ]

        quickActionToolbar.items = quickActions.map { action in
            UIBarButtonItem(
                image: action.icon,
                style: .plain,
                target: self,
                action: #selector(quickActionTapped(_:))
            )
        }

        quickActionToolbar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(quickActionToolbar)

        NSLayoutConstraint.activate([
            quickActionToolbar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            quickActionToolbar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            quickActionToolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            quickActionToolbar.heightAnchor.constraint(equalToConstant: Constants.quickActionHeight)
        ])
    }

    private func setupBreadcrumbNavigation() {
        breadcrumbNavigationView.delegate = self
        breadcrumbNavigationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(breadcrumbNavigationView)

        NSLayoutConstraint.activate([
            breadcrumbNavigationView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            breadcrumbNavigationView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            breadcrumbNavigationView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            breadcrumbNavigationView.heightAnchor.constraint(equalToConstant: Constants.breadcrumbHeight)
        ])

        updateBreadcrumbNavigation()
    }

    private func configureForIPad() {
        // Enable all iPad orientations
        modalPresentationStyle = .fullScreen

        // Configure for multi-tasking
        if #available(iOS 13.0, *) {
            // Enable multiple windows support (iOS 13+)
        }

        // Setup gesture recognizers
        setupGestureRecognizers()
    }

    private func setupGestureRecognizers() {
        // Enable edge pan gesture for back navigation
        let edgePanGesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleEdgePan(_:)))
        edgePanGesture.edges = .left
        view.addGestureRecognizer(edgePanGesture)

        // Enable swipe gestures
        let rightSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeBack))
        rightSwipeGesture.direction = .right
        view.addGestureRecognizer(rightSwipeGesture)
    }

    // MARK: - Navigation Methods

    public func navigateToHome(completion: @escaping () -> Void) {
        let homeVC = HomeViewController()

        UIView.animate(withDuration: Constants.animationDuration) { [weak self] in
            self?.detailNavigationController.setViewControllers([homeVC], animated: true)
        } completion: { [weak self] _ in
            self?.currentScreen = .home
            self?.navigationStack.removeAll()
            self?.currentNavigationPath = NavigationPath(season: "The War Within", dungeon: nil, boss: nil)
            self?.updateBreadcrumbNavigation()
            completion()
        }
    }

    public func navigateToDungeonList(completion: @escaping () -> Void) {
        // Show dungeon list in master view (iPad split view behavior)
        currentScreen = .dungeonList

        // If in portrait mode, show the master view
        if traitCollection.horizontalSizeClass == .compact {
            preferredDisplayMode = .primaryOverlay
        }

        updateNavigationPath(dungeon: nil, boss: nil)
        completion()
    }

    public func navigateToBossDetail(dungeon: Dungeon?, bossIndex: Int, completion: @escaping () -> Void) {
        guard let dungeon = dungeon,
              bossIndex < dungeon.bossEncounters.count else {
            lastError = NavigationError.invalidBossIndex
            completion()
            return
        }

        do {
            let bossEncounter = dungeon.bossEncounters[bossIndex]
            let displayProvider = HealerDisplayProvider()
            let bossDetailVC = try displayProvider.createBossEncounterView(
                encounter: bossEncounter,
                abilities: bossEncounter.abilities
            )

            currentBossDetailViewController = bossDetailVC

            UIView.animate(withDuration: Constants.animationDuration) { [weak self] in
                self?.detailNavigationController.pushViewController(bossDetailVC, animated: true)
            } completion: { [weak self] _ in
                self?.currentScreen = .bossDetail
                self?.navigationStack.append(NavigationState(screen: .bossDetail, context: ["dungeon": dungeon, "bossIndex": bossIndex]))
                self?.updateNavigationPath(dungeon: dungeon.name, boss: bossEncounter.name)
                completion()
            }
        } catch {
            lastError = error
            completion()
        }
    }

    public func navigateBack(completion: @escaping () -> Void) {
        guard !navigationStack.isEmpty else {
            navigateToHome(completion: completion)
            return
        }

        navigationStack.removeLast()

        if navigationStack.isEmpty {
            navigateToHome(completion: completion)
        } else {
            let previousState = navigationStack.last!
            currentScreen = previousState.screen

            UIView.animate(withDuration: Constants.animationDuration) { [weak self] in
                self?.detailNavigationController.popViewController(animated: true)
            } completion: { [weak self] _ in
                self?.updateBreadcrumbNavigation()
                completion()
            }
        }
    }

    // MARK: - Breadcrumb Navigation

    private func updateNavigationPath(dungeon: String?, boss: String?) {
        currentNavigationPath = NavigationPath(
            season: "The War Within",
            dungeon: dungeon,
            boss: boss
        )
        updateBreadcrumbNavigation()
    }

    private func updateBreadcrumbNavigation() {
        breadcrumbNavigationView.updatePath(currentNavigationPath)
    }

    // MARK: - Quick Actions

    @objc private func quickActionTapped(_ sender: UIBarButtonItem) {
        guard let index = quickActionToolbar.items?.firstIndex(of: sender),
              index < quickActions.count else { return }

        let action = quickActions[index]
        action.action()

        // Provide haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }

    private func presentSearch() {
        do {
            let displayProvider = HealerDisplayProvider()
            let searchVC = try displayProvider.createSearchView(delegate: self)
            let searchNavVC = UINavigationController(rootViewController: searchVC)

            present(searchNavVC, animated: true)
        } catch {
            lastError = error
        }
    }

    private func presentSettings() {
        do {
            let displayProvider = HealerDisplayProvider()
            let settingsVC = try displayProvider.createSettingsView()
            let settingsNavVC = UINavigationController(rootViewController: settingsVC)

            present(settingsNavVC, animated: true)
        } catch {
            lastError = error
        }
    }

    // MARK: - Gesture Handlers

    @objc private func handleEdgePan(_ gesture: UIScreenEdgePanGestureRecognizer) {
        switch gesture.state {
        case .began, .changed:
            // Handle interactive back navigation
            break
        case .ended:
            let velocity = gesture.velocity(in: view)
            if velocity.x > 300 {
                navigateBack {}
            }
        default:
            break
        }
    }

    @objc private func handleSwipeBack() {
        navigateBack {}
    }

    // MARK: - Orientation Support

    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all // Support all orientations on iPad
    }

    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: { [weak self] _ in
            self?.updateLayoutForSize(size)
        })
    }

    private func updateLayoutForSize(_ size: CGSize) {
        let isLandscape = size.width > size.height

        if isLandscape {
            preferredDisplayMode = .allVisible
        } else {
            preferredDisplayMode = currentScreen == .dungeonList ? .primaryOverlay : .secondaryOnly
        }
    }

    // MARK: - Memory Management

    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

        // Clear non-essential cached views
        if currentBossDetailViewController != detailNavigationController.topViewController {
            currentBossDetailViewController = nil
        }

        // Maintain essential navigation state
        // Navigation stack and current screen are preserved
    }

    // MARK: - Error Handling

    private enum NavigationError: LocalizedError {
        case invalidBossIndex
        case viewControllerCreationFailed

        var errorDescription: String? {
            switch self {
            case .invalidBossIndex:
                return "Invalid boss index for navigation"
            case .viewControllerCreationFailed:
                return "Failed to create view controller"
            }
        }
    }
}

// MARK: - UISplitViewControllerDelegate

extension MainNavigationController: UISplitViewControllerDelegate {

    public func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        // Return true to indicate that the collapse was handled
        // This ensures proper behavior when rotating to compact width
        return currentScreen == .dungeonList
    }

    public func splitViewController(_ splitViewController: UISplitViewController, separateSecondaryFrom primaryViewController: UIViewController) -> UIViewController? {
        // Return the detail view controller when expanding from compact to regular width
        return detailNavigationController
    }
}

// MARK: - SearchDelegate

extension MainNavigationController: SearchDelegate {

    public func searchDidUpdate(query: String) {
        // Handle search query updates
    }

    public func searchDidSelectDungeon(_ dungeon: DungeonEntity) {
        dismiss(animated: true) { [weak self] in
            // Navigate to selected dungeon's first boss
            // Note: This would need proper dungeon conversion from protocol to concrete type
        }
    }

    public func searchDidSelectBoss(_ boss: BossEncounterEntity) {
        dismiss(animated: true) { [weak self] in
            // Navigate to selected boss
            // Note: This would need proper boss encounter conversion
        }
    }

    public func searchDidSelectAbility(_ ability: AbilityEntity) {
        dismiss(animated: true) { [weak self] in
            // Navigate to boss containing this ability
        }
    }
}

// MARK: - BreadcrumbNavigationDelegate

extension MainNavigationController: BreadcrumbNavigationDelegate {

    func breadcrumbDidSelectHome() {
        navigateToHome {}
    }

    func breadcrumbDidSelectDungeon(_ dungeonName: String) {
        navigateToDungeonList {}
    }

    func breadcrumbDidSelectBoss(_ bossName: String) {
        // Already on boss detail - no action needed
    }
}

// MARK: - Supporting Types

private struct NavigationState {
    let screen: NavigationScreen
    let context: [String: Any]
}

public enum NavigationScreen {
    case home
    case dungeonList
    case bossDetail
}

// MARK: - Navigation Path

public struct NavigationPath {
    let season: String
    let dungeon: String?
    let boss: String?
}

// MARK: - Quick Action

public struct QuickAction {
    let identifier: String
    let title: String
    let icon: UIImage?
    let action: () -> Void
}

// MARK: - Breadcrumb Navigation View

private class BreadcrumbNavigationView: UIView {

    weak var delegate: BreadcrumbNavigationDelegate?

    private let stackView = UIStackView()
    private let homeButton = UIButton(type: .system)
    private let dungeonButton = UIButton(type: .system)
    private let bossButton = UIButton(type: .system)

    private var currentPath: NavigationPath?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        backgroundColor = UIColor.secondarySystemBackground

        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)

        homeButton.setTitle("Home", for: .normal)
        homeButton.addTarget(self, action: #selector(homeTapped), for: .touchUpInside)

        dungeonButton.addTarget(self, action: #selector(dungeonTapped), for: .touchUpInside)
        bossButton.addTarget(self, action: #selector(bossTapped), for: .touchUpInside)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    func updatePath(_ path: NavigationPath) {
        currentPath = path

        // Clear existing views
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        // Add home
        stackView.addArrangedSubview(homeButton)

        // Add separator and dungeon if present
        if let dungeonName = path.dungeon {
            stackView.addArrangedSubview(createSeparator())
            dungeonButton.setTitle(dungeonName, for: .normal)
            stackView.addArrangedSubview(dungeonButton)

            // Add separator and boss if present
            if let bossName = path.boss {
                stackView.addArrangedSubview(createSeparator())
                bossButton.setTitle(bossName, for: .normal)
                stackView.addArrangedSubview(bossButton)
            }
        }
    }

    private func createSeparator() -> UILabel {
        let label = UILabel()
        label.text = ">"
        label.textColor = .systemGray
        return label
    }

    @objc private func homeTapped() {
        delegate?.breadcrumbDidSelectHome()
    }

    @objc private func dungeonTapped() {
        guard let dungeonName = currentPath?.dungeon else { return }
        delegate?.breadcrumbDidSelectDungeon(dungeonName)
    }

    @objc private func bossTapped() {
        guard let bossName = currentPath?.boss else { return }
        delegate?.breadcrumbDidSelectBoss(bossName)
    }
}

protocol BreadcrumbNavigationDelegate: AnyObject {
    func breadcrumbDidSelectHome()
    func breadcrumbDidSelectDungeon(_ dungeonName: String)
    func breadcrumbDidSelectBoss(_ bossName: String)
}

// MARK: - Temporary Implementation Classes

private class HomeViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Home"

        let label = UILabel()
        label.text = "HealerKit Home"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

private class HealerDisplayProvider: HealerDisplayProviding {
    func createDungeonListView(dungeons: [DungeonEntity]) throws -> UIViewController {
        let vc = UIViewController()
        vc.title = "Dungeons"
        vc.view.backgroundColor = .systemBackground
        return vc
    }

    func createBossEncounterView(encounter: BossEncounterEntity, abilities: [AbilityEntity]) throws -> UIViewController {
        let vc = UIViewController()
        vc.title = encounter.name
        vc.view.backgroundColor = .systemBackground
        return vc
    }

    func createSearchView(delegate: SearchDelegate?) throws -> UIViewController {
        let vc = UIViewController()
        vc.title = "Search"
        vc.view.backgroundColor = .systemBackground
        return vc
    }

    func createSettingsView() throws -> UIViewController {
        let vc = UIViewController()
        vc.title = "Settings"
        vc.view.backgroundColor = .systemBackground
        return vc
    }
}