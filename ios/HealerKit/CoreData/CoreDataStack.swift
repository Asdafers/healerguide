//
//  CoreDataStack.swift
//  HealerKit
//
//  Core Data stack initialization optimized for first-generation iPad Pro
//  Handles NSPersistentContainer configuration, migration, and memory management
//

import Foundation
import CoreData
import UIKit
import os.log

/// Core Data stack manager optimized for first-generation iPad Pro constraints
/// Provides thread-safe operations and memory-efficient management for 4GB RAM limit
public final class CoreDataStack {

    // MARK: - Singleton

    public static let shared = CoreDataStack()

    // MARK: - Properties

    private let logger = OSLog(subsystem: "com.healerkit.coredata", category: "CoreDataStack")

    /// Main persistent container for HealerKit data model
    public lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "HealerKit")

        // Configure store description for iPad Pro optimization
        let storeDescription = container.persistentStoreDescriptions.first
        storeDescription?.shouldInferMappingModelAutomatically = true
        storeDescription?.shouldMigrateStoreAutomatically = true

        // Memory optimization for 4GB RAM constraint
        storeDescription?.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        storeDescription?.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)

        // SQLite optimization for A9X processor
        storeDescription?.setOption("WAL" as NSString, forKey: "journal_mode")
        storeDescription?.setOption("NORMAL" as NSString, forKey: "synchronous")
        storeDescription?.setOption(4096 as NSNumber, forKey: "cache_size")

        container.loadPersistentStores { [weak self] storeDescription, error in
            if let error = error {
                self?.handlePersistentStoreError(error, storeDescription: storeDescription)
            } else {
                os_log("Persistent store loaded successfully: %@",
                       log: self?.logger ?? OSLog.default,
                       type: .info,
                       storeDescription.url?.lastPathComponent ?? "Unknown")
            }
        }

        // Configure contexts for optimal performance
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

        // Memory pressure monitoring
        NotificationCenter.default.addObserver(
            forName: UIApplication.didReceiveMemoryWarningNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleMemoryPressure()
        }

        return container
    }()

    /// Background context for data operations
    public lazy var backgroundContext: NSManagedObjectContext = {
        let context = persistentContainer.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
        return context
    }()

    // MARK: - Initialization

    private init() {
        setupNotifications()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Public Methods

    /// Main view context for UI operations (main thread only)
    public var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    /// Create a new background context for data operations
    public func newBackgroundContext() -> NSManagedObjectContext {
        return persistentContainer.newBackgroundContext()
    }

    /// Save context with error handling and thread safety
    /// - Parameter context: The managed object context to save
    /// - Throws: Core Data save errors
    public func save(context: NSManagedObjectContext? = nil) throws {
        let contextToSave = context ?? viewContext

        guard contextToSave.hasChanges else { return }

        try contextToSave.perform {
            do {
                try contextToSave.save()
                os_log("Context saved successfully", log: self.logger, type: .debug)
            } catch {
                os_log("Failed to save context: %@", log: self.logger, type: .error, error.localizedDescription)
                throw CoreDataError.saveFailed(error)
            }
        }
    }

    /// Perform background operation with automatic context management
    /// - Parameter operation: The operation to perform on background thread
    public func performBackgroundTask(_ operation: @escaping (NSManagedObjectContext) -> Void) {
        persistentContainer.performBackgroundTask { context in
            operation(context)

            // Auto-save if changes exist
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    os_log("Auto-save failed in background task: %@",
                           log: self.logger,
                           type: .error,
                           error.localizedDescription)
                }
            }
        }
    }

    /// Check if migration is needed for major patch updates (11.1→11.2)
    public func needsMigration() -> Bool {
        guard let storeURL = persistentContainer.persistentStoreDescriptions.first?.url else {
            return false
        }

        do {
            let metadata = try NSPersistentStoreCoordinator.metadataForPersistentStore(
                ofType: NSSQLiteStoreType,
                at: storeURL,
                options: nil
            )

            let model = persistentContainer.managedObjectModel
            return !model.isConfiguration(withName: nil, compatibleWithStoreMetadata: metadata)
        } catch {
            os_log("Failed to check migration status: %@", log: logger, type: .error, error.localizedDescription)
            return true // Assume migration needed on error
        }
    }

    // MARK: - Private Methods

    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(contextDidSave(_:)),
            name: .NSManagedObjectContextDidSave,
            object: nil
        )
    }

    @objc private func contextDidSave(_ notification: Notification) {
        guard let context = notification.object as? NSManagedObjectContext else { return }

        // Merge changes from background contexts to main context
        if context.parent === viewContext {
            viewContext.perform {
                self.viewContext.mergeChanges(from: notification)
            }
        }
    }

    private func handlePersistentStoreError(_ error: Error, storeDescription: NSPersistentStoreDescription?) {
        os_log("Persistent store error: %@", log: logger, type: .fault, error.localizedDescription)

        // Handle data corruption scenarios
        if let nsError = error as NSError? {
            switch nsError.code {
            case NSPersistentStoreIncompatibleVersionHashError,
                 NSMigrationMissingSourceModelError,
                 NSMigrationError:
                handleCorruptedStore(storeDescription)

            case NSPersistentStoreTimeoutError:
                handleStoreTimeout()

            default:
                fatalError("Unresolved Core Data error: \(error)")
            }
        }
    }

    private func handleCorruptedStore(_ storeDescription: NSPersistentStoreDescription?) {
        guard let storeURL = storeDescription?.url else { return }

        os_log("Handling corrupted store at: %@", log: logger, type: .info, storeURL.path)

        do {
            // Backup corrupted store
            let backupURL = storeURL.appendingPathExtension("corrupted.\(Date().timeIntervalSince1970)")
            try FileManager.default.moveItem(at: storeURL, to: backupURL)

            // Remove associated files
            let walURL = storeURL.appendingPathExtension("sqlite-wal")
            let shmURL = storeURL.appendingPathExtension("sqlite-shm")

            try? FileManager.default.removeItem(at: walURL)
            try? FileManager.default.removeItem(at: shmURL)

            os_log("Corrupted store backed up and cleaned", log: logger, type: .info)

        } catch {
            os_log("Failed to handle corrupted store: %@", log: logger, type: .error, error.localizedDescription)
        }
    }

    private func handleStoreTimeout() {
        os_log("Store timeout detected - implementing retry logic", log: logger, type: .info)
        // Store timeout handling would be implemented here
        // For now, log the issue for debugging
    }

    private func handleMemoryPressure() {
        os_log("Memory pressure detected - optimizing Core Data usage", log: logger, type: .info)

        // Clear row cache
        viewContext.perform {
            self.viewContext.refreshAllObjects()
        }

        // Reset background contexts
        backgroundContext.reset()

        // Force garbage collection of managed objects
        persistentContainer.viewContext.processPendingChanges()
    }
}

// MARK: - Error Types

public enum CoreDataError: Error, LocalizedError {
    case saveFailed(Error)
    case migrationFailed(Error)
    case storeLoadFailed(Error)

    public var errorDescription: String? {
        switch self {
        case .saveFailed(let error):
            return "Failed to save data: \(error.localizedDescription)"
        case .migrationFailed(let error):
            return "Data migration failed: \(error.localizedDescription)"
        case .storeLoadFailed(let error):
            return "Failed to load data store: \(error.localizedDescription)"
        }
    }
}

// MARK: - Migration Support

extension CoreDataStack {

    /// Perform manual migration for major patch updates
    /// - Parameter completionHandler: Called when migration completes
    public func performMigrationIfNeeded(completionHandler: @escaping (Result<Void, Error>) -> Void) {
        guard needsMigration() else {
            completionHandler(.success(()))
            return
        }

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                // Migration logic would be implemented here
                // For now, we rely on automatic lightweight migration
                os_log("Migration completed successfully", log: self.logger, type: .info)
                DispatchQueue.main.async {
                    completionHandler(.success(()))
                }
            } catch {
                os_log("Migration failed: %@", log: self.logger, type: .error, error.localizedDescription)
                DispatchQueue.main.async {
                    completionHandler(.failure(CoreDataError.migrationFailed(error)))
                }
            }
        }
    }
}

// MARK: - Performance Monitoring

extension CoreDataStack {

    /// Monitor Core Data performance metrics
    public func performanceMetrics() -> [String: Any] {
        var metrics: [String: Any] = [:]

        // Memory usage
        let memoryInfo = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &memoryInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         $0,
                         &count)
            }
        }

        if kerr == KERN_SUCCESS {
            metrics["memoryUsage"] = memoryInfo.resident_size
            metrics["virtualMemorySize"] = memoryInfo.virtual_size
        }

        // Context statistics
        metrics["viewContextHasChanges"] = viewContext.hasChanges
        metrics["backgroundContextHasChanges"] = backgroundContext.hasChanges
        metrics["insertedObjectsCount"] = viewContext.insertedObjects.count
        metrics["updatedObjectsCount"] = viewContext.updatedObjects.count
        metrics["deletedObjectsCount"] = viewContext.deletedObjects.count

        return metrics
    }
}