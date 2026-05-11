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

  @override
  void dispose() {
    _userSubscription?.cancel();
    super.dispose();
  }
}
