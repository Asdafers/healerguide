//
//  AbilityKitCLI.swift
//  AbilityKit
//
//  CLI interface for AbilityKit - Healer-focused boss ability analysis and validation
//  Provides commands for analyzing, validating, benchmarking, and exporting ability data
//

import Foundation
import ArgumentParser

// MARK: - Main CLI Structure

/// AbilityKit CLI - Command-line interface for boss ability analysis and healer validation
@main
struct AbilityKitCLI: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "abilitykit",
        abstract: "Command-line interface for AbilityKit - Boss ability analysis for healers",
        version: "1.0.0",
        subcommands: [
            AnalyzeCommand.self,
            ValidateCommand.self,
            BenchmarkCommand.self,
            ExportCommand.self
        ]
    )
}

// MARK: - Analyze Command

struct AnalyzeCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "analyze",
        abstract: "Analyze abilities for a boss encounter, show classifications and healer recommendations"
    )

    @Option(name: .shortAndLong, help: "Boss encounter UUID to analyze")
    var boss: String

    @Option(name: .shortAndLong, help: "Output format (json, human)")
    var format: OutputFormat = .human

    @Flag(name: .shortAndLong, help: "Include detailed healer action recommendations")
    var verbose: Bool = false

    mutating func run() throws {
        let bossUUID = try parseUUID(from: boss, context: "boss")

        let dataProvider = AbilityKit.createAbilityDataProvider()
        let classificationService = AbilityKit.createAbilityClassificationService()
        let analyzer = AbilityKit.createDamageProfileAnalyzer()

        Task {
            do {
                // Fetch abilities for the boss
                let abilities = try await dataProvider.fetchAbilities(for: bossUUID)

                guard !abilities.isEmpty else {
                    print(formatError("No abilities found for boss encounter \(boss)"))
                    return
                }

                // Analyze damage profile
                let damageAnalysis = try await analyzer.analyzeDamageProfile(for: bossUUID)

                // Classify each ability
                let classifications = abilities.map { ability in
                    return AnalyzedAbility(
                        ability: ability,
                        classification: classificationService.classifyAbility(ability),
                        colorScheme: analyzer.getUIColorScheme(for: ability.damageProfile)
                    )
                }

                // Prioritize abilities
                let prioritizedAbilities = analyzer.prioritizeForHealer(abilities)

                let result = AnalysisResult(
                    bossEncounterId: bossUUID,
                    damageAnalysis: damageAnalysis,
                    analyzedAbilities: classifications,
                    prioritizedAbilities: prioritizedAbilities,
                    healerRecommendations: generateHealerRecommendations(from: classifications)
                )

                print(formatAnalysisResult(result, format: format, verbose: verbose))

            } catch {
                print(formatError("Analysis failed: \(error.localizedDescription)"))
            }
        }
    }
}

// MARK: - Validate Command

struct ValidateCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "validate",
        abstract: "Validate ability data for healer relevance and completeness"
    )

    @Option(name: .shortAndLong, help: "Boss encounter UUID to validate")
    var encounter: String

    @Flag(name: .shortAndLong, help: "Show only validation errors")
    var errorsOnly: Bool = false

    @Flag(name: .shortAndLong, help: "Detailed validation output with recommendations")
    var verbose: Bool = false

    mutating func run() throws {
        let encounterUUID = try parseUUID(from: encounter, context: "encounter")

        let dataProvider = AbilityKit.createAbilityDataProvider()
        let classificationService = AbilityKit.createAbilityClassificationService()

        Task {
            do {
                let abilities = try await dataProvider.fetchAbilities(for: encounterUUID)

                guard !abilities.isEmpty else {
                    print(formatError("No abilities found for encounter \(encounter)"))
                    return
                }

                var allValidationResults: [AbilityValidationResult] = []
                var totalIssues = 0
                var totalErrors = 0

                for ability in abilities {
                    let validationResult = classificationService.validateHealerRelevance(ability)

                    let errors = validationResult.issues.filter { $0.severity == .error }.count
                    let warnings = validationResult.issues.filter { $0.severity == .warning }.count

                    totalIssues += validationResult.issues.count
                    totalErrors += errors

                    let abilityValidation = AbilityValidationResult(
                        ability: ability,
                        validation: validationResult,
                        errorCount: errors,
                        warningCount: warnings
                    )

                    if !errorsOnly || !validationResult.isValid {
                        allValidationResults.append(abilityValidation)
                    }
                }

                let summary = ValidationSummary(
                    encounterUUID: encounterUUID,
                    totalAbilities: abilities.count,
                    validAbilities: abilities.count - totalErrors,
                    totalIssues: totalIssues,
                    totalErrors: totalErrors,
                    results: allValidationResults
                )

                print(formatValidationSummary(summary, verbose: verbose, errorsOnly: errorsOnly))

            } catch {
                print(formatError("Validation failed: \(error.localizedDescription)"))
            }
        }
    }
}

// MARK: - Benchmark Command

struct BenchmarkCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "benchmark",
        abstract: "Performance test ability queries and classification operations"
    )

    @Option(name: .shortAndLong, help: "Number of queries to benchmark")
    var queries: Int = 1000

    @Flag(name: .shortAndLong, help: "Include memory usage measurements")
    var memory: Bool = false

    @Flag(name: .shortAndLong, help: "Detailed timing breakdown")
    var verbose: Bool = false

    mutating func run() throws {
        let dataProvider = AbilityKit.createAbilityDataProvider()
        let classificationService = AbilityKit.createAbilityClassificationService()
        let analyzer = AbilityKit.createDamageProfileAnalyzer()

        Task {
            print("🔄 Starting AbilityKit performance benchmark with \(queries) iterations...")

            // Get sample data for benchmarking
            let sampleAbilities = await getSampleAbilities(dataProvider: dataProvider)

            guard !sampleAbilities.isEmpty else {
                print(formatError("No sample data available for benchmarking"))
                return
            }

            let benchmarkResult = await runBenchmarkSuite(
                abilities: sampleAbilities,
                iterations: queries,
                dataProvider: dataProvider,
                classificationService: classificationService,
                analyzer: analyzer,
                measureMemory: memory
            )

            print(formatBenchmarkResult(benchmarkResult, verbose: verbose))
        }
    }
}

// MARK: - Export Command

struct ExportCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "export",
        abstract: "Export ability classifications filtered by damage profile"
    )

    @Option(name: .shortAndLong, help: "Output format (json, csv, human)")
    var format: OutputFormat = .csv

    @Option(name: .long, help: "Filter by damage profile (critical, high, moderate, mechanic)")
    var damageProfile: String?

    @Option(name: .shortAndLong, help: "Output file path")
    var output: String?

    @Flag(name: .shortAndLong, help: "Include color scheme information")
    var includeColors: Bool = false

    @Flag(name: .shortAndLong, help: "Include healer action recommendations")
    var includeActions: Bool = false

    mutating func run() throws {
        let dataProvider = AbilityKit.createAbilityDataProvider()
        let classificationService = AbilityKit.createAbilityClassificationService()
        let analyzer = AbilityKit.createDamageProfileAnalyzer()

        Task {
            do {
                // Parse damage profile filter if provided
                let profileFilter = try parseDamageProfileFilter(damageProfile)

                // Get all available abilities (in production, this would query all encounters)
                let allAbilities = await getAllAvailableAbilities(dataProvider: dataProvider)

                // Filter by damage profile if specified
                let filteredAbilities = profileFilter.map { profile in
                    allAbilities.filter { $0.damageProfile == profile }
                } ?? allAbilities

                guard !filteredAbilities.isEmpty else {
                    let filterText = profileFilter?.rawValue ?? "all profiles"
                    print(formatError("No abilities found for filter: \(filterText)"))
                    return
                }

                // Generate export data
                let exportData = filteredAbilities.map { ability in
                    ExportAbilityData(
                        ability: ability,
                        classification: classificationService.classifyAbility(ability),
                        colorScheme: includeColors ? analyzer.getUIColorScheme(for: ability.damageProfile) : nil,
                        actions: includeActions ? classificationService.getRecommendedActions(for: ability.damageProfile) : []
                    )
                }

                let formattedOutput = formatExportData(exportData, format: format)

                // Write to file or stdout
                if let outputPath = output {
                    try formattedOutput.write(to: URL(fileURLWithPath: outputPath), atomically: true, encoding: .utf8)
                    print("✅ Export completed: \(outputPath)")
                    print("📊 Exported \(exportData.count) abilities")
                } else {
                    print(formattedOutput)
                }

            } catch {
                print(formatError("Export failed: \(error.localizedDescription)"))
            }
        }
    }
}

// MARK: - Supporting Types

enum OutputFormat: String, CaseIterable, ExpressibleByArgument {
    case json = "json"
    case csv = "csv"
    case human = "human"
}

struct AnalyzedAbility {
    let ability: AbilityEntity
    let classification: AbilityClassification
    let colorScheme: AbilityColorScheme
}

struct AnalysisResult {
    let bossEncounterId: UUID
    let damageAnalysis: DamageAnalysis
    let analyzedAbilities: [AnalyzedAbility]
    let prioritizedAbilities: [PrioritizedAbility]
    let healerRecommendations: [String]
}

struct AbilityValidationResult {
    let ability: AbilityEntity
    let validation: ValidationResult
    let errorCount: Int
    let warningCount: Int
}

struct ValidationSummary {
    let encounterUUID: UUID
    let totalAbilities: Int
    let validAbilities: Int
    let totalIssues: Int
    let totalErrors: Int
    let results: [AbilityValidationResult]
}

struct BenchmarkResult {
    let iterations: Int
    let totalTime: TimeInterval
    let averageTime: TimeInterval
    let queryTimes: BenchmarkTimes
    let classificationTimes: BenchmarkTimes
    let analysisTimes: BenchmarkTimes
    let memoryUsage: MemoryUsage?
}

struct BenchmarkTimes {
    let total: TimeInterval
    let average: TimeInterval
    let min: TimeInterval
    let max: TimeInterval
}

struct MemoryUsage {
    let initial: UInt64
    let peak: UInt64
    let final: UInt64
}

struct ExportAbilityData {
    let ability: AbilityEntity
    let classification: AbilityClassification
    let colorScheme: AbilityColorScheme?
    let actions: [HealerAction]
}

// MARK: - Helper Functions

func parseUUID(from string: String, context: String) throws -> UUID {
    guard let uuid = UUID(uuidString: string) else {
        throw ValidationError("Invalid \(context) UUID: \(string)")
    }
    return uuid
}

func parseDamageProfileFilter(_ profile: String?) throws -> DamageProfile? {
    guard let profile = profile else { return nil }

    guard let damageProfile = DamageProfile(rawValue: profile.lowercased()) else {
        let validProfiles = DamageProfile.allCases.map { $0.rawValue }.joined(separator: ", ")
        throw ValidationError("Invalid damage profile: \(profile). Valid options: \(validProfiles)")
    }

    return damageProfile
}

func generateHealerRecommendations(from abilities: [AnalyzedAbility]) -> [String] {
    var recommendations: [String] = []

    let criticalCount = abilities.filter { $0.ability.damageProfile == .critical }.count
    if criticalCount >= 2 {
        recommendations.append("⚠️  Multiple critical abilities detected - prepare major defensive cooldowns")
    }

    let groupAbilities = abilities.filter { $0.ability.targets == .group }.count
    if groupAbilities >= 3 {
        recommendations.append("🔄 High group damage - ensure AoE healing rotation is ready")
    }

    let immediateActions = abilities.filter { $0.classification.urgency == .immediate }.count
    if immediateActions >= 2 {
        recommendations.append("⚡ Multiple immediate-response abilities - practice reaction timing")
    }

    return recommendations
}

func getSampleAbilities(dataProvider: AbilityDataProviding) async -> [AbilityEntity] {
    do {
        return try await dataProvider.searchAbilities(query: "")
    } catch {
        return []
    }
}

func getAllAvailableAbilities(dataProvider: AbilityDataProviding) async -> [AbilityEntity] {
    return await getSampleAbilities(dataProvider: dataProvider)
}

func runBenchmarkSuite(
    abilities: [AbilityEntity],
    iterations: Int,
    dataProvider: AbilityDataProviding,
    classificationService: AbilityClassificationService,
    analyzer: DamageProfileAnalyzer,
    measureMemory: Bool
) async -> BenchmarkResult {

    let initialMemory = measureMemory ? getMemoryUsage() : 0
    var peakMemory: UInt64 = initialMemory

    let startTime = CFAbsoluteTimeGetCurrent()

    var queryTimes: [TimeInterval] = []
    var classificationTimes: [TimeInterval] = []
    var analysisTimes: [TimeInterval] = []

    let testAbility = abilities.first!
    let testBossId = testAbility.bossEncounterId

    for _ in 0..<iterations {
        // Benchmark queries
        let queryStart = CFAbsoluteTimeGetCurrent()
        _ = try? await dataProvider.fetchAbilities(for: testBossId)
        let queryTime = CFAbsoluteTimeGetCurrent() - queryStart
        queryTimes.append(queryTime)

        // Benchmark classification
        let classStart = CFAbsoluteTimeGetCurrent()
        _ = classificationService.classifyAbility(testAbility)
        let classTime = CFAbsoluteTimeGetCurrent() - classStart
        classificationTimes.append(classTime)

        // Benchmark analysis (less frequently to avoid overhead)
        if (iterations < 100) || ((iterations / 10) > 0 && (iterations % (iterations / 10)) == 0) {
            let analysisStart = CFAbsoluteTimeGetCurrent()
            _ = try? await analyzer.analyzeDamageProfile(for: testBossId)
            let analysisTime = CFAbsoluteTimeGetCurrent() - analysisStart
            analysisTimes.append(analysisTime)
        }

        if measureMemory {
            peakMemory = max(peakMemory, getMemoryUsage())
        }
    }

    let totalTime = CFAbsoluteTimeGetCurrent() - startTime
    let finalMemory = measureMemory ? getMemoryUsage() : 0

    let memoryUsage = measureMemory ? MemoryUsage(
        initial: initialMemory,
        peak: peakMemory,
        final: finalMemory
    ) : nil

    return BenchmarkResult(
        iterations: iterations,
        totalTime: totalTime,
        averageTime: totalTime / Double(iterations),
        queryTimes: BenchmarkTimes(
            total: queryTimes.reduce(0, +),
            average: queryTimes.reduce(0, +) / Double(queryTimes.count),
            min: queryTimes.min() ?? 0,
            max: queryTimes.max() ?? 0
        ),
        classificationTimes: BenchmarkTimes(
            total: classificationTimes.reduce(0, +),
            average: classificationTimes.reduce(0, +) / Double(classificationTimes.count),
            min: classificationTimes.min() ?? 0,
            max: classificationTimes.max() ?? 0
        ),
        analysisTimes: BenchmarkTimes(
            total: analysisTimes.reduce(0, +),
            average: analysisTimes.reduce(0, +) / Double(analysisTimes.count),
            min: analysisTimes.min() ?? 0,
            max: analysisTimes.max() ?? 0
        ),
        memoryUsage: memoryUsage
    )
}

func getMemoryUsage() -> UInt64 {
    var info = mach_task_basic_info()
    var count = mach_msg_type_number_t(MemoryLayout.size(ofValue: info) / MemoryLayout<integer_t>.size)

    let result = withUnsafeMutablePointer(to: &info) {
        $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
            task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
        }
    }

    return result == KERN_SUCCESS ? info.resident_size : 0
}

// MARK: - Formatting Functions

func formatError(_ message: String) -> String {
    return "❌ Error: \(message)"
}

func formatAnalysisResult(_ result: AnalysisResult, format: OutputFormat, verbose: Bool) -> String {
    switch format {
    case .json:
        return formatAnalysisAsJSON(result, verbose: verbose)
    case .human:
        return formatAnalysisAsHuman(result, verbose: verbose)
    case .csv:
        return formatAnalysisAsCSV(result)
    }
}

func formatAnalysisAsJSON(_ result: AnalysisResult, verbose: Bool) -> String {
    var json: [String: Any] = [
        "boss_encounter_id": result.bossEncounterId.uuidString,
        "total_abilities": result.analyzedAbilities.count,
        "healing_load": result.damageAnalysis.predictedHealingLoad.rawValue,
        "damage_profile_distribution": result.damageAnalysis.damageProfileDistribution.mapValues { $0 }
    ]

    if verbose {
        json["abilities"] = result.analyzedAbilities.map { analyzed in
            [
                "id": analyzed.ability.id.uuidString,
                "name": analyzed.ability.name,
                "damage_profile": analyzed.ability.damageProfile.rawValue,
                "urgency": analyzed.classification.urgency.rawValue,
                "complexity": analyzed.classification.complexity.rawValue,
                "healer_impact": analyzed.classification.healerImpact.rawValue,
                "healer_action": analyzed.ability.healerAction,
                "critical_insight": analyzed.ability.criticalInsight,
                "color_scheme": [
                    "primary": analyzed.colorScheme.primaryColor,
                    "background": analyzed.colorScheme.backgroundColor,
                    "text": analyzed.colorScheme.textColor,
                    "border": analyzed.colorScheme.borderColor
                ]
            ]
        }

        json["recommendations"] = result.healerRecommendations
        json["cooldown_plan"] = result.damageAnalysis.recommendedCooldownPlan.map { rec in
            [
                "cooldown": rec.cooldownName,
                "timing": rec.suggestedTiming,
                "rationale": rec.rationale,
                "target_count": rec.targetAbilities.count
            ]
        }
    }

    do {
        let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        return String(data: jsonData, encoding: .utf8) ?? "{\"error\": \"JSON encoding failed\"}"
    } catch {
        return "{\"error\": \"JSON serialization failed: \(error.localizedDescription)\"}"
    }
}

func formatAnalysisAsHuman(_ result: AnalysisResult, verbose: Bool) -> String {
    var output: [String] = []

    output.append("📊 AbilityKit Analysis Report")
    output.append("═══════════════════════════")
    output.append("Boss Encounter: \(result.bossEncounterId.uuidString)")
    output.append("Total Abilities: \(result.analyzedAbilities.count)")
    output.append("Predicted Healing Load: \(result.damageAnalysis.predictedHealingLoad.rawValue.capitalized)")
    output.append("")

    // Damage Profile Distribution
    output.append("🎯 Damage Profile Distribution:")
    for profile in DamageProfile.allCases {
        let count = result.damageAnalysis.damageProfileDistribution[profile] ?? 0
        let percentage = Double(count) / Double(result.analyzedAbilities.count) * 100
        let emoji = profile == .critical ? "🔴" : profile == .high ? "🟠" : profile == .moderate ? "🟡" : "🔵"
        output.append("  \(emoji) \(profile.rawValue.capitalized): \(count) abilities (\(String(format: "%.1f", percentage))%)")
    }
    output.append("")

    if verbose {
        // Top Priority Abilities
        output.append("⚡ Priority Abilities for Healers:")
        let topPriorities = result.prioritizedAbilities.prefix(5)
        for prioritized in topPriorities {
            let ability = prioritized.ability
            output.append("  • \(ability.name) (\(ability.damageProfile.rawValue.capitalized))")
            output.append("    Action: \(ability.healerAction)")
            output.append("    Priority: \(prioritized.priority) - \(prioritized.reasoning)")
            output.append("")
        }

        // Cooldown Recommendations
        if !result.damageAnalysis.recommendedCooldownPlan.isEmpty {
            output.append("🛡️  Recommended Cooldown Plan:")
            for rec in result.damageAnalysis.recommendedCooldownPlan {
                output.append("  • \(rec.cooldownName): \(rec.suggestedTiming)")
                output.append("    Rationale: \(rec.rationale)")
                output.append("")
            }
        }
    }

    // Healer Recommendations
    if !result.healerRecommendations.isEmpty {
        output.append("💡 Healer Recommendations:")
        for rec in result.healerRecommendations {
            output.append("  \(rec)")
        }
        output.append("")
    }

    return output.joined(separator: "\n")
}

func formatAnalysisAsCSV(_ result: AnalysisResult) -> String {
    var csv: [String] = []

    csv.append("ability_id,name,type,damage_profile,urgency,complexity,impact,healer_action,critical_insight,priority")

    for (analyzed, prioritized) in zip(result.analyzedAbilities, result.prioritizedAbilities) {
        let ability = analyzed.ability
        let classification = analyzed.classification

        let row = [
            ability.id.uuidString,
            escapeCSV(ability.name),
            ability.type.rawValue,
            ability.damageProfile.rawValue,
            String(classification.urgency.rawValue),
            String(classification.complexity.rawValue),
            String(classification.healerImpact.rawValue),
            escapeCSV(ability.healerAction),
            escapeCSV(ability.criticalInsight),
            String(prioritized.priority)
        ].joined(separator: ",")

        csv.append(row)
    }

    return csv.joined(separator: "\n")
}

func formatValidationSummary(_ summary: ValidationSummary, verbose: Bool, errorsOnly: Bool) -> String {
    var output: [String] = []

    output.append("✅ AbilityKit Validation Report")
    output.append("═══════════════════════════════")
    output.append("Encounter: \(summary.encounterUUID.uuidString)")
    output.append("Total Abilities: \(summary.totalAbilities)")
    output.append("Valid Abilities: \(summary.validAbilities)")
    output.append("Total Issues: \(summary.totalIssues)")
    output.append("Errors: \(summary.totalErrors)")
    output.append("")

    let successRate = Double(summary.validAbilities) / Double(summary.totalAbilities) * 100
    let status = summary.totalErrors == 0 ? "✅ PASS" : "❌ FAIL"
    output.append("Validation Status: \(status) (\(String(format: "%.1f", successRate))% success rate)")
    output.append("")

    if verbose || summary.totalErrors > 0 {
        output.append("📋 Detailed Results:")

        for result in summary.results {
            let ability = result.ability

            if errorsOnly && result.errorCount == 0 {
                continue
            }

            output.append("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            output.append("Ability: \(ability.name)")

            if result.errorCount > 0 {
                output.append("Status: ❌ INVALID (\(result.errorCount) errors, \(result.warningCount) warnings)")
            } else if result.warningCount > 0 {
                output.append("Status: ⚠️  WARNING (\(result.warningCount) warnings)")
            } else {
                output.append("Status: ✅ VALID")
            }

            for issue in result.validation.issues {
                let emoji = issue.severity == .error ? "❌" : issue.severity == .warning ? "⚠️" : "ℹ️"
                output.append("  \(emoji) [\(issue.severity.rawValue.uppercased())] \(issue.message)")
                if let field = issue.field {
                    output.append("      Field: \(field)")
                }
            }

            if verbose && !result.validation.recommendations.isEmpty {
                output.append("  💡 Recommendations:")
                for rec in result.validation.recommendations {
                    output.append("    • \(rec)")
                }
            }

            output.append("")
        }
    }

    return output.joined(separator: "\n")
}

func formatBenchmarkResult(_ result: BenchmarkResult, verbose: Bool) -> String {
    var output: [String] = []

    output.append("🚀 AbilityKit Performance Benchmark")
    output.append("═══════════════════════════════════")
    output.append("Iterations: \(result.iterations)")
    output.append("Total Time: \(String(format: "%.3f", result.totalTime))s")
    output.append("Average Time per Operation: \(String(format: "%.6f", result.averageTime))s")
    output.append("")

    output.append("📊 Performance Breakdown:")
    output.append("┌─────────────────┬──────────┬──────────┬──────────┬──────────┐")
    output.append("│ Operation       │ Total    │ Average  │ Min      │ Max      │")
    output.append("├─────────────────┼──────────┼──────────┼──────────┼──────────┤")

    let queryLine = String(format: "│ %-15s │ %8.3fs │ %8.6fs │ %8.6fs │ %8.6fs │",
                          "Query", result.queryTimes.total, result.queryTimes.average,
                          result.queryTimes.min, result.queryTimes.max)
    output.append(queryLine)

    let classLine = String(format: "│ %-15s │ %8.3fs │ %8.6fs │ %8.6fs │ %8.6fs │",
                          "Classification", result.classificationTimes.total, result.classificationTimes.average,
                          result.classificationTimes.min, result.classificationTimes.max)
    output.append(classLine)

    let analysisLine = String(format: "│ %-15s │ %8.3fs │ %8.6fs │ %8.6fs │ %8.6fs │",
                             "Analysis", result.analysisTimes.total, result.analysisTimes.average,
                             result.analysisTimes.min, result.analysisTimes.max)
    output.append(analysisLine)

    output.append("└─────────────────┴──────────┴──────────┴──────────┴──────────┘")
    output.append("")

    // Performance Assessment
    let queryPerf = result.queryTimes.average < 0.001 ? "🟢 Excellent" :
                   result.queryTimes.average < 0.01 ? "🟡 Good" : "🔴 Needs Improvement"
    let classPerf = result.classificationTimes.average < 0.0001 ? "🟢 Excellent" :
                   result.classificationTimes.average < 0.001 ? "🟡 Good" : "🔴 Needs Improvement"

    output.append("📈 Performance Assessment:")
    output.append("  Query Performance: \(queryPerf)")
    output.append("  Classification Performance: \(classPerf)")
    output.append("")

    if let memory = result.memoryUsage {
        output.append("💾 Memory Usage:")
        output.append("  Initial: \(formatBytes(memory.initial))")
        output.append("  Peak: \(formatBytes(memory.peak))")
        output.append("  Final: \(formatBytes(memory.final))")
        output.append("  Growth: \(formatBytes(memory.final - memory.initial))")
        output.append("")
    }

    // Recommendations
    output.append("💡 Performance Recommendations:")
    if result.queryTimes.average > 0.01 {
        output.append("  • Consider optimizing database queries or adding indexes")
    }
    if result.classificationTimes.average > 0.001 {
        output.append("  • Classification algorithm may benefit from caching")
    }
    if let memory = result.memoryUsage, memory.final > memory.initial * 2 {
        output.append("  • Memory usage grew significantly - check for leaks")
    }
    if result.queryTimes.max > result.queryTimes.average * 10 {
        output.append("  • High variance in query times - investigate outliers")
    }

    return output.joined(separator: "\n")
}

func formatExportData(_ data: [ExportAbilityData], format: OutputFormat) -> String {
    switch format {
    case .json:
        return formatExportAsJSON(data)
    case .csv:
        return formatExportAsCSV(data)
    case .human:
        return formatExportAsHuman(data)
    }
}

func formatExportAsJSON(_ data: [ExportAbilityData]) -> String {
    let jsonArray = data.map { item in
        var abilityData: [String: Any] = [
            "id": item.ability.id.uuidString,
            "name": item.ability.name,
            "type": item.ability.type.rawValue,
            "damage_profile": item.ability.damageProfile.rawValue,
            "targets": item.ability.targets.rawValue,
            "healer_action": item.ability.healerAction,
            "critical_insight": item.ability.criticalInsight,
            "display_order": item.ability.displayOrder,
            "is_key_mechanic": item.ability.isKeyMechanic,
            "classification": [
                "urgency": item.classification.urgency.rawValue,
                "complexity": item.classification.complexity.rawValue,
                "healer_impact": item.classification.healerImpact.rawValue,
                "preparation": item.classification.recommendedPreparation
            ]
        ]

        if let cooldown = item.ability.cooldown {
            abilityData["cooldown"] = cooldown
        }

        if let colorScheme = item.colorScheme {
            abilityData["color_scheme"] = [
                "primary": colorScheme.primaryColor,
                "background": colorScheme.backgroundColor,
                "text": colorScheme.textColor,
                "border": colorScheme.borderColor
            ]
        }

        if !item.actions.isEmpty {
            abilityData["recommended_actions"] = item.actions.map { action in
                [
                    "type": action.actionType.rawValue,
                    "timing": action.timing.rawValue,
                    "description": action.description,
                    "keybind": action.keyBindSuggestion as Any
                ]
            }
        }

        return abilityData
    }

    do {
        let jsonData = try JSONSerialization.data(withJSONObject: jsonArray, options: .prettyPrinted)
        return String(data: jsonData, encoding: .utf8) ?? "[]"
    } catch {
        return "[]"
    }
}

func formatExportAsCSV(_ data: [ExportAbilityData]) -> String {
    var csv: [String] = []

    // Header
    csv.append([
        "id", "name", "type", "damage_profile", "targets", "urgency", "complexity",
        "healer_impact", "healer_action", "critical_insight", "cooldown",
        "is_key_mechanic", "primary_color", "background_color", "text_color", "border_color"
    ].joined(separator: ","))

    // Data rows
    for item in data {
        let row = [
            item.ability.id.uuidString,
            escapeCSV(item.ability.name),
            item.ability.type.rawValue,
            item.ability.damageProfile.rawValue,
            item.ability.targets.rawValue,
            String(item.classification.urgency.rawValue),
            String(item.classification.complexity.rawValue),
            String(item.classification.healerImpact.rawValue),
            escapeCSV(item.ability.healerAction),
            escapeCSV(item.ability.criticalInsight),
            item.ability.cooldown?.description ?? "",
            String(item.ability.isKeyMechanic),
            item.colorScheme?.primaryColor ?? "",
            item.colorScheme?.backgroundColor ?? "",
            item.colorScheme?.textColor ?? "",
            item.colorScheme?.borderColor ?? ""
        ].joined(separator: ",")

        csv.append(row)
    }

    return csv.joined(separator: "\n")
}

func formatExportAsHuman(_ data: [ExportAbilityData]) -> String {
    var output: [String] = []

    output.append("📋 AbilityKit Export Report")
    output.append("═════════════════════════")
    output.append("Total Abilities: \(data.count)")
    output.append("Export Date: \(DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .short))")
    output.append("")

    for item in data {
        let ability = item.ability
        let classification = item.classification

        output.append("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        output.append("🎯 \(ability.name)")
        output.append("   Type: \(ability.type.rawValue) | Profile: \(ability.damageProfile.rawValue)")
        output.append("   Targets: \(ability.targets.rawValue) | Key Mechanic: \(ability.isKeyMechanic ? "Yes" : "No")")

        if let cooldown = ability.cooldown {
            output.append("   Cooldown: \(String(format: "%.1f", cooldown))s")
        }

        output.append("")
        output.append("   Healer Action: \(ability.healerAction)")
        output.append("   Critical Insight: \(ability.criticalInsight)")
        output.append("")
        output.append("   Classification:")
        output.append("     • Urgency: \(urgencyDescription(classification.urgency))")
        output.append("     • Complexity: \(complexityDescription(classification.complexity))")
        output.append("     • Impact: \(impactDescription(classification.healerImpact))")
        output.append("     • Preparation: \(classification.recommendedPreparation)")

        if let colorScheme = item.colorScheme {
            output.append("")
            output.append("   UI Colors: Primary: \(colorScheme.primaryColor) | Background: \(colorScheme.backgroundColor)")
        }

        if !item.actions.isEmpty {
            output.append("")
            output.append("   Recommended Actions:")
            for action in item.actions {
                let keybind = action.keyBindSuggestion.map { " [\($0)]" } ?? ""
                output.append("     • \(action.description)\(keybind)")
            }
        }

        output.append("")
    }

    return output.joined(separator: "\n")
}

// MARK: - Utility Functions

func escapeCSV(_ text: String) -> String {
    if text.contains(",") || text.contains("\"") || text.contains("\n") {
        return "\"" + text.replacingOccurrences(of: "\"", with: "\"\"") + "\""
    }
    return text
}

func formatBytes(_ bytes: UInt64) -> String {
    let formatter = ByteCountFormatter()
    formatter.allowedUnits = [.useKB, .useMB, .useGB]
    formatter.countStyle = .memory
    return formatter.string(fromByteCount: Int64(bytes))
}

func urgencyDescription(_ urgency: UrgencyLevel) -> String {
    switch urgency {
    case .immediate: return "Immediate (1-2s)"
    case .high: return "High (3-5s)"
    case .moderate: return "Moderate (5-10s)"
    case .low: return "Low (passive)"
    }
}

func complexityDescription(_ complexity: ComplexityLevel) -> String {
    switch complexity {
    case .simple: return "Simple (single action)"
    case .moderate: return "Moderate (positioning + healing)"
    case .complex: return "Complex (multi-step)"
    case .extreme: return "Extreme (team coordination)"
    }
}

func impactDescription(_ impact: ImpactLevel) -> String {
    switch impact {
    case .critical: return "Critical (encounter-ending)"
    case .high: return "High (significant damage/death)"
    case .moderate: return "Moderate (manageable)"
    case .low: return "Low (minor)"
    }
}

// MARK: - Error Types

struct ValidationError: LocalizedError {
    let message: String

    init(_ message: String) {
        self.message = message
    }

    var errorDescription: String? {
        return message
    }
}