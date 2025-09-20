
import 'dart:convert';
import 'models.dart';

String formatReport(List<AuditResult> results, String format) {
  switch (format) {
    case 'json':
      return _formatJsonReport(results);
    case 'text':
    default:
      return _formatConsoleReport(results);
  }
}

String _formatConsoleReport(List<AuditResult> results) {
  final buffer = StringBuffer();
  buffer.writeln('\n--- Dependency Audit Report ---');

  if (results.isEmpty) {
    buffer.writeln('No dependencies to audit.');
    return buffer.toString();
  }

  results.sort((a, b) => a.dependency.name.compareTo(b.dependency.name));

  for (final r in results) {
    final statusSymbol = _getStatusSymbol(r.status);
    final name = r.dependency.name.padRight(25);
    final current = (r.dependency.lockedVersion ?? '-').padRight(12);
    final latest = (r.metadata?.latestVersion ?? '-').padRight(12);
    final statusText = r.status.toString().split('.').last;

    buffer.writeln('$statusSymbol $name Current: $current Latest: $latest Status: $statusText');
    if (r.message != null) {
      buffer.writeln('  └─ ${r.message}');
    }
  }
  return buffer.toString();
}

String _getStatusSymbol(AuditStatus status) {
  switch (status) {
    case AuditStatus.ok: return '✅';
    case AuditStatus.updateAvailable: return '⬆️ ';
    case AuditStatus.unused: return '🗑️ ';
    case AuditStatus.discontinued: return '⚠️ ';
    case AuditStatus.stale: return '⏳';
    case AuditStatus.unknown: return '❓';
  }
}

String _formatJsonReport(List<AuditResult> results) {
  final reportData = {
    'results': results.map((r) => {
      'package': r.dependency.name,
      'currentVersion': r.dependency.lockedVersion,
      'latestVersion': r.metadata?.latestVersion,
      'status': r.status.toString().split('.').last,
      'message': r.message,
    }).toList(),
  };
  return JsonEncoder.withIndent('  ').convert(reportData);
}
