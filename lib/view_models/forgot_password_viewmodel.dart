import 'package:flutter/material.dart';
import 'package:massa/service/auth_service.dart';

class ForgotPasswordViewmodel extends ChangeNotifier {
  final AuthService _authService;

  ForgotPasswordViewmodel({required AuthService authService}): _authService = authService;

  // UI state variables
  String _email = "";
  bool _isLoading = false;

  void updateEmail(String value) {_email = value;}
  bool get isLoading => _isLoading;

  // Interaction
  Future<void> resetPassword() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.sendPasswordResetEmail(_email);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}