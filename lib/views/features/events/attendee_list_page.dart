import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:massa/models/attendance_record.dart';
import 'package:massa/models/attendance_session.dart';
import 'package:massa/models/event_attendance_summary.dart';
import 'package:massa/view_models/features/events/attendee_list_viewmodel.dart';
import 'package:provider/provider.dart';

class AttendeeListPage extends StatelessWidget {
  const AttendeeListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AttendeeListViewModel>();
    final summaries = viewModel.attendanceSummaries;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Event Attendance',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.orange[800],
        foregroundColor: Colors.white,
      ),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await Future<void>.delayed(const Duration(milliseconds: 400));
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildSummary(summaries),
                  if (viewModel.errorMessage != null) ...[
                    const SizedBox(height: 12),
                    _buildError(viewModel.errorMessage!),
                  ],
                  const SizedBox(height: 14),
                  if (summaries.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 60),
                      child: Center(child: Text('No students registered yet.')),
                    )
                  else
                    ...summaries.map(
                      (summary) =>
                          _buildStudentCard(context, viewModel, summary),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildSummary(List<EventAttendanceSummary> summaries) {
    final checkedIn = summaries.where((item) => item.checkIn != null).length;
    final checkedOut = summaries.where((item) => item.checkOut != null).length;
    final missingCheckout = summaries
        .where((item) => item.checkedInOnly)
        .length;

    return Card(
      color: Colors.orange[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          alignment: WrapAlignment.spaceAround,
          spacing: 16,
          runSpacing: 16,
          children: [
            _SummaryMetric(label: 'Registered', value: summaries.length),
            _SummaryMetric(label: 'Checked in', value: checkedIn),
            _SummaryMetric(label: 'Checked out', value: checkedOut),
            _SummaryMetric(
              label: 'Missing checkout',
              value: missingCheckout,
              color: Colors.red[700],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentCard(
    BuildContext context,
    AttendeeListViewModel viewModel,
    EventAttendanceSummary summary,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: summary.checkedInOnly
            ? BorderSide(color: Colors.red[300]!, width: 1.5)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.amber[100],
                  child: Text(
                    summary.studentName.isEmpty
                        ? '?'
                        : summary.studentName[0].toUpperCase(),
                    style: TextStyle(
                      color: Colors.orange[900],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        summary.studentName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        summary.matricNumber.isEmpty
                            ? 'No matric number'
                            : summary.matricNumber,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                if (summary.checkedInOnly)
                  Chip(
                    avatar: const Icon(Icons.warning_amber, size: 17),
                    label: const Text('No checkout'),
                    backgroundColor: Colors.red[50],
                    labelStyle: TextStyle(color: Colors.red[800]),
                  ),
              ],
            ),
            const Divider(height: 24),
            _buildAttendanceRow(
              context: context,
              viewModel: viewModel,
              summary: summary,
              type: AttendanceType.checkIn,
              record: summary.checkIn,
            ),
            const SizedBox(height: 10),
            _buildAttendanceRow(
              context: context,
              viewModel: viewModel,
              summary: summary,
              type: AttendanceType.checkOut,
              record: summary.checkOut,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceRow({
    required BuildContext context,
    required AttendeeListViewModel viewModel,
    required EventAttendanceSummary summary,
    required AttendanceType type,
    required AttendanceRecord? record,
  }) {
    final hasSession = viewModel.hasSession(type);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          record == null ? Icons.cancel_outlined : Icons.check_circle,
          color: record == null ? Colors.grey[500] : Colors.green[700],
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                type.label,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              if (record == null)
                Text(
                  hasSession ? 'Not submitted' : 'Session not generated',
                  style: TextStyle(color: Colors.grey[600]),
                )
              else ...[
                Text(DateFormat('MMM d, y h:mm a').format(record.submittedAt)),
                Text(
                  'Method: ${record.method.label}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ],
          ),
        ),
        PopupMenuButton<String>(
          tooltip: 'Manage ${type.label}',
          enabled: hasSession,
          onSelected: (action) async {
            if (action == 'set') {
              final success = await viewModel.setAttendance(
                studentUserId: summary.userId,
                type: type,
              );
              if (context.mounted) {
                _showResult(
                  context,
                  viewModel,
                  success,
                  '${type.label} saved.',
                );
              }
            } else if (action == 'delete' && record != null) {
              final confirmed = await _confirmDelete(context, type);
              if (!confirmed) return;
              final success = await viewModel.deleteAttendance(record.id);
              if (context.mounted) {
                _showResult(
                  context,
                  viewModel,
                  success,
                  '${type.label} removed.',
                );
              }
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'set',
              child: Text(record == null ? 'Mark attended' : 'Update time'),
            ),
            if (record != null)
              const PopupMenuItem(
                value: 'delete',
                child: Text('Remove record'),
              ),
          ],
        ),
      ],
    );
  }

  Future<bool> _confirmDelete(BuildContext context, AttendanceType type) async {
    return await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text('Remove ${type.label}?'),
            content: const Text(
              'This attendance record will be deleted. You can add it again later.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text(
                  'Remove',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showResult(
    BuildContext context,
    AttendeeListViewModel viewModel,
    bool success,
    String successMessage,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? successMessage : viewModel.errorMessage ?? ''),
        backgroundColor: success ? Colors.green[700] : Colors.red[700],
      ),
    );
  }

  Widget _buildError(String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(message, style: TextStyle(color: Colors.red[800])),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  final String label;
  final int value;
  final Color? color;

  const _SummaryMetric({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      child: Column(
        children: [
          Text(
            '$value',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color ?? Colors.orange[900],
            ),
          ),
          Text(label, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
