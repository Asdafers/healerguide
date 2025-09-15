//
//  CoreDataOptimizer.swift
//  HealerKitCore
//
//  Created by HealerKit on 2025-09-15.
//  CoreData performance optimization for first-generation iPad Pro
//

#if canImport(CoreData)
import Foundation
import CoreData

/// CoreData optimization utilities for iPad Pro performance
public class CoreDataOptimizer {

    // MARK: - Persistent Container Optimization

    /// Create optimized persistent container for first-generation iPad Pro
    public static func createOptimizedContainer(modelName: String) -> NSPersistentContainer {
        let container = NSPersistentContainer(name: modelName)

        // Configure store description for performance
        if let storeDescription = container.persistentStoreDescriptions.first {
            optimizeStoreDescription(storeDescription)
        }

        return container
    }

    /// Optimize store description for iPad Pro constraints
    private static func optimizeStoreDescription(_ description: NSPersistentStoreDescription) {
        // Enable history tracking for data synchronization
        description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)

        // SQLite optimizations
        description.setOption("WAL" as NSString, forKey: NSSQLitePragmasOption)

        // Memory management
        description.setValue("memory" as NSString, forKey: NSPersistentStoreFileProtectionKey)

        // Reduce file size and improve performance
        var pragmas: [String: Any] = [:]
        pragmas["synchronous"] = "NORMAL"  // Balance between speed and safety
        pragmas["cache_size"] = 2000       // 2000 pages cache (reasonable for 4GB RAM)
        pragmas["temp_store"] = "MEMORY"   // Use memory for temporary tables
        pragmas["mmap_size"] = 64 * 1024 * 1024  // 64MB memory mapping

        description.setOption(pragmas as NSObject, forKey: NSSQLitePragmasOption)
    }

    // MARK: - Context Optimization

    /// Configure managed object context for optimal performance
    public static func optimizeContext(_ context: NSManagedObjectContext) {
        // Remove undo manager for performance
        context.undoManager = nil

        // Configure merge policy for conflict resolution
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

        // Reduce memory footprint
        context.shouldDeleteInaccessibleFaults = true

        // Set staleness interval for cache efficiency
        context.stalenessInterval = 0  // Always fetch fresh data
    }

    // MARK: - Fetch Request Optimization

    /// Create optimized fetch request for iPad Pro performance
    public static func createOptimizedFetchRequest<T: NSManagedObject>(
        entityName: String,
        predicate: NSPredicate? = nil,
        sortDescriptors: [NSSortDescriptor]? = nil,
        fetchLimit: Int? = nil,
        prefetchRelationships: [String] = []
    ) -> NSFetchRequest<T> {

        let request = NSFetchRequest<T>(entityName: entityName)

        // Set predicate and sort descriptors
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors

        // Performance optimizations
        request.fetchBatchSize = 20  // Reasonable batch size for 4GB RAM
        request.returnsObjectsAsFaults = false  // Prefetch object data

        // Set fetch limit if provided
        if let limit = fetchLimit {
            request.fetchLimit = limit
        }

        // Prefetch relationships to avoid multiple round trips
        if !prefetchRelationships.isEmpty {
            request.relationshipKeyPathsForPrefetching = prefetchRelationships
        }

        return request
    }

    /// Create count-only fetch request for efficient counting
    public static func createCountFetchRequest<T: NSManagedObject>(
        entityName: String,
        predicate: NSPredicate? = nil
    ) -> NSFetchRequest<T> {
        let request = NSFetchRequest<T>(entityName: entityName)
        request.predicate = predicate
        request.resultType = .countResultType
        return request
    }

    // MARK: - Batch Operations

    /// Perform batch insert operation for efficient data loading
    public static func performBatchInsert<T: NSManagedObject>(
        entityName: String,
        objects: [[String: Any]],
        context: NSManagedObjectContext
    ) throws {
        let batchInsert = NSBatchInsertRequest(entityName: entityName, objects: objects)
        batchInsert.resultType = .objectIDs

        let result = try context.execute(batchInsert) as? NSBatchInsertResult
        let objectIDs = result?.result as? [NSManagedObjectID] ?? []

        // Merge changes into context
        let changes = [NSInsertedObjectsKey: objectIDs]
        NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [context])
    }

    /// Perform batch update operation
    public static func performBatchUpdate(
        entityName: String,
        predicate: NSPredicate? = nil,
        propertiesToUpdate: [String: Any],
        context: NSManagedObjectContext
    ) throws {
        let batchUpdate = NSBatchUpdateRequest(entityName: entityName)
        batchUpdate.predicate = predicate
        batchUpdate.propertiesToUpdate = propertiesToUpdate
        batchUpdate.resultType = .updatedObjectIDsResultType

        let result = try context.execute(batchUpdate) as? NSBatchUpdateResult
        let objectIDs = result?.result as? [NSManagedObjectID] ?? []

        // Merge changes into context
        let changes = [NSUpdatedObjectsKey: objectIDs]
        NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [context])
    }

    /// Perform batch delete operation
    public static func performBatchDelete<T: NSManagedObject>(
        fetchRequest: NSFetchRequest<T>,
        context: NSManagedObjectContext
    ) throws {
        let batchDelete = NSBatchDeleteRequest(fetchRequest: fetchRequest as! NSFetchRequest<NSFetchRequestResult>)
        batchDelete.resultType = .resultTypeObjectIDs

        let result = try context.execute(batchDelete) as? NSBatchDeleteResult
        let objectIDs = result?.result as? [NSManagedObjectID] ?? []

        // Merge changes into context
        let changes = [NSDeletedObjectsKey: objectIDs]
        NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [context])
    }

    // MARK: - Memory Management

    /// Reset context to free memory
    public static func resetContextForMemoryPressure(_ context: NSManagedObjectContext) {
        context.reset()
        context.refreshAllObjects()
    }

    /// Cleanup context by removing unnecessary objects
    public static func cleanupContext(_ context: NSManagedObjectContext) {
        // Refresh objects that haven't been accessed recently
        let cutoffDate = Date().addingTimeInterval(-300) // 5 minutes ago

        context.registeredObjects.forEach { object in
            if !object.isFault && object.changedValues().isEmpty {
                // Convert to fault to save memory
                context.refresh(object, mergeChanges: false)
            }
        }
    }

    // MARK: - Performance Monitoring

    /// Monitor CoreData performance metrics
    public static func monitorPerformance(
        for context: NSManagedObjectContext,
        operation: String,
        block: () throws -> Void
    ) rethrows {
        let startTime = CFAbsoluteTimeGetCurrent()
        let initialMemory = PerformanceOptimizer.shared.getCurrentMemoryUsage()

        try block()

        let endTime = CFAbsoluteTimeGetCurrent()
        let finalMemory = PerformanceOptimizer.shared.getCurrentMemoryUsage()

        let duration = endTime - startTime
        let memoryDelta = finalMemory.totalCacheSize - initialMemory.totalCacheSize

        // Log performance if it exceeds thresholds
        if duration > 0.1 || memoryDelta > 10 * 1024 * 1024 { // 100ms or 10MB
            logPerformanceMetric(
                operation: operation,
                duration: duration,
                memoryDelta: memoryDelta,
                context: context
            )
        }
    }

    private static func logPerformanceMetric(
        operation: String,
        duration: TimeInterval,
        memoryDelta: Int64,
        context: NSManagedObjectContext
    ) {
        let objectCount = context.registeredObjects.count
        print("CoreData Performance: \(operation) took \(duration * 1000)ms, memory delta: \(memoryDelta / 1024 / 1024)MB, objects: \(objectCount)")
    }

    // MARK: - Relationship Optimization

    /// Optimize relationship loading for better performance
    public static func optimizeRelationshipLoading<T: NSManagedObject>(
        objects: [T],
        relationshipKeys: [String],
        context: NSManagedObjectContext
    ) {
        guard !objects.isEmpty && !relationshipKeys.isEmpty else { return }

        // Batch fault relationships
        for key in relationshipKeys {
            let objectIDs = objects.compactMap { $0.objectID }
            if !objectIDs.isEmpty {
                try? context.existingObjects(with: objectIDs)
            }
        }
    }

    /// Prefetch relationships to avoid N+1 queries
    public static func prefetchRelationships<T: NSManagedObject>(
        for objects: [T],
        keyPaths: [String]
    ) {
        // Group objects by entity to batch prefetch
        let groupedObjects = Dictionary(grouping: objects) { $0.entity.name ?? "" }

        for (entityName, entityObjects) in groupedObjects {
            guard !entityObjects.isEmpty else { continue }

            // Create a dummy fetch request to trigger prefetching
            let context = entityObjects.first!.managedObjectContext!
            let request = NSFetchRequest<NSManagedObject>(entityName: entityName)
            request.relationshipKeyPathsForPrefetching = keyPaths
            request.predicate = NSPredicate(format: "SELF IN %@", entityObjects)

            try? context.fetch(request)
        }
    }
}

// MARK: - Extensions

extension NSManagedObjectContext {
    /// Perform work with automatic save and error handling
    public func performOptimizedWork<T>(
        _ work: (NSManagedObjectContext) throws -> T
    ) throws -> T {
        var result: T!
        var error: Error?

        performAndWait {
            do {
                result = try work(self)
                if self.hasChanges {
                    try self.save()
                }
            } catch {
                self.rollback()
                error = error
            }
        }

        if let error = error {
            throw error
        }

        return result
    }

    /// Safe object retrieval with error handling
    public func safeObject<T: NSManagedObject>(with objectID: NSManagedObjectID) -> T? {
        do {
            let object = try existingObject(with: objectID)
            return object as? T
        } catch {
            return nil
        }
    }
}

// MARK: - Validation Utilities

/// CoreData validation helpers
public class CoreDataValidator {

    /// Validate entity relationships and constraints
    public static func validateEntity<T: NSManagedObject>(_ object: T) throws {
        let context = object.managedObjectContext

        // Check for required relationships
        let entity = object.entity
        for relationship in entity.relationshipsByName.values {
            if !relationship.isOptional {
                let value = object.value(forKey: relationship.name)
                if value == nil {
                    throw CoreDataValidationError.missingRequiredRelationship(
                        entity: entity.name ?? "Unknown",
                        relationship: relationship.name
                    )
                }
            }
        }

        // Validate using Core Data's built-in validation
        try object.validateForInsert()
    }

    /// Validate data integrity after bulk operations
    public static func validateDataIntegrity(
        in context: NSManagedObjectContext,
        entityName: String
    ) throws -> ValidationSummary {
        let request = NSFetchRequest<NSManagedObject>(entityName: entityName)
        let objects = try context.fetch(request)

        var errors: [ValidationError] = []
        var warnings: [ValidationWarning] = []

        for object in objects {
            do {
                try validateEntity(object)
            } catch {
                errors.append(ValidationError(
                    objectID: object.objectID,
                    error: error
                ))
            }
        }

        return ValidationSummary(
            totalObjects: objects.count,
            validObjects: objects.count - errors.count,
            errors: errors,
            warnings: warnings
        )
    }
}

// MARK: - Supporting Types

public enum CoreDataValidationError: LocalizedError, HealerKitError {
    case missingRequiredRelationship(entity: String, relationship: String)
    case invalidDataType(entity: String, attribute: String, value: Any)
    case constraintViolation(entity: String, constraint: String)

    public var category: ErrorCategory { .validation }
    public var severity: ErrorSeverity { .high }

    public var errorDescription: String? {
        switch self {
        case .missingRequiredRelationship(let entity, let relationship):
            return "Missing required relationship '\(relationship)' in entity '\(entity)'"
        case .invalidDataType(let entity, let attribute, let value):
            return "Invalid data type for attribute '\(attribute)' in entity '\(entity)': \(value)"
        case .constraintViolation(let entity, let constraint):
            return "Constraint violation in entity '\(entity)': \(constraint)"
        }
    }
}

public struct ValidationError {
    public let objectID: NSManagedObjectID
    public let error: Error

    public init(objectID: NSManagedObjectID, error: Error) {
        self.objectID = objectID
        self.error = error
    }
}

public struct ValidationWarning {
    public let objectID: NSManagedObjectID
    public let message: String

    public init(objectID: NSManagedObjectID, message: String) {
        self.objectID = objectID
        self.message = message
    }
}

public struct ValidationSummary {
    public let totalObjects: Int
    public let validObjects: Int
    public let errors: [ValidationError]
    public let warnings: [ValidationWarning]

    public var isValid: Bool {
        return errors.isEmpty
    }

    public var successRate: Double {
        guard totalObjects > 0 else { return 0.0 }
        return Double(validObjects) / Double(totalObjects)
    }

    public init(totalObjects: Int, validObjects: Int, errors: [ValidationError], warnings: [ValidationWarning]) {
        self.totalObjects = totalObjects
        self.validObjects = validObjects
        self.errors = errors
        self.warnings = warnings
    }
}
#endif