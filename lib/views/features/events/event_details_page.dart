import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:massa/models/crew_application.dart';
import 'package:massa/models/event.dart';
import 'package:provider/provider.dart';
import 'package:massa/enums/role_enum.dart';
import 'package:massa/models/user.dart';
import 'package:massa/tab_list.dart';
import 'package:massa/views/features/events/widgets/event_image_gallery.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../view_models/features/events/event_details_viewmodel.dart';

class EventDetailsPage extends StatelessWidget {
  const EventDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch the viewModel to rebuild when registration status changes
    final viewModel = context.watch<EventDetailsViewModel>();
    final currentUser = context.read<UserModel?>();
    final canManageDocumentation = currentUser?.role.canManageEvents ?? false;
    final canManageEvent = currentUser?.role.canManageEvents ?? false;

    // Loading State (Merged with MASSA orange theme)
    if (viewModel.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.orange)),
      );
    }

    final event = viewModel.event;
    // Null Event State (Merged with better UX navigation)
    if (event == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Event not found",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () => context.pop(),
                child: const Text("Back to Programs"),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.amber[50]!, Colors.orange[50]!, Colors.yellow[50]!],
          ),
        ),
        child: Stack(
          children: [
            // Background Decorative Icons
            Positioned(
              top: 100,
              right: -20,
              child: Icon(
                Icons.wb_sunny_outlined,
                size: 200,
                color: Colors.amber[200]!.withValues(alpha: 0.3),
              ),
            ),

            SafeArea(
              child: Column(
                children: [
                  _buildTopNav(context),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildMainCard(
                            context,
                            viewModel,
                            canManageDocumentation,
                            canManageEvent,
                          ),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopNav(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.brown,
            ),
            onPressed: () => context.pop(),
          ),
          const Text(
            "Back to Programs",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.brown),
          ),
        ],
      ),
    );
  }

  Widget _buildMainCard(
    BuildContext context,
    EventDetailsViewModel viewModel,
    bool canManageDocumentation,
    bool canManageEvent,
  ) {
    final event = viewModel.event!;

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF59E0B), Color(0xFFEA580C), Color(0xFFDC2626)],
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.amber[600]!, Colors.orange[700]!],
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBeadworkRow(),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          event.eventName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (canManageEvent) _buildAdminActions(context, viewModel),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildInfoChip(
                    Icons.people,
                    "${event.registeredCount} / ${event.capacity} registered",
                  ),
                  const SizedBox(height: 20),
                  _buildMetaIconRow(
                    Icons.calendar_today,
                    DateFormat(
                      'EEEE, MMMM dd, yyyy',
                    ).format(event.startDateTime),
                  ),
                  _buildMetaIconRow(
                    Icons.access_time,
                    DateFormat('jm').format(event.startDateTime),
                  ),
                  _buildMetaIconRow(Icons.map_outlined, event.location),
                ],
              ),
            ),

            // Content Section
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (event.displayImageUrls.isNotEmpty) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: EventImageCarousel(
                        imageUrls: event.displayImageUrls,
                        aspectRatio: 4 / 3,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  _buildSectionHeader("About this event"),
                  const SizedBox(height: 12),
                  Text(
                    event.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[800],
                      height: 1.6,
                    ),
                  ),
                  if (event.isCrewRegistrationOpen) ...[
                    const SizedBox(height: 24),
                    _buildCrewRegistrationInfo(event),
                  ],
                  const SizedBox(height: 24),
                  _buildActionButtons(
                    context,
                    viewModel,
                    canManageDocumentation,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBeadworkRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        20,
        (i) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          width: 4,
          height: 4,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: i % 3 == 0
                ? Colors.yellow[300]
                : i % 2 == 0
                ? Colors.orange[300]
                : Colors.white24,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaIconRow(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Column(
          children: List.generate(
            3,
            (i) => Container(
              margin: const EdgeInsets.symmetric(vertical: 1),
              width: 3,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.orange[700],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildCrewRegistrationInfo(Event event) {
    final deadline = event.crewRegistrationDeadline;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader("Crew Registration"),
        const SizedBox(height: 12),
        _buildCrewStatusChip(),
        if (event.crewRegistrationDescription.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            event.crewRegistrationDescription,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[800],
              height: 1.5,
            ),
          ),
        ],
        if (event.crewUnits.isNotEmpty) ...[
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: event.crewUnits.map((unit) {
              return Chip(
                label: Text(unit),
                backgroundColor: Colors.orange[50],
                side: BorderSide(color: Colors.amber[300]!),
                labelStyle: TextStyle(
                  color: Colors.orange[900],
                  fontWeight: FontWeight.w600,
                ),
              );
            }).toList(),
          ),
        ],
        if (event.crewCapacity > 0)
          _buildCrewInfoRow(
            Icons.badge_outlined,
            'Crew slots',
            event.crewCapacity.toString(),
          ),
        if (deadline != null)
          _buildCrewInfoRow(
            Icons.event_available_outlined,
            'Deadline',
            DateFormat('MMMM d, y').format(deadline),
          ),
        if (event.crewRequirements.isNotEmpty)
          _buildCrewInfoRow(
            Icons.fact_check_outlined,
            'Requirements',
            event.crewRequirements,
          ),
        if (event.crewContactInfo.isNotEmpty)
          _buildCrewInfoRow(
            Icons.support_agent_outlined,
            'Contact',
            event.crewContactInfo,
          ),
        if (event.crewApplicantInstructions.isNotEmpty)
          _buildCrewInfoRow(
            Icons.quiz_outlined,
            'Applicant questions',
            event.crewApplicantInstructions,
          ),
      ],
    );
  }

  Widget _buildCrewStatusChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.groups_2_outlined, size: 16, color: Colors.green[700]),
          const SizedBox(width: 6),
          Text(
            'Crew Registration Open',
            style: TextStyle(
              color: Colors.green[800],
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCrewInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: Colors.amber[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: Colors.orange[800]),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminActions(
    BuildContext context,
    EventDetailsViewModel viewModel,
  ) {
    return Row(
      children: [
        _buildCircleIconButton(
          Icons.people_outline,
          () => context.push('/events/details/${viewModel.eventId}/attendees'),
        ),
        const SizedBox(width: 8),
        _buildCircleIconButton(
          Icons.edit,
          () => _showEditEventDialog(context, viewModel),
        ),
        const SizedBox(width: 8),
        _buildCircleIconButton(
          Icons.delete_outline,
          () => _showDeleteConfirm(context, viewModel),
        ),
      ],
    );
  }

  Widget _buildCircleIconButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white24,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    EventDetailsViewModel viewModel,
    bool canManageDocumentation,
  ) {
    final event = viewModel.event!;
    final isRegistered = viewModel.isUserRegistered;
    final isFull = event.registeredCount >= event.capacity;

    return Column(
      children: [
        // Documentation management access for EXCO and Admin
        if (canManageDocumentation) ...[
          if (event.isCrewRegistrationOpen) ...[
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  context.push('/events/details/${event.id}/crew-applications');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.groups_2_outlined, color: Colors.white),
                label: const Text(
                  'Review Crew Applications',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () {
                context.push('/events/details/${event.id}/documentation');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFCE1126),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.folder_open, color: Colors.white),
              label: const Text(
                'Manage Documentation',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Registration Button Logic
        if (!canManageDocumentation) ...[
          if (event.isCrewRegistrationOpen) ...[
            _buildCrewApplicationAction(context, viewModel),
            const SizedBox(height: 12),
          ],
          _buildEventRegistrationButton(
            context: context,
            viewModel: viewModel,
            isFull: isFull,
            isRegistered: isRegistered,
          ),
        ],
      ],
    );
  }

  Widget _buildEventRegistrationButton({
    required BuildContext context,
    required EventDetailsViewModel viewModel,
    required bool isFull,
    required bool isRegistered,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: viewModel.isActionLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.orange))
          : ElevatedButton(
              onPressed: (isFull && !isRegistered)
                  ? null
                  : () async {
                      final registering = !viewModel.isUserRegistered;
                      try {
                        await viewModel.toggleRegistration();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                registering
                                    ? "Registration successful!"
                                    : "Successfully unregistered",
                              ),
                              backgroundColor: registering
                                  ? Colors.green[700]
                                  : Colors.red[700],
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(e.toString()),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: isRegistered
                    ? Colors.red[600]
                    : Colors.orange[800],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 5,
              ),
              child: Text(
                isRegistered
                    ? "Unregister from Event"
                    : (isFull ? "Event Full" : "Register Now"),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
    );
  }

  Widget _buildCrewApplicationAction(
    BuildContext context,
    EventDetailsViewModel viewModel,
  ) {
    final event = viewModel.event!;
    final application = viewModel.crewApplication;

    if (application == null) {
      return SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton.icon(
          onPressed:
              event.isCrewRegistrationAvailable && !viewModel.isActionLoading
              ? () => _showCrewApplicationForm(context, viewModel)
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[700],
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey[300],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          icon: const Icon(Icons.assignment_ind_outlined),
          label: Text(
            event.isCrewRegistrationAvailable
                ? 'Apply as Crew'
                : 'Crew Applications Closed',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      );
    }

    if (application.status == CrewApplicationStatus.accepted) {
      return Column(
        children: [
          _buildCrewStatusButton(
            label: 'You are Crew! ${application.assignedUnit}',
            color: Colors.green,
            icon: Icons.verified,
          ),
          if (application.inviteLink.isNotEmpty) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () => _openInviteLink(application.inviteLink),
                icon: const Icon(Icons.chat_outlined),
                label: const Text('Open Crew Group Link'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.green[800],
                  side: BorderSide(color: Colors.green[300]!),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ],
      );
    }

    if (application.status == CrewApplicationStatus.declined) {
      return _buildCrewStatusButton(
        label: 'Quota Filled',
        color: Colors.grey,
        icon: Icons.block,
      );
    }

    if (application.status == CrewApplicationStatus.waitlisted) {
      return _buildCrewStatusButton(
        label: 'Application Waitlisted',
        color: Colors.blue,
        icon: Icons.visibility_outlined,
      );
    }

    return _buildCrewStatusButton(
      label: 'Application Pending',
      color: Colors.grey,
      icon: Icons.hourglass_top,
    );
  }

  Widget _buildCrewStatusButton({
    required String label,
    required MaterialColor color,
    required IconData icon,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: null,
        style: ElevatedButton.styleFrom(
          disabledBackgroundColor: color[100],
          disabledForegroundColor: color[800],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        icon: Icon(icon),
        label: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }

  Future<void> _openInviteLink(String link) async {
    final uri = Uri.tryParse(link);

    if (uri == null) return;

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _showCrewApplicationForm(
    BuildContext context,
    EventDetailsViewModel viewModel,
  ) async {
    final event = viewModel.event!;
    final currentUser = context.read<UserModel?>();

    if (currentUser == null || event.crewUnits.isEmpty) return;

    final result = await showDialog<_CrewApplicationFormResult>(
      context: context,
      builder: (dialogContext) => _CrewApplicationFormDialog(event: event),
    );

    if (result == null) return;

    try {
      await viewModel.applyForCrew(
        applicant: currentUser,
        firstChoiceUnit: result.firstChoiceUnit,
        secondChoiceUnit: result.secondChoiceUnit,
        pitch: result.pitch,
        commitmentAccepted: result.commitmentAccepted,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Crew application submitted.'),
            backgroundColor: Colors.green[700],
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red[700],
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _showEditEventDialog(
    BuildContext context,
    EventDetailsViewModel viewModel,
  ) async {
    final event = viewModel.event;
    if (event == null) return;

    final nameController = TextEditingController(text: event.eventName);
    final descriptionController = TextEditingController(
      text: event.description,
    );
    final locationController = TextEditingController(text: event.location);
    final capacityController = TextEditingController(
      text: event.capacity.toString(),
    );

    DateTime startDateTime = event.startDateTime;
    DateTime endDateTime = event.endDateTime;
    String? errorText;

    Future<void> pickDateTime({
      required BuildContext dialogContext,
      required StateSetter setDialogState,
      required bool isStart,
    }) async {
      final current = isStart ? startDateTime : endDateTime;
      final pickedDate = await showDatePicker(
        context: dialogContext,
        initialDate: current,
        firstDate: DateTime(2020),
        lastDate: DateTime(2100),
      );

      if (pickedDate == null || !dialogContext.mounted) return;

      final pickedTime = await showTimePicker(
        context: dialogContext,
        initialTime: TimeOfDay.fromDateTime(current),
      );

      if (pickedTime == null) return;

      setDialogState(() {
        final updated = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        if (isStart) {
          startDateTime = updated;
        } else {
          endDateTime = updated;
        }
        errorText = null;
      });
    }

    Future<void> saveChanges({
      required BuildContext dialogContext,
      required StateSetter setDialogState,
    }) async {
      final eventName = nameController.text.trim();
      final description = descriptionController.text.trim();
      final location = locationController.text.trim();
      final capacity = int.tryParse(capacityController.text.trim());

      if (eventName.isEmpty ||
          description.isEmpty ||
          location.isEmpty ||
          capacity == null ||
          capacity <= 0) {
        setDialogState(() {
          errorText = 'Please complete all fields with a valid capacity.';
        });
        return;
      }

      if (!endDateTime.isAfter(startDateTime)) {
        setDialogState(() {
          errorText = 'End time must be after start time.';
        });
        return;
      }

      final updateData = {
        'eventName': eventName,
        'description': description,
        'location': location,
        'capacity': capacity,
        'startDateTime': startDateTime,
        'endDateTime': endDateTime,
      };

      Navigator.of(dialogContext).pop();
      if (!context.mounted) return;

      final messenger = ScaffoldMessenger.of(context);
      final success = await viewModel.updateEvent(updateData);

      if (!context.mounted) return;

      if (success) {
        messenger.showSnackBar(
          SnackBar(
            content: const Text('Event updated successfully.'),
            backgroundColor: Colors.green[700],
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      messenger.showSnackBar(
        SnackBar(
          content: const Text('Unable to update event. Please try again.'),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    try {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (dialogContext, setDialogState) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                title: const Text('Edit Event'),
                content: SizedBox(
                  width: 420,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: 'Event title',
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: descriptionController,
                          minLines: 3,
                          maxLines: 5,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                            alignLabelWithHint: true,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: locationController,
                          decoration: const InputDecoration(
                            labelText: 'Location',
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: capacityController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Capacity',
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildDateTimeEditorRow(
                          label: 'Start',
                          value: startDateTime,
                          onTap: () => pickDateTime(
                            dialogContext: dialogContext,
                            setDialogState: setDialogState,
                            isStart: true,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildDateTimeEditorRow(
                          label: 'End',
                          value: endDateTime,
                          onTap: () => pickDateTime(
                            dialogContext: dialogContext,
                            setDialogState: setDialogState,
                            isStart: false,
                          ),
                        ),
                        if (errorText != null) ...[
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              errorText!,
                              style: TextStyle(
                                color: Colors.red[700],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () => saveChanges(
                      dialogContext: dialogContext,
                      setDialogState: setDialogState,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange[700],
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Save'),
                  ),
                ],
              );
            },
          );
        },
      );
    } finally {
      nameController.dispose();
      descriptionController.dispose();
      locationController.dispose();
      capacityController.dispose();
    }
  }

  Widget _buildDateTimeEditorRow({
    required String label,
    required DateTime value,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.orange[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange[100]!),
        ),
        child: Row(
          children: [
            Icon(Icons.event_outlined, color: Colors.orange[800], size: 20),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Flexible(
              flex: 3,
              child: Text(
                DateFormat('MMM d, yyyy - h:mm a').format(value),
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirm(
    BuildContext pageContext,
    EventDetailsViewModel viewModel,
  ) {
    showDialog(
      context: pageContext,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text("Delete Event?"),
        content: const Text("Are you sure? This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(pageContext);
              final success = await viewModel.deleteEvent();

              if (!dialogContext.mounted) return;
              Navigator.of(dialogContext).pop();

              if (!pageContext.mounted) return;

              if (success) {
                pageContext.go(eventPath);
                messenger.showSnackBar(
                  SnackBar(
                    content: const Text('Event deleted successfully.'),
                    backgroundColor: Colors.green[700],
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                return;
              }

              messenger.showSnackBar(
                SnackBar(
                  content: const Text('Unable to delete event.'),
                  backgroundColor: Colors.red[700],
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _CrewApplicationFormResult {
  final String firstChoiceUnit;
  final String secondChoiceUnit;
  final String pitch;
  final bool commitmentAccepted;

  const _CrewApplicationFormResult({
    required this.firstChoiceUnit,
    required this.secondChoiceUnit,
    required this.pitch,
    required this.commitmentAccepted,
  });
}

class _CrewApplicationFormDialog extends StatefulWidget {
  final Event event;

  const _CrewApplicationFormDialog({required this.event});

  @override
  State<_CrewApplicationFormDialog> createState() =>
      _CrewApplicationFormDialogState();
}

class _CrewApplicationFormDialogState
    extends State<_CrewApplicationFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _pitchController = TextEditingController();

  late String _firstChoice;
  late String _secondChoice;
  bool _commitmentAccepted = false;

  @override
  void initState() {
    super.initState();
    _firstChoice = widget.event.crewUnits.first;
    _secondChoice = widget.event.crewUnits.length > 1
        ? widget.event.crewUnits[1]
        : '';
  }

  @override
  void dispose() {
    _pitchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final secondChoiceOptions = widget.event.crewUnits
        .where((unit) => unit != _firstChoice)
        .toList();

    if (secondChoiceOptions.isNotEmpty &&
        !secondChoiceOptions.contains(_secondChoice)) {
      _secondChoice = secondChoiceOptions.first;
    }

    return AlertDialog(
      title: const Text('Apply as Crew'),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: _firstChoice,
                  decoration: const InputDecoration(
                    labelText: 'First choice unit',
                  ),
                  items: widget.event.crewUnits.map((unit) {
                    return DropdownMenuItem(value: unit, child: Text(unit));
                  }).toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _firstChoice = value;
                      final updatedSecondChoiceOptions = widget.event.crewUnits
                          .where((unit) => unit != value)
                          .toList();
                      if (_secondChoice == _firstChoice) {
                        _secondChoice = updatedSecondChoiceOptions.isEmpty
                            ? ''
                            : updatedSecondChoiceOptions.first;
                      }
                    });
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  key: ValueKey(_firstChoice),
                  initialValue: _secondChoice.isEmpty ? null : _secondChoice,
                  decoration: const InputDecoration(
                    labelText: 'Second choice unit',
                  ),
                  items: secondChoiceOptions.map((unit) {
                    return DropdownMenuItem(value: unit, child: Text(unit));
                  }).toList(),
                  validator: (value) {
                    if (widget.event.crewUnits.length > 1 &&
                        (value == null || value.isEmpty)) {
                      return 'Please choose a second choice unit.';
                    }
                    return null;
                  },
                  onChanged: secondChoiceOptions.isEmpty
                      ? null
                      : (value) {
                          if (value != null) {
                            setState(() => _secondChoice = value);
                          }
                        },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _pitchController,
                  minLines: 4,
                  maxLines: 6,
                  maxLength: 1800,
                  decoration: const InputDecoration(
                    labelText: 'Past experience / short pitch',
                    alignLabelWithHint: true,
                  ),
                  validator: (value) {
                    final text = value?.trim() ?? '';
                    if (text.isEmpty) return 'Please write a short pitch.';
                    if (_wordCount(text) > 300) {
                      return 'Please keep it under 300 words.';
                    }
                    return null;
                  },
                ),
                CheckboxListTile(
                  value: _commitmentAccepted,
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: const Text(
                    'I agree to attend all pre-event meetings and rehearsals.',
                  ),
                  onChanged: (value) {
                    setState(() => _commitmentAccepted = value ?? false);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[700],
            foregroundColor: Colors.white,
          ),
          child: const Text('Submit'),
        ),
      ],
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    if (!_commitmentAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept the commitment check.')),
      );
      return;
    }

    Navigator.pop(
      context,
      _CrewApplicationFormResult(
        firstChoiceUnit: _firstChoice,
        secondChoiceUnit: _secondChoice,
        pitch: _pitchController.text,
        commitmentAccepted: _commitmentAccepted,
      ),
    );
  }
}

int _wordCount(String text) {
  return text
      .split(RegExp(r'\s+'))
      .where((word) => word.trim().isNotEmpty)
      .length;
}
