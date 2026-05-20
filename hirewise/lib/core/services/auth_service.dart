import 'package:firebase_auth/firebase_auth.dart';
import '../../models/app_user.dart';
import '../errors/app_exceptions.dart';
import 'user_service.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _userService = UserService();

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentFirebaseUser => _auth.currentUser;
  bool get isSignedIn => _auth.currentUser != null;

  Future<AppUser> signIn(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final firebaseUser = cred.user!;

      // Try to load the Firestore profile.
      AppUser? user;
      bool loadedFromFirestore = false;
      try {
        user = await _userService.getUser(firebaseUser.uid);
        if (user != null) loadedFromFirestore = true;
      } on FirebaseException catch (e) {
        if (e.code == 'permission-denied') {
          throw const AppException(
            'Database access denied.\n'
            'Go to Firebase Console → Firestore → Rules and set them to allow reads.',
          );
        }
        // Any other Firestore error — still let them in with a minimal profile.
      }

      final resolvedEmail = firebaseUser.email ?? email.trim();
      const knownAdminEmails = {'tresor@hirewise.app', 'esther@hirewise.app'};
      final isAdminEmail = knownAdminEmails.contains(resolvedEmail.toLowerCase());

      // If the Firestore doc is missing, recreate it so login never hard-fails.
      if (user == null) {
        user = AppUser(
          uid: firebaseUser.uid,
          email: resolvedEmail,
          name: firebaseUser.displayName ?? resolvedEmail.split('@').first,
          role: isAdminEmail ? 'admin' : 'student',
          tutorStatus: TutorStatus.incomplete,
        );
        try {
          await _userService.createUser(user);
        } catch (_) {}
      }

      // Correct the role for known admin accounts only.
      if (isAdminEmail && user.role != 'admin') {
        try {
          await _userService.updateUser(firebaseUser.uid, {'role': 'admin'});
        } catch (_) {}
        user = AppUser(
          uid: user.uid,
          email: user.email,
          name: user.name,
          role: 'admin',
          phone: user.phone,
          location: user.location,
          bio: user.bio,
          avatarUrl: user.avatarUrl,
          specialty: user.specialty,
          qualifications: user.qualifications,
          experience: user.experience,
          applicationStatement: user.applicationStatement,
          tutorStatus: user.tutorStatus,
          savedExpertIds: user.savedExpertIds,
        );
      }

      // Require email verification for non-admin accounts only.
      // Skip if Firestore profile couldn't be loaded (role is unknown).
      if (loadedFromFirestore &&
          user.role != 'admin' &&
          !firebaseUser.emailVerified) {
        throw const AppException(
          'Your email address is not verified yet.\n'
          'Check your inbox for the verification link.',
          code: 'email-not-verified',
        );
      }

      return user;
    } on FirebaseAuthException catch (e) {
      throw AppException(_mapAuthError(e.code));
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('Sign in failed: ${e.toString()}');
    }
  }

  Future<AppUser> createAccount({
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
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await cred.user!.updateDisplayName(name);

      final user = AppUser(
        uid: cred.user!.uid,
        email: email.trim(),
        name: name,
        role: role,
        phone: phone,
        specialty: specialty,
        qualifications: qualifications,
        experience: experience,
        applicationStatement: applicationStatement,
        tutorStatus:
            role == 'tutor' ? TutorStatus.incomplete : TutorStatus.approved,
      );

      try {
        await _userService.createUser(user);
      } on FirebaseException catch (e) {
        if (e.code == 'permission-denied') {
          // Auth account created but Firestore blocked the write.
          // The profile will be auto-created on first sign-in.
          // Don't throw — signup still succeeded.
        } else {
          rethrow;
        }
      }

      // Send email verification — non-blocking, failure is silently ignored.
      try {
        await cred.user!.sendEmailVerification();
      } catch (_) {}

      return user;
    } on FirebaseAuthException catch (e) {
      throw AppException(_mapAuthError(e.code));
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('Account creation failed: ${e.toString()}');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Resends the verification email to the currently signed-in user,
  /// then signs them out so they must verify before continuing.
  Future<void> resendVerificationEmail() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
    } catch (_) {}
    await _auth.signOut();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw AppException(_mapAuthError(e.code));
    } catch (e) {
      throw AppException('Could not send reset email: ${e.toString()}');
    }
  }

  String _mapAuthError(String code) {
    return switch (code) {
      'user-not-found' => 'No account found with this email.',
      'wrong-password' => 'Incorrect password. Please try again.',
      'invalid-credential' => 'Incorrect email or password. Please try again.',
      'email-already-in-use' => 'This email is already registered. Sign in instead.',
      'weak-password' => 'Password must be at least 6 characters.',
      'invalid-email' => 'Please enter a valid email address.',
      'too-many-requests' => 'Too many failed attempts. Try again later or reset your password.',
      'network-request-failed' =>
        'No internet connection. Please check your network.',
      'user-disabled' => 'This account has been disabled. Contact support.',
      _ => 'Error ($code). Please try again.',
    };
  }
}
