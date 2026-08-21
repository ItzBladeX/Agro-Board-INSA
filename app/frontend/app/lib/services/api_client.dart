import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/constants.dart';
import '../utils/secure_storage.dart';

class ApiClient {
  Future<Map<String, String>> _headers({bool auth = true}) async {
    final headers = {"Content-Type": "application/json"};
    if (auth) {
      final token = await SecureStorage.getToken();
      if (token != null) {
        headers["Authorization"] = "Bearer $token";
      }
    }
    return headers;
  }

  Future<http.Response> get(String path, {bool auth = true}) async {
    final headers = await _headers(auth: auth);
    return http.get(
      Uri.parse("${ApiEndpoints.baseUrl}$path"),
      headers: headers,
    );
  }

  Future<http.Response> post(
    String path,
    Map<String, dynamic> body, {
    bool auth = true,
  }) async {
    final headers = await _headers(auth: auth);
    return http.post(
      Uri.parse("${ApiEndpoints.baseUrl}$path"),
      headers: headers,
      body: jsonEncode(body),
    );
  }

  Future<http.Response> put(
    String path,
    Map<String, dynamic> body, {
    bool auth = true,
  }) async {
    final headers = await _headers(auth: auth);
    return http.put(
      Uri.parse("${ApiEndpoints.baseUrl}$path"),
      headers: headers,
      body: jsonEncode(body),
    );
  }

  Future<http.Response> patch(
    String path, {
    Map<String, dynamic>? body,
    bool auth = true,
  }) async {
    final headers = await _headers(auth: auth);
    return http.patch(
      Uri.parse("${ApiEndpoints.baseUrl}$path"),
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
  }

  Future<http.Response> delete(String path, {bool auth = true}) async {
    final headers = await _headers(auth: auth);
    return http.delete(
      Uri.parse("${ApiEndpoints.baseUrl}$path"),
      headers: headers,
    );
  }
}
