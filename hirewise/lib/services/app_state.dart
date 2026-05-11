
enum TutorStatus { pending, approved, rejected }

class AppUser {
  String email;
  String password;
  String name;
  String role;
  String phone;
  String location;
  String bio;
  String specialty;
  String qualifications;
  String experience;
  String applicationStatement;
  TutorStatus tutorStatus;

  AppUser({
    required this.email,
    required this.password,
    required this.name,
    required this.role,
    this.phone = '',
    this.location = 'Kigali, Rwanda',
    this.bio = '',
    this.specialty = '',
    this.qualifications = '',
    this.experience = '',
    this.applicationStatement = '',
    this.tutorStatus = TutorStatus.pending,
  });

  String get initial => name.isNotEmpty ? name[0].toUpperCase() : '?';
}

class AppState {
  static final AppState instance = AppState._();
  AppState._();

  AppUser? currentUser;

  final List<AppUser> _users = [
    AppUser(
      email: 'student@demo.com',
      password: 'password',
      name: 'Jean Claude Nkurunziza',
      role: 'student',
      phone: '+250 788 123 456',
      location: 'Kigali, Rwanda',
      bio: 'Computer Science student passionate about mobile development.',
    ),
    AppUser(
      email: 'tutor@demo.com',
      password: 'password',
      name: 'Dr. Amina Uwase',
      role: 'tutor',
      phone: '+250 789 654 321',
      location: 'Kigali, Rwanda',
      bio: 'Passionate educator with 8+ years experience in software development.',
      specialty: 'Full-Stack Development',
      qualifications: 'PhD Computer Science, University of Rwanda',
      experience: '8 years',
      applicationStatement:
          'I want to empower the next generation of Rwandan developers through quality tutoring.',
      tutorStatus: TutorStatus.approved,
    ),
    AppUser(
      email: 'tutor2@demo.com',
      password: 'password',
      name: 'Sophia Vance',
      role: 'tutor',
      phone: '+250 731 987 654',
      location: 'Kigali, Rwanda',
      bio: 'UI/UX Designer with a passion for beautiful interfaces.',
      specialty: 'UI/UX Design',
      qualifications: 'Bachelor of Design, INES-Ruhengeri',
      experience: '5 years',
      applicationStatement:
          'I can help students master design principles and build stunning apps.',
      tutorStatus: TutorStatus.pending,
    ),
    AppUser(
      email: 'tutor3@demo.com',
      password: 'password',
      name: 'Marcus Williams',
      role: 'tutor',
      phone: '+250 722 111 222',
      location: 'Kigali, Rwanda',
      bio: 'Database expert and backend engineer.',
      specialty: 'Database Design & Backend',
      qualifications: 'MSc Information Systems, Carnegie Mellon Africa',
      experience: '6 years',
      applicationStatement:
          'I specialize in teaching data-driven engineering to students.',
      tutorStatus: TutorStatus.pending,
    ),
    AppUser(
      email: 'admin@demo.com',
      password: 'admin123',
      name: 'HireWise Admin',
      role: 'admin',
      location: 'Kigali, Rwanda',
      bio: 'Platform administrator.',
    ),
  ];


  AppUser? login(String email, String password, String role) {
    try {
      final user = _users.firstWhere(
        (u) =>
            u.email.toLowerCase() == email.toLowerCase() &&
            u.password == password &&
            u.role == role,
      );
      currentUser = user;
      return user;
    } catch (_) {
      return null;
    }
  }

  bool signup(AppUser newUser) {
    final exists = _users
        .any((u) => u.email.toLowerCase() == newUser.email.toLowerCase());
    if (exists) return false;
    _users.add(newUser);
    currentUser = newUser;
    return true;
  }

  void logout() => currentUser = null;


  void approveTutor(String email) {
    final u = _userByEmail(email);
    if (u != null) u.tutorStatus = TutorStatus.approved;
    if (currentUser?.email == email) {
      currentUser!.tutorStatus = TutorStatus.approved;
    }
  }

  void rejectTutor(String email) {
    final u = _userByEmail(email);
    if (u != null) u.tutorStatus = TutorStatus.rejected;
  }

  AppUser? _userByEmail(String email) {
    try {
      return _users.firstWhere((u) => u.email == email);
    } catch (_) {
      return null;
    }
  }


  List<AppUser> get pendingTutors =>
      _users.where((u) => u.role == 'tutor' && u.tutorStatus == TutorStatus.pending).toList();

  List<AppUser> get approvedTutors =>
      _users.where((u) => u.role == 'tutor' && u.tutorStatus == TutorStatus.approved).toList();

  List<AppUser> get allTutors =>
      _users.where((u) => u.role == 'tutor').toList();

  List<AppUser> get students =>
      _users.where((u) => u.role == 'student').toList();


  void updateProfile({
    String? name,
    String? phone,
    String? location,
    String? bio,
    String? specialty,
  }) {
    if (currentUser == null) return;
    if (name != null && name.isNotEmpty) currentUser!.name = name;
    if (phone != null) currentUser!.phone = phone;
    if (location != null) currentUser!.location = location;
    if (bio != null) currentUser!.bio = bio;
    if (specialty != null) currentUser!.specialty = specialty;
  }
}
