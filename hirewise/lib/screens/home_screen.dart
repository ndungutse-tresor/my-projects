import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/expert.dart';
import '../widgets/expert_card.dart';
import '../widgets/sector_chip.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedSector = 'All';
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _searchQuery = '';

  static const List<_QuickCategory> _categories = [
    _QuickCategory(icon: Icons.code_rounded, label: 'Tech', color: Color(0xFF1A56DB)),
    _QuickCategory(icon: Icons.palette_outlined, label: 'Design', color: Color(0xFF7C3AED)),
    _QuickCategory(icon: Icons.gavel_rounded, label: 'Legal', color: Color(0xFF0891B2)),
    _QuickCategory(icon: Icons.bar_chart_rounded, label: 'Finance', color: Color(0xFF059669)),
    _QuickCategory(icon: Icons.school_outlined, label: 'Education', color: Color(0xFFD97706)),
    _QuickCategory(icon: Icons.campaign_outlined, label: 'Marketing', color: Color(0xFFDC2626)),
  ];

  List<Expert> get _filteredExperts {
    return kExperts.where((e) {
      final matchesSector =
          _selectedSector == 'All' || e.sector == _selectedSector;
      final matchesSearch = _searchQuery.isEmpty ||
          e.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          e.title.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesSector && matchesSearch;
    }).toList();
  }

  List<Expert> get _topRatedExperts {
    final sorted = [...kExperts]..sort((a, b) => b.rating.compareTo(a.rating));
    return sorted.take(4).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToExperts() {
    _scrollController.animateTo(
      680,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
    );
  }

  void _showNotifications(BuildContext context) {
    const notifications = [
      _NotifData(
        icon: Icons.person_add_rounded,
        color: Color(0xFF059669),
        title: 'Marcus Williams accepted your request',
        subtitle: 'Your Flutter Development booking is confirmed.',
        time: '2 min ago',
        isNew: true,
      ),
      _NotifData(
        icon: Icons.star_rounded,
        color: Color(0xFFF59E0B),
        title: 'New review from Sophia Vance',
        subtitle: 'Your UI/UX project received a 5-star review.',
        time: '1 hr ago',
        isNew: true,
      ),
      _NotifData(
        icon: Icons.payment_rounded,
        color: AppTheme.primaryBlue,
        title: 'Payment confirmed',
        subtitle: 'RWF 35,000 sent via MTN Mobile Money.',
        time: '3 hr ago',
        isNew: true,
      ),
      _NotifData(
        icon: Icons.chat_bubble_rounded,
        color: Color(0xFF7C3AED),
        title: 'New message from Julian Vance',
        subtitle: 'Hi! I have reviewed your contract request…',
        time: 'Yesterday',
        isNew: false,
      ),
      _NotifData(
        icon: Icons.verified_rounded,
        color: Color(0xFF059669),
        title: 'Expert verified',
        subtitle: 'Amara Osei has been verified on HireWise.',
        time: 'Yesterday',
        isNew: false,
      ),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        maxChildSize: 0.92,
        minChildSize: 0.4,
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
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    const Text('Notifications',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textDark)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('3 new',
                          style: TextStyle(
                              color: Color(0xFFEF4444),
                              fontSize: 11,
                              fontWeight: FontWeight.w700)),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Mark all read',
                          style: TextStyle(
                              fontSize: 12, color: AppTheme.primaryBlue)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  controller: scroll,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: notifications.length,
                  itemBuilder: (_, i) {
                    final n = notifications[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: n.isNew
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(14),
                        border: n.isNew
                            ? Border.all(
                                color: AppTheme.primaryBlue
                                    .withValues(alpha: 0.2))
                            : null,
                        boxShadow: n.isNew
                            ? [
                                BoxShadow(
                                    color: Colors.black
                                        .withValues(alpha: 0.04),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2))
                              ]
                            : null,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: n.color.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(n.icon, color: n.color, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(n.title,
                                          style: TextStyle(
                                              fontWeight: n.isNew
                                                  ? FontWeight.w700
                                                  : FontWeight.w500,
                                              fontSize: 13,
                                              color: AppTheme.textDark)),
                                    ),
                                    if (n.isNew)
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFEF4444),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(n.subtitle,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.textMuted,
                                        height: 1.3)),
                                const SizedBox(height: 4),
                                Text(n.time,
                                    style: const TextStyle(
                                        fontSize: 11,
                                        color: AppTheme.textMuted)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.white,
            expandedHeight: 0,
            toolbarHeight: 70,
            flexibleSpace: _buildStickyHeader(),
          ),

          SliverToBoxAdapter(child: _buildHero()),

          SliverToBoxAdapter(child: _buildQuickCategories()),

          SliverToBoxAdapter(child: _buildStatsStrip()),

          SliverToBoxAdapter(child: _buildTopRatedSection()),

          SliverToBoxAdapter(child: _buildSectorFilter()),
          SliverToBoxAdapter(
            child: _buildSectionLabel('All Experts', trailing: '${_filteredExperts.length} found'),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => ExpertCard(
                  expert: _filteredExperts[index],
                  onTap: () => Navigator.pushNamed(context, '/expert',
                      arguments: _filteredExperts[index]),
                ),
                childCount: _filteredExperts.length,
              ),
            ),
          ),

          SliverToBoxAdapter(child: _buildHowItWorks()),

          const SliverToBoxAdapter(child: SizedBox(height: 30)),
        ],
      ),
    );
  }

  Widget _buildStickyHeader() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F6FB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _searchQuery = v),
                  style: const TextStyle(fontSize: 13, color: AppTheme.textDark),
                  decoration: InputDecoration(
                    hintText: 'Search experts, skills...',
                    hintStyle: TextStyle(
                        color: Colors.grey.shade400, fontSize: 13),
                    prefixIcon: Icon(Icons.search_rounded,
                        color: Colors.grey.shade400, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close_rounded, size: 16),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () => _showNotifications(context),
              child: Stack(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F6FB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: const Icon(Icons.notifications_outlined,
                        color: AppTheme.textDark, size: 22),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: const BoxDecoration(
                          color: Color(0xFFEF4444),
                          shape: BoxShape.circle),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryBlue, AppTheme.accentPurple],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text('A',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHero() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF1A56DB), Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -30,
            right: -30,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
          ),
          Positioned(
            bottom: -40,
            right: 40,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
          ),
          Positioned(
            top: 20,
            right: 20,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.verified_rounded,
                      size: 13, color: Colors.white),
                  SizedBox(width: 4),
                  Text('Verified Experts',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Good morning,\nAlex 👋',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Find the perfect expert for\nany task today.',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.80),
                      fontSize: 13,
                      height: 1.3),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: _scrollToExperts,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 9),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Explore Now →',
                      style: TextStyle(
                          color: AppTheme.primaryBlue,
                          fontWeight: FontWeight.w700,
                          fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickCategories() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('Browse Categories'),
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) {
              final cat = _categories[i];
              final isSelected = _selectedSector == cat.label ||
                  (_selectedSector == 'All' && cat.label == 'Tech');
              return GestureDetector(
                onTap: () => setState(() {
                  _selectedSector =
                      cat.label == 'Tech' ? 'Tech & Dev' : cat.label;
                }),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? cat.color
                            : cat.color.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                    color: cat.color.withValues(alpha: 0.35),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4))
                              ]
                            : [],
                      ),
                      child: Icon(cat.icon,
                          size: 26,
                          color:
                              isSelected ? Colors.white : cat.color),
                    ),
                    const SizedBox(height: 6),
                    Text(cat.label,
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? cat.color
                                : AppTheme.textMuted)),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatsStrip() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
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
          _StatCell(value: '${kExperts.length}+', label: 'Experts'),
          _StatDivider(),
          const _StatCell(value: '6', label: 'Sectors'),
          _StatDivider(),
          const _StatCell(value: '98%', label: 'Satisfaction'),
          _StatDivider(),
          const _StatCell(value: '24/7', label: 'Support'),
        ],
      ),
    );
  }

  Widget _buildTopRatedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('Top Rated',
            trailing: 'See All', onTrailingTap: () {}),
        SizedBox(
          height: 200,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _topRatedExperts.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              final e = _topRatedExperts[i];
              return GestureDetector(
                onTap: () =>
                    Navigator.pushNamed(context, '/expert', arguments: e),
                child: Container(
                  width: 150,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 3))
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          CircleAvatar(
                            radius: 34,
                            backgroundColor:
                                AppTheme.primaryBlue.withValues(alpha: 0.1),
                            child: Text(e.name[0],
                                style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryBlue)),
                          ),
                          if (e.isOnline)
                            Positioned(
                              right: 2,
                              bottom: 2,
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                    color: AppTheme.successGreen,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.white, width: 2)),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(e.name.split(' ').first,
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textDark)),
                      const SizedBox(height: 2),
                      Text(e.title,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 10, color: AppTheme.textMuted)),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.star_rounded,
                              size: 13, color: AppTheme.warningAmber),
                          const SizedBox(width: 3),
                          Text('${e.rating}',
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textDark)),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSectorFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('Filter by Sector'),
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: kSectors.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) => SectorChip(
              label: kSectors[index],
              isSelected: _selectedSector == kSectors[index],
              onTap: () =>
                  setState(() => _selectedSector = kSectors[index]),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHowItWorks() {
    const steps = [
      _HowStep(
          number: '1',
          icon: Icons.search_rounded,
          title: 'Browse Experts',
          desc: 'Search by skill, sector, or rating to find your match.'),
      _HowStep(
          number: '2',
          icon: Icons.calendar_today_rounded,
          title: 'Book a Session',
          desc: 'Pick a time that works and confirm your booking.'),
      _HowStep(
          number: '3',
          icon: Icons.check_circle_outline_rounded,
          title: 'Get It Done',
          desc: 'Collaborate and deliver. Pay only when satisfied.'),
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A56DB), Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('How It Works',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text('Simple, fast, and reliable',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7), fontSize: 12)),
          const SizedBox(height: 20),
          ...steps.map((step) => Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(step.icon,
                          color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color:
                                      Colors.white.withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text('Step ${step.number}',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700)),
                              ),
                              const SizedBox(width: 8),
                              Text(step.title,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(step.desc,
                              style: TextStyle(
                                  color:
                                      Colors.white.withValues(alpha: 0.75),
                                  fontSize: 12,
                                  height: 1.4)),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String title,
      {String? trailing, VoidCallback? onTrailingTap}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textDark,
                  letterSpacing: -0.3)),
          if (trailing != null)
            GestureDetector(
              onTap: onTrailingTap,
              child: Text(trailing,
                  style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.primaryBlue,
                      fontWeight: FontWeight.w600)),
            ),
        ],
      ),
    );
  }
}


class _QuickCategory {
  final IconData icon;
  final String label;
  final Color color;
  const _QuickCategory(
      {required this.icon, required this.label, required this.color});
}

class _HowStep {
  final String number;
  final IconData icon;
  final String title;
  final String desc;
  const _HowStep(
      {required this.number,
      required this.icon,
      required this.title,
      required this.desc});
}

class _StatCell extends StatelessWidget {
  final String value;
  final String label;
  const _StatCell({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primaryBlue)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  fontSize: 11, color: AppTheme.textMuted)),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        width: 1, height: 28, color: Colors.grey.shade200);
  }
}


class _NotifData {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String time;
  final bool isNew;

  const _NotifData({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.isNew,
  });
}
