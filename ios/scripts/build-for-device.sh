#!/bin/bash

# Script to build HealerKit iOS app for device testing
# Can be used locally to create IPA for iPad installation

set -euo pipefail

# Configuration
PROJECT_PATH="HealerKit.xcodeproj"
SCHEME="HealerKit"
CONFIGURATION="Release"
BUNDLE_ID="com.healerkit.app"

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

# Function to clean build directory
clean_build() {
    print_status "Cleaning previous builds..."

    if [ -d "build" ]; then
        rm -rf build
    fi

    xcodebuild clean \
        -project "$PROJECT_PATH" \
        -scheme "$SCHEME" \
        -configuration "$CONFIGURATION" \
        -quiet

    print_success "Build directory cleaned"
}

# Function to build and archive the app
build_and_archive() {
    print_status "Building and archiving HealerKit for iOS device..."

    xcodebuild archive \
        -project "$PROJECT_PATH" \
        -scheme "$SCHEME" \
        -configuration "$CONFIGURATION" \
        -destination 'generic/platform=iOS' \
        -archivePath "build/HealerKit.xcarchive" \
        CODE_SIGNING_ALLOWED=NO \
        CODE_SIGNING_REQUIRED=NO \
        PRODUCT_BUNDLE_IDENTIFIER="$BUNDLE_ID" \
        -quiet

    if [ $? -eq 0 ]; then
        print_success "Archive created successfully"
    else
        print_error "Archive creation failed"
        exit 1
    fi
}

# Function to create export options
create_export_options() {
    print_status "Creating export options..."

    cat > build/ExportOptions.plist << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>development</string>
    <key>uploadBitcode</key>
    <false/>
    <key>uploadSymbols</key>
    <false/>
    <key>compileBitcode</key>
    <false/>
    <key>signingStyle</key>
    <string>manual</string>
    <key>stripSwiftSymbols</key>
    <true/>
    <key>thinning</key>
    <string>&lt;none&gt;</string>
</dict>
</plist>
EOF

    print_success "Export options created"
}

# Function to export IPA
export_ipa() {
    print_status "Exporting IPA from archive..."

    # Try standard export first
    if xcodebuild -exportArchive \
        -archivePath "build/HealerKit.xcarchive" \
        -exportPath "build/export" \
        -exportOptionsPlist "build/ExportOptions.plist" \
        -allowProvisioningUpdates 2>/dev/null; then

        print_success "IPA exported successfully"
        return 0
    fi

    print_warning "Standard export failed, creating IPA manually..."

    # Manual IPA creation
    mkdir -p "build/manual_export/Payload"

    # Find and copy the app bundle
    APP_PATH=$(find "build/HealerKit.xcarchive" -name "*.app" | head -n1)

    if [ -z "$APP_PATH" ]; then
        print_error "Could not find app bundle in archive"
        exit 1
    fi

    cp -R "$APP_PATH" "build/manual_export/Payload/"

    # Create IPA
    cd "build/manual_export"
    zip -r -q "../HealerKit-unsigned.ipa" Payload/
    cd ../..

    # Move to export directory
    mkdir -p "build/export"
    mv "build/HealerKit-unsigned.ipa" "build/export/"

    print_success "Manual IPA creation completed"
}

# Function to generate installation instructions
generate_instructions() {
    print_status "Generating installation instructions..."

    cat > build/export/INSTALL_INSTRUCTIONS.txt << EOF
HealerKit iPad Installation Instructions
=======================================

Build Date: $(date)
Configuration: $CONFIGURATION
Bundle ID: $BUNDLE_ID

INSTALLATION METHODS:
====================

Method 1: Using Xcode (Recommended)
-----------------------------------
1. Connect your iPad to your Mac via USB
2. Open Xcode
3. Go to Window → Devices and Simulators
4. Select your iPad from the left sidebar
5. Drag and drop the IPA file onto the "Installed Apps" section
6. The app should install automatically

Method 2: Using Third-Party Tools
---------------------------------
- 3uTools: Drag IPA to the Apps section
- iMazing: Use the App Management feature
- Sideloadly: Follow the sideloading process

Method 3: Re-signing (For Distribution)
--------------------------------------
1. Use iOS App Signer or similar tool
2. Sign with your Apple Developer certificate
3. Install the signed IPA using Method 1 or 2

REQUIREMENTS:
============
- iPad running iOS 13.1 or later
- USB connection to Mac (for Xcode method)
- For unsigned installation: Development access or jailbroken device
- For signed installation: Valid Apple Developer account

TROUBLESHOOTING:
===============
- If "App installation failed", try re-signing the IPA
- Check iPad iOS version compatibility
- Ensure iPad is in Developer Mode (iOS 16+)
- Trust developer certificate in Settings → General → VPN & Device Management

FEATURES:
=========
✓ Complete War Within Season 1 content
✓ 8 dungeons with detailed boss encounters
✓ Healer-specific positioning and cooldown guidance
✓ Color-coded ability priority system
✓ Offline functionality for raid usage
✓ Optimized for iPad Pro form factor

For support, check the project repository or GitHub issues.
EOF

    print_success "Installation instructions created"
}

# Function to display summary
show_summary() {
    echo ""
    echo "🎉 HealerKit iOS Build Complete!"
    echo "=================================="
    echo ""
    echo "📦 Build Artifacts:"

    if [ -f "build/export/HealerKit.ipa" ]; then
        echo "   ✅ HealerKit.ipa (signed)"
    fi

    if [ -f "build/export/HealerKit-unsigned.ipa" ]; then
        echo "   ✅ HealerKit-unsigned.ipa"
    fi

    echo "   ✅ Installation instructions"
    echo "   ✅ Xcode archive"
    echo ""
    echo "📍 Location: $(pwd)/build/export/"
    echo ""
    echo "📱 Ready for iPad installation!"
    echo "   See INSTALL_INSTRUCTIONS.txt for detailed setup steps."
    echo ""
}

# Main execution
main() {
    echo "🛠️  HealerKit iOS App Builder"
    echo "============================="

    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --debug)
                CONFIGURATION="Debug"
                shift
                ;;
            --release)
                CONFIGURATION="Release"
                shift
                ;;
            --help)
                echo "Usage: $0 [--debug|--release] [--help]"
                echo "  --debug     Build in Debug configuration"
                echo "  --release   Build in Release configuration (default)"
                echo "  --help      Show this help message"
                exit 0
                ;;
            *)
                print_error "Unknown option $1"
                exit 1
                ;;
        esac
    done

    print_status "Building in $CONFIGURATION configuration"

    # Execute build steps
    check_prerequisites
    clean_build
    build_and_archive
    create_export_options
    export_ipa
    generate_instructions
    show_summary

    print_success "Build process completed successfully! 🚀"
}

# Run main function with all arguments
main "$@"