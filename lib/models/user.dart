import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:massa/enums/role_enum.dart';

class UserModel {
  final String uuid;
  final String email;
  final Role role;
  final DateTime createdOn;
  final String fullName;
  final String? matricNumber;
  final DateTime? memberSince;

  String get getUUID => uuid;

  UserModel({
    required this.uuid,
    required this.email,
    required this.role,
    required this.fullName,
    required this.createdOn,
    this.matricNumber,
    this.memberSince,
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String id) {
    return UserModel(
      uuid: id,
      email: data['email'] ?? '',
      // Safely parse the enum so it doesn't crash if the role string is weird/missing
      role: Role.values.firstWhere(
        (e) => e.name == data['role'],
        orElse: () => Role.user,
      ),
      // ADDED FALLBACK: Prevents crash if 'fullName' is missing on old accounts
      fullName: data['fullName'] ?? 'Unknown User',
      matricNumber: data['matricNumber'],
      memberSince: data['memberSince'] != null
          ? (data['memberSince'] as Timestamp).toDate()
          : null,
      createdOn: data['createdOn'] != null
          ? (data['createdOn'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uuid': uuid,
      'email': email,
      'role': role.name,
      'createdOn': createdOn,
      'matricNumber': matricNumber, // FIXED TYPO: Was 'fatricNumber'
      'fullName': fullName, // FIXED TYPO: Was 'mullName'
      'memberSince': memberSince,
    };
  }
}
