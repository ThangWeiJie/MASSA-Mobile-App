import 'package:flutter/material.dart';
import 'package:massa/enums/role_enum.dart';
import 'package:massa/models/user.dart';
import 'package:massa/view_models/profile_viewmodel.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ProfileViewModel>();
    final user = context.watch<UserModel?>();

    if (viewModel.isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.indigo,
                  child: Icon(Icons.person, size: 60, color: Colors.white),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.edit, size: 18, color: Colors.indigo),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Section 2: Personal Information
          _buildSectionHeader("Personal Information"),
          const SizedBox(height: 10),
          _infoRow(Icons.person_outline, "Full Name", user?.fullName ?? ''),
          _infoRow(Icons.email_outlined, "Email", viewModel.user?.email ?? ''),

          const SizedBox(height: 30),

          _buildSectionHeader("Membership Status"),
          const SizedBox(height: 10),
          _infoRow(Icons.card_membership, "Member ID", "Temp ID"),
          _infoRow(Icons.verified_user_outlined, "Role", viewModel.user?.role.name ?? Role.user.name),
          _infoRow(Icons.calendar_month, "Joined on", viewModel.user?.memberSince.toString().split(' ').first ?? ''),

          const SizedBox(height: 40),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text(
                  "Update Profile",
                  style: TextStyle(color: Colors.white, fontSize: 16)
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.indigo),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 22),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}
