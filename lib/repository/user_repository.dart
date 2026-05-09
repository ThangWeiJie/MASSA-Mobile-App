import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:massa/models/user.dart';

import '../enums/role_enum.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<UserModel?> get userStream {
    return FirebaseAuth.instance.authStateChanges().asyncExpand((firebaseUser) {
      if (firebaseUser == null) return Stream.value(null);

      return _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .snapshots()
          .map((doc) {
            if (!doc.exists) {
              return _loadingUser(firebaseUser);
            }
            return UserModel.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            );
          });
    });
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
}
