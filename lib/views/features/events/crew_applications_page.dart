import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:massa/models/crew_application.dart';
import 'package:massa/models/user.dart';
import 'package:massa/view_models/features/events/crew_applications_viewmodel.dart';
import 'package:provider/provider.dart';

class CrewApplicationsPage extends StatelessWidget {
  const CrewApplicationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CrewApplicationsViewModel>();
    final currentUser = context.read<UserModel?>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Crew Applications',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.orange[800],
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.orange[800]!, Colors.amber[50]!],
            stops: const [0.0, 0.22],
          ),
        ),
        child: viewModel.isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
            : Column(
                children: [
                  _buildSummaryAndFilters(viewModel),
                  Expanded(
                    child: viewModel.applications.isEmpty
                        ? const Center(
                            child: Text(
                              'No crew applications found.',
                              style: TextStyle(
                                color: Colors.brown,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                            itemCount: viewModel.applications.length,
                            itemBuilder: (context, index) {
                              final application = viewModel.applications[index];
                              return _CrewApplicationCard(
                                application: application,
                                unitOptions: viewModel.unitOptions,
                                isActionLoading: viewModel.isActionLoading,
                                onAccept: currentUser == null
                                    ? null
                                    : () => _showAcceptDialog(
                                        context,
                                        viewModel,
                                        application,
                                        currentUser,
                                      ),
                                onDecline: currentUser == null
                                    ? null
                                    : () => _confirmDecision(
                                        context: context,
                                        title: 'Decline application?',
                                        message:
                                            'The student will be notified politely that the quota is full.',
                                        onConfirm: () =>
                                            viewModel.declineApplication(
                                              application: application,
                                              reviewer: currentUser,
                                            ),
                                      ),
                                onWaitlist: currentUser == null
                                    ? null
                                    : () => viewModel.waitlistApplication(
                                        application: application,
                                        reviewer: currentUser,
                                      ),
                              );
                            },
                          ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildSummaryAndFilters(CrewApplicationsViewModel viewModel) {
    final allApplications = viewModel.applications;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 12)],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  viewModel.event?.eventName ?? 'Event Crew',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.amber[300]!),
                ),
                child: Text(
                  '${allApplications.length} shown',
                  style: TextStyle(
                    color: Colors.orange[900],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            onChanged: viewModel.updateSearchQuery,
            decoration: InputDecoration(
              hintText: 'Search name, matric, email, department, pitch',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey[200]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey[200]!),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: viewModel.statusFilter,
                  decoration: _filterDecoration('Status'),
                  items: [
                    const DropdownMenuItem(value: 'all', child: Text('All')),
                    ...CrewApplicationStatus.values.map(
                      (status) => DropdownMenuItem(
                        value: status.name,
                        child: Text(status.label),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) viewModel.updateStatusFilter(value);
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: viewModel.unitFilter,
                  decoration: _filterDecoration('Unit'),
                  items: [
                    const DropdownMenuItem(value: 'all', child: Text('All')),
                    ...viewModel.unitOptions.map(
                      (unit) =>
                          DropdownMenuItem(value: unit, child: Text(unit)),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) viewModel.updateUnitFilter(value);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  InputDecoration _filterDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.grey[50],
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey[200]!),
      ),
    );
  }

  Future<void> _showAcceptDialog(
    BuildContext context,
    CrewApplicationsViewModel viewModel,
    CrewApplication application,
    UserModel reviewer,
  ) async {
    final roleOptions = <String>{
      application.firstChoiceUnit,
      if (application.secondChoiceUnit.isNotEmpty) application.secondChoiceUnit,
      ...viewModel.unitOptions,
    }.where((unit) => unit.isNotEmpty).toList();
    String selectedUnit = application.firstChoiceUnit;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Accepting for which role?'),
              content: DropdownButtonFormField<String>(
                initialValue: selectedUnit,
                decoration: const InputDecoration(labelText: 'Assigned unit'),
                items: roleOptions.map((unit) {
                  return DropdownMenuItem(value: unit, child: Text(unit));
                }).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => selectedUnit = value);
                },
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await viewModel.acceptApplication(
                      application: application,
                      assignedUnit: selectedUnit,
                      reviewer: reviewer,
                    );
                    if (dialogContext.mounted) Navigator.pop(dialogContext);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Accept'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _confirmDecision({
    required BuildContext context,
    required String title,
    required String message,
    required Future<void> Function() onConfirm,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                await onConfirm();
                if (dialogContext.mounted) Navigator.pop(dialogContext);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[700],
                foregroundColor: Colors.white,
              ),
              child: const Text('Decline'),
            ),
          ],
        );
      },
    );
  }
}

class _CrewApplicationCard extends StatelessWidget {
  final CrewApplication application;
  final List<String> unitOptions;
  final bool isActionLoading;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;
  final VoidCallback? onWaitlist;

  const _CrewApplicationCard({
    required this.application,
    required this.unitOptions,
    required this.isActionLoading,
    this.onAccept,
    this.onDecline,
    this.onWaitlist,
  });

  @override
  Widget build(BuildContext context) {
    final canDecide =
        application.status != CrewApplicationStatus.accepted &&
        application.status != CrewApplicationStatus.declined;

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.amber[100],
                  child: Text(
                    application.fullName.isEmpty
                        ? '?'
                        : application.fullName[0].toUpperCase(),
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
                        application.fullName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        [
                          application.matricNumber,
                          application.department,
                        ].where((text) => text.isNotEmpty).join(' - '),
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                _StatusChip(status: application.status),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _ChoiceChip(
                  label: '1st: ${application.firstChoiceUnit}',
                  color: Colors.orange,
                ),
                if (application.secondChoiceUnit.isNotEmpty)
                  _ChoiceChip(
                    label: '2nd: ${application.secondChoiceUnit}',
                    color: Colors.amber,
                  ),
                if (application.assignedUnit.isNotEmpty)
                  _ChoiceChip(
                    label: 'Assigned: ${application.assignedUnit}',
                    color: Colors.green,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(application.pitch, style: const TextStyle(height: 1.45)),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 6),
                Text(
                  DateFormat('MMM d, y - jm').format(application.appliedAt),
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
            if (canDecide) ...[
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: isActionLoading ? null : onAccept,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.check),
                      label: const Text('Accept'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    onPressed: isActionLoading ? null : onWaitlist,
                    tooltip: 'Keep in View',
                    icon: const Icon(Icons.visibility_outlined),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    onPressed: isActionLoading ? null : onDecline,
                    tooltip: 'Decline',
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  final String label;
  final MaterialColor color;

  const _ChoiceChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color[50],
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color[200]!),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color[900],
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final CrewApplicationStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      CrewApplicationStatus.pending => Colors.orange,
      CrewApplicationStatus.accepted => Colors.green,
      CrewApplicationStatus.declined => Colors.red,
      CrewApplicationStatus.waitlisted => Colors.blue,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color[50],
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color[200]!),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: color[800],
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
