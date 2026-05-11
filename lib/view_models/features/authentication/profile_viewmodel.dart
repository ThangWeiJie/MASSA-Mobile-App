import 'package:flutter/material.dart';
import 'package:massa/models/user.dart';
import 'package:massa/repository/user_repository.dart';

class ProfileViewModel extends ChangeNotifier {
  final UserRepository _userRepository;
  final String userId;

  UserModel? _userModel;
  bool _isLoading = false;
  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  UserModel? get user => _userModel;
  bool get isLoading => _isLoading;

  ProfileViewModel({required UserRepository userRepo, required this.userId})
    : _userRepository = userRepo {
    fetchUser();
  }

  Future<void> fetchUser() async {
    _setLoading(true);
    final result = await _userRepository.getUser(userId);
    if (_disposed) return;
    _userModel = result;
    _setLoading(false);
  }

  Future<void> updateProfile({
    required String fullName,
    required String phone,
    required String department,
  }) async {
    if (_userModel == null) return;

    _setLoading(true);

    try {
      await _userRepository.updateUserProfile(
        userId: userId,
        fullName: fullName,
        phone: phone,
        department: department,
      );

      await fetchUser();
    } finally {
      if (!_disposed) {
        _setLoading(false);
      }
    }
  }

  Future<void> adminUpdateUserProfile({
    required String fullName,
    required String phone,
    required String department,
    required String role,
  }) async {
    if (_userModel == null) return;

    _setLoading(true);

    try {
      await _userRepository.adminUpdateUserProfile(
        userId: userId,
        fullName: fullName,
        phone: phone,
        department: department,
        role: role,
      );

      await fetchUser();
    } finally {
      if (!_disposed) {
        _setLoading(false);
      }
    }
  }

  void _setLoading(bool value) {
    if (_disposed) return;
    _isLoading = value;
    notifyListeners();
  }
}
