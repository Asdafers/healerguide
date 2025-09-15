//
//  AppDelegate.swift
//  HealerKit
//
//  Created by HealerKit on 2025-09-14.
//

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Initialize CoreData stack for iPad Pro optimization
        setupCoreDataStack()

        // Initialize performance monitoring
        setupPerformanceMonitoring()

        // Configure app settings for iPad Pro
        setupAppConfiguration()

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // MARK: - App Lifecycle

    func applicationWillTerminate(_ application: UIApplication) {
        // Save CoreData changes before app terminates
        do {
            try CoreDataStack.shared.save()
        } catch {
            print("Failed to save context before termination: \(error)")
        }

        // Stop performance monitoring
        PerformanceManager.shared.stopMonitoring()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Save context when entering background
        do {
            try CoreDataStack.shared.save()
        } catch {
            print("Failed to save context when entering background: \(error)")
        }

        // Optimize memory usage for background state
        PerformanceManager.shared.optimizeMemoryUsage()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Resume performance monitoring when returning to foreground
        PerformanceManager.shared.startMonitoring()
    }

    func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
        // Handle memory pressure
        PerformanceManager.shared.handleMemoryPressure(level: .critical)
    }

    // MARK: - Setup Methods

    private func setupCoreDataStack() {
        // Initialize CoreData with migration check
        CoreDataStack.shared.performMigrationIfNeeded { result in
            switch result {
            case .success:
                print("CoreData stack initialized successfully for iPad Pro")
            case .failure(let error):
                print("CoreData migration failed: \(error)")
                // Handle migration failure appropriately for production
            }
        }
    }

    private func setupPerformanceMonitoring() {
        // Start performance monitoring optimized for iPad Pro A9X
        PerformanceManager.shared.startMonitoring()

        // Log initial performance metrics
        let metrics = PerformanceManager.shared.currentMetrics()
        print("Initial performance metrics - Memory: \(metrics.memoryUsageMB)MB, FPS: \(metrics.currentFPS)")
    }

    private func setupAppConfiguration() {
        // Configure app for iPad Pro characteristics
        let config = AppConfiguration.shared

        // Apply typography settings for iPad readability
        UINavigationBar.appearance().titleTextAttributes = [
            .font: config.font(for: .navigationTitle, textStyle: .largeTitle)
        ]

        // Configure color scheme
        UINavigationBar.appearance().tintColor = config.color(for: .interactive("tint"))
        UITabBar.appearance().tintColor = config.color(for: .interactive("tint"))

        // Enable accessibility features
        if AppConfiguration.Accessibility.DynamicType.isLargeTextEnabled {
            print("Large text accessibility enabled")
        }

        if AppConfiguration.Accessibility.HighContrast.isEnabled {
            print("High contrast mode enabled")
        }

        if AppConfiguration.Accessibility.ReducedMotion.isEnabled {
            print("Reduced motion enabled")
        }
    }
}