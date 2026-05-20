import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/booking.dart';
import '../models/review.dart';
import '../theme/app_theme.dart';
import '../core/providers/app_providers.dart';
import '../core/providers/auth_provider.dart';
import 'video_session_screen.dart';

class StudentStudyScreen extends StatefulWidget {
  const StudentStudyScreen({super.key});

  @override
  State<StudentStudyScreen> createState() => _StudentStudyScreenState();
}

class _StudentStudyScreenState extends State<StudentStudyScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Study Hub',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textDark)),
                  const SizedBox(height: 2),
                  const Text('Sessions · Notes · Resources',
                      style:
                          TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                  const SizedBox(height: 12),
                  TabBar(
                    controller: _tab,
                    labelColor: AppTheme.primaryBlue,
                    unselectedLabelColor: AppTheme.textMuted,
                    indicatorColor: AppTheme.primaryBlue,
                    labelStyle: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 13),
                    tabs: const [
                      Tab(text: 'Sessions'),
                      Tab(text: 'My Notes'),
                      Tab(text: 'Resources'),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tab,
                children: const [
                  _SessionsTab(),
                  _NotesTab(),
                  _ResourcesTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SessionsTab extends ConsumerWidget {
  const _SessionsTab();

  static String _fmtDateTime(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final p = dt.hour < 12 ? 'AM' : 'PM';
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year} · '
        '$h:${dt.minute.toString().padLeft(2, '0')} $p';
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    final uid = user?.uid ?? '';
    final clientName = user?.name ?? '';
    final bookingsAsync = ref.watch(clientBookingsProvider(uid));
    final allBookings = bookingsAsync.valueOrNull ?? [];
    final now = DateTime.now();

    final upcoming = allBookings
        .where((b) =>
            (b.status == BookingStatus.pending ||
                b.status == BookingStatus.confirmed) &&
            b.scheduledAt.isAfter(now))
        .toList();

    final past = allBookings
        .where((b) =>
            b.status == BookingStatus.completed ||
            ((b.status == BookingStatus.pending ||
                    b.status == BookingStatus.confirmed) &&
                b.scheduledAt.isBefore(now)))
        .toList();

    if (bookingsAsync.isLoading) {
      return const Center(
          child:
              CircularProgressIndicator(color: AppTheme.primaryBlue));
    }

    if (allBookings.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.calendar_today_outlined,
                size: 56, color: AppTheme.textMuted),
            SizedBox(height: 12),
            Text('No sessions yet',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textMuted)),
            Text('Book an expert from the Home tab',
                style:
                    TextStyle(fontSize: 13, color: AppTheme.textMuted)),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _sectionHead('Upcoming Sessions'),
        if (upcoming.isEmpty)
          _emptyRow('No upcoming sessions')
        else
          ...upcoming.map(
              (b) => _sessionCard(context, ref, b, clientName, upcoming: true)),
        const SizedBox(height: 8),
        _sectionHead('Past Sessions'),
        if (past.isEmpty)
          _emptyRow('No past sessions')
        else
          ...past.map((b) =>
              _sessionCard(context, ref, b, clientName, upcoming: false)),
      ],
    );
  }

  Widget _sectionHead(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(title,
          style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark)),
    );
  }

  Widget _emptyRow(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(14)),
        child: Text(label,
            style:
                const TextStyle(fontSize: 13, color: AppTheme.textMuted)),
      ),
    );
  }

  Widget _sessionCard(BuildContext context, WidgetRef ref, Booking b,
      String clientName, {required bool upcoming}) {
    final timeStr = _fmtDateTime(b.scheduledAt);
    final roomName =
        'HireWise-${b.id.substring(0, b.id.length < 8 ? b.id.length : 8)}';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: upcoming
            ? Border.all(
                color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.videocam_rounded,
                    color: AppTheme.primaryBlue, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(b.serviceName,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: AppTheme.textDark)),
                    Text('with ${b.expertName}',
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.textMuted)),
                  ],
                ),
              ),
              Text(_fmtPrice(b.servicePrice),
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: AppTheme.primaryBlue)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.schedule_rounded,
                  size: 13, color: AppTheme.textMuted),
              const SizedBox(width: 4),
              Expanded(
                child: Text(timeStr,
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.textMuted)),
              ),
              if (upcoming)
                ElevatedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => VideoSessionScreen(
                        roomName: roomName,
                        partnerName: b.expertName,
                        subject: b.serviceName,
                        scheduledTime: timeStr,
                        isTutor: false,
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.videocam_rounded, size: 15),
                  label: const Text('Join',
                      style: TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                )
              else
                GestureDetector(
                  onTap: () =>
                      _showReviewSheet(context, ref, b, clientName),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppTheme.warningAmber.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color:
                              AppTheme.warningAmber.withValues(alpha: 0.4)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star_outline_rounded,
                            size: 13, color: AppTheme.warningAmber),
                        SizedBox(width: 4),
                        Text('Review',
                            style: TextStyle(
                                fontSize: 11,
                                color: AppTheme.warningAmber,
                                fontWeight: FontWeight.w600)),
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

  void _showReviewSheet(
      BuildContext context, WidgetRef ref, Booking b, String clientName) {
    int stars = 5;
    final commentCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Review ${b.expertName}',
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textDark)),
                const SizedBox(height: 4),
                Text(b.serviceName,
                    style: const TextStyle(
                        fontSize: 13, color: AppTheme.textMuted)),
                const SizedBox(height: 16),
                Row(
                  children: List.generate(
                    5,
                    (i) => GestureDetector(
                      onTap: () => setModalState(() => stars = i + 1),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Icon(Icons.star_rounded,
                            size: 32,
                            color: i < stars
                                ? AppTheme.warningAmber
                                : Colors.grey.shade200),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: commentCtrl,
                  maxLines: 3,
                  style: const TextStyle(
                      fontSize: 14, color: AppTheme.textDark),
                  decoration: InputDecoration(
                    hintText: 'Share your experience…',
                    hintStyle: const TextStyle(
                        fontSize: 13, color: AppTheme.textMuted),
                    filled: true,
                    fillColor: const Color(0xFFF4F6FB),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.all(14),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      await ref.read(reviewServiceProvider).createReview(
                            Review(
                              id: '',
                              bookingId: b.id,
                              clientId: b.clientId,
                              clientName: clientName,
                              expertId: b.expertId,
                              expertName: b.expertName,
                              expertTitle: '',
                              stars: stars,
                              comment: commentCtrl.text.trim(),
                              createdAt: DateTime.now(),
                            ),
                          );
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Submit Review',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NotesTab extends StatefulWidget {
  const _NotesTab();

  @override
  State<_NotesTab> createState() => _NotesTabState();
}

class _NotesTabState extends State<_NotesTab> {
  final List<_Note> _notes = [
    _Note(
      id: '1',
      title: 'Flutter State Management',
      content:
          'StatefulWidget vs StatelessWidget.\n\nStateless: no state, rebuilds only when parent does.\nStateful: has mutable state via setState().\n\nKey patterns:\n- Provider\n- BLoC\n- Riverpod',
      subject: 'Flutter Development',
      date: 'Apr 15, 2025',
      color: const Color(0xFFEEF2FF),
    ),
    _Note(
      id: '2',
      title: 'UI/UX Principles',
      content:
          'Gestalt principles:\n1. Proximity\n2. Similarity\n3. Closure\n4. Continuity\n\nColor theory: use 60-30-10 rule.\nPrimary: 60% neutral\nSecondary: 30% brand\nAccent: 10% highlight',
      subject: 'UI/UX Design',
      date: 'Apr 12, 2025',
      color: const Color(0xFFF0FDF4),
    ),
  ];

  void _openNoteEditor({_Note? existing}) {
    final titleCtrl =
        TextEditingController(text: existing?.title ?? '');
    final contentCtrl =
        TextEditingController(text: existing?.content ?? '');
    final subjectCtrl =
        TextEditingController(text: existing?.subject ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom),
        child: DraggableScrollableSheet(
          initialChildSize: 0.85,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          expand: false,
          builder: (ctx, scroll) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                  child: Row(
                    children: [
                      Text(existing == null ? 'New Note' : 'Edit Note',
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textDark)),
                      const Spacer(),
                      if (existing != null)
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded,
                              color: Color(0xFFEF4444)),
                          onPressed: () {
                            setState(() => _notes
                                .removeWhere((n) => n.id == existing.id));
                            Navigator.pop(ctx);
                          },
                        ),
                      GestureDetector(
                        onTap: () => Navigator.pop(ctx),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close_rounded,
                              size: 16, color: AppTheme.textDark),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scroll,
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Column(
                      children: [
                        TextField(
                          controller: titleCtrl,
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textDark),
                          decoration: const InputDecoration(
                            hintText: 'Note title…',
                            border: InputBorder.none,
                            hintStyle: TextStyle(
                                color: AppTheme.textMuted, fontSize: 18),
                          ),
                        ),
                        TextField(
                          controller: subjectCtrl,
                          style: const TextStyle(
                              fontSize: 13, color: AppTheme.primaryBlue),
                          decoration: const InputDecoration(
                            hintText: 'Subject / Session',
                            border: InputBorder.none,
                            hintStyle: TextStyle(
                                color: AppTheme.textMuted, fontSize: 13),
                          ),
                        ),
                        const Divider(),
                        const SizedBox(height: 8),
                        TextField(
                          controller: contentCtrl,
                          maxLines: null,
                          style: const TextStyle(
                              fontSize: 14,
                              color: AppTheme.textDark,
                              height: 1.6),
                          decoration: const InputDecoration(
                            hintText: 'Start writing your notes…',
                            border: InputBorder.none,
                            hintStyle: TextStyle(
                                color: AppTheme.textMuted, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final title = titleCtrl.text.trim();
                        if (title.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter a note title'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          return;
                        }
                        setState(() {
                          if (existing != null) {
                            final idx = _notes.indexWhere(
                                (n) => n.id == existing.id);
                            if (idx != -1) {
                              _notes[idx] = _Note(
                                id: existing.id,
                                title: title,
                                content: contentCtrl.text,
                                subject: subjectCtrl.text,
                                date: existing.date,
                                color: existing.color,
                              );
                            }
                          } else {
                            _notes.insert(
                              0,
                              _Note(
                                id: DateTime.now()
                                    .millisecondsSinceEpoch
                                    .toString(),
                                title: title,
                                content: contentCtrl.text,
                                subject: subjectCtrl.text,
                                date: 'Today',
                                color: const Color(0xFFFFF7ED),
                              ),
                            );
                          }
                        });
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Save Note',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 15)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openNoteEditor(),
        backgroundColor: AppTheme.primaryBlue,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('New Note',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w700)),
      ),
      body: _notes.isEmpty
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.note_alt_outlined,
                      size: 56, color: AppTheme.textMuted),
                  SizedBox(height: 12),
                  Text('No notes yet',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textMuted)),
                  Text('Tap + to create your first note',
                      style: TextStyle(
                          fontSize: 13, color: AppTheme.textMuted)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              itemCount: _notes.length,
              itemBuilder: (_, i) {
                final n = _notes[i];
                return GestureDetector(
                  onTap: () => _openNoteEditor(existing: n),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: n.color,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 6,
                            offset: const Offset(0, 2))
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(n.title,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                      color: AppTheme.textDark)),
                            ),
                            const Icon(Icons.edit_outlined,
                                size: 16, color: AppTheme.textMuted),
                          ],
                        ),
                        if (n.subject.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(n.subject,
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.primaryBlue,
                                  fontWeight: FontWeight.w600)),
                        ],
                        const SizedBox(height: 8),
                        Text(
                          n.content,
                          style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.textMuted,
                              height: 1.4),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(n.date,
                            style: const TextStyle(
                                fontSize: 11, color: AppTheme.textMuted)),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _ResourcesTab extends StatelessWidget {
  const _ResourcesTab();

  static const _resources = [
    _Resource('Flutter Widgets Cheatsheet.pdf', 'Dr. Amina Uwase',
        'Apr 15, 2025', '1.2 MB', 'pdf', Color(0xFFEF4444)),
    _Resource('UI Design Principles.pptx', 'Sophia Vance', 'Apr 12, 2025',
        '3.4 MB', 'pptx', Color(0xFFD97706)),
    _Resource('Database ERD Template.xlsx', 'Marcus Williams', 'Apr 10, 2025',
        '450 KB', 'xlsx', Color(0xFF059669)),
    _Resource('Python Basics Notes.pdf', 'Dr. Amina Uwase', 'Apr 8, 2025',
        '890 KB', 'pdf', Color(0xFFEF4444)),
    _Resource('React Native Setup Guide.docx', 'Marcus Williams',
        'Apr 5, 2025', '210 KB', 'docx', AppTheme.primaryBlue),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: AppTheme.primaryBlue.withValues(alpha: 0.2)),
          ),
          child: const Row(
            children: [
              Icon(Icons.folder_shared_outlined,
                  color: AppTheme.primaryBlue, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Files shared by your tutors appear here.',
                  style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.primaryBlue,
                      height: 1.4),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ..._resources.map((r) => _resourceCard(context, r)),
      ],
    );
  }

  void _showFileContent(BuildContext context, _Resource r) {
    final content = _sampleContent(r);
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
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: r.iconColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(r.ext.toUpperCase(),
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: r.iconColor)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(r.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: AppTheme.textDark),
                              overflow: TextOverflow.ellipsis),
                          Text('by ${r.tutor}  •  ${r.size}',
                              style: const TextStyle(
                                  fontSize: 11, color: AppTheme.textMuted)),
                        ],
                      ),
                    ),
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
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4F6FB),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          content,
                          style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.textDark,
                              height: 1.7,
                              fontFamily: 'monospace'),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('${r.name} saved to downloads!'),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: AppTheme.primaryBlue,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              margin: const EdgeInsets.all(16),
                            ));
                          },
                          icon: const Icon(Icons.download_rounded, size: 18),
                          label: const Text('Save to Downloads',
                              style: TextStyle(fontWeight: FontWeight.w700)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryBlue,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
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

  String _sampleContent(_Resource r) {
    return switch (r.ext) {
      'pdf' => '''${r.name.replaceAll('.pdf', '')}
════════════════════════════════════

${r.tutor}  |  ${r.date}

────────────────────────────────────
INTRODUCTION
────────────────────────────────────

This document covers the fundamentals of ${r.name.contains('Flutter') ? 'Flutter widgets and layout system' : r.name.contains('Python') ? 'Python programming basics' : r.name.contains('UI') ? 'UI/UX design principles' : 'the subject matter'}.

KEY TOPICS:

1. Core Concepts
   • Understanding the fundamentals
   • Best practices and patterns
   • Common use cases and examples

2. Practical Examples
   • Step-by-step walkthrough
   • Code snippets and diagrams
   • Exercises for practice

3. Summary & Next Steps
   • Review of key points
   • Recommended resources
   • Assignment for next session

────────────────────────────────────
© HireWise · Shared by ${r.tutor}
────────────────────────────────────''',
      'pptx' || 'ppt' => '''PRESENTATION: ${r.name.replaceAll('.pptx', '').replaceAll('.ppt', '')}
════════════════════════════════════

Slide 1: Introduction
  • Welcome & Agenda
  • Learning objectives for today

Slide 2: Core Principles
  • Principle 1: Proximity
  • Principle 2: Similarity
  • Principle 3: Visual hierarchy

Slide 3: Practical Application
  • Real-world examples
  • Case study walkthrough

Slide 4: Tools & Resources
  • Recommended tools
  • Practice exercises

Slide 5: Q&A
  • Open discussion
  • Assignment details

────────────────────────────────────
Presented by ${r.tutor}  |  ${r.date}''',
      'xlsx' || 'xls' => '''SPREADSHEET: ${r.name.replaceAll('.xlsx', '').replaceAll('.xls', '')}
════════════════════════════════════

  A            B             C          D
──────────────────────────────────────────
  Entity       Attribute     Type       Key
──────────────────────────────────────────
  User         user_id       INT        PK
  User         full_name     VARCHAR    --
  User         email         VARCHAR    UQ
  User         role          ENUM       --
──────────────────────────────────────────
  Course       course_id     INT        PK
  Course       title         VARCHAR    --
  Course       tutor_id      INT        FK
──────────────────────────────────────────
  Booking      booking_id    INT        PK
  Booking      user_id       INT        FK
  Booking      course_id     INT        FK
  Booking      date          DATETIME   --

Created by ${r.tutor}  |  ${r.date}''',
      'docx' || 'doc' => '''DOCUMENT: ${r.name.replaceAll('.docx', '').replaceAll('.doc', '')}
════════════════════════════════════

Author: ${r.tutor}
Date:   ${r.date}
Size:   ${r.size}

────────────────────────────────────
OVERVIEW
────────────────────────────────────

This guide provides step-by-step instructions for setting up and using the tools covered in our sessions.

SECTION 1: Prerequisites
  ✓ Install required software
  ✓ Configure your environment
  ✓ Verify installation

SECTION 2: Getting Started
  Step 1: Open the terminal
  Step 2: Run the setup command
  Step 3: Follow the prompts

SECTION 3: Troubleshooting
  • Common errors and solutions
  • Where to get help
  • Community resources

────────────────────────────────────
Questions? Message ${r.tutor} on HireWise''',
      _ => '''FILE: ${r.name}
════════════════════════════════════

Shared by: ${r.tutor}
Date:       ${r.date}
Size:       ${r.size}

This file contains study materials
for your learning session.

Please download to view the full
content in the appropriate app.
════════════════════════════════════''',
    };
  }

  Widget _resourceCard(BuildContext context, _Resource r) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: r.iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(r.ext.toUpperCase(),
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: r.iconColor)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(r.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: AppTheme.textDark),
                    overflow: TextOverflow.ellipsis),
                Text('by ${r.tutor}  •  ${r.size}',
                    style: const TextStyle(
                        fontSize: 11, color: AppTheme.textMuted)),
                Text(r.date,
                    style: const TextStyle(
                        fontSize: 11, color: AppTheme.textMuted)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _showFileContent(context, r),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.open_in_new_rounded,
                  size: 18, color: AppTheme.primaryBlue),
            ),
          ),
        ],
      ),
    );
  }
}

class _Note {
  final String id;
  final String title;
  final String content;
  final String subject;
  final String date;
  final Color color;

  const _Note({
    required this.id,
    required this.title,
    required this.content,
    required this.subject,
    required this.date,
    required this.color,
  });
}

class _Resource {
  final String name;
  final String tutor;
  final String date;
  final String size;
  final String ext;
  final Color iconColor;

  const _Resource(
      this.name, this.tutor, this.date, this.size, this.ext, this.iconColor);
}
