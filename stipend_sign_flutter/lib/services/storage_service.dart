import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class StorageService {
  static final _users = FirebaseFirestore.instance.collection('users');
  static const _sessionKey = 'currentUserId';

  // ── helpers ──────────────────────────────────────────────────────────────

  static Map<String, dynamic> _toFirestore(User u) => {
        'email': u.email,
        'password': u.password,
        'firstName': u.firstName,
        'lastName': u.lastName,
        'studentId': u.studentId,
        'department': u.department,
        'yearOfStudy': u.yearOfStudy,
        'phone': u.phone,
        'isBiometricEnrolled': u.isBiometricEnrolled,
        'hasSigned': u.hasSigned,
        'signedAt': u.signedAt?.toIso8601String(),
        'createdAt': u.createdAt.toIso8601String(),
      };

  static User _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    d['id'] = doc.id;
    return User.fromJson(d);
  }

  // ── read all ──────────────────────────────────────────────────────────────

  static Future<List<User>> getAllStudents() async {
    final snap = await _users.get();
    return snap.docs.map(_fromDoc).toList();
  }

  static Future<List<User>> getSignedStudents() async {
    final snap = await _users.where('hasSigned', isEqualTo: true).get();
    return snap.docs.map(_fromDoc).toList();
  }

  static Future<List<User>> getUnsignedStudents() async {
    final snap = await _users.where('hasSigned', isEqualTo: false).get();
    return snap.docs.map(_fromDoc).toList();
  }

  // ── auth ──────────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> registerUser({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String studentId,
    String department = '',
    String yearOfStudy = '',
    String phone = '',
  }) async {
    // Check duplicate email
    final byEmail =
        await _users.where('email', isEqualTo: email).limit(1).get();
    if (byEmail.docs.isNotEmpty) {
      return {'success': false, 'message': 'Email already registered'};
    }

    // Check duplicate student ID
    if (studentId.isNotEmpty) {
      final byId =
          await _users.where('studentId', isEqualTo: studentId).limit(1).get();
      if (byId.docs.isNotEmpty) {
        return {'success': false, 'message': 'Student ID already registered'};
      }
    }

    final newUser = User(
      id: '', // Firestore auto-assigns
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      studentId: studentId,
      department: department,
      yearOfStudy: yearOfStudy,
      phone: phone,
      createdAt: DateTime.now(),
    );

    final ref = await _users.add(_toFirestore(newUser));
    final withId = User(
      id: ref.id,
      email: newUser.email,
      password: newUser.password,
      firstName: newUser.firstName,
      lastName: newUser.lastName,
      studentId: newUser.studentId,
      department: newUser.department,
      yearOfStudy: newUser.yearOfStudy,
      phone: newUser.phone,
      createdAt: newUser.createdAt,
    );
    return {'success': true, 'user': withId};
  }

  static Future<Map<String, dynamic>> loginUser(
      String email, String password) async {
    final snap = await _users
        .where('email', isEqualTo: email)
        .where('password', isEqualTo: password)
        .limit(1)
        .get();

    if (snap.docs.isEmpty) {
      return {'success': false, 'message': 'Invalid email or password'};
    }

    final user = _fromDoc(snap.docs.first);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, user.id);
    return {'success': true, 'user': user};
  }

  static Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(_sessionKey);
    if (id == null) return null;
    final doc = await _users.doc(id).get();
    if (!doc.exists) return null;
    return _fromDoc(doc);
  }

  static Future<void> logoutUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }

  // ── update ────────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> updateUser(
      String userId, Map<String, dynamic> updates) async {
    final allowedKeys = {
      'firstName', 'lastName', 'studentId', 'department',
      'yearOfStudy', 'phone', 'isBiometricEnrolled',
    };
    final filtered = {
      for (final e in updates.entries)
        if (allowedKeys.contains(e.key)) e.key: e.value
    };

    await _users.doc(userId).update(filtered);
    final doc = await _users.doc(userId).get();
    return {'success': true, 'user': _fromDoc(doc)};
  }

  static Future<Map<String, dynamic>> markStudentSigned(
      String studentId) async {
    await _users.doc(studentId).update({
      'hasSigned': true,
      'signedAt': DateTime.now().toIso8601String(),
    });
    final doc = await _users.doc(studentId).get();
    return {'success': true, 'user': _fromDoc(doc)};
  }

  // ── admin check ───────────────────────────────────────────────────────────

  static bool isAdmin(String email, String password) =>
      email == 'admin@university.edu' && password == 'admin123';
}
