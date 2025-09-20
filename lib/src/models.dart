
class DependencyInfo {
  final String name;
  final String? declaredConstraint;
  String? lockedVersion;
  final bool dev;

  DependencyInfo({
    required this.name,
    this.declaredConstraint,
    this.lockedVersion,
    this.dev = false,
  });
}

class PackageMetadata {
  final String name;
  final String latestVersion;
  final DateTime? updatedAt;
  final bool discontinued;

  PackageMetadata({
    required this.name,
    required this.latestVersion,
    this.updatedAt,
    this.discontinued = false,
  });

  bool get isStale {
    if (updatedAt == null) return false;
    return DateTime.now().difference(updatedAt!).inDays > 365;
  }
}

enum AuditStatus { ok, updateAvailable, unused, discontinued, stale, unknown }

class AuditResult {
  final DependencyInfo dependency;
  final PackageMetadata? metadata;
  final AuditStatus status;
  final String? message;

  AuditResult({
    required this.dependency,
    this.metadata,
    required this.status,
    this.message,
  });
}
