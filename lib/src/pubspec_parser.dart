
import 'dart:io';
import 'package:yaml/yaml.dart';
import 'models.dart';

Map<String, dynamic> _loadYamlFile(File file) {
  try {
    final content = file.readAsStringSync();
    final yamlMap = loadYaml(content) as YamlMap;
    return Map<String, dynamic>.from(yamlMap.map((k, v) => MapEntry(k.toString(), v)));
  } catch (e) {
    throw Exception('Failed to parse YAML file: \${file.path}. Error: \$e');
  }
}

List<DependencyInfo> parsePubspec(File pubspec) {
  final map = _loadYamlFile(pubspec);
  final deps = <DependencyInfo>[];

  void addDeps(Map<dynamic, dynamic>? depMap, bool isDev) {
    if (depMap == null) return;
    depMap.forEach((key, value) {
      final constraint = value is String ? value : null;
      deps.add(DependencyInfo(name: key.toString(), declaredConstraint: constraint, dev: isDev));
    });
  }

  addDeps(map['dependencies'] as Map?, false);
  addDeps(map['dev_dependencies'] as Map?, true);
  return deps;
}

List<DependencyInfo> enrichDependenciesFromLockfile(List<DependencyInfo> deps, File lockfile) {
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
