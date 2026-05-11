import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/app_state.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _index = 0;

  final List<Widget> _screens = const [
    _AdminDashboard(),
    _AdminUsers(),
    _AdminReports(),
    _AdminSettings(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_index],
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
                _navItem(0, Icons.dashboard_outlined,
                    Icons.dashboard_rounded, 'Overview'),
                _navItem(1, Icons.people_outline_rounded,
                    Icons.people_rounded, 'Users',
                    badge: 5),
                _navItem(
                    2, Icons.bar_chart_outlined, Icons.bar_chart_rounded, 'Reports'),
                _navItem(3, Icons.settings_outlined,
                    Icons.settings_rounded, 'Settings'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(int i, IconData icon, IconData active, String label,
      {int badge = 0}) {
    final isActive = _index == i;
    const color = Color(0xFF7C3AED);
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
                        fontWeight:
                            isActive ? FontWeight.w700 : FontWeight.w400,
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

class _AdminDashboard extends StatefulWidget {
  const _AdminDashboard();

  @override
  State<_AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<_AdminDashboard> {

  static const _color = Color(0xFF7C3AED);

  @override
  Widget build(BuildContext context) {
    final pendingTutors = AppState.instance.pendingTutors;
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF7C3AED), Color(0xFF5B21B6)],
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
                            Text('Admin Console',
                                style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontSize: 13)),
                            const Text('Welcome, Admin 🛡️',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800)),
                            const SizedBox(height: 4),
                            Text(
                                'HireWise Platform  •  Kigali, Rwanda',
                                style: TextStyle(
                                    color:
                                        Colors.white.withValues(alpha: 0.75),
                                    fontSize: 12)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                            Icons.admin_panel_settings_rounded,
                            color: Colors.white,
                            size: 22),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                children: [
                  Row(
                    children: [
                      _statCard('1,248', 'Total Students',
                          Icons.school_rounded, const Color(0xFF3B82F6)),
                      const SizedBox(width: 10),
                      _statCard('186', 'Active Tutors',
                          Icons.workspace_premium_rounded,
                          const Color(0xFF059669)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _statCard('94', 'Bookings Today',
                          Icons.calendar_today_rounded,
                          const Color(0xFFD97706)),
                      const SizedBox(width: 10),
                      _statCard('RWF 8.4M', 'Revenue / Month',
                          Icons.trending_up_rounded, _color),
                    ],
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
              child: _sectionLabel('Pending Tutor Applications',
                  pendingTutors.isEmpty ? null : pendingTutors.length)),
          if (pendingTutors.isEmpty)
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF059669).withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle_outline_rounded,
                        color: Color(0xFF059669), size: 20),
                    SizedBox(width: 10),
                    Text('All tutor applications reviewed!',
                        style: TextStyle(
                            color: Color(0xFF059669),
                            fontWeight: FontWeight.w600,
                            fontSize: 13)),
                  ],
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => _tutorApplicationTile(context, pendingTutors[i]),
                childCount: pendingTutors.length,
              ),
            ),

          SliverToBoxAdapter(
              child: _sectionLabel('Recent Sign-ups', null)),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, i) => _signupTile(_recentUsers[i]),
              childCount: _recentUsers.length,
            ),
          ),

          SliverToBoxAdapter(
              child: _sectionLabel('Quick Actions', null)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: Row(
                children: [
                  _quickAction(context, Icons.person_add_outlined,
                      'Add Tutor', const Color(0xFF059669),
                      () => _showAddTutor(context)),
                  const SizedBox(width: 10),
                  _quickAction(context, Icons.block_outlined,
                      'Suspend User', const Color(0xFFEF4444),
                      () => _showSuspendUser(context)),
                  const SizedBox(width: 10),
                  _quickAction(context, Icons.download_outlined,
                      'Export CSV', const Color(0xFF3B82F6),
                      () => _showExportDialog(context)),
                  const SizedBox(width: 10),
                  _quickAction(context, Icons.notifications_outlined,
                      'Broadcast', _color,
                      () => _showBroadcast(context)),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 28)),
        ],
      ),
    );
  }


  static const _recentUsers = [
    ('Jean Pierre Habimana', 'Student', 'Apr 17, 2025'),
    ('Ange Claudine Uwase', 'Student', 'Apr 17, 2025'),
    ('David Nsanzimfura', 'Tutor', 'Apr 16, 2025'),
    ('Sarah Mutesi', 'Student', 'Apr 16, 2025'),
    ('Bruno Nkurunziza', 'Student', 'Apr 15, 2025'),
  ];

  Widget _statCard(
      String value, String label, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value,
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: color)),
                  Text(label,
                      style: const TextStyle(
                          fontSize: 11, color: AppTheme.textMuted),
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String title, int? badge) {
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('$badge',
                  style: const TextStyle(
                      color: Color(0xFFEF4444),
                      fontSize: 11,
                      fontWeight: FontWeight.w700)),
            ),
          ]
        ],
      ),
    );
  }

  Widget _tutorApplicationTile(BuildContext context, AppUser tutor) {
    return GestureDetector(
      onTap: () => _showApplicationDetail(context, tutor),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 6,
                offset: const Offset(0, 2))
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF7C3AED).withValues(alpha: 0.1),
              ),
              child: Center(
                child: Text(tutor.initial,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        color: Color(0xFF7C3AED))),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tutor.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: AppTheme.textDark)),
                  Text(
                      '${tutor.specialty.isNotEmpty ? tutor.specialty : 'Tutor'}  •  ${tutor.email}',
                      style: const TextStyle(
                          fontSize: 11, color: AppTheme.textMuted),
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            Row(
              children: [
                _approvalBtn('Reject', const Color(0xFFEF4444), () {
                  AppState.instance.rejectTutor(tutor.email);
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('${tutor.name} application rejected'),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: const Color(0xFFEF4444),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    margin: const EdgeInsets.all(16),
                  ));
                }),
                const SizedBox(width: 6),
                _approvalBtn('Approve', const Color(0xFF059669), () {
                  AppState.instance.approveTutor(tutor.email);
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('${tutor.name} approved as tutor!'),
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
      ),
    );
  }

  Widget _approvalBtn(String label, Color color, VoidCallback onTap) {
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
            style: TextStyle(
                color: color, fontSize: 11, fontWeight: FontWeight.w700)),
      ),
    );
  }

  void _showApplicationDetail(BuildContext context, AppUser tutor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (ctx, scroll) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2)),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                child: Row(
                  children: [
                    const Text('Tutor Application',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textDark)),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            shape: BoxShape.circle),
                        child: const Icon(Icons.close_rounded,
                            size: 16, color: AppTheme.textDark),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  controller: scroll,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF7C3AED)
                                  .withValues(alpha: 0.12),
                            ),
                            child: Center(
                              child: Text(tutor.initial,
                                  style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF7C3AED))),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(tutor.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 16,
                                        color: AppTheme.textDark)),
                                Text(tutor.email,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.textMuted)),
                                if (tutor.phone.isNotEmpty)
                                  Text(tutor.phone,
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.textMuted)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _appDetailRow('Specialty', tutor.specialty),
                      _appDetailRow('Qualifications', tutor.qualifications),
                      _appDetailRow('Experience', tutor.experience),
                      const SizedBox(height: 8),
                      const Text('Application Statement',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textMuted,
                              letterSpacing: 0.4)),
                      const SizedBox(height: 6),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4F6FB),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          tutor.applicationStatement.isNotEmpty
                              ? tutor.applicationStatement
                              : 'No statement provided.',
                          style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.textDark,
                              height: 1.5),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                AppState.instance.rejectTutor(tutor.email);
                                setState(() {});
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content: Text(
                                      '${tutor.name} rejected'),
                                  backgroundColor: const Color(0xFFEF4444),
                                  behavior: SnackBarBehavior.floating,
                                ));
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFFEF4444),
                                side: const BorderSide(
                                    color: Color(0xFFEF4444)),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text('Reject',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                AppState.instance.approveTutor(tutor.email);
                                setState(() {});
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content: Text(
                                      '${tutor.name} approved!'),
                                  backgroundColor: const Color(0xFF059669),
                                  behavior: SnackBarBehavior.floating,
                                ));
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF059669),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text('Approve Tutor',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _appDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textMuted)),
          ),
          Expanded(
            child: Text(
                value.isNotEmpty ? value : '—',
                style: const TextStyle(
                    fontSize: 13, color: AppTheme.textDark)),
          ),
        ],
      ),
    );
  }

  Widget _signupTile((String, String, String) u) {
    final isTutor = u.$2 == 'Tutor';
    final color =
        isTutor ? const Color(0xFF059669) : AppTheme.primaryBlue;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.1),
            ),
            child: Center(
              child: Text(u.$1[0],
                  style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: color)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(u.$1,
                style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppTheme.textDark)),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(u.$2,
                style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 8),
          Text(u.$3,
              style: const TextStyle(
                  fontSize: 11, color: AppTheme.textMuted)),
        ],
      ),
    );
  }

  Widget _quickAction(BuildContext context, IconData icon, String label,
      Color color, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2))
            ],
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 5),
              Text(label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textMuted)),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminUsers extends StatefulWidget {
  const _AdminUsers();

  @override
  State<_AdminUsers> createState() => _AdminUsersState();
}

class _AdminUsersState extends State<_AdminUsers>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  static const _students = [
    ('Jean Pierre Habimana', 'Kigali', '3 bookings', 'Active'),
    ('Ange Claudine Uwase', 'Musanze', '1 booking', 'Active'),
    ('Sarah Mutesi', 'Huye', '5 bookings', 'Active'),
    ('Bruno Nkurunziza', 'Kigali', '0 bookings', 'Inactive'),
    ('Alice Nyiraneza', 'Rubavu', '2 bookings', 'Active'),
    ('Thierry Hakizimana', 'Kigali', '7 bookings', 'Active'),
  ];

  static const _tutors = [
    ('Dr. Amina Uwase', 'Full-Stack Dev', '142 students', 'Verified'),
    ('Marcus Williams', 'Mobile Dev', '98 students', 'Verified'),
    ('Sophia Vance', 'UI/UX Design', '76 students', 'Verified'),
    ('Emmanuel Nzeyimana', 'Mathematics', '0 students', 'Pending'),
    ('Sylvie Mukamana', 'English Lit', '0 students', 'Pending'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('User Management',
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textDark)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF7C3AED)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text('1,434 total',
                            style: TextStyle(
                                color: Color(0xFF7C3AED),
                                fontSize: 12,
                                fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TabBar(
                    controller: _tab,
                    labelColor: const Color(0xFF7C3AED),
                    unselectedLabelColor: AppTheme.textMuted,
                    indicatorColor: const Color(0xFF7C3AED),
                    labelStyle: const TextStyle(fontWeight: FontWeight.w700),
                    tabs: const [
                      Tab(text: 'Students (1248)'),
                      Tab(text: 'Tutors (186)'),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tab,
                children: [
                  _userList(_students, isStudent: true),
                  _userList(_tutors, isStudent: false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _userList(List<(String, String, String, String)> items,
      {required bool isStudent}) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final u = items[i];
        final isActive = u.$4 == 'Active' || u.$4 == 'Verified';
        final statusColor = u.$4 == 'Pending'
            ? const Color(0xFFD97706)
            : isActive
                ? const Color(0xFF059669)
                : AppTheme.textMuted;
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2))
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (isStudent
                          ? AppTheme.primaryBlue
                          : const Color(0xFF059669))
                      .withValues(alpha: 0.1),
                ),
                child: Center(
                  child: Text(u.$1[0],
                      style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: isStudent
                              ? AppTheme.primaryBlue
                              : const Color(0xFF059669))),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(u.$1,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: AppTheme.textDark)),
                    Text('${u.$2}  •  ${u.$3}',
                        style: const TextStyle(
                            fontSize: 11, color: AppTheme.textMuted)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Text(u.$4,
                        style: TextStyle(
                            color: statusColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: () {},
                    child: const Icon(Icons.more_horiz_rounded,
                        color: AppTheme.textMuted, size: 18),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AdminReports extends StatelessWidget {
  const _AdminReports();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Reports & Analytics',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textDark)),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7C3AED)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('April 2025',
                          style: TextStyle(
                              color: Color(0xFF7C3AED),
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _reportCard('Revenue', [
                      ('Week 1', 'RWF 1.8M', 0.43),
                      ('Week 2', 'RWF 2.1M', 0.50),
                      ('Week 3', 'RWF 2.4M', 0.57),
                      ('Week 4', 'RWF 2.1M', 0.50),
                    ], const Color(0xFF7C3AED)),
                    const SizedBox(height: 14),
                    _reportCard('New Signups', [
                      ('Students', '312', 0.75),
                      ('Tutors', '28', 0.20),
                    ], AppTheme.primaryBlue),
                    const SizedBox(height: 14),
                    _reportCard('Bookings by Category', [
                      ('Tech & Dev', '148', 0.80),
                      ('Design', '89', 0.48),
                      ('Finance', '62', 0.33),
                      ('Legal', '44', 0.24),
                    ], const Color(0xFF059669)),
                    const SizedBox(height: 14),
                    _paymentReport(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _reportCard(String title,
      List<(String, String, double)> rows, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: AppTheme.textDark)),
          const SizedBox(height: 14),
          ...rows.map((r) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                            child: Text(r.$1,
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textMuted))),
                        Text(r.$2,
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textDark)),
                      ],
                    ),
                    const SizedBox(height: 5),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: r.$3,
                        backgroundColor:
                            color.withValues(alpha: 0.1),
                        valueColor:
                            AlwaysStoppedAnimation<Color>(color),
                        minHeight: 7,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _paymentReport() {
    return Container(
      padding: const EdgeInsets.all(16),
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
          const Text('Payment Methods',
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: AppTheme.textDark)),
          const SizedBox(height: 14),
          _payRow('MTN Mobile Money', '64%', const Color(0xFFFFCB05), 0.64),
          const SizedBox(height: 10),
          _payRow('Airtel Money', '22%', const Color(0xFFED1C24), 0.22),
          const SizedBox(height: 10),
          _payRow('Bank Transfer', '14%', AppTheme.primaryBlue, 0.14),
        ],
      ),
    );
  }

  Widget _payRow(String label, String pct, Color color, double value) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration:
                  BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Expanded(
                child: Text(label,
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.textMuted))),
            Text(pct,
                style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: AppTheme.textDark)),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value,
            backgroundColor: color.withValues(alpha: 0.12),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 7,
          ),
        ),
      ],
    );
  }
}

class _AdminSettings extends StatefulWidget {
  const _AdminSettings();

  @override
  State<_AdminSettings> createState() => _AdminSettingsState();
}

class _AdminSettingsState extends State<_AdminSettings> {
  bool _maintenanceMode = false;
  bool _newRegistrations = true;
  bool _emailNotifications = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Row(
                  children: [
                    const Text('Platform Settings',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textDark)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF059669)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.circle,
                              size: 8, color: Color(0xFF059669)),
                          SizedBox(width: 4),
                          Text('Live',
                              style: TextStyle(
                                  color: Color(0xFF059669),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: _settingsGroup([
                _SettingsToggle(
                  icon: Icons.build_outlined,
                  color: const Color(0xFFD97706),
                  title: 'Maintenance Mode',
                  subtitle: 'Take the platform temporarily offline',
                  value: _maintenanceMode,
                  onChanged: (v) =>
                      setState(() => _maintenanceMode = v),
                ),
                _SettingsToggle(
                  icon: Icons.person_add_outlined,
                  color: const Color(0xFF059669),
                  title: 'New Registrations',
                  subtitle: 'Allow new students and tutors to sign up',
                  value: _newRegistrations,
                  onChanged: (v) =>
                      setState(() => _newRegistrations = v),
                ),
                _SettingsToggle(
                  icon: Icons.email_outlined,
                  color: AppTheme.primaryBlue,
                  title: 'Email Notifications',
                  subtitle: 'Send automated emails to users',
                  value: _emailNotifications,
                  onChanged: (v) =>
                      setState(() => _emailNotifications = v),
                ),
              ]),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Column(
                  children: [
                    _actionTile(context, 'Manage Payment Methods',
                        Icons.payment_outlined, const Color(0xFF7C3AED),
                        () => _showManagePayments(context)),
                    const SizedBox(height: 10),
                    _actionTile(context, 'Content Moderation Rules',
                        Icons.rule_outlined, AppTheme.primaryBlue,
                        () => _showModerationRules(context)),
                    const SizedBox(height: 10),
                    _actionTile(context, 'Platform Fee Settings',
                        Icons.percent_outlined, const Color(0xFF059669),
                        () => _showFeeSettings(context)),
                    const SizedBox(height: 10),
                    _actionTile(context, 'Audit Log',
                        Icons.history_rounded, AppTheme.textMuted,
                        () => _showAuditLog(context)),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: GestureDetector(
                  onTap: () => Navigator.pushNamedAndRemoveUntil(
                      context, '/login', (_) => false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: Colors.red.shade100, width: 1.5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout_rounded,
                            size: 18, color: Colors.red.shade500),
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
      ),
    );
  }

  Widget _settingsGroup(List<_SettingsToggle> items) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
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
        children: items
            .asMap()
            .entries
            .map((e) => Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 13),
                      child: Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: e.value.color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(e.value.icon,
                                size: 20, color: e.value.color),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(e.value.title,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                        color: AppTheme.textDark)),
                                Text(e.value.subtitle,
                                    style: const TextStyle(
                                        fontSize: 11,
                                        color: AppTheme.textMuted)),
                              ],
                            ),
                          ),
                          Switch(
                            value: e.value.value,
                            onChanged: e.value.onChanged,
                            activeThumbColor: e.value.color,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                        ],
                      ),
                    ),
                    if (e.key < items.length - 1)
                      Divider(
                          height: 1,
                          indent: 66,
                          endIndent: 16,
                          color: Colors.grey.shade100),
                  ],
                ))
            .toList(),
      ),
    );
  }

  Widget _actionTile(BuildContext context, String title, IconData icon,
      Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 6,
                offset: const Offset(0, 2))
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
                child: Text(title,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textDark))),
            Icon(Icons.chevron_right_rounded,
                size: 20, color: Colors.grey.shade300),
          ],
        ),
      ),
    );
  }
}


void _adminSheet(BuildContext context,
    {required String title, required Widget child}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (ctx, scroll) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF4F6FB),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textDark)),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          shape: BoxShape.circle),
                      child: const Icon(Icons.close_rounded,
                          size: 16, color: AppTheme.textDark),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                controller: scroll,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                child: child,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

void _adminSnack(BuildContext context, String msg, {Color? color}) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(msg),
    behavior: SnackBarBehavior.floating,
    backgroundColor: color,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    margin: const EdgeInsets.all(16),
    duration: const Duration(seconds: 2),
  ));
}

void _showAddTutor(BuildContext context) {
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final subjectCtrl = TextEditingController();
  String selectedLevel = 'University';

  _adminSheet(
    context,
    title: 'Add New Tutor',
    child: StatefulBuilder(builder: (ctx, setSt) {
      return Column(
        children: [
          _adminField('Full Name', nameCtrl, Icons.person_outline_rounded,
              hint: 'e.g. Dr. Emmanuel Nzeyimana'),
          const SizedBox(height: 12),
          _adminField('Email Address', emailCtrl, Icons.email_outlined,
              hint: 'tutor@example.com',
              keyboard: TextInputType.emailAddress),
          const SizedBox(height: 12),
          _adminField('Phone (MTN/Airtel)', phoneCtrl, Icons.phone_outlined,
              hint: '+250 78 000 0000', keyboard: TextInputType.phone),
          const SizedBox(height: 12),
          _adminField('Subject / Specialty', subjectCtrl,
              Icons.school_outlined,
              hint: 'e.g. Mathematics, Flutter Dev'),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerLeft,
            child: Text('Teaching Level',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700)),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: ['Primary', 'Secondary', 'University', 'Professional']
                .map((l) => ChoiceChip(
                      label: Text(l),
                      selected: selectedLevel == l,
                      onSelected: (_) => setSt(() => selectedLevel = l),
                      selectedColor:
                          const Color(0xFF059669).withValues(alpha: 0.15),
                      labelStyle: TextStyle(
                          color: selectedLevel == l
                              ? const Color(0xFF059669)
                              : AppTheme.textMuted,
                          fontWeight: FontWeight.w600,
                          fontSize: 12),
                    ))
                .toList(),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                _adminSnack(context,
                    'Tutor "${nameCtrl.text.isEmpty ? 'New Tutor' : nameCtrl.text}" added successfully',
                    color: const Color(0xFF059669));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF059669),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Add Tutor',
                  style: TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 15)),
            ),
          ),
        ],
      );
    }),
  );
}

void _showSuspendUser(BuildContext context) {
  const users = [
    'Jean Pierre Habimana (Student)',
    'Ange Claudine Uwase (Student)',
    'Sarah Mutesi (Student)',
    'Bruno Nkurunziza (Student)',
    'Marcus Williams (Tutor)',
    'Sophia Vance (Tutor)',
    'Alice Nyiraneza (Student)',
    'Thierry Hakizimana (Student)',
  ];
  String? selected;
  String reason = 'Violation of Terms';
  final reasonCtrl = TextEditingController(text: 'Violation of Terms');

  _adminSheet(
    context,
    title: 'Suspend User',
    child: StatefulBuilder(builder: (ctx, setSt) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444).withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.warning_amber_rounded,
                    color: Color(0xFFEF4444), size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                      'Suspended users cannot log in until reinstated.',
                      style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFFEF4444),
                          height: 1.4)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('Select User',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selected,
                hint: const Text('Choose a user…',
                    style:
                        TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                isExpanded: true,
                items: users
                    .map((u) => DropdownMenuItem(
                        value: u,
                        child: Text(u,
                            style: const TextStyle(fontSize: 13))))
                    .toList(),
                onChanged: (v) => setSt(() => selected = v),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text('Reason',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              'Violation of Terms',
              'Spam / Abuse',
              'Fraudulent Activity',
              'Other',
            ]
                .map((r) => ChoiceChip(
                      label: Text(r),
                      selected: reason == r,
                      onSelected: (_) {
                        setSt(() {
                          reason = r;
                          reasonCtrl.text = r;
                        });
                      },
                      selectedColor:
                          const Color(0xFFEF4444).withValues(alpha: 0.12),
                      labelStyle: TextStyle(
                          color: reason == r
                              ? const Color(0xFFEF4444)
                              : AppTheme.textMuted,
                          fontWeight: FontWeight.w600,
                          fontSize: 11),
                    ))
                .toList(),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: reasonCtrl,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'Additional notes…',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                      color: Color(0xFFEF4444), width: 2)),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: selected == null
                  ? null
                  : () {
                      Navigator.pop(ctx);
                      _adminSnack(context,
                          '$selected has been suspended.',
                          color: const Color(0xFFEF4444));
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade200,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Suspend User',
                  style: TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 15)),
            ),
          ),
        ],
      );
    }),
  );
}

void _showExportDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => _ExportDialog(),
  );
}

void _showBroadcast(BuildContext context) {
  final titleCtrl = TextEditingController();
  final msgCtrl = TextEditingController();
  String audience = 'All Users';

  _adminSheet(
    context,
    title: 'Send Broadcast',
    child: StatefulBuilder(builder: (ctx, setSt) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _adminField('Notification Title', titleCtrl, Icons.title_rounded,
              hint: 'e.g. Platform Maintenance'),
          const SizedBox(height: 12),
          _adminField('Message', msgCtrl, Icons.message_outlined,
              hint: 'Write your message here…', maxLines: 4),
          const SizedBox(height: 14),
          Text('Send To',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700)),
          const SizedBox(height: 8),
          ...['All Users', 'Students Only', 'Tutors Only'].map((a) =>
              InkWell(
                onTap: () => setSt(() => audience = a),
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  child: Row(
                    children: [
                      Icon(
                        audience == a
                            ? Icons.radio_button_checked_rounded
                            : Icons.radio_button_unchecked_rounded,
                        color: audience == a
                            ? const Color(0xFF7C3AED)
                            : Colors.grey.shade400,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Text(a,
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w500,
                              color: AppTheme.textDark)),
                    ],
                  ),
                ),
              )),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF7C3AED).withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.people_outline_rounded,
                    color: Color(0xFF7C3AED), size: 16),
                const SizedBox(width: 8),
                Text(
                  audience == 'All Users'
                      ? 'This will reach ~1,434 users'
                      : audience == 'Students Only'
                          ? 'This will reach ~1,248 students'
                          : 'This will reach ~186 tutors',
                  style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF7C3AED),
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                _adminSnack(context,
                    'Broadcast sent to $audience successfully!',
                    color: const Color(0xFF7C3AED));
              },
              icon: const Icon(Icons.send_rounded, size: 18),
              label: const Text('Send Broadcast',
                  style: TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 15)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      );
    }),
  );
}

void _showManagePayments(BuildContext context) {
  bool mtnEnabled = true;
  bool airtelEnabled = true;
  bool bankEnabled = true;
  final mtnFeeCtrl = TextEditingController(text: '1.5');
  final airtelFeeCtrl = TextEditingController(text: '1.5');
  final bankFeeCtrl = TextEditingController(text: '0.5');

  _adminSheet(
    context,
    title: 'Manage Payment Methods',
    child: StatefulBuilder(builder: (ctx, setSt) {
      return Column(
        children: [
          _payMethodRow(
            ctx,
            logoIcon: Icons.phone_android_rounded,
            logoColor: const Color(0xFFFFCB05),
            name: 'MTN Mobile Money',
            fee: mtnFeeCtrl,
            color: const Color(0xFFFFCB05),
            enabled: mtnEnabled,
            onToggle: (v) => setSt(() => mtnEnabled = v),
          ),
          const SizedBox(height: 12),
          _payMethodRow(
            ctx,
            logoIcon: Icons.phone_android_rounded,
            logoColor: const Color(0xFFED1C24),
            name: 'Airtel Money',
            fee: airtelFeeCtrl,
            color: const Color(0xFFED1C24),
            enabled: airtelEnabled,
            onToggle: (v) => setSt(() => airtelEnabled = v),
          ),
          const SizedBox(height: 12),
          _payMethodRow(
            ctx,
            logoIcon: Icons.account_balance_rounded,
            logoColor: AppTheme.primaryBlue,
            name: 'Bank Transfer',
            fee: bankFeeCtrl,
            color: AppTheme.primaryBlue,
            enabled: bankEnabled,
            onToggle: (v) => setSt(() => bankEnabled = v),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                _adminSnack(context, 'Payment method settings saved');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Save Changes',
                  style: TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 15)),
            ),
          ),
        ],
      );
    }),
  );
}

Widget _payMethodRow(
  BuildContext context, {
  required IconData logoIcon,
  required Color logoColor,
  required String name,
  required TextEditingController fee,
  required Color color,
  required bool enabled,
  required ValueChanged<bool> onToggle,
}) {
  return Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(
          color: enabled ? color.withValues(alpha: 0.4) : Colors.grey.shade100,
          width: enabled ? 1.5 : 1),
    ),
    child: Column(
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: logoColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(logoIcon, color: logoColor, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(name,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: AppTheme.textDark)),
            ),
            Switch(
              value: enabled,
              onChanged: onToggle,
              activeThumbColor: color,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],
        ),
        if (enabled) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              const Text('Transaction Fee (%)',
                  style:
                      TextStyle(fontSize: 12, color: AppTheme.textMuted)),
              const Spacer(),
              SizedBox(
                width: 70,
                child: TextField(
                  controller: fee,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700),
                  decoration: InputDecoration(
                    suffixText: '%',
                    isDense: true,
                    filled: true,
                    fillColor: color.withValues(alpha: 0.07),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    ),
  );
}

void _showModerationRules(BuildContext context) {
  bool offensiveLanguage = true;
  bool spamDetection = true;
  bool requireIdVerification = true;
  bool autoSuspendReports = false;
  bool reviewBeforePublish = false;
  final reportsCtrl = TextEditingController(text: '3');

  _adminSheet(
    context,
    title: 'Content Moderation Rules',
    child: StatefulBuilder(builder: (ctx, setSt) {
      return Column(
        children: [
          _modToggle(
            ctx,
            icon: Icons.block_outlined,
            color: const Color(0xFFEF4444),
            title: 'Filter Offensive Language',
            subtitle: 'Auto-flag messages with prohibited words',
            value: offensiveLanguage,
            onChanged: (v) => setSt(() => offensiveLanguage = v),
          ),
          const SizedBox(height: 10),
          _modToggle(
            ctx,
            icon: Icons.report_outlined,
            color: const Color(0xFFD97706),
            title: 'Spam Detection',
            subtitle: 'Detect and block repetitive or spam messages',
            value: spamDetection,
            onChanged: (v) => setSt(() => spamDetection = v),
          ),
          const SizedBox(height: 10),
          _modToggle(
            ctx,
            icon: Icons.verified_user_outlined,
            color: AppTheme.primaryBlue,
            title: 'Require ID Verification',
            subtitle: 'Tutors must be verified before going live',
            value: requireIdVerification,
            onChanged: (v) => setSt(() => requireIdVerification = v),
          ),
          const SizedBox(height: 10),
          _modToggle(
            ctx,
            icon: Icons.pause_circle_outline_rounded,
            color: const Color(0xFF7C3AED),
            title: 'Review Before Publish',
            subtitle: 'Admin reviews all new tutor profiles before approval',
            value: reviewBeforePublish,
            onChanged: (v) => setSt(() => reviewBeforePublish = v),
          ),
          const SizedBox(height: 10),
          _modToggle(
            ctx,
            icon: Icons.gavel_rounded,
            color: const Color(0xFFEF4444),
            title: 'Auto-Suspend on Reports',
            subtitle: 'Automatically suspend accounts when reported multiple times',
            value: autoSuspendReports,
            onChanged: (v) => setSt(() => autoSuspendReports = v),
          ),
          if (autoSuspendReports) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Reports threshold',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: AppTheme.textDark)),
                        Text('Number of reports before auto-suspend',
                            style: TextStyle(
                                fontSize: 11, color: AppTheme.textMuted)),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 60,
                    child: TextField(
                      controller: reportsCtrl,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w700),
                      decoration: InputDecoration(
                        isDense: true,
                        filled: true,
                        fillColor: const Color(0xFFEF4444)
                            .withValues(alpha: 0.07),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                _adminSnack(context, 'Moderation rules updated');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Save Rules',
                  style: TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 15)),
            ),
          ),
        ],
      );
    }),
  );
}

Widget _modToggle(
  BuildContext context, {
  required IconData icon,
  required Color color,
  required String title,
  required String subtitle,
  required bool value,
  required ValueChanged<bool> onChanged,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Colors.grey.shade100),
    ),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: AppTheme.textDark)),
              Text(subtitle,
                  style: const TextStyle(
                      fontSize: 11, color: AppTheme.textMuted, height: 1.3)),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: color,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ],
    ),
  );
}

void _showFeeSettings(BuildContext context) {
  final platformFeeCtrl = TextEditingController(text: '10');
  final payoutFeeCtrl = TextEditingController(text: '2');
  final bookingFeeCtrl = TextEditingController(text: '500');
  bool vatEnabled = true;

  _adminSheet(
    context,
    title: 'Platform Fee Settings',
    child: StatefulBuilder(builder: (ctx, setSt) {
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF059669).withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: const Color(0xFF059669).withValues(alpha: 0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline_rounded,
                    color: Color(0xFF059669), size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                      'Changes apply to new bookings only. Existing bookings are unaffected.',
                      style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF059669),
                          height: 1.4)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _feeField(
            'Platform Commission',
            'Percentage taken from each tutor payout',
            platformFeeCtrl,
            '%',
            const Color(0xFF059669),
          ),
          const SizedBox(height: 12),
          _feeField(
            'Payout Processing Fee',
            'Fee charged per payout to tutors',
            payoutFeeCtrl,
            '%',
            AppTheme.primaryBlue,
          ),
          const SizedBox(height: 12),
          _feeField(
            'Booking Service Fee',
            'Fixed fee added to every student booking',
            bookingFeeCtrl,
            'RWF',
            const Color(0xFF7C3AED),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD97706).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.receipt_outlined,
                      color: Color(0xFFD97706), size: 18),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Apply VAT (18%)',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: AppTheme.textDark)),
                      Text('Rwanda Revenue Authority standard rate',
                          style: TextStyle(
                              fontSize: 11, color: AppTheme.textMuted)),
                    ],
                  ),
                ),
                Switch(
                  value: vatEnabled,
                  onChanged: (v) => setSt(() => vatEnabled = v),
                  activeThumbColor: const Color(0xFFD97706),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                _adminSnack(context, 'Fee settings saved successfully',
                    color: const Color(0xFF059669));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF059669),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Save Fee Settings',
                  style: TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 15)),
            ),
          ),
        ],
      );
    }),
  );
}

Widget _feeField(String title, String subtitle,
    TextEditingController ctrl, String unit, Color color) {
  return Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Colors.grey.shade100),
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: AppTheme.textDark)),
              Text(subtitle,
                  style: const TextStyle(
                      fontSize: 11, color: AppTheme.textMuted)),
            ],
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 80,
          child: TextField(
            controller: ctrl,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w700),
            decoration: InputDecoration(
              suffixText: unit,
              suffixStyle:
                  TextStyle(color: color, fontWeight: FontWeight.w600),
              isDense: true,
              filled: true,
              fillColor: color.withValues(alpha: 0.07),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            ),
          ),
        ),
      ],
    ),
  );
}

void _showAuditLog(BuildContext context) {
  const logs = [
    _AuditEntry('Admin', 'Approved tutor Dr. Emmanuel Nzeyimana',
        'Apr 17, 2025 · 10:42 AM', Icons.check_circle_outline_rounded,
        Color(0xFF059669)),
    _AuditEntry('Admin', 'Suspended user Bruno Nkurunziza (spam)',
        'Apr 17, 2025 · 09:15 AM', Icons.block_outlined, Color(0xFFEF4444)),
    _AuditEntry('Admin', 'Updated platform commission to 10%',
        'Apr 16, 2025 · 4:30 PM', Icons.percent_outlined,
        Color(0xFF7C3AED)),
    _AuditEntry('Admin', 'Sent broadcast to all users',
        'Apr 16, 2025 · 2:00 PM', Icons.notifications_outlined,
        AppTheme.primaryBlue),
    _AuditEntry('Admin', 'Rejected tutor application — Kevin Byiringiro',
        'Apr 15, 2025 · 11:20 AM', Icons.cancel_outlined, Color(0xFFEF4444)),
    _AuditEntry('Admin', 'Added new tutor Sylvie Mukamana',
        'Apr 14, 2025 · 3:10 PM', Icons.person_add_outlined,
        Color(0xFF059669)),
    _AuditEntry('Admin', 'Exported user CSV (students)',
        'Apr 13, 2025 · 9:00 AM', Icons.download_outlined,
        Color(0xFF3B82F6)),
    _AuditEntry('Admin', 'Enabled maintenance mode',
        'Apr 10, 2025 · 11:59 PM', Icons.build_outlined,
        Color(0xFFD97706)),
    _AuditEntry('Admin', 'Disabled maintenance mode',
        'Apr 11, 2025 · 12:30 AM', Icons.build_outlined,
        Color(0xFF059669)),
  ];

  _adminSheet(
    context,
    title: 'Audit Log',
    child: Column(
      children: logs
          .map((log) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: log.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Icon(log.icon, color: log.color, size: 16),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(log.action,
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textDark,
                                  height: 1.3)),
                          const SizedBox(height: 3),
                          Text(log.timestamp,
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.textMuted)),
                        ],
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
    ),
  );
}

Widget _adminField(
    String label, TextEditingController ctrl, IconData icon, {
    String? hint,
    int maxLines = 1,
    TextInputType keyboard = TextInputType.text,
  }) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label,
          style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700)),
      const SizedBox(height: 7),
      TextField(
        controller: ctrl,
        maxLines: maxLines,
        keyboardType: keyboard,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle:
              TextStyle(color: Colors.grey.shade400, fontSize: 13),
          prefixIcon: maxLines == 1
              ? Icon(icon, size: 18, color: Colors.grey.shade400)
              : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: AppTheme.primaryBlue, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
    ],
  );
}

class _ExportDialog extends StatefulWidget {
  @override
  State<_ExportDialog> createState() => _ExportDialogState();
}

class _ExportDialogState extends State<_ExportDialog> {
  String _selected = 'Students';
  bool _exporting = false;
  bool _done = false;

  Future<void> _export() async {
    setState(() => _exporting = true);
    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;
    setState(() {
      _exporting = false;
      _done = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: EdgeInsets.zero,
      content: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: _done
                  ? const Icon(Icons.check_circle_rounded,
                      color: Color(0xFF059669), size: 28)
                  : _exporting
                      ? const Padding(
                          padding: EdgeInsets.all(14),
                          child: CircularProgressIndicator(
                              color: Color(0xFF3B82F6), strokeWidth: 2.5),
                        )
                      : const Icon(Icons.download_rounded,
                          color: Color(0xFF3B82F6), size: 28),
            ),
            const SizedBox(height: 14),
            Text(
              _done
                  ? 'Export Ready!'
                  : _exporting
                      ? 'Generating CSV…'
                      : 'Export Data',
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textDark),
            ),
            const SizedBox(height: 6),
            Text(
              _done
                  ? '$_selected CSV downloaded successfully.'
                  : _exporting
                      ? 'Please wait…'
                      : 'Choose which data to export.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 13, color: AppTheme.textMuted),
            ),
            if (!_exporting && !_done) ...[
              const SizedBox(height: 16),
              ...['Students', 'Tutors', 'Bookings', 'Revenue'].map(
                (opt) => InkWell(
                  onTap: () => setState(() => _selected = opt),
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 4, vertical: 8),
                    child: Row(
                      children: [
                        Icon(
                          _selected == opt
                              ? Icons.radio_button_checked_rounded
                              : Icons.radio_button_unchecked_rounded,
                          color: _selected == opt
                              ? const Color(0xFF3B82F6)
                              : Colors.grey.shade400,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Text(opt,
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.textDark)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
            if (_done)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF059669),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                  child: const Text('Done',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              )
            else
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          _exporting ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _exporting ? null : _export,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B82F6),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                      ),
                      child: const Text('Export',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _AuditEntry {
  final String actor;
  final String action;
  final String timestamp;
  final IconData icon;
  final Color color;

  const _AuditEntry(
      this.actor, this.action, this.timestamp, this.icon, this.color);
}

class _SettingsToggle {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsToggle({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });
}
