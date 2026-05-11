import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:massa/view_models/features/authentication/forgot_password_viewmodel.dart';
import 'package:provider/provider.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ForgotPasswordViewmodel>();

    return Scaffold(
      // Prevents the layout from breaking/overflowing when the keyboard pops up on an unscrollable screen
      resizeToAvoidBottomInset: false,
      body: Container(
        // Main Background Gradient (Emerald/Green/Teal Theme)
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.teal[700]!, Colors.green[800]!, Colors.teal[900]!],
          ),
        ),
        child: SafeArea(
          child: Center(
            // Unscrollable Padding
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
            ? Colors.tealAccent[400]!
            : index % 2 == 0
            ? Colors.teal[400]!
            : Colors.green[500]!;
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

  Widget _buildMainCard(
    BuildContext context,
    ForgotPasswordViewmodel viewModel,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.teal[50]!.withValues(alpha: 0.98),
            Colors.green[50]!.withValues(alpha: 0.98),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.teal[300]!.withValues(alpha: 0.6),
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
                  top: BorderSide(color: Colors.teal[600]!, width: 4),
                  left: BorderSide(color: Colors.teal[600]!, width: 4),
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
                  top: BorderSide(color: Colors.teal[600]!, width: 4),
                  right: BorderSide(color: Colors.teal[600]!, width: 4),
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
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.teal[600]!,
                    Colors.green[600]!,
                    Colors.teal[800]!,
                  ],
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.teal[200]!.withValues(alpha: 0.3),
                  width: 8,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 16,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.vpn_key_rounded,
                size: 42,
                color: Colors.white,
              ),
            ),
            Positioned(
              top: -8,
              right: -8,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.tealAccent[400],
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
                  color: Colors.green[400],
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
            colors: [Colors.teal[800]!, Colors.green[700]!, Colors.teal[800]!],
          ).createShader(bounds),
          child: const Text(
            'Reset Password',
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
                  colors: [Colors.transparent, Colors.teal[600]!],
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Enter your email',
              style: TextStyle(color: Colors.black54, fontSize: 14),
            ),
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.teal[600]!, Colors.transparent],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildForm(BuildContext context, ForgotPasswordViewmodel viewModel) {
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
          keyboardType: TextInputType.emailAddress,
          onChanged: viewModel.updateEmail,
          decoration: InputDecoration(
            hintText: 'you@example.com',
            hintStyle: const TextStyle(color: Colors.black38, fontSize: 15),
            prefixIcon: const Icon(
              Icons.mail_outline,
              color: Colors.black38,
              size: 20,
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.teal[500]!, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Submit Button
        Container(
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.teal[600]!,
                Colors.green[600]!,
                Colors.teal[700]!,
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
                : () => _handleResetPassword(context, viewModel),
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
                    'Send Reset Link',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 24),

        // Footer (Back to Login)
        Center(
          child: GestureDetector(
            onTap: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/signin');
              }
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.arrow_back, color: Colors.teal[700], size: 18),
                const SizedBox(width: 8),
                Text(
                  'Back to login',
                  style: TextStyle(
                    color: Colors.teal[700],
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- Logic Remains Unchanged ---

  Future<void> _handleResetPassword(
    BuildContext context,
    ForgotPasswordViewmodel viewModel,
  ) async {
    try {
      await viewModel.resetPassword();

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            "A reset link has been sent if an account exists with the email.",
          ),
          backgroundColor:
              Colors.teal[700], // Styled to match the success theme
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("$e"),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
