import 'dart:async';

import 'package:flutter/material.dart';
import 'package:massa/models/attendance_session.dart';
import 'package:massa/models/user.dart';
import 'package:massa/service/features/events/event_service.dart';

class AttendanceSessionViewModel extends ChangeNotifier {
  final EventService eventService;
  final String eventId;
  final UserModel requester;

  List<AttendanceSession> _sessions = const [];
  List<AttendanceSession> get sessions => _sessions;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool _isGenerating = false;
  bool get isGenerating => _isGenerating;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  int _durationMinutes = 10;
  int get durationMinutes => _durationMinutes;

  StreamSubscription<List<AttendanceSession>>? _subscription;

  AttendanceSessionViewModel({
    required this.eventService,
    required this.eventId,
    required this.requester,
  }) {
    _subscription = eventService
        .streamAttendanceSessions(eventId)
        .listen(
          (sessions) {
            _sessions = sessions;
            _isLoading = false;
            _errorMessage = null;
            notifyListeners();
          },
          onError: (Object error) {
            _isLoading = false;
            _errorMessage = _cleanError(error);
            notifyListeners();
          },
        );
  }

  AttendanceSession? get activeSession {
    for (final session in _sessions.reversed) {
      if (session.isActive) return session;
    }
    return null;
  }

  AttendanceType get nextType =>
      _sessions.any((session) => session.type == AttendanceType.checkIn)
      ? AttendanceType.checkOut
      : AttendanceType.checkIn;

  bool get hasGeneratedAll =>
      _sessions.any((session) => session.type == AttendanceType.checkIn) &&
      _sessions.any((session) => session.type == AttendanceType.checkOut);

  bool get canGenerate =>
      !_isGenerating && activeSession == null && !hasGeneratedAll;

  void setDuration(int minutes) {
    if (![5, 10, 15].contains(minutes)) return;
    _durationMinutes = minutes;
    notifyListeners();
  }

  Future<AttendanceSession?> generate() async {
    if (_isGenerating) return null;
    _isGenerating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      return await eventService.generateAttendanceSession(
        eventId: eventId,
        requester: requester,
        durationMinutes: _durationMinutes,
      );
    } catch (error) {
      _errorMessage = _cleanError(error);
      return null;
    } finally {
      _isGenerating = false;
      notifyListeners();
    }
  }

  String _cleanError(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
