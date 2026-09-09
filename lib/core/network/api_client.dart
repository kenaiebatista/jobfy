import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'api_exception.dart';

/// Thin JSON REST client for the Jobfy backend.
///
/// Every repository's remote data source goes through this instead of
/// talking to `package:http` directly, so retries, auth headers and error
/// mapping live in exactly one place.
class ApiClient {
  final http.Client _http;
  final String _baseUrl;
  String? _authToken;

  ApiClient({http.Client? httpClient, String? baseUrl})
      : _http = httpClient ?? http.Client(),
        _baseUrl = baseUrl ?? ApiConfig.baseUrl;

  /// Attaches a `Bearer` token to every subsequent request. Pass `null` to
  /// clear it (e.g. on logout).
  void setAuthToken(String? token) => _authToken = token;

  Future<dynamic> get(String path, {Map<String, String>? query}) {
    return _send('GET', path, query: query);
  }

  Future<dynamic> post(String path, {Map<String, dynamic>? body}) {
    return _send('POST', path, body: body);
  }

  Future<dynamic> put(String path, {Map<String, dynamic>? body}) {
    return _send('PUT', path, body: body);
  }

  Future<dynamic> delete(String path) {
    return _send('DELETE', path);
  }

  Future<dynamic> _send(
    String method,
    String path, {
    Map<String, String>? query,
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse('$_baseUrl$path').replace(queryParameters: query);
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (_authToken != null) 'Authorization': 'Bearer $_authToken',
    };

    late final http.Response response;
    try {
      final request = http.Request(method, uri)..headers.addAll(headers);
      if (body != null) request.body = jsonEncode(body);
      final streamed = await _http.send(request).timeout(ApiConfig.timeout);
      response = await http.Response.fromStream(streamed);
    } on SocketException {
      throw const ApiUnreachableException();
    } on HttpException {
      throw const ApiUnreachableException();
    } on http.ClientException {
      throw const ApiUnreachableException();
    } catch (_) {
      // Covers TimeoutException and any other transport-level failure.
      throw const ApiUnreachableException();
    }

    return _decode(response);
  }

  dynamic _decode(http.Response response) {
    final body = response.body.isEmpty ? null : response.body;

    if (response.statusCode < 200 || response.statusCode >= 300) {
      String message = 'Request failed with status ${response.statusCode}.';
      if (body != null) {
        try {
          final decoded = jsonDecode(body);
          if (decoded is Map<String, dynamic> && decoded['message'] is String) {
            message = decoded['message'] as String;
          }
        } catch (_) {
          // Body wasn't JSON — keep the default message.
        }
      }
      throw ApiStatusException(response.statusCode, message);
    }

    if (body == null) return null;
    try {
      return jsonDecode(body);
    } on FormatException {
      throw const ApiDecodeException();
    }
  }

  void close() => _http.close();
}
