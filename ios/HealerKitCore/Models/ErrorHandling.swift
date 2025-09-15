//
//  ErrorHandling.swift
//  HealerKitCore
//
//  Created by HealerKit on 2025-09-15.
//  Comprehensive error handling system for HealerKit libraries
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif

// MARK: - Error Management

/// Centralized error manager for HealerKit
public class HealerKitErrorManager {
    public static let shared = HealerKitErrorManager()

    private var errorHandlers: [ErrorCategory: (HealerKitError) -> Void] = [:]
    private var errorLog: [ErrorLogEntry] = []
    private let maxLogSize = 1000

    private init() {}

    /// Register error handler for specific category
    public func registerHandler(for category: ErrorCategory, handler: @escaping (HealerKitError) -> Void) {
        errorHandlers[category] = handler
    }

    /// Handle error with appropriate severity and category
    public func handleError(_ error: HealerKitError) {
        // Log the error
        logError(error)

        // Execute registered handler
        errorHandlers[error.category]?(error)

        // Handle critical errors immediately
        if error.severity == .critical {
            handleCriticalError(error)
        }
    }

    /// Handle non-HealerKitError types
    public func handleError(_ error: Error, category: ErrorCategory, severity: ErrorSeverity) {
        let wrappedError = GenericHealerKitError(
            underlyingError: error,
            category: category,
            severity: severity
        )
        handleError(wrappedError)
    }

    private func logError(_ error: HealerKitError) {
        let entry = ErrorLogEntry(
            timestamp: Date(),
            error: error,
            context: getCurrentContext()
        )

        errorLog.append(entry)

        // Maintain log size
        if errorLog.count > maxLogSize {
            errorLog.removeFirst(errorLog.count - maxLogSize)
        }
    }

    private func handleCriticalError(_ error: HealerKitError) {
        // For critical errors, we should attempt recovery or graceful degradation
        switch error.category {
        case .dataAccess:
            handleCriticalDataError(error)
        case .performance:
            handleCriticalPerformanceError(error)
        case .ui:
            handleCriticalUIError(error)
        case .validation:
            handleCriticalValidationError(error)
        case .network:
            handleCriticalNetworkError(error)
        }
    }

    private func handleCriticalDataError(_ error: HealerKitError) {
        // Attempt to recover from data access errors
        #if canImport(UIKit)
        PerformanceOptimizer.shared.performEmergencyCleanup()
        #endif

        // Could trigger data re-import or fallback to cached data
        NotificationCenter.default.post(
            name: .criticalDataError,
            object: error
        )
    }

    private func handleCriticalPerformanceError(_ error: HealerKitError) {
        // Free up resources immediately
        #if canImport(UIKit)
        PerformanceOptimizer.shared.performEmergencyCleanup()
        #endif

        // Switch to low-performance mode
        NotificationCenter.default.post(
            name: .performanceEmergency,
            object: error
        )
    }

    private func handleCriticalUIError(_ error: HealerKitError) {
        // Attempt to recover UI state
        NotificationCenter.default.post(
            name: .uiRecoveryNeeded,
            object: error
        )
    }

    private func handleCriticalValidationError(_ error: HealerKitError) {
        // Log validation failure for content team
        NotificationCenter.default.post(
            name: .validationFailure,
            object: error
        )
    }

    private func handleCriticalNetworkError(_ error: HealerKitError) {
        // Switch to offline mode
        NotificationCenter.default.post(
            name: .networkFailure,
            object: error
        )
    }

    private func getCurrentContext() -> [String: Any] {
        var context: [String: Any] = [
            "timestamp": Date()
        ]

        #if canImport(UIKit)
        context["memoryUsage"] = PerformanceOptimizer.shared.getCurrentMemoryUsage().totalCacheSize
        context["frameRate"] = PerformanceOptimizer.shared.getCurrentFrameRate()
        context["device"] = UIDevice.current.model
        context["iOSVersion"] = UIDevice.current.systemVersion
        #endif

        return context
    }

    /// Get error statistics for debugging
    public func getErrorStatistics() -> ErrorStatistics {
        var categoryCounts: [ErrorCategory: Int] = [:]
        var severityCounts: [ErrorSeverity: Int] = [:]

        for entry in errorLog {
            categoryCounts[entry.error.category, default: 0] += 1
            severityCounts[entry.error.severity, default: 0] += 1
        }

        return ErrorStatistics(
            totalErrors: errorLog.count,
            categoryCounts: categoryCounts,
            severityCounts: severityCounts,
            recentErrors: Array(errorLog.suffix(10))
        )
    }

    /// Clear error log
    public func clearErrorLog() {
        errorLog.removeAll()
    }
}

// MARK: - Specific Error Types

/// Generic wrapper for non-HealerKitError types
public struct GenericHealerKitError: HealerKitError {
    public let underlyingError: Error
    public let category: ErrorCategory
    public let severity: ErrorSeverity

    public var errorDescription: String? {
        return underlyingError.localizedDescription
    }
}

/// Data access errors
public enum DataAccessError: LocalizedError, HealerKitError {
    case dungeonNotFound(UUID)
    case bossEncounterNotFound(UUID)
    case abilityNotFound(UUID)
    case seasonNotFound(String)
    case dataCorruption(String)
    case storageError(Error)
    case cacheError(String)
    case performanceThreshold(operation: String, duration: TimeInterval)

    public var category: ErrorCategory { .dataAccess }

    public var severity: ErrorSeverity {
        switch self {
        case .dataCorruption, .storageError:
            return .critical
        case .performanceThreshold:
            return .high
        case .cacheError:
            return .medium
        default:
            return .low
        }
    }

    public var errorDescription: String? {
        switch self {
        case .dungeonNotFound(let id):
            return "Dungeon with ID \(id) not found"
        case .bossEncounterNotFound(let id):
            return "Boss encounter with ID \(id) not found"
        case .abilityNotFound(let id):
            return "Ability with ID \(id) not found"
        case .seasonNotFound(let name):
            return "Season '\(name)' not found"
        case .dataCorruption(let details):
            return "Data corruption detected: \(details)"
        case .storageError(let error):
            return "Storage error: \(error.localizedDescription)"
        case .cacheError(let details):
            return "Cache error: \(details)"
        case .performanceThreshold(let operation, let duration):
            return "Performance threshold exceeded for \(operation): \(duration)s"
        }
    }
}

/// Validation errors
public enum ValidationError: LocalizedError, HealerKitError {
    case emptyRequiredField(field: String, entity: String)
    case invalidFormat(field: String, expected: String, actual: String)
    case constraintViolation(constraint: String, entity: String)
    case relationshipViolation(relationship: String, from: String, to: String)
    case businessRuleViolation(rule: String, context: String)
    case healerContentIncomplete(entity: String, missingFields: [String])

    public var category: ErrorCategory { .validation }

    public var severity: ErrorSeverity {
        switch self {
        case .constraintViolation, .relationshipViolation:
            return .high
        case .businessRuleViolation:
            return .medium
        default:
            return .low
        }
    }

    public var errorDescription: String? {
        switch self {
        case .emptyRequiredField(let field, let entity):
            return "Required field '\(field)' is empty in \(entity)"
        case .invalidFormat(let field, let expected, let actual):
            return "Invalid format for field '\(field)': expected \(expected), got \(actual)"
        case .constraintViolation(let constraint, let entity):
            return "Constraint violation in \(entity): \(constraint)"
        case .relationshipViolation(let relationship, let from, let to):
            return "Invalid relationship '\(relationship)' from \(from) to \(to)"
        case .businessRuleViolation(let rule, let context):
            return "Business rule violation: \(rule) in context: \(context)"
        case .healerContentIncomplete(let entity, let missingFields):
            return "Incomplete healer content in \(entity): missing \(missingFields.joined(separator: ", "))"
        }
    }
}

/// Performance errors
public enum PerformanceError: LocalizedError, HealerKitError {
    case memoryExhaustion(current: Int64, limit: Int64)
    case slowOperation(operation: String, duration: TimeInterval, threshold: TimeInterval)
    case frameDrops(currentFPS: Double, targetFPS: Double)
    case cacheOverflow(current: Int, limit: Int)
    case resourceLeakDetected(resourceType: String, count: Int)

    public var category: ErrorCategory { .performance }

    public var severity: ErrorSeverity {
        switch self {
        case .memoryExhaustion, .resourceLeakDetected:
            return .critical
        case .frameDrops, .cacheOverflow:
            return .high
        case .slowOperation:
            return .medium
        }
    }

    public var errorDescription: String? {
        switch self {
        case .memoryExhaustion(let current, let limit):
            return "Memory exhaustion: \(current / 1024 / 1024)MB / \(limit / 1024 / 1024)MB"
        case .slowOperation(let operation, let duration, let threshold):
            return "Slow operation '\(operation)': \(duration)s > \(threshold)s"
        case .frameDrops(let currentFPS, let targetFPS):
            return "Frame drops detected: \(currentFPS)fps < \(targetFPS)fps"
        case .cacheOverflow(let current, let limit):
            return "Cache overflow: \(current) items > \(limit) limit"
        case .resourceLeakDetected(let resourceType, let count):
            return "Resource leak detected: \(count) unreleased \(resourceType) instances"
        }
    }
}

/// UI errors
public enum UIError: LocalizedError, HealerKitError {
    case viewControllerCreationFailed(String)
    case layoutConstraintConflict(String)
    case accessibilityConfigurationError(String)
    case colorSchemeNotFound(DamageProfile)
    case imageLoadingFailed(String)
    case animationFailure(String)

    public var category: ErrorCategory { .ui }

    public var severity: ErrorSeverity {
        switch self {
        case .viewControllerCreationFailed:
            return .critical
        case .layoutConstraintConflict, .accessibilityConfigurationError:
            return .high
        case .colorSchemeNotFound, .imageLoadingFailed:
            return .medium
        case .animationFailure:
            return .low
        }
    }

    public var errorDescription: String? {
        switch self {
        case .viewControllerCreationFailed(let details):
            return "Failed to create view controller: \(details)"
        case .layoutConstraintConflict(let details):
            return "Layout constraint conflict: \(details)"
        case .accessibilityConfigurationError(let details):
            return "Accessibility configuration error: \(details)"
        case .colorSchemeNotFound(let profile):
            return "Color scheme not found for damage profile: \(profile.rawValue)"
        case .imageLoadingFailed(let imageName):
            return "Failed to load image: \(imageName)"
        case .animationFailure(let details):
            return "Animation failure: \(details)"
        }
    }
}

/// Network errors
public enum NetworkError: LocalizedError, HealerKitError {
    case noConnection
    case timeout(operation: String, duration: TimeInterval)
    case serverError(statusCode: Int, message: String?)
    case invalidResponse(expected: String, received: String)
    case dataParsingFailed(Error)

    public var category: ErrorCategory { .network }

    public var severity: ErrorSeverity {
        switch self {
        case .noConnection:
            return .medium  // App should work offline
        case .timeout, .serverError:
            return .high
        case .invalidResponse, .dataParsingFailed:
            return .medium
        }
    }

    public var errorDescription: String? {
        switch self {
        case .noConnection:
            return "No network connection available"
        case .timeout(let operation, let duration):
            return "Network timeout for \(operation): \(duration)s"
        case .serverError(let statusCode, let message):
            return "Server error \(statusCode): \(message ?? "Unknown error")"
        case .invalidResponse(let expected, let received):
            return "Invalid response: expected \(expected), received \(received)"
        case .dataParsingFailed(let error):
            return "Data parsing failed: \(error.localizedDescription)"
        }
    }
}

// MARK: - Supporting Types

public struct ErrorLogEntry {
    public let timestamp: Date
    public let error: HealerKitError
    public let context: [String: Any]

    public init(timestamp: Date, error: HealerKitError, context: [String: Any]) {
        self.timestamp = timestamp
        self.error = error
        self.context = context
    }
}

public struct ErrorStatistics {
    public let totalErrors: Int
    public let categoryCounts: [ErrorCategory: Int]
    public let severityCounts: [ErrorSeverity: Int]
    public let recentErrors: [ErrorLogEntry]

    public init(
        totalErrors: Int,
        categoryCounts: [ErrorCategory: Int],
        severityCounts: [ErrorSeverity: Int],
        recentErrors: [ErrorLogEntry]
    ) {
        self.totalErrors = totalErrors
        self.categoryCounts = categoryCounts
        self.severityCounts = severityCounts
        self.recentErrors = recentErrors
    }
}

// MARK: - Error Recovery

/// Error recovery strategies
public class ErrorRecoveryManager {
    public static let shared = ErrorRecoveryManager()

    private init() {}

    /// Attempt to recover from data access error
    public func recoverFromDataError(_ error: DataAccessError) -> Bool {
        switch error {
        case .cacheError:
            // Clear cache and retry
            clearDataCaches()
            return true

        case .performanceThreshold:
            // Reduce performance demands
            #if canImport(UIKit)
            PerformanceOptimizer.shared.performEmergencyCleanup()
            #endif
            return true

        case .storageError:
            // Attempt CoreData recovery
            return attemptCoreDataRecovery()

        default:
            return false
        }
    }

    /// Attempt to recover from performance error
    public func recoverFromPerformanceError(_ error: PerformanceError) -> Bool {
        switch error {
        case .memoryExhaustion:
            #if canImport(UIKit)
            PerformanceOptimizer.shared.performEmergencyCleanup()
            #endif
            return true

        case .frameDrops:
            // Reduce visual complexity
            NotificationCenter.default.post(name: .reduceVisualComplexity, object: nil)
            return true

        case .cacheOverflow:
            // Clear oldest cache entries
            clearOldCacheEntries()
            return true

        default:
            return false
        }
    }

    private func clearDataCaches() {
        // Clear various data caches
        NotificationCenter.default.post(name: .clearDataCaches, object: nil)
    }

    private func attemptCoreDataRecovery() -> Bool {
        // Attempt to recover CoreData stack
        // This would involve recreating the persistent store
        return false // Placeholder - real implementation would handle CoreData recovery
    }

    private func clearOldCacheEntries() {
        // Clear old cache entries across all caches
        NotificationCenter.default.post(name: .clearOldCacheEntries, object: nil)
    }
}

// MARK: - Notification Extensions

extension Notification.Name {
    public static let criticalDataError = Notification.Name("healerkit.error.critical.data")
    public static let performanceEmergency = Notification.Name("healerkit.error.performance.emergency")
    public static let uiRecoveryNeeded = Notification.Name("healerkit.error.ui.recovery")
    public static let validationFailure = Notification.Name("healerkit.error.validation.failure")
    public static let networkFailure = Notification.Name("healerkit.error.network.failure")
    public static let reduceVisualComplexity = Notification.Name("healerkit.performance.reduce.complexity")
    public static let clearDataCaches = Notification.Name("healerkit.cache.clear.data")
    public static let clearOldCacheEntries = Notification.Name("healerkit.cache.clear.old")
}