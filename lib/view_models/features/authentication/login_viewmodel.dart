import 'package:flutter/material.dart';
import 'package:massa/service/features/auth/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthService _authService;
  static const String _emailKey = 'remembered_email';

  // We use a controller so we can pre-fill the text field when data loads
  final TextEditingController emailController = TextEditingController();

  LoginViewModel({required AuthService authService}) : _authService = authService {
    _loadSavedEmail();
  }

  // UI state variables
  String _password = "";
  bool _isLoading = false;
  bool _rememberMe = false;

  bool get isLoading => _isLoading;
  bool get rememberMe => _rememberMe;

  void updatePassword(String value) => _password = value.trim();

  void toggleRememberMe(bool? value) {
    _rememberMe = value ?? false;
    notifyListeners();
  }

  // Load the email from device storage when the screen opens
  Future<void> _loadSavedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString(_emailKey);
    
    if (savedEmail != null && savedEmail.isNotEmpty) {
      emailController.text = savedEmail;
      _rememberMe = true;
      notifyListeners();
    }
  }

  // Interaction
  Future<void> login() async {
    final email = emailController.text.trim();
    if (email.isEmpty || _password.isEmpty) return;

    _isLoading = true;
    notifyListeners();

    try {
      await _authService.signInWithEmailPassword(email, _password);
      
      // Save or remove the email based on the checkbox state
      final prefs = await SharedPreferences.getInstance();
      if (_rememberMe) {
        await prefs.setString(_emailKey, email);
      } else {
        await prefs.remove(_emailKey);
      }
      
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }
}