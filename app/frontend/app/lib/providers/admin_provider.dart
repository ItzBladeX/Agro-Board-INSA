import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/admin_service.dart';

class AdminProvider extends ChangeNotifier {
  final AdminService _adminService = AdminService();

  List<UserModel> _users = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<UserModel> get users => _users;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchUsers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _users = await _adminService.getAllUsers();
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<Map<String, dynamic>> blockUser(int userId) async {
    final result = await _adminService.blockUser(userId);
    if (result["success"]) await fetchUsers();
    return result;
  }

  Future<Map<String, dynamic>> unblockUser(int userId) async {
    final result = await _adminService.unblockUser(userId);
    if (result["success"]) await fetchUsers();
    return result;
  }

  Future<Map<String, dynamic>> deleteUser(int userId) async {
    final result = await _adminService.deleteUser(userId);
    if (result["success"]) await fetchUsers();
    return result;
  }

  Future<Map<String, dynamic>> updateUserRole(int userId, String role) async {
    final result = await _adminService.updateUserRole(userId, role);
    if (result["success"]) await fetchUsers();
    return result;
  }
}