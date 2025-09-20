
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models.dart';

/// HTTP client for fetching package metadata from pub.dev.
/// 
/// Provides methods to retrieve package information including latest versions,
/// publication dates, and discontinuation status from the pub.dev API.
class PubDevClient {
  final http.Client _client;
  final String _baseUrl = 'https://pub.dev/api/packages/';

  /// Creates a new [PubDevClient] instance.
  /// 
  /// Optionally accepts a custom [http.Client] for testing or customization.
  PubDevClient([http.Client? client]) : _client = client ?? http.Client();

  /// Fetches metadata for a package from pub.dev.
  /// 
  /// Returns [PackageMetadata] if the package exists and can be fetched,
  /// or null if the package doesn't exist or there's a network error.
  /// 
  /// Example:
  /// ```dart
  /// final client = PubDevClient();
  /// final metadata = await client.fetchPackageMetadata('http');
  /// print(metadata?.latestVersion); // '1.2.0'
  /// ```
  Future<PackageMetadata?> fetchPackageMetadata(String packageName) async {
    final url = Uri.parse('$_baseUrl$packageName');
    try {
      final response = await _client.get(url, headers: {'Accept': 'application/vnd.pub.v2+json'});

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final latestVersion = (data['latest'] as Map<String, dynamic>?)?['version'] as String?;
        final publishedString = (data['latest'] as Map<String, dynamic>?)?['published']?.toString();

        return PackageMetadata(
          name: packageName,
          latestVersion: latestVersion ?? '0.0.0',
          updatedAt: publishedString != null ? DateTime.tryParse(publishedString) : null,
          discontinued: data['isDiscontinued'] == true,
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Closes the underlying HTTP client and releases resources.
  /// 
  /// Should be called when the client is no longer needed to prevent
  /// resource leaks.
  void close() => _client.close();
}
