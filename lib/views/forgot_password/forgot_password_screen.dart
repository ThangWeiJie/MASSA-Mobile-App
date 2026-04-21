import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:massa/view_models/forgot_password_viewmodel.dart';
import 'package:provider/provider.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ForgotPasswordViewmodel>();

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 48.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            // Centered for this screen
            children: [
              const SizedBox(height: 60),
              _buildHeader(),
              const SizedBox(height: 40),
              _buildForm(context, viewModel),
              const SizedBox(height: 60),
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
        // Question Mark Icon Graphic
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFFCE1126).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Center(
            child: Text(
              '?',
              style: TextStyle(
                color: Color(0xFFCE1126), // Match theme red
                fontSize: 42,
                fontFamily: 'Arial',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),

        // Title
        const Text(
          'Forgot Password',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.black,
            fontSize: 30,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
            height: 1.20,
          ),
        ),
        const SizedBox(height: 12),

        // Subtitle
        const Text(
          'Enter your email to reset your password',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF666666),
            fontSize: 16,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
            height: 1.50,
          ),
        ),
      ],
    );
  }

  Widget _buildForm(BuildContext context, ForgotPasswordViewmodel viewModel) {
    return Column(
      children: [
        // Real Email Input Field
        TextFormField(
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: 'Enter your email',
            hintStyle: const TextStyle(
              color: Color(0x7F0A0A0A),
              fontSize: 16,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: const Icon(
              Icons.email_outlined,
              color: Color(0x7F0A0A0A),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 18,
            ),
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Color(0xFFE5E7EB),
                width: 1.18,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Color(0xFFCE1126),
                width: 1.5,
              ),
            ),
          ),
          onChanged: viewModel.updateEmail,
        ),
        const SizedBox(height: 24),

        // Real Submit Button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: viewModel.isLoading
                ? null
                : () => _handleResetPassword(context, viewModel),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFCE1126),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 4,
              shadowColor: const Color(0x3FCE1126),
            ),
            child: viewModel.isLoading
                ? CircularProgressIndicator(color: Colors.white)
                : const Text(
                    'Send Reset Link',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context, ForgotPasswordViewmodel viewModel) {
    return GestureDetector(
      onTap: () {
        // context.pop() safely returns the user to the previous screen (Login)
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/signin'); // Fallback just in case
        }
      },
      child: const Text(
        'Back to Login',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Color(0xFFCE1126),
          fontSize: 16,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Future<void> _handleResetPassword(
    BuildContext context,
    ForgotPasswordViewmodel viewModel,
  ) async {
    try {
      await viewModel.resetPassword();

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("A reset link has been sent if an account exists with the email.")),
      );
    } on FirebaseAuthException catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$e")));
    }
  }
}
