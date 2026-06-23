import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:massa/models/attendance_qr_payload.dart';
import 'package:massa/models/attendance_record.dart';
import 'package:massa/models/attendance_session.dart';

void main() {
  group('AttendanceSession', () {
    test('encodes event and session data in the QR payload', () {
      final session = AttendanceSession(
        id: 'check_in',
        eventId: 'event-123',
        type: AttendanceType.checkIn,
        manualCode: 'MASSA-4821',
        createdAt: DateTime(2026, 6, 13, 10),
        expiresAt: DateTime(2026, 6, 13, 10, 10),
        generatedByUserId: 'admin-1',
        generatedByName: 'Admin',
        durationMinutes: 10,
      );

      final payload = jsonDecode(session.qrPayload) as Map<String, dynamic>;

      expect(payload['kind'], 'massa_attendance');
      expect(payload['eventId'], 'event-123');
      expect(payload['sessionId'], 'check_in');
      expect(payload['code'], 'MASSA-4821');
    });
  });

  group('Attendance values', () {
    test('maps stored values to user-facing types and methods', () {
      expect(AttendanceType.fromValue('check_out'), AttendanceType.checkOut);
      expect(AttendanceMethod.fromValue('qr_scan'), AttendanceMethod.qrScan);
      expect(AttendanceMethod.admin.label, 'Admin');
    });

    test('builds fixed attendance record document IDs', () {
      expect(
        AttendanceRecord.documentId('check_in', 'student-123'),
        'check_in_student-123',
      );
      expect(
        AttendanceRecord.documentId('check_out', 'student-123'),
        'check_out_student-123',
      );
    });
  });

  group('AttendanceQrPayload', () {
    test('parses a valid MASSA attendance QR payload', () {
      final parsed = AttendanceQrPayload.parse(
        '{"kind":"massa_attendance","eventId":"event-123",'
        '"sessionId":"check_in","code":"MASSA-4821"}',
      );

      expect(parsed.eventId, 'event-123');
      expect(parsed.sessionId, 'check_in');
      expect(parsed.manualCode, 'MASSA-4821');
    });

    test('rejects invalid session IDs and manual-code formats', () {
      expect(
        () => AttendanceQrPayload.parse(
          '{"kind":"massa_attendance","eventId":"event-123",'
          '"sessionId":"arrival","code":"MASSA-12"}',
        ),
        throwsFormatException,
      );
    });
  });
}
