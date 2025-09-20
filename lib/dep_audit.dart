
/// A lightweight dependency & package health auditor for Dart/Flutter projects.
/// 
/// This library provides tools to audit your project dependencies for:
/// - Outdated packages that have newer versions available
/// - Unused dependencies that are declared but not imported
/// - Discontinued or stale packages that may need attention
/// - Automatic fixing capabilities to update and clean dependencies
/// 
/// ## Usage
/// 
/// ```dart
/// import 'package:dep_audit/dep_audit.dart';
/// 
/// // Parse dependencies from pubspec.yaml
/// final dependencies = parsePubspec(pubspecFile);
/// 
/// // Scan for package imports in source code
/// final usedPackages = scanForPackageImports(projectDirectory);
/// 
/// // Run a complete audit
/// await runAudit(AuditOptions(projectPath: '.'));
/// ```
library dep_audit;

export 'src/cli/runner.dart';
export 'src/models.dart';
export 'src/pubspec_parser.dart';
export 'src/scanner.dart';
export 'src/pubdev_client.dart';
export 'src/reporter.dart';
