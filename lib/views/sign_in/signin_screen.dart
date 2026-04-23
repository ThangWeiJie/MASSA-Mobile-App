import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:massa/view_models/login_viewmodel.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<LoginViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              _buildHeader(),
              const SizedBox(height: 40),
              _buildForm(context, viewModel),
              const SizedBox(height: 32),
              _buildFooter(context, viewModel),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Center(
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFCE1126),
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x19000000),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                  spreadRadius: -2,
                ),
                BoxShadow(
                  color: Color(0x19000000),
                  blurRadius: 6,
                  offset: Offset(0, 4),
                  spreadRadius: -1,
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'A',
                style: TextStyle(
                  color: Color(0xFFFCD106),
                  fontSize: 24,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Center(
          child: Text(
            'Welcome Back',
            style: TextStyle(
              color: Colors.black,
              fontSize: 30,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Center(
          child: Text(
            'Log in to your account',
            style: TextStyle(
              color: Color(0xFF364153),
              fontSize: 16,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForm(BuildContext context, LoginViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Email',
          style: TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          decoration: InputDecoration(
            hintText: 'name@example.com',
            hintStyle: const TextStyle(
              color: Color(0xFF717182),
              fontSize: 16,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 16,
            ),
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Color(0xFFD1D5DC),
                width: 1.18,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Color(0xFFCE1126),
                width: 1.5,
              ),
            ),
          ),
          onChanged: viewModel.updateEmail,
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Password',
              style: TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
              ),
            ),
            GestureDetector(
              onTap: () {
                // context now works perfectly! Use .push so they can go back easily.
                context.push('/forgot-password');
              },
              child: const Text(
                'Forgot?',
                style: TextStyle(
                  color: Color(0xFFCE1126),
                  fontSize: 14,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          obscureText: true,
          decoration: InputDecoration(
            hintText: 'Enter your password',
            hintStyle: const TextStyle(
              color: Color(0xFF717182),
              fontSize: 16,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 16,
            ),
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Color(0xFFD1D5DC),
                width: 1.18,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Color(0xFFCE1126),
                width: 1.5,
              ),
            ),
          ),
          onChanged: viewModel.updatePassword,
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            SizedBox(
              height: 20,
              width: 20,
              child: Checkbox(
                value: false,
                onChanged: (bool? value) {},
                side: const BorderSide(color: Color(0xFFD1D5DC)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                activeColor: const Color(0xFFCE1126),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Remember me',
              style: TextStyle(
                color: Color(0xFF364153),
                fontSize: 14,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // We accept BuildContext here too
  Widget _buildFooter(BuildContext context, LoginViewModel viewModel) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: viewModel.isLoading
                ? null
                : () => _handleLogin(context, viewModel),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFCE1126),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: viewModel.isLoading
                ? CircularProgressIndicator(color: Colors.white)
                : const Text(
                    'Log In',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 16),
        Text.rich(
          TextSpan(
            children: [
              const TextSpan(
                text: 'Don\'t have an account? ',
                style: TextStyle(
                  color: Color(0xFF364153),
                  fontSize: 14,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                ),
              ),
              WidgetSpan(
                child: GestureDetector(
                  onTap: () {
                    // You can add context.push('/signup') here when you build it!
                    context.push('/signup');
                  },
                  child: const Text(
                    'Sign up',
                    style: TextStyle(
                      color: Color(0xFFCE1126),
                      fontSize: 14,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _handleLogin(BuildContext context, LoginViewModel viewModel) async {
    try {
      await viewModel.login();
    } on FirebaseAuthException catch (e) {
      if (!context.mounted) {
        return;
      }

      String message = _handleErrorMessage(e);
      _showSnackBar(context, message);
    } catch (e) {
      if (!context.mounted) {
        return;
      }

      _showSnackBar(context, "An unexpected error has occurred");
    }
  }

  String _handleErrorMessage(FirebaseAuthException e) {
    switch(e.code) {
      case "invalid-credential": return "Wrong email or password";

      default: return "";
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
