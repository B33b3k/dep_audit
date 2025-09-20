
import 'dart:io';
import 'package:glob/glob.dart';
import 'package:glob/list_local_fs.dart';

/// Scans a project directory for package imports in Dart source files.
/// 
/// This function searches through common Dart source directories
/// (lib, bin, test, example, integration_test) and extracts all
/// package imports to determine which dependencies are actually used.
/// 
/// Returns a [Set] of package names that are imported in the source code.
/// 
/// Example:
/// ```dart
/// final usedPackages = scanForPackageImports(Directory('./my_project'));
/// print(usedPackages); // {'http', 'path', 'test', ...}
/// ```
Set<String> scanForPackageImports(Directory root) {
  final globs = [
    Glob('lib/**.dart'),
    Glob('bin/**.dart'),
    Glob('test/**.dart'),
    Glob('example/**.dart'),
    Glob('integration_test/**.dart'),
  ];

  final usedPackages = <String>{};
  final importRegex = RegExp(r'''package:([a-zA-Z0-9_]+)''');

  for (final g in globs) {
    for (final entity in g.listSync(root: root.path, followLinks: false)) {
      if (entity is File) {
        try {
          final content = (entity as File).readAsStringSync();
          for (final line in content.split('\n')) {
              if (line.trim().startsWith('import') || line.trim().startsWith('export')) {
                  final match = importRegex.firstMatch(line);
                  if (match != null) {
                      final packageName = match.group(1);
                      if (packageName != null) {
                          usedPackages.add(packageName);
                      }
                  }
              }
          }
        } catch (e) {
          // Ignore files that can't be read.
        }
      }
    }
  }
  return usedPackages;
}
