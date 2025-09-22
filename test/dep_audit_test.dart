import 'dart:io';
import 'package:dep_audit/dep_audit.dart';
import 'package:test/test.dart';

void main() {
  group('PubspecParser', () {
    late Directory tempDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('dep_audit_test');
    });

    tearDown(() {
      tempDir.deleteSync(recursive: true);
    });

    test('correctly parses dependencies and dev_dependencies', () {
      const pubspecContent = '''
      name: test_project
      environment:
        sdk: '>=3.0.0 <4.0.0'
      dependencies:
        path: ^1.8.0
      dev_dependencies:
        test: ^1.20.0
      ''';
      final pubspecFile = File('${tempDir.path}/pubspec.yaml')
        ..writeAsStringSync(pubspecContent);

      final dependencies = parsePubspec(pubspecFile);

      expect(dependencies.length, 2);

      final pathDep = dependencies.firstWhere((d) => d.name == 'path');
      expect(pathDep.dev, isFalse);
      expect(pathDep.declaredConstraint, '^1.8.0');

      final testDep = dependencies.firstWhere((d) => d.name == 'test');
      expect(testDep.dev, isTrue);
      expect(testDep.declaredConstraint, '^1.20.0');
    });
  });
}
