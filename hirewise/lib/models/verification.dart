import 'package:cloud_firestore/cloud_firestore.dart';

enum DocumentType {
  nationalIdFront,
  nationalIdBack,
  profilePhoto,
  qualification,
  professionalLicense,
}

extension DocumentTypeLabel on DocumentType {
  String get label => switch (this) {
        DocumentType.nationalIdFront => 'National ID (Front)',
        DocumentType.nationalIdBack => 'National ID (Back)',
        DocumentType.profilePhoto => 'Profile Photo',
        DocumentType.qualification => 'Qualification / Certificate',
        DocumentType.professionalLicense => 'Professional License',
      };

  String get storageName => switch (this) {
        DocumentType.nationalIdFront => 'national_id_front',
        DocumentType.nationalIdBack => 'national_id_back',
        DocumentType.profilePhoto => 'profile_photo',
        DocumentType.qualification => 'qualification',
        DocumentType.professionalLicense => 'professional_license',
      };

  bool get isImage => this != DocumentType.qualification;
}

class VerificationDocument {
  final String id;
  final DocumentType type;
  final String storagePath;
  final String downloadUrl;
  final String fileName;
  final DateTime uploadedAt;

  const VerificationDocument({
    required this.id,
    required this.type,
    required this.storagePath,
    required this.downloadUrl,
    required this.fileName,
    required this.uploadedAt,
  });

  factory VerificationDocument.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return VerificationDocument(
      id: doc.id,
      type: DocumentType.values.firstWhere(
        (t) => t.name == (data['type'] as String? ?? ''),
        orElse: () => DocumentType.qualification,
      ),
      storagePath: data['storagePath'] as String? ?? '',
      downloadUrl: data['downloadUrl'] as String? ?? '',
      fileName: data['fileName'] as String? ?? '',
      uploadedAt:
          (data['uploadedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'type': type.name,
        'storagePath': storagePath,
        'downloadUrl': downloadUrl,
        'fileName': fileName,
        'uploadedAt': FieldValue.serverTimestamp(),
      };
}

class VerificationApplication {
  final String userId;
  final String tutorName;
  final String tutorEmail;
  final String specialty;
  final String tutorStatus; // mirrors TutorStatus.name
  final String adminNote;
  final String adminId;
  final DateTime? submittedAt;
  final DateTime? reviewedAt;
  final List<VerificationDocument> documents;

  const VerificationApplication({
    required this.userId,
    required this.tutorName,
    required this.tutorEmail,
    required this.specialty,
    required this.tutorStatus,
    this.adminNote = '',
    this.adminId = '',
    this.submittedAt,
    this.reviewedAt,
    this.documents = const [],
  });

  factory VerificationApplication.fromFirestore(
      DocumentSnapshot doc, List<VerificationDocument> docs) {
    final data = doc.data() as Map<String, dynamic>;
    return VerificationApplication(
      userId: doc.id,
      tutorName: data['tutorName'] as String? ?? '',
      tutorEmail: data['tutorEmail'] as String? ?? '',
      specialty: data['specialty'] as String? ?? '',
      tutorStatus: data['tutorStatus'] as String? ?? 'incomplete',
      adminNote: data['adminNote'] as String? ?? '',
      adminId: data['adminId'] as String? ?? '',
      submittedAt: (data['submittedAt'] as Timestamp?)?.toDate(),
      reviewedAt: (data['reviewedAt'] as Timestamp?)?.toDate(),
      documents: docs,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'tutorName': tutorName,
        'tutorEmail': tutorEmail,
        'specialty': specialty,
        'tutorStatus': tutorStatus,
        'adminNote': adminNote,
        'adminId': adminId,
        if (submittedAt != null)
          'submittedAt': Timestamp.fromDate(submittedAt!),
        if (reviewedAt != null)
          'reviewedAt': Timestamp.fromDate(reviewedAt!),
      };
}

class AuditLogEntry {
  final String id;
  final String tutorId;
  final String tutorName;
  final String adminId;
  final String action; // 'submitted' | 'approved' | 'rejected' | 'changes_requested'
  final String note;
  final DateTime timestamp;

  const AuditLogEntry({
    required this.id,
    required this.tutorId,
    required this.tutorName,
    required this.adminId,
    required this.action,
    required this.note,
    required this.timestamp,
  });

  factory AuditLogEntry.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AuditLogEntry(
      id: doc.id,
      tutorId: data['tutorId'] as String? ?? '',
      tutorName: data['tutorName'] as String? ?? '',
      adminId: data['adminId'] as String? ?? '',
      action: data['action'] as String? ?? '',
      note: data['note'] as String? ?? '',
      timestamp:
          (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'tutorId': tutorId,
        'tutorName': tutorName,
        'adminId': adminId,
        'action': action,
        'note': note,
        'timestamp': FieldValue.serverTimestamp(),
      };

  String get actionLabel => switch (action) {
        'approved' => 'Approved',
        'rejected' => 'Rejected',
        'changes_requested' => 'Requested Changes',
        'submitted' => 'Submitted Application',
        _ => action,
      };
}
