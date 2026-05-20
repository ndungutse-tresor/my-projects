import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/app_user.dart';

class UserService {
  final _db = FirebaseFirestore.instance;
  CollectionReference get _users => _db.collection('users');

  Future<AppUser?> getUser(String uid) async {
    final doc = await _users.doc(uid).get();
    if (!doc.exists) return null;
    return AppUser.fromFirestore(doc);
  }

  Future<void> createUser(AppUser user) async {
    await _users.doc(user.uid).set(user.toFirestore());
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _users.doc(uid).update(data);
  }

  Stream<AppUser?> userStream(String uid) {
    return _users.doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return AppUser.fromFirestore(doc);
    });
  }

  Future<List<AppUser>> getUsersByRole(String role) async {
    final query = await _users.where('role', isEqualTo: role).get();
    return query.docs.map((d) => AppUser.fromFirestore(d)).toList();
  }

  Future<List<AppUser>> getPendingTutors() async {
    final query = await _users
        .where('role', isEqualTo: 'tutor')
        .where('tutorStatus', isEqualTo: 'pending')
        .get();
    return query.docs.map((d) => AppUser.fromFirestore(d)).toList();
  }

  Stream<List<AppUser>> pendingTutorsStream() {
    return _users
        .where('role', isEqualTo: 'tutor')
        .where('tutorStatus', isEqualTo: 'pending')
        .snapshots()
        .map((q) => q.docs.map((d) => AppUser.fromFirestore(d)).toList());
  }

  Future<void> updateTutorStatus(String uid, TutorStatus status) async {
    await _users.doc(uid).update({'tutorStatus': status.name});
  }

  Future<void> updateTutorStatusByEmail(
      String email, TutorStatus status) async {
    final query =
        await _users.where('email', isEqualTo: email.toLowerCase()).limit(1).get();
    if (query.docs.isEmpty) return;
    await updateTutorStatus(query.docs.first.id, status);
  }

  Stream<List<AppUser>> usersByRoleStream(String role) {
    return _users
        .where('role', isEqualTo: role)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((q) => q.docs.map((d) => AppUser.fromFirestore(d)).toList());
  }

  Stream<int> studentsCountStream() {
    return _users
        .where('role', isEqualTo: 'student')
        .snapshots()
        .map((q) => q.docs.length);
  }

  Stream<int> activeTutorsCountStream() {
    return _users
        .where('role', isEqualTo: 'tutor')
        .where('tutorStatus', isEqualTo: 'approved')
        .snapshots()
        .map((q) => q.docs.length);
  }

  Stream<List<AppUser>> recentUsersStream({int limit = 5}) {
    return _users
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((q) => q.docs.map((d) => AppUser.fromFirestore(d)).toList());
  }

  Future<void> toggleSaveExpert(String uid, String expertId) async {
    final doc = await _users.doc(uid).get();
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final saved = List<String>.from(data['savedExpertIds'] as List? ?? []);
    if (saved.contains(expertId)) {
      saved.remove(expertId);
    } else {
      saved.add(expertId);
    }
    await _users.doc(uid).update({'savedExpertIds': saved});
  }
}
