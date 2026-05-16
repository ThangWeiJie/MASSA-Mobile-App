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
        authSubscription = FirebaseAuth.instance.userChanges().listen(
          (firebaseUser) async {
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
                .listen(
                  (doc) {
                    if (!doc.exists) {
                      controller.add(_loadingUser(firebaseUser));
                      return;
                    }

                    controller.add(
                      UserModel.fromMap(
                        doc.data() as Map<String, dynamic>,
                        doc.id,
                      ),
                    );
                  },
                  onError: controller.addError,
                );
          },
          onError: controller.addError,
        );
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
