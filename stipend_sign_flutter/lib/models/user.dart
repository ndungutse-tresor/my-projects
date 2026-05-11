class User {
  final String id;
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String studentId;
  final String department;
  final String yearOfStudy;
  final String phone;
  final String? studentCardImage;
  final bool isBiometricEnrolled;
  final bool hasSigned;
  final DateTime? signedAt;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.email,
    required this.password,
    this.firstName = '',
    this.lastName = '',
    this.studentId = '',
    this.department = '',
    this.yearOfStudy = '',
    this.phone = '',
    this.studentCardImage,
    this.isBiometricEnrolled = false,
    this.hasSigned = false,
    this.signedAt,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
        'studentId': studentId,
        'department': department,
        'yearOfStudy': yearOfStudy,
        'phone': phone,
        'studentCardImage': studentCardImage,
        'isBiometricEnrolled': isBiometricEnrolled,
        'hasSigned': hasSigned,
        'signedAt': signedAt?.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'],
        email: json['email'],
        password: json['password'],
        firstName: json['firstName'] ?? '',
        lastName: json['lastName'] ?? '',
        studentId: json['studentId'] ?? '',
        department: json['department'] ?? '',
        yearOfStudy: json['yearOfStudy'] ?? '',
        phone: json['phone'] ?? '',
        studentCardImage: json['studentCardImage'],
        isBiometricEnrolled: json['isBiometricEnrolled'] ?? false,
        hasSigned: json['hasSigned'] ?? false,
        signedAt: json['signedAt'] != null ? DateTime.parse(json['signedAt']) : null,
        createdAt: DateTime.parse(json['createdAt']),
      );

  User copyWith({
    String? firstName,
    String? lastName,
    String? studentId,
    String? department,
    String? yearOfStudy,
    String? phone,
    String? studentCardImage,
    bool? isBiometricEnrolled,
    bool? hasSigned,
    DateTime? signedAt,
  }) =>
      User(
        id: id,
        email: email,
        password: password,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        studentId: studentId ?? this.studentId,
        department: department ?? this.department,
        yearOfStudy: yearOfStudy ?? this.yearOfStudy,
        phone: phone ?? this.phone,
        studentCardImage: studentCardImage ?? this.studentCardImage,
        isBiometricEnrolled: isBiometricEnrolled ?? this.isBiometricEnrolled,
        hasSigned: hasSigned ?? this.hasSigned,
        signedAt: signedAt ?? this.signedAt,
        createdAt: createdAt,
      );

  String get initials {
    final f = firstName.isNotEmpty ? firstName[0] : '';
    final l = lastName.isNotEmpty ? lastName[0] : '';
    return '$f$l'.toUpperCase();
  }

  String get fullName => '$firstName $lastName'.trim();
}
