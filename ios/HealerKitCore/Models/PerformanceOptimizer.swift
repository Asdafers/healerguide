//
//  PerformanceOptimizer.swift
//  HealerKitCore
//
//  Created by HealerKit on 2025-09-15.
//  Performance optimization utilities for first-generation iPad Pro
//

#if canImport(UIKit)
import Foundation
import UIKit

/// Performance monitoring and optimization for first-generation iPad Pro constraints
public class PerformanceOptimizer {

    // MARK: - Singleton

    public static let shared = PerformanceOptimizer()

    private init() {
        setupMemoryPressureHandling()
        setupPerformanceMonitoring()
    }

    // MARK: - Memory Management

    private var memoryWarningCallback: (() -> Void)?
    private var currentMemoryUsage: Int64 = 0
    private let maxMemoryThreshold = IPadProFirstGenSpec.maxMemoryUsage

    /// Register for memory pressure notifications
    private func setupMemoryPressureHandling() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleMemoryPressure),
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAppBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
    }

    @objc private func handleMemoryPressure() {
        memoryWarningCallback?()
        performEmergencyCleanup()
    }

    @objc private func handleAppBackground() {
        performBackgroundOptimization()
    }

    /// Set callback for memory warning events
    public func setMemoryWarningCallback(_ callback: @escaping () -> Void) {
        memoryWarningCallback = callback
    }

    /// Get current memory usage statistics
    public func getCurrentMemoryUsage() -> MemoryUsageStats {
        let info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4

        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         $0,
                         &count)
            }
        }

        let memoryUsage = kerr == KERN_SUCCESS ? Int64(info.resident_size) : 0
        currentMemoryUsage = memoryUsage

        let recommendedAction: CacheAction
        if memoryUsage > maxMemoryThreshold * 80 / 100 {
            recommendedAction = .fullClear
        } else if memoryUsage > maxMemoryThreshold * 60 / 100 {
            recommendedAction = .clearOldEntries
        } else {
            recommendedAction = .none
        }

        return MemoryUsageStats(
            totalCacheSize: memoryUsage,
            entityCount: 0, // Updated by specific caches
            lastCacheClean: Date(),
            recommendedAction: recommendedAction
        )
    }

    /// Check if memory usage is approaching limits
    public func isMemoryPressureHigh() -> Bool {
        return currentMemoryUsage > maxMemoryThreshold * 70 / 100
    }

    /// Perform emergency cleanup during memory pressure
    private func performEmergencyCleanup() {
        // Clear image caches
        URLCache.shared.removeAllCachedResponses()

        // Force garbage collection
        autoreleasepool {
            // Temporary objects will be released
        }
    }

    /// Perform background optimization
    private func performBackgroundOptimization() {
        // Reduce memory footprint when backgrounded
        URLCache.shared.memoryCapacity = 1024 * 1024 // 1MB
    }

    // MARK: - Performance Monitoring

    private var frameRateMonitor: CADisplayLink?
    private var frameCount = 0
    private var lastFrameTime = CFAbsoluteTimeGetCurrent()
    private var currentFrameRate: Double = 60.0

    private func setupPerformanceMonitoring() {
        startFrameRateMonitoring()
    }

    /// Start monitoring frame rate
    public func startFrameRateMonitoring() {
        frameRateMonitor = CADisplayLink(target: self, selector: #selector(frameUpdate))
        frameRateMonitor?.add(to: .main, forMode: .common)
    }

    /// Stop monitoring frame rate
    public func stopFrameRateMonitoring() {
        frameRateMonitor?.invalidate()
        frameRateMonitor = nil
    }

    @objc private func frameUpdate() {
        frameCount += 1

        let currentTime = CFAbsoluteTimeGetCurrent()
        let timeDelta = currentTime - lastFrameTime

        if timeDelta >= 1.0 {
            currentFrameRate = Double(frameCount) / timeDelta
            frameCount = 0
            lastFrameTime = currentTime

            // Alert if frame rate drops significantly
            if currentFrameRate < 50 {
                handleLowFrameRate()
            }
        }
    }

    /// Get current frame rate
    public func getCurrentFrameRate() -> Double {
        return currentFrameRate
    }

    /// Check if frame rate meets target
    public func isFrameRateAcceptable() -> Bool {
        return currentFrameRate >= Double(IPadProFirstGenSpec.targetFrameRate) * 0.85 // 85% of target
    }

    private func handleLowFrameRate() {
        // Could notify observers or trigger optimizations
        NotificationCenter.default.post(name: .performanceDegraded, object: currentFrameRate)
    }

    // MARK: - View Optimization

    /// Optimize view for first-generation iPad Pro
    public static func optimizeView(_ view: UIView) {
        // Enable hardware acceleration
        view.layer.shouldRasterize = true
        view.layer.rasterizationScale = UIScreen.main.scale
        view.layer.drawsAsynchronously = true

        // Optimize opaque views
        if view.backgroundColor != nil && view.backgroundColor != .clear {
            view.isOpaque = true
        }

        // Reduce overdraw
        view.clipsToBounds = true
    }

    /// Configure layer for optimal performance
    public static func optimizeLayer(_ layer: CALayer) {
        // Reduce compositing complexity
        layer.allowsGroupOpacity = false
        layer.allowsEdgeAntialiasing = false

        // Use efficient blending
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }

    // MARK: - Animation Optimization

    /// Get optimized animation duration for current performance
    public func getOptimizedAnimationDuration(base: TimeInterval) -> TimeInterval {
        let performanceFactor = min(currentFrameRate / 60.0, 1.0)
        return base * max(performanceFactor, 0.5) // Don't go below half speed
    }

    /// Create performance-optimized animation
    public static func createOptimizedAnimation(
        duration: TimeInterval,
        animations: @escaping () -> Void,
        completion: ((Bool) -> Void)? = nil
    ) {
        // Use spring animation with performance-tuned parameters
        UIView.animate(
            withDuration: duration,
            delay: 0,
            usingSpringWithDamping: 0.8, // Balanced responsiveness
            initialSpringVelocity: 0,
            options: [.allowUserInteraction, .curveEaseOut],
            animations: animations,
            completion: completion
        )
    }

    // MARK: - Image Optimization

    /// Optimize image for iPad Pro display
    public static func optimizeImage(_ image: UIImage, targetSize: CGSize) -> UIImage? {
        let scale = min(UIScreen.main.scale, 2.0) // Don't exceed 2x for performance
        let pixelSize = CGSize(
            width: targetSize.width * scale,
            height: targetSize.height * scale
        )

        let renderer = UIGraphicsImageRenderer(
            size: pixelSize,
            format: UIGraphicsImageRendererFormat.preferred()
        )

        return renderer.image { context in
            context.cgContext.interpolationQuality = .medium
            context.cgContext.setShouldAntialias(true)
            context.cgContext.setAllowsAntialiasing(true)

            image.draw(in: CGRect(origin: .zero, size: pixelSize))
        }
    }

    // MARK: - Batch Processing

    /// Process items in performance-conscious batches
    public static func processBatch<T, R>(
        items: [T],
        batchSize: Int = 10,
        processor: (T) -> R
    ) -> [R] {
        var results: [R] = []
        results.reserveCapacity(items.count)

        for chunk in items.chunked(into: batchSize) {
            autoreleasepool {
                let chunkResults = chunk.map(processor)
                results.append(contentsOf: chunkResults)
            }
        }

        return results
    }

    deinit {
        stopFrameRateMonitoring()
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - LRU Cache Implementation

/// Memory-efficient LRU cache for first-generation iPad Pro
public class LRUCache<Key: Hashable, Value> {
    private struct CacheItem {
        let value: Value
        var lastAccessed: Date
    }

    private let maxCapacity: Int
    private let maxMemoryBytes: Int64
    private var cache: [Key: CacheItem] = [:]
    private let accessQueue = DispatchQueue(label: "healerkit.lru-cache", attributes: .concurrent)

    public init(maxItems: Int = 50, maxMemoryMB: Int = 32) {
        self.maxCapacity = maxItems
        self.maxMemoryBytes = Int64(maxMemoryMB * 1024 * 1024)
    }

    public func getValue(for key: Key) -> Value? {
        return accessQueue.sync {
            guard var item = cache[key] else { return nil }
            item.lastAccessed = Date()
            cache[key] = item
            return item.value
        }
    }

    public func setValue(_ value: Value, for key: Key) {
        accessQueue.async(flags: .barrier) {
            // Check memory pressure before adding
            if PerformanceOptimizer.shared.isMemoryPressureHigh() {
                self.evictLeastRecentlyUsed()
            }

            self.cache[key] = CacheItem(value: value, lastAccessed: Date())

            // Evict if over capacity
            if self.cache.count > self.maxCapacity {
                self.evictLeastRecentlyUsed()
            }
        }
    }

    public func removeValue(for key: Key) {
        accessQueue.async(flags: .barrier) {
            self.cache.removeValue(forKey: key)
        }
    }

    public func removeAll() {
        accessQueue.async(flags: .barrier) {
            self.cache.removeAll()
        }
    }

    private func evictLeastRecentlyUsed() {
        guard let oldestKey = cache.min(by: { $0.value.lastAccessed < $1.value.lastAccessed })?.key else { return }
        cache.removeValue(forKey: oldestKey)
    }
}

// MARK: - Extensions

extension Array {
    /// Split array into chunks of specified size
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}

// MARK: - Notifications

extension Notification.Name {
    public static let performanceDegraded = Notification.Name("healerkit.performance.degraded")
    public static let memoryPressureCleanup = Notification.Name("healerkit.memory.cleanup")
}
#endif