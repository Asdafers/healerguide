# HealerUIKit CLI Tools

Command-line interface for HealerUIKit performance, accessibility, and layout validation optimized for iPad Pro first-generation constraints.

## Installation

```bash
cd /path/to/healerkit/ios/HealerUIKit/CLI
swift build -c release
cp .build/release/healeruikit /usr/local/bin/
```

## Commands

### Performance Benchmarking

Test UI component rendering performance against 60fps targets:

```bash
# Benchmark ability card rendering
healeruikit benchmark --component ability-card --iterations 100

# Include memory usage analysis
healeruikit benchmark --component ability-card --iterations 100 --include-memory

# JSON output for CI/CD integration
healeruikit benchmark --component ability-card --iterations 100 --format json
```

**Components Available:**
- `ability-card` - AbilityCardView performance testing
- `dungeon-list` - DungeonListViewController performance
- `boss-encounter` - BossEncounterViewController performance

**Performance Targets:**
- Frame Rate: 60fps (16.67ms per frame)
- Touch Response: <100ms
- Memory Usage: <200MB peak on first-gen iPad Pro

### Layout Validation

Validate UI layouts for iPad Pro constraints:

```bash
# Basic layout validation
healeruikit validate-layouts --device ipad-pro-gen1

# Include touch target validation
healeruikit validate-layouts --device ipad-pro-gen1 --validate-touch-targets

# Test both orientations
healeruikit validate-layouts --device ipad-pro-gen1 --test-orientations

# JSON output
healeruikit validate-layouts --device ipad-pro-gen1 --format json
```

**iPad Pro Gen 1 Constraints:**
- Screen Size: 1024x768pt (2048x1536px at 264 PPI)
- Minimum Touch Target: 44x44pt
- iOS Version: 13.1+ compatibility
- Multitasking: Split View and Slide Over support

### Accessibility Audit

Generate accessibility compliance reports:

```bash
# Basic accessibility audit
healeruikit accessibility-audit

# Comprehensive testing
healeruikit accessibility-audit --test-voice-over --test-dynamic-type --test-high-contrast

# Save report to file
healeruikit accessibility-audit --output accessibility-report.json
```

**Standards Tested:**
- WCAG 2.1 AA compliance
- iOS Accessibility Guidelines
- VoiceOver navigation
- Dynamic Type scaling
- High Contrast mode support

### Color Contrast Testing

Test damage profile color schemes for WCAG compliance:

```bash
# Test WCAG AA compliance (4.5:1 ratio)
healeruikit test-colors --standard wcag-aa

# Test WCAG AAA compliance (7:1 ratio)
healeruikit test-colors --standard wcag-aaa

# Include high contrast mode testing
healeruikit test-colors --standard wcag-aa --test-high-contrast

# JSON output
healeruikit test-colors --standard wcag-aa --format json
```

**Damage Profiles Tested:**
- Critical (Red): Immediate action required
- High (Orange): Significant concern
- Moderate (Yellow): Notable but manageable
- Mechanic (Blue): Non-damage mechanic

## Output Formats

### Human-Readable (Default)

Formatted for terminal display with status indicators:
- ✅ PASS / ❌ FAIL status indicators
- 📊 Performance metrics with targets
- 💡 Actionable recommendations
- ⚠️ Issues with severity levels

### JSON Format

Structured data for CI/CD integration:
```bash
--format json
```

Perfect for:
- Automated testing pipelines
- Performance regression tracking
- Integration with monitoring tools
- Custom reporting dashboards

## Integration with HealerUIKit

The CLI tools integrate directly with HealerUIKit components:

### Performance Testing
- `AbilityCardView` rendering benchmarks
- `DungeonListViewController` scroll performance
- `BossEncounterViewController` layout complexity
- Memory usage on 4GB RAM constraint

### Layout Validation
- Auto Layout constraint validation
- Safe Area handling for iOS 13.1+
- Touch target size verification (44pt minimum)
- Multitasking Split View compatibility

### Accessibility Testing
- VoiceOver label and hint validation
- Dynamic Type font scaling (12pt-28pt range)
- Color contrast ratios for damage profiles
- Focus ordering for keyboard navigation

### Color Scheme Validation
- Healer damage profile color accuracy
- WCAG AA/AAA contrast compliance
- High contrast mode compatibility
- Color blindness accessibility

## Performance Targets

### First-Generation iPad Pro Specifications
- **Processor**: A9X chip
- **RAM**: 4GB
- **Screen**: 2048×1536 pixels (264 PPI)
- **iOS**: Maximum 13.1 support

### Target Metrics
- **Frame Rate**: 60fps sustained
- **Touch Response**: <100ms latency
- **Memory Usage**: <200MB app footprint
- **Battery Impact**: Minimal background CPU usage

## Example Workflows

### CI/CD Performance Testing
```bash
#!/bin/bash
# Performance regression testing
healeruikit benchmark --component ability-card --iterations 100 --format json > perf-results.json

# Check if performance meets targets
python check-performance.py perf-results.json

# Layout validation for iPad constraints
healeruikit validate-layouts --device ipad-pro-gen1 --format json > layout-results.json
```

### Accessibility Compliance Check
```bash
#!/bin/bash
# Full accessibility audit
healeruikit accessibility-audit \
  --test-voice-over \
  --test-dynamic-type \
  --test-high-contrast \
  --output accessibility-report.json

# Color contrast validation
healeruikit test-colors --standard wcag-aa --format json > color-contrast.json
```

### Pre-Release Validation
```bash
#!/bin/bash
echo "🔥 Running HealerUIKit validation suite..."

# Performance benchmarks
echo "📊 Performance testing..."
healeruikit benchmark --component ability-card --iterations 200

# Layout validation
echo "📱 Layout validation..."
healeruikit validate-layouts --device ipad-pro-gen1 --validate-touch-targets --test-orientations

# Accessibility audit
echo "♿ Accessibility audit..."
healeruikit accessibility-audit --test-voice-over --test-dynamic-type

# Color contrast check
echo "🎨 Color contrast testing..."
healeruikit test-colors --standard wcag-aa --test-high-contrast

echo "✅ Validation complete!"
```

## Troubleshooting

### Performance Issues
- **High render times**: Check view hierarchy complexity
- **Memory spikes**: Verify proper view controller lifecycle
- **Frame drops**: Profile with Instruments for bottlenecks

### Layout Problems
- **Touch target failures**: Increase button/control sizes to 44pt minimum
- **Orientation issues**: Test constraint priorities and multipliers
- **Safe area problems**: Update to iOS 13+ safe area APIs

### Accessibility Failures
- **VoiceOver issues**: Add accessibility labels and hints
- **Contrast failures**: Adjust color schemes or add alternative indicators
- **Dynamic Type problems**: Use preferredFont(forTextStyle:)

### Common Error Messages

**"Performance below 60fps target"**
- Optimize render pipeline
- Reduce view complexity
- Profile with Instruments

**"Touch target too small"**
- Increase control size to ≥44pt
- Add invisible touch area expansion
- Test with accessibility inspector

**"Color contrast below WCAG standards"**
- Darken text colors
- Lighten background colors
- Add alternative visual indicators

## Development

### Building from Source
```bash
git clone <repository>
cd ios/HealerUIKit/CLI
swift build
```

### Running Tests
```bash
swift test
```

### Contributing
1. Follow Swift coding standards
2. Add test coverage for new features
3. Validate against iPad Pro first-gen constraints
4. Document CLI command changes

## Constitutional Requirements

This CLI implementation fulfills the constitutional requirement that "Each library must have functional CLI interfaces" for the HealerUIKit library.

### CLI Interface Contract Compliance
- ✅ Performance benchmarking tools
- ✅ Layout constraint validation
- ✅ Accessibility compliance testing
- ✅ Color contrast verification
- ✅ JSON and human-readable output formats
- ✅ Integration with iPad Pro first-gen specifications
- ✅ Healer workflow optimization validation