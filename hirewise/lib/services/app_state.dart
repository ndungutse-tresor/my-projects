// Firebase-backed singleton that keeps the same public surface area as the
// original in-memory AppState so existing screens continue to compile while
// they are progressively migrated to Riverpod providers in later phases.

// Re-export the real model so every file that imports this one still gets
// AppUser and TutorStatus without changing its import path.
export '../models/app_user.dart' show AppUser, TutorStatus;

import '../models/app_user.dart';
import '../core/services/auth_service.dart';
import '../core/services/user_service.dart';
import '../core/errors/app_exceptions.dart';

class AppState {
  static final AppState instance = AppState._();
  AppState._();

  // Set by AuthGate after Firebase resolves the session, so all screens that
  // still reference AppState.instance.currentUser get a live value.
  AppUser? currentUser;

  final _authService = AuthService();
  final _userService = UserService();

  // ── Auth ─────────────────────────────────────────────────────────────────

  Future<AppUser> signIn(String email, String password) async {
    final user = await _authService.signIn(email, password);
    currentUser = user;
    return user;
  }

  Future<AppUser> signUp({
    required String email,
    required String password,
    required String name,
    required String role,
    String phone = '',
    String specialty = '',
    String qualifications = '',
    String experience = '',
    String applicationStatement = '',
  }) async {
    final user = await _authService.createAccount(
      email: email,
      password: password,
      name: name,
      role: role,
      phone: phone,
      specialty: specialty,
      qualifications: qualifications,
      experience: experience,
      applicationStatement: applicationStatement,
    );
    currentUser = user;
    return user;
  }

  Future<void> signOut() async {
    await _authService.signOut();
    currentUser = null;
  }

  Future<void> sendPasswordReset(String email) async {
    await _authService.sendPasswordResetEmail(email);
  }

  Future<void> resendVerificationEmail() async {
    await _authService.resendVerificationEmail();
  }

  // ── Profile ───────────────────────────────────────────────────────────────

  Future<void> updateProfile({
    String? name,
    String? phone,
    String? location,
    String? bio,
    String? specialty,
  }) async {
    if (currentUser == null) return;
    final updates = <String, dynamic>{};
    if (name != null && name.isNotEmpty) {
      updates['name'] = name;
      currentUser!.name = name;
    }
    if (phone != null) {
      updates['phone'] = phone;
      currentUser!.phone = phone;
    }
    if (location != null) {
      updates['location'] = location;
      currentUser!.location = location;
    }
    if (bio != null) {
      updates['bio'] = bio;
      currentUser!.bio = bio;
    }
    if (specialty != null) {
      updates['specialty'] = specialty;
      currentUser!.specialty = specialty;
    }
    if (updates.isNotEmpty) {
      await _userService.updateUser(currentUser!.uid, updates);
    }
  }

  // ── Admin ─────────────────────────────────────────────────────────────────

  // Sync cached list kept for backward compat with admin_shell until Phase 4.
  // Call refreshAdminCache() after a page loads to populate it from Firestore.
  List<AppUser> pendingTutors = [];

  Future<void> refreshAdminCache() async {
    pendingTutors = await _userService.getPendingTutors();
  }

  // Async — admin shell will be migrated to use these directly in Phase 4.
  Future<List<AppUser>> getPendingTutors() => _userService.getPendingTutors();
  Future<List<AppUser>> getAllTutors() =>
      _userService.getUsersByRole('tutor');
  Future<List<AppUser>> getStudents() =>
      _userService.getUsersByRole('student');

  Future<void> approveTutor(String uid) async {
    try {
      await _userService.updateTutorStatus(uid, TutorStatus.approved);
    } on AppException {
      rethrow;
    }
  }

  Future<void> rejectTutor(String uid) async {
    try {
      await _userService.updateTutorStatus(uid, TutorStatus.rejected);
    } on AppException {
      rethrow;
    }
  }
}
