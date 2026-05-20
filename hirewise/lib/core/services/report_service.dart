import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/report.dart';

class ReportService {
  final _db = FirebaseFirestore.instance;
  CollectionReference get _reports => _db.collection('reports');
  CollectionReference get _users => _db.collection('users');

  // Submit a new report from a user.
  Future<void> submitReport({
    required String reporterId,
    required String reporterName,
    required String reportedUserId,
    required String reportedUserName,
    required ReportReason reason,
    required String details,
  }) async {
    await _reports.add({
      'reporterId': reporterId,
      'reporterName': reporterName,
      'reportedUserId': reportedUserId,
      'reportedUserName': reportedUserName,
      'reason': reason.name,
      'details': details,
      'status': ReportStatus.pending.name,
      'adminNote': '',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Admin: live stream of pending/under-review reports.
  Stream<List<Report>> pendingReportsStream() {
    return _reports
        .where('status', whereIn: [
          ReportStatus.pending.name,
          ReportStatus.underReview.name,
        ])
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((s) => s.docs.map(Report.fromFirestore).toList());
  }

  // Admin: resolve a report with an action.
  Future<void> resolveReport({
    required String reportId,
    required String reportedUserId,
    required AdminReportAction action,
    required String adminNote,
  }) async {
    final batch = _db.batch();

    batch.update(_reports.doc(reportId), {
      'status': ReportStatus.resolved.name,
      'adminAction': action.name,
      'adminNote': adminNote,
      'resolvedAt': FieldValue.serverTimestamp(),
    });

    // Apply platform action to the reported user's profile.
    if (action == AdminReportAction.ban) {
      batch.update(_users.doc(reportedUserId), {'isBanned': true});
    } else if (action == AdminReportAction.suspendTemporary) {
      final until = DateTime.now().add(const Duration(days: 7));
      batch.update(_users.doc(reportedUserId), {
        'isSuspendedUntil': Timestamp.fromDate(until),
      });
    }

    await batch.commit();
  }

  // Admin: dismiss a report without action.
  Future<void> dismissReport(String reportId) async {
    await _reports.doc(reportId).update({
      'status': ReportStatus.dismissed.name,
      'resolvedAt': FieldValue.serverTimestamp(),
    });
  }
}
