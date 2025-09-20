# dep_audit Example

This directory contains examples demonstrating how to use the `dep_audit` package programmatically.

## Running the Example

To run the example:

```bash
cd example
dart run dep_audit_example.dart
```

## What the Example Shows

The example demonstrates three main use cases:

### 1. Parsing Dependencies
```dart
final dependencies = parsePubspec(pubspecFile);
```
Shows how to parse `pubspec.yaml` and extract dependency information.

### 2. Scanning for Imports
```dart
final usedPackages = scanForPackageImports(projectDirectory);
```
Demonstrates scanning source code to find which packages are actually imported.

### 3. Running a Complete Audit
```dart
final options = AuditOptions(
  projectPath: '..',
  includeDevDependencies: true,
  applyFixes: false,
);
await runAudit(options);
```
Shows how to configure and run a complete dependency audit.

## CLI Usage

For command-line usage, you can also run:

```bash
# Basic audit
dart run dep_audit

# Include dev dependencies
dart run dep_audit --include-dev

# Auto-fix issues
dart run dep_audit --fix

# JSON output
dart run dep_audit --format json

# Get help
dart run dep_audit --help
```