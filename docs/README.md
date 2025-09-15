# HealerKit Documentation

This directory contains comprehensive documentation for the HealerKit iPad application and its supporting libraries.

## Documentation Structure

### API Documentation
- **[Library APIs](./api/README.md)** - Complete interface documentation for all libraries
  - [DungeonKit API](./api/DungeonKit.md) - Dungeon and boss encounter data management
  - [AbilityKit API](./api/AbilityKit.md) - Boss ability classification and damage analysis
  - [HealerUIKit API](./api/HealerUIKit.md) - iPad-optimized UI components

### Usage Guides
- **[iPad Usage Guidelines](./usage/ipad-guidelines.md)** - iPad-specific development and usage patterns
- **[Healer Workflow Guide](./usage/healer-workflow.md)** - Color coding, priorities, and healer-focused design
- **[CLI Tools Guide](./usage/cli-tools.md)** - Command-line interfaces for all libraries

### Technical Guides
- **[Performance Optimization](./technical/performance-optimization.md)** - First-gen iPad Pro optimization strategies
- **[Accessibility Guide](./technical/accessibility.md)** - Compliance and testing procedures
- **[Data Structure Guide](./technical/data-structure.md)** - Season data format and content guidelines

## Quick Start

For immediate development needs:

1. **API Reference**: Start with [Library APIs](./api/README.md) for interface contracts
2. **iPad Development**: See [iPad Usage Guidelines](./usage/ipad-guidelines.md) for platform-specific patterns
3. **Performance**: Review [Performance Optimization](./technical/performance-optimization.md) for first-gen iPad Pro requirements
4. **Testing**: Check [CLI Tools Guide](./usage/cli-tools.md) for validation and testing commands

## Constitutional Requirements

This documentation reflects the project's constitutional requirements:

- **Library-First Architecture**: Each feature as standalone Swift framework
- **Offline-First**: No network dependencies during gameplay
- **Performance-Optimized**: 60fps target on first-gen iPad Pro
- **Test-Driven Development**: Comprehensive testing with CLI validation tools
- **Healer-Focused**: Content specifically curated for Mythic+ healers

## Target Platform

- **Device**: First-generation iPad Pro
- **iOS Version**: iOS 13.1+ (maximum supported)
- **Performance Target**: 60fps rendering, <3s data load times
- **Memory Constraint**: Optimized for 4GB RAM limitation