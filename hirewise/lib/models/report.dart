import 'package:cloud_firestore/cloud_firestore.dart';

enum ReportReason {
  inappropriateBehavior,
  scam,
  noShow,
  fakeCredentials,
  harassment,
  other,
}

extension ReportReasonLabel on ReportReason {
  String get label => switch (this) {
        ReportReason.inappropriateBehavior => 'Inappropriate Behavior',
        ReportReason.scam => 'Scam / Fraud',
        ReportReason.noShow => 'No-Show / No Contact',
        ReportReason.fakeCredentials => 'Fake Credentials',
        ReportReason.harassment => 'Harassment',
        ReportReason.other => 'Other',
      };
}

enum ReportStatus { pending, underReview, resolved, dismissed }

enum AdminReportAction { warn, suspendTemporary, ban, dismiss }

extension AdminReportActionLabel on AdminReportAction {
  String get label => switch (this) {
        AdminReportAction.warn => 'Issue Warning',
        AdminReportAction.suspendTemporary => 'Suspend (7 days)',
        AdminReportAction.ban => 'Permanent Ban',
        AdminReportAction.dismiss => 'Dismiss Report',
      };
}

class Report {
  final String id;
  final String reporterId;
  final String reporterName;
  final String reportedUserId;
  final String reportedUserName;
  final ReportReason reason;
  final String details;
  final ReportStatus status;
  final String adminNote;
  final AdminReportAction? adminAction;
  final DateTime createdAt;
  final DateTime? resolvedAt;

  const Report({
    required this.id,
    required this.reporterId,
    required this.reporterName,
    required this.reportedUserId,
    required this.reportedUserName,
    required this.reason,
    required this.details,
    required this.status,
    this.adminNote = '',
    this.adminAction,
    required this.createdAt,
    this.resolvedAt,
  });

  factory Report.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Report(
      id: doc.id,
      reporterId: data['reporterId'] as String? ?? '',
      reporterName: data['reporterName'] as String? ?? '',
      reportedUserId: data['reportedUserId'] as String? ?? '',
      reportedUserName: data['reportedUserName'] as String? ?? '',
      reason: ReportReason.values.firstWhere(
        (r) => r.name == (data['reason'] as String? ?? ''),
        orElse: () => ReportReason.other,
      ),
      details: data['details'] as String? ?? '',
      status: ReportStatus.values.firstWhere(
        (s) => s.name == (data['status'] as String? ?? 'pending'),
        orElse: () => ReportStatus.pending,
      ),
      adminNote: data['adminNote'] as String? ?? '',
      adminAction: data['adminAction'] == null
          ? null
          : AdminReportAction.values.firstWhere(
              (a) => a.name == data['adminAction'],
              orElse: () => AdminReportAction.dismiss,
            ),
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      resolvedAt: (data['resolvedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'reporterId': reporterId,
        'reporterName': reporterName,
        'reportedUserId': reportedUserId,
        'reportedUserName': reportedUserName,
        'reason': reason.name,
        'details': details,
        'status': status.name,
        'adminNote': adminNote,
        if (adminAction != null) 'adminAction': adminAction!.name,
        'createdAt': FieldValue.serverTimestamp(),
        if (resolvedAt != null) 'resolvedAt': Timestamp.fromDate(resolvedAt!),
      };
}
