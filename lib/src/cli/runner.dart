
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:pub_semver/pub_semver.dart';

import '../models.dart';
import '../pubdev_client.dart';
import '../pubspec_parser.dart';
import '../reporter.dart';
import '../scanner.dart';

/// Configuration options for running a dependency audit.
/// 
/// Controls various aspects of the audit process including which
/// dependencies to include, output format, and whether to apply fixes.
class AuditOptions {
  /// The path to the project directory to audit.
  final String projectPath;
  
  /// The output format for the report ('text' or 'json').
  final String format;
  
  /// Whether to include dev_dependencies in the audit.
  final bool includeDevDependencies;
  
  /// Set of package names to ignore during the audit.
  final Set<String> ignoredPackages;
  
  /// Whether to automatically apply safe fixes.
  final bool applyFixes;

  /// Creates a new [AuditOptions] instance.
  AuditOptions({
    required this.projectPath,
    this.format = 'text',
    this.includeDevDependencies = false,
    this.ignoredPackages = const {},
    this.applyFixes = false,
  });
}

/// Runs a comprehensive dependency audit on the specified project.
/// 
/// This function performs the main audit logic:
/// 1. Parses pubspec.yaml and pubspec.lock
/// 2. Scans source code for package imports
/// 3. Fetches metadata from pub.dev
/// 4. Analyzes each dependency for issues
/// 5. Optionally applies automatic fixes
/// 
/// Throws [Exception] if the project directory or pubspec.yaml is not found.
Future<void> runAudit(AuditOptions options) async {
  final projectDir = Directory(options.projectPath);
  if (!projectDir.existsSync()) {
    throw Exception('Project directory not found: ${options.projectPath}');
  }

  final pubspecFile = File(p.join(projectDir.path, 'pubspec.yaml'));
  final lockFile = File(p.join(projectDir.path, 'pubspec.lock'));

  if (!pubspecFile.existsSync()) {
    throw Exception('pubspec.yaml not found in ${projectDir.path}');
  }

  var dependencies = parsePubspec(pubspecFile);
  if (lockFile.existsSync()) {
    dependencies = enrichDependenciesFromLockfile(dependencies, lockFile);
  }

  final usedPackages = scanForPackageImports(projectDir);
  final client = PubDevClient();
  final results = <AuditResult>[];

  print('Auditing dependencies...');

  for (final dep in dependencies) {
    if (options.ignoredPackages.contains(dep.name)) continue;
    if (dep.dev && !options.includeDevDependencies) continue;

    final metadata = await client.fetchPackageMetadata(dep.name);
    final isUsed = usedPackages.contains(dep.name) || dep.name == 'flutter';

    AuditStatus status = AuditStatus.ok;
    String? message;

    if (!isUsed) {
      status = AuditStatus.unused;
      message = 'Package is declared but not imported in the project.';
    } else if (metadata != null) {
      if (metadata.discontinued) {
        status = AuditStatus.discontinued;
        message = 'Package is marked as discontinued on pub.dev.';
      } else if (metadata.isStale) {
        status = AuditStatus.stale;
        message = 'Package has not been updated in over a year.';
      } else if (dep.lockedVersion != null) {
        try {
          final current = Version.parse(dep.lockedVersion!);
          final latest = Version.parse(metadata.latestVersion);
          if (latest > current) {
            status = AuditStatus.updateAvailable;
            message = 'Update available: \${metadata.latestVersion}';
          }
        } catch (e) {
           message = 'Could not compare versions (\${dep.lockedVersion} vs \${metadata.latestVersion})';
           status = AuditStatus.unknown;
        }
      }
    } else {
        status = AuditStatus.unknown;
        message = 'Could not fetch package metadata from pub.dev.';
    }

    results.add(AuditResult(
      dependency: dep,
      metadata: metadata,
      status: status,
      message: message,
    ));
  }

  client.close();

  final report = formatReport(results, options.format);
  print(report);

  // Apply fixes if requested
  if (options.applyFixes) {
    await _applyFixes(results, projectDir);
  }
}

Future<void> _applyFixes(List<AuditResult> results, Directory projectDir) async {
  final fixableResults = results.where((r) => 
    r.status == AuditStatus.unused || r.status == AuditStatus.updateAvailable
  ).toList();

  if (fixableResults.isEmpty) {
    print('\n✅ No fixes needed - all dependencies are up to date and in use.');
    return;
  }

  print('\n🔧 Applying fixes...');

  final unusedPackages = results
      .where((r) => r.status == AuditStatus.unused)
      .map((r) => r.dependency.name)
      .toList();

  final packagesToUpdate = results
      .where((r) => r.status == AuditStatus.updateAvailable)
      .map((r) => r.dependency.name)
      .toList();

  // Remove unused packages
  if (unusedPackages.isNotEmpty) {
    print('📦 Removing unused packages: ${unusedPackages.join(', ')}');
    for (final package in unusedPackages) {
      final result = await Process.run(
        'dart',
        ['pub', 'remove', package],
        workingDirectory: projectDir.path,
      );
      if (result.exitCode == 0) {
        print('   ✅ Removed $package');
      } else {
        print('   ❌ Failed to remove $package: ${result.stderr}');
      }
    }
  }

  // Update outdated packages
  if (packagesToUpdate.isNotEmpty) {
    print('⬆️  Updating outdated packages: ${packagesToUpdate.join(', ')}');
    final result = await Process.run(
      'dart',
      ['pub', 'upgrade', ...packagesToUpdate],
      workingDirectory: projectDir.path,
    );
    if (result.exitCode == 0) {
      print('   ✅ Successfully updated packages');
    } else {
      print('   ❌ Failed to update packages: ${result.stderr}');
    }
  }

  print('\n🎉 Auto-fix complete! Run dep_audit again to verify the changes.');
}
