import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:massa/models/attendance_session.dart';

enum AttendanceMethod {
  qrScan,
  manualCode,
  admin;

  String get value {
    switch (this) {
      case AttendanceMethod.qrScan:
        return 'qr_scan';
      case AttendanceMethod.manualCode:
        return 'manual_code';
      case AttendanceMethod.admin:
        return 'admin';
    }
  }

  String get label {
    switch (this) {
      case AttendanceMethod.qrScan:
        return 'QR scan';
      case AttendanceMethod.manualCode:
        return 'Manual code';
      case AttendanceMethod.admin:
        return 'Admin';
    }
  }

  static AttendanceMethod fromValue(String? value) {
    return AttendanceMethod.values.firstWhere(
      (method) => method.value == value,
      orElse: () => AttendanceMethod.manualCode,
    );
  }
}

class AttendanceRecord {
  final String id;
  final String eventId;
  final String sessionId;
  final String userId;
  final String studentName;
  final String matricNumber;
  final AttendanceType type;
  final DateTime submittedAt;
  final AttendanceMethod method;

  const AttendanceRecord({
    required this.id,
    required this.eventId,
    required this.sessionId,
    required this.userId,
    required this.studentName,
    required this.matricNumber,
    required this.type,
    required this.submittedAt,
    required this.method,
  });

  static String documentId(String sessionId, String userId) {
    return '${sessionId}_$userId';
  }

  Map<String, dynamic> toMap() {
    return {
      'eventId': eventId,
      'sessionId': sessionId,
      'userId': userId,
      'studentName': studentName,
      'matricNumber': matricNumber,
      'type': type.value,
      'submittedAt': Timestamp.fromDate(submittedAt),
      'method': method.value,
    };
  }

  factory AttendanceRecord.fromMap(
    Map<String, dynamic> map,
    String documentId,
  ) {
    final submittedAt = map['submittedAt'];
    return AttendanceRecord(
      id: documentId,
      eventId: map['eventId']?.toString() ?? '',
      sessionId: map['sessionId']?.toString() ?? '',
      userId: map['userId']?.toString() ?? '',
      studentName: map['studentName']?.toString() ?? 'Unknown Student',
      matricNumber: map['matricNumber']?.toString() ?? '',
      type: AttendanceType.fromValue(map['type']?.toString()),
      submittedAt: submittedAt is Timestamp
          ? submittedAt.toDate()
          : DateTime.fromMillisecondsSinceEpoch(0),
      method: AttendanceMethod.fromValue(map['method']?.toString()),
    );
  }
}
