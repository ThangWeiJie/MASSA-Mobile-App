import 'package:flutter/material.dart';
import 'package:massa/view_models/features/events/create_event_viewmodel.dart';
import 'package:provider/provider.dart';

class CreateEventPage extends StatelessWidget {
  const CreateEventPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Listens to the ViewModel provided by GoRouter
    final viewModel = context.watch<CreateEventViewModel>();

    return viewModel.isLoading
        ? const Center(child: CircularProgressIndicator())
        : Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Custom Header (Replaces AppBar)
          const Text(
            "Add New Event",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4A3780),
            ),
          ),
          const SizedBox(height: 24),

          // 2. Scrollable Form Content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event Name Field
                  TextFormField(
                    controller: viewModel.nameController,
                    decoration: InputDecoration(
                      labelText: 'Name of event',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.cancel_outlined, color: Colors.grey),
                        onPressed: () => viewModel.nameController.clear(),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF4F4F4),
                      border: const UnderlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Start Date & Time
                  Row(
                    children: [
                      Expanded(
                        child: _buildPickerField(
                          label: 'Start Date',
                          controller: viewModel.startDateController,
                          icon: Icons.calendar_month,
                          onTap: () => viewModel.selectDate(context, viewModel.startDateController),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildPickerField(
                          label: 'Start Time',
                          controller: viewModel.startTimeController,
                          onTap: () => viewModel.selectTime(context, viewModel.startTimeController),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // End Date & Time
                  Row(
                    children: [
                      Expanded(
                        child: _buildPickerField(
                          label: 'End Date',
                          controller: viewModel.endDateController,
                          icon: Icons.calendar_month,
                          onTap: () => viewModel.selectDate(context, viewModel.endDateController),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildPickerField(
                          label: 'End Time',
                          controller: viewModel.endTimeController,
                          onTap: () => viewModel.selectTime(context, viewModel.endTimeController),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Description Field
                  TextFormField(
                    controller: viewModel.descriptionController,
                    maxLines: 6,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      alignLabelWithHint: true,
                      filled: true,
                      fillColor: Color(0xFFF4F4F4),
                      border: InputBorder.none,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // 3. Save Button pinned to bottom
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: () => viewModel.saveEvent(),
              icon: const Icon(Icons.calendar_today_outlined, size: 20),
              label: const Text(
                'Save',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE5D9F2),
                foregroundColor: const Color(0xFF4A3780),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // UI Helper for the Outlined Date/Time boxes
  Widget _buildPickerField({
    required String label,
    required TextEditingController controller,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: label,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: icon != null ? Icon(icon, color: Colors.grey) : null,
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF4A3780), width: 1.5),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF4A3780), width: 2.0),
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      ),
    );
  }
}