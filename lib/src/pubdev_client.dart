
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models.dart';

class PubDevClient {
  final http.Client _client;
  final String _baseUrl = 'https://pub.dev/api/packages/';

  PubDevClient([http.Client? client]) : _client = client ?? http.Client();

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

  void close() => _client.close();
}
