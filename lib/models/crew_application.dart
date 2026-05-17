import 'package:cloud_firestore/cloud_firestore.dart';

enum CrewApplicationStatus {
  pending,
  accepted,
  declined,
  waitlisted;

  String get label {
    switch (this) {
      case CrewApplicationStatus.pending:
        return 'Pending';
      case CrewApplicationStatus.accepted:
        return 'Accepted';
      case CrewApplicationStatus.declined:
        return 'Declined';
      case CrewApplicationStatus.waitlisted:
        return 'Waitlisted';
    }
  }

  static CrewApplicationStatus fromName(String? name) {
    return CrewApplicationStatus.values.firstWhere(
      (status) => status.name == name,
      orElse: () => CrewApplicationStatus.pending,
    );
  }
}

class CrewApplication {
  final String id;
  final String userId;
  final String fullName;
  final String email;
  final String matricNumber;
  final String phone;
  final String department;
  final String firstChoiceUnit;
  final String secondChoiceUnit;
  final String pitch;
  final bool commitmentAccepted;
  final CrewApplicationStatus status;
  final String assignedUnit;
  final String inviteLink;
  final DateTime appliedAt;
  final DateTime updatedAt;
  final DateTime? decidedAt;
  final String reviewedByUserId;
  final String reviewedByName;

  const CrewApplication({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.email,
    required this.matricNumber,
    required this.phone,
    required this.department,
    required this.firstChoiceUnit,
    required this.secondChoiceUnit,
    required this.pitch,
    required this.commitmentAccepted,
    required this.status,
    required this.assignedUnit,
    required this.inviteLink,
    required this.appliedAt,
    required this.updatedAt,
    this.decidedAt,
    this.reviewedByUserId = '',
    this.reviewedByName = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'fullName': fullName,
      'email': email,
      'matricNumber': matricNumber,
      'phone': phone,
      'department': department,
      'firstChoiceUnit': firstChoiceUnit,
      'secondChoiceUnit': secondChoiceUnit,
      'pitch': pitch,
      'commitmentAccepted': commitmentAccepted,
      'status': status.name,
      'assignedUnit': assignedUnit,
      'inviteLink': inviteLink,
      'appliedAt': appliedAt,
      'updatedAt': updatedAt,
      'decidedAt': decidedAt,
      'reviewedByUserId': reviewedByUserId,
      'reviewedByName': reviewedByName,
    };
  }

  factory CrewApplication.fromMap(Map<String, dynamic> map, String id) {
    return CrewApplication(
      id: id,
      userId: map['userId'] ?? id,
      fullName: map['fullName'] ?? 'Unknown Student',
      email: map['email'] ?? '',
      matricNumber: map['matricNumber'] ?? '',
      phone: map['phone'] ?? '',
      department: map['department'] ?? '',
      firstChoiceUnit: map['firstChoiceUnit'] ?? '',
      secondChoiceUnit: map['secondChoiceUnit'] ?? '',
      pitch: map['pitch'] ?? '',
      commitmentAccepted: map['commitmentAccepted'] ?? false,
      status: CrewApplicationStatus.fromName(map['status']),
      assignedUnit: map['assignedUnit'] ?? '',
      inviteLink: map['inviteLink'] ?? '',
      appliedAt: _dateFromValue(map['appliedAt']) ?? DateTime.now(),
      updatedAt: _dateFromValue(map['updatedAt']) ?? DateTime.now(),
      decidedAt: _dateFromValue(map['decidedAt']),
      reviewedByUserId: map['reviewedByUserId'] ?? '',
      reviewedByName: map['reviewedByName'] ?? '',
    );
  }

  static DateTime? _dateFromValue(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}
