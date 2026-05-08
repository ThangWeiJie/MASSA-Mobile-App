import 'package:flutter/material.dart';
import 'package:massa/service/features/auth/auth_service.dart';

class SignupViewModel extends ChangeNotifier {
  final AuthService _authService;

  SignupViewModel({required AuthService authService})
    : _authService = authService;

  String _fullName = "";
  String _email = "";
  String _matricNumber = ""; // Added matricNumber
  String _password = "";
  String _confirmPassword = "";

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void updateFullName(String value) => _fullName = value.trim();
  void updateEmail(String value) => _email = value.trim();
  void updateMatricNumber(String value) => _matricNumber = value.trim(); // New updater
  void updatePassword(String value) => _password = value.trim();
  void updateConfirmPassword(String value) => _confirmPassword = value.trim();

  Future<void> signup() async {
    if (_fullName.isEmpty ||
        _email.isEmpty ||
        _matricNumber.isEmpty || // Validating new field
        _password.isEmpty ||
        _confirmPassword.isEmpty) {
      throw Exception("Please fill all fields");
    }

    if (_password != _confirmPassword) {
      throw Exception("Passwords do not match");
    }

    if (_password.length < 6) {
      throw Exception("Password must be at least 6 characters");
    }

    _isLoading = true;
    notifyListeners();

    try {
      // Note: Make sure your AuthService accepts the matricNumber parameter now!
      await _authService.registerNewAccount(
          email: _email,
          password: _password,
          name: _fullName,
          matricNumber: _matricNumber, // Pass to service
      );
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}