/// Scans content for package imports.
///
/// This is a web-compatible version that can analyze Dart source code
/// content that's provided as strings instead of reading from the file system.
///
/// Returns a [Set] of package names that are imported in the source code.
///
/// Example:
/// ```dart
/// final content = 'import "package:http/http.dart";';
/// final usedPackages = scanContentForPackageImports(content);
/// print(usedPackages); // {'http'}
/// ```
Set<String> scanContentForPackageImports(String content) {
  final usedPackages = <String>{};
  final importRegex = RegExp(r'''package:([a-zA-Z0-9_]+)''');

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

  return usedPackages;
}

/// Scans multiple content strings for package imports.
///
/// This function takes a list of Dart source code content and extracts all
/// package imports to determine which dependencies are actually used.
///
/// Returns a [Set] of package names that are imported across all content.
///
/// Example:
/// ```dart
/// final contents = ['import "package:http/http.dart";', 'import "package:path/path.dart";'];
/// final usedPackages = scanContentsForPackageImports(contents);
/// print(usedPackages); // {'http', 'path'}
/// ```
Set<String> scanContentsForPackageImports(Iterable<String> contents) {
  final usedPackages = <String>{};

  for (final content in contents) {
    usedPackages.addAll(scanContentForPackageImports(content));
  }

  return usedPackages;
}

/// Stub implementation for web platforms - throws UnsupportedError.
///
/// File system scanning is not supported on web/WASM platforms.
/// Use [scanContentForPackageImports] or [scanContentsForPackageImports] instead.
Set<String> scanForPackageImportsIO(dynamic root) {
  throw UnsupportedError(
      'File system scanning is not supported on web/WASM platforms. '
      'Use scanContentForPackageImports or scanContentsForPackageImports instead.');
}
