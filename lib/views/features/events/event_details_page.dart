import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:massa/enums/role_enum.dart';
import 'package:massa/models/user.dart';
import '../../../view_models/features/events/event_details_viewmodel.dart';

class EventDetailsPage extends StatelessWidget {
  const EventDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // context.watch is essential here so the UI rebuilds when the 
    // registration transaction completes and notifyListeners() is called.
    final viewModel = context.watch<EventDetailsViewModel>();
    final currentUser = context.read<UserModel?>();
    final isAdmin = currentUser?.role == Role.admin;

    if (viewModel.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.orange)),
      );
    }

    final event = viewModel.event;
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
            // Background Decorative Icons (Simulating the motifs)
            Positioned(
              top: 100,
              right: -20,
              child: Icon(
                Icons.wb_sunny_outlined,
                size: 200,
                color: Colors.amber[200]!.withOpacity(0.3),
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
                          _buildMainCard(context, viewModel, isAdmin),
                          const SizedBox(
                            height: 100,
                          ), // Space for bottom actions
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
    bool isAdmin,
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
        margin: const EdgeInsets.all(4), // Border thickness
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gradient Header Section
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
                      if (isAdmin) _buildAdminActions(context, viewModel),
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

            // Description Section
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  const SizedBox(height: 24),
                  _buildActionButtons(context, viewModel, isAdmin),
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

Widget _buildAdminActions(BuildContext context, EventDetailsViewModel viewModel) {
  return Row(
    children: [
      // NEW: View Attendees Button
      _buildCircleIconButton(
        Icons.people_outline, 
        () => context.push('/events/details/${viewModel.eventId}/attendees'),
      ),
      const SizedBox(width: 8),
      _buildCircleIconButton(
        Icons.edit, 
        () => _showEditModal(context, viewModel),
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
    bool isAdmin,
  ) {
    if (isAdmin) return const SizedBox.shrink();

    final event = viewModel.event!;
    final isRegistered = viewModel.isUserRegistered;
    final isFull = event.registeredCount >= event.capacity;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: viewModel.isActionLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.orange))
          : ElevatedButton(
              onPressed: (isFull && !isRegistered)
                  ? null
                  : () async {
                      try {
                        // This calls the transaction-based logic in your ViewModel
                        await viewModel.toggleRegistration();
                        
                        if (context.mounted) {
                          // The snackbar now uses the UPDATED state from the ViewModel
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                viewModel.isUserRegistered
                                    ? "Registration successful!"
                                    : "Successfully unregistered",
                              ),
                              backgroundColor: viewModel.isUserRegistered
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

  void _showDeleteConfirm(
    BuildContext context,
    EventDetailsViewModel viewModel,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text("Delete Event?"),
        content: const Text("Are you sure? This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await viewModel.deleteEvent();
              if (context.mounted) context.pop();
            },
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEditModal(BuildContext context, EventDetailsViewModel viewModel) {
    // Navigate to CreateEventPage in Edit Mode
  }
}