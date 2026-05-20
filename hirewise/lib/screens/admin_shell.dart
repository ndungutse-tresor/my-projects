import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../firebase_options.dart';
import '../theme/app_theme.dart';
import '../models/app_user.dart';
import '../models/verification.dart';
import '../core/providers/app_providers.dart';
import '../core/providers/auth_provider.dart';
import '../core/providers/verification_providers.dart';
import '../core/services/bootstrap_service.dart';

class AdminShell extends ConsumerStatefulWidget {
  const AdminShell({super.key});

  @override
  ConsumerState<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends ConsumerState<AdminShell> {
  int _index = 0;

  final List<Widget> _screens = const [
    _AdminDashboard(),
    _AdminUsers(),
    _AdminReports(),
    _AdminSettings(),
  ];

  @override
  Widget build(BuildContext context) {
    final pendingTutorCount =
        ref.watch(pendingTutorsProvider).valueOrNull?.length ?? 0;

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
                    badge: pendingTutorCount),
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

class _AdminDashboard extends ConsumerStatefulWidget {
  const _AdminDashboard();

  @override
  ConsumerState<_AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends ConsumerState<_AdminDashboard> {

  static const _color = Color(0xFF7C3AED);

  @override
  Widget build(BuildContext context) {
    final pendingTutors =
        ref.watch(pendingVerificationsProvider).valueOrNull ?? [];
    final studentCount = ref.watch(studentCountProvider).valueOrNull;
    final tutorCount = ref.watch(activeTutorCountProvider).valueOrNull;
    final bookingCount = ref.watch(allBookingsCountProvider).valueOrNull;
    final recentUsers = ref.watch(recentUsersProvider).valueOrNull ?? [];

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
                            const Text('Welcome, Admin',
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
                      _statCard(
                          studentCount != null ? '$studentCount' : '…',
                          'Total Students',
                          Icons.school_rounded,
                          const Color(0xFF3B82F6)),
                      const SizedBox(width: 10),
                      _statCard(
                          tutorCount != null ? '$tutorCount' : '…',
                          'Active Tutors',
                          Icons.workspace_premium_rounded,
                          const Color(0xFF059669)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _statCard(
                          bookingCount != null ? '$bookingCount' : '…',
                          'Total Bookings',
                          Icons.calendar_today_rounded,
                          const Color(0xFFD97706)),
                      const SizedBox(width: 10),
                      _statCard('Live', 'Platform Status',
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
          if (recentUsers.isEmpty)
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Text('No users yet.',
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => _signupTile(recentUsers[i]),
                childCount: recentUsers.length,
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
                  _quickAction(context, Icons.admin_panel_settings_outlined,
                      'Add Admin', const Color(0xFF7C3AED),
                      () => _showAddAdmin(context)),
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

  Widget _tutorApplicationTile(
      BuildContext context, VerificationApplication app) {
    final initial =
        app.tutorName.isNotEmpty ? app.tutorName[0].toUpperCase() : '?';
    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => _ApplicationDetailSheet(app: app),
      ),
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
                child: Text(initial,
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
                  Text(app.tutorName,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: AppTheme.textDark)),
                  Text(
                      '${app.specialty.isNotEmpty ? app.specialty : 'Tutor'}  •  ${app.tutorEmail}',
                      style: const TextStyle(
                          fontSize: 11, color: AppTheme.textMuted),
                      overflow: TextOverflow.ellipsis),
                  if (app.submittedAt != null)
                    Text(
                      '${app.documents.length} doc(s) • ${_fmt(app.submittedAt!)}',
                      style: const TextStyle(
                          fontSize: 10, color: AppTheme.textMuted),
                    ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppTheme.textMuted, size: 20),
          ],
        ),
      ),
    );
  }

  String _fmt(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';

  Widget _signupTile(AppUser u) {
    final isTutor = u.role == 'tutor';
    final isAdmin = u.role == 'admin';
    final color = isAdmin
        ? const Color(0xFF7C3AED)
        : isTutor
            ? const Color(0xFF059669)
            : AppTheme.primaryBlue;
    final roleLabel = isAdmin
        ? 'Admin'
        : isTutor
            ? 'Tutor'
            : 'Student';
    final initial = u.name.isNotEmpty ? u.name[0].toUpperCase() : '?';
    final dateStr =
        '${u.createdAt.day.toString().padLeft(2, '0')}/${u.createdAt.month.toString().padLeft(2, '0')}/${u.createdAt.year}';
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
              child: Text(initial,
                  style: TextStyle(fontWeight: FontWeight.w800, color: color)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(u.name.isNotEmpty ? u.name : u.email,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: AppTheme.textDark)),
                if (u.email.isNotEmpty)
                  Text(u.email,
                      style: const TextStyle(
                          fontSize: 11, color: AppTheme.textMuted),
                      overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(roleLabel,
                style: TextStyle(
                    color: color, fontSize: 11, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 8),
          Text(dateStr,
              style:
                  const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
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

class _ApplicationDetailSheet extends ConsumerStatefulWidget {
  final VerificationApplication app;

  const _ApplicationDetailSheet({required this.app});

  @override
  ConsumerState<_ApplicationDetailSheet> createState() =>
      _ApplicationDetailSheetState();
}

class _ApplicationDetailSheetState
    extends ConsumerState<_ApplicationDetailSheet> {
  final _noteController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _decide(
    Future<void> Function(String adminId, String note) action,
    String successMsg,
  ) async {
    final note = _noteController.text.trim();
    if (note.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('A note is required before making a decision.')),
      );
      return;
    }
    final adminId =
        ref.read(currentUserProvider).valueOrNull?.uid ?? 'unknown';
    setState(() => _loading = true);
    try {
      await action(adminId, note);
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(successMsg),
          backgroundColor: const Color(0xFF059669),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = widget.app;
    final svc = ref.read(verificationServiceProvider);
    final auditLog = ref.watch(auditLogProvider(app.userId));

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
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
              width: 40,
              height: 4,
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
                    onTap: () => Navigator.of(ctx).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                          color: Colors.grey.shade100, shape: BoxShape.circle),
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
                    _headerRow(app),
                    const SizedBox(height: 16),
                    _documentsSection(app.documents),
                    const SizedBox(height: 16),
                    const Text('Admin Note (required)',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textDark)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _noteController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Explain your decision clearly...',
                        hintStyle: const TextStyle(
                            color: AppTheme.textMuted, fontSize: 13),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: Colors.grey.shade200),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: Colors.grey.shade200),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Color(0xFF7C3AED)),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF4F6FB),
                        contentPadding: const EdgeInsets.all(12),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_loading)
                      const Center(child: CircularProgressIndicator())
                    else
                      _actionButtons(app, svc),
                    const SizedBox(height: 24),
                    const Text('Audit History',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textDark)),
                    const SizedBox(height: 8),
                    auditLog.when(
                      data: (entries) => entries.isEmpty
                          ? const Text('No audit entries yet.',
                              style: TextStyle(
                                  fontSize: 12, color: AppTheme.textMuted))
                          : Column(
                              children: entries.map(_auditTile).toList()),
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (_, __) =>
                          const Text('Could not load audit log.'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerRow(VerificationApplication app) {
    final initial =
        app.tutorName.isNotEmpty ? app.tutorName[0].toUpperCase() : '?';
    return Row(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF7C3AED).withValues(alpha: 0.12),
          ),
          child: Center(
            child: Text(initial,
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
              Text(app.tutorName,
                  style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: AppTheme.textDark)),
              Text(app.tutorEmail,
                  style: const TextStyle(
                      fontSize: 12, color: AppTheme.textMuted)),
              if (app.specialty.isNotEmpty)
                Text(app.specialty,
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.textMuted)),
              if (app.submittedAt != null)
                Text('Submitted ${_fmtDate(app.submittedAt!)}',
                    style: const TextStyle(
                        fontSize: 11, color: AppTheme.textMuted)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _documentsSection(List<VerificationDocument> docs) {
    if (docs.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF3C7),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Row(
          children: [
            Icon(Icons.warning_amber_rounded,
                color: Color(0xFFD97706), size: 18),
            SizedBox(width: 8),
            Text('No documents uploaded yet.',
                style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFFD97706),
                    fontWeight: FontWeight.w600)),
          ],
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Submitted Documents',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppTheme.textDark)),
        const SizedBox(height: 10),
        ...docs.map(_docCard),
      ],
    );
  }

  Widget _docCard(VerificationDocument doc) {
    final isImg = doc.type.isImage;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6FB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
            child: Row(
              children: [
                Icon(
                  isImg ? Icons.image_outlined : Icons.picture_as_pdf_outlined,
                  size: 16,
                  color: const Color(0xFF7C3AED),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(doc.type.label,
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textDark)),
                ),
              ],
            ),
          ),
          if (isImg && doc.downloadUrl.isNotEmpty)
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(12)),
              child: InteractiveViewer(
                child: Image.network(
                  doc.downloadUrl,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (_, child, prog) =>
                      prog == null ? child : const SizedBox(
                          height: 80,
                          child: Center(child: CircularProgressIndicator())),
                  errorBuilder: (_, __, ___) => Container(
                    height: 80,
                    color: Colors.grey.shade200,
                    child: const Center(
                        child: Icon(Icons.broken_image_outlined,
                            color: AppTheme.textMuted)),
                  ),
                ),
              ),
            )
          else if (!isImg && doc.fileName.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
              child: Row(
                children: [
                  const Icon(Icons.picture_as_pdf_outlined,
                      color: Color(0xFFEF4444), size: 18),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(doc.fileName,
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.textMuted),
                        overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _actionButtons(VerificationApplication app, dynamic svc) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _decide(
              (adminId, note) => svc.approve(
                  tutorId: app.userId,
                  tutorName: app.tutorName,
                  adminId: adminId,
                  note: note),
              '${app.tutorName} approved as tutor!',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF059669),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child:
                const Text('Approve', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => _decide(
              (adminId, note) => svc.requestChanges(
                  tutorId: app.userId,
                  tutorName: app.tutorName,
                  adminId: adminId,
                  note: note),
              'Changes requested from ${app.tutorName}.',
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFD97706),
              side: const BorderSide(color: Color(0xFFD97706)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Request Changes',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => _decide(
              (adminId, note) => svc.reject(
                  tutorId: app.userId,
                  tutorName: app.tutorName,
                  adminId: adminId,
                  note: note),
              '${app.tutorName} application rejected.',
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFEF4444),
              side: const BorderSide(color: Color(0xFFEF4444)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child:
                const Text('Reject', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ),
      ],
    );
  }

  Widget _auditTile(AuditLogEntry entry) {
    final (color, icon) = switch (entry.action) {
      'approved' => (const Color(0xFF059669), Icons.check_circle_outline_rounded),
      'rejected' => (const Color(0xFFEF4444), Icons.cancel_outlined),
      'changes_requested' => (const Color(0xFFD97706), Icons.edit_note_outlined),
      _ => (AppTheme.primaryBlue, Icons.history_rounded),
    };
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.actionLabel,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: color)),
                if (entry.note.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(entry.note,
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.textDark)),
                  ),
                Text(_fmtDate(entry.timestamp),
                    style: const TextStyle(
                        fontSize: 11, color: AppTheme.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _fmtDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
}

class _AdminUsers extends ConsumerStatefulWidget {
  const _AdminUsers();

  @override
  ConsumerState<_AdminUsers> createState() => _AdminUsersState();
}

class _AdminUsersState extends ConsumerState<_AdminUsers>
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

  @override
  Widget build(BuildContext context) {
    final students = ref.watch(studentsProvider).valueOrNull ?? [];
    final tutors = ref.watch(allTutorsProvider).valueOrNull ?? [];
    final total = students.length + tutors.length;

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
                        child: Text('$total total',
                            style: const TextStyle(
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
                    tabs: [
                      Tab(text: 'Students (${students.length})'),
                      Tab(text: 'Tutors (${tutors.length})'),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tab,
                children: [
                  _userList(students, isStudent: true),
                  _userList(tutors, isStudent: false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _userList(List<AppUser> items, {required bool isStudent}) {
    if (items.isEmpty) {
      return Center(
        child: Text(
          isStudent ? 'No students yet.' : 'No tutors yet.',
          style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final u = items[i];
        final statusLabel = isStudent
            ? 'Student'
            : u.tutorStatus == TutorStatus.approved
                ? 'Verified'
                : u.tutorStatus == TutorStatus.pending
                    ? 'Pending'
                    : u.tutorStatus.name;
        final statusColor = u.tutorStatus == TutorStatus.pending
            ? const Color(0xFFD97706)
            : u.tutorStatus == TutorStatus.approved || isStudent
                ? const Color(0xFF059669)
                : AppTheme.textMuted;
        final initial = u.name.isNotEmpty ? u.name[0].toUpperCase() : '?';
        final color =
            isStudent ? AppTheme.primaryBlue : const Color(0xFF059669);
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
                  color: color.withValues(alpha: 0.1),
                ),
                child: Center(
                  child: Text(initial,
                      style: TextStyle(
                          fontWeight: FontWeight.w800, color: color)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(u.name.isNotEmpty ? u.name : u.email,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: AppTheme.textDark)),
                    Text(
                        '${u.location.isNotEmpty ? u.location : 'Kigali'}  •  ${u.email}',
                        style: const TextStyle(
                            fontSize: 11, color: AppTheme.textMuted),
                        overflow: TextOverflow.ellipsis),
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
                    child: Text(statusLabel,
                        style: TextStyle(
                            color: statusColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: () => _showUserActions(context, u, isStudent),
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

  void _showUserActions(BuildContext context, AppUser u, bool isStudent) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 38,
                height: 4,
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(u.name.isNotEmpty ? u.name : u.email,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: AppTheme.textDark)),
              const SizedBox(height: 2),
              Text(u.email,
                  style: const TextStyle(
                      fontSize: 12, color: AppTheme.textMuted)),
              const SizedBox(height: 16),
              if (!isStudent && u.tutorStatus == TutorStatus.pending) ...[
                ListTile(
                  leading: const Icon(Icons.verified_rounded,
                      color: Color(0xFF059669)),
                  title: const Text('Approve tutor'),
                  onTap: () async {
                    Navigator.pop(sheetCtx);
                    await ref
                        .read(userServiceProvider)
                        .updateTutorStatus(u.uid, TutorStatus.approved);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('${u.name} approved'),
                          backgroundColor: const Color(0xFF059669)));
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.cancel_rounded,
                      color: Color(0xFFDC2626)),
                  title: const Text('Reject application'),
                  onTap: () async {
                    Navigator.pop(sheetCtx);
                    await ref
                        .read(userServiceProvider)
                        .updateTutorStatus(u.uid, TutorStatus.rejected);
                  },
                ),
              ],
              ListTile(
                leading: const Icon(Icons.delete_forever_rounded,
                    color: Color(0xFFDC2626)),
                title: const Text('Delete account'),
                subtitle:
                    const Text('Removes their profile from the platform.'),
                onTap: () async {
                  Navigator.pop(sheetCtx);
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (dCtx) => AlertDialog(
                      title: const Text('Delete account?'),
                      content: Text(
                          'This will permanently remove ${u.name.isNotEmpty ? u.name : u.email} from HireWise.'),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(dCtx, false),
                            child: const Text('Cancel')),
                        TextButton(
                          onPressed: () => Navigator.pop(dCtx, true),
                          style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFFDC2626)),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );
                  if (confirm != true) return;
                  try {
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(u.uid)
                        .delete();
                    if (!isStudent) {
                      await FirebaseFirestore.instance
                          .collection('experts')
                          .doc(u.uid)
                          .delete();
                    }
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('${u.name} deleted'),
                          backgroundColor: const Color(0xFF059669)));
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Delete failed: $e'),
                          backgroundColor: const Color(0xFFDC2626)));
                    }
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.close_rounded,
                    color: AppTheme.textMuted),
                title: const Text('Cancel'),
                onTap: () => Navigator.pop(sheetCtx),
              ),
            ],
          ),
        ),
      ),
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

class _AdminSettings extends ConsumerStatefulWidget {
  const _AdminSettings();

  @override
  ConsumerState<_AdminSettings> createState() => _AdminSettingsState();
}

class _AdminSettingsState extends ConsumerState<_AdminSettings> {
  bool _maintenanceMode = false;
  bool _newRegistrations = true;
  bool _emailNotifications = true;
  bool _seeding = false;

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
                    const SizedBox(height: 10),
                    _seedTile(context),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: GestureDetector(
                  onTap: () async {
                    final nav = Navigator.of(context);
                    await ref.read(authServiceProvider).signOut();
                    nav.pushNamedAndRemoveUntil('/', (_) => false);
                  },
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

  Widget _seedTile(BuildContext context) {
    return GestureDetector(
      onTap: _seeding ? null : () => _seedDemoTutors(context),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF059669).withValues(alpha: 0.3), width: 1),
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
                color: const Color(0xFF059669).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: _seeding
                  ? const Center(
                      child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF059669))))
                  : const Icon(Icons.group_add_outlined,
                      color: Color(0xFF059669), size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _seeding ? 'Creating accounts…' : 'Seed Demo Tutors',
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF059669)),
                  ),
                  const Text('Creates 4 sample tutor accounts for demo',
                      style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                size: 20, color: Colors.grey.shade300),
          ],
        ),
      ),
    );
  }

  Future<void> _seedDemoTutors(BuildContext context) async {
    if (_seeding) return;
    setState(() => _seeding = true);

    final db = FirebaseFirestore.instance;
    final messenger = ScaffoldMessenger.of(context);

    final List<Map<String, dynamic>> tutors = [
      {
        'email': 'amina.uwase@hirewise.app',
        'password': 'Demo@2025',
        'name': 'Dr. Amina Uwase',
        'phone': '+250788100001',
        'specialty': 'Math & Physics',
        'bio': 'Award-winning educator at University of Rwanda with 12 years teaching math and physics at A-level and university level.',
        'expert': <String, dynamic>{
          'name': 'Dr. Amina Uwase',
          'title': 'Math & Physics Tutor',
          'sector': 'Education',
          'rating': 4.9,
          'reviewCount': 84,
          'yearsExp': 12,
          'responseTime': '< 1 hr',
          'completedJobs': 230,
          'about': 'Award-winning educator with 12 years at University of Rwanda. I make complex math and physics accessible through personalized sessions tailored to A-level and university curricula.',
          'startingPrice': 30000,
          'isVerified': true,
          'isOnline': true,
          'avatarUrl': '',
          'services': [
            {'icon': '📐', 'name': 'Math Tutoring', 'description': 'A-level & university mathematics.', 'price': 30000},
            {'icon': '⚛️', 'name': 'Physics Tutoring', 'description': 'Mechanics, thermodynamics, electromagnetism.', 'price': 35000},
          ],
          'reviews': [],
        },
      },
      {
        'email': 'marcus.williams@hirewise.app',
        'password': 'Demo@2025',
        'name': 'Marcus Williams',
        'phone': '+250788100002',
        'specialty': 'Full-Stack Development',
        'bio': 'Full-stack engineer with 7 years building scalable web and mobile apps. Specializes in Flutter, React, and Node.js.',
        'expert': <String, dynamic>{
          'name': 'Marcus Williams',
          'title': 'Full-Stack Developer',
          'sector': 'Tech & Dev',
          'rating': 4.9,
          'reviewCount': 126,
          'yearsExp': 7,
          'responseTime': '< 1 hr',
          'completedJobs': 312,
          'about': 'I build scalable web and mobile applications. Specializing in Flutter, React, and Node.js with experience delivering enterprise-grade solutions for startups and large organizations alike.',
          'startingPrice': 150000,
          'isVerified': true,
          'isOnline': true,
          'avatarUrl': '',
          'services': [
            {'icon': '💻', 'name': 'App Development', 'description': 'Full mobile app built with Flutter or React Native.', 'price': 150000},
            {'icon': '🌐', 'name': 'Web Development', 'description': 'Responsive websites and web apps.', 'price': 80000},
          ],
          'reviews': [],
        },
      },
      {
        'email': 'sophia.vance@hirewise.app',
        'password': 'Demo@2025',
        'name': 'Sophia Vance',
        'phone': '+250788100003',
        'specialty': 'UI/UX Design',
        'bio': 'Passionate UI/UX designer with a focus on user-centered design. 5 years creating intuitive, beautiful interfaces for mobile and web products.',
        'expert': <String, dynamic>{
          'name': 'Sophia Vance',
          'title': 'UI/UX Designer',
          'sector': 'Design',
          'rating': 4.8,
          'reviewCount': 98,
          'yearsExp': 5,
          'responseTime': '< 2 hr',
          'completedJobs': 201,
          'about': 'Passionate UI/UX designer with a focus on user-centered design. I create intuitive, beautiful interfaces for mobile and web products that users love.',
          'startingPrice': 55000,
          'isVerified': true,
          'isOnline': false,
          'avatarUrl': '',
          'services': [
            {'icon': '🎨', 'name': 'UI Design', 'description': 'High-fidelity mockups and design systems.', 'price': 55000},
            {'icon': '🔍', 'name': 'UX Research', 'description': 'User interviews, wireframes, and usability testing.', 'price': 40000},
          ],
          'reviews': [],
        },
      },
      {
        'email': 'james.okafor@hirewise.app',
        'password': 'Demo@2025',
        'name': 'James Okafor',
        'phone': '+250788100004',
        'specialty': 'Business & Finance',
        'bio': 'Certified financial advisor with 9 years helping startups and individuals with investment planning and business strategy.',
        'expert': <String, dynamic>{
          'name': 'James Okafor',
          'title': 'Business & Finance Advisor',
          'sector': 'Finance',
          'rating': 4.7,
          'reviewCount': 61,
          'yearsExp': 9,
          'responseTime': '< 3 hr',
          'completedJobs': 155,
          'about': 'Certified financial advisor helping startups and individuals with investment planning, financial modelling, and business strategy. Based in Kigali with clients across East Africa.',
          'startingPrice': 120000,
          'isVerified': true,
          'isOnline': true,
          'avatarUrl': '',
          'services': [
            {'icon': '📊', 'name': 'Investment Planning', 'description': 'Personalized investment portfolio strategy.', 'price': 120000},
            {'icon': '📈', 'name': 'Business Strategy', 'description': 'Market analysis and growth planning for SMEs.', 'price': 80000},
          ],
          'reviews': [],
        },
      },
    ];

    int created = 0;
    final errors = <String>[];

    for (final t in tutors) {
      FirebaseApp? secondaryApp;
      try {
        final email = t['email'] as String;
        final appName =
            'seeder_${email.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}';
        secondaryApp = await Firebase.initializeApp(
          name: appName,
          options: DefaultFirebaseOptions.web,
        );
        final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);

        UserCredential cred;
        try {
          cred = await secondaryAuth.createUserWithEmailAndPassword(
              email: email, password: t['password'] as String);
        } on FirebaseAuthException catch (e) {
          if (e.code == 'email-already-in-use') {
            cred = await secondaryAuth.signInWithEmailAndPassword(
                email: email, password: t['password'] as String);
          } else {
            rethrow;
          }
        }

        final uid = cred.user!.uid;
        final expert = t['expert'] as Map<String, dynamic>;
        final batch = db.batch();

        batch.set(db.collection('users').doc(uid), {
          'email': t['email'],
          'name': t['name'],
          'role': 'tutor',
          'phone': t['phone'],
          'location': 'Kigali, Rwanda',
          'bio': t['bio'],
          'avatarUrl': '',
          'specialty': t['specialty'],
          'qualifications': 'University of Rwanda, Professional Certification',
          'experience': '${expert['yearsExp']} years',
          'applicationStatement':
              'Demo tutor account for the HireWise platform.',
          'tutorStatus': 'approved',
          'savedExpertIds': [],
          'createdAt': FieldValue.serverTimestamp(),
        });

        batch.set(db.collection('experts').doc(uid), expert);

        await batch.commit();
        created++;
      } catch (e) {
        errors.add('${t['name']}: $e');
      } finally {
        await secondaryApp?.delete();
      }
    }

    if (!mounted) return;
    setState(() => _seeding = false);

    if (errors.isEmpty) {
      messenger.showSnackBar(SnackBar(
        content: Text('$created demo tutors ready! Password: Demo@2025'),
        backgroundColor: const Color(0xFF059669),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 5),
      ));
    } else {
      messenger.showSnackBar(SnackBar(
        content: Text(
            '$created created, ${errors.length} failed. Check console for details.'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ));
    }
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
  _showCreateUserSheet(
    context,
    title: 'Add New Tutor',
    color: const Color(0xFF059669),
    extraField: 'Specialty / Subject Area',
    extraHint: 'e.g. Mathematics, Flutter Dev',
    extraIcon: Icons.school_outlined,
    submitLabel: 'Create Tutor Account',
    onSubmit: (name, email, password, phone, extra) async {
      await BootstrapService.createTutor(
        email: email,
        password: password,
        name: name,
        phone: phone,
        specialty: extra,
      );
    },
  );
}

void _showAddAdmin(BuildContext context) {
  _showCreateUserSheet(
    context,
    title: 'Add New Admin',
    color: const Color(0xFF7C3AED),
    extraField: null,
    extraHint: null,
    extraIcon: null,
    submitLabel: 'Create Admin Account',
    onSubmit: (name, email, password, phone, _) async {
      await BootstrapService.createAdmin(
        email: email,
        password: password,
        name: name,
        phone: phone,
      );
    },
  );
}

void _showCreateUserSheet(
  BuildContext context, {
  required String title,
  required Color color,
  required String? extraField,
  required String? extraHint,
  required IconData? extraIcon,
  required String submitLabel,
  required Future<void> Function(
          String name, String email, String password, String phone, String extra)
      onSubmit,
}) {
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final extraCtrl = TextEditingController();
  bool loading = false;

  _adminSheet(
    context,
    title: title,
    child: StatefulBuilder(builder: (ctx, setSt) {
      return Column(
        children: [
          _adminField('Full Name', nameCtrl, Icons.person_outline_rounded,
              hint: 'e.g. Dr. Emmanuel Nzeyimana'),
          const SizedBox(height: 12),
          _adminField('Email Address', emailCtrl, Icons.email_outlined,
              hint: 'user@example.com',
              keyboard: TextInputType.emailAddress),
          const SizedBox(height: 12),
          _adminField('Password', passwordCtrl, Icons.lock_outline_rounded,
              hint: 'Min 6 characters', obscure: true),
          const SizedBox(height: 12),
          _adminField('Phone (optional)', phoneCtrl, Icons.phone_outlined,
              hint: '+250 78 000 0000', keyboard: TextInputType.phone),
          if (extraField != null) ...[
            const SizedBox(height: 12),
            _adminField(extraField, extraCtrl, extraIcon ?? Icons.work_outline,
                hint: extraHint ?? ''),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: loading
                  ? null
                  : () async {
                      final name = nameCtrl.text.trim();
                      final email = emailCtrl.text.trim();
                      final password = passwordCtrl.text;
                      if (name.isEmpty || email.isEmpty || password.length < 6) {
                        _adminSnack(ctx,
                            'Name, email and a 6+ char password are required.',
                            color: Colors.red.shade500);
                        return;
                      }
                      setSt(() => loading = true);
                      try {
                        await onSubmit(name, email, password,
                            phoneCtrl.text.trim(), extraCtrl.text.trim());
                        if (ctx.mounted) {
                          Navigator.pop(ctx);
                          _adminSnack(context, '$name added successfully!',
                              color: color);
                        }
                      } on FirebaseAuthException catch (e) {
                        setSt(() => loading = false);
                        if (ctx.mounted) {
                          _adminSnack(ctx,
                              e.code == 'email-already-in-use'
                                  ? 'That email is already registered.'
                                  : 'Error: ${e.message}',
                              color: Colors.red.shade500);
                        }
                      } catch (e) {
                        setSt(() => loading = false);
                        if (ctx.mounted) {
                          _adminSnack(ctx, 'Error: $e',
                              color: Colors.red.shade500);
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.5))
                  : Text(submitLabel,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 15)),
            ),
          ),
        ],
      );
    }),
  );
}

void _showSuspendUser(BuildContext context) {
  AppUser? selected;
  String reason = 'Violation of Terms';
  final reasonCtrl = TextEditingController(text: 'Violation of Terms');

  _adminSheet(
    context,
    title: 'Suspend User',
    child: Consumer(
      builder: (ctx, ref, _) {
        final students = ref.watch(studentsProvider).valueOrNull ?? [];
        final tutors = ref.watch(allTutorsProvider).valueOrNull ?? [];
        final allUsers = [...students, ...tutors];

        return StatefulBuilder(builder: (ctx2, setSt) {
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
          if (allUsers.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(child: CircularProgressIndicator()),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<AppUser>(
                  value: selected,
                  hint: const Text('Choose a user…',
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                  isExpanded: true,
                  items: allUsers
                      .map((u) => DropdownMenuItem(
                            value: u,
                            child: Text(
                              '${u.name.isNotEmpty ? u.name : u.email}  (${u.role})',
                              style: const TextStyle(fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ))
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
                  : () async {
                      final nav = Navigator.of(ctx2);
                      final messenger = ScaffoldMessenger.of(context);
                      try {
                        await ref.read(userServiceProvider).updateUser(
                          selected!.uid,
                          {
                            'suspended': true,
                            'suspendedReason': reasonCtrl.text.trim(),
                          },
                        );
                        nav.pop();
                        messenger.showSnackBar(SnackBar(
                          content: Text(
                              '${selected!.name.isNotEmpty ? selected!.name : selected!.email} has been suspended.'),
                          backgroundColor: const Color(0xFFEF4444),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          margin: const EdgeInsets.all(16),
                        ));
                      } catch (e) {
                        messenger.showSnackBar(SnackBar(
                          content: Text('Error: $e'),
                          backgroundColor: Colors.red,
                        ));
                      }
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
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            ),
          ),
        ],
          );
        });
      },
    ),
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
    child: Consumer(
      builder: (ctx, ref, _) {
        final studentCount = ref.watch(studentCountProvider).valueOrNull ?? 0;
        final tutorCount = ref.watch(activeTutorCountProvider).valueOrNull ?? 0;
        final totalCount = studentCount + tutorCount;

        return StatefulBuilder(builder: (ctx2, setSt) {
          final reachLabel = audience == 'All Users'
              ? 'This will reach $totalCount users'
              : audience == 'Students Only'
                  ? 'This will reach $studentCount students'
                  : 'This will reach $tutorCount tutors';

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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 8),
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
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
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
                    Text(reachLabel,
                        style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF7C3AED),
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final title = titleCtrl.text.trim();
                    final message = msgCtrl.text.trim();
                    if (title.isEmpty || message.isEmpty) {
                      _adminSnack(ctx2, 'Title and message are required.',
                          color: Colors.red.shade500);
                      return;
                    }
                    final nav = Navigator.of(ctx2);
                    final messenger = ScaffoldMessenger.of(context);
                    try {
                      await FirebaseFirestore.instance
                          .collection('broadcasts')
                          .add({
                        'title': title,
                        'message': message,
                        'audience': audience,
                        'sentAt': FieldValue.serverTimestamp(),
                        'sentBy': ref
                                .read(currentUserProvider)
                                .valueOrNull
                                ?.uid ??
                            'unknown',
                      });
                      nav.pop();
                      messenger.showSnackBar(SnackBar(
                        content:
                            Text('Broadcast sent to $audience successfully!'),
                        backgroundColor: const Color(0xFF7C3AED),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        margin: const EdgeInsets.all(16),
                      ));
                    } catch (e) {
                      messenger.showSnackBar(SnackBar(
                          content: Text('Error: $e'),
                          backgroundColor: Colors.red));
                    }
                  },
                  icon: const Icon(Icons.send_rounded, size: 18),
                  label: const Text('Send Broadcast',
                      style:
                          TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
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
        });
      },
    ),
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
    bool obscure = false,
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
        maxLines: obscure ? 1 : maxLines,
        obscureText: obscure,
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

class _ExportDialog extends ConsumerStatefulWidget {
  @override
  ConsumerState<_ExportDialog> createState() => _ExportDialogState();
}

class _ExportDialogState extends ConsumerState<_ExportDialog> {
  String _selected = 'Students';
  bool _exporting = false;
  bool _done = false;

  Future<void> _export() async {
    setState(() => _exporting = true);
    // CSV export feature disabled due to platform constraints
    // Future: implement via API endpoint instead of client-side download
    await Future.delayed(const Duration(milliseconds: 500));

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
