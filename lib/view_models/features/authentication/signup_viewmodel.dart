import 'package:flutter/material.dart';
import 'package:massa/service/features/auth/auth_email_validator.dart';
import 'package:massa/service/features/auth/auth_service.dart';

class SignupViewModel extends ChangeNotifier {
  final AuthService _authService;

  SignupViewModel({required AuthService authService})
      : _authService = authService;

  // Fields from both versions
  String _fullName = "";
  String _email = "";
  String _matricNumber = ""; 
  String _password = "";
  String _confirmPassword = "";
  bool _agreeToTerms = false;
  bool _isLoading = false;

  // Getters
  bool get isLoading => _isLoading;
  bool get agreeToTerms => _agreeToTerms;

  // Updaters
  void updateFullName(String value) => _fullName = value.trim();
  void updateEmail(String value) => _email = value.trim();
  void updateMatricNumber(String value) => _matricNumber = value.trim();
  void updatePassword(String value) => _password = value.trim();
  void updateConfirmPassword(String value) => _confirmPassword = value.trim();
  void updateAgreeToTerms(bool value) {
    _agreeToTerms = value;
    notifyListeners();
  }

  Future<void> signup() async {
    // 1. Basic empty field validation (including matricNumber)
    if (_fullName.isEmpty ||
        _email.isEmpty ||
        _matricNumber.isEmpty ||
        _password.isEmpty ||
        _confirmPassword.isEmpty) {
      throw Exception("Please fill all fields");
    }

    // 2. Terms and Conditions validation
    if (!_agreeToTerms) {
      throw Exception("Please agree to the terms and conditions");
    }

    // 3. Password logic validation
    if (_password != _confirmPassword) {
      throw Exception("Passwords do not match");
    }

    if (_password.length < 6) {
      throw Exception("Password must be at least 6 characters");
    }

    // 4. Custom UTM Email validation logic
    AuthEmailValidator.requireAllowedUtmEmail(_email);

    // Start loading
    _isLoading = true;
    notifyListeners();

    try {
      // 5. Call service with all merged parameters
      await _authService.registerNewAccount(
        email: _email,
        password: _password,
        name: _fullName,
        matricNumber: _matricNumber, 
      );
    } catch (e) {
      rethrow;
    } finally {
      // Ensure UI updates to stop loading state regardless of success or failure
      _isLoading = false;
      notifyListeners();
    }
  }
}