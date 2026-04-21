import 'package:firebase_auth/firebase_auth.dart';
import 'package:massa/models/user.dart';

class AuthService {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  User? get currentUser => firebaseAuth.currentUser;

  Stream<User?> get authStateChanges {
    return firebaseAuth.authStateChanges();
  }

  // Sign in
  Future<UserModel?> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      final credentials = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userFromFirebaseUser(credentials.user);
    } catch (e) {
      rethrow;
    }
  }

  // Register
  Future<UserModel?> createUserWithEmailPassword({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final credentials = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Optional: later save fullName in Firestore
      return userFromFirebaseUser(credentials.user);
    } catch (e) {
      rethrow;
    }
  }

  // Reset password
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> resetPassword(String code, String newPassword) async {
    try {
      await firebaseAuth.confirmPasswordReset(
        code: code,
        newPassword: newPassword,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await firebaseAuth.signOut();
  }

  // Utility mapper function (Firebase User -> Model User)
  UserModel? userFromFirebaseUser(User? user) {
    if (user == null) {
      return null;
    }

    return UserModel(
      uuid: user.uid,
      email: user.email ?? "",
      phone: user.phoneNumber ?? "",
    );
  }
}
