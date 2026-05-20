import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../services/app_state.dart';
import '../models/booking.dart';
import '../models/expert.dart' show ExpertService;
import '../core/providers/auth_provider.dart';
import '../core/providers/app_providers.dart';
import 'inbox_screen.dart';
import 'video_session_screen.dart';
import 'tutor_resources_screen.dart';

class TutorShell extends ConsumerStatefulWidget {
  const TutorShell({super.key});

  @override
  ConsumerState<TutorShell> createState() => _TutorShellState();
}

class _TutorShellState extends ConsumerState<TutorShell> {
  int _index = 0;

  bool get _isPending {
    final status =
        ref.watch(currentUserProvider).valueOrNull?.tutorStatus;
    return status == TutorStatus.pending ||
        status == TutorStatus.incomplete;
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      const _TutorDashboard(),
      _isPending ? _lockedScreen('Resources') : const TutorResourcesScreen(),
      _isPending ? _lockedScreen('Messages') : const InboxScreen(),
      const _TutorProfile(),
    ];

    final totalUnread = ref.watch(conversationsProvider).valueOrNull
            ?.fold<int>(0, (acc, c) => acc + c.unreadCount) ??
        0;

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
                _navItem(2, Icons.chat_bubble_outline_rounded, Icons.chat_bubble_rounded, 'Messages', badge: totalUnread),
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

class _TutorDashboard extends ConsumerWidget {
  const _TutorDashboard();

  static const _color = Color(0xFF059669);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    final uid = user?.uid ?? '';
    final allBookings =
        ref.watch(expertBookingsProvider(uid)).valueOrNull ?? [];
    final now = DateTime.now();
    final pendingRequests =
        allBookings.where((b) => b.status == BookingStatus.pending).toList();
    final confirmedSessions = allBookings
        .where((b) => b.status == BookingStatus.confirmed)
        .toList()
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    final completedBookings =
        allBookings.where((b) => b.status == BookingStatus.completed).toList();
    final sessionCount = completedBookings.length;
    final monthlyEarnings = completedBookings
        .where((b) =>
            b.scheduledAt.year == now.year &&
            b.scheduledAt.month == now.month)
        .fold<int>(0, (acc, b) => acc + b.servicePrice);
    final totalEarnings =
        completedBookings.fold<int>(0, (acc, b) => acc + b.servicePrice);
    final services =
        ref.watch(expertByIdProvider(uid)).valueOrNull?.services ?? [];
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
                                user?.name ?? 'Tutor',
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
                                Text('$sessionCount Sessions completed',
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
                              user?.initial ?? 'T',
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
                  _stat(_fmtPrice(monthlyEarnings), 'This Month', _color),
                  Container(height: 36, width: 1, color: Colors.grey.shade200),
                  _stat(_fmtPrice(totalEarnings), 'Total Earned', _color),
                  Container(height: 36, width: 1, color: Colors.grey.shade200),
                  _stat('$sessionCount', 'Sessions', _color),
                  Container(height: 36, width: 1, color: Colors.grey.shade200),
                  _stat('${pendingRequests.length}', 'Pending', const Color(0xFFD97706)),
                ],
              ),
            ),
          ),

          if (user?.tutorStatus == TutorStatus.incomplete)
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF7C3AED).withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: const Color(0xFF7C3AED).withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.assignment_outlined,
                        size: 22, color: Color(0xFF7C3AED)),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Complete Your Verification',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  color: Color(0xFF7C3AED))),
                          Text(
                              'Submit your documents to become a verified tutor on HireWise.',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF7C3AED),
                                  height: 1.4)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => Navigator.of(context)
                          .pushNamed('/tutor/verify'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: const Color(0xFF7C3AED),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text('Start',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          if (user?.tutorStatus == TutorStatus.pending)
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

          SliverToBoxAdapter(
            child: _sectionLabel(
              'Pending Requests',
              pendingRequests.isEmpty ? null : '${pendingRequests.length} new',
            ),
          ),
          SliverToBoxAdapter(
            child: pendingRequests.isEmpty
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16)),
                      child: const Row(
                        children: [
                          Icon(Icons.inbox_outlined,
                              size: 20, color: AppTheme.textMuted),
                          SizedBox(width: 10),
                          Text('No pending requests',
                              style: TextStyle(
                                  fontSize: 13, color: AppTheme.textMuted)),
                        ],
                      ),
                    ),
                  )
                : Column(
                    children: pendingRequests
                        .map((b) => _bookingRequest(context, ref, b))
                        .toList(),
                  ),
          ),

          SliverToBoxAdapter(
            child: _sectionLabel(
              'Confirmed Sessions',
              confirmedSessions.isEmpty
                  ? null
                  : '${confirmedSessions.length} session${confirmedSessions.length == 1 ? '' : 's'}',
            ),
          ),
          SliverToBoxAdapter(
            child: confirmedSessions.isEmpty
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16)),
                      child: const Row(
                        children: [
                          Icon(Icons.calendar_today_outlined,
                              size: 20, color: AppTheme.textMuted),
                          SizedBox(width: 10),
                          Text('No confirmed sessions yet',
                              style: TextStyle(
                                  fontSize: 13, color: AppTheme.textMuted)),
                        ],
                      ),
                    ),
                  )
                : Column(
                    children: [
                      for (var i = 0; i < confirmedSessions.length; i++)
                        _sessionCard(context, confirmedSessions[i], i == 0)
                    ],
                  ),
          ),

          SliverToBoxAdapter(child: _sectionLabel('My Services', null)),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  ...services.map((s) => _serviceChip(s, _color)),
                  _addServiceTile(context, ref, uid, _color),
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

  static String _fmtTime(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final p = dt.hour < 12 ? 'AM' : 'PM';
    return '$h:${dt.minute.toString().padLeft(2, '0')} $p';
  }

  static String _fmtPrice(int price) {
    if (price >= 1000000) {
      return 'RWF ${(price / 1000000).toStringAsFixed(1)}M';
    }
    if (price >= 1000) {
      return 'RWF ${(price / 1000).toStringAsFixed(price % 1000 == 0 ? 0 : 1)}K';
    }
    return 'RWF $price';
  }

  static Widget _bookingRequest(
      BuildContext context, WidgetRef ref, Booking booking) {
    final name = booking.clientName.isNotEmpty ? booking.clientName : '?';
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
                Text(booking.serviceName,
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.textMuted)),
                Text(_fmtTime(booking.scheduledAt),
                    style: const TextStyle(
                        fontSize: 11, color: AppTheme.textMuted)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(_fmtPrice(booking.servicePrice),
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: Color(0xFF059669))),
              const SizedBox(height: 8),
              Row(
                children: [
                  _actionBtn('Decline', const Color(0xFFEF4444), () async {
                    await ref
                        .read(bookingServiceProvider)
                        .updateStatus(booking.id, BookingStatus.cancelled, booking);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Booking with $name declined.'),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: const Color(0xFFEF4444),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        margin: const EdgeInsets.all(16),
                      ));
                    }
                  }),
                  const SizedBox(width: 6),
                  _actionBtn('Accept', const Color(0xFF059669), () async {
                    await ref
                        .read(bookingServiceProvider)
                        .updateStatus(booking.id, BookingStatus.confirmed, booking);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Booking with $name accepted!'),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: const Color(0xFF059669),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        margin: const EdgeInsets.all(16),
                      ));
                    }
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

  static Widget _sessionCard(
      BuildContext context, Booking booking, bool isNext) {
    final timeStr = _fmtTime(booking.scheduledAt);
    final roomName =
        'HireWise-${booking.id.substring(0, booking.id.length < 8 ? booking.id.length : 8)}';
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isNext
            ? Border.all(
                color: const Color(0xFF059669).withValues(alpha: 0.4),
                width: 1.5)
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
            child: Text(timeStr,
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
                Text(booking.serviceName,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: AppTheme.textDark)),
                Text('with ${booking.clientName}',
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.textMuted)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(_fmtPrice(booking.servicePrice),
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
                      partnerName: booking.clientName,
                      subject: booking.serviceName,
                      scheduledTime: timeStr,
                      isTutor: true,
                    ),
                  ),
                ),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF059669),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.videocam_rounded,
                          color: Colors.white, size: 13),
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

  static Widget _serviceChip(ExpertService s, Color color) {
    final priceLabel = s.price >= 1000
        ? 'RWF ${(s.price / 1000).toStringAsFixed(0)}K'
        : 'RWF ${s.price}';
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.all(14),
      width: 130,
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
          Text(s.icon.isNotEmpty ? s.icon : '🛠️',
              style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 6),
          Text(s.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  color: AppTheme.textDark)),
          Text(priceLabel,
              style: TextStyle(fontSize: 11, color: color)),
        ],
      ),
    );
  }

  static Widget _addServiceTile(
      BuildContext context, WidgetRef ref, String uid, Color color) {
    return GestureDetector(
      onTap: () => _showAddService(context, ref, uid, color),
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.all(14),
        width: 110,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3),
              style: BorderStyle.solid),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_rounded, color: color, size: 28),
            const SizedBox(height: 6),
            Text('Add Service',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: color)),
          ],
        ),
      ),
    );
  }

  static void _showAddService(
      BuildContext context, WidgetRef ref, String uid, Color color) {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final emojiCtrl = TextEditingController(text: '🛠️');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Add Service',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textDark)),
              const SizedBox(height: 16),
              _field(emojiCtrl, 'Icon (emoji)', '🛠️'),
              const SizedBox(height: 10),
              _field(nameCtrl, 'Service Name', 'e.g. App Development'),
              const SizedBox(height: 10),
              _field(descCtrl, 'Short Description', 'What you offer'),
              const SizedBox(height: 10),
              _field(priceCtrl, 'Price (RWF)', '35000',
                  keyboardType: TextInputType.number),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final name = nameCtrl.text.trim();
                    final price = int.tryParse(
                            priceCtrl.text.replaceAll(',', '').trim()) ??
                        0;
                    if (name.isEmpty || uid.isEmpty) return;
                    await ref.read(expertServiceProvider).addService(
                          uid,
                          ExpertService(
                            icon: emojiCtrl.text.trim(),
                            name: name,
                            description: descCtrl.text.trim(),
                            price: price,
                          ),
                        );
                    if (context.mounted) Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Save Service',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _field(TextEditingController ctrl, String label, String hint,
      {TextInputType? keyboardType}) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 14, color: AppTheme.textDark),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle:
            const TextStyle(fontSize: 13, color: AppTheme.textMuted),
        filled: true,
        fillColor: const Color(0xFFF4F6FB),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }
}

class _TutorProfile extends ConsumerStatefulWidget {
  const _TutorProfile();

  @override
  ConsumerState<_TutorProfile> createState() => _TutorProfileState();
}

class _TutorProfileState extends ConsumerState<_TutorProfile> {
  bool _availableForHire = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final uid = ref.read(currentUserProvider).valueOrNull?.uid;
      if (uid == null || !mounted) return;
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (mounted) {
        setState(() {
          _availableForHire = (doc.data()?['isAvailable'] as bool?) ?? true;
        });
      }
    });
  }

  void _editProfile() {
    final user = ref.read(currentUserProvider).valueOrNull;
    final nameCtrl = TextEditingController(text: user?.name ?? '');
    final specCtrl = TextEditingController(text: user?.specialty ?? '');
    final bioCtrl = TextEditingController(text: user?.bio ?? '');
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
              _sheetSaveBtn('Save Changes', () async {
                final uid = ref.read(currentUserProvider).valueOrNull?.uid;
                if (uid != null) {
                  await ref.read(userServiceProvider).updateUser(uid, {
                    if (nameCtrl.text.isNotEmpty) 'name': nameCtrl.text,
                    if (bioCtrl.text.isNotEmpty) 'bio': bioCtrl.text,
                    if (specCtrl.text.isNotEmpty) 'specialty': specCtrl.text,
                  });
                }
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Profile updated successfully!'),
                    backgroundColor: Color(0xFF059669),
                    behavior: SnackBarBehavior.floating,
                  ));
                }
              }),
            ],
          ),
        ),
      ),
    );
  }

  void _myServices() {
    final uid = ref.read(currentUserProvider).valueOrNull?.uid ?? '';
    const color = Color(0xFF059669);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SheetWrap(
        title: 'My Services & Pricing',
        child: Consumer(
          builder: (ctx, ref, _) {
            final services =
                ref.watch(expertByIdProvider(uid)).valueOrNull?.services ?? [];
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (services.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      'No services added yet. Add your first service below.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                    ),
                  )
                else
                  ...services.map((s) {
                    final priceLabel = s.price >= 1000
                        ? 'RWF ${(s.price / 1000).toStringAsFixed(0)},000'
                        : 'RWF ${s.price}';
                    return Container(
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
                              color: color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                s.icon.isNotEmpty ? s.icon : '🛠️',
                                style: const TextStyle(fontSize: 20),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(s.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                        color: AppTheme.textDark)),
                                Text(priceLabel,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: color,
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              await ref
                                  .read(expertServiceProvider)
                                  .removeService(uid, s.name);
                            },
                            child: Icon(Icons.delete_outline_rounded,
                                size: 18, color: Colors.red.shade300),
                          ),
                        ],
                      ),
                    );
                  }),
                const SizedBox(height: 8),
                _sheetSaveBtn('Add New Service', () {
                  Navigator.pop(context);
                  _TutorDashboard._showAddService(ctx, ref, uid, color);
                }),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _availabilityCalendar() async {
    const allDays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    const defaultDays = ['Monday', 'Tuesday', 'Wednesday', 'Friday', 'Saturday'];
    final uid = ref.read(currentUserProvider).valueOrNull?.uid ?? '';

    List<String> savedDays = defaultDays;
    if (uid.isNotEmpty) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final raw = doc.data()?['availableDays'];
      if (raw is List) savedDays = List<String>.from(raw);
    }
    if (!mounted) return;

    final enabled = allDays.map((d) => savedDays.contains(d)).toList();

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
              ...List.generate(allDays.length, (i) => Container(
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
                          child: Text(allDays[i],
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
              _sheetSaveBtn('Save Availability', () async {
                final selected = <String>[
                  for (int i = 0; i < allDays.length; i++)
                    if (enabled[i]) allDays[i],
                ];
                if (uid.isNotEmpty) {
                  await ref
                      .read(userServiceProvider)
                      .updateUser(uid, {'availableDays': selected});
                }
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
                    content: Text('Availability saved!'),
                    backgroundColor: Color(0xFF059669),
                    behavior: SnackBarBehavior.floating,
                  ));
                }
              }),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _payoutMethods() async {
    final uid = ref.read(currentUserProvider).valueOrNull?.uid ?? '';
    int initialSelected = 0;
    if (uid.isNotEmpty) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      initialSelected = (doc.data()?['payoutMethod'] as int?) ?? 0;
    }
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModalState) {
          int selected = initialSelected;
          return _SheetWrap(
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
                _sheetSaveBtn('Save Payout Method', () async {
                  if (uid.isNotEmpty) {
                    await ref
                        .read(userServiceProvider)
                        .updateUser(uid, {'payoutMethod': selected});
                  }
                  if (ctx.mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
                      content: Text('Payout method updated!'),
                      backgroundColor: Color(0xFF059669),
                      behavior: SnackBarBehavior.floating,
                    ));
                  }
                }),
              ],
            ),
          );
        },
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
    final uid = ref.read(currentUserProvider).valueOrNull?.uid ?? '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SheetWrap(
        title: 'Earnings History',
        child: Consumer(
          builder: (ctx, ref, _) {
            final completed = (ref.watch(expertBookingsProvider(uid)).valueOrNull ?? [])
                .where((b) => b.status == BookingStatus.completed)
                .toList();
            final totalEarned = completed.fold<int>(0, (s, b) => s + b.servicePrice);
            final totalSessions = completed.length;

            // Group by "Month YYYY"
            final Map<String, (int, int)> byMonth = {};
            for (final b in completed) {
              final key =
                  '${_monthName(b.scheduledAt.month)} ${b.scheduledAt.year}';
              final prev = byMonth[key] ?? (0, 0);
              byMonth[key] = (prev.$1 + b.servicePrice, prev.$2 + 1);
            }
            final months = byMonth.entries.toList()
              ..sort((a, b) {
                final aDate = _parseMonthKey(a.key);
                final bDate = _parseMonthKey(b.key);
                return bDate.compareTo(aDate);
              });

            String fmtPrice(int p) {
              if (p >= 1000000) {
                return 'RWF ${(p / 1000000).toStringAsFixed(1)}M';
              }
              final s = p.toString();
              if (s.length > 3) {
                return 'RWF ${s.substring(0, s.length - 3)},${s.substring(s.length - 3)}';
              }
              return 'RWF $s';
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Color(0xFF059669), Color(0xFF047857)]),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Total Earned',
                              style: TextStyle(color: Colors.white70, fontSize: 12)),
                          Text(fmtPrice(totalEarned),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Total Sessions',
                              style: TextStyle(color: Colors.white70, fontSize: 12)),
                          Text('$totalSessions sessions',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (months.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'No completed sessions yet.',
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                    ),
                  )
                else
                  ...months.map((e) => Container(
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
                                  Text(e.key,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13,
                                          color: AppTheme.textDark)),
                                  Text('${e.value.$2} sessions',
                                      style: const TextStyle(
                                          fontSize: 12, color: AppTheme.textMuted)),
                                ],
                              ),
                            ),
                            Text(fmtPrice(e.value.$1),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    color: Color(0xFF059669))),
                          ],
                        ),
                      )),
              ],
            );
          },
        ),
      ),
    );
  }

  static String _monthName(int m) => const [
        '', 'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ][m];

  static DateTime _parseMonthKey(String key) {
    final parts = key.split(' ');
    const months = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final month = months.indexOf(parts[0]);
    final year = int.tryParse(parts[1]) ?? 2000;
    return DateTime(year, month);
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
    final user = ref.watch(currentUserProvider).valueOrNull;
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
                            onTap: () async {
                              final newVal = !_availableForHire;
                              setState(() => _availableForHire = newVal);
                              final uid = ref.read(currentUserProvider).valueOrNull?.uid;
                              if (uid != null) {
                                await ref
                                    .read(userServiceProvider)
                                    .updateUser(uid, {'isAvailable': newVal});
                              }
                            },
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
                                  user?.initial ?? 'T',
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
                              Text(user?.name ?? 'Tutor',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800)),
                              Text(
                                  user?.specialty.isNotEmpty == true
                                      ? '${user!.specialty} · Tutor'
                                      : 'Tutor',
                                  style: const TextStyle(color: Colors.white70, fontSize: 13)),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.location_on_outlined,
                                      size: 12, color: Colors.white70),
                                  const SizedBox(width: 3),
                                  Text(
                                      user?.location.isNotEmpty == true
                                          ? user!.location
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
                    onChanged: (v) async {
                      setState(() => _availableForHire = v);
                      final uid = ref.read(currentUserProvider).valueOrNull?.uid;
                      if (uid != null) {
                        await ref
                            .read(userServiceProvider)
                            .updateUser(uid, {'isAvailable': v});
                      }
                    },
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
                onTap: () async {
                  final nav = Navigator.of(context);
                  await ref.read(authServiceProvider).signOut();
                  if (mounted) nav.pushNamedAndRemoveUntil('/', (_) => false);
                },
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
