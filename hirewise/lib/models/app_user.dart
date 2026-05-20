import 'package:cloud_firestore/cloud_firestore.dart';

enum TutorStatus {
  incomplete,        // just signed up, profile not submitted yet
  pending,           // submitted for review, awaiting admin decision
  approved,          // verified and visible in listings
  changesRequested,  // admin asked for more info / better documents
  rejected,          // application denied
}

class AppUser {
  final String uid;
  final String email;
  String name;
  final String role;
  String phone;
  String location;
  String bio;
  String avatarUrl;
  String specialty;
  String qualifications;
  String experience;
  String applicationStatement;
  TutorStatus tutorStatus;
  final DateTime createdAt;
  DateTime? verificationSubmittedAt;
  List<String> savedExpertIds;

  AppUser({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    this.phone = '',
    this.location = 'Kigali, Rwanda',
    this.bio = '',
    this.avatarUrl = '',
    this.specialty = '',
    this.qualifications = '',
    this.experience = '',
    this.applicationStatement = '',
    this.tutorStatus = TutorStatus.incomplete,
    DateTime? createdAt,
    this.verificationSubmittedAt,
    this.savedExpertIds = const [],
  }) : createdAt = createdAt ?? DateTime.now();

  String get initial => name.isNotEmpty ? name[0].toUpperCase() : '?';

  bool get isVerified => tutorStatus == TutorStatus.approved;
  bool get isPending => tutorStatus == TutorStatus.pending;
  bool get needsChanges => tutorStatus == TutorStatus.changesRequested;

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppUser(
      uid: doc.id,
      email: data['email'] as String? ?? '',
      name: data['name'] as String? ?? '',
      role: data['role'] as String? ?? 'student',
      phone: data['phone'] as String? ?? '',
      location: data['location'] as String? ?? 'Kigali, Rwanda',
      bio: data['bio'] as String? ?? '',
      avatarUrl: data['avatarUrl'] as String? ?? '',
      specialty: data['specialty'] as String? ?? '',
      qualifications: data['qualifications'] as String? ?? '',
      experience: data['experience'] as String? ?? '',
      applicationStatement: data['applicationStatement'] as String? ?? '',
      tutorStatus: TutorStatus.values.firstWhere(
        (s) => s.name == (data['tutorStatus'] as String? ?? 'incomplete'),
        orElse: () => TutorStatus.incomplete,
      ),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      verificationSubmittedAt:
          (data['verificationSubmittedAt'] as Timestamp?)?.toDate(),
      savedExpertIds:
          List<String>.from(data['savedExpertIds'] as List? ?? []),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'email': email,
        'name': name,
        'role': role,
        'phone': phone,
        'location': location,
        'bio': bio,
        'avatarUrl': avatarUrl,
        'specialty': specialty,
        'qualifications': qualifications,
        'experience': experience,
        'applicationStatement': applicationStatement,
        'tutorStatus': tutorStatus.name,
        'createdAt': FieldValue.serverTimestamp(),
        'savedExpertIds': savedExpertIds,
        if (verificationSubmittedAt != null)
          'verificationSubmittedAt':
              Timestamp.fromDate(verificationSubmittedAt!),
      };
}
