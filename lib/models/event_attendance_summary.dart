import 'package:massa/models/attendance_record.dart';

class EventAttendanceSummary {
  final String userId;
  final String studentName;
  final String matricNumber;
  final AttendanceRecord? checkIn;
  final AttendanceRecord? checkOut;

  const EventAttendanceSummary({
    required this.userId,
    required this.studentName,
    required this.matricNumber,
    this.checkIn,
    this.checkOut,
  });

  bool get checkedInOnly => checkIn != null && checkOut == null;
}
