import 'dart:convert';
import 'api_client.dart';
import '../models/user_model.dart';

class ProfileService {
  final ApiClient _apiClient = ApiClient();

  Future<UserModel> getProfile() async {
    final response = await _apiClient.get("/profile/");
    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return UserModel.fromJson(data);
    } else {
      throw Exception(data["detail"] ?? "Failed to load profile");
    }
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> changes) async {
    final response = await _apiClient.put("/profile/", changes);
    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return {"success": true, "message": data["message"]};
    } else {
      return {"success": false, "message": data["detail"] ?? "Update failed"};
    }
  }
}