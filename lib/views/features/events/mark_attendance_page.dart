import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:massa/view_models/features/events/mark_attendance_viewmodel.dart';
import 'package:provider/provider.dart';

class MarkAttendancePage extends StatelessWidget {
  const MarkAttendancePage({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<MarkAttendanceViewModel>();
    final basePath = '/events/details/${viewModel.eventId}/attendance';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mark Attendance',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.orange[800],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Choose how you want to submit attendance',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Each attendance session can only be submitted once.',
              style: TextStyle(color: Colors.grey[700]),
            ),
            const SizedBox(height: 24),
            _AttendanceOptionCard(
              icon: Icons.qr_code_scanner,
              title: 'Scan QR Code',
              description: 'Use your camera to scan the QR shown by EXCO.',
              onTap: () => context.push('$basePath/scan'),
            ),
            const SizedBox(height: 14),
            _AttendanceOptionCard(
              icon: Icons.keyboard_alt_outlined,
              title: 'Enter Attendance Code',
              description: 'Use the short MASSA code shown below the QR.',
              onTap: () => context.push('$basePath/code'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AttendanceOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _AttendanceOptionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.orange[100],
                child: Icon(icon, color: Colors.orange[900], size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
