import 'dart:async';
import 'package:http/http.dart' as http;
import '../../constants/app_constants.dart';

/// Network info utility for checking connectivity.
class NetworkClient {
  final http.Client _client;

  NetworkClient({http.Client? client}) : _client = client ?? http.Client();

  http.Client get client => _client;

  /// Perform a health check against the backend.
  Future<bool> isServerReachable() async {
    try {
      final response = await _client
          .get(Uri.parse('${ApiConstants.baseUrl}/health'))
          .timeout(const Duration(seconds: 3));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  void dispose() {
    _client.close();
  }
}
