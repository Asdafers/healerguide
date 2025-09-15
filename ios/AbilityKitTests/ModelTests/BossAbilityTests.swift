//
//  BossAbilityTests.swift
//  AbilityKitTests
//
//  Unit tests for BossAbility CoreData model - Task T036
//  iOS 13.1+ compatible - First generation iPad Pro support
//

import XCTest
import CoreData
@testable import AbilityKit

final class BossAbilityTests: XCTestCase {

    // MARK: - Test Infrastructure

    var persistentContainer: NSPersistentContainer!
    var context: NSManagedObjectContext!
    var testBossEncounter: BossEncounter!

    override func setUpWithError() throws {
        try super.setUpWithError()

        // Setup in-memory Core Data stack for testing
        persistentContainer = NSPersistentContainer(name: "AbilityKit")

        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        description.shouldAddStoreAsynchronously = false

        persistentContainer.persistentStoreDescriptions = [description]

        persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load test store: \(error)")
            }
        }

        context = persistentContainer.viewContext

        // Create test boss encounter (using forward declaration from BossAbility.swift)
        testBossEncounter = BossEncounter(entity: NSEntityDescription.entity(forEntityName: "BossEncounter", in: context)!, insertInto: context)
        try context.save()
    }

    override func tearDownWithError() throws {
        testBossEncounter = nil
        context = nil
        persistentContainer = nil
        try super.tearDownWithError()
    }

    // MARK: - Initialization Tests

    func testBossAbilityInitialization() {
        // Arrange
        let name = "Alerting Shrill"
        let type = AbilityType.damage
        let targets = TargetType.group
        let damageProfile = DamageProfile.critical
        let healerAction = "Use major defensive cooldown immediately. Pre-heal all players to full health."
        let criticalInsight = "This ability can instantly kill players if not properly prepared for with healing cooldowns."
        let cooldown: TimeInterval = 45.0
        let displayOrder: Int16 = 1
        let isKeyMechanic = true

        // Act
        let ability = BossAbility(
            context: context,
            name: name,
            type: type,
            targets: targets,
            damageProfile: damageProfile,
            healerAction: healerAction,
            criticalInsight: criticalInsight,
            cooldown: cooldown,
            displayOrder: displayOrder,
            isKeyMechanic: isKeyMechanic
        )

        // Assert
        XCTAssertNotNil(ability.id)
        XCTAssertEqual(ability.name, name)
        XCTAssertEqual(ability.type, type.rawValue)
        XCTAssertEqual(ability.targets, targets.rawValue)
        XCTAssertEqual(ability.damageProfile, damageProfile.rawValue)
        XCTAssertEqual(ability.healerAction, healerAction)
        XCTAssertEqual(ability.criticalInsight, criticalInsight)
        XCTAssertEqual(ability.cooldown, cooldown)
        XCTAssertEqual(ability.displayOrder, displayOrder)
        XCTAssertEqual(ability.isKeyMechanic, isKeyMechanic)
    }

    func testBossAbilityInitializationDefaults() {
        // Act
        let ability = BossAbility(
            context: context,
            name: "Test Ability",
            type: .damage,
            targets: .tank,
            damageProfile: .moderate,
            healerAction: "Monitor tank health",
            criticalInsight: "Standard tank damage",
            displayOrder: 1
        )

        // Assert
        XCTAssertEqual(ability.cooldown, 0.0) // Default value
        XCTAssertFalse(ability.isKeyMechanic) // Default value
    }

    // MARK: - Validation Tests

    func testValidBossAbilityInsert() throws {
        // Arrange
        let ability = BossAbility(
            context: context,
            name: "Valid Ability",
            type: .damage,
            targets: .tank,
            damageProfile: .moderate,
            healerAction: "Valid healer action description",
            criticalInsight: "Valid critical insight",
            displayOrder: 1
        )
        testBossEncounter.addToAbilities(ability)

        // Act & Assert - Should not throw
        try context.save()
        XCTAssertFalse(context.hasChanges)
    }

    func testEmptyAbilityNameValidation() {
        // Arrange
        let ability = BossAbility(
            context: context,
            name: "",
            type: .damage,
            targets: .tank,
            damageProfile: .moderate,
            healerAction: "Test action",
            criticalInsight: "Test insight",
            displayOrder: 1
        )
        testBossEncounter.addToAbilities(ability)

        // Act & Assert
        XCTAssertThrowsError(try context.save()) { error in
            guard let validationError = error as? BossAbilityValidationError else {
                XCTFail("Expected BossAbilityValidationError, got \(error)")
                return
            }

            if case .emptyAbilityName = validationError {
                // Expected error type
            } else {
                XCTFail("Expected emptyAbilityName, got \(validationError)")
            }
        }
    }

    func testWhitespaceOnlyAbilityNameValidation() {
        // Arrange
        let ability = BossAbility(
            context: context,
            name: "   \n\t   ",
            type: .damage,
            targets: .tank,
            damageProfile: .moderate,
            healerAction: "Test action",
            criticalInsight: "Test insight",
            displayOrder: 1
        )
        testBossEncounter.addToAbilities(ability)

        // Act & Assert
        XCTAssertThrowsError(try context.save()) { error in
            guard let validationError = error as? BossAbilityValidationError else {
                XCTFail("Expected BossAbilityValidationError, got \(error)")
                return
            }

            if case .emptyAbilityName = validationError {
                // Expected error type
            } else {
                XCTFail("Expected emptyAbilityName, got \(validationError)")
            }
        }
    }

    func testEmptyHealerActionValidation() {
        // Arrange
        let ability = BossAbility(
            context: context,
            name: "Test Ability",
            type: .damage,
            targets: .tank,
            damageProfile: .moderate,
            healerAction: "",
            criticalInsight: "Test insight",
            displayOrder: 1
        )
        testBossEncounter.addToAbilities(ability)

        // Act & Assert
        XCTAssertThrowsError(try context.save()) { error in
            guard let validationError = error as? BossAbilityValidationError else {
                XCTFail("Expected BossAbilityValidationError, got \(error)")
                return
            }

            if case .emptyHealerAction = validationError {
                // Expected error type
            } else {
                XCTFail("Expected emptyHealerAction, got \(validationError)")
            }
        }
    }

    func testWhitespaceOnlyHealerActionValidation() {
        // Arrange
        let ability = BossAbility(
            context: context,
            name: "Test Ability",
            type: .damage,
            targets: .tank,
            damageProfile: .moderate,
            healerAction: "   \n\t   ",
            criticalInsight: "Test insight",
            displayOrder: 1
        )
        testBossEncounter.addToAbilities(ability)

        // Act & Assert
        XCTAssertThrowsError(try context.save()) { error in
            guard let validationError = error as? BossAbilityValidationError else {
                XCTFail("Expected BossAbilityValidationError, got \(error)")
                return
            }

            if case .emptyHealerAction = validationError {
                // Expected error type
            } else {
                XCTFail("Expected emptyHealerAction, got \(validationError)")
            }
        }
    }

    func testHealerActionTooLongValidation() {
        // Arrange - Create action longer than 200 characters
        let longAction = String(repeating: "a", count: 201)
        let ability = BossAbility(
            context: context,
            name: "Test Ability",
            type: .damage,
            targets: .tank,
            damageProfile: .moderate,
            healerAction: longAction,
            criticalInsight: "Test insight",
            displayOrder: 1
        )
        testBossEncounter.addToAbilities(ability)

        // Act & Assert
        XCTAssertThrowsError(try context.save()) { error in
            guard let validationError = error as? BossAbilityValidationError else {
                XCTFail("Expected BossAbilityValidationError, got \(error)")
                return
            }

            if case .healerActionTooLong(let length) = validationError {
                XCTAssertEqual(length, 201)
            } else {
                XCTFail("Expected healerActionTooLong, got \(validationError)")
            }
        }
    }

    func testHealerActionMaxLengthAllowed() throws {
        // Arrange - Create action exactly 200 characters
        let maxLengthAction = String(repeating: "a", count: 200)
        let ability = BossAbility(
            context: context,
            name: "Test Ability",
            type: .damage,
            targets: .tank,
            damageProfile: .moderate,
            healerAction: maxLengthAction,
            criticalInsight: "Test insight",
            displayOrder: 1
        )
        testBossEncounter.addToAbilities(ability)

        // Act & Assert - Should not throw
        try context.save()
    }

    func testEmptyCriticalInsightValidation() {
        // Arrange
        let ability = BossAbility(
            context: context,
            name: "Test Ability",
            type: .damage,
            targets: .tank,
            damageProfile: .moderate,
            healerAction: "Test action",
            criticalInsight: "",
            displayOrder: 1
        )
        testBossEncounter.addToAbilities(ability)

        // Act & Assert
        XCTAssertThrowsError(try context.save()) { error in
            guard let validationError = error as? BossAbilityValidationError else {
                XCTFail("Expected BossAbilityValidationError, got \(error)")
                return
            }

            if case .emptyCriticalInsight = validationError {
                // Expected error type
            } else {
                XCTFail("Expected emptyCriticalInsight, got \(validationError)")
            }
        }
    }

    func testWhitespaceOnlyCriticalInsightValidation() {
        // Arrange
        let ability = BossAbility(
            context: context,
            name: "Test Ability",
            type: .damage,
            targets: .tank,
            damageProfile: .moderate,
            healerAction: "Test action",
            criticalInsight: "   \n\t   ",
            displayOrder: 1
        )
        testBossEncounter.addToAbilities(ability)

        // Act & Assert
        XCTAssertThrowsError(try context.save()) { error in
            guard let validationError = error as? BossAbilityValidationError else {
                XCTFail("Expected BossAbilityValidationError, got \(error)")
                return
            }

            if case .emptyCriticalInsight = validationError {
                // Expected error type
            } else {
                XCTFail("Expected emptyCriticalInsight, got \(validationError)")
            }
        }
    }

    func testCriticalInsightTooLongValidation() {
        // Arrange - Create insight longer than 150 characters
        let longInsight = String(repeating: "a", count: 151)
        let ability = BossAbility(
            context: context,
            name: "Test Ability",
            type: .damage,
            targets: .tank,
            damageProfile: .moderate,
            healerAction: "Test action",
            criticalInsight: longInsight,
            displayOrder: 1
        )
        testBossEncounter.addToAbilities(ability)

        // Act & Assert
        XCTAssertThrowsError(try context.save()) { error in
            guard let validationError = error as? BossAbilityValidationError else {
                XCTFail("Expected BossAbilityValidationError, got \(error)")
                return
            }

            if case .criticalInsightTooLong(let length) = validationError {
                XCTAssertEqual(length, 151)
            } else {
                XCTFail("Expected criticalInsightTooLong, got \(validationError)")
            }
        }
    }

    func testCriticalInsightMaxLengthAllowed() throws {
        // Arrange - Create insight exactly 150 characters
        let maxLengthInsight = String(repeating: "a", count: 150)
        let ability = BossAbility(
            context: context,
            name: "Test Ability",
            type: .damage,
            targets: .tank,
            damageProfile: .moderate,
            healerAction: "Test action",
            criticalInsight: maxLengthInsight,
            displayOrder: 1
        )
        testBossEncounter.addToAbilities(ability)

        // Act & Assert - Should not throw
        try context.save()
    }

    func testDuplicateNameInEncounterValidation() throws {
        // Arrange
        let duplicateName = "Duplicate Ability"
        let ability1 = BossAbility(
            context: context,
            name: duplicateName,
            type: .damage,
            targets: .tank,
            damageProfile: .moderate,
            healerAction: "First action",
            criticalInsight: "First insight",
            displayOrder: 1
        )
        testBossEncounter.addToAbilities(ability1)
        try context.save()

        let ability2 = BossAbility(
            context: context,
            name: duplicateName,
            type: .mechanic,
            targets: .group,
            damageProfile: .high,
            healerAction: "Second action",
            criticalInsight: "Second insight",
            displayOrder: 2
        )
        testBossEncounter.addToAbilities(ability2)

        // Act & Assert
        XCTAssertThrowsError(try context.save()) { error in
            guard let validationError = error as? BossAbilityValidationError else {
                XCTFail("Expected BossAbilityValidationError, got \(error)")
                return
            }

            if case .duplicateNameInEncounter(let name) = validationError {
                XCTAssertEqual(name, duplicateName)
            } else {
                XCTFail("Expected duplicateNameInEncounter, got \(validationError)")
            }
        }
    }

    func testDuplicateDisplayOrderInEncounterValidation() throws {
        // Arrange
        let displayOrder: Int16 = 5
        let ability1 = BossAbility(
            context: context,
            name: "First Ability",
            type: .damage,
            targets: .tank,
            damageProfile: .moderate,
            healerAction: "First action",
            criticalInsight: "First insight",
            displayOrder: displayOrder
        )
        testBossEncounter.addToAbilities(ability1)
        try context.save()

        let ability2 = BossAbility(
            context: context,
            name: "Second Ability",
            type: .mechanic,
            targets: .group,
            damageProfile: .high,
            healerAction: "Second action",
            criticalInsight: "Second insight",
            displayOrder: displayOrder
        )
        testBossEncounter.addToAbilities(ability2)

        // Act & Assert
        XCTAssertThrowsError(try context.save()) { error in
            guard let validationError = error as? BossAbilityValidationError else {
                XCTFail("Expected BossAbilityValidationError, got \(error)")
                return
            }

            if case .duplicateDisplayOrder(let order) = validationError {
                XCTAssertEqual(order, Int(displayOrder))
            } else {
                XCTFail("Expected duplicateDisplayOrder, got \(validationError)")
            }
        }
    }

    func testNegativeCooldownValidation() {
        // Arrange
        let ability = BossAbility(
            context: context,
            name: "Test Ability",
            type: .damage,
            targets: .tank,
            damageProfile: .moderate,
            healerAction: "Test action",
            criticalInsight: "Test insight",
            cooldown: -30,
            displayOrder: 1
        )
        testBossEncounter.addToAbilities(ability)

        // Act & Assert
        XCTAssertThrowsError(try context.save()) { error in
            guard let validationError = error as? BossAbilityValidationError else {
                XCTFail("Expected BossAbilityValidationError, got \(error)")
                return
            }

            if case .invalidCooldown(let cooldown) = validationError {
                XCTAssertEqual(cooldown, -30)
            } else {
                XCTFail("Expected invalidCooldown, got \(validationError)")
            }
        }
    }

    func testZeroCooldownAllowed() throws {
        // Arrange
        let ability = BossAbility(
            context: context,
            name: "Test Ability",
            type: .damage,
            targets: .tank,
            damageProfile: .moderate,
            healerAction: "Test action",
            criticalInsight: "Test insight",
            cooldown: 0,
            displayOrder: 1
        )
        testBossEncounter.addToAbilities(ability)

        // Act & Assert - Should not throw
        try context.save()
    }

    func testInvalidAbilityTypeValidation() {
        // Arrange
        let ability = BossAbility(
            context: context,
            name: "Test Ability",
            type: .damage,
            targets: .tank,
            damageProfile: .moderate,
            healerAction: "Test action",
            criticalInsight: "Test insight",
            displayOrder: 1
        )

        // Manually set invalid ability type
        ability.type = "invalid_type"
        testBossEncounter.addToAbilities(ability)

        // Act & Assert
        XCTAssertThrowsError(try context.save()) { error in
            guard let validationError = error as? BossAbilityValidationError else {
                XCTFail("Expected BossAbilityValidationError, got \(error)")
                return
            }

            if case .invalidAbilityType(let type) = validationError {
                XCTAssertEqual(type, "invalid_type")
            } else {
                XCTFail("Expected invalidAbilityType, got \(validationError)")
            }
        }
    }

    func testInvalidTargetTypeValidation() {
        // Arrange
        let ability = BossAbility(
            context: context,
            name: "Test Ability",
            type: .damage,
            targets: .tank,
            damageProfile: .moderate,
            healerAction: "Test action",
            criticalInsight: "Test insight",
            displayOrder: 1
        )

        // Manually set invalid target type
        ability.targets = "invalid_target"
        testBossEncounter.addToAbilities(ability)

        // Act & Assert
        XCTAssertThrowsError(try context.save()) { error in
            guard let validationError = error as? BossAbilityValidationError else {
                XCTFail("Expected BossAbilityValidationError, got \(error)")
                return
            }

            if case .invalidTargetType(let type) = validationError {
                XCTAssertEqual(type, "invalid_target")
            } else {
                XCTFail("Expected invalidTargetType, got \(validationError)")
            }
        }
    }

    func testInvalidDamageProfileValidation() {
        // Arrange
        let ability = BossAbility(
            context: context,
            name: "Test Ability",
            type: .damage,
            targets: .tank,
            damageProfile: .moderate,
            healerAction: "Test action",
            criticalInsight: "Test insight",
            displayOrder: 1
        )

        // Manually set invalid damage profile
        ability.damageProfile = "invalid_profile"
        testBossEncounter.addToAbilities(ability)

        // Act & Assert
        XCTAssertThrowsError(try context.save()) { error in
            guard let validationError = error as? BossAbilityValidationError else {
                XCTFail("Expected BossAbilityValidationError, got \(error)")
                return
            }

            if case .invalidDamageProfile(let profile) = validationError {
                XCTAssertEqual(profile, "invalid_profile")
            } else {
                XCTFail("Expected invalidDamageProfile, got \(validationError)")
            }
        }
    }

    // MARK: - Business Logic Tests

    func testAbilityTypeEnumConversion() {
        // Test all ability types
        let types: [AbilityType] = [.damage, .heal, .mechanic, .movement, .interrupt]

        for type in types {
            // Arrange
            let ability = BossAbility(
                context: context,
                name: "Test Ability",
                type: type,
                targets: .tank,
                damageProfile: .moderate,
                healerAction: "Test action",
                criticalInsight: "Test insight",
                displayOrder: 1
            )

            // Act & Assert
            XCTAssertEqual(ability.abilityType, type)

            // Test setting ability type
            let newType: AbilityType = type == .damage ? .heal : .damage
            ability.setAbilityType(newType)
            XCTAssertEqual(ability.abilityType, newType)
            XCTAssertEqual(ability.type, newType.rawValue)
        }
    }

    func testAbilityTypeEnum() {
        // Test enum properties
        XCTAssertEqual(AbilityType.damage.rawValue, "damage")
        XCTAssertEqual(AbilityType.heal.rawValue, "heal")
        XCTAssertEqual(AbilityType.mechanic.rawValue, "mechanic")
        XCTAssertEqual(AbilityType.movement.rawValue, "movement")
        XCTAssertEqual(AbilityType.interrupt.rawValue, "interrupt")

        XCTAssertEqual(AbilityType.damage.displayName, "Damage")
        XCTAssertEqual(AbilityType.heal.displayName, "Heal")
        XCTAssertEqual(AbilityType.mechanic.displayName, "Mechanic")
        XCTAssertEqual(AbilityType.movement.displayName, "Movement")
        XCTAssertEqual(AbilityType.interrupt.displayName, "Interrupt")

        // Test all cases
        let allCases = AbilityType.allCases
        XCTAssertEqual(allCases.count, 5)
        XCTAssertTrue(allCases.contains(.damage))
        XCTAssertTrue(allCases.contains(.heal))
        XCTAssertTrue(allCases.contains(.mechanic))
        XCTAssertTrue(allCases.contains(.movement))
        XCTAssertTrue(allCases.contains(.interrupt))
    }

    func testTargetTypeEnumConversion() {
        // Test all target types
        let targets: [TargetType] = [.tank, .randomPlayer, .group, .healers, .location]

        for target in targets {
            // Arrange
            let ability = BossAbility(
                context: context,
                name: "Test Ability",
                type: .damage,
                targets: target,
                damageProfile: .moderate,
                healerAction: "Test action",
                criticalInsight: "Test insight",
                displayOrder: 1
            )

            // Act & Assert
            XCTAssertEqual(ability.targetType, target)

            // Test setting target type
            let newTarget: TargetType = target == .tank ? .group : .tank
            ability.setTargetType(newTarget)
            XCTAssertEqual(ability.targetType, newTarget)
            XCTAssertEqual(ability.targets, newTarget.rawValue)
        }
    }

    func testTargetTypeEnum() {
        // Test enum properties
        XCTAssertEqual(TargetType.tank.rawValue, "tank")
        XCTAssertEqual(TargetType.randomPlayer.rawValue, "random_player")
        XCTAssertEqual(TargetType.group.rawValue, "group")
        XCTAssertEqual(TargetType.healers.rawValue, "healers")
        XCTAssertEqual(TargetType.location.rawValue, "location")

        XCTAssertEqual(TargetType.tank.displayName, "Tank")
        XCTAssertEqual(TargetType.randomPlayer.displayName, "Random Player")
        XCTAssertEqual(TargetType.group.displayName, "Group")
        XCTAssertEqual(TargetType.healers.displayName, "Healers")
        XCTAssertEqual(TargetType.location.displayName, "Location")

        // Test all cases
        let allCases = TargetType.allCases
        XCTAssertEqual(allCases.count, 5)
        XCTAssertTrue(allCases.contains(.tank))
        XCTAssertTrue(allCases.contains(.randomPlayer))
        XCTAssertTrue(allCases.contains(.group))
        XCTAssertTrue(allCases.contains(.healers))
        XCTAssertTrue(allCases.contains(.location))
    }

    func testDamageProfileEnumConversion() {
        // Test all damage profiles
        let profiles: [DamageProfile] = [.critical, .high, .moderate, .mechanic]

        for profile in profiles {
            // Arrange
            let ability = BossAbility(
                context: context,
                name: "Test Ability",
                type: .damage,
                targets: .tank,
                damageProfile: profile,
                healerAction: "Test action",
                criticalInsight: "Test insight",
                displayOrder: 1
            )

            // Act & Assert
            XCTAssertEqual(ability.damage, profile)

            // Test setting damage profile
            let newProfile: DamageProfile = profile == .critical ? .moderate : .critical
            ability.setDamageProfile(newProfile)
            XCTAssertEqual(ability.damage, newProfile)
            XCTAssertEqual(ability.damageProfile, newProfile.rawValue)
        }
    }

    func testDamageProfileEnum() {
        // Test enum properties
        XCTAssertEqual(DamageProfile.critical.rawValue, "critical")
        XCTAssertEqual(DamageProfile.high.rawValue, "high")
        XCTAssertEqual(DamageProfile.moderate.rawValue, "moderate")
        XCTAssertEqual(DamageProfile.mechanic.rawValue, "mechanic")

        XCTAssertEqual(DamageProfile.critical.displayName, "Critical")
        XCTAssertEqual(DamageProfile.high.displayName, "High")
        XCTAssertEqual(DamageProfile.moderate.displayName, "Moderate")
        XCTAssertEqual(DamageProfile.mechanic.displayName, "Mechanic")

        // Test priority values
        XCTAssertEqual(DamageProfile.critical.priority, 4)
        XCTAssertEqual(DamageProfile.high.priority, 3)
        XCTAssertEqual(DamageProfile.moderate.priority, 2)
        XCTAssertEqual(DamageProfile.mechanic.priority, 1)

        // Test color schemes
        let criticalScheme = DamageProfile.critical.colorScheme
        XCTAssertEqual(criticalScheme.primaryColor, "#FF4444")
        XCTAssertEqual(criticalScheme.backgroundColor, "#FFEBEE")
        XCTAssertEqual(criticalScheme.textColor, "#B71C1C")
        XCTAssertEqual(criticalScheme.borderColor, "#FF4444")

        let highScheme = DamageProfile.high.colorScheme
        XCTAssertEqual(highScheme.primaryColor, "#FF9800")
        XCTAssertEqual(highScheme.backgroundColor, "#FFF3E0")
        XCTAssertEqual(highScheme.textColor, "#E65100")
        XCTAssertEqual(highScheme.borderColor, "#FF9800")

        let moderateScheme = DamageProfile.moderate.colorScheme
        XCTAssertEqual(moderateScheme.primaryColor, "#FFC107")
        XCTAssertEqual(moderateScheme.backgroundColor, "#FFFDE7")
        XCTAssertEqual(moderateScheme.textColor, "#F57F17")
        XCTAssertEqual(moderateScheme.borderColor, "#FFC107")

        let mechanicScheme = DamageProfile.mechanic.colorScheme
        XCTAssertEqual(mechanicScheme.primaryColor, "#2196F3")
        XCTAssertEqual(mechanicScheme.backgroundColor, "#E3F2FD")
        XCTAssertEqual(mechanicScheme.textColor, "#0D47A1")
        XCTAssertEqual(mechanicScheme.borderColor, "#2196F3")

        // Test all cases
        let allCases = DamageProfile.allCases
        XCTAssertEqual(allCases.count, 4)
        XCTAssertTrue(allCases.contains(.critical))
        XCTAssertTrue(allCases.contains(.high))
        XCTAssertTrue(allCases.contains(.moderate))
        XCTAssertTrue(allCases.contains(.mechanic))
    }

    func testFormattedCooldownNone() {
        // Arrange
        let ability = BossAbility(
            context: context,
            name: "Test Ability",
            type: .damage,
            targets: .tank,
            damageProfile: .moderate,
            healerAction: "Test action",
            criticalInsight: "Test insight",
            cooldown: 0,
            displayOrder: 1
        )

        // Act & Assert
        XCTAssertNil(ability.formattedCooldown)
    }

    func testFormattedCooldownSeconds() {
        // Test various cooldowns in seconds
        let testCases: [(TimeInterval, String)] = [
            (15, "15s"),
            (30, "30s"),
            (45, "45s"),
            (59, "59s")
        ]

        for (cooldown, expected) in testCases {
            // Arrange
            let ability = BossAbility(
                context: context,
                name: "Test Ability",
                type: .damage,
                targets: .tank,
                damageProfile: .moderate,
                healerAction: "Test action",
                criticalInsight: "Test insight",
                cooldown: cooldown,
                displayOrder: 1
            )

            // Act & Assert
            XCTAssertEqual(ability.formattedCooldown, expected, "Cooldown \(cooldown) should format as \(expected)")
        }
    }

    func testFormattedCooldownMinutesAndSeconds() {
        // Test cooldowns with minutes and seconds
        let testCases: [(TimeInterval, String)] = [
            (60, "1:00"),
            (75, "1:15"),
            (120, "2:00"),
            (135, "2:15"),
            (180, "3:00"),
            (195, "3:15"),
            (300, "5:00"),
            (365, "6:05")
        ]

        for (cooldown, expected) in testCases {
            // Arrange
            let ability = BossAbility(
                context: context,
                name: "Test Ability",
                type: .damage,
                targets: .tank,
                damageProfile: .moderate,
                healerAction: "Test action",
                criticalInsight: "Test insight",
                cooldown: cooldown,
                displayOrder: 1
            )

            // Act & Assert
            XCTAssertEqual(ability.formattedCooldown, expected, "Cooldown \(cooldown) should format as \(expected)")
        }
    }

    func testColorSchemeFromDamageProfile() {
        let testCases: [(DamageProfile, String)] = [
            (.critical, "#FF4444"),
            (.high, "#FF9800"),
            (.moderate, "#FFC107"),
            (.mechanic, "#2196F3")
        ]

        for (profile, expectedPrimaryColor) in testCases {
            // Arrange
            let ability = BossAbility(
                context: context,
                name: "Test Ability",
                type: .damage,
                targets: .tank,
                damageProfile: profile,
                healerAction: "Test action",
                criticalInsight: "Test insight",
                displayOrder: 1
            )

            // Act & Assert
            XCTAssertNotNil(ability.colorScheme)
            XCTAssertEqual(ability.colorScheme?.primaryColor, expectedPrimaryColor)
        }
    }

    func testColorSchemeWithInvalidProfile() {
        // Arrange
        let ability = BossAbility(
            context: context,
            name: "Test Ability",
            type: .damage,
            targets: .tank,
            damageProfile: .moderate,
            healerAction: "Test action",
            criticalInsight: "Test insight",
            displayOrder: 1
        )

        // Manually set invalid damage profile
        ability.damageProfile = "invalid"

        // Act & Assert
        XCTAssertNil(ability.colorScheme)
    }

    func testPriorityCalculation() {
        // Test priority without key mechanic
        let regularAbility = BossAbility(
            context: context,
            name: "Regular Ability",
            type: .damage,
            targets: .tank,
            damageProfile: .high,
            healerAction: "Test action",
            criticalInsight: "Test insight",
            displayOrder: 1,
            isKeyMechanic: false
        )
        XCTAssertEqual(regularAbility.priority, 3) // High priority without boost

        // Test priority with key mechanic
        let keyMechanicAbility = BossAbility(
            context: context,
            name: "Key Mechanic Ability",
            type: .damage,
            targets: .tank,
            damageProfile: .high,
            healerAction: "Test action",
            criticalInsight: "Test insight",
            displayOrder: 1,
            isKeyMechanic: true
        )
        XCTAssertEqual(keyMechanicAbility.priority, 13) // High priority (3) + key mechanic boost (10)

        // Test different damage profiles
        let criticalAbility = BossAbility(
            context: context,
            name: "Critical Ability",
            type: .damage,
            targets: .tank,
            damageProfile: .critical,
            healerAction: "Test action",
            criticalInsight: "Test insight",
            displayOrder: 1,
            isKeyMechanic: true
        )
        XCTAssertEqual(criticalAbility.priority, 14) // Critical priority (4) + key mechanic boost (10)
    }

    func testDisplayHint() {
        // Test display hints for different scenarios
        let testCases: [(DamageProfile, Bool, UIDisplayHint)] = [
            (.critical, false, .emphasize),
            (.critical, true, .highlight), // Key mechanic overrides
            (.high, false, .standard),
            (.high, true, .highlight),
            (.moderate, false, .standard),
            (.moderate, true, .highlight),
            (.mechanic, false, .muted),
            (.mechanic, true, .highlight)
        ]

        for (profile, isKey, expectedHint) in testCases {
            // Arrange
            let ability = BossAbility(
                context: context,
                name: "Test Ability",
                type: .damage,
                targets: .tank,
                damageProfile: profile,
                healerAction: "Test action",
                criticalInsight: "Test insight",
                displayOrder: 1,
                isKeyMechanic: isKey
            )

            // Act & Assert
            XCTAssertEqual(ability.displayHint, expectedHint,
                          "Profile \(profile), key: \(isKey) should have hint \(expectedHint)")
        }
    }

    func testDisplayHintWithInvalidProfile() {
        // Arrange
        let ability = BossAbility(
            context: context,
            name: "Test Ability",
            type: .damage,
            targets: .tank,
            damageProfile: .moderate,
            healerAction: "Test action",
            criticalInsight: "Test insight",
            displayOrder: 1
        )

        // Manually set invalid damage profile
        ability.damageProfile = "invalid"

        // Act & Assert
        XCTAssertEqual(ability.displayHint, .standard) // Default for invalid profile
    }

    func testRequiresImmediateAttention() {
        // Test critical abilities
        let criticalAbility = BossAbility(
            context: context,
            name: "Critical Ability",
            type: .damage,
            targets: .tank,
            damageProfile: .critical,
            healerAction: "Test action",
            criticalInsight: "Test insight",
            displayOrder: 1
        )
        XCTAssertTrue(criticalAbility.requiresImmediateAttention)

        // Test high + key mechanic
        let highKeyAbility = BossAbility(
            context: context,
            name: "High Key Ability",
            type: .damage,
            targets: .tank,
            damageProfile: .high,
            healerAction: "Test action",
            criticalInsight: "Test insight",
            displayOrder: 1,
            isKeyMechanic: true
        )
        XCTAssertTrue(highKeyAbility.requiresImmediateAttention)

        // Test high without key mechanic
        let highRegularAbility = BossAbility(
            context: context,
            name: "High Regular Ability",
            type: .damage,
            targets: .tank,
            damageProfile: .high,
            healerAction: "Test action",
            criticalInsight: "Test insight",
            displayOrder: 1,
            isKeyMechanic: false
        )
        XCTAssertFalse(highRegularAbility.requiresImmediateAttention)

        // Test moderate abilities
        let moderateAbility = BossAbility(
            context: context,
            name: "Moderate Ability",
            type: .damage,
            targets: .tank,
            damageProfile: .moderate,
            healerAction: "Test action",
            criticalInsight: "Test insight",
            displayOrder: 1
        )
        XCTAssertFalse(moderateAbility.requiresImmediateAttention)

        // Test mechanic abilities
        let mechanicAbility = BossAbility(
            context: context,
            name: "Mechanic Ability",
            type: .damage,
            targets: .tank,
            damageProfile: .mechanic,
            healerAction: "Test action",
            criticalInsight: "Test insight",
            displayOrder: 1
        )
        XCTAssertFalse(mechanicAbility.requiresImmediateAttention)
    }

    func testRequiresImmediateAttentionWithInvalidProfile() {
        // Arrange
        let ability = BossAbility(
            context: context,
            name: "Test Ability",
            type: .damage,
            targets: .tank,
            damageProfile: .moderate,
            healerAction: "Test action",
            criticalInsight: "Test insight",
            displayOrder: 1
        )

        // Manually set invalid damage profile
        ability.damageProfile = "invalid"

        // Act & Assert
        XCTAssertFalse(ability.requiresImmediateAttention) // Default for invalid profile
    }

    // MARK: - Fetch Request Tests

    func testFetchAbilitiesForBossEncounterId() throws {
        // Arrange
        let ability1 = BossAbility(context: context, name: "Ability 1", type: .damage, targets: .tank, damageProfile: .moderate, healerAction: "Action 1", criticalInsight: "Insight 1", displayOrder: 2)
        let ability2 = BossAbility(context: context, name: "Ability 2", type: .mechanic, targets: .group, damageProfile: .high, healerAction: "Action 2", criticalInsight: "Insight 2", displayOrder: 1)

        testBossEncounter.addToAbilities(ability1)
        testBossEncounter.addToAbilities(ability2)
        try context.save()

        // Act
        let fetchedAbilities = try BossAbility.fetchAbilities(for: testBossEncounter.id! as UUID, context: context)

        // Assert - Should be ordered by display order
        XCTAssertEqual(fetchedAbilities.count, 2)
        XCTAssertEqual(fetchedAbilities[0].displayOrder, 1)
        XCTAssertEqual(fetchedAbilities[1].displayOrder, 2)
        XCTAssertEqual(fetchedAbilities[0].name, "Ability 2")
        XCTAssertEqual(fetchedAbilities[1].name, "Ability 1")
    }

    func testSearchAbilities() throws {
        // Arrange
        let abilities = [
            BossAbility(context: context, name: "Alerting Shrill", type: .damage, targets: .group, damageProfile: .critical, healerAction: "Major cooldown", criticalInsight: "Deadly", displayOrder: 1),
            BossAbility(context: context, name: "Web Blast", type: .damage, targets: .randomPlayer, damageProfile: .high, healerAction: "Heal target", criticalInsight: "Positioning", displayOrder: 2),
            BossAbility(context: context, name: "Piercing Strike", type: .damage, targets: .tank, damageProfile: .moderate, healerAction: "Tank healing", criticalInsight: "Steady damage", displayOrder: 3)
        ]

        for ability in abilities {
            testBossEncounter.addToAbilities(ability)
        }
        try context.save()

        // Act & Assert - Test name search
        let shrillResults = try BossAbility.searchAbilities(query: "shrill", context: context)
        XCTAssertEqual(shrillResults.count, 1)
        XCTAssertEqual(shrillResults[0].name, "Alerting Shrill")

        // Test partial match
        let webResults = try BossAbility.searchAbilities(query: "web", context: context)
        XCTAssertEqual(webResults.count, 1)
        XCTAssertEqual(webResults[0].name, "Web Blast")

        // Test case insensitive
        let piercingResults = try BossAbility.searchAbilities(query: "PIERCING", context: context)
        XCTAssertEqual(piercingResults.count, 1)
        XCTAssertEqual(piercingResults[0].name, "Piercing Strike")

        // Test no results
        let noResults = try BossAbility.searchAbilities(query: "nonexistent", context: context)
        XCTAssertTrue(noResults.isEmpty)
    }

    func testFetchAbilitiesByDamageProfile() throws {
        // Arrange
        let criticalAbility = BossAbility(context: context, name: "Critical Ability", type: .damage, targets: .group, damageProfile: .critical, healerAction: "Emergency response", criticalInsight: "Life or death", displayOrder: 1)
        let highAbility1 = BossAbility(context: context, name: "High Ability 1", type: .damage, targets: .tank, damageProfile: .high, healerAction: "Strong heal", criticalInsight: "Significant damage", displayOrder: 2)
        let highAbility2 = BossAbility(context: context, name: "High Ability 2", type: .damage, targets: .randomPlayer, damageProfile: .high, healerAction: "Heal target", criticalInsight: "Notable damage", displayOrder: 3)
        let moderateAbility = BossAbility(context: context, name: "Moderate Ability", type: .damage, targets: .tank, damageProfile: .moderate, healerAction: "Standard heal", criticalInsight: "Regular damage", displayOrder: 4)

        testBossEncounter.addToAbilities(criticalAbility)
        testBossEncounter.addToAbilities(highAbility1)
        testBossEncounter.addToAbilities(highAbility2)
        testBossEncounter.addToAbilities(moderateAbility)
        try context.save()

        // Act & Assert - Test high damage profile
        let highAbilities = try BossAbility.fetchAbilities(for: testBossEncounter.id! as UUID, damageProfile: .high, context: context)
        XCTAssertEqual(highAbilities.count, 2)
        XCTAssertTrue(highAbilities.allSatisfy { $0.damage == .high })

        // Test ordering by display order
        XCTAssertEqual(highAbilities[0].displayOrder, 2)
        XCTAssertEqual(highAbilities[1].displayOrder, 3)

        // Test critical damage profile
        let criticalAbilities = try BossAbility.fetchAbilities(for: testBossEncounter.id! as UUID, damageProfile: .critical, context: context)
        XCTAssertEqual(criticalAbilities.count, 1)
        XCTAssertEqual(criticalAbilities[0].name, "Critical Ability")

        // Test mechanic damage profile (none exist)
        let mechanicAbilities = try BossAbility.fetchAbilities(for: testBossEncounter.id! as UUID, damageProfile: .mechanic, context: context)
        XCTAssertTrue(mechanicAbilities.isEmpty)
    }

    func testFetchKeyMechanics() throws {
        // Arrange
        let keyAbility1 = BossAbility(context: context, name: "Key Ability 1", type: .damage, targets: .group, damageProfile: .critical, healerAction: "Major response", criticalInsight: "Key mechanic", displayOrder: 2, isKeyMechanic: true)
        let regularAbility = BossAbility(context: context, name: "Regular Ability", type: .damage, targets: .tank, damageProfile: .moderate, healerAction: "Standard heal", criticalInsight: "Regular damage", displayOrder: 1, isKeyMechanic: false)
        let keyAbility2 = BossAbility(context: context, name: "Key Ability 2", type: .mechanic, targets: .location, damageProfile: .mechanic, healerAction: "Position response", criticalInsight: "Important mechanic", displayOrder: 3, isKeyMechanic: true)

        testBossEncounter.addToAbilities(keyAbility1)
        testBossEncounter.addToAbilities(regularAbility)
        testBossEncounter.addToAbilities(keyAbility2)
        try context.save()

        // Act
        let keyMechanics = try BossAbility.fetchKeyMechanics(for: testBossEncounter.id! as UUID, context: context)

        // Assert - Should only include key mechanics, ordered by display order
        XCTAssertEqual(keyMechanics.count, 2)
        XCTAssertTrue(keyMechanics.allSatisfy { $0.isKeyMechanic })
        XCTAssertEqual(keyMechanics[0].displayOrder, 2)
        XCTAssertEqual(keyMechanics[1].displayOrder, 3)
        XCTAssertEqual(keyMechanics[0].name, "Key Ability 1")
        XCTAssertEqual(keyMechanics[1].name, "Key Ability 2")
    }

    func testFetchCriticalAbilities() throws {
        // Arrange
        let criticalAbility = BossAbility(context: context, name: "Critical Ability", type: .damage, targets: .group, damageProfile: .critical, healerAction: "Emergency", criticalInsight: "Critical", displayOrder: 1, isKeyMechanic: false)
        let highKeyAbility = BossAbility(context: context, name: "High Key Ability", type: .damage, targets: .tank, damageProfile: .high, healerAction: "Strong response", criticalInsight: "Important", displayOrder: 2, isKeyMechanic: true)
        let highRegularAbility = BossAbility(context: context, name: "High Regular Ability", type: .damage, targets: .tank, damageProfile: .high, healerAction: "Strong heal", criticalInsight: "Notable", displayOrder: 3, isKeyMechanic: false)
        let moderateAbility = BossAbility(context: context, name: "Moderate Ability", type: .damage, targets: .tank, damageProfile: .moderate, healerAction: "Standard", criticalInsight: "Regular", displayOrder: 4, isKeyMechanic: false)

        testBossEncounter.addToAbilities(criticalAbility)
        testBossEncounter.addToAbilities(highKeyAbility)
        testBossEncounter.addToAbilities(highRegularAbility)
        testBossEncounter.addToAbilities(moderateAbility)
        try context.save()

        // Act
        let criticalAbilities = try BossAbility.fetchCriticalAbilities(for: testBossEncounter.id! as UUID, context: context)

        // Assert - Should include critical abilities and high + key mechanic abilities
        XCTAssertEqual(criticalAbilities.count, 2)
        XCTAssertEqual(criticalAbilities[0].name, "Critical Ability")
        XCTAssertEqual(criticalAbilities[1].name, "High Key Ability")
        XCTAssertEqual(criticalAbilities[0].displayOrder, 1)
        XCTAssertEqual(criticalAbilities[1].displayOrder, 2)
    }

    func testFetchPrioritizedAbilities() throws {
        // Arrange
        let criticalKeyAbility = BossAbility(context: context, name: "Critical Key", type: .damage, targets: .group, damageProfile: .critical, healerAction: "Emergency", criticalInsight: "Critical key", displayOrder: 4, isKeyMechanic: true) // Priority: 14
        let criticalAbility = BossAbility(context: context, name: "Critical Regular", type: .damage, targets: .group, damageProfile: .critical, healerAction: "Emergency", criticalInsight: "Critical", displayOrder: 3, isKeyMechanic: false) // Priority: 4
        let highKeyAbility = BossAbility(context: context, name: "High Key", type: .damage, targets: .tank, damageProfile: .high, healerAction: "Strong", criticalInsight: "High key", displayOrder: 2, isKeyMechanic: true) // Priority: 13
        let moderateAbility = BossAbility(context: context, name: "Moderate", type: .damage, targets: .tank, damageProfile: .moderate, healerAction: "Standard", criticalInsight: "Moderate", displayOrder: 1, isKeyMechanic: false) // Priority: 2

        testBossEncounter.addToAbilities(criticalKeyAbility)
        testBossEncounter.addToAbilities(criticalAbility)
        testBossEncounter.addToAbilities(highKeyAbility)
        testBossEncounter.addToAbilities(moderateAbility)
        try context.save()

        // Act
        let prioritizedAbilities = try BossAbility.fetchPrioritizedAbilities(for: testBossEncounter.id! as UUID, context: context)

        // Assert - Should be ordered by priority (highest first), then by display order as tiebreaker
        XCTAssertEqual(prioritizedAbilities.count, 4)
        XCTAssertEqual(prioritizedAbilities[0].name, "Critical Key") // Priority 14
        XCTAssertEqual(prioritizedAbilities[1].name, "High Key") // Priority 13
        XCTAssertEqual(prioritizedAbilities[2].name, "Critical Regular") // Priority 4
        XCTAssertEqual(prioritizedAbilities[3].name, "Moderate") // Priority 2
    }

    // MARK: - Validation Error Tests

    func testValidationErrorDescriptions() {
        // Test all validation error descriptions
        let errors: [BossAbilityValidationError] = [
            .emptyAbilityName,
            .emptyHealerAction,
            .healerActionTooLong(201),
            .emptyCriticalInsight,
            .criticalInsightTooLong(151),
            .duplicateNameInEncounter("Duplicate Ability"),
            .duplicateDisplayOrder(5),
            .invalidCooldown(-30),
            .invalidAbilityType("invalid_type"),
            .invalidTargetType("invalid_target"),
            .invalidDamageProfile("invalid_profile")
        ]

        for error in errors {
            XCTAssertNotNil(error.errorDescription)
            XCTAssertFalse(error.errorDescription!.isEmpty)
        }
    }

    // MARK: - Supporting Structure Tests

    func testAbilityColorScheme() {
        // Test AbilityColorScheme structure
        let colorScheme = AbilityColorScheme(
            primaryColor: "#FF0000",
            backgroundColor: "#FFEEEE",
            textColor: "#990000",
            borderColor: "#FF0000"
        )

        XCTAssertEqual(colorScheme.primaryColor, "#FF0000")
        XCTAssertEqual(colorScheme.backgroundColor, "#FFEEEE")
        XCTAssertEqual(colorScheme.textColor, "#990000")
        XCTAssertEqual(colorScheme.borderColor, "#FF0000")
    }

    func testUIDisplayHintEnum() {
        // Test enum properties
        XCTAssertEqual(UIDisplayHint.highlight.rawValue, "highlight")
        XCTAssertEqual(UIDisplayHint.emphasize.rawValue, "emphasize")
        XCTAssertEqual(UIDisplayHint.standard.rawValue, "standard")
        XCTAssertEqual(UIDisplayHint.muted.rawValue, "muted")

        // Test all cases
        let allCases = UIDisplayHint.allCases
        XCTAssertEqual(allCases.count, 4)
        XCTAssertTrue(allCases.contains(.highlight))
        XCTAssertTrue(allCases.contains(.emphasize))
        XCTAssertTrue(allCases.contains(.standard))
        XCTAssertTrue(allCases.contains(.muted))
    }

    // MARK: - Edge Cases

    func testBossAbilityWithNilManagedObjectContext() {
        // Arrange
        let ability = BossAbility()

        // Act & Assert
        XCTAssertNil(ability.managedObjectContext)
        XCTAssertNil(ability.abilityType) // Should handle nil context gracefully
        XCTAssertNil(ability.targetType)
        XCTAssertNil(ability.damage)
        XCTAssertNil(ability.formattedCooldown)
        XCTAssertNil(ability.colorScheme)
    }

    func testIdentifiableConformance() {
        // Arrange
        let ability = BossAbility(
            context: context,
            name: "Test Ability",
            type: .damage,
            targets: .tank,
            damageProfile: .moderate,
            healerAction: "Test action",
            criticalInsight: "Test insight",
            displayOrder: 1
        )

        // Act & Assert
        XCTAssertNotNil(ability.id)

        // Test that ability conforms to Identifiable
        let identifiableAbility: any Identifiable = ability
        XCTAssertEqual(identifiableAbility.id as? UUID, ability.id)
    }

    func testCoreDataPropertiesAccessibility() {
        // Arrange
        let ability = BossAbility(
            context: context,
            name: "Test Ability",
            type: .damage,
            targets: .tank,
            damageProfile: .moderate,
            healerAction: "Test action",
            criticalInsight: "Test insight",
            displayOrder: 1
        )
        let testUUID = UUID()

        // Act & Assert - Test all Core Data properties are accessible
        ability.id = testUUID
        XCTAssertEqual(ability.id, testUUID)

        ability.name = "Updated Ability"
        XCTAssertEqual(ability.name, "Updated Ability")

        ability.type = "updated_type"
        XCTAssertEqual(ability.type, "updated_type")

        ability.targets = "updated_target"
        XCTAssertEqual(ability.targets, "updated_target")

        ability.damageProfile = "updated_profile"
        XCTAssertEqual(ability.damageProfile, "updated_profile")

        ability.healerAction = "Updated action"
        XCTAssertEqual(ability.healerAction, "Updated action")

        ability.criticalInsight = "Updated insight"
        XCTAssertEqual(ability.criticalInsight, "Updated insight")

        ability.cooldown = 120
        XCTAssertEqual(ability.cooldown, 120)

        ability.displayOrder = 5
        XCTAssertEqual(ability.displayOrder, 5)

        ability.isKeyMechanic = true
        XCTAssertTrue(ability.isKeyMechanic)
    }
}