#!/usr/bin/env swift

//
//  validate_performance_tests.swift
//  HealerKit
//
//  T040/T041 Performance Test Validation Script
//  Validates hardware performance tests and sample data generation
//

import Foundation

/// Performance test validation and benchmarking script
/// Ensures T040 and T041 implementations meet first-gen iPad Pro requirements
struct PerformanceTestValidator {

    // MARK: - Configuration

    struct ValidationConfig {
        static let testTimeout: TimeInterval = 300 // 5 minutes max per test
        static let expectedTestCount = 8 // T040.1 through T040.8
        static let sampleDataDungeonCount = 8
        static let integrationTestDungeonCount = 1 // Ara-Kara for integration tests
        static let minimumAbilitiesPerBoss = 12
        static let maximumAbilitiesPerBoss = 18
    }

    // MARK: - Validation Results

    enum ValidationResult {
        case passed(String)
        case failed(String)
        case warning(String)

        var isSuccess: Bool {
            switch self {
            case .passed: return true
            case .failed: return false
            case .warning: return true // Warnings don't fail validation
            }
        }

        var message: String {
            switch self {
            case .passed(let msg): return "✓ \(msg)"
            case .failed(let msg): return "✗ \(msg)"
            case .warning(let msg): return "⚠ \(msg)"
            }
        }
    }

    // MARK: - Main Validation

    static func validateAll() -> [ValidationResult] {
        var results: [ValidationResult] = []

        print("🔧 HealerKit Performance Test Validation")
        print("=========================================")
        print("Target: First-generation iPad Pro (A9X, 4GB RAM, iOS 13.1)")
        print("")

        // Validate T040: Hardware Performance Tests
        results.append(contentsOf: validateHardwarePerformanceTests())

        // Validate T041: Sample Data Generation
        results.append(contentsOf: validateSampleDataGeneration())

        // Validate Integration
        results.append(contentsOf: validateTestIntegration())

        return results
    }

    // MARK: - T040 Validation: Hardware Performance Tests

    static func validateHardwarePerformanceTests() -> [ValidationResult] {
        var results: [ValidationResult] = []

        print("📱 T040: Hardware Performance Tests")
        print("-----------------------------------")

        // Check test file exists
        let testFilePath = "HealerKitTests/HardwarePerformanceTests.swift"
        if !fileExists(testFilePath) {
            results.append(.failed("HardwarePerformanceTests.swift not found"))
            return results
        }

        results.append(.passed("HardwarePerformanceTests.swift found"))

        // Validate test structure
        results.append(contentsOf: validateTestStructure(testFilePath))

        // Validate performance targets
        results.append(contentsOf: validatePerformanceTargets(testFilePath))

        // Validate A9X specific optimizations
        results.append(contentsOf: validateA9XOptimizations(testFilePath))

        return results
    }

    static func validateTestStructure(_ filePath: String) -> [ValidationResult] {
        var results: [ValidationResult] = []

        guard let content = readFile(filePath) else {
            results.append(.failed("Could not read test file"))
            return results
        }

        // Check for required test methods
        let requiredTests = [
            "test_T040_1_SixtyFPSValidation",
            "test_T040_2_MemoryUsage_Under500MB",
            "test_T040_3_LoadTimeValidation",
            "test_T040_4_BatteryOptimization",
            "test_T040_5_ProcessorPerformance_DualCore",
            "test_T040_6_CoreDataQueryPerformance",
            "test_T040_7_TouchResponsiveness",
            "test_T040_8_ThermalThrottling"
        ]

        for test in requiredTests {
            if content.contains(test) {
                results.append(.passed("Test method \(test) found"))
            } else {
                results.append(.failed("Missing test method: \(test)"))
            }
        }

        // Check for performance metrics structures
        let requiredStructures = [
            "FrameMetrics",
            "MemoryMetrics",
            "BatteryMetrics",
            "HardwareSpecs"
        ]

        for structure in requiredStructures {
            if content.contains(structure) {
                results.append(.passed("Performance structure \(structure) found"))
            } else {
                results.append(.failed("Missing performance structure: \(structure)"))
            }
        }

        return results
    }

    static func validatePerformanceTargets(_ filePath: String) -> [ValidationResult] {
        var results: [ValidationResult] = []

        guard let content = readFile(filePath) else {
            results.append(.failed("Could not read test file"))
            return results
        }

        // Validate performance constants
        let performanceChecks = [
            ("targetFrameRate: Double = 60.0", "60fps target"),
            ("maxDataLoadTime: TimeInterval = 3.0", "3-second load time"),
            ("maxMemoryFootprint: Int = 500 * 1024 * 1024", "500MB memory limit"),
            ("maxTouchResponseTime: TimeInterval = 0.1", "100ms touch response"),
            ("totalRAM: Int = 4 * 1024 * 1024 * 1024", "4GB RAM constraint"),
            ("processor = \"Apple A9X\"", "A9X processor targeting")
        ]

        for (check, description) in performanceChecks {
            if content.contains(check) || content.contains(check.replacingOccurrences(of: " ", with: "")) {
                results.append(.passed("\(description) configured"))
            } else {
                results.append(.failed("Missing performance target: \(description)"))
            }
        }

        // Check for XCTest performance assertions
        let performanceAssertions = [
            "XCTAssertLessThan",
            "XCTAssertGreaterThan",
            "measure(metrics:",
            "XCTClockMetric",
            "XCTMemoryMetric"
        ]

        for assertion in performanceAssertions {
            if content.contains(assertion) {
                results.append(.passed("Performance assertion \(assertion) used"))
            } else {
                results.append(.warning("Performance assertion \(assertion) not found"))
            }
        }

        return results
    }

    static func validateA9XOptimizations(_ filePath: String) -> [ValidationResult] {
        var results: [ValidationResult] = []

        guard let content = readFile(filePath) else {
            results.append(.failed("Could not read test file"))
            return results
        }

        // Check for A9X specific considerations
        let a9xOptimizations = [
            "dual-core",
            "A9X",
            "thermal",
            "first-gen",
            "iPad Pro",
            "concurrent",
            "DispatchQueue.concurrentPerform"
        ]

        var foundOptimizations = 0
        for optimization in a9xOptimizations {
            if content.lowercased().contains(optimization.lowercased()) {
                foundOptimizations += 1
            }
        }

        if foundOptimizations >= 4 {
            results.append(.passed("A9X-specific optimizations implemented (\(foundOptimizations)/\(a9xOptimizations.count))"))
        } else {
            results.append(.warning("Limited A9X optimizations found (\(foundOptimizations)/\(a9xOptimizations.count))"))
        }

        return results
    }

    // MARK: - T041 Validation: Sample Data Generation

    static func validateSampleDataGeneration() -> [ValidationResult] {
        var results: [ValidationResult] = []

        print("")
        print("📊 T041: Sample Data Generation")
        print("-------------------------------")

        // Check generator file exists
        let generatorPath = "HealerKit/SampleData/SeasonDataGenerator.swift"
        if !fileExists(generatorPath) {
            results.append(.failed("SeasonDataGenerator.swift not found"))
            return results
        }

        results.append(.passed("SeasonDataGenerator.swift found"))

        // Validate generator structure
        results.append(contentsOf: validateGeneratorStructure(generatorPath))

        // Validate War Within content
        results.append(contentsOf: validateWarWithinContent(generatorPath))

        // Validate integration test data
        results.append(contentsOf: validateIntegrationTestData(generatorPath))

        return results
    }

    static func validateGeneratorStructure(_ filePath: String) -> [ValidationResult] {
        var results: [ValidationResult] = []

        guard let content = readFile(filePath) else {
            results.append(.failed("Could not read generator file"))
            return results
        }

        // Check for required methods
        let requiredMethods = [
            "generateWarWithinSeason",
            "generateIntegrationTestSeason",
            "exportToJSON",
            "loadFromJSON",
            "generateAraKaraDungeon",
            "generateAvanoxxEncounter"
        ]

        for method in requiredMethods {
            if content.contains(method) {
                results.append(.passed("Generator method \(method) found"))
            } else {
                results.append(.failed("Missing generator method: \(method)"))
            }
        }

        // Check for dungeon data
        if content.contains("getWarWithinDungeonData") {
            results.append(.passed("War Within dungeon data structure found"))
        } else {
            results.append(.failed("Missing War Within dungeon data"))
        }

        return results
    }

    static func validateWarWithinContent(_ filePath: String) -> [ValidationResult] {
        var results: [ValidationResult] = []

        guard let content = readFile(filePath) else {
            results.append(.failed("Could not read generator file"))
            return results
        }

        // Check for War Within dungeons
        let warWithinDungeons = [
            "Ara-Kara, City of Echoes",
            "City of Threads",
            "The Dawnbreaker",
            "The Stonevault",
            "Cinderbrew Meadery",
            "Darkflame Cleft",
            "Priory of the Sacred Flame",
            "The Rookery"
        ]

        var foundDungeons = 0
        for dungeon in warWithinDungeons {
            if content.contains(dungeon) {
                foundDungeons += 1
            }
        }

        if foundDungeons == ValidationConfig.sampleDataDungeonCount {
            results.append(.passed("All 8 War Within dungeons included"))
        } else {
            results.append(.failed("Missing War Within dungeons: \(foundDungeons)/8 found"))
        }

        // Check for ability classifications
        let abilityClassifications = [
            "critical", "high", "moderate", "mechanic"
        ]

        for classification in abilityClassifications {
            if content.contains(".\(classification)") {
                results.append(.passed("Ability classification .\(classification) used"))
            } else {
                results.append(.failed("Missing ability classification: .\(classification)"))
            }
        }

        // Check for healer-specific content
        let healerContent = [
            "healerGuidance",
            "damageProfile",
            "healerSummary",
            "emergency",
            "cooldown",
            "tank",
            "raid"
        ]

        var foundHealerContent = 0
        for content_item in healerContent {
            if content.contains(content_item) {
                foundHealerContent += 1
            }
        }

        if foundHealerContent >= 5 {
            results.append(.passed("Healer-focused content implemented (\(foundHealerContent)/\(healerContent.count))"))
        } else {
            results.append(.warning("Limited healer content (\(foundHealerContent)/\(healerContent.count))"))
        }

        return results
    }

    static func validateIntegrationTestData(_ filePath: String) -> [ValidationResult] {
        var results: [ValidationResult] = []

        guard let content = readFile(filePath) else {
            results.append(.failed("Could not read generator file"))
            return results
        }

        // Check for Avanoxx encounter (used in integration tests)
        if content.contains("Avanoxx") {
            results.append(.passed("Avanoxx boss encounter included"))
        } else {
            results.append(.failed("Missing Avanoxx boss for integration tests"))
        }

        // Check for specific Avanoxx abilities
        let avanoxxAbilities = [
            "Voracious Bite",
            "Web Bolt",
            "Burrow Charge",
            "Poison Nova",
            "Ensnaring Web"
        ]

        var foundAbilities = 0
        for ability in avanoxxAbilities {
            if content.contains(ability) {
                foundAbilities += 1
            }
        }

        if foundAbilities >= 3 {
            results.append(.passed("Avanoxx abilities implemented (\(foundAbilities)/\(avanoxxAbilities.count))"))
        } else {
            results.append(.warning("Limited Avanoxx abilities (\(foundAbilities)/\(avanoxxAbilities.count))"))
        }

        return results
    }

    // MARK: - Integration Validation

    static func validateTestIntegration() -> [ValidationResult] {
        var results: [ValidationResult] = []

        print("")
        print("🔗 Integration Validation")
        print("-------------------------")

        // Check if tests can access sample data
        results.append(contentsOf: validateDataAccess())

        // Check performance monitoring integration
        results.append(contentsOf: validatePerformanceIntegration())

        // Check CLI integration
        results.append(contentsOf: validateCLIIntegration())

        return results
    }

    static func validateDataAccess() -> [ValidationResult] {
        var results: [ValidationResult] = []

        // Check if performance tests import sample data generator
        let testFilePath = "HealerKitTests/HardwarePerformanceTests.swift"
        guard let testContent = readFile(testFilePath) else {
            results.append(.failed("Could not validate data access"))
            return results
        }

        if testContent.contains("SeasonDataGenerator") {
            results.append(.passed("Performance tests can access sample data generator"))
        } else {
            results.append(.warning("Performance tests may not access sample data generator"))
        }

        return results
    }

    static func validatePerformanceIntegration() -> [ValidationResult] {
        var results: [ValidationResult] = []

        // Check if PerformanceManager exists and is used
        let perfManagerPath = "ios/HealerKit/Performance/PerformanceManager.swift"
        if fileExists(perfManagerPath) {
            results.append(.passed("PerformanceManager found"))

            guard let content = readFile(perfManagerPath) else {
                results.append(.failed("Could not read PerformanceManager"))
                return results
            }

            // Check for first-gen iPad Pro optimizations
            if content.contains("4GB") && content.contains("A9X") {
                results.append(.passed("PerformanceManager targets first-gen iPad Pro"))
            } else {
                results.append(.warning("PerformanceManager may not be optimized for first-gen iPad Pro"))
            }
        } else {
            results.append(.warning("PerformanceManager not found - using existing implementation"))
        }

        return results
    }

    static func validateCLIIntegration() -> [ValidationResult] {
        var results: [ValidationResult] = []

        let generatorPath = "HealerKit/SampleData/SeasonDataGenerator.swift"
        guard let content = readFile(generatorPath) else {
            results.append(.failed("Could not validate CLI integration"))
            return results
        }

        // Check for CLI support
        if content.contains("SeasonDataCLI") {
            results.append(.passed("CLI integration implemented"))
        } else {
            results.append(.warning("CLI integration may be limited"))
        }

        // Check for JSON export/import
        if content.contains("exportToJSON") && content.contains("loadFromJSON") {
            results.append(.passed("JSON export/import implemented"))
        } else {
            results.append(.failed("Missing JSON export/import functionality"))
        }

        return results
    }

    // MARK: - Utility Methods

    static func fileExists(_ path: String) -> Bool {
        return FileManager.default.fileExists(atPath: path)
    }

    static func readFile(_ path: String) -> String? {
        return try? String(contentsOfFile: path, encoding: .utf8)
    }

    static func printSummary(_ results: [ValidationResult]) {
        print("")
        print("📋 Validation Summary")
        print("====================")

        let passed = results.filter { result in
            if case .passed = result { return true }
            return false
        }.count

        let failed = results.filter { result in
            if case .failed = result { return true }
            return false
        }.count

        let warnings = results.filter { result in
            if case .warning = result { return true }
            return false
        }.count

        print("Passed: \(passed)")
        print("Failed: \(failed)")
        print("Warnings: \(warnings)")
        print("Total: \(results.count)")

        let successRate = Double(passed) / Double(results.count) * 100
        print("Success Rate: \(String(format: "%.1f", successRate))%")

        if failed == 0 {
            print("")
            print("✅ All critical validations passed!")
            print("T040 Hardware Performance Tests: Ready for implementation")
            print("T041 Sample Data Generation: Complete")
        } else {
            print("")
            print("❌ \(failed) critical issues found")
            print("Please address failed validations before proceeding")
        }

        if warnings > 0 {
            print("")
            print("⚠️  \(warnings) warnings noted")
            print("Consider addressing warnings for optimal implementation")
        }

        print("")
        print("Next Steps:")
        print("1. Run performance tests: swift test --filter T040")
        print("2. Generate sample data: swift run SeasonDataCLI --generate")
        print("3. Validate on device: Connect first-gen iPad Pro and run full test suite")
    }
}

// MARK: - Main Execution

let results = PerformanceTestValidator.validateAll()

print("")
print("Validation Results:")
print("==================")

for result in results {
    print(result.message)
}

PerformanceTestValidator.printSummary(results)

// Exit with appropriate code
let failedCount = results.filter { !$0.isSuccess }.count
exit(Int32(failedCount > 0 ? 1 : 0))