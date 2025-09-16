#!/bin/bash

# Script to run iOS Content Validation Tests
# Can be used locally or in CI environments

set -euo pipefail

# Configuration
PROJECT_PATH="HealerKit.xcodeproj"
SCHEME="DungeonKit"
DESTINATION="platform=iOS Simulator,name=iPhone 15,OS=17.2"
CONFIGURATION="Debug"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."

    # Check if we're in the right directory
    if [ ! -f "$PROJECT_PATH" ]; then
        print_error "Xcode project not found. Please run this script from the ios directory."
        exit 1
    fi

    # Check for xcodebuild
    if ! command -v xcodebuild &> /dev/null; then
        print_error "xcodebuild not found. Please install Xcode."
        exit 1
    fi

    # Check Xcode version
    XCODE_VERSION=$(xcodebuild -version | head -n1 | cut -d' ' -f2)
    print_status "Using Xcode version: $XCODE_VERSION"

    print_success "Prerequisites check passed"
}

# Function to build the project
build_project() {
    print_status "Building DungeonKit framework..."

    xcodebuild build \
        -project "$PROJECT_PATH" \
        -scheme "$SCHEME" \
        -destination "$DESTINATION" \
        -configuration "$CONFIGURATION" \
        CODE_SIGNING_ALLOWED=NO \
        -quiet

    if [ $? -eq 0 ]; then
        print_success "Build completed successfully"
    else
        print_error "Build failed"
        exit 1
    fi
}

# Function to run specific test suite
run_test_suite() {
    local test_suite=$1
    local test_name=$2

    print_status "Running $test_name..."

    xcodebuild test \
        -project "$PROJECT_PATH" \
        -scheme "$SCHEME" \
        -destination "$DESTINATION" \
        -only-testing:"DungeonKitTests/$test_suite" \
        -configuration "$CONFIGURATION" \
        CODE_SIGNING_ALLOWED=NO \
        -quiet

    if [ $? -eq 0 ]; then
        print_success "$test_name passed"
        return 0
    else
        print_error "$test_name failed"
        return 1
    fi
}

# Function to run all content validation tests
run_content_validation_tests() {
    print_status "Running Content Validation Tests..."

    local failed_tests=0

    # Define test suites
    declare -A test_suites
    test_suites["DungeonContentValidationTests"]="Dungeon Content Validation"
    test_suites["BossEncounterContentValidationTests"]="Boss Encounter Content Validation"
    test_suites["DataIntegrityValidationTests"]="Data Integrity Validation"

    # Run each test suite
    for suite in "${!test_suites[@]}"; do
        if ! run_test_suite "$suite" "${test_suites[$suite]}"; then
            ((failed_tests++))
        fi
        echo
    done

    # Summary
    if [ $failed_tests -eq 0 ]; then
        print_success "All content validation tests passed! ✅"
        return 0
    else
        print_error "$failed_tests test suite(s) failed ❌"
        return 1
    fi
}

# Function to generate test report
generate_test_report() {
    print_status "Generating test report..."

    # Create results directory
    mkdir -p test-reports

    # Run tests with detailed output
    xcodebuild test \
        -project "$PROJECT_PATH" \
        -scheme "$SCHEME" \
        -destination "$DESTINATION" \
        -only-testing:DungeonKitTests/DungeonContentValidationTests \
        -only-testing:DungeonKitTests/BossEncounterContentValidationTests \
        -only-testing:DungeonKitTests/DataIntegrityValidationTests \
        -configuration "$CONFIGURATION" \
        CODE_SIGNING_ALLOWED=NO \
        -resultBundlePath "test-reports/ContentValidationTests.xcresult" \
        > "test-reports/test-output.log" 2>&1

    if [ -d "test-reports/ContentValidationTests.xcresult" ]; then
        print_success "Test results saved to test-reports/ContentValidationTests.xcresult"

        # Extract summary if xcresulttool is available
        if command -v xcresulttool &> /dev/null; then
            xcresulttool get --format json --path "test-reports/ContentValidationTests.xcresult" > "test-reports/results.json"
            print_success "JSON results saved to test-reports/results.json"
        fi
    fi
}

# Main execution
main() {
    echo "🧪 iOS Content Validation Test Runner"
    echo "====================================="

    # Parse command line arguments
    local GENERATE_REPORT=false
    local BUILD_ONLY=false

    while [[ $# -gt 0 ]]; do
        case $1 in
            --report)
                GENERATE_REPORT=true
                shift
                ;;
            --build-only)
                BUILD_ONLY=true
                shift
                ;;
            --help)
                echo "Usage: $0 [--report] [--build-only] [--help]"
                echo "  --report      Generate detailed test report"
                echo "  --build-only  Only build, don't run tests"
                echo "  --help        Show this help message"
                exit 0
                ;;
            *)
                print_error "Unknown option $1"
                exit 1
                ;;
        esac
    done

    # Run steps
    check_prerequisites
    build_project

    if [ "$BUILD_ONLY" = true ]; then
        print_success "Build-only mode completed"
        exit 0
    fi

    if [ "$GENERATE_REPORT" = true ]; then
        generate_test_report
    else
        run_content_validation_tests
    fi

    local exit_code=$?

    if [ $exit_code -eq 0 ]; then
        print_success "Content validation completed successfully! 🎉"
    else
        print_error "Content validation failed 💥"
    fi

    exit $exit_code
}

# Run main function with all arguments
main "$@"