import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/profile_service.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileService _profileService = ProfileService();

  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _profileService.getProfile();
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> updateProfile(Map<String, dynamic> changes) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _profileService.updateProfile(changes);

    _isLoading = false;

    if (result["success"]) {
      await fetchProfile(); // refresh local data so UI shows the latest values
      return true;
    } else {
      _errorMessage = result["message"];
      notifyListeners();
      return false;
    }
  }
}