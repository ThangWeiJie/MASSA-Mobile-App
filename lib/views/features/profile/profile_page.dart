import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:massa/service/features/auth/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:massa/view_models/features/authentication/profile_viewmodel.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _handleLogout(BuildContext context) async {
    try {
      await context.read<AuthService>().signOut();
      if (context.mounted) {
        context.go('/signin');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error signing out: $e"),
            backgroundColor: Colors.red[700],
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ProfileViewModel>();

    return Scaffold(
      body: Container(
        // Consistent Background: Orange/Amber/Yellow Gradient
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.orange[50]!, Colors.amber[50]!, Colors.yellow[50]!],
          ),
        ),
        child: SafeArea(
          child: viewModel.isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.orange),
                )
              : viewModel.user == null
              ? const Center(child: Text("User data not found."))
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 24.0,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 500),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildHeader(),
                          const SizedBox(height: 24),
                          _buildUserCard(context, viewModel),
                          const SizedBox(height: 24),
                          _buildLogoutButton(context),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: List.generate(
            3,
            (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: 6,
              height: 8,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange[600]!, Colors.amber[700]!],
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) => LinearGradient(
            colors: [
              Colors.orange[800]!,
              Colors.amber[700]!,
              Colors.yellow[800]!,
            ],
          ).createShader(bounds),
          child: const Text(
            'Profile',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 12),
        Row(
          children: List.generate(
            3,
            (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: 6,
              height: 8,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange[600]!, Colors.amber[700]!],
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserCard(BuildContext context, ProfileViewModel viewModel) {
    final user = viewModel.user!;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.orange[400]!,
            Colors.amber[300]!,
            Colors.yellow[600]!,
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.all(24),
        child: Stack(
          children: [
            // Traditional Corner Decorations
            Positioned(
              top: 0,
              left: 0,
              child: Row(
                children: List.generate(
                  3,
                  (i) => Container(
                    margin: const EdgeInsets.only(right: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i % 2 == 0
                          ? Colors.orange[400]
                          : Colors.amber[600],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: Row(
                children: List.generate(
                  3,
                  (i) => Container(
                    margin: const EdgeInsets.only(left: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i % 2 == 0
                          ? Colors.orange[400]
                          : Colors.amber[600],
                    ),
                  ),
                ),
              ),
            ),

            Column(
              children: [
                const SizedBox(height: 16),
                // Avatar Section
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.orange[600]!,
                            Colors.amber[500]!,
                            Colors.yellow[700]!,
                          ],
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.amber[100]!.withOpacity(0.5),
                          width: 6,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 12,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                    Positioned(
                      top: -4,
                      right: -4,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: Colors.yellow[400],
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -4,
                      left: -4,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.orange[700],
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  user.fullName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  user.email,
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
                const SizedBox(height: 12),

                // Divider Beadwork
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    10,
                    (i) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i % 3 == 0
                            ? Colors.orange[400]
                            : i % 2 == 0
                            ? Colors.amber[600]
                            : Colors.yellow[600],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Info Rows
                _buildInfoRow(
                  title: 'Email',
                  value: user.email,
                  icon: Icons.mail_outline,
                  bgColor: Colors.orange[50]!,
                  accentColor: Colors.orange[700]!,
                ),
                const SizedBox(height: 16),
                _buildInfoRow(
                  title: 'Matric Number',
                  value: user.matricNumber ?? 'Not Provided',
                  icon: Icons.badge_outlined,
                  bgColor: Colors.amber[50]!,
                  accentColor: Colors.amber[700]!,
                ),
                const SizedBox(height: 16),
                _buildInfoRow(
                  title: 'Role',
                  value: user.role.name.toUpperCase(),
                  icon: Icons.security_outlined,
                  bgColor: Colors.yellow[50]!,
                  accentColor: Colors.yellow[800]!,
                  isAdmin: user.role.name == 'admin',
                ),

                const SizedBox(height: 24),
                const Divider(color: Colors.black12, thickness: 1),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    20,
                    (i) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i % 4 == 0
                            ? Colors.orange[400]
                            : i % 3 == 0
                            ? Colors.amber[600]
                            : i % 2 == 0
                            ? Colors.yellow[600]
                            : Colors.transparent,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required String title,
    required String value,
    required IconData icon,
    required Color bgColor,
    required Color accentColor,
    bool isAdmin = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        // SAFE BORDER: Uniform but themed
        border: Border.all(color: accentColor.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [accentColor, accentColor.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          if (isAdmin)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange[600]!, Colors.deepOrange[700]!],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: const Text(
                'ADMIN',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.red[600]!, Colors.red[800]!]),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () => _handleLogout(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, color: Colors.white, size: 24),
            SizedBox(width: 12),
            Text(
              'Sign Out',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
