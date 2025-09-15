//
//  PerformanceTests.swift
//  HealerKitTests
//
//  Created by HealerKit on 2025-09-15.
//  T012: First-Generation iPad Pro Performance Integration Tests
//

import XCTest
import UIKit
import CoreData
@testable import HealerKit
@testable import DungeonKit
@testable import AbilityKit
@testable import HealerUIKit

final class T012_FirstGenIPadProPerformanceTests: XCTestCase {

    // MARK: - Performance Constants

    /// First-generation iPad Pro performance targets
    private struct PerformanceTargets {
        static let targetFrameRate: Double = 60.0 // fps
        static let maxDataLoadTime: TimeInterval = 3.0 // seconds
        static let maxMemoryFootprint: Int = 500 * 1024 * 1024 // 500MB in bytes
        static let maxTouchResponseTime: TimeInterval = 0.1 // 100ms
        static let frameTime: TimeInterval = 1.0 / targetFrameRate // ~16.67ms per frame

        // First-gen iPad Pro hardware constraints
        static let maxRAM: Int = 4 * 1024 * 1024 * 1024 // 4GB
        static let processorType = "A9X" // First-gen iPad Pro processor
    }

    // MARK: - Test Fixtures

    private var coreDataStack: CoreDataStack!
    private var dungeonService: DungeonService!
    private var abilityService: AbilityService!
    private var seasonDataProvider: SeasonDataProvider!
    private var abilityCardViewController: AbilityCardViewController!
    private var scrollView: UIScrollView!
    private var window: UIWindow!

    // Memory tracking
    private var initialMemoryUsage: Int = 0
    private var peakMemoryUsage: Int = 0

    override func setUpWithError() throws {
        super.setUp()

        // Record initial memory state
        initialMemoryUsage = getCurrentMemoryUsage()
        peakMemoryUsage = initialMemoryUsage

        // Initialize CoreData stack with performance configuration
        coreDataStack = try CoreDataStack(inMemory: false, performanceOptimized: true)

        // Initialize services
        dungeonService = DungeonService(coreDataStack: coreDataStack)
        abilityService = AbilityService(coreDataStack: coreDataStack)
        seasonDataProvider = SeasonDataProvider(dungeonService: dungeonService,
                                               abilityService: abilityService)

        // Setup UI components for testing
        window = UIWindow(frame: CGRect(x: 0, y: 0, width: 1024, height: 1366)) // iPad Pro dimensions
        setupAbilityCardScrollView()

        // Load test data that represents full season
        try loadFullSeasonTestData()

        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        // Memory cleanup validation
        let finalMemoryUsage = getCurrentMemoryUsage()
        let memoryLeak = finalMemoryUsage - initialMemoryUsage

        // Allow for reasonable memory growth but detect major leaks
        let maxAcceptableMemoryGrowth = 50 * 1024 * 1024 // 50MB
        XCTAssertLessThan(memoryLeak, maxAcceptableMemoryGrowth,
                         "Potential memory leak detected: \(memoryLeak) bytes")

        // Cleanup
        abilityCardViewController = nil
        scrollView = nil
        window = nil
        seasonDataProvider = nil
        abilityService = nil
        dungeonService = nil
        coreDataStack = nil

        super.tearDown()
    }

    // MARK: - T012.1: 60fps Rendering Performance During Scroll

    func test_T012_1_ScrollPerformance_MaintainsSixtyFPSDuringAbilityCardScroll() throws {
        // GIVEN: Ability card scroll view with full season data loaded
        let expectation = XCTestExpectation(description: "60fps scroll performance maintained")
        let frameDropTolerance = 2 // Allow up to 2 dropped frames per test run
        var droppedFrames = 0
        var frameCount = 0

        // Create performance monitor
        let displayLink = CADisplayLink(target: self, selector: #selector(frameCallback))
        let startTime = CACurrentMediaTime()
        var lastFrameTime = startTime

        // WHEN: Scrolling through ability cards at maximum speed
        displayLink.add(to: .main, forMode: .default)

        // Simulate aggressive scrolling
        let scrollDuration: TimeInterval = 2.0
        let scrollDistance: CGFloat = scrollView.contentSize.height

        DispatchQueue.main.async {
            UIView.animate(withDuration: scrollDuration,
                          delay: 0,
                          options: [.curveLinear],
                          animations: {
                self.scrollView.contentOffset = CGPoint(x: 0, y: scrollDistance)
            }) { _ in
                displayLink.invalidate()
                expectation.fulfill()
            }
        }

        // Monitor frame timing
        let frameTimer = Timer.scheduledTimer(withTimeInterval: PerformanceTargets.frameTime, repeats: true) { _ in
            let currentTime = CACurrentMediaTime()
            let frameDuration = currentTime - lastFrameTime

            // Check if frame took longer than target (dropped frame)
            if frameDuration > PerformanceTargets.frameTime * 1.5 { // 50% tolerance
                droppedFrames += 1
            }

            frameCount += 1
            lastFrameTime = currentTime

            // Track peak memory during scroll
            self.peakMemoryUsage = max(self.peakMemoryUsage, self.getCurrentMemoryUsage())
        }

        wait(for: [expectation], timeout: scrollDuration + 1.0)
        frameTimer.invalidate()

        // THEN: Frame rate should maintain close to 60fps
        let actualFrameRate = Double(frameCount) / scrollDuration

        // THIS TEST MUST FAIL initially until performance optimizations are implemented
        XCTAssertLessThanOrEqual(droppedFrames, frameDropTolerance,
                                "Dropped \(droppedFrames) frames during scroll (max allowed: \(frameDropTolerance))")
        XCTAssertGreaterThanOrEqual(actualFrameRate, PerformanceTargets.targetFrameRate * 0.9,
                                   "Actual frame rate \(actualFrameRate)fps below target \(PerformanceTargets.targetFrameRate)fps")

        print("T012.1 Performance Results:")
        print("- Actual Frame Rate: \(actualFrameRate) fps")
        print("- Dropped Frames: \(droppedFrames)")
        print("- Peak Memory During Scroll: \(peakMemoryUsage / (1024*1024)) MB")
    }

    @objc private func frameCallback() {
        // Frame callback for display link monitoring
    }

    // MARK: - T012.2: CoreData Load Performance

    func test_T012_2_CoreDataLoadPerformance_LoadsFullSeasonUnderThreeSeconds() throws {
        // GIVEN: Empty CoreData context
        try coreDataStack.clearAllData()

        // WHEN: Loading complete season data from CoreData
        let loadStartTime = CFAbsoluteTimeGetCurrent()

        measure(metrics: [XCTClockMetric(), XCTMemoryMetric()]) {
            do {
                // Load all 8 dungeons with full encounter and ability data
                let season = try seasonDataProvider.loadCurrentSeason()
                let dungeons = try dungeonService.getAllDungeons(for: season.id)

                // Force loading of all related data
                for dungeon in dungeons {
                    let encounters = try dungeonService.getBossEncounters(for: dungeon.id)
                    for encounter in encounters {
                        _ = try abilityService.getAbilities(for: encounter.id)
                    }
                }

                // Verify data completeness
                XCTAssertEqual(dungeons.count, 8, "Should load all 8 dungeons")
                XCTAssertGreaterThan(dungeons.flatMap { _ in encounters }.count, 0,
                                   "Should have boss encounters")

            } catch {
                XCTFail("Failed to load season data: \(error)")
            }
        }

        let loadEndTime = CFAbsoluteTimeGetCurrent()
        let loadDuration = loadEndTime - loadStartTime

        // THEN: Load time should be under 3 seconds
        // THIS TEST MUST FAIL initially until CoreData optimizations are implemented
        XCTAssertLessThan(loadDuration, PerformanceTargets.maxDataLoadTime,
                         "CoreData load time \(loadDuration)s exceeds target \(PerformanceTargets.maxDataLoadTime)s")

        print("T012.2 Performance Results:")
        print("- Load Duration: \(loadDuration) seconds")
        print("- Memory Usage After Load: \(getCurrentMemoryUsage() / (1024*1024)) MB")
    }

    // MARK: - T012.3: Memory Footprint Validation

    func test_T012_3_MemoryFootprint_StaysUnder500MBWithFullSeasonData() throws {
        // GIVEN: Application with full season data loaded
        let memoryBefore = getCurrentMemoryUsage()

        // WHEN: Loading and displaying all season content
        let season = try seasonDataProvider.loadCurrentSeason()
        let dungeons = try dungeonService.getAllDungeons(for: season.id)

        // Simulate worst-case memory usage: all ability cards in memory
        var allAbilityCards: [AbilityCardView] = []

        for dungeon in dungeons {
            let encounters = try dungeonService.getBossEncounters(for: dungeon.id)
            for encounter in encounters {
                let abilities = try abilityService.getAbilities(for: encounter.id)
                for ability in abilities {
                    let cardView = AbilityCardView(ability: ability)
                    cardView.frame = CGRect(x: 0, y: 0, width: 300, height: 200)
                    allAbilityCards.append(cardView)
                }
            }
        }

        // Force memory pressure by creating additional objects
        let additionalData = generateMemoryPressureData()

        let memoryAfter = getCurrentMemoryUsage()
        let memoryDelta = memoryAfter - memoryBefore

        // THEN: Total memory footprint should stay under 500MB
        // THIS TEST MUST FAIL initially until memory optimizations are implemented
        XCTAssertLessThan(memoryAfter, PerformanceTargets.maxMemoryFootprint,
                         "Memory footprint \(memoryAfter / (1024*1024))MB exceeds target \(PerformanceTargets.maxMemoryFootprint / (1024*1024))MB")

        // Validate memory is within first-gen iPad Pro constraints
        XCTAssertLessThan(memoryAfter, PerformanceTargets.maxRAM / 2, // Use less than half of available RAM
                         "Memory usage too high for 4GB iPad Pro: \(memoryAfter / (1024*1024))MB")

        print("T012.3 Performance Results:")
        print("- Memory Before: \(memoryBefore / (1024*1024)) MB")
        print("- Memory After: \(memoryAfter / (1024*1024)) MB")
        print("- Memory Delta: \(memoryDelta / (1024*1024)) MB")
        print("- Ability Cards Loaded: \(allAbilityCards.count)")

        // Cleanup to prevent memory leaks
        allAbilityCards.removeAll()
    }

    // MARK: - T012.4: Touch Responsiveness Performance

    func test_T012_4_TouchResponsiveness_RespondsWithin100msOnFirstGenHardware() throws {
        // GIVEN: Ability card view ready for interaction
        let abilityCard = createTestAbilityCard()
        window.addSubview(abilityCard)
        window.makeKeyAndVisible()

        let touchExpectation = XCTestExpectation(description: "Touch response within 100ms")
        var responseTimes: [TimeInterval] = []
        let numberOfTouches = 10 // Test multiple touches for consistency

        // WHEN: Simulating touch events on first-gen iPad Pro
        for i in 0..<numberOfTouches {
            let touchStartTime = CFAbsoluteTimeGetCurrent()

            // Simulate touch with A9X processor constraints
            DispatchQueue.main.async {
                // Add artificial delay to simulate first-gen hardware
                let hardwareDelay: TimeInterval = 0.008 // ~8ms A9X touch latency

                DispatchQueue.main.asyncAfter(deadline: .now() + hardwareDelay) {
                    // Simulate touch handling
                    abilityCard.touchesBegan(Set<UITouch>(), with: nil)

                    let responseTime = CFAbsoluteTimeGetCurrent() - touchStartTime
                    responseTimes.append(responseTime)

                    if i == numberOfTouches - 1 {
                        touchExpectation.fulfill()
                    }
                }
            }

            // Delay between touches
            Thread.sleep(forTimeInterval: 0.05)
        }

        wait(for: [touchExpectation], timeout: 5.0)

        // THEN: All touch responses should be under 100ms
        let averageResponseTime = responseTimes.reduce(0, +) / Double(responseTimes.count)
        let maxResponseTime = responseTimes.max() ?? 0

        // THIS TEST MUST FAIL initially until touch optimizations are implemented
        XCTAssertLessThan(maxResponseTime, PerformanceTargets.maxTouchResponseTime,
                         "Max touch response time \(maxResponseTime * 1000)ms exceeds target \(PerformanceTargets.maxTouchResponseTime * 1000)ms")
        XCTAssertLessThan(averageResponseTime, PerformanceTargets.maxTouchResponseTime * 0.8,
                         "Average touch response time \(averageResponseTime * 1000)ms too high for smooth interaction")

        print("T012.4 Performance Results:")
        print("- Average Response Time: \(averageResponseTime * 1000) ms")
        print("- Max Response Time: \(maxResponseTime * 1000) ms")
        print("- Number of Touch Tests: \(numberOfTouches)")
        print("- Hardware Simulation: \(PerformanceTargets.processorType) processor")
    }

    // MARK: - T012.5: Memory Pressure Handling

    func test_T012_5_MemoryPressure_HandlesLowMemoryWarningsGracefully() throws {
        // GIVEN: Application with substantial data loaded
        let initialMemory = getCurrentMemoryUsage()
        try loadFullSeasonTestData()

        let memoryWarningExpectation = XCTestExpectation(description: "Memory warning handled")

        // WHEN: Simulating memory pressure on first-gen iPad Pro
        NotificationCenter.default.addObserver(
            forName: UIApplication.didReceiveMemoryWarningNotification,
            object: nil,
            queue: .main
        ) { _ in
            // Memory warning received - app should clean up
            memoryWarningExpectation.fulfill()
        }

        // Trigger memory warning
        DispatchQueue.main.async {
            // Simulate the memory warning that would occur on 4GB device
            UIApplication.shared.perform(Selector(("_performMemoryWarning")))
        }

        wait(for: [memoryWarningExpectation], timeout: 2.0)

        // Allow time for cleanup
        Thread.sleep(forTimeInterval: 1.0)

        let memoryAfterWarning = getCurrentMemoryUsage()
        let memoryReduction = initialMemory - memoryAfterWarning

        // THEN: Memory usage should be reduced after warning
        // THIS TEST MUST FAIL initially until memory management is implemented
        XCTAssertGreaterThan(memoryReduction, 10 * 1024 * 1024, // At least 10MB cleanup
                            "App should reduce memory usage by at least 10MB after memory warning")
        XCTAssertLessThan(memoryAfterWarning, PerformanceTargets.maxMemoryFootprint,
                         "Memory should be under limit after cleanup: \(memoryAfterWarning / (1024*1024))MB")

        print("T012.5 Performance Results:")
        print("- Memory Before Warning: \(initialMemory / (1024*1024)) MB")
        print("- Memory After Warning: \(memoryAfterWarning / (1024*1024)) MB")
        print("- Memory Reduction: \(memoryReduction / (1024*1024)) MB")
    }

    // MARK: - T012.6: Critical User Path Benchmarks

    func test_T012_6_CriticalUserPaths_MeetPerformanceBaselinesOnFirstGenHardware() throws {
        // GIVEN: Application ready for typical user workflows

        // Critical Path 1: Dungeon Selection → Boss Detail → Ability Card View
        measure(metrics: [XCTClockMetric(), XCTCPUMetric(), XCTMemoryMetric()]) {
            do {
                // Navigate from dungeon list to ability details
                let season = try! seasonDataProvider.loadCurrentSeason()
                let dungeons = try! dungeonService.getAllDungeons(for: season.id)
                let firstDungeon = dungeons.first!

                let encounters = try! dungeonService.getBossEncounters(for: firstDungeon.id)
                let firstEncounter = encounters.first!

                let abilities = try! abilityService.getAbilities(for: firstEncounter.id)

                // Simulate UI rendering for each step
                let dungeonView = DungeonDetailView(dungeon: firstDungeon)
                let encounterView = BossEncounterView(encounter: firstEncounter)
                let abilityCards = abilities.map { AbilityCardView(ability: $0) }

                // Force view layout (simulates actual rendering)
                dungeonView.layoutIfNeeded()
                encounterView.layoutIfNeeded()
                abilityCards.forEach { $0.layoutIfNeeded() }

            } catch {
                XCTFail("Critical path navigation failed: \(error)")
            }
        }

        // Critical Path 2: Search and Filter Performance
        let searchPerformanceExpectation = XCTestExpectation(description: "Search completes quickly")
        let searchStartTime = CFAbsoluteTimeGetCurrent()

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                // Simulate searching across all abilities
                let allAbilities = try! self.abilityService.searchAbilities(query: "damage", limit: 100)
                let searchEndTime = CFAbsoluteTimeGetCurrent()
                let searchDuration = searchEndTime - searchStartTime

                DispatchQueue.main.async {
                    // Search should complete within reasonable time on A9X
                    XCTAssertLessThan(searchDuration, 1.0, "Search took too long: \(searchDuration)s")
                    XCTAssertGreaterThan(allAbilities.count, 0, "Search should return results")
                    searchPerformanceExpectation.fulfill()
                }

            } catch {
                XCTFail("Search performance test failed: \(error)")
            }
        }

        wait(for: [searchPerformanceExpectation], timeout: 5.0)

        print("T012.6 Performance Results:")
        print("- Critical path navigation completed")
        print("- Search performance validated")
        print("- Hardware target: \(PerformanceTargets.processorType) with \(PerformanceTargets.maxRAM / (1024*1024*1024))GB RAM")
    }

    // MARK: - Helper Methods

    private func setupAbilityCardScrollView() {
        scrollView = UIScrollView(frame: window.bounds)
        scrollView.contentSize = CGSize(width: window.bounds.width, height: 5000) // Large content

        abilityCardViewController = AbilityCardViewController()
        abilityCardViewController.view.frame = window.bounds

        window.rootViewController = abilityCardViewController
        abilityCardViewController.view.addSubview(scrollView)
    }

    private func loadFullSeasonTestData() throws {
        // Load comprehensive test data representing full season
        // This includes all 8 dungeons with complete encounter and ability data

        let season = Season(id: UUID(),
                          name: "The War Within Season 1",
                          startDate: Date(),
                          dungeonIds: (0..<8).map { _ in UUID() })

        try seasonDataProvider.saveSeason(season)

        // Create test dungeons with full data
        for dungeonId in season.dungeonIds {
            let dungeon = createTestDungeon(id: dungeonId)
            try dungeonService.saveDungeon(dungeon)

            // Add encounters and abilities for each dungeon
            for _ in 0..<4 { // 4 bosses per dungeon
                let encounter = createTestBossEncounter(dungeonId: dungeonId)
                try dungeonService.saveBossEncounter(encounter)

                // Add abilities for each encounter
                for _ in 0..<15 { // 15 abilities per boss
                    let ability = createTestAbility(encounterId: encounter.id)
                    try abilityService.saveAbility(ability)
                }
            }
        }
    }

    private func createTestDungeon(id: UUID) -> Dungeon {
        return Dungeon(
            id: id,
            name: "Test Dungeon \(id.uuidString.prefix(8))",
            description: "Performance test dungeon",
            difficulty: .mythicplus,
            estimatedDuration: 1800,
            bossEncounterIds: []
        )
    }

    private func createTestBossEncounter(dungeonId: UUID) -> BossEncounter {
        return BossEncounter(
            id: UUID(),
            name: "Test Boss",
            dungeonId: dungeonId,
            description: "Performance test boss encounter",
            phase: 1,
            abilityIds: []
        )
    }

    private func createTestAbility(encounterId: UUID) -> Ability {
        return Ability(
            id: UUID(),
            name: "Test Ability",
            encounterId: encounterId,
            classification: .critical,
            description: "Performance test ability",
            healerGuidance: "Test healing response",
            damageProfile: DamageProfile(
                type: .burst,
                severity: .high,
                timing: .immediate,
                affectedPlayers: .raid
            )
        )
    }

    private func createTestAbilityCard() -> AbilityCardView {
        let testAbility = Ability(
            id: UUID(),
            name: "Test Touch Ability",
            encounterId: UUID(),
            classification: .critical,
            description: "Touch responsiveness test ability",
            healerGuidance: "Touch to test responsiveness",
            damageProfile: DamageProfile(
                type: .burst,
                severity: .high,
                timing: .immediate,
                affectedPlayers: .tank
            )
        )

        let cardView = AbilityCardView(ability: testAbility)
        cardView.frame = CGRect(x: 100, y: 100, width: 300, height: 200)
        return cardView
    }

    private func generateMemoryPressureData() -> [Any] {
        // Generate data to simulate memory pressure
        var pressureData: [Any] = []

        for _ in 0..<1000 {
            let largeString = String(repeating: "Performance Test Data ", count: 1000)
            let imageData = Data(count: 1024 * 100) // 100KB of data
            pressureData.append([largeString, imageData])
        }

        return pressureData
    }

    private func getCurrentMemoryUsage() -> Int {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4

        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         $0,
                         &count)
            }
        }

        if kerr == KERN_SUCCESS {
            return Int(info.resident_size)
        } else {
            return 0
        }
    }
}

// MARK: - Mock Extensions for Testing

extension T012_FirstGenIPadProPerformanceTests {

    private class MockCoreDataStack: CoreDataStack {
        override init(inMemory: Bool = false, performanceOptimized: Bool = false) throws {
            try super.init(inMemory: true, performanceOptimized: performanceOptimized)
        }

        func clearAllData() throws {
            // Implementation for clearing test data
        }
    }
}

// MARK: - Performance Test Documentation

/*
 T012: First-Generation iPad Pro Performance Integration Tests

 PURPOSE:
 Validates that HealerKit meets strict performance requirements for first-generation iPad Pro devices,
 ensuring smooth healer experience during Mythic+ encounters on older hardware.

 HARDWARE TARGET:
 - Device: iPad Pro (1st generation, 2015)
 - Processor: Apple A9X (2.26 GHz dual-core)
 - RAM: 4GB
 - Storage: 128GB+ (user dependent)
 - iOS Version: 13.1+ (maximum supported)

 PERFORMANCE REQUIREMENTS:
 1. Rendering: 60fps during scroll operations and UI transitions
 2. Data Loading: Complete season data loads in < 3 seconds from CoreData
 3. Memory Usage: Total app footprint stays under 500MB
 4. Touch Response: UI responds to touch input within 100ms
 5. Memory Management: Graceful handling of memory pressure warnings
 6. Critical Paths: Key user workflows complete within performance baselines

 TEST FAILURE EXPECTATIONS:
 These tests are designed to FAIL initially until performance optimizations are implemented:
 - Frame rate optimization for ability card rendering
 - CoreData query optimization and caching strategies
 - Memory management and cleanup procedures
 - Touch event handling optimization
 - Lazy loading and view recycling implementation

 OPTIMIZATION AREAS TO ADDRESS:
 - View controller lifecycle management
 - Image loading and caching
 - CoreData fetch request optimization
 - Memory pressure response implementation
 - Background queue usage for non-UI operations
 - View recycling for scroll performance

 This test suite establishes measurable performance baselines that guide implementation
 decisions and ensure the app remains usable on first-generation iPad Pro hardware.
 */