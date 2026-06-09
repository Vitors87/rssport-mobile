import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'api_exception.dart';

abstract class ApiClient {
  static final _client = http.Client();

  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Future<Map<String, dynamic>> get(String endpoint) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}$endpoint');
    final response = await _client.get(uri, headers: _headers);
    return _handle(response);
  }

  static Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}$endpoint');
    final response = await _client.post(
      uri,
      headers: _headers,
      body: jsonEncode(body),
    );
    return _handle(response);
  }

  static Map<String, dynamic> _handle(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      // Forzar UTF-8 para manejar tildes y caracteres especiales del español
      return jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    }
    throw ApiException(
      statusCode: response.statusCode,
      message: _extractMessage(response),
    );
  }

  static String _extractMessage(http.Response response) {
    try {
      final body = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return body['message'] as String? ?? 'Error ${response.statusCode}';
    } catch (_) {
      return 'Error ${response.statusCode}';
    }
  }
}
