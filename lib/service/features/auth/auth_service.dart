import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:massa/enums/role_enum.dart';
import 'package:massa/models/user.dart';
import 'package:massa/repository/user_repository.dart';

class AuthService {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final UserRepository _userRepository;

  AuthService(this._userRepository);

  User? get currentUser => firebaseAuth.currentUser;

  Future<void> refreshUser() async {
    await firebaseAuth.currentUser?.reload();
  }

  // Get auth state changes (login/logout)
  Stream<User?> get authStateChanges {
    return firebaseAuth.userChanges();
  }

  // Sign in
  Future signInWithEmailPassword(String email, String password) async {
    try {
      final credentials = await firebaseAuth.signInWithEmailAndPassword(email: email, password: password);

      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await _userRepository.updateFcmToken(credentials.user!.uid, token);
      }

      var user = userFromFirebaseUser(credentials.user);
      return user;
    } catch(e) {
      rethrow;
    }
  }

  // Register
  Future<void> registerNewAccount({
    required String email,
    required String password,
    required String name,
    required String matricNumber, // <-- ADDED HERE
  }) async {
    try {
      UserCredential userCredential = await firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);

      final newUser = UserModel(
          uuid: userCredential.user!.uid,
          email: email,
          role: Role.user,
          fullName: name,
          matricNumber: matricNumber, // <-- ADDED HERE
          createdOn: DateTime.now()
      );

      await _userRepository.createMember(newUser);

      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await _userRepository.updateFcmToken(userCredential.user!.uid, token);
      }

      await userCredential.user?.sendEmailVerification();
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
      final uid = firebaseAuth.currentUser?.uid;
      if (uid != null) {
        await _userRepository.updateFcmToken(uid, null);
      }
      firebaseAuth.confirmPasswordReset(code: code, newPassword: newPassword);
    } catch (e) {
      rethrow;
    }
  }
  
  // Sign out
  Future<void> signOut() async {
    await firebaseAuth.signOut();
  }

  // Utility mapper function (Firebase User -> Model User)
  Future<UserModel?> userFromFirebaseUser(User? user) async {
    if (user == null) {
      throw Error();
    }

    return await _userRepository.getUser(user.uid);
  }
}
