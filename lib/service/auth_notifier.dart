import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:massa/service/auth_service.dart';

class AuthNotifier extends ChangeNotifier {
  final AuthService _authService;
  StreamSubscription<User?>? _authSubscription;

  AuthNotifier(this._authService) {
    _authSubscription = _authService.authStateChanges.listen((user) {
      notifyListeners();
    });
  }

  bool get isAuthenticated => _authService.currentUser != null;
  bool get isEmailVerified => _authService.currentUser?.emailVerified ?? false;
  User? get currentUser => _authService.currentUser;

  Future<void> signIn(String email, String password) async {
    try {
      await _authService.signInWithEmailPassword(email, password);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> refreshUser() async {
    await _authService.refreshUser();
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}