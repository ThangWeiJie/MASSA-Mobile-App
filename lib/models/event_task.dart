import 'package:cloud_firestore/cloud_firestore.dart';

enum EventTaskStatus { todo, inProgress, completed }

enum EventTaskPriority { low, medium, high }

extension EventTaskStatusLabel on EventTaskStatus {
  String get label {
    switch (this) {
      case EventTaskStatus.todo:
        return 'To Do';
      case EventTaskStatus.inProgress:
        return 'In Progress';
      case EventTaskStatus.completed:
        return 'Completed';
    }
  }
}

extension EventTaskPriorityLabel on EventTaskPriority {
  String get label {
    switch (this) {
      case EventTaskPriority.low:
        return 'Low';
      case EventTaskPriority.medium:
        return 'Medium';
      case EventTaskPriority.high:
        return 'High';
    }
  }
}

class EventTask {
  final String id;
  final String title;
  final String description;
  final String department;
  final String assignedToUserId;
  final String assignedToName;
  final String assignedToEmail;
  final EventTaskStatus status;
  final EventTaskPriority priority;
  final DateTime dueDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdByUserId;
  final String createdByName;

  const EventTask({
    required this.id,
    required this.title,
    required this.description,
    required this.department,
    required this.assignedToUserId,
    required this.assignedToName,
    required this.assignedToEmail,
    required this.status,
    required this.priority,
    required this.dueDate,
    required this.createdAt,
    required this.updatedAt,
    required this.createdByUserId,
    required this.createdByName,
  });

  bool get isOverdue {
    if (status == EventTaskStatus.completed) return false;
    final today = DateTime.now();
    final dueDateOnly = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final todayOnly = DateTime(today.year, today.month, today.day);
    return dueDateOnly.isBefore(todayOnly);
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'department': department,
      'assignedToUserId': assignedToUserId,
      'assignedToName': assignedToName,
      'assignedToEmail': assignedToEmail,
      'status': status.name,
      'priority': priority.name,
      'dueDate': dueDate,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'createdByUserId': createdByUserId,
      'createdByName': createdByName,
    };
  }

  factory EventTask.fromMap(Map<String, dynamic> map, String documentId) {
    return EventTask(
      id: documentId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      department: map['department'] ?? '',
      assignedToUserId: map['assignedToUserId'] ?? '',
      assignedToName: map['assignedToName'] ?? '',
      assignedToEmail: map['assignedToEmail'] ?? '',
      status: EventTaskStatus.values.byName(
        map['status'] ?? EventTaskStatus.todo.name,
      ),
      priority: EventTaskPriority.values.byName(
        map['priority'] ?? EventTaskPriority.medium.name,
      ),
      dueDate: map['dueDate'] is Timestamp
          ? (map['dueDate'] as Timestamp).toDate()
          : DateTime.now(),
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: map['updatedAt'] is Timestamp
          ? (map['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
      createdByUserId: map['createdByUserId'] ?? '',
      createdByName: map['createdByName'] ?? '',
    );
  }
}
