import 'package:flutter/material.dart';
import 'package:massa/enums/role_enum.dart';
import 'package:massa/view_models/features/authentication/profile_viewmodel.dart';
import 'package:massa/views/features/profile/edit_profile_page.dart';
import 'package:go_router/go_router.dart';
import 'package:massa/service/features/auth/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:massa/view_models/features/authentication/profile_viewmodel.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

class ProfilePage extends StatelessWidget {
  final bool isAdminView;

  const ProfilePage({super.key, this.isAdminView = false});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ProfileViewModel>();
    final user = viewModel.user;

    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (user == null) {
      return const Center(child: Text('User profile not found'));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: Color(0xFFE5E7EB),
                    child: Icon(Icons.person, size: 50, color: Colors.white),
                  ),
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: const Color(0xFFCE1126),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Text(
                user.fullName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 8),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFCD106),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  user.role == Role.admin ? 'Admin' : 'Student',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _profileInfo('Full Name', user.fullName),
                    _divider(),
                    _profileInfo('Email Address', user.email),
                    _divider(),
                    _profileInfo('Phone Number', user.phone),
                    _divider(),
                    _profileInfo('Faculty / Department', user.department),
                    _divider(),
                    _profileInfo('Member ID', user.uuid),
                    _divider(),
                    _profileInfo(
                      'Joined Date',
                      user.memberSince.toString().split(' ').first,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChangeNotifierProvider.value(
                          value: viewModel,
                          child: EditProfilePage(isAdminEdit: isAdminView),
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit, color: Colors.white, size: 18),
                  label: const Text(
                    'Edit Profile',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFCE1126),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _profileInfo(String label, String value) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              value.isEmpty ? '-' : value,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() {
    return const Divider(height: 1, thickness: 1, color: Color(0xFFE5E7EB));
  }
}
