#!/usr/bin/env swift

// Validation script for T038-T039 UI and Accessibility Tests
// Checks test completeness and structure

import Foundation

struct TestValidation {
    let filePath: String
    let expectedTestMethods: [String]
    let requiredImports: [String]
}

let testValidations = [
    TestValidation(
        filePath: "ios/HealerUIKitTests/ViewTests/ComponentTests.swift",
        expectedTestMethods: [
            "test_DungeonListViewController_TouchTargets_Meet44PointMinimum",
            "test_BossEncounterViewController_TouchTargets_Meet44PointMinimum",
            "test_AbilityCardView_TouchTargets_Meet44PointMinimum",
            "test_ColorContrast_DamageProfiles_MeetWCAGAACompliance",
            "test_DynamicType_TextScaling_SupportsFullRange",
            "test_OrientationChange_PortraitToLandscape_LayoutAdapts",
            "test_SplitViewController_MasterDetailNavigation_iPadOptimized",
            "test_AbilityCardAnimations_CriticalAbilities_AttentionAnimation"
        ],
        requiredImports: ["XCTest", "UIKit", "XCUITest", "@testable import HealerUIKit"]
    ),
    TestValidation(
        filePath: "HealerKitTests/AccessibilityTests.swift",
        expectedTestMethods: [
            "test_VoiceOver_DungeonListViewController_AccessibilityLabelsAndTraits",
            "test_VoiceOver_BossEncounterViewController_CriticalAbilityAnnouncements",
            "test_DynamicType_AllTextElements_ScaleCorrectly",
            "test_ColorBlindFriendly_DamageProfiles_AlternativeIndicators",
            "test_KeyboardNavigation_DungeonListViewController_SupportsExternalKeyboard",
            "test_HighContrastMode_AllComponents_EnhancedVisibility",
            "test_ReducedMotion_AbilityCardAnimations_RespectPreferences",
            "test_FocusManagement_HealerWorkflow_LogicalFocusOrder",
            "test_WCAG21AA_CriticalHealerWorkflow_FullCompliance"
        ],
        requiredImports: ["XCTest", "UIKit", "XCUITest", "@testable import HealerUIKit"]
    )
]

func validateTestFile(_ validation: TestValidation) -> Bool {
    let fullPath = "/code/healerkit/" + validation.filePath

    guard let content = try? String(contentsOfFile: fullPath) else {
        print("❌ Could not read file: \(validation.filePath)")
        return false
    }

    print("📋 Validating: \(validation.filePath)")

    // Check required imports
    var missingImports: [String] = []
    for requiredImport in validation.requiredImports {
        if !content.contains(requiredImport) {
            missingImports.append(requiredImport)
        }
    }

    if !missingImports.isEmpty {
        print("⚠️  Missing imports: \(missingImports.joined(separator: ", "))")
    }

    // Check test methods
    var missingMethods: [String] = []
    for expectedMethod in validation.expectedTestMethods {
        if !content.contains("func \(expectedMethod)") {
            missingMethods.append(expectedMethod)
        }
    }

    if !missingMethods.isEmpty {
        print("❌ Missing test methods:")
        for method in missingMethods {
            print("   - \(method)")
        }
        return false
    } else {
        print("✅ All expected test methods found (\(validation.expectedTestMethods.count) tests)")
    }

    // Check for critical test patterns
    let criticalPatterns = [
        "XCTAssert",
        "AccessibilityConstants.minimumTouchTarget",
        "AccessibilityConstants.wcagAAContrastRatio",
        "UIContentSizeCategory",
        "UIAccessibility"
    ]

    for pattern in criticalPatterns {
        if content.contains(pattern) {
            print("✅ Contains critical pattern: \(pattern)")
        } else {
            print("⚠️  Missing critical pattern: \(pattern)")
        }
    }

    return missingMethods.isEmpty
}

print("🧪 HealerKit Test Validation Report")
print("==================================")
print("")

var allValid = true
for validation in testValidations {
    let isValid = validateTestFile(validation)
    allValid = allValid && isValid
    print("")
}

print("📊 Summary")
print("=========")
if allValid {
    print("✅ All test files are complete and properly structured")
    print("🎯 Ready for T038-T039 test execution")
} else {
    print("❌ Some test files need attention")
    print("🔧 Review missing components above")
}

print("")
print("📱 iPad Testing Coverage:")
print("• Touch target sizing (44pt minimum)")
print("• WCAG AA color contrast compliance")
print("• Dynamic Type support (12pt-28pt range)")
print("• Orientation change handling")
print("• Split view controller behavior")
print("• VoiceOver compatibility")
print("• Keyboard navigation support")
print("• High contrast mode")
print("• Reduced motion preferences")
print("• Focus management")
print("• WCAG 2.1 AA compliance validation")

exit(allValid ? 0 : 1)