import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  AuthService({
    FirebaseAuth? firebaseAuth,
  }) : _firebaseAuth = firebaseAuth;

  final FirebaseAuth? _firebaseAuth;

  User? get currentUser => _firebaseAuth?.currentUser;

  Stream<User?> authStateChanges() {
    return _firebaseAuth?.authStateChanges() ?? const Stream<User?>.empty();
  }

  bool get isEmailVerified => _firebaseAuth?.currentUser?.emailVerified ?? false;

  Future<UserCredential> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    final auth = _requireFirebaseAuth();
    final normalizedEmail = _normalizeEmail(email);
    return auth.createUserWithEmailAndPassword(
      email: normalizedEmail,
      password: password,
    );
  }

  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    final auth = _requireFirebaseAuth();
    final normalizedEmail = _normalizeEmail(email);
    return auth.signInWithEmailAndPassword(
      email: normalizedEmail,
      password: password,
    );
  }

  Future<void> sendEmailVerification() async {
    await _requireFirebaseAuth().currentUser?.sendEmailVerification();
  }

  Future<User?> reloadCurrentUser() async {
    final auth = _requireFirebaseAuth();
    await auth.currentUser?.reload();
    return auth.currentUser;
  }

  Future<void> sendPasswordResetEmail(String email) async {
    final auth = _requireFirebaseAuth();
    final normalizedEmail = _normalizeEmail(email);
    await auth.sendPasswordResetEmail(email: normalizedEmail);
  }

  Future<void> changePassword({
    required String email,
    required String currentPassword,
    required String newPassword,
  }) async {
    final auth = _requireFirebaseAuth();
    final user = auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'No authenticated user found.',
      );
    }

    final credential = EmailAuthProvider.credential(
      email: _normalizeEmail(email),
      password: currentPassword,
    );
    await user.reauthenticateWithCredential(credential);
    await user.updatePassword(newPassword);
  }

  Future<void> signOut() async {
    await _firebaseAuth?.signOut();
  }

  String normalizeEmail(String email) => _normalizeEmail(email);

  String _normalizeEmail(String email) {
    return email.trim().toLowerCase();
  }

  FirebaseAuth _requireFirebaseAuth() {
    if (_firebaseAuth != null) {
      return _firebaseAuth!;
    }
    throw StateError(
      'Firebase email/password authentication is not configured. Add Firebase '
      'options and enable Email/Password sign-in in Firebase Auth.',
    );
  }
}
