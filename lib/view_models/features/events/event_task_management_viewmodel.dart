import 'dart:async';

import 'package:flutter/material.dart';
import 'package:massa/models/event_task.dart';
import 'package:massa/models/user.dart';
import 'package:massa/repository/event_task_repository.dart';
import 'package:massa/repository/user_repository.dart';

class EventTaskManagementViewModel extends ChangeNotifier {
  final String eventId;
  final EventTaskRepository taskRepository;
  final UserRepository userRepository;
  final UserModel? currentUser;

  EventTaskManagementViewModel({
    required this.eventId,
    required this.taskRepository,
    required this.userRepository,
    required this.currentUser,
  }) {
    _subscribeToTasks();
    _subscribeToExcoMembers();
  }

  List<EventTask> _allTasks = [];
  List<EventTask> _filteredTasks = [];
  List<UserModel> _excoMembers = [];

  StreamSubscription<List<EventTask>>? _taskSubscription;
  StreamSubscription<List<UserModel>>? _excoSubscription;

  bool _isLoading = true;
  bool _isActionLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  EventTaskStatus? _selectedStatusFilter;

  bool get isLoading => _isLoading;
  bool get isActionLoading => _isActionLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  EventTaskStatus? get selectedStatusFilter => _selectedStatusFilter;

  List<EventTask> get tasks => _filteredTasks;
  List<UserModel> get excoMembers => _excoMembers;

  int get totalTasks => _allTasks.length;

  int get completedTasks => _allTasks
      .where((task) => task.status == EventTaskStatus.completed)
      .length;

  int get inProgressTasks => _allTasks
      .where((task) => task.status == EventTaskStatus.inProgress)
      .length;

  int get todoTasks =>
      _allTasks.where((task) => task.status == EventTaskStatus.todo).length;

  int get overdueTasks => _allTasks.where((task) => task.isOverdue).length;

  double get progressValue {
    if (_allTasks.isEmpty) return 0;
    return completedTasks / _allTasks.length;
  }

  int get progressPercent => (progressValue * 100).round();

  List<EventTaskSection> get sections {
    final grouped = <String, List<EventTask>>{};

    for (final task in _filteredTasks) {
      final title = _sectionTitleForTask(task);
      grouped.putIfAbsent(title, () => []).add(task);
    }

    final orderedTitles = ['Overdue', 'To Do', 'In Progress', 'Completed'];

    return orderedTitles
        .where((title) => grouped[title]?.isNotEmpty ?? false)
        .map((title) => EventTaskSection(title: title, tasks: grouped[title]!))
        .toList();
  }

  void _subscribeToTasks() {
    _taskSubscription = taskRepository
        .streamEventTasks(eventId)
        .listen(
          (tasks) {
            _allTasks = tasks;
            _isLoading = false;
            _errorMessage = null;
            _applyFilters();
          },
          onError: (error) {
            _errorMessage = error.toString();
            _isLoading = false;
            notifyListeners();
          },
        );
  }

  void _subscribeToExcoMembers() {
    _excoSubscription = userRepository.streamExcoMembers().listen(
      (members) {
        _excoMembers = members;
        notifyListeners();
      },
      onError: (error) {
        debugPrint('EXCO members loading error: $error');
      },
    );
  }

  void updateSearchQuery(String value) {
    _searchQuery = value.trim().toLowerCase();
    _applyFilters();
  }

  void updateStatusFilter(EventTaskStatus? status) {
    _selectedStatusFilter = status;
    _applyFilters();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedStatusFilter = null;
    _applyFilters();
  }

  void _applyFilters() {
    var result = List<EventTask>.from(_allTasks);

    if (_selectedStatusFilter != null) {
      result = result
          .where((task) => task.status == _selectedStatusFilter)
          .toList();
    }

    if (_searchQuery.isNotEmpty) {
      result = result.where((task) {
        final text =
            '${task.title} ${task.description} ${task.department} ${task.assignedToName} ${task.assignedToEmail} ${task.priority.label} ${task.status.label}'
                .toLowerCase();

        return text.contains(_searchQuery);
      }).toList();
    }

    _filteredTasks = result;
    notifyListeners();
  }

  String _sectionTitleForTask(EventTask task) {
    if (task.isOverdue) return 'Overdue';

    switch (task.status) {
      case EventTaskStatus.todo:
        return 'To Do';
      case EventTaskStatus.inProgress:
        return 'In Progress';
      case EventTaskStatus.completed:
        return 'Completed';
    }
  }

  Future<void> createTask({
    required String title,
    required String description,
    required String department,
    required UserModel assignee,
    required EventTaskPriority priority,
    required EventTaskStatus status,
    required DateTime dueDate,
  }) async {
    _validateTask(
      title: title,
      department: department,
      assignee: assignee,
      dueDate: dueDate,
    );

    final now = DateTime.now();

    final task = EventTask(
      id: '',
      title: title.trim(),
      description: description.trim(),
      department: department.trim(),
      assignedToUserId: assignee.uuid,
      assignedToName: assignee.fullName,
      assignedToEmail: assignee.email,
      status: status,
      priority: priority,
      dueDate: dueDate,
      createdAt: now,
      updatedAt: now,
      createdByUserId: currentUser?.uuid ?? '',
      createdByName: currentUser?.fullName ?? '',
    );

    _isActionLoading = true;
    notifyListeners();

    try {
      await taskRepository.createTask(eventId: eventId, task: task);
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateTask({
    required EventTask existingTask,
    required String title,
    required String description,
    required String department,
    required UserModel assignee,
    required EventTaskPriority priority,
    required EventTaskStatus status,
    required DateTime dueDate,
  }) async {
    _validateTask(
      title: title,
      department: department,
      assignee: assignee,
      dueDate: dueDate,
    );

    final updatedTask = EventTask(
      id: existingTask.id,
      title: title.trim(),
      description: description.trim(),
      department: department.trim(),
      assignedToUserId: assignee.uuid,
      assignedToName: assignee.fullName,
      assignedToEmail: assignee.email,
      status: status,
      priority: priority,
      dueDate: dueDate,
      createdAt: existingTask.createdAt,
      updatedAt: DateTime.now(),
      createdByUserId: existingTask.createdByUserId,
      createdByName: existingTask.createdByName,
    );

    _isActionLoading = true;
    notifyListeners();

    try {
      await taskRepository.updateTask(eventId: eventId, task: updatedTask);
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateTaskStatus({
    required EventTask task,
    required EventTaskStatus status,
  }) async {
    _isActionLoading = true;
    notifyListeners();

    try {
      await taskRepository.updateTaskStatus(
        eventId: eventId,
        taskId: task.id,
        status: status,
      );
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteTask(EventTask task) async {
    _isActionLoading = true;
    notifyListeners();

    try {
      await taskRepository.deleteTask(eventId: eventId, taskId: task.id);
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }

  void _validateTask({
    required String title,
    required String department,
    required UserModel assignee,
    required DateTime dueDate,
  }) {
    if (title.trim().isEmpty) {
      throw Exception('Please enter a task title.');
    }

    if (department.trim().isEmpty) {
      throw Exception('Please choose a department.');
    }

    if (assignee.uuid.isEmpty) {
      throw Exception('Please assign an EXCO member.');
    }
  }

  List<UserModel> membersForDepartment(String department) {
    final normalizedDepartment = department.trim().toLowerCase();

    if (normalizedDepartment.isEmpty) return _excoMembers;

    final matched = _excoMembers.where((member) {
      return member.department.trim().toLowerCase() == normalizedDepartment;
    }).toList();

    if (matched.isEmpty) return _excoMembers;

    return matched;
  }

  @override
  void dispose() {
    _taskSubscription?.cancel();
    _excoSubscription?.cancel();
    super.dispose();
  }

  static const List<String> departments = [
    'Highest Council Members',
    'Corporate and External Affairs Department',
    'Multimedia Department',
    'Publicity Department',
    'Sports, Technical and Logistics Department',
    'Cultural Department',
    'Entrepreneurship Department',
    'Welfare and Academic Department',
  ];
}

class EventTaskSection {
  final String title;
  final List<EventTask> tasks;

  const EventTaskSection({required this.title, required this.tasks});
}
