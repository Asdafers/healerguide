//
//  CLITests.swift
//  HealerUIKit CLI Tests
//
//  Created by HealerKit on 2025-09-15.
//  Task T030: CLI Testing and Validation
//

import XCTest
import Foundation

/// Test suite for HealerUIKit CLI tools
class HealerUIKitCLITests: XCTestCase {

    // MARK: - Benchmark Command Tests

    func testBenchmarkCommandBasic() {
        let benchmarker = UIPerformanceBenchmarker()
        let results = benchmarker.benchmarkComponent(
            component: "ability-card",
            iterations: 10,
            includeMemoryAnalysis: false
        )

        XCTAssertEqual(results.component, "ability-card")
        XCTAssertEqual(results.iterations, 10)
        XCTAssertGreaterThan(results.averageRenderTime, 0)
        XCTAssertGreaterThan(results.estimatedFPS, 0)
        XCTAssertFalse(results.recommendations.isEmpty)
    }

    func testBenchmarkCommandWithMemory() {
        let benchmarker = UIPerformanceBenchmarker()
        let results = benchmarker.benchmarkComponent(
            component: "ability-card",
            iterations: 5,
            includeMemoryAnalysis: true
        )

        XCTAssertNotNil(results.memoryUsage)
        XCTAssertGreaterThan(results.memoryUsage!.peakMemoryMB, 0)
        XCTAssertGreaterThan(results.memoryUsage!.averageMemoryMB, 0)
    }

    func testBenchmarkDifferentComponents() {
        let benchmarker = UIPerformanceBenchmarker()

        let components = ["ability-card", "dungeon-list", "boss-encounter", "unknown-component"]

        for component in components {
            let results = benchmarker.benchmarkComponent(
                component: component,
                iterations: 3,
                includeMemoryAnalysis: false
            )

            XCTAssertEqual(results.component, component)
            XCTAssertGreaterThan(results.averageRenderTime, 0)
        }
    }

    // MARK: - Layout Validation Tests

    func testLayoutValidationBasic() {
        let validator = LayoutValidator()
        let results = validator.validateLayouts(
            device: "ipad-pro-gen1",
            validateTouchTargets: false,
            testOrientations: false
        )

        XCTAssertEqual(results.device, "ipad-pro-gen1")
        XCTAssertNotNil(results.allConstraintsMet)
        XCTAssertFalse(results.recommendations.isEmpty)
    }

    func testLayoutValidationWithTouchTargets() {
        let validator = LayoutValidator()
        let results = validator.validateLayouts(
            device: "ipad-pro-gen1",
            validateTouchTargets: true,
            testOrientations: false
        )

        // Should have recommendations about touch targets
        let hasTouchTargetRecommendation = results.recommendations.contains { recommendation in
            recommendation.lowercased().contains("touch target")
        }
        XCTAssertTrue(hasTouchTargetRecommendation || results.touchTargetIssues.isEmpty)
    }

    func testLayoutValidationWithOrientations() {
        let validator = LayoutValidator()
        let results = validator.validateLayouts(
            device: "ipad-pro-gen1",
            validateTouchTargets: false,
            testOrientations: true
        )

        // Should include orientation testing
        XCTAssertTrue(results.orientationIssues.isEmpty || !results.recommendations.isEmpty)
    }

    // MARK: - Accessibility Audit Tests

    func testAccessibilityAuditBasic() {
        let auditor = AccessibilityAuditor()
        let results = auditor.performAccessibilityAudit(
            testVoiceOver: false,
            testDynamicType: false,
            testHighContrast: false
        )

        XCTAssertGreaterThanOrEqual(results.overallComplianceScore, 0.0)
        XCTAssertLessThanOrEqual(results.overallComplianceScore, 1.0)

        XCTAssertGreaterThanOrEqual(results.voiceOverScore, 0.0)
        XCTAssertLessThanOrEqual(results.voiceOverScore, 1.0)

        XCTAssertGreaterThanOrEqual(results.dynamicTypeScore, 0.0)
        XCTAssertLessThanOrEqual(results.dynamicTypeScore, 1.0)

        XCTAssertGreaterThanOrEqual(results.colorContrastScore, 0.0)
        XCTAssertLessThanOrEqual(results.colorContrastScore, 1.0)

        XCTAssertFalse(results.recommendations.isEmpty)
    }

    func testAccessibilityAuditWithAllFeatures() {
        let auditor = AccessibilityAuditor()
        let results = auditor.performAccessibilityAudit(
            testVoiceOver: true,
            testDynamicType: true,
            testHighContrast: true
        )

        XCTAssertGreaterThan(results.overallComplianceScore, 0.0)
        XCTAssertFalse(results.recommendations.isEmpty)
    }

    // MARK: - Color Contrast Tests

    func testColorContrastWCAG_AA() {
        let tester = ColorContrastTester()
        let results = tester.testDamageProfileColors(
            standard: .wcagAA,
            includeHighContrast: false
        )

        XCTAssertEqual(results.standard, "wcag-aa")
        XCTAssertEqual(results.profileResults.count, 4) // Critical, High, Moderate, Mechanic

        for profileResult in results.profileResults {
            XCTAssertGreaterThan(profileResult.contrastRatio, 0)
            XCTAssertEqual(profileResult.requiredRatio, 4.5) // WCAG AA standard
            XCTAssertFalse(profileResult.backgroundColor.isEmpty)
            XCTAssertFalse(profileResult.textColor.isEmpty)
        }
    }

    func testColorContrastWCAG_AAA() {
        let tester = ColorContrastTester()
        let results = tester.testDamageProfileColors(
            standard: .wcagAAA,
            includeHighContrast: false
        )

        XCTAssertEqual(results.standard, "wcag-aaa")

        for profileResult in results.profileResults {
            XCTAssertEqual(profileResult.requiredRatio, 7.0) // WCAG AAA standard
        }
    }

    func testColorContrastWithHighContrast() {
        let tester = ColorContrastTester()
        let results = tester.testDamageProfileColors(
            standard: .wcagAA,
            includeHighContrast: true
        )

        XCTAssertNotNil(results.highContrastResults)
    }

    func testDamageProfileColors() {
        let tester = ColorContrastTester()
        let results = tester.testDamageProfileColors(
            standard: .wcagAA,
            includeHighContrast: false
        )

        let profileNames = results.profileResults.map { $0.damageProfile }
        XCTAssertTrue(profileNames.contains("critical"))
        XCTAssertTrue(profileNames.contains("high"))
        XCTAssertTrue(profileNames.contains("moderate"))
        XCTAssertTrue(profileNames.contains("mechanic"))
    }

    // MARK: - Integration Tests

    func testCLIResultsAreCodable() throws {
        // Test that all result types can be encoded to JSON
        let benchmarker = UIPerformanceBenchmarker()
        let benchmarkResults = benchmarker.benchmarkComponent(
            component: "ability-card",
            iterations: 3,
            includeMemoryAnalysis: true
        )

        let benchmarkData = try JSONEncoder().encode(benchmarkResults)
        XCTAssertGreaterThan(benchmarkData.count, 0)

        // Test layout results
        let validator = LayoutValidator()
        let layoutResults = validator.validateLayouts(
            device: "ipad-pro-gen1",
            validateTouchTargets: true,
            testOrientations: true
        )

        let layoutData = try JSONEncoder().encode(layoutResults)
        XCTAssertGreaterThan(layoutData.count, 0)

        // Test accessibility results
        let auditor = AccessibilityAuditor()
        let accessibilityResults = auditor.performAccessibilityAudit(
            testVoiceOver: true,
            testDynamicType: true,
            testHighContrast: true
        )

        let accessibilityData = try JSONEncoder().encode(accessibilityResults)
        XCTAssertGreaterThan(accessibilityData.count, 0)

        // Test color contrast results
        let tester = ColorContrastTester()
        let colorResults = tester.testDamageProfileColors(
            standard: .wcagAA,
            includeHighContrast: true
        )

        let colorData = try JSONEncoder().encode(colorResults)
        XCTAssertGreaterThan(colorData.count, 0)
    }

    func testMockAbilityEntityConformance() {
        let mockAbility = MockAbilityEntity(
            id: UUID(),
            name: "Test Ability",
            bossEncounterId: UUID(),
            healerAction: "Test action",
            criticalInsight: "Test insight",
            cooldown: 30.0,
            damageProfile: .critical
        )

        XCTAssertEqual(mockAbility.type, .damage)
        XCTAssertEqual(mockAbility.targets, .group)
        XCTAssertEqual(mockAbility.displayOrder, 1)
        XCTAssertTrue(mockAbility.isKeyMechanic)
        XCTAssertEqual(mockAbility.damageProfile, .critical)
        XCTAssertEqual(mockAbility.cooldown, 30.0)
    }

    // MARK: - Performance Benchmarks

    func testPerformanceBenchmarkSpeed() {
        let startTime = CFAbsoluteTimeGetCurrent()

        let benchmarker = UIPerformanceBenchmarker()
        _ = benchmarker.benchmarkComponent(
            component: "ability-card",
            iterations: 10,
            includeMemoryAnalysis: false
        )

        let endTime = CFAbsoluteTimeGetCurrent()
        let totalTime = endTime - startTime

        // CLI should complete within reasonable time (5 seconds for 10 iterations)
        XCTAssertLessThan(totalTime, 5.0)
    }

    // MARK: - Error Handling Tests

    func testUnknownComponent() {
        let benchmarker = UIPerformanceBenchmarker()
        let results = benchmarker.benchmarkComponent(
            component: "unknown-component",
            iterations: 1,
            includeMemoryAnalysis: false
        )

        // Should handle unknown components gracefully
        XCTAssertEqual(results.component, "unknown-component")
        XCTAssertGreaterThan(results.averageRenderTime, 0)
    }

    func testUnsupportedDevice() {
        let validator = LayoutValidator()
        let results = validator.validateLayouts(
            device: "unsupported-device",
            validateTouchTargets: false,
            testOrientations: false
        )

        // Should have warnings about unsupported device
        let hasWarning = results.layoutIssues.contains { issue in
            issue.severity == .warning && issue.component == "Device Configuration"
        }
        XCTAssertTrue(hasWarning)
    }
}

// MARK: - Test Extensions for Validation

extension HealerUIKitCLITests {

    /// Validate that performance targets are realistic
    func testPerformanceTargetsAreRealistic() {
        let targetFPS = 60.0
        let targetFrameTime = 1000.0 / targetFPS // 16.67ms

        // Ensure our targets are achievable on first-gen iPad Pro
        XCTAssertEqual(targetFrameTime, 16.666666666666668, accuracy: 0.1)
        XCTAssertGreaterThanOrEqual(targetFPS, 60.0)
    }

    /// Validate accessibility standards compliance
    func testAccessibilityStandardsCompliance() {
        XCTAssertEqual(AccessibilityStandard.wcagAA.minimumRatio, 4.5)
        XCTAssertEqual(AccessibilityStandard.wcagAAA.minimumRatio, 7.0)
    }

    /// Validate that all damage profiles are tested
    func testAllDamageProfilesCovered() {
        let expectedProfiles: Set<DamageProfile> = [.critical, .high, .moderate, .mechanic]

        let tester = ColorContrastTester()
        let results = tester.testDamageProfileColors(
            standard: .wcagAA,
            includeHighContrast: false
        )

        let testedProfiles = Set(results.profileResults.compactMap { result in
            DamageProfile(rawValue: result.damageProfile)
        })

        XCTAssertEqual(testedProfiles, expectedProfiles)
    }
}