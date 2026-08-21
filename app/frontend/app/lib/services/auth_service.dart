import 'dart:convert';
import 'api_client.dart';
import '../utils/secure_storage.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> login(String phoneNumber, String password) async {
    final response = await _apiClient.post(
      "/auth/login",
      {
        "phone_number": phoneNumber,
        "passwd": password,
      },
      auth: false, // no token exists yet before login
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      await SecureStorage.saveToken(data["access_token"]);
      return {"success": true};
    } else {
      return {"success": false, "message": data["detail"] ?? "Login failed"};
    }
  }

  Future<void> logout() async {
    await SecureStorage.deleteToken();
  }

  Future<bool> isLoggedIn() async {
    final token = await SecureStorage.getToken();
    return token != null;
  }
}