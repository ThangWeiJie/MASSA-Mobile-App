import 'dart:ui';
import 'package:file_picker/file_picker.dart';
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
      backgroundColor:
          Colors.transparent, // Background is handled by BackdropFilter
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
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 40.0,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 450),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.amber[200]!, width: 2),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 24,
                        offset: Offset(0, 10),
                      ),
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
                                child: CircularProgressIndicator(
                                  color: Colors.amber,
                                ),
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildTextField(
                                    label: 'Event Title',
                                    controller: viewModel.nameController,
                                    hintText: 'Enter title',
                                  ),
                                  const SizedBox(height: 16),
                                  _buildDescriptionField(viewModel),
                                  const SizedBox(height: 16),
                                  _buildPhotoPicker(viewModel),
                                  const SizedBox(height: 16),
                                  _buildDateTimePickers(context, viewModel),
                                  const SizedBox(height: 16),
                                  _buildTextField(
                                    label: 'Location',
                                    controller: viewModel.locationController,
                                    hintText: 'Event location',
                                  ),
                                  const SizedBox(height: 16),
                                  _buildTextField(
                                    label: 'Capacity',
                                    controller: viewModel.capacityController,
                                    hintText: 'e.g., 50',
                                    keyboardType: TextInputType.number,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildCrewRegistrationSection(
                                    context,
                                    viewModel,
                                  ),
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
          colors: [
            Colors.orange[600]!,
            Colors.amber[600]!,
            Colors.yellow[700]!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Create Event",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.close_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    CreateEventViewModel viewModel,
  ) {
    return Row(
      children: [
        // CANCEL BUTTON
        Expanded(
          child: OutlinedButton(
            onPressed: () => context.pop(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: BorderSide(color: Colors.grey[300]!),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // CREATE BUTTON
        Expanded(
          flex: 2,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange[600]!, Colors.amber[600]!],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Create Event',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- Reused UI Components ---

  Widget _buildCrewRegistrationSection(
    BuildContext context,
    CreateEventViewModel viewModel,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.amber[50]!.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.amber[200]!),
      ),
      child: Column(
        children: [
          SwitchListTile.adaptive(
            value: viewModel.isCrewRegistrationOpen,
            onChanged: viewModel.toggleCrewRegistration,
            activeThumbColor: Colors.orange[700],
            activeTrackColor: Colors.orange[200],
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            title: const Text(
              'Open Crew Registration',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
            secondary: Icon(Icons.groups_2_outlined, color: Colors.orange[700]),
          ),
          if (viewModel.isCrewRegistrationOpen)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMultilineTextField(
                    label: 'Crew Description',
                    controller: viewModel.crewRegistrationDescriptionController,
                    hintText: 'Describe the crew responsibilities',
                  ),
                  const SizedBox(height: 14),
                  _buildCrewUnitPicker(viewModel),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _buildPickerField(
                          label: 'Crew Deadline',
                          controller:
                              viewModel.crewRegistrationDeadlineController,
                          onTap: () =>
                              viewModel.selectCrewRegistrationDeadline(context),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          label: 'Crew Slots',
                          controller: viewModel.crewCapacityController,
                          hintText: 'e.g., 12',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _buildMultilineTextField(
                    label: 'Requirements',
                    controller: viewModel.crewRequirementsController,
                    hintText: 'Skills, commitment, dress code, or notes',
                  ),
                  const SizedBox(height: 14),
                  _buildTextField(
                    label: 'Contact / PIC',
                    controller: viewModel.crewContactInfoController,
                    hintText: 'Name, phone, Telegram, or email',
                  ),
                  const SizedBox(height: 14),
                  _buildMultilineTextField(
                    label: 'Applicant Questions',
                    controller: viewModel.crewApplicantInstructionsController,
                    hintText:
                        'Availability, past experience, preferred unit, phone number',
                  ),
                  const SizedBox(height: 14),
                  _buildTextField(
                    label: 'Crew WhatsApp / Telegram Link',
                    controller: viewModel.crewWhatsappGroupLinkController,
                    hintText: 'Optional group invite link',
                    keyboardType: TextInputType.url,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCrewUnitPicker(CreateEventViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'List of Units',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: viewModel.crewUnitController,
                onFieldSubmitted: (_) => viewModel.addCrewUnit(),
                decoration: _inputDecoration('Protocol, Media, Food, Safety'),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 48,
              height: 48,
              child: IconButton.filled(
                onPressed: viewModel.addCrewUnit,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.orange[700],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.add),
              ),
            ),
          ],
        ),
        if (viewModel.crewUnits.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(viewModel.crewUnits.length, (index) {
              return InputChip(
                label: Text(viewModel.crewUnits[index]),
                onDeleted: () => viewModel.removeCrewUnit(index),
                deleteIcon: const Icon(Icons.close, size: 16),
                backgroundColor: Colors.orange[50],
                side: BorderSide(color: Colors.amber[300]!),
                labelStyle: TextStyle(
                  color: Colors.orange[900],
                  fontWeight: FontWeight.w600,
                ),
              );
            }),
          ),
        ],
      ],
    );
  }

  Widget _buildPhotoPicker(CreateEventViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Event Photos',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: viewModel.pickImages,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
            side: BorderSide(color: Colors.amber[300]!),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            foregroundColor: Colors.orange[800],
          ),
          icon: const Icon(Icons.add_photo_alternate_outlined),
          label: Text(
            viewModel.selectedImages.isEmpty ? 'Add Photos' : 'Add More Photos',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        if (viewModel.selectedImages.isNotEmpty) ...[
          const SizedBox(height: 12),
          SizedBox(
            height: 112,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: viewModel.selectedImages.length,
              separatorBuilder: (context, index) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final image = viewModel.selectedImages[index];
                final isMain = index == viewModel.mainImageIndex;

                return _SelectedEventImageTile(
                  image: image,
                  isMain: isMain,
                  onSetMain: () => viewModel.setMainImage(index),
                  onRemove: () => viewModel.removeImage(index),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDateTimePickers(
    BuildContext context,
    CreateEventViewModel viewModel,
  ) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildPickerField(
                label: 'Start Date',
                controller: viewModel.startDateController,
                onTap: () => viewModel.selectDate(context, true),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildPickerField(
                label: 'Start Time',
                controller: viewModel.startTimeController,
                onTap: () => viewModel.selectTime(context, true),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildPickerField(
                label: 'End Date',
                controller: viewModel.endDateController,
                onTap: () => viewModel.selectDate(context, false),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildPickerField(
                label: 'End Time',
                controller: viewModel.endTimeController,
                onTap: () => viewModel.selectTime(context, false),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: _inputDecoration(hintText),
        ),
      ],
    );
  }

  Widget _buildDescriptionField(CreateEventViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Description',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: viewModel.descriptionController,
          maxLines: 3,
          decoration: _inputDecoration('Describe the event'),
        ),
      ],
    );
  }

  Widget _buildMultilineTextField({
    required String label,
    required TextEditingController controller,
    required String hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: 3,
          decoration: _inputDecoration(hintText),
        ),
      ],
    );
  }

  Widget _buildPickerField({
    required String label,
    required TextEditingController controller,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          readOnly: true,
          onTap: onTap,
          style: const TextStyle(fontSize: 14),
          decoration: _inputDecoration(
            'Select',
          ).copyWith(suffixIcon: const Icon(Icons.arrow_drop_down)),
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
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[200]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.amber, width: 2),
      ),
    );
  }

  Widget _buildErrorText(String error) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Center(
        child: Text(
          error,
          style: const TextStyle(
            color: Colors.red,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _SelectedEventImageTile extends StatelessWidget {
  final PlatformFile image;
  final bool isMain;
  final VoidCallback onSetMain;
  final VoidCallback onRemove;

  const _SelectedEventImageTile({
    required this.image,
    required this.isMain,
    required this.onSetMain,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final imageBytes = image.bytes;

    return GestureDetector(
      onTap: onSetMain,
      child: SizedBox(
        width: 120,
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: imageBytes == null
                    ? Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.image_not_supported_outlined),
                      )
                    : Image.memory(imageBytes, fit: BoxFit.cover),
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isMain ? Colors.orange[700]! : Colors.grey[300]!,
                    width: isMain ? 3 : 1,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 6,
              bottom: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isMain ? Colors.orange[700] : Colors.black54,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  isMain ? 'Main' : 'Make Main',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: InkWell(
                onTap: onRemove,
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
