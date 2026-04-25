import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:massa/models/user.dart';

import '../enums/role_enum.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<UserModel?> get userStream {
    return FirebaseAuth.instance.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;

      try {
        return await getUser(firebaseUser.uid);
      } on FirebaseException catch (e) {
        if (e.code == 'not-found') {
          return _loadingUser(firebaseUser);
        }

        print("Actual Firebase Error: ${e.message}");
        return null;
      } catch (e) {
        if (e.toString().contains("not found")) {
          return _loadingUser(firebaseUser);
        }

        print("Unexpected error in userStream: $e");
        rethrow;
      }
    });
  }

// Helper to keep the code clean
  UserModel _loadingUser(User firebaseUser) {
    return UserModel(
      uuid: firebaseUser.uid,
      email: firebaseUser.email ?? "",
      fullName: "Loading...",
      role: Role.user,
      createdOn: DateTime.now(),
    );
  }

  Future<void> createMember(UserModel user) async {
    var userMap = user.toMap();

    try {
      await _firestore.collection("users").doc(user.uuid).set(userMap);
    } on Exception catch (e) {
      rethrow;
    }
  }
  Future<UserModel> getUser(String uid) async {
    DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();

    if (!doc.exists) {
      throw Exception("Member not found in database");
    }

    return UserModel.fromMap(
      doc.data() as Map<String, dynamic>,
      doc.id
    );
  }
}