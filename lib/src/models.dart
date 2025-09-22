/// Represents information about a dependency declared in pubspec.yaml.
///
/// Contains details about the package name, version constraints,
/// locked version, and whether it's a development dependency.
class DependencyInfo {
  /// The name of the package.
  final String name;

  /// The version constraint declared in pubspec.yaml (e.g., '^1.0.0').
  final String? declaredConstraint;

  /// The actual locked version from pubspec.lock.
  String? lockedVersion;

  /// Whether this is a development dependency.
  final bool dev;

  /// Creates a new [DependencyInfo] instance.
  DependencyInfo({
    required this.name,
    this.declaredConstraint,
    this.lockedVersion,
    this.dev = false,
  });
}

/// Metadata about a package fetched from pub.dev.
///
/// Contains information about the latest version, update timestamp,
/// and whether the package has been discontinued.
class PackageMetadata {
  /// The name of the package.
  final String name;

  /// The latest available version on pub.dev.
  final String latestVersion;

  /// When the package was last updated.
  final DateTime? updatedAt;

  /// Whether the package has been marked as discontinued.
  final bool discontinued;

  /// Creates a new [PackageMetadata] instance.
  PackageMetadata({
    required this.name,
    required this.latestVersion,
    this.updatedAt,
    this.discontinued = false,
  });

  /// Returns true if the package hasn't been updated in over a year.
  bool get isStale {
    if (updatedAt == null) return false;
    return DateTime.now().difference(updatedAt!).inDays > 365;
  }
}

/// The status of a dependency after auditing.
enum AuditStatus {
  /// Package is up to date and in use.
  ok,

  /// A newer version is available.
  updateAvailable,

  /// Package is declared but not imported in code.
  unused,

  /// Package has been marked as discontinued.
  discontinued,

  /// Package hasn't been updated in over a year.
  stale,

  /// Unable to determine status (e.g., network error).
  unknown
}

/// The result of auditing a single dependency.
///
/// Contains the dependency information, package metadata from pub.dev,
/// the audit status, and any additional messages.
class AuditResult {
  /// The dependency that was audited.
  final DependencyInfo dependency;

  /// Metadata fetched from pub.dev (if available).
  final PackageMetadata? metadata;

  /// The status determined by the audit.
  final AuditStatus status;

  /// Additional message explaining the status.
  final String? message;

  /// Creates a new [AuditResult] instance.
  AuditResult({
    required this.dependency,
    this.metadata,
    required this.status,
    this.message,
  });
}
