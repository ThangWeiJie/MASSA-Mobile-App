import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:massa/models/event_task.dart';

class EventTaskRepository {
  final FirebaseFirestore _firestore;

  EventTaskRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _tasksCollection(String eventId) {
    return _firestore.collection('events').doc(eventId).collection('tasks');
  }

  Stream<List<EventTask>> streamEventTasks(String eventId) {
    return _tasksCollection(eventId).orderBy('dueDate').snapshots().map((
      snapshot,
    ) {
      final tasks = snapshot.docs.map((doc) {
        return EventTask.fromMap(doc.data(), doc.id);
      }).toList();

      tasks.sort((first, second) {
        if (first.isOverdue != second.isOverdue) {
          return first.isOverdue ? -1 : 1;
        }

        final statusOrder = _statusSortValue(
          first.status,
        ).compareTo(_statusSortValue(second.status));
        if (statusOrder != 0) return statusOrder;

        final priorityOrder = _prioritySortValue(
          second.priority,
        ).compareTo(_prioritySortValue(first.priority));
        if (priorityOrder != 0) return priorityOrder;

        return first.dueDate.compareTo(second.dueDate);
      });

      return tasks;
    });
  }

  Future<void> createTask({
    required String eventId,
    required EventTask task,
  }) async {
    final docRef = _tasksCollection(eventId).doc();

    final taskWithId = EventTask(
      id: docRef.id,
      title: task.title,
      description: task.description,
      department: task.department,
      assignedToUserId: task.assignedToUserId,
      assignedToName: task.assignedToName,
      assignedToEmail: task.assignedToEmail,
      status: task.status,
      priority: task.priority,
      dueDate: task.dueDate,
      createdAt: task.createdAt,
      updatedAt: task.updatedAt,
      createdByUserId: task.createdByUserId,
      createdByName: task.createdByName,
    );

    await docRef.set(taskWithId.toMap());
  }

  Future<void> updateTask({
    required String eventId,
    required EventTask task,
  }) async {
    await _tasksCollection(eventId).doc(task.id).update({
      'title': task.title,
      'description': task.description,
      'department': task.department,
      'assignedToUserId': task.assignedToUserId,
      'assignedToName': task.assignedToName,
      'assignedToEmail': task.assignedToEmail,
      'status': task.status.name,
      'priority': task.priority.name,
      'dueDate': task.dueDate,
      'updatedAt': DateTime.now(),
    });
  }

  Future<void> updateTaskStatus({
    required String eventId,
    required String taskId,
    required EventTaskStatus status,
  }) async {
    await _tasksCollection(
      eventId,
    ).doc(taskId).update({'status': status.name, 'updatedAt': DateTime.now()});
  }

  Future<void> deleteTask({
    required String eventId,
    required String taskId,
  }) async {
    await _tasksCollection(eventId).doc(taskId).delete();
  }

  int _statusSortValue(EventTaskStatus status) {
    switch (status) {
      case EventTaskStatus.todo:
        return 0;
      case EventTaskStatus.inProgress:
        return 1;
      case EventTaskStatus.completed:
        return 2;
    }
  }

  int _prioritySortValue(EventTaskPriority priority) {
    switch (priority) {
      case EventTaskPriority.low:
        return 0;
      case EventTaskPriority.medium:
        return 1;
      case EventTaskPriority.high:
        return 2;
    }
  }
}
