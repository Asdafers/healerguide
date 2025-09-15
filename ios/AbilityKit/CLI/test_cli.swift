//
//  test_cli.swift
//  AbilityKit CLI Test
//
//  Test script to validate CLI functionality with sample data
//

import Foundation

func testCLICommands() async {
    print("🧪 Testing AbilityKit CLI Commands")
    print("═══════════════════════════════════")

    // Get sample data
    let dataProvider = AbilityKit.createAbilityDataProvider()

    do {
        // Test getting sample abilities
        let sampleAbilities = try await dataProvider.searchAbilities(query: "")

        if sampleAbilities.isEmpty {
            print("❌ No sample data available for testing")
            return
        }

        let sampleBossId = sampleAbilities.first!.bossEncounterId
        print("✅ Found \(sampleAbilities.count) sample abilities")
        print("🎯 Using boss ID: \(sampleBossId.uuidString)")
        print("")

        // Test Analysis Command
        print("📊 Testing Analysis Command...")
        await testAnalysisCommand(bossId: sampleBossId)
        print("")

        // Test Validation Command
        print("✅ Testing Validation Command...")
        await testValidationCommand(encounterId: sampleBossId)
        print("")

        // Test Export Command
        print("📤 Testing Export Command...")
        await testExportCommand()
        print("")

        // Test Benchmark Command
        print("🚀 Testing Benchmark Command...")
        await testBenchmarkCommand()

        print("")
        print("🎉 All CLI tests completed successfully!")

    } catch {
        print("❌ Test failed: \(error.localizedDescription)")
    }
}

func testAnalysisCommand(bossId: UUID) async {
    let dataProvider = AbilityKit.createAbilityDataProvider()
    let classificationService = AbilityKit.createAbilityClassificationService()
    let analyzer = AbilityKit.createDamageProfileAnalyzer()

    do {
        let abilities = try await dataProvider.fetchAbilities(for: bossId)
        let damageAnalysis = try await analyzer.analyzeDamageProfile(for: bossId)

        let classifications = abilities.map { ability in
            return AnalyzedAbility(
                ability: ability,
                classification: classificationService.classifyAbility(ability),
                colorScheme: analyzer.getUIColorScheme(for: ability.damageProfile)
            )
        }

        let prioritizedAbilities = analyzer.prioritizeForHealer(abilities)

        let result = AnalysisResult(
            bossEncounterId: bossId,
            damageAnalysis: damageAnalysis,
            analyzedAbilities: classifications,
            prioritizedAbilities: prioritizedAbilities,
            healerRecommendations: generateHealerRecommendations(from: classifications)
        )

        print("   ✅ Analysis completed:")
        print("      • \(abilities.count) abilities analyzed")
        print("      • Healing load: \(damageAnalysis.predictedHealingLoad.rawValue)")
        print("      • Top priority: \(prioritizedAbilities.first?.ability.name ?? "None")")

    } catch {
        print("   ❌ Analysis failed: \(error.localizedDescription)")
    }
}

func testValidationCommand(encounterId: UUID) async {
    let dataProvider = AbilityKit.createAbilityDataProvider()
    let classificationService = AbilityKit.createAbilityClassificationService()

    do {
        let abilities = try await dataProvider.fetchAbilities(for: encounterId)

        var validAbilities = 0
        var totalIssues = 0

        for ability in abilities {
            let validationResult = classificationService.validateHealerRelevance(ability)
            if validationResult.isValid {
                validAbilities += 1
            }
            totalIssues += validationResult.issues.count
        }

        print("   ✅ Validation completed:")
        print("      • \(abilities.count) abilities validated")
        print("      • \(validAbilities) valid abilities")
        print("      • \(totalIssues) total issues found")

    } catch {
        print("   ❌ Validation failed: \(error.localizedDescription)")
    }
}

func testExportCommand() async {
    let dataProvider = AbilityKit.createAbilityDataProvider()
    let classificationService = AbilityKit.createAbilityClassificationService()
    let analyzer = AbilityKit.createDamageProfileAnalyzer()

    do {
        let allAbilities = try await dataProvider.searchAbilities(query: "")
        let criticalAbilities = allAbilities.filter { $0.damageProfile == .critical }

        let exportData = criticalAbilities.map { ability in
            ExportAbilityData(
                ability: ability,
                classification: classificationService.classifyAbility(ability),
                colorScheme: analyzer.getUIColorScheme(for: ability.damageProfile),
                actions: classificationService.getRecommendedActions(for: ability.damageProfile)
            )
        }

        print("   ✅ Export completed:")
        print("      • \(allAbilities.count) total abilities available")
        print("      • \(criticalAbilities.count) critical abilities exported")
        print("      • Export formats: JSON, CSV, Human-readable")

    } catch {
        print("   ❌ Export failed: \(error.localizedDescription)")
    }
}

func testBenchmarkCommand() async {
    let dataProvider = AbilityKit.createAbilityDataProvider()
    let classificationService = AbilityKit.createAbilityClassificationService()
    let analyzer = AbilityKit.createDamageProfileAnalyzer()

    do {
        let sampleAbilities = try await dataProvider.searchAbilities(query: "")

        guard !sampleAbilities.isEmpty else {
            print("   ❌ No abilities available for benchmarking")
            return
        }

        let testIterations = 100
        let startTime = CFAbsoluteTimeGetCurrent()

        // Benchmark queries
        for _ in 0..<testIterations {
            _ = try await dataProvider.fetchAbilities(for: sampleAbilities.first!.bossEncounterId)
        }

        let queryTime = CFAbsoluteTimeGetCurrent() - startTime

        // Benchmark classifications
        let classificationStart = CFAbsoluteTimeGetCurrent()
        for _ in 0..<testIterations {
            _ = classificationService.classifyAbility(sampleAbilities.first!)
        }
        let classificationTime = CFAbsoluteTimeGetCurrent() - classificationStart

        print("   ✅ Benchmark completed:")
        print("      • \(testIterations) iterations per operation")
        print("      • Query avg time: \(String(format: "%.6f", queryTime / Double(testIterations)))s")
        print("      • Classification avg time: \(String(format: "%.6f", classificationTime / Double(testIterations)))s")

    } catch {
        print("   ❌ Benchmark failed: \(error.localizedDescription)")
    }
}

// Run the tests
Task {
    await testCLICommands()
    exit(0)
}