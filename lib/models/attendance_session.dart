import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

enum AttendanceType {
  checkIn,
  checkOut;

  String get value => this == AttendanceType.checkIn ? 'check_in' : 'check_out';

  String get label => this == AttendanceType.checkIn ? 'Check-in' : 'Check-out';

  static AttendanceType fromValue(String? value) {
    return value == AttendanceType.checkOut.value
        ? AttendanceType.checkOut
        : AttendanceType.checkIn;
  }
}

class AttendanceSession {
  final String id;
  final String eventId;
  final AttendanceType type;
  final String manualCode;
  final DateTime createdAt;
  final DateTime expiresAt;
  final String generatedByUserId;
  final String generatedByName;
  final int durationMinutes;

  const AttendanceSession({
    required this.id,
    required this.eventId,
    required this.type,
    required this.manualCode,
    required this.createdAt,
    required this.expiresAt,
    required this.generatedByUserId,
    required this.generatedByName,
    required this.durationMinutes,
  });

  bool get isExpired => !DateTime.now().isBefore(expiresAt);

  bool get isActive => !isExpired;

  String get qrPayload => jsonEncode({
    'kind': 'massa_attendance',
    'eventId': eventId,
    'sessionId': id,
    'code': manualCode,
  });

  Map<String, dynamic> toMap() {
    return {
      'eventId': eventId,
      'type': type.value,
      'manualCode': manualCode,
      'createdAt': Timestamp.fromDate(createdAt),
      'expiresAt': Timestamp.fromDate(expiresAt),
      'generatedByUserId': generatedByUserId,
      'generatedByName': generatedByName,
      'durationMinutes': durationMinutes,
    };
  }

  factory AttendanceSession.fromMap(
    Map<String, dynamic> map,
    String documentId,
  ) {
    return AttendanceSession(
      id: documentId,
      eventId: map['eventId']?.toString() ?? '',
      type: AttendanceType.fromValue(map['type']?.toString()),
      manualCode: map['manualCode']?.toString() ?? '',
      createdAt: _readDate(map['createdAt']),
      expiresAt: _readDate(map['expiresAt']),
      generatedByUserId: map['generatedByUserId']?.toString() ?? '',
      generatedByName: map['generatedByName']?.toString() ?? '',
      durationMinutes: (map['durationMinutes'] as num?)?.toInt() ?? 10,
    );
  }

  static DateTime _readDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.fromMillisecondsSinceEpoch(0);
  }
}
