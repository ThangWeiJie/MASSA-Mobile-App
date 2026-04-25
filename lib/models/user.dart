import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:massa/enums/role_enum.dart';

class UserModel {
  final String uuid;
  final String email;
  final Role role;
  final DateTime createdOn;
  final String fullName;
  final DateTime? memberSince;

  String get getUUID => uuid;

  UserModel({
    required this.uuid,
    required this.email,
    required this.role,
    required this.fullName,
    required this.createdOn,
    this.memberSince,
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String id) {
    return UserModel(
      uuid: id,
      email: data['email'],
      role: Role.values.byName(data['role']),
      fullName: data['fullName'],
      memberSince: data['memberSince'] != null ? (data['memberSince'] as Timestamp).toDate() : null,
      createdOn: (data['createdOn'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uuid': uuid,
      'email': email,
      'role': role.name,
      'createdOn': createdOn,
      'fullName': fullName,
      'memberSince': memberSince,
    };
  }
}
