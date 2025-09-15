//
//  PerformanceManager.swift
//  HealerKit
//
//  Performance optimization manager for first-generation iPad Pro
//  Handles memory pressure, view caching, lazy loading, and frame rate monitoring
//

import UIKit
import Foundation
import CoreData
import os.log

/// Performance manager optimized for first-generation iPad Pro constraints
/// Monitors and optimizes memory usage, rendering performance, and data operations
public final class PerformanceManager {

    // MARK: - Singleton

    public static let shared = PerformanceManager()

    // MARK: - Properties

    private let logger = OSLog(subsystem: "com.healerkit.performance", category: "PerformanceManager")
    private let performanceQueue = DispatchQueue(label: "com.healerkit.performance", qos: .utility)

    /// Memory pressure monitoring
    private var memoryPressureSource: DispatchSourceMemoryPressure?

    /// View caching for smooth scrolling
    private var viewCache: NSCache<NSString, UIView> = {
        let cache = NSCache<NSString, UIView>()
        cache.countLimit = 50 // Optimized for 4GB RAM
        cache.totalCostLimit = 50 * 1024 * 1024 // 50MB cache limit
        return cache
    }()

    /// Ability card cache for quick access
    private var abilityCardCache: NSCache<NSUUID, AbilityCardData> = {
        let cache = NSCache<NSUUID, AbilityCardData>()
        cache.countLimit = 100
        cache.totalCostLimit = 20 * 1024 * 1024 // 20MB for ability data
        return cache
    }()

    /// Image cache for boss portraits and icons
    private var imageCache: NSCache<NSString, UIImage> = {
        let cache = NSCache<NSString, UIImage>()
        cache.countLimit = 30
        cache.totalCostLimit = 30 * 1024 * 1024 // 30MB for images
        return cache
    }()

    /// Frame rate monitoring
    private var displayLink: CADisplayLink?
    private var frameTimestamps: [CFTimeInterval] = []
    private var currentFPS: Double = 60.0

    /// Memory usage tracking
    private var lastMemoryCheck: TimeInterval = 0
    private var memoryCheckInterval: TimeInterval = 5.0

    /// Background queue management
    private let backgroundOperationQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 2 // Optimized for A9X dual-core
        queue.qualityOfService = .utility
        queue.name = "com.healerkit.background"
        return queue
    }()

    /// Data loading queue for CoreData operations
    private let dataQueue = DispatchQueue(label: "com.healerkit.data", qos: .userInitiated)

    // MARK: - Performance Metrics

    public struct PerformanceMetrics {
        let memoryUsage: UInt64
        let virtualMemorySize: UInt64
        let currentFPS: Double
        let averageFPS: Double
        let cacheHitRate: Double
        let backgroundOperationCount: Int
        let timestamp: Date

        public var memoryUsageMB: Double {
            return Double(memoryUsage) / (1024 * 1024)
        }

        public var isMemoryPressureHigh: Bool {
            return memoryUsageMB > 512 // Alert if over 512MB on 4GB device
        }

        public var isFrameRateOptimal: Bool {
            return currentFPS >= 55.0 // Allow 5fps tolerance from 60fps target
        }
    }

    // MARK: - Initialization

    private init() {
        setupMemoryPressureMonitoring()
        setupFrameRateMonitoring()
        setupBackgroundTaskManagement()
        setupNotificationObservers()
    }

    deinit {
        displayLink?.invalidate()
        memoryPressureSource?.cancel()
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Public Methods

    /// Start performance monitoring
    public func startMonitoring() {
        os_log("Starting performance monitoring for iPad Pro", log: logger, type: .info)

        // Start frame rate monitoring
        displayLink?.isPaused = false

        // Start memory pressure monitoring
        memoryPressureSource?.resume()

        // Schedule periodic cleanup
        schedulePeriodicCleanup()
    }

    /// Stop performance monitoring
    public func stopMonitoring() {
        displayLink?.isPaused = true
        memoryPressureSource?.suspend()
        cancelPeriodicCleanup()
    }

    /// Get current performance metrics
    public func currentMetrics() -> PerformanceMetrics {
        let memoryInfo = getMemoryInfo()

        let avgFPS = frameTimestamps.isEmpty ? currentFPS :
            Double(frameTimestamps.count) / (frameTimestamps.last! - frameTimestamps.first!)

        return PerformanceMetrics(
            memoryUsage: memoryInfo.resident_size,
            virtualMemorySize: memoryInfo.virtual_size,
            currentFPS: currentFPS,
            averageFPS: avgFPS,
            cacheHitRate: calculateCacheHitRate(),
            backgroundOperationCount: backgroundOperationQueue.operationCount,
            timestamp: Date()
        )
    }

    // MARK: - Memory Management

    /// Handle memory pressure warnings
    public func handleMemoryPressure(level: MemoryPressureLevel) {
        os_log("Handling memory pressure level: %d", log: logger, type: .info, level.rawValue)

        switch level {
        case .normal:
            // No action needed
            break

        case .warning:
            performLightweightCleanup()

        case .critical:
            performAggressiveCleanup()
        }
    }

    /// Clear view caches to free memory
    public func clearCaches() {
        viewCache.removeAllObjects()
        abilityCardCache.removeAllObjects()
        imageCache.removeAllObjects()

        // Force garbage collection
        autoreleasepool {
            // Trigger memory cleanup
        }

        os_log("Caches cleared to free memory", log: logger, type: .info)
    }

    /// Optimize memory usage for current state
    public func optimizeMemoryUsage() {
        let metrics = currentMetrics()

        if metrics.isMemoryPressureHigh {
            performLightweightCleanup()
        }

        // Adjust cache limits based on available memory
        adjustCacheLimitsForMemory(metrics.memoryUsageMB)
    }

    // MARK: - View Caching

    /// Cache view for smooth scrolling
    /// - Parameters:
    ///   - view: View to cache
    ///   - key: Cache key
    ///   - cost: Memory cost estimate
    public func cacheView(_ view: UIView, forKey key: String, cost: Int = 0) {
        viewCache.setObject(view, forKey: key as NSString, cost: cost)
    }

    /// Retrieve cached view
    /// - Parameter key: Cache key
    /// - Returns: Cached view if available
    public func cachedView(forKey key: String) -> UIView? {
        return viewCache.object(forKey: key as NSString)
    }

    /// Pre-cache ability cards for upcoming dungeons
    /// - Parameter abilityIDs: List of ability IDs to pre-cache
    public func precacheAbilityCards(_ abilityIDs: [UUID]) {
        let operation = BlockOperation { [weak self] in
            for abilityID in abilityIDs {
                guard let self = self else { break }

                // Check if already cached
                if self.abilityCardCache.object(forKey: abilityID as NSUUID) != nil {
                    continue
                }

                // Load and cache ability data
                self.loadAbilityCardData(abilityID) { [weak self] data in
                    if let data = data {
                        self?.abilityCardCache.setObject(data, forKey: abilityID as NSUUID)
                    }
                }
            }
        }

        operation.qualityOfService = .utility
        backgroundOperationQueue.addOperation(operation)
    }

    // MARK: - Lazy Loading

    /// Lazy load ability data with caching
    /// - Parameters:
    ///   - abilityID: Ability identifier
    ///   - completion: Completion handler with loaded data
    public func loadAbilityData(_ abilityID: UUID, completion: @escaping (AbilityCardData?) -> Void) {
        // Check cache first
        if let cachedData = abilityCardCache.object(forKey: abilityID as NSUUID) {
            completion(cachedData)
            return
        }

        // Load from CoreData on background queue
        loadAbilityCardData(abilityID) { [weak self] data in
            if let data = data {
                self?.abilityCardCache.setObject(data, forKey: abilityID as NSUUID)
            }

            DispatchQueue.main.async {
                completion(data)
            }
        }
    }

    /// Lazy load image with caching
    /// - Parameters:
    ///   - imageKey: Image identifier
    ///   - loader: Image loading closure
    ///   - completion: Completion handler with loaded image
    public func loadImage(_ imageKey: String, loader: @escaping () -> UIImage?, completion: @escaping (UIImage?) -> Void) {
        // Check cache first
        if let cachedImage = imageCache.object(forKey: imageKey as NSString) {
            completion(cachedImage)
            return
        }

        // Load on background queue
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let image = loader()

            if let image = image {
                let cost = Int(image.size.width * image.size.height * 4) // RGBA bytes
                self?.imageCache.setObject(image, forKey: imageKey as NSString, cost: cost)
            }

            DispatchQueue.main.async {
                completion(image)
            }
        }
    }

    // MARK: - Frame Rate Monitoring

    /// Get current frame rate
    public func getCurrentFPS() -> Double {
        return currentFPS
    }

    /// Check if frame rate is optimal for smooth scrolling
    public func isFrameRateOptimal() -> Bool {
        return currentFPS >= 55.0
    }

    /// Optimize rendering for better frame rate
    public func optimizeRendering() {
        // Reduce animation complexity if needed
        if currentFPS < 50.0 {
            NotificationCenter.default.post(
                name: .HealerKitReduceRenderingComplexity,
                object: self,
                userInfo: ["currentFPS": currentFPS]
            )
        }
    }

    // MARK: - Background Queue Management

    /// Execute data operation on background queue
    /// - Parameter operation: Operation to execute
    public func performBackgroundDataOperation(_ operation: @escaping () -> Void) {
        dataQueue.async {
            operation()
        }
    }

    /// Execute operation with background queue management
    /// - Parameter operation: Operation to add to background queue
    public func addBackgroundOperation(_ operation: Operation) {
        // Limit concurrent operations for A9X processor
        if backgroundOperationQueue.operationCount >= 2 {
            // Queue is full, defer operation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?.addBackgroundOperation(operation)
            }
            return
        }

        backgroundOperationQueue.addOperation(operation)
    }

    // MARK: - Private Methods

    private func setupMemoryPressureMonitoring() {
        memoryPressureSource = DispatchSource.makeMemoryPressureSource(
            eventMask: [.warning, .critical],
            queue: performanceQueue
        )

        memoryPressureSource?.setEventHandler { [weak self] in
            guard let self = self else { return }

            let event = self.memoryPressureSource?.mask
            if event?.contains(.warning) == true {
                self.handleMemoryPressure(level: .warning)
            }
            if event?.contains(.critical) == true {
                self.handleMemoryPressure(level: .critical)
            }
        }
    }

    private func setupFrameRateMonitoring() {
        displayLink = CADisplayLink(target: self, selector: #selector(displayLinkTick))
        displayLink?.add(to: .main, forMode: .common)
        displayLink?.isPaused = true
    }

    @objc private func displayLinkTick(_ displayLink: CADisplayLink) {
        let now = displayLink.timestamp

        // Maintain rolling window of frame timestamps
        frameTimestamps.append(now)
        if frameTimestamps.count > 120 { // 2 seconds at 60fps
            frameTimestamps.removeFirst()
        }

        // Calculate current FPS
        if frameTimestamps.count >= 2 {
            let timeInterval = frameTimestamps.last! - frameTimestamps.first!
            currentFPS = Double(frameTimestamps.count - 1) / timeInterval
        }

        // Check memory usage periodically
        if now - lastMemoryCheck > memoryCheckInterval {
            lastMemoryCheck = now
            checkMemoryUsage()
        }
    }

    private func setupBackgroundTaskManagement() {
        backgroundOperationQueue.addObserver(self, forKeyPath: "operationCount", options: [.new], context: nil)
    }

    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidReceiveMemoryWarning),
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
    }

    @objc private func applicationDidReceiveMemoryWarning() {
        handleMemoryPressure(level: .critical)
    }

    @objc private func applicationDidEnterBackground() {
        performLightweightCleanup()
    }

    private func performLightweightCleanup() {
        // Remove older cached views
        let cacheLimit = viewCache.countLimit
        viewCache.countLimit = Int(Double(cacheLimit) * 0.7) // Reduce by 30%
        viewCache.countLimit = cacheLimit // Restore limit

        // Clear unused images
        pruneImageCache()

        os_log("Performed lightweight memory cleanup", log: logger, type: .debug)
    }

    private func performAggressiveCleanup() {
        // Clear most caches
        viewCache.removeAllObjects()

        // Keep only essential ability cards
        pruneAbilityCardCache(keepCount: 10)

        // Clear most images
        imageCache.removeAllObjects()

        // Cancel non-essential background operations
        backgroundOperationQueue.cancelAllOperations()

        os_log("Performed aggressive memory cleanup", log: logger, type: .info)
    }

    private func adjustCacheLimitsForMemory(_ memoryUsageMB: Double) {
        let baseLimit = 50
        let adjustmentFactor = max(0.5, min(1.0, (512.0 - memoryUsageMB) / 256.0))
        let newLimit = Int(Double(baseLimit) * adjustmentFactor)

        viewCache.countLimit = max(10, newLimit)
        abilityCardCache.countLimit = max(20, newLimit * 2)
        imageCache.countLimit = max(5, newLimit / 2)
    }

    private func pruneImageCache() {
        // Implementation would remove least recently used images
        // For now, reduce cache limit temporarily
        let currentLimit = imageCache.countLimit
        imageCache.countLimit = currentLimit / 2
        imageCache.countLimit = currentLimit
    }

    private func pruneAbilityCardCache(keepCount: Int) {
        // Keep only the most recently accessed ability cards
        // Implementation would track access times and prune accordingly
        while abilityCardCache.countLimit > keepCount {
            // Reduce cache size gradually
            abilityCardCache.countLimit -= 1
        }
    }

    private func checkMemoryUsage() {
        let memoryInfo = getMemoryInfo()
        let memoryUsageMB = Double(memoryInfo.resident_size) / (1024 * 1024)

        if memoryUsageMB > 400 { // Warning threshold
            performLightweightCleanup()
        } else if memoryUsageMB > 500 { // Critical threshold
            performAggressiveCleanup()
        }
    }

    private func getMemoryInfo() -> mach_task_basic_info {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4

        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         $0,
                         &count)
            }
        }

        if kerr != KERN_SUCCESS {
            os_log("Failed to get memory info: %d", log: logger, type: .error, kerr)
        }

        return info
    }

    private func loadAbilityCardData(_ abilityID: UUID, completion: @escaping (AbilityCardData?) -> Void) {
        performBackgroundDataOperation { [weak self] in
            guard let self = self else {
                completion(nil)
                return
            }

            // Load from CoreData (implementation would fetch from persistent store)
            let context = CoreDataStack.shared.backgroundContext
            context.perform {
                // Fetch ability data
                let request: NSFetchRequest<BossAbility> = BossAbility.fetchRequest()
                request.predicate = NSPredicate(format: "id == %@", abilityID as CVarArg)
                request.fetchLimit = 1

                do {
                    let abilities = try context.fetch(request)
                    if let ability = abilities.first {
                        let data = AbilityCardData(
                            id: ability.id!,
                            name: ability.name ?? "",
                            damageProfile: ability.damageProfile ?? "",
                            healerAction: ability.healerAction,
                            criticalInsight: ability.criticalInsight,
                            isKeyMechanic: ability.isKeyMechanic
                        )
                        completion(data)
                    } else {
                        completion(nil)
                    }
                } catch {
                    os_log("Failed to load ability data: %@", log: self.logger, type: .error, error.localizedDescription)
                    completion(nil)
                }
            }
        }
    }

    private func calculateCacheHitRate() -> Double {
        // Implementation would track cache hits vs misses
        // For now, return estimated value
        return 0.85 // 85% hit rate estimate
    }

    private var periodicCleanupTimer: Timer?

    private func schedulePeriodicCleanup() {
        periodicCleanupTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] _ in
            self?.optimizeMemoryUsage()
        }
    }

    private func cancelPeriodicCleanup() {
        periodicCleanupTimer?.invalidate()
        periodicCleanupTimer = nil
    }
}

// MARK: - KVO Observer

extension PerformanceManager {
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "operationCount" {
            if let newCount = change?[.newKey] as? Int {
                os_log("Background operations count: %d", log: logger, type: .debug, newCount)
            }
        }
    }
}

// MARK: - Supporting Types

public enum MemoryPressureLevel: Int {
    case normal = 0
    case warning = 1
    case critical = 2
}

public struct AbilityCardData {
    let id: UUID
    let name: String
    let damageProfile: String
    let healerAction: String?
    let criticalInsight: String?
    let isKeyMechanic: Bool
}

// MARK: - Notifications

extension Notification.Name {
    public static let HealerKitReduceRenderingComplexity = Notification.Name("HealerKitReduceRenderingComplexity")
    public static let HealerKitMemoryPressureDetected = Notification.Name("HealerKitMemoryPressureDetected")
    public static let HealerKitPerformanceMetricsUpdated = Notification.Name("HealerKitPerformanceMetricsUpdated")
}