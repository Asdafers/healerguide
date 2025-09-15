# Performance Optimization Guide

This guide provides comprehensive strategies for optimizing HealerKit performance specifically for first-generation iPad Pro hardware constraints while maintaining 60fps rendering and responsive user experience during high-pressure encounters.

## Hardware Profile: First-Generation iPad Pro

### Performance Baseline
- **CPU**: A9X dual-core @ 2.26 GHz (2015 technology)
- **GPU**: PowerVR Series 7XT 12-cluster
- **RAM**: 4GB total system memory
- **Storage**: Flash storage with good sequential read/write
- **Display**: 2732×2048 @ 264 PPI (high pixel density)

### Performance Targets
- **Frame Rate**: Consistent 60fps during all interactions
- **Memory Usage**: Application < 512MB peak usage
- **Launch Time**: Cold start < 3 seconds to usable interface
- **Data Access**: Dungeon/ability queries < 100ms
- **Touch Response**: < 16ms from tap to visual feedback

## Memory Optimization Strategies

### 1. Intelligent Caching System

#### LRU Cache Implementation
```swift
class LRUCache<Key: Hashable, Value> {
    private struct CacheItem {
        let value: Value
        var lastAccessed: Date
    }

    private let maxCapacity: Int
    private let maxMemoryBytes: Int64
    private var cache: [Key: CacheItem] = [:]

    init(maxItems: Int = 50, maxMemoryMB: Int = 32) {
        self.maxCapacity = maxItems
        self.maxMemoryBytes = Int64(maxMemoryMB * 1024 * 1024)
    }

    func setValue(_ value: Value, for key: Key) {
        // Check memory pressure before adding
        if getCurrentMemoryUsage() > maxMemoryBytes * 80 / 100 {
            evictLeastRecentlyUsed()
        }

        cache[key] = CacheItem(value: value, lastAccessed: Date())

        // Evict if over capacity
        if cache.count > maxCapacity {
            evictLeastRecentlyUsed()
        }
    }

    private func evictLeastRecentlyUsed() {
        guard let oldestKey = cache.min(by: { $0.value.lastAccessed < $1.value.lastAccessed })?.key else { return }
        cache.removeValue(forKey: oldestKey)
    }
}
```

#### Memory Pool for View Recycling
```swift
class AbilityCardPool {
    private var availableCards: [AbilityCardView] = []
    private var inUseCards: Set<AbilityCardView> = []
    private let maxPoolSize: Int = 20

    func dequeueReusableCard() -> AbilityCardView {
        if let reusableCard = availableCards.popLast() {
            inUseCards.insert(reusableCard)
            return reusableCard
        }

        let newCard = AbilityCardView()
        inUseCards.insert(newCard)
        return newCard
    }

    func returnCard(_ card: AbilityCardView) {
        inUseCards.remove(card)

        // Clean the card for reuse
        card.prepareForReuse()

        // Return to pool if under capacity
        if availableCards.count < maxPoolSize {
            availableCards.append(card)
        }
        // Otherwise, let it deallocate
    }

    func clearPool() {
        availableCards.removeAll()
        // Force cleanup of in-use cards during memory pressure
        inUseCards.forEach { $0.removeFromSuperview() }
        inUseCards.removeAll()
    }
}
```

### 2. Memory Pressure Handling

#### System Memory Monitoring
```swift
class MemoryPressureManager {
    static let shared = MemoryPressureManager()

    private init() {
        // Monitor system memory warnings
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleMemoryWarning),
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )

        // Monitor app lifecycle for cleanup opportunities
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAppBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
    }

    @objc private func handleMemoryWarning() {
        // Immediate cleanup of non-essential resources
        ImageCache.shared.clearNonEssentialImages()
        AbilityCardPool.shared.clearPool()
        DungeonDataCache.shared.clearOldEntries()

        // Notify components to clean up
        NotificationCenter.default.post(name: .memoryPressureCleanup, object: nil)
    }

    @objc private func handleAppBackground() {
        // Proactive cleanup when app goes background
        performBackgroundCleanup()
    }

    private func performBackgroundCleanup() {
        // Clear view caches that can be regenerated
        ViewControllerCache.shared.clearAll()

        // Compress image caches
        ImageCache.shared.compressCache()

        // Clear temporary data
        TemporaryDataManager.shared.clearAll()
    }
}
```

### 3. Efficient Data Structures

#### Optimized Core Data Configuration
```swift
class CoreDataPerformanceOptimizer {
    static func configurePersistentContainer() -> NSPersistentContainer {
        let container = NSPersistentContainer(name: "HealerKit")

        // Configure for first-gen iPad Pro performance
        let storeDescription = container.persistentStoreDescriptions.first!
        storeDescription.shouldInferMappingModelAutomatically = false
        storeDescription.shouldMigrateStoreAutomatically = false

        // Optimize SQLite configuration
        storeDescription.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        storeDescription.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)

        // WAL mode for better concurrent performance
        storeDescription.setOption("WAL" as NSString, forKey: NSSQLitePragmasOption)

        return container
    }

    static func optimizeContext(_ context: NSManagedObjectContext) {
        // Reduce memory footprint
        context.undoManager = nil
        context.shouldDeleteInaccessibleFaults = true

        // Optimize fetch performance
        context.stalenessInterval = 0  // Always fetch fresh data
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
}
```

## Rendering Performance Optimization

### 1. View Layer Optimization

#### Efficient Layer Configuration
```swift
extension UIView {
    func optimizeForFirstGenIPadPro() {
        // Reduce layer complexity
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        layer.drawsAsynchronously = true

        // Optimize opaque views
        if backgroundColor != nil && backgroundColor != .clear {
            isOpaque = true
        }

        // Reduce overdraw with clipping
        clipsToBounds = true
    }
}

class OptimizedAbilityCardView: UIView {
    override func awakeFromNib() {
        super.awakeFromNib()
        setupPerformanceOptimizations()
    }

    private func setupPerformanceOptimizations() {
        // Pre-calculate expensive operations
        layer.shadowPath = UIBezierPath(
            roundedRect: bounds,
            cornerRadius: layer.cornerRadius
        ).cgPath

        // Use efficient blending modes
        layer.compositingFilter = "multiplyBlendMode"

        // Optimize for A9X GPU
        layer.allowsEdgeAntialiasing = false  // Reduce GPU load
        layer.allowsGroupOpacity = false      // Reduce compositing complexity
    }
}
```

#### Texture and Image Optimization
```swift
class ImagePerformanceOptimizer {
    static func optimizeImageForDisplay(_ image: UIImage, targetSize: CGSize) -> UIImage? {
        // Calculate optimal size for first-gen iPad Pro
        let scale = min(UIScreen.main.scale, 2.0)  // Don't exceed 2x for performance
        let pixelSize = CGSize(
            width: targetSize.width * scale,
            height: targetSize.height * scale
        )

        // Use efficient rendering context
        let renderer = UIGraphicsImageRenderer(
            size: pixelSize,
            format: UIGraphicsImageRendererFormat.preferred()
        )

        return renderer.image { context in
            // Optimize rendering quality vs performance
            context.cgContext.interpolationQuality = .medium
            context.cgContext.setShouldAntialias(true)
            context.cgContext.setAllowsAntialiasing(true)

            image.draw(in: CGRect(origin: .zero, size: pixelSize))
        }
    }

    static func preloadCriticalImages() {
        // Preload commonly used images during app launch
        let criticalImages = [
            "critical-damage-icon",
            "high-damage-icon",
            "moderate-damage-icon",
            "mechanic-icon"
        ]

        criticalImages.forEach { imageName in
            if let image = UIImage(named: imageName) {
                let optimized = optimizeImageForDisplay(image, targetSize: CGSize(width: 24, height: 24))
                ImageCache.shared.setImage(optimized, forKey: imageName)
            }
        }
    }
}
```

### 2. Animation Performance

#### Hardware-Accelerated Animations
```swift
class HealerAnimationManager {
    // Optimized animation parameters for A9X GPU
    static let fastDuration: TimeInterval = 0.15
    static let standardDuration: TimeInterval = 0.25
    static let slowDuration: TimeInterval = 0.35

    static func animateAbilitySelection(_ view: UIView, completion: @escaping () -> Void) {
        // Use transform animations (GPU accelerated)
        UIView.animate(
            withDuration: fastDuration,
            delay: 0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0,
            options: [.allowUserInteraction, .curveEaseOut],
            animations: {
                view.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
            }
        ) { _ in
            UIView.animate(withDuration: fastDuration) {
                view.transform = .identity
            } completion: { _ in
                completion()
            }
        }
    }

    static func animateCriticalAbilityAlert(_ view: UIView) {
        // Efficient pulse animation for critical alerts
        let pulseAnimation = CABasicAnimation(keyPath: "opacity")
        pulseAnimation.fromValue = 1.0
        pulseAnimation.toValue = 0.5
        pulseAnimation.duration = 0.5
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = 3

        view.layer.add(pulseAnimation, forKey: "criticalPulse")
    }
}
```

### 3. Collection View Performance

#### Optimized Collection View Configuration
```swift
class PerformantAbilityCollectionView: UICollectionView {
    override func awakeFromNib() {
        super.awakeFromNib()
        optimizeForFirstGenIPadPro()
    }

    private func optimizeForFirstGenIPadPro() {
        // Enable prefetching for smooth scrolling
        isPrefetchingEnabled = true
        prefetchDataSource = self

        // Optimize memory usage
        remembersLastFocusedIndexPath = false

        // Configure for 60fps scrolling
        decelerationRate = .fast
        showsVerticalScrollIndicator = false  // Reduce draw calls
        showsHorizontalScrollIndicator = false
    }

    // Efficient cell dequeuing
    func dequeueOptimizedAbilityCell(for indexPath: IndexPath) -> AbilityCollectionViewCell {
        let cell = dequeueReusableCell(
            withReuseIdentifier: AbilityCollectionViewCell.identifier,
            for: indexPath
        ) as! AbilityCollectionViewCell

        // Configure for performance
        cell.optimizeForScrolling()
        return cell
    }
}

extension PerformantAbilityCollectionView: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        // Preload ability data for smooth scrolling
        indexPaths.forEach { indexPath in
            AbilityDataPreloader.shared.preload(at: indexPath.row)
        }
    }

    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        // Cancel unnecessary preloading to save memory
        indexPaths.forEach { indexPath in
            AbilityDataPreloader.shared.cancelPreload(at: indexPath.row)
        }
    }
}
```

## Data Access Performance

### 1. Core Data Optimization

#### Efficient Fetch Requests
```swift
class OptimizedDungeonProvider: DungeonDataProviding {
    private let context: NSManagedObjectContext

    func fetchDungeonsForActiveSeason() async throws -> [DungeonEntity] {
        return try await withCheckedThrowingContinuation { continuation in
            context.perform {
                let request: NSFetchRequest<DungeonManagedObject> = DungeonManagedObject.fetchRequest()

                // Optimize fetch for first-gen iPad Pro
                request.fetchBatchSize = 20  // Reasonable batch size for 4GB RAM
                request.returnsObjectsAsFaults = false  // Prefetch data
                request.relationshipKeyPathsForPrefetching = ["bossEncounters"]

                // Use efficient predicate
                request.predicate = NSPredicate(format: "season.isActive == YES")

                // Sort efficiently (use indexed fields)
                request.sortDescriptors = [
                    NSSortDescriptor(key: "displayOrder", ascending: true)
                ]

                do {
                    let results = try self.context.fetch(request)
                    let entities = results.map { $0.toEntity() }
                    continuation.resume(returning: entities)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    func fetchAbilitiesOptimized(for bossId: UUID) async throws -> [AbilityEntity] {
        return try await withCheckedThrowingContinuation { continuation in
            context.perform {
                let request: NSFetchRequest<AbilityManagedObject> = AbilityManagedObject.fetchRequest()

                // Efficient batch loading
                request.fetchBatchSize = 50
                request.returnsObjectsAsFaults = false

                // Indexed predicate for performance
                request.predicate = NSPredicate(format: "bossEncounter.id == %@", bossId as CVarArg)

                // Sort by priority for healer relevance
                request.sortDescriptors = [
                    NSSortDescriptor(key: "damageProfile", ascending: false),  // Critical first
                    NSSortDescriptor(key: "displayOrder", ascending: true)
                ]

                do {
                    let results = try self.context.fetch(request)
                    let entities = results.map { $0.toEntity() }
                    continuation.resume(returning: entities)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
```

### 2. Background Processing

#### Async Data Loading
```swift
class BackgroundDataProcessor {
    private let backgroundQueue = DispatchQueue(
        label: "healerkit.background-processing",
        qos: .utility,
        attributes: .concurrent
    )

    func preprocessAbilityData(_ abilities: [AbilityEntity]) async -> [ProcessedAbilityData] {
        return await withTaskGroup(of: ProcessedAbilityData?.self, returning: [ProcessedAbilityData].self) { group in
            for ability in abilities {
                group.addTask { [weak self] in
                    return await self?.processAbility(ability)
                }
            }

            var results: [ProcessedAbilityData] = []
            for await result in group {
                if let processedData = result {
                    results.append(processedData)
                }
            }
            return results
        }
    }

    private func processAbility(_ ability: AbilityEntity) async -> ProcessedAbilityData? {
        return await withCheckedContinuation { continuation in
            backgroundQueue.async {
                // Perform expensive processing off main thread
                let classification = AbilityClassifier.classify(ability)
                let colorScheme = ColorSchemeGenerator.generate(for: ability.damageProfile)
                let displayHints = UIDisplayHintGenerator.generate(for: classification)

                let processedData = ProcessedAbilityData(
                    ability: ability,
                    classification: classification,
                    colorScheme: colorScheme,
                    displayHints: displayHints
                )

                continuation.resume(returning: processedData)
            }
        }
    }
}
```

## Battery and Thermal Optimization

### 1. Power-Efficient Rendering

#### Adaptive Refresh Rate Management
```swift
class PowerEfficiencyManager {
    private var displayLink: CADisplayLink?
    private var targetFrameRate: Int = 60

    func startOptimizedRendering() {
        displayLink = CADisplayLink(target: self, selector: #selector(renderFrame))

        // Adapt frame rate based on battery level and thermal state
        updateTargetFrameRate()

        displayLink?.add(to: .main, forMode: .common)
    }

    private func updateTargetFrameRate() {
        let batteryLevel = UIDevice.current.batteryLevel
        let thermalState = ProcessInfo.processInfo.thermalState

        switch thermalState {
        case .nominal:
            targetFrameRate = 60
        case .fair:
            targetFrameRate = 45
        case .serious, .critical:
            targetFrameRate = 30
        @unknown default:
            targetFrameRate = 30
        }

        // Reduce frame rate on low battery
        if batteryLevel < 0.2 {
            targetFrameRate = min(targetFrameRate, 30)
        }

        displayLink?.preferredFramesPerSecond = targetFrameRate
    }

    @objc private func renderFrame() {
        // Update only what's necessary
        updateVisibleElements()

        // Monitor thermal state and adjust
        if ProcessInfo.processInfo.thermalState != .nominal {
            updateTargetFrameRate()
        }
    }
}
```

### 2. Background App Optimization

#### Efficient Background Handling
```swift
class BackgroundOptimizationManager {
    func optimizeForBackground() {
        // Pause non-essential operations
        ImageCache.shared.pauseCleanupTimer()
        DataSyncManager.shared.pauseSync()

        // Reduce memory footprint
        releaseNonEssentialResources()

        // Suspend expensive operations
        AbilityClassificationService.shared.suspendProcessing()
    }

    func optimizeForForeground() {
        // Resume operations
        ImageCache.shared.resumeCleanupTimer()
        DataSyncManager.shared.resumeSync()

        // Preload essential data
        preloadCriticalResources()

        // Resume processing
        AbilityClassificationService.shared.resumeProcessing()
    }

    private func releaseNonEssentialResources() {
        // Clear view caches that can be regenerated
        ViewCache.shared.clearNonVisible()

        // Reduce image cache size
        ImageCache.shared.reduceToEssentials()

        // Clear temporary data
        TemporaryDataCache.shared.clear()
    }
}
```

## Performance Monitoring and Debugging

### 1. Real-Time Performance Metrics

#### Performance Dashboard
```swift
class PerformanceMonitor {
    private var frameRateCounter = 0
    private var lastFrameRateCheck = Date()
    private var memoryUsageHistory: [Double] = []

    func startMonitoring() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.collectMetrics()
        }
    }

    private func collectMetrics() {
        let currentMemory = getCurrentMemoryUsage()
        let fps = calculateFrameRate()

        memoryUsageHistory.append(currentMemory)
        if memoryUsageHistory.count > 60 {  // Keep last 60 seconds
            memoryUsageHistory.removeFirst()
        }

        // Alert on performance degradation
        if fps < 50 {
            triggerPerformanceAlert("Low frame rate: \(fps)fps")
        }

        if currentMemory > 400 * 1024 * 1024 {  // 400MB warning
            triggerMemoryAlert("High memory usage: \(currentMemory / 1024 / 1024)MB")
        }
    }

    func getPerformanceReport() -> PerformanceReport {
        return PerformanceReport(
            averageFrameRate: calculateAverageFrameRate(),
            peakMemoryUsage: memoryUsageHistory.max() ?? 0,
            averageMemoryUsage: memoryUsageHistory.reduce(0, +) / Double(memoryUsageHistory.count),
            recommendations: generateRecommendations()
        )
    }
}
```

### 2. Automated Performance Testing

#### Performance Test Suite
```swift
class PerformanceTestSuite: XCTestCase {
    func testDungeonListScrollingPerformance() {
        let dungeonList = createDungeonListViewController()
        let expectation = XCTestExpectation(description: "Smooth scrolling")

        measure {
            // Simulate rapid scrolling
            dungeonList.collectionView.setContentOffset(CGPoint(x: 0, y: 1000), animated: false)
            dungeonList.collectionView.setContentOffset(CGPoint(x: 0, y: 2000), animated: false)
            dungeonList.collectionView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        }

        // Verify frame rate stayed above 50fps during scrolling
        XCTAssertGreaterThan(PerformanceMonitor.shared.minFrameRate, 50)
    }

    func testMemoryUsageDuringNavigation() {
        let initialMemory = getCurrentMemoryUsage()

        // Navigate through multiple screens
        navigateThroughAllDungeons()

        let finalMemory = getCurrentMemoryUsage()
        let memoryIncrease = finalMemory - initialMemory

        // Memory increase should be reasonable (< 100MB)
        XCTAssertLessThan(memoryIncrease, 100 * 1024 * 1024)
    }

    func testAbilityCardRenderingPerformance() {
        measure {
            let abilities = generateTestAbilities(count: 50)
            abilities.forEach { ability in
                let card = AbilityCardView(ability: ability)
                _ = card.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
            }
        }

        // Should render 50 cards in < 100ms
        XCTAssertLessThan(measureBlock.timeInterval, 0.1)
    }
}
```

## Production Performance Guidelines

### 1. Launch Optimization Checklist
- [ ] Preload critical images during splash screen
- [ ] Initialize Core Data stack on background queue
- [ ] Cache frequent UI components
- [ ] Prefetch active season data
- [ ] Warm up classification algorithms
- [ ] Verify memory usage < 256MB at launch

### 2. Runtime Performance Monitoring
- [ ] Frame rate monitoring with alerts < 50fps
- [ ] Memory usage tracking with cleanup triggers
- [ ] Battery usage optimization based on level
- [ ] Thermal state adaptation for sustained performance
- [ ] Background/foreground optimization cycles

### 3. Memory Management Best Practices
- [ ] Implement LRU caches with memory pressure handling
- [ ] Use view recycling for collection views
- [ ] Clear non-essential resources during memory warnings
- [ ] Optimize Core Data fetch requests with batching
- [ ] Monitor and limit peak memory usage to < 512MB

This comprehensive performance optimization guide ensures HealerKit delivers consistent 60fps performance and responsive user experience on first-generation iPad Pro hardware, even during intensive healer gameplay scenarios.