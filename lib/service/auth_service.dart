import 'package:firebase_auth/firebase_auth.dart';
import 'package:massa/models/user.dart';

class AuthService {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  User? get currentUser => firebaseAuth.currentUser;

  Stream<User?> get authStateChanges {
    return firebaseAuth.authStateChanges();
  }

  // Sign in
  Future signInWithEmailPassword(String email, String password) async {
    try {
      final credentials = await firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
      var user = userFromFirebaseUser(credentials.user);
      return user;
    } catch(e) {
      rethrow;
    }
  }

  // Register

  // Reset password
  
  // Future<void> resetPassword(String email) async {
  //   try {
  //     await firebaseAuth.sendPasswordResetEmail(email: email);
  //     firebaseAuth.confirmPasswordReset(code: code, newPassword: newPassword)
  //   } catch (e) {
  //     rethrow;
  //   }
  // }
  
  // Sign out
  Future<void> signOut() async {
    await firebaseAuth.signOut();
  }

  // Utility mapper function (Firebase User -> Model User)
  UserModel? userFromFirebaseUser(User? user) {
    if (user == null) {
      throw Error();
    }

    return UserModel(uuid: user.uid, email: user.email ?? "", phone: user.phoneNumber ?? "");
  }
}