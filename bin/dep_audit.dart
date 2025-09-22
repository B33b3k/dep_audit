import 'dart:io';
import 'package:args/args.dart';
import 'package:dep_audit/dep_audit.dart';

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption('path',
        abbr: 'p', defaultsTo: '.', help: 'Project path to audit.')
    ..addOption('format',
        abbr: 'f',
        defaultsTo: 'text',
        allowed: ['text', 'json'],
        help: 'Output format.')
    ..addMultiOption('ignore',
        help: 'Comma-separated list of packages to ignore.')
    ..addFlag('include-dev',
        defaultsTo: false, help: 'Include dev_dependencies in the audit.')
    ..addFlag('fix', defaultsTo: false, help: 'Automatically apply safe fixes.')
    ..addFlag('help',
        abbr: 'h', negatable: false, help: 'Displays this help message.');

  ArgResults argResults;
  try {
    argResults = parser.parse(arguments);
  } on FormatException catch (e) {
    stderr.writeln('Error parsing arguments: ${e.message}');
    stderr.writeln(parser.usage);
    exit(1);
  }

  if (argResults['help'] as bool) {
    print(
        'dep_audit - A dependency & package health auditor for Dart/Flutter.');
    print('');
    print(parser.usage);
    exit(0);
  }

  final options = AuditOptions(
    projectPath: argResults['path'] as String,
    format: argResults['format'] as String,
    includeDevDependencies: argResults['include-dev'] as bool,
    ignoredPackages: Set.from(argResults['ignore']),
    applyFixes: argResults['fix'] as bool,
  );

  try {
    await runAudit(options);
  } catch (e, st) {
    stderr.writeln('An unexpected error occurred: $e');
    stderr.writeln(st);
    exit(2);
  }
}
