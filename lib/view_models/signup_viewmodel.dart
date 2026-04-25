import 'package:flutter/material.dart';
import 'package:massa/service/auth_service.dart';

class SignupViewModel extends ChangeNotifier {
  final AuthService _authService;

  SignupViewModel({required AuthService authService})
    : _authService = authService;

  String _fullName = "";
  String _email = "";
  String _password = "";
  String _confirmPassword = "";
  bool _agreeToTerms = false;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  void updateFullName(String value) => _fullName = value.trim();

  void updateEmail(String value) => _email = value.trim();

  void updatePassword(String value) => _password = value.trim();

  void updateConfirmPassword(String value) => _confirmPassword = value.trim();

  void updateAgreeToTerms(bool value) => _agreeToTerms = value;

  Future<void> signup() async {
    if (_fullName.isEmpty ||
        _email.isEmpty ||
        _password.isEmpty ||
        _confirmPassword.isEmpty) {
      throw Exception("Please fill all fields");
    }

    if (_password != _confirmPassword) {
      throw Exception("Passwords do not match");
    }

    _isLoading = true;
    notifyListeners();

    try {
      await _authService.registerNewAccount(
          email: _email,
          password: _password,
          name: _fullName,
      );
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      // notifyListeners();
    }
  }
}
