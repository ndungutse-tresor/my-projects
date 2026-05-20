import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/app_user.dart';
import '../../models/verification.dart';
import 'notification_service.dart';

class VerificationService {
  final _db = FirebaseFirestore.instance;
  final _notifService = NotificationService();

  CollectionReference get _verification => _db.collection('verification');
  CollectionReference get _auditLog => _db.collection('audit_log');
  CollectionReference get _users => _db.collection('users');
  CollectionReference get _experts => _db.collection('experts');

  // ── Tutor-facing ──────────────────────────────────────────────────────────

  // Create or update the verification application record for a tutor.
  Future<void> upsertApplication(VerificationApplication app) async {
    await _verification.doc(app.userId).set(app.toFirestore(), SetOptions(merge: true));
  }

  // Add or replace a single document record under the application.
  Future<String> saveDocument(
      String userId, VerificationDocument doc) async {
    final ref = _verification
        .doc(userId)
        .collection('documents')
        .doc(doc.id);
    await ref.set(doc.toFirestore());
    return ref.id;
  }

  // Remove a document record (e.g. when user re-uploads).
  Future<void> removeDocument(String userId, String docId) async {
    await _verification.doc(userId).collection('documents').doc(docId).delete();
  }

  // Fetch all documents for a tutor's application.
  Future<List<VerificationDocument>> getDocuments(String userId) async {
    final snap =
        await _verification.doc(userId).collection('documents').get();
    return snap.docs.map(VerificationDocument.fromFirestore).toList();
  }

  // Live stream of a tutor's own application (for status updates in UI).
  Stream<VerificationApplication?> applicationStream(String userId) {
    return _verification.doc(userId).snapshots().asyncMap((doc) async {
      if (!doc.exists) return null;
      final docs = await getDocuments(userId);
      return VerificationApplication.fromFirestore(doc, docs);
    });
  }

  // Submit the application: set status → pending, record submittedAt.
  Future<void> submitApplication({
    required String userId,
    required String tutorName,
    required String tutorEmail,
    required String specialty,
  }) async {
    final now = Timestamp.now();
    await _verification.doc(userId).set({
      'tutorName': tutorName,
      'tutorEmail': tutorEmail,
      'specialty': specialty,
      'tutorStatus': TutorStatus.pending.name,
      'submittedAt': now,
    }, SetOptions(merge: true));

    await _users.doc(userId).update({
      'tutorStatus': TutorStatus.pending.name,
      'verificationSubmittedAt': now,
    });

    await _addAuditEntry(
      tutorId: userId,
      tutorName: tutorName,
      adminId: 'system',
      action: 'submitted',
      note: 'Tutor submitted verification application.',
    );
  }

  // ── Admin-facing ──────────────────────────────────────────────────────────

  // Live stream of all pending applications (admin queue).
  Stream<List<VerificationApplication>> pendingApplicationsStream() {
    return _verification
        .where('tutorStatus', isEqualTo: TutorStatus.pending.name)
        .orderBy('submittedAt', descending: false)
        .snapshots()
        .asyncMap((snap) async {
      final apps = <VerificationApplication>[];
      for (final doc in snap.docs) {
        final docs = await getDocuments(doc.id);
        apps.add(VerificationApplication.fromFirestore(doc, docs));
      }
      return apps;
    });
  }

  // Approve a tutor.
  Future<void> approve({
    required String tutorId,
    required String tutorName,
    required String adminId,
    required String note,
  }) async {
    await _decide(
      tutorId: tutorId,
      tutorName: tutorName,
      adminId: adminId,
      status: TutorStatus.approved,
      action: 'approved',
      note: note,
    );
  }

  // Request additional changes from the tutor.
  Future<void> requestChanges({
    required String tutorId,
    required String tutorName,
    required String adminId,
    required String note,
  }) async {
    await _decide(
      tutorId: tutorId,
      tutorName: tutorName,
      adminId: adminId,
      status: TutorStatus.changesRequested,
      action: 'changes_requested',
      note: note,
    );
  }

  // Reject a tutor.
  Future<void> reject({
    required String tutorId,
    required String tutorName,
    required String adminId,
    required String note,
  }) async {
    await _decide(
      tutorId: tutorId,
      tutorName: tutorName,
      adminId: adminId,
      status: TutorStatus.rejected,
      action: 'rejected',
      note: note,
    );
  }

  Future<void> _decide({
    required String tutorId,
    required String tutorName,
    required String adminId,
    required TutorStatus status,
    required String action,
    required String note,
  }) async {
    final now = Timestamp.now();
    final batch = _db.batch();

    batch.update(_verification.doc(tutorId), {
      'tutorStatus': status.name,
      'adminId': adminId,
      'adminNote': note,
      'reviewedAt': now,
    });

    batch.update(_users.doc(tutorId), {
      'tutorStatus': status.name,
    });

    // When approved, create experts/{tutorId} so bookings map to this tutor.
    if (status == TutorStatus.approved) {
      final userDoc = await _users.doc(tutorId).get();
      final data = userDoc.data() as Map<String, dynamic>? ?? {};
      final specialty = data['specialty'] as String? ?? 'Expert';
      batch.set(_experts.doc(tutorId), {
        'name': tutorName,
        'title': specialty,
        'sector': specialty,
        'avatarUrl': data['avatarUrl'] as String? ?? '',
        'rating': 0.0,
        'reviewCount': 0,
        'yearsExp': 0,
        'responseTime': '< 1 hr',
        'completedJobs': 0,
        'about': data['bio'] as String? ?? '',
        'startingPrice': 0,
        'services': [],
        'reviews': [],
        'isVerified': true,
        'isOnline': false,
      }, SetOptions(merge: true));
    }

    await batch.commit();

    await _addAuditEntry(
      tutorId: tutorId,
      tutorName: tutorName,
      adminId: adminId,
      action: action,
      note: note,
    );

    // Notify the tutor of the decision.
    final (title, body) = switch (status) {
      TutorStatus.approved => (
          'Application Approved! 🎉',
          'Congratulations $tutorName! You are now a verified HireWise expert.'
        ),
      TutorStatus.rejected => (
          'Application Not Approved',
          'Your HireWise tutor application was not approved. ${note.isNotEmpty ? note : ''}'
        ),
      TutorStatus.changesRequested => (
          'Changes Requested',
          'Admin has requested changes to your application. $note'
        ),
      _ => ('Application Update', note),
    };
    await _notifService.send(
      recipientUid: tutorId,
      type: action,
      title: title,
      body: body,
    );
  }

  // ── Audit log ─────────────────────────────────────────────────────────────

  Future<void> _addAuditEntry({
    required String tutorId,
    required String tutorName,
    required String adminId,
    required String action,
    required String note,
  }) async {
    await _auditLog.add({
      'tutorId': tutorId,
      'tutorName': tutorName,
      'adminId': adminId,
      'action': action,
      'note': note,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Live stream of all audit log entries for a specific tutor.
  Stream<List<AuditLogEntry>> auditLogStream(String tutorId) {
    return _auditLog
        .where('tutorId', isEqualTo: tutorId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((s) => s.docs.map(AuditLogEntry.fromFirestore).toList());
  }

  // All audit log entries (admin-wide view).
  Stream<List<AuditLogEntry>> allAuditLogStream() {
    return _auditLog
        .orderBy('timestamp', descending: true)
        .limit(200)
        .snapshots()
        .map((s) => s.docs.map(AuditLogEntry.fromFirestore).toList());
  }
}
