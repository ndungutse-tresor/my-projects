import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../firebase_options.dart';

/// Ensures the two permanent demo admin accounts always exist.
/// Runs on every app startup — idempotent (merge: true, signs in if already exists).
class BootstrapService {
  static final _db = FirebaseFirestore.instance;

  static const _demoAdmins = [
    (email: 'tresor@hirewise.app', password: 'Admin@2025', name: 'Tresor Ndungutse'),
    (email: 'esther@hirewise.app', password: 'Admin@2025', name: 'Esther (Admin)'),
  ];

  static bool _ran = false;

  static Future<void> ensureAdminsExist() async {
    // Only run once per app session — admins are seeded permanently in Firestore.
    if (_ran) return;
    _ran = true;

    for (final admin in _demoAdmins) {
      FirebaseApp? secondaryApp;
      try {
        final appName =
            'bs_${admin.email.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}';
        secondaryApp = await Firebase.initializeApp(
          name: appName,
          options: DefaultFirebaseOptions.web,
        );
        final auth = FirebaseAuth.instanceFor(app: secondaryApp);
        final secondaryDb =
            FirebaseFirestore.instanceFor(app: secondaryApp);

        // If admin Firestore doc already exists, skip entirely — no network writes.
        UserCredential cred;
        try {
          cred = await auth.signInWithEmailAndPassword(
              email: admin.email, password: admin.password);
        } on FirebaseAuthException catch (e) {
          if (e.code == 'user-not-found' ||
              e.code == 'invalid-credential' ||
              e.code == 'wrong-password') {
            cred = await auth.createUserWithEmailAndPassword(
                email: admin.email, password: admin.password);
          } else {
            rethrow;
          }
        }

        final uid = cred.user!.uid;
        final existing =
            await secondaryDb.collection('users').doc(uid).get();
        if (existing.exists && existing.data()?['role'] == 'admin') {
          continue; // Already seeded — no write needed.
        }

        await secondaryDb.collection('users').doc(uid).set({
          'email': admin.email,
          'name': admin.name,
          'role': 'admin',
          'phone': '',
          'location': 'Kigali, Rwanda',
          'bio': 'Platform administrator.',
          'avatarUrl': '',
          'specialty': '',
          'qualifications': '',
          'experience': '',
          'applicationStatement': '',
          'tutorStatus': 'incomplete',
          'savedExpertIds': [],
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } catch (_) {
        // Non-critical — never crash the app
      } finally {
        await secondaryApp?.delete();
      }
    }
  }

  /// Creates a new admin account. Called from the admin panel.
  static Future<String> createAdmin({
    required String email,
    required String password,
    required String name,
    String phone = '',
  }) async {
    FirebaseApp? secondaryApp;
    try {
      final appName =
          'newadmin_${email.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}';
      secondaryApp = await Firebase.initializeApp(
        name: appName,
        options: DefaultFirebaseOptions.web,
      );
      final auth = FirebaseAuth.instanceFor(app: secondaryApp);
      final cred = await auth.createUserWithEmailAndPassword(
          email: email, password: password);
      final uid = cred.user!.uid;
      await _db.collection('users').doc(uid).set({
        'email': email,
        'name': name,
        'role': 'admin',
        'phone': phone,
        'location': 'Kigali, Rwanda',
        'bio': 'Platform administrator.',
        'avatarUrl': '',
        'specialty': '',
        'qualifications': '',
        'experience': '',
        'applicationStatement': '',
        'tutorStatus': 'incomplete',
        'savedExpertIds': [],
        'createdAt': FieldValue.serverTimestamp(),
      });
      return uid;
    } finally {
      await secondaryApp?.delete();
    }
  }

  /// Creates a new tutor account. Called from the admin panel.
  static Future<String> createTutor({
    required String email,
    required String password,
    required String name,
    String phone = '',
    String specialty = '',
  }) async {
    FirebaseApp? secondaryApp;
    try {
      final appName =
          'newtutor_${email.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}';
      secondaryApp = await Firebase.initializeApp(
        name: appName,
        options: DefaultFirebaseOptions.web,
      );
      final auth = FirebaseAuth.instanceFor(app: secondaryApp);
      final cred = await auth.createUserWithEmailAndPassword(
          email: email, password: password);
      final uid = cred.user!.uid;
      await _db.collection('users').doc(uid).set({
        'email': email,
        'name': name,
        'role': 'tutor',
        'phone': phone,
        'location': 'Kigali, Rwanda',
        'bio': '',
        'avatarUrl': '',
        'specialty': specialty,
        'qualifications': '',
        'experience': '',
        'applicationStatement': '',
        'tutorStatus': 'approved',
        'savedExpertIds': [],
        'createdAt': FieldValue.serverTimestamp(),
      });
      // Create experts doc so the tutor appears in listings
      await _db.collection('experts').doc(uid).set({
        'name': name,
        'title': specialty.isNotEmpty ? specialty : 'Tutor',
        'sector': 'Education',
        'rating': 0.0,
        'reviewCount': 0,
        'yearsExp': 0,
        'responseTime': 'N/A',
        'completedJobs': 0,
        'about': '',
        'startingPrice': 0,
        'isVerified': true,
        'isOnline': true,
        'avatarUrl': '',
        'services': [],
        'reviews': [],
      });
      return uid;
    } finally {
      await secondaryApp?.delete();
    }
  }
}
