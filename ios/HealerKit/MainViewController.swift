//
//  MainViewController.swift
//  HealerKit
//
//  Created by HealerKit on 2025-09-14.
//

import UIKit
import HealerUIKit

class MainViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Configure iPad-specific settings
        setupForIPad()

        // Set up the main interface
        setupUI()
    }

    private func setupForIPad() {
        // Configure for iPad usage
        title = "Mythic+ Healer's Field Manual"
        navigationController?.navigationBar.prefersLargeTitles = true

        // Support all orientations on iPad
        if UIDevice.current.userInterfaceIdiom == .pad {
            // Additional iPad-specific configuration will go here
        }
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground

        // Placeholder for main UI setup
        let welcomeLabel = UILabel()
        welcomeLabel.text = "Welcome to HealerKit"
        welcomeLabel.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        welcomeLabel.textAlignment = .center
        welcomeLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(welcomeLabel)

        NSLayoutConstraint.activate([
            welcomeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            welcomeLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}