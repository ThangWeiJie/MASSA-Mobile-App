import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:massa/models/attendance_qr_payload.dart';
import 'package:massa/models/attendance_record.dart';
import 'package:massa/models/user.dart';
import 'package:massa/service/features/events/event_service.dart';

class MarkAttendanceViewModel extends ChangeNotifier {
  final EventService eventService;
  final String eventId;
  final UserModel student;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  AttendanceRecord? _lastRecord;
  AttendanceRecord? get lastRecord => _lastRecord;

  MarkAttendanceViewModel({
    required this.eventService,
    required this.eventId,
    required this.student,
  });

  Future<bool> submitCode(String code) {
    return _submit(() {
      return eventService.submitAttendanceCode(
        eventId: eventId,
        student: student,
        code: code,
        method: AttendanceMethod.manualCode,
      );
    });
  }

  Future<bool> submitQrPayload(String payload) async {
    try {
      final qrPayload = AttendanceQrPayload.parse(payload);
      if (qrPayload.eventId != eventId) {
        throw Exception('This attendance QR belongs to another event.');
      }

      return _submit(() {
        return eventService.submitAttendance(
          eventId: eventId,
          student: student,
          sessionId: qrPayload.sessionId,
          code: qrPayload.manualCode,
          method: AttendanceMethod.qrScan,
        );
      });
    } on FormatException catch (error) {
      _errorMessage = error.message;
      notifyListeners();
      return false;
    } catch (error, stackTrace) {
      developer.log(
        'QR attendance payload validation failed',
        name: 'MarkAttendanceViewModel',
        error: error,
        stackTrace: stackTrace,
      );
      _errorMessage = _cleanError(error);
      notifyListeners();
      return false;
    }
  }

  Future<bool> _submit(Future<AttendanceRecord> Function() action) async {
    if (_isSubmitting) return false;
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _lastRecord = await action().timeout(const Duration(seconds: 20));
      return true;
    } on TimeoutException catch (error, stackTrace) {
      developer.log(
        'Attendance submission timed out',
        name: 'MarkAttendanceViewModel',
        error: error,
        stackTrace: stackTrace,
      );
      _errorMessage =
          'Attendance validation took too long. Check your connection and try again.';
      return false;
    } catch (error, stackTrace) {
      developer.log(
        'Attendance submission failed',
        name: 'MarkAttendanceViewModel',
        error: error,
        stackTrace: stackTrace,
      );
      _errorMessage = _cleanError(error);
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  String _cleanError(Object error) {
    final message = error.toString().replaceFirst('Exception: ', '');
    if (message.contains('permission-denied')) {
      return 'Attendance could not be submitted. Confirm that you joined this '
          'event, then try again.';
    }
    return message;
  }

  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }
}
