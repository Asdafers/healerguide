# HealerKit iOS Project

## Overview
Native iPad application for World of Warcraft Mythic+ healers targeting first-generation iPad Pro with iOS 13.1+ compatibility.

## Project Structure

### Main Application
- **HealerKit** - Main iPad app target
  - iOS 13.1+ deployment target (first-gen iPad Pro support)
  - Swift 5.9 language version
  - CoreData for offline storage
  - iPad-optimized UI with portrait and landscape support

### Framework Libraries
- **DungeonKit** - Framework for managing dungeon and boss encounter data
- **AbilityKit** - Framework for managing boss abilities and damage classification
- **HealerUIKit** - Framework for iPad-optimized UI components

### Test Targets
- **HealerKitTests** - Tests for main application
- **DungeonKitTests** - Tests for DungeonKit framework
- **AbilityKitTests** - Tests for AbilityKit framework
- **HealerUIKitTests** - Tests for HealerUIKit framework

### CoreData Model
- **HealerKit.xcdatamodeld** - Data model with entities:
  - Season (id, name, majorPatchVersion, isActive, createdAt, updatedAt)
  - Dungeon (id, name, shortName, difficultyLevel, displayOrder, estimatedDuration, healerNotes)
  - BossEncounter (id, name, encounterOrder, healerSummary, difficultyRating, estimatedDuration, keyMechanics)
  - BossAbility (id, name, type, targets, damageProfile, healerAction, criticalInsight, cooldown, displayOrder, isKeyMechanic)

## Build Configuration
- **iOS Deployment Target**: 13.1 (first-gen iPad Pro maximum supported version)
- **Swift Version**: 5.9
- **Device Support**: iPad only (TARGETED_DEVICE_FAMILY = 2)
- **Orientations**: Portrait, Landscape Left, Landscape Right
- **Architecture**: Library-first design following constitutional principles

## Next Steps
This structure implements Task T001 from the implementation plan. The next tasks will involve:
1. Setting up project dependencies and build settings (T002)
2. Configuring development tools (T003)
3. Writing contract tests (T004-T006)
4. Implementing the core functionality following TDD principles

## Constitutional Compliance
- ✅ Library-first architecture (DungeonKit, AbilityKit, HealerUIKit)
- ✅ Test targets for all components
- ✅ iOS 13.1+ compatibility for first-gen iPad Pro
- ✅ Swift 5.9 configuration
- ✅ CoreData model with proper entity relationships
- ✅ iPad-specific configuration (device family, orientations)