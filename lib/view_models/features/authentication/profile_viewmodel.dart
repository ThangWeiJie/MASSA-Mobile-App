import 'dart:async';

import 'package:flutter/material.dart';
import 'package:massa/models/user.dart';
import 'package:massa/repository/user_repository.dart';

class ProfileViewModel extends ChangeNotifier {
  final UserRepository _userRepository;
  final String userId;

  UserModel? _userModel;
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  StreamSubscription<UserModel>? _userSubscription;

  ProfileViewModel({required UserRepository userRepo, required this.userId})
    : _userRepository = userRepo {
    if (userId.isNotEmpty) {
      _listenToUser();
    } else {
      _isLoading = false;
    }
  }

  UserModel? get user => _userModel;
  bool get isLoading => _isLoading;

  ProfileViewModel({required UserRepository userRepo, required this.userId})
    : _userRepository = userRepo {
    fetchUser();
  }

  void _listenToUser() {
    _userSubscription = _userRepository
        .getUserStream(userId)
        .listen(
          (updatedUser) {
            _userModel = updatedUser;
            _isLoading = false;
            notifyListeners();
          },
          onError: (error) {
            debugPrint('Profile sync error: $error');
            _isLoading = false;
            notifyListeners();
          },
        );
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
