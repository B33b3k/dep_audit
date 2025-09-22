import 'scanner_web.dart' if (dart.library.io) 'scanner_io.dart'
    as scanner_impl;

export 'scanner_web.dart'
    show scanContentForPackageImports, scanContentsForPackageImports;

/// Scans a project directory for package imports in Dart source files.
///
/// This function searches through common Dart source directories
/// (lib, bin, test, example, integration_test) and extracts all
/// package imports to determine which dependencies are actually used.
///
/// Returns a [Set] of package names that are imported in the source code.
///
/// Note: This function requires dart:io and is not available on web/WASM platforms.
/// For web-compatible scanning, use scanContentForPackageImports instead.
Set<String> scanForPackageImports(dynamic root) {
  // This will only work on platforms with dart:io support
  return scanner_impl.scanForPackageImportsIO(root);
}
