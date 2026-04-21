import 'package:flutter/material.dart';
import 'package:massa/service/auth_service.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthService _authService;

  LoginViewModel({required AuthService authService}): _authService = authService;

  String _email = "";
  String _password = "";
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  void updateEmail(String value) => _email = value;
  void updatePassword(String value) => _password = value;

  Future<void> login() async {
    if (_email.isEmpty || _password.isEmpty) return;

    _isLoading = true;
    notifyListeners();

    try {
      await _authService.signInWithEmailPassword(_email, _password);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
    }
  }
}