import 'dart:convert';

class AttendanceQrPayload {
  final String eventId;
  final String sessionId;
  final String manualCode;

  const AttendanceQrPayload({
    required this.eventId,
    required this.sessionId,
    required this.manualCode,
  });

  factory AttendanceQrPayload.parse(String payload) {
    final decoded = jsonDecode(payload);
    if (decoded is! Map<String, dynamic> ||
        decoded['kind'] != 'massa_attendance') {
      throw const FormatException('Invalid attendance QR code.');
    }

    final eventId = decoded['eventId']?.toString() ?? '';
    final sessionId = decoded['sessionId']?.toString() ?? '';
    final manualCode = decoded['code']?.toString() ?? '';
    if (eventId.isEmpty ||
        !['check_in', 'check_out'].contains(sessionId) ||
        !RegExp(r'^MASSA-\d{4}$').hasMatch(manualCode)) {
      throw const FormatException('Invalid attendance QR code.');
    }

    return AttendanceQrPayload(
      eventId: eventId,
      sessionId: sessionId,
      manualCode: manualCode,
    );
  }
}
