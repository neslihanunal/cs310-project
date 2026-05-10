import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/local_storage_service.dart';

const approvedAdminEmails = <String>{
  'artelier@sabanciuniv.edu',
  'computerclub@sabanciuniv.edu',
  'subuh.sr@sabanciuniv.edu',
  'sudance@sabanciuniv.edu',
  'eik@sabanciuniv.edu',
  'sr.suec@sabanciuniv.edu',
  'suwell@sabanciuniv.edu',
  'suieee@sabanciuniv.edu',
  'ies@sabanciuniv.edu',
  'kaisabanci.sr@sabanciuniv.edu',
  'mun@sabanciuniv.edu',
  'muzikus@sabanciuniv.edu',
  'offtownyk@sabanciuniv.edu',
  'sufirst@sabanciuniv.edu',
  'suss@sabanciuniv.edu',
  'sr.suint@sabanciuniv.edu',
};

const passwordPolicyMessage =
    'Password must be at least 8 characters and include uppercase, lowercase, number, and special character.';

enum AuthStatus {
  loggedOut,
  emailVerificationPending,
  needsProfile,
  authenticated,
}

class AuthProvider extends ChangeNotifier {
  AuthProvider({
    required AuthService authService,
    required FirestoreService firestoreService,
    required LocalStorageService localStorageService,
  })  : _authService = authService,
        _firestoreService = firestoreService,
        _localStorageService = localStorageService {
    initialize();
  }

  final AuthService _authService;
  final FirestoreService _firestoreService;
  final LocalStorageService _localStorageService;

  bool _isLoading = true;
  String? _uid;
  String? _email;
  AppUser? _currentUser;
  String? _errorMessage;
  AuthStatus _status = AuthStatus.loggedOut;

  String _dashboardLayout = 'board';
  int _reminderLeadMinutes = 30;
  Set<String> _preferredCategories = const <String>{
    'Academic',
    'Social',
    'Sports',
    'Career',
    'Arts',
  };
  String _lastSelectedTab = 'all';

  bool get isLoading => _isLoading;
  bool get isLoggedIn => _status == AuthStatus.authenticated;
  bool get needsEmailVerification =>
      _status == AuthStatus.emailVerificationPending;
  bool get needsProfile => _status == AuthStatus.needsProfile;
  String? get uid => _uid;
  String? get email => _email;
  AppUser? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  AuthStatus get status => _status;
  bool get isApprovedAdminEmail =>
      approvedAdminEmails.contains(_normalizeEmail(_email));
  bool get canUseAdminRole =>
      _currentUser?.role == 'admin' || isApprovedAdminEmail;
  String get role => canUseAdminRole ? 'admin' : 'student';
  String get dashboardLayout => _dashboardLayout;
  int get reminderLeadMinutes => _reminderLeadMinutes;
  Set<String> get preferredCategories => _preferredCategories;
  String get lastSelectedTab => _lastSelectedTab;

  String get reminderLabel {
    return switch (_reminderLeadMinutes) {
      15 => '15 min',
      30 => '30 min',
      60 => '1 hour',
      1440 => '1 day',
      _ => '$_reminderLeadMinutes min',
    };
  }

  String get currentClubName {
    final clubName = _currentUser?.clubName?.trim();
    if (clubName != null && clubName.isNotEmpty) {
      return clubName;
    }
    final displayName = _currentUser?.displayName.trim();
    if (role == 'admin' && displayName != null && displayName.isNotEmpty) {
      return displayName;
    }
    return 'Campus Club';
  }

  String get currentClubId {
    final emailPrefix = _email?.split('@').firstOrNull?.trim().toLowerCase();
    if (emailPrefix != null && emailPrefix.isNotEmpty) {
      return emailPrefix.replaceAll(RegExp(r'[^a-z0-9]+'), '');
    }
    return currentClubName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '');
  }

  bool isSabanciEmail(String email) {
    return _normalizeEmail(email).endsWith('@sabanciuniv.edu');
  }

  String? validateRegistrationPassword(String password) {
    if (password.length < 8) {
      return passwordPolicyMessage;
    }
    final hasUppercase = RegExp(r'[A-Z]').hasMatch(password);
    final hasLowercase = RegExp(r'[a-z]').hasMatch(password);
    final hasNumber = RegExp(r'\d').hasMatch(password);
    final hasSpecial = RegExp(r'[^A-Za-z0-9]').hasMatch(password);
    if (!hasUppercase || !hasLowercase || !hasNumber || !hasSpecial) {
      return passwordPolicyMessage;
    }
    return null;
  }

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    _dashboardLayout = _localStorageService.dashboardLayout;
    _reminderLeadMinutes = _localStorageService.reminderLeadMinutes;
    _preferredCategories = _localStorageService.preferredCategories.toSet();
    _lastSelectedTab = _localStorageService.lastSelectedTab;

    final firebaseUser = _authService.currentUser;
    _uid = firebaseUser?.uid;
    _email = firebaseUser?.email;

    if (_uid != null && _email != null) {
      if (_authService.isEmailVerified) {
        await loadCurrentUserProfile();
        if (_currentUser != null) {
          _status = AuthStatus.authenticated;
        } else {
          _status = AuthStatus.needsProfile;
        }
      } else {
        _currentUser = null;
        _status = AuthStatus.emailVerificationPending;
      }
    } else {
      _status = AuthStatus.loggedOut;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail.isEmpty) {
      _errorMessage = 'Sabancı email cannot be empty.';
      notifyListeners();
      return false;
    }
    if (!isSabanciEmail(normalizedEmail)) {
      _errorMessage = 'Please use your @sabanciuniv.edu address.';
      notifyListeners();
      return false;
    }
    if (password.isEmpty) {
      _errorMessage = 'Password cannot be empty.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final credential = await _authService.signInWithEmailAndPassword(
        normalizedEmail,
        password,
      );
      _uid = credential.user?.uid;
      _email = credential.user?.email ?? normalizedEmail;
      if (credential.user?.emailVerified ?? false) {
        await loadCurrentUserProfile();
        _status = _currentUser == null
            ? AuthStatus.needsProfile
            : AuthStatus.authenticated;
      } else {
        _currentUser = null;
        _status = AuthStatus.emailVerificationPending;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (error) {
      _errorMessage = _mapAuthError(error);
      _status = AuthStatus.loggedOut;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String email, String password) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail.isEmpty) {
      _errorMessage = 'Sabancı email cannot be empty.';
      notifyListeners();
      return false;
    }
    if (!isSabanciEmail(normalizedEmail)) {
      _errorMessage = 'Please use your @sabanciuniv.edu address.';
      notifyListeners();
      return false;
    }
    if (password.isEmpty) {
      _errorMessage = 'Password cannot be empty.';
      notifyListeners();
      return false;
    }
    final passwordValidationError = validateRegistrationPassword(password);
    if (passwordValidationError != null) {
      _errorMessage = passwordValidationError;
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final credential = await _authService.createUserWithEmailAndPassword(
        normalizedEmail,
        password,
      );
      _uid = credential.user?.uid;
      _email = credential.user?.email ?? normalizedEmail;
      _currentUser = null;
      await _authService.sendEmailVerification();
      _status = AuthStatus.emailVerificationPending;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (error) {
      _isLoading = false;
      _status = AuthStatus.loggedOut;
      _errorMessage = _mapAuthError(error);
      notifyListeners();
      return false;
    }
  }

  Future<bool> sendPasswordResetEmail(String email) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail.isEmpty) {
      _errorMessage = 'Sabancı email cannot be empty.';
      notifyListeners();
      return false;
    }
    if (!isSabanciEmail(normalizedEmail)) {
      _errorMessage = 'Please use your @sabanciuniv.edu address.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.sendPasswordResetEmail(normalizedEmail);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (error) {
      _errorMessage = _mapPasswordResetError(error);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> resendVerificationEmail() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.sendEmailVerification();
      _errorMessage = 'Verification email sent. Please check your inbox.';
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (error) {
      _errorMessage = _mapAuthError(error);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> refreshEmailVerification() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _authService.reloadCurrentUser();
      _uid = user?.uid;
      _email = user?.email ?? _email;

      if (user == null) {
        _currentUser = null;
        _status = AuthStatus.loggedOut;
        _errorMessage = 'Your session expired. Please log in again.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (!(user.emailVerified)) {
        _currentUser = null;
        _status = AuthStatus.emailVerificationPending;
        _errorMessage =
            'Your email is not verified yet. Please check your inbox and try again.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      await loadCurrentUserProfile();
      _status = _currentUser == null
          ? AuthStatus.needsProfile
          : AuthStatus.authenticated;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (error) {
      _errorMessage = _mapAuthError(error);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    if (currentPassword.isEmpty) {
      _errorMessage = 'Current password cannot be empty.';
      notifyListeners();
      return false;
    }
    if (newPassword.isEmpty) {
      _errorMessage = 'New password cannot be empty.';
      notifyListeners();
      return false;
    }
    final passwordValidationError = validateRegistrationPassword(newPassword);
    if (passwordValidationError != null) {
      _errorMessage = passwordValidationError;
      notifyListeners();
      return false;
    }
    if (newPassword != confirmNewPassword) {
      _errorMessage = 'New passwords do not match.';
      notifyListeners();
      return false;
    }
    if ((_email ?? '').isEmpty) {
      _errorMessage =
          'Your session is missing email information. Please log in again.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.changePassword(
        email: _email!,
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (error) {
      _errorMessage = _mapChangePasswordError(error);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> loadCurrentUserProfile() async {
    if (_uid == null) {
      _currentUser = null;
      notifyListeners();
      return;
    }

    _currentUser = await _firestoreService.getUserProfile(_uid!);
    notifyListeners();
  }

  Future<void> createOrUpdateUserProfile(AppUser user) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final resolvedRole = canUseAdminRole ? 'admin' : 'student';
    final profile = user.copyWith(
      uid: _uid,
      email: _normalizeEmail(_email),
      role: resolvedRole,
      firstName: resolvedRole == 'admin' ? '' : user.firstName.trim(),
      lastName: resolvedRole == 'admin' ? '' : user.lastName.trim(),
      department: resolvedRole == 'admin' ? '' : user.department.trim(),
      clubName: resolvedRole == 'admin' ? user.clubName?.trim() : null,
      createdAt: _currentUser?.createdAt ?? user.createdAt,
      updatedAt: DateTime.now(),
    );

    await _firestoreService.createOrUpdateUserProfile(profile);
    _currentUser = profile;
    _status = AuthStatus.authenticated;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    await _authService.signOut();
    _uid = null;
    _email = null;
    _currentUser = null;
    _errorMessage = null;
    _status = AuthStatus.loggedOut;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updatePreferences({
    Set<String>? categories,
    String? layout,
    int? reminderMinutes,
    String? lastSelectedTab,
  }) async {
    if (categories != null) {
      _preferredCategories = categories;
      await _localStorageService.savePreferredCategories(
        categories.toList(),
      );
    }
    if (layout != null) {
      _dashboardLayout = layout;
      await _localStorageService.saveDashboardLayout(layout);
    }
    if (reminderMinutes != null) {
      _reminderLeadMinutes = reminderMinutes;
      await _localStorageService.saveReminderLeadMinutes(reminderMinutes);
    }
    if (lastSelectedTab != null) {
      _lastSelectedTab = lastSelectedTab;
      await _localStorageService.saveLastSelectedTab(lastSelectedTab);
    }
    notifyListeners();
  }

  void clearError() {
    if (_errorMessage == null) {
      return;
    }
    _errorMessage = null;
    notifyListeners();
  }

  String _normalizeEmail(String? value) {
    return (value ?? '').trim().toLowerCase();
  }

  String _mapAuthError(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'email-already-in-use':
          return 'An account already exists for this email. Please log in instead.';
        case 'user-not-found':
          return 'No account found for this email. Please create an account first.';
        case 'wrong-password':
          return 'Incorrect email or password.';
        case 'invalid-credential':
          return 'Incorrect email or password, or no account exists for this email.';
        case 'invalid-email':
          return 'Please enter a valid email address.';
        case 'weak-password':
          return passwordPolicyMessage;
        case 'operation-not-allowed':
          return 'Email/password sign-in is not enabled in Firebase Auth.';
        case 'too-many-requests':
          return 'Too many attempts. Please try again later.';
        case 'network-request-failed':
          return 'Network error. Please check your connection.';
        case 'user-disabled':
          return 'This account has been disabled.';
      }
      return error.message ?? error.toString();
    }
    return error.toString();
  }

  String _mapPasswordResetError(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-email':
          return 'Please enter a valid Sabancı email address.';
        case 'user-not-found':
          return 'No account found for this email. Please create an account first.';
        case 'too-many-requests':
          return 'Too many attempts. Please try again later.';
        case 'network-request-failed':
          return 'Network error. Please check your connection.';
      }
      return error.message ?? error.toString();
    }
    return error.toString();
  }

  String _mapChangePasswordError(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'wrong-password':
        case 'invalid-credential':
          return 'Current password is incorrect.';
        case 'weak-password':
          return passwordPolicyMessage;
        case 'too-many-requests':
          return 'Too many attempts. Please try again later.';
        case 'network-request-failed':
          return 'Network error. Please check your connection.';
        case 'requires-recent-login':
          return 'For security reasons, please log in again before changing your password.';
      }
      return error.message ?? error.toString();
    }
    return error.toString();
  }
}

extension on Iterable<String> {
  String? get firstOrNull => isEmpty ? null : first;
}
