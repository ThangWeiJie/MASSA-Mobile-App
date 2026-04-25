import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
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
          _infoRow(Icons.person_outline, "Full Name", "Jane Doe"),
          _infoRow(Icons.email_outlined, "Email", "jane.doe@example.com"),
          _infoRow(Icons.phone_android, "Phone", "+1 234 567 890"),

          const SizedBox(height: 30),

          _buildSectionHeader("Membership Status"),
          const SizedBox(height: 10),
          _infoRow(Icons.card_membership, "Member ID", "#CLUB-99283"),
          _infoRow(Icons.verified_user_outlined, "Role", "Member"),
          _infoRow(Icons.calendar_month, "Renewal Date", "Dec 31, 2026"),

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
