import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:massa/models/event_task.dart';
import 'package:massa/models/user.dart';
import 'package:massa/view_models/features/events/event_task_management_viewmodel.dart';
import 'package:provider/provider.dart';

class EventTaskManagementPage extends StatelessWidget {
  const EventTaskManagementPage({super.key});

  static const Color _massaBrown = Color(0xFF92400E);
  static const Color _massaOrange = Color(0xFFEA580C);

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<EventTaskManagementViewModel>();

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: _massaOrange,
        foregroundColor: Colors.white,
        onPressed: viewModel.isActionLoading
            ? null
            : () => _showTaskSheet(context),
        child: const Icon(Icons.add_task),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.orange[50]!, Colors.amber[50]!, Colors.yellow[50]!],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                children: [
                  _buildHeader(context),
                  _buildSummaryCard(viewModel),
                  _buildSearchAndFilter(context, viewModel),
                  Expanded(child: _buildBody(context, viewModel)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 20, 20, 10),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: Icon(Icons.arrow_back_rounded, color: Colors.amber[900]),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [
                      Colors.orange[800]!,
                      Colors.amber[700]!,
                      Colors.yellow[800]!,
                    ],
                  ).createShader(bounds),
                  child: const Text(
                    'Event Tasks',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  'Assign and track EXCO responsibilities',
                  style: TextStyle(
                    color: Colors.amber[900]!.withValues(alpha: 0.75),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(EventTaskManagementViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFF59E0B), Color(0xFFEA580C)],
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withValues(alpha: 0.22),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Task Overview',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: viewModel.progressValue,
                minHeight: 9,
                backgroundColor: Colors.white24,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${viewModel.progressPercent}% completed',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _summaryItem('Total', viewModel.totalTasks),
                _summaryItem('Done', viewModel.completedTasks),
                _summaryItem('Doing', viewModel.inProgressTasks),
                _summaryItem('Overdue', viewModel.overdueTasks),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryItem(String label, int value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter(
    BuildContext context,
    EventTaskManagementViewModel viewModel,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Column(
        children: [
          TextField(
            onChanged: viewModel.updateSearchQuery,
            decoration: InputDecoration(
              hintText: 'Search task, assignee, department',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.orange[100]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.orange[100]!),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(16)),
                borderSide: BorderSide(color: _massaOrange, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _filterChip(
                  label: 'All',
                  selected: viewModel.selectedStatusFilter == null,
                  onTap: () => viewModel.updateStatusFilter(null),
                ),
                ...EventTaskStatus.values.map(
                  (status) => _filterChip(
                    label: status.label,
                    selected: viewModel.selectedStatusFilter == status,
                    onTap: () => viewModel.updateStatusFilter(status),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: Colors.orange[700],
        backgroundColor: Colors.white,
        labelStyle: TextStyle(
          color: selected ? Colors.white : _massaBrown,
          fontWeight: FontWeight.bold,
        ),
        side: BorderSide(color: Colors.orange[200]!),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    EventTaskManagementViewModel viewModel,
  ) {
    if (viewModel.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: _massaOrange),
      );
    }

    if (viewModel.errorMessage != null) {
      return _messageState(
        icon: Icons.error_outline,
        title: 'Unable to load tasks',
        message: 'Please check your connection and Firestore rules.',
      );
    }

    if (viewModel.tasks.isEmpty) {
      return _messageState(
        icon: Icons.task_alt,
        title: 'No tasks yet',
        message: 'Create the first task for this event.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 120),
      itemCount: viewModel.sections.length,
      itemBuilder: (context, index) {
        final section = viewModel.sections[index];

        return Padding(
          padding: const EdgeInsets.only(bottom: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionHeader(section.title, section.tasks.length),
              const SizedBox(height: 10),
              ...section.tasks.map(
                (task) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _TaskCard(
                    task: task,
                    onEdit: () => _showTaskSheet(context, task: task),
                    onDelete: () => _confirmDelete(context, task),
                    onStatusChanged: (status) {
                      context
                          .read<EventTaskManagementViewModel>()
                          .updateTaskStatus(task: task, status: status);
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _sectionHeader(String title, int count) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange[100]!),
      ),
      child: Row(
        children: [
          Icon(_iconForSection(title), color: Colors.orange[800]),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: _massaBrown,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            count.toString(),
            style: TextStyle(
              color: Colors.orange[900],
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconForSection(String title) {
    if (title == 'Overdue') return Icons.warning_amber_rounded;
    if (title == 'In Progress') return Icons.pending_actions;
    if (title == 'Completed') return Icons.verified_outlined;
    return Icons.radio_button_unchecked;
  }

  Widget _messageState({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 60, color: Colors.brown.withValues(alpha: 0.28)),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(
                color: _massaBrown,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, EventTask task) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Text('Delete task?'),
        content: Text('Are you sure you want to delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[700]),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (shouldDelete != true || !context.mounted) return;

    await context.read<EventTaskManagementViewModel>().deleteTask(task);
  }

  Future<void> _showTaskSheet(BuildContext context, {EventTask? task}) async {
    final result = await showModalBottomSheet<_TaskFormResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _TaskFormSheet(task: task),
    );

    if (!context.mounted || result == null) return;

    final viewModel = context.read<EventTaskManagementViewModel>();
    final messenger = ScaffoldMessenger.of(context);

    try {
      if (task == null) {
        await viewModel.createTask(
          title: result.title,
          description: result.description,
          department: result.department,
          assignee: result.assignee,
          priority: result.priority,
          status: result.status,
          dueDate: result.dueDate,
        );
      } else {
        await viewModel.updateTask(
          existingTask: task,
          title: result.title,
          description: result.description,
          department: result.department,
          assignee: result.assignee,
          priority: result.priority,
          status: result.status,
          dueDate: result.dueDate,
        );
      }

      messenger.showSnackBar(
        SnackBar(
          content: Text(task == null ? 'Task created.' : 'Task updated.'),
          backgroundColor: Colors.green[700],
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({
    required this.task,
    required this.onEdit,
    required this.onDelete,
    required this.onStatusChanged,
  });

  final EventTask task;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<EventTaskStatus> onStatusChanged;

  @override
  Widget build(BuildContext context) {
    final dueText = DateFormat('d MMM y').format(task.dueDate);

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: task.isOverdue ? Colors.red[200]! : Colors.orange[100]!,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: _priorityColor(
                  task.priority,
                ).withValues(alpha: 0.12),
                child: Icon(
                  Icons.task_alt,
                  color: _priorityColor(task.priority),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  task.title,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') onEdit();
                  if (value == 'delete') onDelete();
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'edit', child: Text('Edit')),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ],
          ),
          if (task.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              task.description,
              style: TextStyle(color: Colors.grey[700], height: 1.35),
            ),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _chip(task.status.label, _statusColor(task.status)),
              _chip(task.priority.label, _priorityColor(task.priority)),
              if (task.isOverdue) _chip('Overdue', Colors.red),
            ],
          ),
          const SizedBox(height: 12),
          _infoRow(Icons.person_outline, task.assignedToName),
          _infoRow(Icons.apartment_outlined, task.department),
          _infoRow(Icons.event_outlined, 'Due $dueText'),
          const SizedBox(height: 12),
          DropdownButtonFormField<EventTaskStatus>(
            initialValue: task.status,
            decoration: InputDecoration(
              labelText: 'Update status',
              filled: true,
              fillColor: Colors.orange[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.orange[100]!),
              ),
            ),
            items: EventTaskStatus.values.map((status) {
              return DropdownMenuItem(value: status, child: Text(status.label));
            }).toList(),
            onChanged: (status) {
              if (status == null) return;
              onStatusChanged(status);
            },
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, MaterialColor color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color[50],
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color[200]!),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color[800],
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String value) {
    if (value.trim().isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey[700], fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  MaterialColor _statusColor(EventTaskStatus status) {
    switch (status) {
      case EventTaskStatus.todo:
        return Colors.amber;
      case EventTaskStatus.inProgress:
        return Colors.blue;
      case EventTaskStatus.completed:
        return Colors.green;
    }
  }

  MaterialColor _priorityColor(EventTaskPriority priority) {
    switch (priority) {
      case EventTaskPriority.low:
        return Colors.green;
      case EventTaskPriority.medium:
        return Colors.amber;
      case EventTaskPriority.high:
        return Colors.red;
    }
  }
}

class _TaskFormSheet extends StatefulWidget {
  const _TaskFormSheet({this.task});

  final EventTask? task;

  @override
  State<_TaskFormSheet> createState() => _TaskFormSheetState();
}

class _TaskFormSheetState extends State<_TaskFormSheet> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  late String _selectedDepartment;
  UserModel? _selectedAssignee;
  EventTaskPriority _priority = EventTaskPriority.medium;
  EventTaskStatus _status = EventTaskStatus.todo;
  DateTime _dueDate = DateTime.now();

  @override
  void initState() {
    super.initState();

    final task = widget.task;
    _selectedDepartment = EventTaskManagementViewModel.departments.first;

    if (task != null) {
      _titleController.text = task.title;
      _descriptionController.text = task.description;
      _selectedDepartment = task.department;
      _priority = task.priority;
      _status = task.status;
      _dueDate = task.dueDate;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<EventTaskManagementViewModel>();
    final members = viewModel.membersForDepartment(_selectedDepartment);

    if (_selectedAssignee == null && members.isNotEmpty) {
      if (widget.task != null) {
        _selectedAssignee = members.firstWhere(
          (member) => member.uuid == widget.task!.assignedToUserId,
          orElse: () => members.first,
        );
      } else {
        _selectedAssignee = members.first;
      }
    }

    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFFFFBF0),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            22,
            12,
            22,
            24 + MediaQuery.paddingOf(context).bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 18),
                  decoration: BoxDecoration(
                    color: Colors.brown.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              Text(
                widget.task == null ? 'Create Task' : 'Edit Task',
                style: const TextStyle(
                  color: Color(0xFF92400E),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 18),
              _textField(
                controller: _titleController,
                label: 'Task title',
                hint: 'e.g., Prepare event poster',
              ),
              const SizedBox(height: 14),
              _textField(
                controller: _descriptionController,
                label: 'Description',
                hint: 'Write task details',
                maxLines: 3,
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue:
                    EventTaskManagementViewModel.departments.contains(
                      _selectedDepartment,
                    )
                    ? _selectedDepartment
                    : EventTaskManagementViewModel.departments.first,
                isExpanded: true,
                decoration: _inputDecoration('Department'),
                items: EventTaskManagementViewModel.departments.map((dept) {
                  return DropdownMenuItem(
                    value: dept,
                    child: Text(dept, overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _selectedDepartment = value;
                    _selectedAssignee = null;
                  });
                },
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<UserModel>(
                initialValue: _selectedAssignee,
                isExpanded: true,
                decoration: _inputDecoration('Assign to EXCO'),
                items: members.map((member) {
                  final name = member.fullName.trim().isEmpty
                      ? member.email
                      : member.fullName;
                  return DropdownMenuItem(
                    value: member,
                    child: Text(name, overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedAssignee = value),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<EventTaskPriority>(
                      initialValue: _priority,
                      decoration: _inputDecoration('Priority'),
                      items: EventTaskPriority.values.map((priority) {
                        return DropdownMenuItem(
                          value: priority,
                          child: Text(priority.label),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) setState(() => _priority = value);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<EventTaskStatus>(
                      initialValue: _status,
                      decoration: _inputDecoration('Status'),
                      items: EventTaskStatus.values.map((status) {
                        return DropdownMenuItem(
                          value: status,
                          child: Text(status.label),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) setState(() => _status = value);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: _pickDueDate,
                child: InputDecorator(
                  decoration: _inputDecoration('Due date'),
                  child: Row(
                    children: [
                      Icon(Icons.event_outlined, color: Colors.orange[800]),
                      const SizedBox(width: 10),
                      Text(DateFormat('d MMMM y').format(_dueDate)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEA580C),
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(48),
                      ),
                      icon: const Icon(Icons.check),
                      label: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: _inputDecoration(label).copyWith(hintText: hint),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.orange[100]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.orange[100]!),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        borderSide: BorderSide(color: Color(0xFFEA580C), width: 2),
      ),
    );
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked == null) return;

    setState(() => _dueDate = picked);
  }

  void _submit() {
    final assignee = _selectedAssignee;

    if (assignee == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No EXCO member available to assign.')),
      );
      return;
    }

    Navigator.pop(
      context,
      _TaskFormResult(
        title: _titleController.text,
        description: _descriptionController.text,
        department: _selectedDepartment,
        assignee: assignee,
        priority: _priority,
        status: _status,
        dueDate: _dueDate,
      ),
    );
  }
}

class _TaskFormResult {
  final String title;
  final String description;
  final String department;
  final UserModel assignee;
  final EventTaskPriority priority;
  final EventTaskStatus status;
  final DateTime dueDate;

  const _TaskFormResult({
    required this.title,
    required this.description,
    required this.department,
    required this.assignee,
    required this.priority,
    required this.status,
    required this.dueDate,
  });
}
