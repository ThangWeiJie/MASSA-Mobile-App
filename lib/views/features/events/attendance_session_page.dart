import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:massa/models/attendance_session.dart';
import 'package:massa/view_models/features/events/attendance_session_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class AttendanceSessionPage extends StatefulWidget {
  const AttendanceSessionPage({super.key});

  @override
  State<AttendanceSessionPage> createState() => _AttendanceSessionPageState();
}

class _AttendanceSessionPageState extends State<AttendanceSessionPage> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AttendanceSessionViewModel>();
    final activeSession = viewModel.activeSession;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Attendance QR',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.orange[800],
        foregroundColor: Colors.white,
      ),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildGenerationCard(context, viewModel),
                if (viewModel.errorMessage != null) ...[
                  const SizedBox(height: 12),
                  _buildMessage(
                    viewModel.errorMessage!,
                    Colors.red[50]!,
                    Colors.red[800]!,
                  ),
                ],
                if (activeSession != null) ...[
                  const SizedBox(height: 16),
                  _buildActiveSession(activeSession),
                ],
                if (viewModel.sessions.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const Text(
                    'Session history',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...viewModel.sessions.map(_buildSessionTile),
                ],
              ],
            ),
    );
  }

  Widget _buildGenerationCard(
    BuildContext context,
    AttendanceSessionViewModel viewModel,
  ) {
    final activeSession = viewModel.activeSession;
    String helperText;
    if (viewModel.hasGeneratedAll) {
      helperText =
          'Maximum 2 attendance sessions already generated for this event.';
    } else if (activeSession != null) {
      helperText =
          '${activeSession.type.label} is active. Wait until it expires before generating the next session.';
    } else {
      helperText =
          'Next session: ${viewModel.nextType.label}. The QR will stop accepting submissions when the timer ends.';
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              viewModel.nextType.label,
              style: TextStyle(
                color: Colors.orange[900],
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(helperText, style: TextStyle(color: Colors.grey[700])),
            const SizedBox(height: 18),
            const Text(
              'QR duration',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 5, label: Text('5 min')),
                ButtonSegment(value: 10, label: Text('10 min')),
                ButtonSegment(value: 15, label: Text('15 min')),
              ],
              selected: {viewModel.durationMinutes},
              onSelectionChanged: viewModel.canGenerate
                  ? (selection) => viewModel.setDuration(selection.first)
                  : null,
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: viewModel.canGenerate
                    ? () async {
                        final session = await viewModel.generate();
                        if (!context.mounted || session == null) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${session.type.label} attendance QR generated.',
                            ),
                            backgroundColor: Colors.green[700],
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[800],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: viewModel.isGenerating
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.qr_code_2),
                label: Text(
                  viewModel.isGenerating
                      ? 'Generating...'
                      : 'Generate ${viewModel.nextType.label} QR',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveSession(AttendanceSession session) {
    final remaining = session.expiresAt.difference(DateTime.now());
    final safeRemaining = remaining.isNegative ? Duration.zero : remaining;
    final minutes = safeRemaining.inMinutes.toString().padLeft(2, '0');
    final seconds = (safeRemaining.inSeconds % 60).toString().padLeft(2, '0');

    return Card(
      color: Colors.orange[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              '${session.type.label} QR is active',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.white,
              child: QrImageView(
                data: session.qrPayload,
                version: QrVersions.auto,
                size: 230,
                semanticsLabel: '${session.type.label} attendance QR code',
              ),
            ),
            const SizedBox(height: 16),
            const Text('Manual attendance code'),
            const SizedBox(height: 4),
            SelectableText(
              session.manualCode,
              style: TextStyle(
                color: Colors.orange[900],
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              '$minutes:$seconds remaining',
              style: TextStyle(
                color: safeRemaining == Duration.zero
                    ? Colors.red[700]
                    : Colors.green[800],
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Expires ${DateFormat('h:mm:ss a').format(session.expiresAt)}',
              style: TextStyle(color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionTile(AttendanceSession session) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: session.isActive
              ? Colors.green[100]
              : Colors.grey[200],
          child: Icon(
            session.type == AttendanceType.checkIn ? Icons.login : Icons.logout,
            color: session.isActive ? Colors.green[800] : Colors.grey[700],
          ),
        ),
        title: Text(
          session.type.label,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${session.manualCode} | ${session.durationMinutes} min\n'
          'Generated ${DateFormat('MMM d, h:mm a').format(session.createdAt)}',
        ),
        isThreeLine: true,
        trailing: Chip(
          label: Text(session.isActive ? 'Active' : 'Expired'),
          backgroundColor: session.isActive
              ? Colors.green[50]
              : Colors.grey[100],
        ),
      ),
    );
  }

  Widget _buildMessage(String text, Color background, Color foreground) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text, style: TextStyle(color: foreground)),
    );
  }
}
