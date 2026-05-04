import 'package:firebase_auth/firebase_auth.dart';
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
  Future<void> registerNewAccount({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      UserCredential userCredential = await firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);

      final newUser = UserModel(
          uuid: userCredential.user!.uid,
          email: email,
          role: Role.user,
          fullName: name,
          createdOn: DateTime.now()
      );

      await _userRepository.createMember(newUser);

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