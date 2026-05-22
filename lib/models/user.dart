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
  final String phone;
  final String department;
  final String organizationRole;

  String get getUUID => uuid;

  UserModel({
    required this.uuid,
    required this.email,
    required this.role,
    required this.fullName,
    required this.createdOn,
    this.matricNumber,
    this.memberSince,
    this.phone = '',
    this.department = '',
    this.organizationRole = '',
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String id) {
    return UserModel(
      uuid: id,
      email: data['email'] ?? '',
      role: Role.values.byName(data['role'] ?? Role.user.name),
      fullName: data['fullName'] ?? '',
      matricNumber: data['matricNumber'] ?? '',
      phone: data['phone'] ?? '',
      department: data['department'] ?? '',
      organizationRole:
          data['organizationRole'] ??
          data['committeeRole'] ??
          data['excoPosition'] ??
          data['position'] ??
          '',
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
      'fullName': fullName,
      'matricNumber': matricNumber,
      'phone': phone,
      'department': department,
      'organizationRole': organizationRole,
      'memberSince': memberSince,
    };
  }
}
