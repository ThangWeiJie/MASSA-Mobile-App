import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:massa/service/features/auth/auth_email_validator.dart';
import 'package:massa/view_models/features/authentication/login_viewmodel.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<LoginViewModel>();

    return Scaffold(
      // Prevents the layout from breaking/overflowing when the keyboard pops up on an unscrollable screen
      resizeToAvoidBottomInset: false,
      body: Container(
        // Main Background Gradient
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.amber[700]!, Colors.orange[800]!, Colors.red[900]!],
          ),
        ),
        child: SafeArea(
          child: Center(
            // Replaced SingleChildScrollView with Padding to make it unscrollable
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 450),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildDecorativeDots(),
                    const SizedBox(height: 16),
                    _buildMainCard(context, viewModel),
                    const SizedBox(height: 16),
                    _buildDecorativeDots(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDecorativeDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(15, (index) {
        Color dotColor = index % 3 == 0
            ? Colors.yellow[400]!
            : index % 2 == 0
            ? Colors.amber[500]!
            : Colors.orange[600]!;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: dotColor,
            shape: BoxShape.circle,
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildMainCard(BuildContext context, LoginViewModel viewModel) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.amber[50]!.withValues(alpha: 0.98),
            Colors.orange[50]!.withValues(alpha: 0.98),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.amber[300]!.withValues(alpha: 0.6),
          width: 4,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Hornbill Accent: Top Left
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.amber[600]!, width: 4),
                  left: BorderSide(color: Colors.amber[600]!, width: 4),
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                ),
              ),
            ),
          ),
          // Hornbill Accent: Top Right
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.amber[600]!, width: 4),
                  right: BorderSide(color: Colors.amber[600]!, width: 4),
                ),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(8),
                ),
              ),
            ),
          ),

          // Main Content Area
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(),
                const SizedBox(height: 32),
                _buildForm(context, viewModel),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // Restored the original Massa Logo, wrapped nicely to fit the theme
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: Colors.white, // Gives a nice clean background for logos
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.amber[200]!.withValues(alpha: 0.8),
                  width: 6,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 16,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(
                12,
              ), // Some padding so the logo doesn't hug the edges
              child: Image.asset(
                'assets/images/Massa_Logo.png',
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              top: -8,
              right: -8,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.yellow[400],
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 4),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: -8,
              left: -8,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.orange[500],
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 4),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [Colors.amber[800]!, Colors.orange[700]!, Colors.red[800]!],
          ).createShader(bounds),
          child: const Text(
            'Welcome Back',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 32,
              height: 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, Colors.amber[600]!],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Sign in to continue',
              style: TextStyle(
                color: Colors.amber[900]!.withValues(alpha: 0.8),
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.amber[600]!, Colors.transparent],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildForm(BuildContext context, LoginViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Email Address',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: viewModel.emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: _inputDecoration(
            hint: 'you@example.com',
            icon: Icons.mail_outline,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Password',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          obscureText: true,
          onChanged: viewModel.updatePassword,
          decoration: _inputDecoration(
            hint: '••••••••',
            icon: Icons.lock_outline,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                SizedBox(
                  height: 20,
                  width: 20,
                  child: Checkbox(
                    value: viewModel.rememberMe,
                    onChanged: viewModel.toggleRememberMe,
                    activeColor: Colors.amber[700],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Remember me',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () => context.push('/forgot-password'),
              child: Text(
                'Forgot password?',
                style: TextStyle(
                  color: Colors.amber[700],
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildFooter(context, viewModel),
      ],
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.black38, fontSize: 15),
      prefixIcon: Icon(icon, color: Colors.black38, size: 20),
      filled: true,
      fillColor: Colors.grey[50],
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[200]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.amber[600]!, width: 2),
      ),
    );
  }

  Widget _buildFooter(BuildContext context, LoginViewModel viewModel) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.amber[600]!,
                Colors.orange[600]!,
                Colors.red[700]!,
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: viewModel.isLoading
                ? null
                : () => _handleLogin(context, viewModel),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: viewModel.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.0,
                    ),
                  )
                : const Text(
                    'Sign In',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Don't have an account? ",
              style: TextStyle(color: Colors.black54, fontSize: 14),
            ),
            GestureDetector(
              onTap: () => context.push('/signup'),
              child: Text(
                'Sign up',
                style: TextStyle(
                  color: Colors.amber[700],
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // --- Logic Remains Unchanged ---

  void _handleLogin(BuildContext context, LoginViewModel viewModel) async {
    try {
      await viewModel.login();
    } on AuthValidationException catch (e) {
      if (!context.mounted) return;
      _showSnackBar(context, e.message);
    } on FirebaseAuthException catch (e) {
      if (!context.mounted) return;
      String message = _handleErrorMessage(e);
      _showSnackBar(context, message);
    } catch (e) {
      if (!context.mounted) return;
      _showSnackBar(context, "An unexpected error has occurred");
    }
  }

  String _handleErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case "invalid-credential":
        return "Wrong email or password";
      default:
        return "Authentication failed. Please try again.";
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
