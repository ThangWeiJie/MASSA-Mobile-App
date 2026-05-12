import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:massa/view_models/features/events/create_event_viewmodel.dart';

class CreateEventPage extends StatelessWidget {
  const CreateEventPage({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CreateEventViewModel>();

    return Scaffold(
      backgroundColor: Colors.transparent, // Background is handled by BackdropFilter
      body: Stack(
        children: [
          // Dismiss modal when clicking background
          GestureDetector(
            onTap: () => context.pop(),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: Container(color: Colors.transparent),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 40.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 450),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.amber[200]!, width: 2),
                    boxShadow: const [
                      BoxShadow(color: Colors.black26, blurRadius: 24, offset: Offset(0, 10)),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildModalHeader(context),
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: viewModel.isLoading
                            ? const Padding(
                                padding: EdgeInsets.all(48.0),
                                child: CircularProgressIndicator(color: Colors.amber),
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildTextField(label: 'Event Title', controller: viewModel.nameController, hintText: 'Enter title'),
                                  const SizedBox(height: 16),
                                  _buildDescriptionField(viewModel),
                                  const SizedBox(height: 16),
                                  _buildDateTimePickers(context, viewModel),
                                  const SizedBox(height: 16),
                                  _buildTextField(label: 'Location', controller: viewModel.locationController, hintText: 'Event location'),
                                  const SizedBox(height: 16),
                                  _buildTextField(label: 'Capacity', controller: viewModel.capacityController, hintText: 'e.g., 50', keyboardType: TextInputType.number),
                                  const SizedBox(height: 24),
                                  
                                  if (viewModel.errorMessage != null)
                                    _buildErrorText(viewModel.errorMessage!),

                                  _buildActionButtons(context, viewModel),
                                ],
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModalHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange[600]!, Colors.amber[600]!, Colors.yellow[700]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Create Event", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.close_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, CreateEventViewModel viewModel) {
    return Row(
      children: [
        // CANCEL BUTTON
        Expanded(
          child: OutlinedButton(
            onPressed: () => context.pop(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: BorderSide(color: Colors.grey[300]!),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Cancel', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(width: 12),
        // CREATE BUTTON
        Expanded(
          flex: 2,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.orange[600]!, Colors.amber[600]!]),
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))],
            ),
            child: ElevatedButton(
              onPressed: () async {
                final success = await viewModel.saveEvent();
                if (success && context.mounted) context.pop("success");
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Create Event', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      ],
    );
  }

  // --- Reused UI Components ---

  Widget _buildDateTimePickers(BuildContext context, CreateEventViewModel viewModel) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildPickerField(label: 'Start Date', controller: viewModel.startDateController, onTap: () => viewModel.selectDate(context, true))),
            const SizedBox(width: 12),
            Expanded(child: _buildPickerField(label: 'Start Time', controller: viewModel.startTimeController, onTap: () => viewModel.selectTime(context, true))),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildPickerField(label: 'End Date', controller: viewModel.endDateController, onTap: () => viewModel.selectDate(context, false))),
            const SizedBox(width: 12),
            Expanded(child: _buildPickerField(label: 'End Time', controller: viewModel.endTimeController, onTap: () => viewModel.selectTime(context, false))),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField({required String label, required TextEditingController controller, required String hintText, TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(height: 8),
        TextFormField(controller: controller, keyboardType: keyboardType, decoration: _inputDecoration(hintText)),
      ],
    );
  }

  Widget _buildDescriptionField(CreateEventViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Description', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(height: 8),
        TextFormField(controller: viewModel.descriptionController, maxLines: 3, decoration: _inputDecoration('Describe the event')),
      ],
    );
  }

  Widget _buildPickerField({required String label, required TextEditingController controller, required VoidCallback onTap}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54)),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          readOnly: true,
          onTap: onTap,
          style: const TextStyle(fontSize: 14),
          decoration: _inputDecoration('Select').copyWith(suffixIcon: const Icon(Icons.arrow_drop_down)),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey[50],
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.amber, width: 2)),
    );
  }

  Widget _buildErrorText(String error) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Center(child: Text(error, style: const TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.w600))),
    );
  }
}