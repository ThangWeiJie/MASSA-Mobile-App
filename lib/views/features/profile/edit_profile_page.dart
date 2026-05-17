import 'package:flutter/material.dart';
import 'package:massa/view_models/features/authentication/profile_viewmodel.dart';
import 'package:provider/provider.dart';

class EditProfilePage extends StatefulWidget {
  final bool isAdminEdit;

  const EditProfilePage({super.key, this.isAdminEdit = false});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController fullNameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController departmentController;

  String selectedRole = 'user';

  @override
  void initState() {
    super.initState();

    final user = context.read<ProfileViewModel>().user;

    fullNameController = TextEditingController(text: user?.fullName ?? '');
    emailController = TextEditingController(text: user?.email ?? '');
    phoneController = TextEditingController(text: user?.phone ?? '');
    departmentController = TextEditingController(text: user?.department ?? '');
    selectedRole = user?.role.name ?? 'user';
  }

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    departmentController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final viewModel = context.read<ProfileViewModel>();

    if (fullNameController.text.trim().isEmpty) {
      _showMessage('Full name cannot be empty');
      return;
    }

    try {
      if (widget.isAdminEdit) {
        await viewModel.adminUpdateUserProfile(
          fullName: fullNameController.text.trim(),
          phone: phoneController.text.trim(),
          department: departmentController.text.trim(),
          role: selectedRole,
        );
      } else {
        await viewModel.updateProfile(
          fullName: fullNameController.text.trim(),
          phone: phoneController.text.trim(),
          department: departmentController.text.trim(),
        );
      }

      if (!mounted) return;
      _showMessage('Profile updated successfully');
      Navigator.pop(context);
    } catch (e) {
      _showMessage('Failed to update profile');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ProfileViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFBF0),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          widget.isAdminEdit ? 'Edit User Profile' : 'Edit Profile',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Column(
          children: [
            const SizedBox(height: 8),

            Stack(
              alignment: Alignment.bottomRight,
              children: [
                const CircleAvatar(
                  radius: 48,
                  backgroundColor: Color(0xFFE5E7EB),
                  child: Icon(Icons.person, size: 48, color: Colors.white),
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

            const SizedBox(height: 14),

            if (widget.isAdminEdit)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFCD106),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Admin Access',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),

            const SizedBox(height: 24),

            _buildLabel('Full Name'),
            _buildTextField(fullNameController, 'Enter full name'),

            _buildLabel('Email Address'),
            _buildTextField(emailController, 'Email address', enabled: false),

            _buildLabel('Phone Number'),
            _buildTextField(phoneController, 'Enter phone number'),

            _buildLabel('Faculty / Department'),
            _buildTextField(departmentController, 'Enter department'),

            if (widget.isAdminEdit) ...[
              _buildLabel('User Role'),
              _buildRoleDropdown(),
            ],

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: viewModel.isLoading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFCE1126),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: viewModel.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Save Changes',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFD1D5DC)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8, top: 14),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    bool enabled = true,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: enabled ? Colors.white : const Color(0xFFF7F7F7),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFD1D5DC)),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFD1D5DC)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFCE1126), width: 1.5),
        ),
      ),
    );
  }

  Widget _buildRoleDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: selectedRole,
      items: const [
        DropdownMenuItem(value: 'user', child: Text('Student')),
        DropdownMenuItem(value: 'exco', child: Text('EXCO')),
        DropdownMenuItem(value: 'admin', child: Text('Admin')),
      ],
      onChanged: (value) {
        setState(() {
          selectedRole = value ?? 'user';
        });
      },
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFD1D5DC)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFCE1126), width: 1.5),
        ),
      ),
    );
  }
}
