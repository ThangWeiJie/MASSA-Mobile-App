import 'dart:async';

import 'package:flutter/material.dart';
import 'package:massa/models/attendance_record.dart';
import 'package:massa/models/attendance_session.dart';
import 'package:massa/models/event_attendance_summary.dart';
import 'package:massa/models/user.dart';
import 'package:massa/service/features/events/event_service.dart';

class AttendeeListViewModel extends ChangeNotifier {
  final EventService eventService;
  final String eventId;
  final UserModel requester;

  List<Map<String, dynamic>> _participants = [];
  List<Map<String, dynamic>> get participants => _participants;

  List<AttendanceRecord> _records = [];
  List<AttendanceSession> _sessions = [];

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  StreamSubscription<List<Map<String, dynamic>>>? _participantsSubscription;
  StreamSubscription<List<AttendanceRecord>>? _recordsSubscription;
  StreamSubscription<List<AttendanceSession>>? _sessionsSubscription;

  AttendeeListViewModel({
    required this.eventService,
    required this.eventId,
    required this.requester,
  }) {
    _listenToParticipants();
    _listenToAttendance();
  }

  void _listenToParticipants() {
    _participantsSubscription = eventService
        .getEventParticipants(eventId)
        .listen(
          (data) {
            _participants = data;
            _isLoading = false;
            notifyListeners();
          },
          onError: (Object error) {
            debugPrint('Error fetching participants: $error');
            _isLoading = false;
            _errorMessage = _cleanError(error);
            notifyListeners();
          },
        );
  }

  void _listenToAttendance() {
    _recordsSubscription = eventService
        .streamAttendanceRecords(eventId)
        .listen(
          (records) {
            _records = records;
            notifyListeners();
          },
          onError: (Object error) {
            _errorMessage = _cleanError(error);
            notifyListeners();
          },
        );
    _sessionsSubscription = eventService
        .streamAttendanceSessions(eventId)
        .listen(
          (sessions) {
            _sessions = sessions;
            notifyListeners();
          },
          onError: (Object error) {
            _errorMessage = _cleanError(error);
            notifyListeners();
          },
        );
  }

  List<EventAttendanceSummary> get attendanceSummaries {
    final recordsByUser = <String, List<AttendanceRecord>>{};
    for (final record in _records) {
      recordsByUser.putIfAbsent(record.userId, () => []).add(record);
    }

    final participantUserIds = <String>{};
    final summaries =
        _participants.map((participant) {
          final userId = participant['userId']?.toString() ?? '';
          participantUserIds.add(userId);
          final records = recordsByUser[userId] ?? const <AttendanceRecord>[];
          return EventAttendanceSummary(
            userId: userId,
            studentName:
                participant['fullName']?.toString() ?? 'Unknown Student',
            matricNumber: participant['matricNumber']?.toString() ?? '',
            checkIn: _recordForType(records, AttendanceType.checkIn),
            checkOut: _recordForType(records, AttendanceType.checkOut),
          );
        }).toList()..addAll(
          recordsByUser.entries
              .where((entry) => !participantUserIds.contains(entry.key))
              .map((entry) {
                final records = entry.value;
                final representative = records.first;
                return EventAttendanceSummary(
                  userId: entry.key,
                  studentName: representative.studentName,
                  matricNumber: representative.matricNumber,
                  checkIn: _recordForType(records, AttendanceType.checkIn),
                  checkOut: _recordForType(records, AttendanceType.checkOut),
                );
              }),
        );

    summaries.sort((a, b) {
      if (a.checkedInOnly != b.checkedInOnly) {
        return a.checkedInOnly ? -1 : 1;
      }
      return a.studentName.toLowerCase().compareTo(b.studentName.toLowerCase());
    });
    return summaries;
  }

  AttendanceRecord? _recordForType(
    List<AttendanceRecord> records,
    AttendanceType type,
  ) {
    for (final record in records) {
      if (record.type == type) return record;
    }
    return null;
  }

  bool hasSession(AttendanceType type) {
    return _sessions.any((session) => session.type == type);
  }

  Future<bool> setAttendance({
    required String studentUserId,
    required AttendanceType type,
    DateTime? submittedAt,
  }) async {
    try {
      _errorMessage = null;
      await eventService.upsertAttendanceRecord(
        eventId: eventId,
        requester: requester,
        studentUserId: studentUserId,
        type: type,
        submittedAt: submittedAt,
      );
      return true;
    } catch (error) {
      _errorMessage = _cleanError(error);
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteAttendance(String recordId) async {
    try {
      _errorMessage = null;
      await eventService.deleteAttendanceRecord(
        eventId: eventId,
        requester: requester,
        recordId: recordId,
      );
      return true;
    } catch (error) {
      _errorMessage = _cleanError(error);
      notifyListeners();
      return false;
    }
  }

  String _cleanError(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }

  @override
  void dispose() {
    _participantsSubscription?.cancel();
    _recordsSubscription?.cancel();
    _sessionsSubscription?.cancel();
    super.dispose();
  }
}
