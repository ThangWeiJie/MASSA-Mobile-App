import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:massa/service/features/auth/auth_email_validator.dart';
import 'package:massa/view_models/features/authentication/signup_viewmodel.dart';
import 'package:provider/provider.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController matricNumberController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    matricNumberController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSignUp(BuildContext context, SignupViewModel viewModel) async {
    final fullName = fullNameController.text.trim();
    final email = emailController.text.trim();
    final matric = matricNumberController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (fullName.isEmpty ||
        email.isEmpty ||
        matric.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      _showSnackBar(context, "Please fill all fields");
      return;
    }

    if (!email.contains('@')) {
      _showSnackBar(context, "Please enter a valid email address");
      return;
    }

    if (password.length < 6) {
      _showSnackBar(context, "Password must be at least 6 characters");
      return;
    }

    if (password != confirmPassword) {
      _showSnackBar(context, "Passwords do not match");
      return;
    }

    try {
      await viewModel.signup();
      if (context.mounted) {
        context.go('/');
      }
    } on AuthValidationException catch (e) {
      if (context.mounted) {
        _showSnackBar(context, e.message);
      }
    } on FirebaseAuthException catch (e) {
      String message = _handleError(e);
      if (context.mounted) {
        _showSnackBar(context, message);
      }
    } catch (e) {
      if (context.mounted) {
        _showSnackBar(context, e.toString().replaceAll("Exception: ", ""));
      }
    }
  }

  String _handleError(FirebaseAuthException e) {
    switch (e.code) {
      case "email-already-in-use":
        return "This email is already associated with another account.";
      default:
        return "Registration failed. Please try again.";
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

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SignupViewModel>();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.orange[700]!, Colors.red[800]!, Colors.pink[900]!],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 24.0,
              ),
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
            ? Colors.pink[400]!
            : index % 2 == 0
                ? Colors.orange[500]!
                : Colors.red[600]!;
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

  Widget _buildMainCard(BuildContext context, SignupViewModel viewModel) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.orange[50]!.withOpacity(0.98),
            Colors.red[50]!.withOpacity(0.98),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.orange[300]!.withOpacity(0.6),
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
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.orange[600]!, width: 4),
                  left: BorderSide(color: Colors.orange[600]!, width: 4),
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                ),
              ),
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.orange[600]!, width: 4),
                  right: BorderSide(color: Colors.orange[600]!, width: 4),
                ),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(8),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
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
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.orange[600]!,
                    Colors.red[600]!,
                    Colors.pink[700]!,
                  ],
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.orange[200]!.withOpacity(0.3),
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
              child: const Icon(
                Icons.person_add_alt_1_rounded,
                size: 36,
                color: Colors.white,
              ),
            ),
            Positioned(
              top: -6,
              right: -6,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.pink[400],
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 4),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: -6,
              left: -6,
              child: Container(
                width: 10,
                height: 10,
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
        const SizedBox(height: 12),
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [Colors.orange[800]!, Colors.red[700]!, Colors.pink[800]!],
          ).createShader(bounds),
          child: const Text(
            'Create Account',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
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
                  colors: [Colors.transparent, Colors.orange[600]!],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Keep Up to Date with MASSA!',
              style: TextStyle(
                color: Colors.orange[900]!.withOpacity(0.8),
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange[600]!, Colors.transparent],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildForm(BuildContext context, SignupViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          label: 'Full Name',
          controller: fullNameController,
          hintText: 'John Doe',
          icon: Icons.person_outline,
          onChange: viewModel.updateFullName,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          label: 'Email Address',
          controller: emailController,
          hintText: 'you@example.com',
          icon: Icons.mail_outline,
          keyboardType: TextInputType.emailAddress,
          onChange: viewModel.updateEmail,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          label: 'Matric Number',
          controller: matricNumberController,
          hintText: 'e.g., 12345678',
          icon: Icons.badge_outlined,
          onChange: viewModel.updateMatricNumber,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          label: 'Password',
          controller: passwordController,
          hintText: '••••••••',
          icon: Icons.lock_outline,
          obscureText: obscurePassword,
          onChange: viewModel.updatePassword,
          suffixIcon: IconButton(
            icon: Icon(
              obscurePassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: Colors.black38,
              size: 20,
            ),
            onPressed: () => setState(() => obscurePassword = !obscurePassword),
          ),
        ),
        const SizedBox(height: 12),
        _buildTextField(
          label: 'Confirm Password',
          controller: confirmPasswordController,
          hintText: '••••••••',
          icon: Icons.lock_outline,
          obscureText: obscureConfirmPassword,
          onChange: viewModel.updateConfirmPassword,
          suffixIcon: IconButton(
            icon: Icon(
              obscureConfirmPassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: Colors.black38,
              size: 20,
            ),
            onPressed: () => setState(
              () => obscureConfirmPassword = !obscureConfirmPassword,
            ),
          ),
        ),
        const SizedBox(height: 24),
        _buildFooter(context, viewModel),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    required void Function(String) onChange,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 48,
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            onChanged: onChange,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
              prefixIcon: Icon(icon, color: Colors.black38, size: 20),
              suffixIcon: suffixIcon,
              filled: true,
              fillColor: Colors.grey[50],
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 0,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey[200]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.orange[600]!, width: 2),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context, SignupViewModel viewModel) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.orange[600]!,
                Colors.red[600]!,
                Colors.pink[700]!,
              ],
            ),
            borderRadius: BorderRadius.circular(10),
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
                : () => _handleSignUp(context, viewModel),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
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
                    'Create Account',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: const [
            Expanded(child: Divider(color: Color(0xFFD1D5DC), thickness: 1)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'or continue with',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(child: Divider(color: Color(0xFFD1D5DC), thickness: 1)),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFD1D5DC)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: Colors.white,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      'G',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Google',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFD1D5DC)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: Colors.white,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.apple, color: Colors.black, size: 22),
                    SizedBox(width: 6),
                    Text(
                      'Apple',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Already have an account? ",
              style: TextStyle(color: Colors.black54, fontSize: 13),
            ),
            GestureDetector(
              onTap: () => context.push('/login'),
              child: Text(
                'Sign in',
                style: TextStyle(
                  color: Colors.orange[700],
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}