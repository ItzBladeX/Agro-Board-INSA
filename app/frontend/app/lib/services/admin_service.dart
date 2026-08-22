import 'dart:convert';
import 'api_client.dart';
import '../models/user_model.dart';

class AdminService {
  final ApiClient _apiClient = ApiClient();

  Future<List<UserModel>> getAllUsers() async {
    final response = await _apiClient.get("/admin/users");
    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return (data as List).map((u) => UserModel.fromJson(u)).toList();
    } else {
      throw Exception(data["detail"] ?? "Failed to load users");
    }
  }

  Future<Map<String, dynamic>> blockUser(int userId) async {
    return _patchAction("/admin/users/$userId/block");
  }

  Future<Map<String, dynamic>> unblockUser(int userId) async {
    return _patchAction("/admin/users/$userId/unblock");
  }

  Future<Map<String, dynamic>> deleteUser(int userId) async {
    final response = await _apiClient.delete("/admin/users/$userId");
    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return {"success": true, "message": data["message"]};
    } else {
      return {"success": false, "message": data["detail"] ?? "Delete failed"};
    }
  }

  Future<Map<String, dynamic>> updateUserRole(int userId, String role) async {
    final response = await _apiClient.patch(
      "/admin/users/$userId/role",
      body: {"role": role},
    );
    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return {"success": true, "message": data["message"]};
    } else {
      return {"success": false, "message": data["detail"] ?? "Role update failed"};
    }
  }

  Future<Map<String, dynamic>> _patchAction(String path) async {
    final response = await _apiClient.patch(path);
    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return {"success": true, "message": data["message"]};
    } else {
      return {"success": false, "message": data["detail"] ?? "Action failed"};
    }
  }
}