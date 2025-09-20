/// Example demonstrating how to use dep_audit programmatically.
/// 
/// This example shows how to:
/// 1. Parse dependencies from a pubspec.yaml file
/// 2. Scan source code for package imports
/// 3. Run a complete audit with options
/// 4. Format and display results

import 'dart:io';
import 'package:dep_audit/dep_audit.dart';

Future<void> main() async {
  print('🔍 Running dep_audit example...\n');

  // Example 1: Parse dependencies from pubspec.yaml
  await _parseExample();
  
  // Example 2: Scan for package imports
  await _scanExample();
  
  // Example 3: Run a complete audit
  await _auditExample();
}

/// Example of parsing dependencies from pubspec.yaml
Future<void> _parseExample() async {
  print('📄 Example 1: Parsing pubspec.yaml');
  
  final pubspecFile = File('../pubspec.yaml');
  if (!pubspecFile.existsSync()) {
    print('❌ pubspec.yaml not found in parent directory');
    return;
  }
  
  try {
    final dependencies = parsePubspec(pubspecFile);
    print('✅ Found ${dependencies.length} dependencies:');
    
    for (final dep in dependencies.take(3)) {
      final type = dep.dev ? '(dev)' : '';
      print('   • ${dep.name}: ${dep.declaredConstraint ?? 'any'} $type');
    }
    
    if (dependencies.length > 3) {
      print('   ... and ${dependencies.length - 3} more');
    }
  } catch (e) {
    print('❌ Error parsing pubspec.yaml: $e');
  }
  
  print('');
}

/// Example of scanning for package imports
Future<void> _scanExample() async {
  print('🔎 Example 2: Scanning for package imports');
  
  final projectDir = Directory('..');
  if (!projectDir.existsSync()) {
    print('❌ Project directory not found');
    return;
  }
  
  try {
    final usedPackages = scanForPackageImports(projectDir);
    print('✅ Found ${usedPackages.length} imported packages:');
    
    final sortedPackages = usedPackages.toList()..sort();
    for (final package in sortedPackages.take(5)) {
      print('   • $package');
    }
    
    if (sortedPackages.length > 5) {
      print('   ... and ${sortedPackages.length - 5} more');
    }
  } catch (e) {
    print('❌ Error scanning imports: $e');
  }
  
  print('');
}

/// Example of running a complete audit
Future<void> _auditExample() async {
  print('🔧 Example 3: Running complete audit');
  
  try {
    // Configure audit options
    final options = AuditOptions(
      projectPath: '..',
      format: 'text',
      includeDevDependencies: true,
      ignoredPackages: {'example_package'}, // Packages to ignore
      applyFixes: false, // Set to true to automatically fix issues
    );
    
    print('⚙️  Audit configuration:');
    print('   • Project path: ${options.projectPath}');
    print('   • Format: ${options.format}');
    print('   • Include dev dependencies: ${options.includeDevDependencies}');
    print('   • Apply fixes: ${options.applyFixes}');
    print('');
    
    // Run the audit
    await runAudit(options);
    
  } catch (e) {
    print('❌ Error running audit: $e');
  }
}