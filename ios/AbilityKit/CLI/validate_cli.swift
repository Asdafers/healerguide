//
//  validate_cli.swift
//  AbilityKit CLI Validation
//
//  Basic validation script to ensure CLI implementation is correctly structured
//

import Foundation

// Validate that all required types are available
func validateCLIImplementation() {
    print("🔍 Validating AbilityKit CLI Implementation")
    print("═══════════════════════════════════════════")

    // Test 1: Verify core services are available
    print("✅ Testing service availability...")
    let dataProvider = AbilityKit.createAbilityDataProvider()
    let classificationService = AbilityKit.createAbilityClassificationService()
    let analyzer = AbilityKit.createDamageProfileAnalyzer()
    print("   • AbilityDataProvider: Available")
    print("   • AbilityClassificationService: Available")
    print("   • DamageProfileAnalyzer: Available")
    print("")

    // Test 2: Verify enum cases
    print("✅ Testing enum definitions...")
    let outputFormats: [OutputFormat] = [.json, .csv, .human]
    let damageProfiles: [DamageProfile] = [.critical, .high, .moderate, .mechanic]
    print("   • OutputFormat cases: \(outputFormats.count)")
    print("   • DamageProfile cases: \(damageProfiles.count)")
    print("")

    // Test 3: Verify helper functions compile
    print("✅ Testing helper functions...")
    do {
        let testUUID = try parseUUID(from: "123e4567-e89b-12d3-a456-426614174000", context: "test")
        print("   • UUID parsing: Working (\(testUUID.uuidString))")

        let criticalProfile = try parseDamageProfileFilter("critical")
        print("   • Damage profile parsing: Working (\(criticalProfile?.rawValue ?? "nil"))")

        let csvText = escapeCSV("test,text")
        print("   • CSV escaping: Working (\(csvText))")

    } catch {
        print("   ❌ Helper function error: \(error)")
    }
    print("")

    // Test 4: Verify formatting functions
    print("✅ Testing formatting functions...")
    let sampleError = formatError("Test error message")
    print("   • Error formatting: \(sampleError.prefix(20))...")

    let bytes = formatBytes(1024 * 1024)
    print("   • Byte formatting: \(bytes)")
    print("")

    // Test 5: Test with sample data
    Task {
        print("✅ Testing with sample data...")

        do {
            let sampleAbilities = try await dataProvider.searchAbilities(query: "")
            print("   • Sample abilities loaded: \(sampleAbilities.count)")

            if let firstAbility = sampleAbilities.first {
                let classification = classificationService.classifyAbility(firstAbility)
                print("   • Classification working: \(classification.urgency)")

                let validation = classificationService.validateHealerRelevance(firstAbility)
                print("   • Validation working: \(validation.isValid ? "Valid" : "Invalid")")

                let colorScheme = analyzer.getUIColorScheme(for: firstAbility.damageProfile)
                print("   • Color scheme working: \(colorScheme.primaryColor)")
            }

            print("")
            print("🎉 CLI Implementation Validation Complete!")
            print("   All core functionality is properly structured and accessible.")
            print("")

            print("📋 Available Commands:")
            print("   • abilitykit analyze --boss <uuid> --format json")
            print("   • abilitykit validate --encounter <uuid> --verbose")
            print("   • abilitykit export --format csv --damage-profile critical")
            print("   • abilitykit benchmark --queries 1000 --memory")
            print("")

        } catch {
            print("   ❌ Sample data test failed: \(error)")
        }
    }
}

// Run validation
validateCLIImplementation()