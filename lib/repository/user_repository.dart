import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:massa/models/user.dart';

import '../enums/role_enum.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<UserModel?> get userStream {
    late StreamController<UserModel?> controller;
    StreamSubscription<User?>? authSubscription;
    StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
    userSubscription;

    controller = StreamController<UserModel?>(
      onListen: () {
        authSubscription = FirebaseAuth.instance.userChanges().listen((
          firebaseUser,
        ) async {
          await userSubscription?.cancel();
          userSubscription = null;

          if (firebaseUser == null) {
            controller.add(null);
            return;
          }

          userSubscription = _firestore
              .collection('users')
              .doc(firebaseUser.uid)
              .snapshots()
              .listen((doc) {
                if (!doc.exists) {
                  controller.add(_loadingUser(firebaseUser));
                  return;
                }

                controller.add(
                  UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id),
                );
              }, onError: controller.addError);
        }, onError: controller.addError);
      },
      onCancel: () async {
        await userSubscription?.cancel();
        await authSubscription?.cancel();
      },
    );

    return controller.stream;
  }

  Stream<UserModel> getUserStream(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((doc) {
      if (!doc.exists) {
        throw Exception('User not found');
      }
      return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    });
  }

  Stream<List<UserModel>> streamExcoMembers() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: Role.exco.name)
        .snapshots()
        .map((snapshot) {
          final members = snapshot.docs.map((doc) {
            return UserModel.fromMap(doc.data(), doc.id);
          }).toList();

          members.sort((first, second) {
            return first.fullName.toLowerCase().compareTo(
              second.fullName.toLowerCase(),
            );
          });

          return members;
        });
  }

  Stream<List<UserModel>> streamAssignableExcoUsers() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      final members = snapshot.docs
          .map((doc) {
            return UserModel.fromMap(doc.data(), doc.id);
          })
          .where((user) {
            return user.role != Role.admin;
          })
          .toList();

      members.sort((first, second) {
        final roleOrder = _roleSortValue(
          first.role,
        ).compareTo(_roleSortValue(second.role));
        if (roleOrder != 0) return roleOrder;
        return first.fullName.toLowerCase().compareTo(
          second.fullName.toLowerCase(),
        );
      });

      return members;
    });
  }

  Future<void> assignExcoMember({
    required String userId,
    required String department,
    required String organizationRole,
  }) async {
    final trimmedDepartment = department.trim();
    final trimmedOrganizationRole = organizationRole.trim();
    final canonicalHighestCouncilRole = _canonicalHighestCouncilRole(
      trimmedOrganizationRole,
    );

    if (_isHighestCouncilDepartment(trimmedDepartment) &&
        canonicalHighestCouncilRole == null) {
      throw Exception(
        'Please choose a valid Highest Council role: President, Vice President, Secretary, Vice Secretary, Treasurer, or Vice Treasurer.',
      );
    }

    final safeOrganizationRole =
        canonicalHighestCouncilRole ?? trimmedOrganizationRole;
    final userRef = _firestore.collection('users').doc(userId);
    final batch = _firestore.batch();

    if (canonicalHighestCouncilRole != null) {
      final existingRoleHolders = await _firestore
          .collection('users')
          .where('role', isEqualTo: Role.exco.name)
          .where('department', isEqualTo: _highestCouncilDepartment)
          .get();

      for (final doc in existingRoleHolders.docs) {
        if (doc.id == userId) continue;
        final existingRole = doc.data()['organizationRole'] as String? ?? '';
        if (_canonicalHighestCouncilRole(existingRole) !=
            canonicalHighestCouncilRole) {
          continue;
        }

        batch.update(doc.reference, {
          'role': Role.user.name,
          'organizationRole': '',
          'department': '',
        });
      }
    }

    batch.update(userRef, {
      'role': Role.exco.name,
      'department': trimmedDepartment,
      'organizationRole': safeOrganizationRole,
    });

    await batch.commit();
  }

  UserModel _loadingUser(User firebaseUser) {
    return UserModel(
      uuid: firebaseUser.uid,
      email: firebaseUser.email ?? "",
      fullName: "Loading...",
      matricNumber: "Loading...",
      role: Role.user,
      createdOn: DateTime.now(),
    );
  }

  int _roleSortValue(Role role) {
    switch (role) {
      case Role.admin:
        return 0;
      case Role.exco:
        return 1;
      case Role.user:
        return 2;
    }
  }

  bool _isHighestCouncilDepartment(String department) {
    return department.trim().toLowerCase() ==
        _highestCouncilDepartment.toLowerCase();
  }

  String? _canonicalHighestCouncilRole(String value) {
    final normalized = value
        .toLowerCase()
        .replaceAll('&', 'and')
        .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
        .trim();

    return _highestCouncilRoles[normalized];
  }

  static const String _highestCouncilDepartment = 'Highest Council Members';

  static const Map<String, String> _highestCouncilRoles = {
    'president': 'President',
    'vice president': 'Vice President',
    'secretary': 'Secretary',
    'vice secretary': 'Vice Secretary',
    'treasurer': 'Treasurer',
    'vice treasurer': 'Vice Treasurer',
  };

  Future<void> createMember(UserModel user) async {
    var userMap = user.toMap();

    try {
      await _firestore.collection("users").doc(user.uuid).set(userMap);
    } on Exception {
      rethrow;
    }
  }

  Future<UserModel> getUser(String uid) async {
    DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();

    if (!doc.exists) {
      throw Exception("Member not found in database");
    }

    return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  Future<void> updateUserProfile({
    required String userId,
    required String fullName,
    required String phone,
    required String department,
  }) async {
    await _firestore.collection('users').doc(userId).update({
      'fullName': fullName,
      'phone': phone,
      'department': department,
    });
  }

  Future<void> adminUpdateUserProfile({
    required String userId,
    required String fullName,
    required String phone,
    required String department,
    required String role,
  }) async {
    await _firestore.collection('users').doc(userId).update({
      'fullName': fullName,
      'phone': phone,
      'department': department,
      'role': role,
    });
  }
}
