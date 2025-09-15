//
//  IntegrationTestSuite.swift
//  HealerKitTests
//
//  Integration tests for CoreData stack, App configuration, and Performance manager
//

import XCTest
import CoreData
@testable import HealerKit

class IntegrationTestSuite: XCTestCase {

    var testContext: NSManagedObjectContext!

    override func setUp() {
        super.setUp()

        // Use in-memory store for testing
        testContext = CoreDataStack.shared.newBackgroundContext()
    }

    override func tearDown() {
        testContext = nil
        super.tearDown()
    }

    // MARK: - T027 CoreData Stack Tests

    func testCoreDataStackInitialization() {
        // Given: CoreData stack is initialized
        let coreDataStack = CoreDataStack.shared

        // When: Accessing the persistent container
        let container = coreDataStack.persistentContainer

        // Then: Container should be properly configured
        XCTAssertEqual(container.name, "HealerKit")
        XCTAssertNotNil(coreDataStack.viewContext)
        XCTAssertNotNil(coreDataStack.backgroundContext)
    }

    func testCoreDataStackMemoryOptimization() {
        // Given: CoreData stack with memory constraints
        let coreDataStack = CoreDataStack.shared
        let performanceMetrics = coreDataStack.performanceMetrics()

        // When: Checking memory usage
        let memoryUsage = performanceMetrics["memoryUsage"] as? UInt64 ?? 0
        let memoryUsageMB = Double(memoryUsage) / (1024 * 1024)

        // Then: Memory usage should be reasonable for iPad Pro constraints
        XCTAssertLessThan(memoryUsageMB, 512.0, "Memory usage should be under 512MB for 4GB device")
    }

    func testCoreDataSaveOperation() {
        // Given: A managed object context with changes
        let context = CoreDataStack.shared.newBackgroundContext()
        context.perform {
            // Create test data
            let season = Season(context: context)
            season.id = UUID()
            season.name = "Test Season"
            season.isActive = true
            season.createdAt = Date()
            season.updatedAt = Date()
            season.majorPatchVersion = "11.1"

            // When: Saving the context
            XCTAssertNoThrow(try CoreDataStack.shared.save(context: context))
        }
    }

    // MARK: - T031 App Configuration Tests

    func testAppConfigurationInitialization() {
        // Given: App configuration is initialized
        let config = AppConfiguration.shared

        // When: Accessing configuration properties
        let abilityNameFont = config.font(for: .abilityName)
        let criticalColor = config.color(for: .damageProfile("critical"))
        let animationDuration = config.animationDuration(for: .cardTransition)

        // Then: Configuration should provide appropriate values for iPad Pro
        XCTAssertGreaterThanOrEqual(abilityNameFont.pointSize, 18.0, "Ability name font should be at least 18pt for iPad readability")
        XCTAssertEqual(criticalColor, UIColor.systemRed, "Critical damage should be red")
        XCTAssertGreaterThan(animationDuration, 0, "Animation duration should be positive")
    }

    func testAppConfigurationAccessibility() {
        // Given: App configuration with accessibility features
        let config = AppConfiguration.shared

        // When: Checking accessibility settings
        let largeTextEnabled = AppConfiguration.Accessibility.DynamicType.isLargeTextEnabled
        let highContrastEnabled = AppConfiguration.Accessibility.HighContrast.isEnabled
        let reducedMotionEnabled = AppConfiguration.Accessibility.ReducedMotion.isEnabled

        // Then: Configuration should handle accessibility appropriately
        if largeTextEnabled {
            let scaledSize = AppConfiguration.Accessibility.DynamicType.scaledFontSize(18.0)
            XCTAssertGreaterThanOrEqual(scaledSize, 18.0, "Scaled font size should not be smaller than base")
        }

        if reducedMotionEnabled {
            let reducedDuration = AppConfiguration.Accessibility.ReducedMotion.animationDuration(0.3)
            XCTAssertLessThan(reducedDuration, 0.3, "Animation should be faster with reduced motion")
        }
    }

    func testAppConfigurationIPadOptimization() {
        // Given: App configuration for iPad Pro
        let config = AppConfiguration.shared

        // When: Getting touch target sizes
        let minimumTouch = AppConfiguration.Layout.TouchTarget.minimum
        let preferredTouch = AppConfiguration.Layout.TouchTarget.preferred

        // Then: Touch targets should meet iPad guidelines
        XCTAssertGreaterThanOrEqual(minimumTouch, 44.0, "Minimum touch target should be 44pt")
        XCTAssertGreaterThanOrEqual(preferredTouch, minimumTouch, "Preferred touch target should be at least minimum")

        // And: Typography should be optimized for iPad reading distances
        let healerActionFont = config.font(for: .healerAction)
        XCTAssertGreaterThanOrEqual(healerActionFont.pointSize, 16.0, "Healer action font should be at least 16pt")
    }

    // MARK: - T032 Performance Manager Tests

    func testPerformanceManagerInitialization() {
        // Given: Performance manager is initialized
        let performanceManager = PerformanceManager.shared

        // When: Getting current metrics
        let metrics = performanceManager.currentMetrics()

        // Then: Metrics should be valid for iPad Pro constraints
        XCTAssertLessThan(metrics.memoryUsageMB, 512.0, "Memory usage should be under 512MB")
        XCTAssertGreaterThan(metrics.currentFPS, 0, "FPS should be positive")
        XCTAssertLessThanOrEqual(metrics.backgroundOperationCount, 2, "Background operations should be limited for A9X")
    }

    func testPerformanceManagerMemoryOptimization() {
        // Given: Performance manager with memory pressure
        let performanceManager = PerformanceManager.shared

        // When: Handling memory pressure
        performanceManager.handleMemoryPressure(level: .warning)

        // Then: Memory usage should be optimized
        let metricsAfter = performanceManager.currentMetrics()
        XCTAssertFalse(metricsAfter.isMemoryPressureHigh, "Memory pressure should be reduced")
    }

    func testPerformanceManagerCaching() {
        // Given: Performance manager with caching enabled
        let performanceManager = PerformanceManager.shared
        let testView = UIView()
        let testKey = "test_view_key"

        // When: Caching a view
        performanceManager.cacheView(testView, forKey: testKey, cost: 1024)

        // Then: View should be retrievable from cache
        let cachedView = performanceManager.cachedView(forKey: testKey)
        XCTAssertEqual(cachedView, testView, "Cached view should be retrievable")
    }

    func testPerformanceManagerFrameRateMonitoring() {
        // Given: Performance manager with frame rate monitoring
        let performanceManager = PerformanceManager.shared

        // When: Starting monitoring
        performanceManager.startMonitoring()

        // Then: Frame rate should be monitored
        let fps = performanceManager.getCurrentFPS()
        let isOptimal = performanceManager.isFrameRateOptimal()

        XCTAssertGreaterThan(fps, 0, "FPS should be positive when monitoring")

        if fps >= 55.0 {
            XCTAssertTrue(isOptimal, "Frame rate should be considered optimal at 55+ FPS")
        }

        // Clean up
        performanceManager.stopMonitoring()
    }

    // MARK: - Integration Tests

    func testCoreDataStackWithPerformanceManager() {
        // Given: CoreData stack and performance manager working together
        let coreDataStack = CoreDataStack.shared
        let performanceManager = PerformanceManager.shared

        // When: Performing a background data operation
        let expectation = XCTestExpectation(description: "Background operation completes")

        performanceManager.performBackgroundDataOperation {
            coreDataStack.performBackgroundTask { context in
                // Simulate data operation
                let season = Season(context: context)
                season.id = UUID()
                season.name = "Integration Test Season"
                season.isActive = true
                season.createdAt = Date()
                season.updatedAt = Date()
                season.majorPatchVersion = "11.1"

                // Save should complete successfully
                if context.hasChanges {
                    do {
                        try context.save()
                        expectation.fulfill()
                    } catch {
                        XCTFail("Save operation failed: \(error)")
                    }
                }
            }
        }

        wait(for: [expectation], timeout: 5.0)
    }

    func testAppConfigurationWithPerformanceManager() {
        // Given: App configuration and performance manager integration
        let config = AppConfiguration.shared
        let performanceManager = PerformanceManager.shared

        // When: Using configuration for performance-sensitive operations
        let animationDuration = config.animationDuration(for: .cardTransition)
        let isFrameRateOptimal = performanceManager.isFrameRateOptimal()

        // Then: Configuration should adapt to performance conditions
        if !isFrameRateOptimal {
            // Animation should be faster when frame rate is poor
            let reducedDuration = AppConfiguration.Accessibility.ReducedMotion.animationDuration(animationDuration)
            XCTAssertLessThanOrEqual(reducedDuration, animationDuration, "Animation should be faster when performance is poor")
        }
    }

    func testFullSystemIntegration() {
        // Given: All three systems working together
        let coreDataStack = CoreDataStack.shared
        let config = AppConfiguration.shared
        let performanceManager = PerformanceManager.shared

        // When: Simulating app launch scenario
        performanceManager.startMonitoring()

        let initialMetrics = performanceManager.currentMetrics()

        // Create some test data
        let context = coreDataStack.newBackgroundContext()
        context.perform {
            let season = Season(context: context)
            season.id = UUID()
            season.name = "Full Integration Test Season"
            season.isActive = true
            season.createdAt = Date()
            season.updatedAt = Date()
            season.majorPatchVersion = "11.1"

            let dungeon = Dungeon(context: context)
            dungeon.id = UUID()
            dungeon.name = "Test Dungeon"
            dungeon.shortName = "TD"
            dungeon.difficultyLevel = 15
            dungeon.displayOrder = 1
            dungeon.season = season

            do {
                try context.save()
            } catch {
                XCTFail("Failed to save test data: \(error)")
            }
        }

        // Then: System should remain performant
        let finalMetrics = performanceManager.currentMetrics()

        XCTAssertLessThan(finalMetrics.memoryUsageMB, 512.0, "Memory usage should remain under iPad Pro constraint")
        XCTAssertTrue(finalMetrics.isFrameRateOptimal, "Frame rate should remain optimal")

        // Configuration should provide consistent values
        let font = config.font(for: .abilityName)
        let color = config.color(for: .damageProfile("critical"))

        XCTAssertNotNil(font, "Configuration should provide valid fonts")
        XCTAssertNotNil(color, "Configuration should provide valid colors")

        // Clean up
        performanceManager.stopMonitoring()
    }
}

// MARK: - Performance Test Case

class PerformanceIntegrationTests: XCTestCase {

    func testMemoryUsageUnderLoad() {
        // This test simulates heavy usage to ensure memory constraints are respected
        measure(metrics: [XCTMemoryMetric()]) {
            let performanceManager = PerformanceManager.shared
            let coreDataStack = CoreDataStack.shared

            // Simulate creating many ability cards
            for i in 0..<100 {
                let context = coreDataStack.newBackgroundContext()
                context.perform {
                    let ability = BossAbility(context: context)
                    ability.id = UUID()
                    ability.name = "Test Ability \(i)"
                    ability.damageProfile = "critical"
                    ability.healerAction = "Test healer action for ability \(i)"
                    ability.isKeyMechanic = i % 5 == 0

                    try? context.save()
                }
            }

            // Verify memory usage
            let metrics = performanceManager.currentMetrics()
            XCTAssertLessThan(metrics.memoryUsageMB, 512.0, "Memory should stay under constraint during heavy load")
        }
    }

    func testFrameRateUnderLoad() {
        // This test simulates UI operations to ensure frame rate remains optimal
        measure(metrics: [XCTClockMetric()]) {
            let config = AppConfiguration.shared
            let performanceManager = PerformanceManager.shared

            performanceManager.startMonitoring()

            // Simulate UI operations
            for _ in 0..<50 {
                let _ = config.font(for: .abilityName)
                let _ = config.color(for: .damageProfile("critical"))
                let _ = config.animationDuration(for: .cardTransition)
            }

            let fps = performanceManager.getCurrentFPS()
            XCTAssertGreaterThanOrEqual(fps, 55.0, "Frame rate should remain optimal during UI operations")

            performanceManager.stopMonitoring()
        }
    }
}