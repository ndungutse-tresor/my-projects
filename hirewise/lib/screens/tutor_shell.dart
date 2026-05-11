import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/app_state.dart';
import 'inbox_screen.dart';
import 'video_session_screen.dart';
import 'tutor_resources_screen.dart';

class TutorShell extends StatefulWidget {
  const TutorShell({super.key});

  @override
  State<TutorShell> createState() => _TutorShellState();
}

class _TutorShellState extends State<TutorShell> {
  int _index = 0;

  bool get _isPending =>
      AppState.instance.currentUser?.tutorStatus == TutorStatus.pending;

  @override
  Widget build(BuildContext context) {
    final screens = [
      const _TutorDashboard(),
      _isPending ? _lockedScreen('Resources') : const TutorResourcesScreen(),
      _isPending ? _lockedScreen('Messages') : const InboxScreen(),
      const _TutorProfile(),
    ];

    return Scaffold(
      body: screens[_index],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 16,
                offset: const Offset(0, -4))
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(0, Icons.dashboard_outlined, Icons.dashboard_rounded, 'Dashboard'),
                _navItem(1, Icons.folder_outlined, Icons.folder_rounded, 'Resources'),
                _navItem(2, Icons.chat_bubble_outline_rounded, Icons.chat_bubble_rounded, 'Messages', badge: 2),
                _navItem(3, Icons.person_outline_rounded, Icons.person_rounded, 'Profile'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _lockedScreen(String name) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFD97706).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.lock_outline_rounded,
                    size: 40, color: Color(0xFFD97706)),
              ),
              const SizedBox(height: 20),
              Text('$name Locked',
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textDark)),
              const SizedBox(height: 10),
              const Text(
                'This feature is available after your tutor application is approved by the admin.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 13, color: AppTheme.textMuted, height: 1.5),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFD97706).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: const Color(0xFFD97706).withValues(alpha: 0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.pending_outlined,
                        size: 18, color: Color(0xFFD97706)),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Application under review · Typical wait: 1–2 business days',
                        style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFFD97706),
                            height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(int i, IconData icon, IconData active, String label, {int badge = 0}) {
    final isActive = _index == i;
    const color = Color(0xFF059669);
    return GestureDetector(
      onTap: () => setState(() => _index = i),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? color.withValues(alpha: 0.10) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(isActive ? active : icon,
                    color: isActive ? color : Colors.grey.shade400, size: 24),
                const SizedBox(height: 3),
                Text(label,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                        color: isActive ? color : Colors.grey.shade400)),
              ],
            ),
            if (badge > 0)
              Positioned(
                top: -4,
                right: -8,
                child: Container(
                  width: 17,
                  height: 17,
                  decoration: const BoxDecoration(
                      color: Color(0xFFEF4444), shape: BoxShape.circle),
                  child: Center(
                    child: Text('$badge',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TutorDashboard extends StatelessWidget {
  const _TutorDashboard();

  static const _color = Color(0xFF059669);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF059669), Color(0xFF047857)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Good morning,',
                                style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontSize: 13)),
                            Text(
                                AppState.instance.currentUser?.name ??
                                    'Tutor',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800)),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.star_rounded,
                                    color: Color(0xFFFBBF24), size: 14),
                                const SizedBox(width: 4),
                                Text('4.9 Rating  •  142 Students',
                                    style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.85),
                                        fontSize: 12)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.2),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Center(
                          child: Text(
                              AppState.instance.currentUser?.initial ?? 'T',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4))
                ],
              ),
              child: Row(
                children: [
                  _stat('RWF 420K', 'This Month', _color),
                  Container(height: 36, width: 1, color: Colors.grey.shade200),
                  _stat('RWF 2.1M', 'Total Earned', _color),
                  Container(height: 36, width: 1, color: Colors.grey.shade200),
                  _stat('18', 'Sessions', _color),
                  Container(height: 36, width: 1, color: Colors.grey.shade200),
                  _stat('3', 'Pending', const Color(0xFFD97706)),
                ],
              ),
            ),
          ),

          if (AppState.instance.currentUser?.tutorStatus == TutorStatus.pending)
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFD97706).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: const Color(0xFFD97706).withValues(alpha: 0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.pending_outlined,
                        size: 22, color: Color(0xFFD97706)),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Application Under Review',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  color: Color(0xFFD97706))),
                          Text(
                              'Admin is reviewing your application. Some features are locked until approval.',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFFD97706),
                                  height: 1.4)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          SliverToBoxAdapter(child: _sectionLabel('Pending Requests', '3 new')),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _bookingRequest(context, 'Jean Claude Nkurunziza',
                    'Flutter App Development', 'Apr 20, 2025 · 10:00 AM', 'RWF 35,000'),
                _bookingRequest(context, 'Marie Ange Habimana',
                    'UI/UX Design Basics', 'Apr 21, 2025 · 2:00 PM', 'RWF 25,000'),
                _bookingRequest(context, 'Eric Mugisha',
                    'Python for Data Science', 'Apr 22, 2025 · 9:00 AM', 'RWF 30,000'),
              ],
            ),
          ),

          SliverToBoxAdapter(child: _sectionLabel("Today's Sessions", null)),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _sessionCard(context, '10:00 AM', 'React Native Basics',
                    'Alice Uwimana', 'RWF 35,000', true,
                    'HireWise-ReactNative-Amina'),
                _sessionCard(context, '2:00 PM', 'Database Design',
                    'Patrick Habimana', 'RWF 28,000', false,
                    'HireWise-Database-Amina'),
              ],
            ),
          ),

          SliverToBoxAdapter(child: _sectionLabel('My Services', null)),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 110,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _serviceChip(Icons.laptop_mac_rounded, 'App Dev', 'RWF 35K/hr', _color),
                  _serviceChip(Icons.language_rounded, 'Web Dev', 'RWF 28K/hr', _color),
                  _serviceChip(Icons.bar_chart_rounded, 'Data Science', 'RWF 30K/hr', _color),
                  _serviceChip(Icons.brush_rounded, 'UI/UX', 'RWF 25K/hr', _color),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 28)),
        ],
      ),
    );
  }

  Widget _stat(String val, String lbl, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(val,
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 2),
          Text(lbl,
              style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
        ],
      ),
    );
  }

  Widget _sectionLabel(String title, String? badge) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Row(
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textDark)),
          if (badge != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFD97706).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(badge,
                  style: const TextStyle(
                      color: Color(0xFFD97706),
                      fontSize: 11,
                      fontWeight: FontWeight.w700)),
            ),
          ]
        ],
      ),
    );
  }

  static Widget _bookingRequest(BuildContext context, String name,
      String service, String time, String price) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF059669).withValues(alpha: 0.1),
            ),
            child: Center(
              child: Text(name[0],
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF059669))),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: AppTheme.textDark)),
                Text(service,
                    style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                Text(time,
                    style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(price,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: Color(0xFF059669))),
              const SizedBox(height: 8),
              Row(
                children: [
                  _actionBtn('Decline', const Color(0xFFEF4444), () {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Booking with $name declined.'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: const Color(0xFFEF4444),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      margin: const EdgeInsets.all(16),
                    ));
                  }),
                  const SizedBox(width: 6),
                  _actionBtn('Accept', const Color(0xFF059669), () {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Booking with $name accepted!'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: const Color(0xFF059669),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      margin: const EdgeInsets.all(16),
                    ));
                  }),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _actionBtn(String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Text(label,
            style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
      ),
    );
  }

  static Widget _sessionCard(BuildContext context, String time, String subject,
      String student, String price, bool isNext, String roomName) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isNext
            ? Border.all(color: const Color(0xFF059669).withValues(alpha: 0.4), width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF059669).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(time,
                style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: Color(0xFF059669))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(subject,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: AppTheme.textDark)),
                Text('with $student',
                    style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(price,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: AppTheme.primaryBlue)),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => VideoSessionScreen(
                      roomName: roomName,
                      partnerName: student,
                      subject: subject,
                      scheduledTime: time,
                      isTutor: true,
                    ),
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF059669),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.videocam_rounded, color: Colors.white, size: 13),
                      SizedBox(width: 4),
                      Text('Join',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _serviceChip(IconData icon, String name, String price, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.all(14),
      width: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 6),
          Text(name,
              style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  color: AppTheme.textDark)),
          Text(price,
              style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
        ],
      ),
    );
  }
}

class _TutorProfile extends StatefulWidget {
  const _TutorProfile();

  @override
  State<_TutorProfile> createState() => _TutorProfileState();
}

class _TutorProfileState extends State<_TutorProfile> {
  bool _availableForHire = true;


  void _editProfile() {
    final nameCtrl = TextEditingController(text: AppState.instance.currentUser?.name ?? '');
    final specCtrl = TextEditingController(text: AppState.instance.currentUser?.specialty ?? '');
    final bioCtrl = TextEditingController(text: AppState.instance.currentUser?.bio ?? '');
    final rateCtrl = TextEditingController(text: '35,000');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SheetWrap(
        title: 'Edit Profile',
        child: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _field('Full Name', nameCtrl, Icons.person_outline_rounded),
              const SizedBox(height: 12),
              _field('Specialty', specCtrl, Icons.work_outline_rounded),
              const SizedBox(height: 12),
              _field('Bio', bioCtrl, Icons.notes_rounded, maxLines: 3),
              const SizedBox(height: 12),
              _field('Hourly Rate (RWF)', rateCtrl, Icons.attach_money_rounded,
                  keyboardType: TextInputType.number),
              const SizedBox(height: 20),
              _sheetSaveBtn('Save Changes', () {
                AppState.instance.updateProfile(
                  name: nameCtrl.text,
                  bio: bioCtrl.text,
                  specialty: specCtrl.text,
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Profile updated successfully!'),
                  backgroundColor: Color(0xFF059669),
                  behavior: SnackBarBehavior.floating,
                ));
              }),
            ],
          ),
        ),
      ),
    );
  }

  void _myServices() {
    final services = [
      (Icons.laptop_mac_rounded, 'App Development', 'RWF 35,000/hr', const Color(0xFF059669)),
      (Icons.language_rounded, 'Web Development', 'RWF 28,000/hr', AppTheme.primaryBlue),
      (Icons.bar_chart_rounded, 'Data Science', 'RWF 30,000/hr', const Color(0xFF7C3AED)),
      (Icons.brush_rounded, 'UI/UX Design', 'RWF 25,000/hr', const Color(0xFFD97706)),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SheetWrap(
        title: 'My Services & Pricing',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...services.map((s) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F6FB),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: s.$4.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(s.$1, color: s.$4, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(s.$2,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    color: AppTheme.textDark)),
                            Text(s.$3,
                                style: TextStyle(fontSize: 12, color: s.$4, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      Icon(Icons.edit_outlined, size: 18, color: Colors.grey.shade400),
                    ],
                  ),
                )),
            const SizedBox(height: 8),
            _sheetSaveBtn('Add New Service', () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('New service added!'),
                behavior: SnackBarBehavior.floating,
              ));
            }),
          ],
        ),
      ),
    );
  }

  void _availabilityCalendar() {
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final enabled = [true, true, true, false, true, true, false];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModalState) => _SheetWrap(
          title: 'Availability Calendar',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Toggle the days you are available for sessions.',
                style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
              ),
              const SizedBox(height: 14),
              ...List.generate(days.length, (i) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: enabled[i]
                          ? const Color(0xFF059669).withValues(alpha: 0.06)
                          : const Color(0xFFF4F6FB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: enabled[i]
                              ? const Color(0xFF059669).withValues(alpha: 0.3)
                              : Colors.transparent),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today_rounded,
                            size: 18,
                            color: enabled[i]
                                ? const Color(0xFF059669)
                                : Colors.grey.shade400),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(days[i],
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: enabled[i]
                                      ? AppTheme.textDark
                                      : AppTheme.textMuted)),
                        ),
                        Switch(
                          value: enabled[i],
                          onChanged: (v) => setModalState(() => enabled[i] = v),
                          activeThumbColor: const Color(0xFF059669),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: 12),
              _sheetSaveBtn('Save Availability', () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Availability saved!'),
                  backgroundColor: Color(0xFF059669),
                  behavior: SnackBarBehavior.floating,
                ));
              }),
            ],
          ),
        ),
      ),
    );
  }

  void _payoutMethods() {
    int selected = 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModalState) => _SheetWrap(
          title: 'Payout Methods',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _payoutTile(0, selected, Icons.phone_android_rounded, const Color(0xFFFFCC00),
                  'MTN Mobile Money', '+250 789 123 456', () => setModalState(() => selected = 0)),
              const SizedBox(height: 10),
              _payoutTile(1, selected, Icons.phone_android_rounded, const Color(0xFFE40521),
                  'Airtel Money', '+250 731 654 321', () => setModalState(() => selected = 1)),
              const SizedBox(height: 10),
              _payoutTile(2, selected, Icons.account_balance_rounded, const Color(0xFF1E4DB7),
                  'Bank of Kigali', 'ACC: **** 8821', () => setModalState(() => selected = 2)),
              const SizedBox(height: 16),
              _sheetSaveBtn('Save Payout Method', () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Payout method updated!'),
                  behavior: SnackBarBehavior.floating,
                ));
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _payoutTile(int index, int selected, IconData icon, Color color,
      String name, String detail, VoidCallback onTap) {
    final isSelected = index == selected;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.06) : const Color(0xFFF4F6FB),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: isSelected ? color.withValues(alpha: 0.4) : Colors.transparent,
              width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: AppTheme.textDark)),
                  Text(detail,
                      style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                ],
              ),
            ),
            Icon(
                isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: isSelected ? color : Colors.grey.shade400,
                size: 22),
          ],
        ),
      ),
    );
  }

  void _earningsHistory() {
    const months = [
      ('April 2025', 'RWF 420,000', 12),
      ('March 2025', 'RWF 385,000', 10),
      ('February 2025', 'RWF 310,000', 9),
      ('January 2025', 'RWF 450,000', 14),
      ('December 2024', 'RWF 520,000', 16),
      ('November 2024', 'RWF 290,000', 8),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SheetWrap(
        title: 'Earnings History',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFF059669), Color(0xFF047857)]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total Earned', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      Text('RWF 2,375,000',
                          style: TextStyle(
                              color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Total Sessions', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      Text('69 sessions',
                          style: TextStyle(
                              color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ...months.map((m) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F6FB),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFF059669).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.bar_chart_rounded,
                            color: Color(0xFF059669), size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(m.$1,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    color: AppTheme.textDark)),
                            Text('${m.$3} sessions',
                                style: const TextStyle(
                                    fontSize: 12, color: AppTheme.textMuted)),
                          ],
                        ),
                      ),
                      Text(m.$2,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: Color(0xFF059669))),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  void _taxDocuments() {
    const docs = [
      ('Annual Tax Statement 2024', 'PDF · 1.2 MB', Icons.description_outlined),
      ('Annual Tax Statement 2023', 'PDF · 1.1 MB', Icons.description_outlined),
      ('Earnings Summary Q1 2025', 'PDF · 0.8 MB', Icons.summarize_outlined),
      ('TIN Certificate', 'PDF · 0.5 MB', Icons.verified_outlined),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SheetWrap(
        title: 'Tax Documents',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Download your tax documents for RRA compliance.',
              style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
            ),
            const SizedBox(height: 14),
            ...docs.map((d) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F6FB),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(d.$3, color: AppTheme.primaryBlue, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(d.$1,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                    color: AppTheme.textDark)),
                            Text(d.$2,
                                style: const TextStyle(
                                    fontSize: 11, color: AppTheme.textMuted)),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('${d.$1} downloaded!'),
                            behavior: SnackBarBehavior.floating,
                          ));
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.download_rounded,
                              color: AppTheme.primaryBlue, size: 18),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }


  static Widget _field(String label, TextEditingController ctrl, IconData icon,
      {int maxLines = 1, TextInputType? keyboardType}) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF059669))),
        filled: true,
        fillColor: const Color(0xFFF4F6FB),
      ),
    );
  }

  static Widget _sheetSaveBtn(String label, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF059669),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Text(label,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF059669), Color(0xFF047857)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Tutor Profile',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800)),
                          GestureDetector(
                            onTap: () => setState(() => _availableForHire = !_availableForHire),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                      _availableForHire
                                          ? Icons.circle
                                          : Icons.circle_outlined,
                                      size: 8,
                                      color: _availableForHire
                                          ? const Color(0xFF86EFAC)
                                          : Colors.white54),
                                  const SizedBox(width: 5),
                                  Text(
                                      _availableForHire ? 'Available' : 'Unavailable',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                            child: Center(
                              child: Text(
                                  AppState.instance.currentUser?.initial ?? 'T',
                                  style: const TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white)),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(AppState.instance.currentUser?.name ?? 'Tutor',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800)),
                              Text(
                                  AppState.instance.currentUser?.specialty.isNotEmpty == true
                                      ? '${AppState.instance.currentUser!.specialty} · Tutor'
                                      : 'Tutor',
                                  style: const TextStyle(color: Colors.white70, fontSize: 13)),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.location_on_outlined,
                                      size: 12, color: Colors.white70),
                                  const SizedBox(width: 3),
                                  Text(
                                      AppState.instance.currentUser?.location.isNotEmpty == true
                                          ? AppState.instance.currentUser!.location
                                          : 'Kigali, Rwanda',
                                      style: const TextStyle(color: Colors.white70, fontSize: 12)),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: _menuGroup(
              'Account',
              [
                ('Edit Profile', Icons.person_outline_rounded, const Color(0xFF059669),
                    _editProfile),
                ('My Services & Pricing', Icons.work_outline_rounded, AppTheme.primaryBlue,
                    _myServices),
                ('Availability Calendar', Icons.calendar_month_outlined, const Color(0xFF7C3AED),
                    _availabilityCalendar),
              ],
            ),
          ),

          SliverToBoxAdapter(
            child: _menuGroup(
              'Earnings',
              [
                ('Payout Methods', Icons.account_balance_outlined, const Color(0xFF059669),
                    _payoutMethods),
                ('Earnings History', Icons.bar_chart_rounded, AppTheme.primaryBlue,
                    _earningsHistory),
                ('Tax Documents', Icons.description_outlined, AppTheme.textMuted,
                    _taxDocuments),
              ],
            ),
          ),

          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Available for Hire',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: AppTheme.textDark)),
                        Text('Students can see and book you when ON',
                            style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                      ],
                    ),
                  ),
                  Switch(
                    value: _availableForHire,
                    onChanged: (v) => setState(() => _availableForHire = v),
                    activeThumbColor: const Color(0xFF059669),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: GestureDetector(
                onTap: () => Navigator.pushNamedAndRemoveUntil(
                    context, '/login', (_) => false),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.red.shade100, width: 1.5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout_rounded, size: 18, color: Colors.red.shade500),
                      const SizedBox(width: 8),
                      Text('Sign Out',
                          style: TextStyle(
                              color: Colors.red.shade500,
                              fontSize: 15,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 28)),
        ],
      ),
    );
  }

  Widget _menuGroup(String title, List<(String, IconData, Color, VoidCallback)> items) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
            child: Text(title,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade400,
                    letterSpacing: 0.6)),
          ),
          ...items.asMap().entries.map((e) => Column(
                children: [
                  InkWell(
                    onTap: e.value.$4,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                      child: Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: e.value.$3.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(e.value.$2, size: 20, color: e.value.$3),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(e.value.$1,
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppTheme.textDark)),
                          ),
                          Icon(Icons.chevron_right_rounded,
                              size: 20, color: Colors.grey.shade300),
                        ],
                      ),
                    ),
                  ),
                  if (e.key < items.length - 1)
                    Divider(
                        height: 1,
                        indent: 66,
                        endIndent: 16,
                        color: Colors.grey.shade100),
                ],
              )),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

class _SheetWrap extends StatelessWidget {
  final String title;
  final Widget child;

  const _SheetWrap({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 16),
          Text(title,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textDark)),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
