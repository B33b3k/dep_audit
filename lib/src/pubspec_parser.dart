import 'dart:io';
import 'package:yaml/yaml.dart';
import 'models.dart';

Map<String, dynamic> _loadYamlFile(File file) {
  try {
    final content = file.readAsStringSync();
    final yamlMap = loadYaml(content) as YamlMap;
    return Map<String, dynamic>.from(
        yamlMap.map((k, v) => MapEntry(k.toString(), v)));
  } catch (e) {
    throw Exception('Failed to parse YAML file: ${file.path}. Error: $e');
  }
}

/// Parses a pubspec.yaml file and extracts dependency information.
///
/// Reads both regular dependencies and dev_dependencies from the pubspec.yaml
/// file and returns a list of [DependencyInfo] objects.
///
/// Throws [Exception] if the file cannot be read or parsed.
///
/// Example:
/// ```dart
/// final pubspecFile = File('pubspec.yaml');
/// final dependencies = parsePubspec(pubspecFile);
/// ```
List<DependencyInfo> parsePubspec(File pubspec) {
  final map = _loadYamlFile(pubspec);
  final deps = <DependencyInfo>[];

  void addDeps(Map<dynamic, dynamic>? depMap, bool isDev) {
    if (depMap == null) return;
    depMap.forEach((key, value) {
      final constraint = value is String ? value : null;
      deps.add(DependencyInfo(
          name: key.toString(), declaredConstraint: constraint, dev: isDev));
    });
  }

  addDeps(map['dependencies'] as Map?, false);
  addDeps(map['dev_dependencies'] as Map?, true);
  return deps;
}

/// Enriches dependency information with locked versions from pubspec.lock.
///
/// Takes a list of dependencies from pubspec.yaml and adds the actual
/// locked versions by reading from the pubspec.lock file.
///
/// Returns the updated list of [DependencyInfo] with locked versions populated.
///
/// Example:
/// ```dart
/// final deps = parsePubspec(pubspecFile);
/// final enrichedDeps = enrichDependenciesFromLockfile(deps, lockFile);
/// ```
List<DependencyInfo> enrichDependenciesFromLockfile(
    List<DependencyInfo> deps, File lockfile) {
  final lockMap = _loadYamlFile(lockfile);
  final packages = lockMap['packages'] as Map?;
  if (packages == null) return deps;

  for (final dep in deps) {
    if (packages.containsKey(dep.name)) {
      final packageData = packages[dep.name] as Map?;
      dep.lockedVersion = packageData?['version'] as String?;
    }
  }
  return deps;
}
