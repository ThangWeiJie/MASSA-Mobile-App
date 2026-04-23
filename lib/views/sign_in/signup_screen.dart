import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:massa/view_models/signup_viewmodel.dart';
import 'package:provider/provider.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
  TextEditingController();

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  bool agreeToTerms = false;
  bool isLoading = false;

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSignUp(BuildContext context, SignupViewModel viewModel) async {
    final fullName = fullNameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (fullName.isEmpty) {
      _showSnackBar(context, "Please enter your full name");
      return;
    }

    if (email.isEmpty) {
      _showSnackBar(context, "Please enter your email address");
      return;
    }

    if (!email.contains('@')) {
      _showSnackBar(context, "Please enter a valid email address");
      return;
    }

    if (password.isEmpty) {
      _showSnackBar(context, "Please create a password");
      return;
    }

    if (password.length < 6) {
      _showSnackBar(context, "Password must be at least 6 characters");
      return;
    }

    if (confirmPassword.isEmpty) {
      _showSnackBar(context, "Please confirm your password");
      return;
    }

    if (password != confirmPassword) {
      _showSnackBar(context, "Passwords do not match");
      return;
    }

    if (!agreeToTerms) {
      _showSnackBar(context, "Please agree to Terms & Conditions");
      return;
    }

    try {
      await viewModel.signup();
      // _showSnackBar("Sign up button clicked");
    } on FirebaseAuthException catch (e) {
      String message = _handleError(e);
      if (context.mounted) { _showSnackBar(context, message); }
    }
    // Later you can replace this with Firebase sign up logic
  }

  String _handleError(FirebaseAuthException e) {
    switch (e.code) {
      case "email-already-in-use": return "This email is already associated with another account. Please try another email address.";
      default: return "";
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SignupViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildHeader(),
              const SizedBox(height: 36),
              _buildForm(context, viewModel),
              const SizedBox(height: 24),
              _buildSignUpButton(context, viewModel),
              const SizedBox(height: 28),
              _buildDivider(),
              const SizedBox(height: 24),
              _buildSocialButtons(),
              const SizedBox(height: 28),
              _buildFooter(context),
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
        const SizedBox(height: 28),
        const Center(
          child: Text(
            'Create Account',
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
            'Sign up to get started',
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

  Widget _buildForm(BuildContext context, SignupViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Full Name'),
        const SizedBox(height: 8),
        _buildTextField(
          controller: fullNameController,
          hintText: 'Enter your full name',
          onChange: viewModel.updateFullName
        ),
        const SizedBox(height: 20),

        _buildLabel('Email Address'),
        const SizedBox(height: 8),
        _buildTextField(
          controller: emailController,
          hintText: 'name@example.com',
          onChange: viewModel.updateEmail,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 20),

        _buildLabel('Password'),
        const SizedBox(height: 8),
        _buildTextField(
          controller: passwordController,
          hintText: 'Create a password',
          obscureText: obscurePassword,
          onChange: viewModel.updatePassword,
          suffixIcon: IconButton(
            onPressed: () {
              setState(() {
                obscurePassword = !obscurePassword;
              });
            },
            icon: Icon(
              obscurePassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: const Color(0xFF6B7280),
              size: 20,
            ),
          ),
        ),
        const SizedBox(height: 20),

        _buildLabel('Confirm Password'),
        const SizedBox(height: 8),
        _buildTextField(
          controller: confirmPasswordController,
          hintText: 'Confirm your password',
          obscureText: obscureConfirmPassword,
          onChange: viewModel.updateConfirmPassword,
          suffixIcon: IconButton(
            onPressed: () {
              setState(() {
                obscureConfirmPassword = !obscureConfirmPassword;
              });
            },
            icon: Icon(
              obscureConfirmPassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: const Color(0xFF6B7280),
              size: 20,
            ),
          ),
        ),
        const SizedBox(height: 20),

        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 20,
              width: 20,
              child: Checkbox(
                value: agreeToTerms,
                onChanged: (bool? value) {
                  setState(() {
                    agreeToTerms = value ?? false;
                  });
                },
                side: const BorderSide(color: Color(0xFFD1D5DC)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                activeColor: const Color(0xFFCE1126),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            const SizedBox(width: 10),
            RichText(
              text: const TextSpan(
                style: TextStyle(fontSize: 14, fontFamily: 'Inter'),
                children: [
                  TextSpan(
                    text: 'I agree to ',
                    style: TextStyle(color: Color(0xFF364153)),
                  ),
                  TextSpan(
                    text: 'Terms & Conditions',
                    style: TextStyle(
                      color: Color(0xFFCE1126),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSignUpButton(BuildContext context, SignupViewModel viewModel) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: isLoading ? null : () => _handleSignUp(context, viewModel),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFCE1126),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
          'Sign Up',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: const [
        Expanded(child: Divider(color: Color(0xFFD1D5DC), thickness: 1)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'or continue with',
            style: TextStyle(
              color: Color(0xFF717182),
              fontSize: 14,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        Expanded(child: Divider(color: Color(0xFFD1D5DC), thickness: 1)),
      ],
    );
  }

  Widget _buildSocialButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFD1D5DC)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
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
                    color: Color(0xFF364153),
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
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
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: Colors.white,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.apple, color: Colors.black, size: 18),
                SizedBox(width: 8),
                Text(
                  'Apple',
                  style: TextStyle(
                    color: Color(0xFF364153),
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Center(
      child: Text.rich(
        TextSpan(
          children: [
            const TextSpan(
              text: 'Already have an account? ',
              style: TextStyle(
                color: Color(0xFF364153),
                fontSize: 14,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
              ),
            ),
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: GestureDetector(
                onTap: () {
                  context.pop();
                },
                child: const Text(
                  'Log in',
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
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.black,
        fontSize: 14,
        fontFamily: 'Inter',
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    required void Function(String)? onChange
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      onChanged: onChange,
      decoration: InputDecoration(
        hintText: hintText,
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
        suffixIcon: suffixIcon,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFD1D5DC), width: 1.18),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFCE1126), width: 1.5),
        ),
      ),
    );
  }
}