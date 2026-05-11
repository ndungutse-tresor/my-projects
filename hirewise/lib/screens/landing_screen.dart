import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/expert.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});
  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final _scrollController = ScrollController();
  final _contactFormKey = GlobalKey<FormState>();
  final _contactName = TextEditingController();
  final _contactEmail = TextEditingController();
  final _contactMsg = TextEditingController();
  bool _messageSent = false;
  bool _sending = false;

  @override
  void dispose() {
    _scrollController.dispose();
    _contactName.dispose();
    _contactEmail.dispose();
    _contactMsg.dispose();
    super.dispose();
  }

  void _goLogin() => Navigator.pushNamed(context, '/login');
  void _goSignup() => Navigator.pushNamed(context, '/login');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildNavBar(),
          SliverToBoxAdapter(child: _HeroSection(onGetStarted: _goSignup, onSignIn: _goLogin)),
          SliverToBoxAdapter(child: _StatsSection()),
          SliverToBoxAdapter(child: _HowItWorksSection()),
          SliverToBoxAdapter(child: _CategoriesSection()),
          SliverToBoxAdapter(child: _FeaturedExpertsSection(onTap: _goSignup)),
          SliverToBoxAdapter(child: _TestimonialsSection()),
          SliverToBoxAdapter(child: _AboutSection()),
          SliverToBoxAdapter(
            child: _ContactSection(
              formKey: _contactFormKey,
              nameCtrl: _contactName,
              emailCtrl: _contactEmail,
              msgCtrl: _contactMsg,
              messageSent: _messageSent,
              sending: _sending,
              onSend: _sendMessage,
            ),
          ),
          SliverToBoxAdapter(child: _FooterSection(onNav: _goLogin)),
        ],
      ),
    );
  }

  SliverAppBar _buildNavBar() {
    return SliverAppBar(
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      toolbarHeight: 64,
      flexibleSpace: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryBlue, AppTheme.accentPurple],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 8),
              const Text('HireWise',
                  style: TextStyle(
                      color: AppTheme.primaryBlue,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5)),
              const Spacer(),
              LayoutBuilder(builder: (_, c) {
                if (c.maxWidth > 500) {
                  return Row(
                    children: [
                      _NavLink(label: 'How it Works', onTap: () {}),
                      _NavLink(label: 'Experts', onTap: () {}),
                      _NavLink(label: 'About', onTap: () {}),
                      const SizedBox(width: 8),
                    ],
                  );
                }
                return const SizedBox.shrink();
              }),
              TextButton(
                onPressed: _goLogin,
                style: TextButton.styleFrom(foregroundColor: AppTheme.textDark),
                child: const Text('Sign In',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _goSignup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                  textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
                child: const Text('Get Started'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _sendMessage() async {
    if (!_contactFormKey.currentState!.validate()) return;
    setState(() => _sending = true);
    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;
    setState(() {
      _sending = false;
      _messageSent = true;
    });
    _contactName.clear();
    _contactEmail.clear();
    _contactMsg.clear();
  }
}

class _NavLink extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _NavLink({required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) => TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(foregroundColor: AppTheme.textMuted),
        child: Text(label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
      );
}

class _HeroSection extends StatelessWidget {
  final VoidCallback onGetStarted;
  final VoidCallback onSignIn;
  const _HeroSection({required this.onGetStarted, required this.onSignIn});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F1B3D), Color(0xFF1A56DB), Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(top: -60, right: -60,
              child: _GlowCircle(size: 260, color: Colors.white.withValues(alpha: 0.05))),
          Positioned(bottom: -40, left: -40,
              child: _GlowCircle(size: 200, color: Colors.white.withValues(alpha: 0.04))),
          Positioned(top: 80, right: w * 0.12,
              child: _GlowCircle(size: 80, color: Colors.white.withValues(alpha: 0.06))),

          Padding(
            padding: EdgeInsets.fromLTRB(w > 700 ? 80 : 24, 60, w > 700 ? 80 : 24, 60),
            child: w > 700
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(flex: 5, child: _heroText(context)),
                      const SizedBox(width: 48),
                      Expanded(flex: 4, child: _heroCard()),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _heroText(context),
                      const SizedBox(height: 40),
                      Center(child: _heroCard()),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _heroText(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.verified_rounded, size: 14, color: Colors.white),
              SizedBox(width: 6),
              Text('Trusted by 10,000+ professionals',
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Your Expert,\nOne Tap Away.',
          style: TextStyle(
            color: Colors.white,
            fontSize: 46,
            fontWeight: FontWeight.w900,
            height: 1.1,
            letterSpacing: -1.5,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Connect instantly with verified professionals\nin tech, design, law, finance, and more.\nFast. Trusted. Results-driven.',
          style: TextStyle(
              color: Colors.white.withValues(alpha: 0.78),
              fontSize: 16,
              height: 1.6),
        ),
        const SizedBox(height: 32),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            ElevatedButton(
              onPressed: onGetStarted,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppTheme.primaryBlue,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
                textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
              ),
              child: const Text('Get Started Free'),
            ),
            OutlinedButton.icon(
              onPressed: onSignIn,
              icon: const Icon(Icons.play_circle_outline_rounded, size: 18),
              label: const Text('Sign In'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white38, width: 1.5),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            _AvatarStack(),
            const SizedBox(width: 12),
            Text('Join 10K+ happy clients',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 13)),
          ],
        ),
      ],
    );
  }

  Widget _heroCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Top Experts Live Now',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
          const SizedBox(height: 16),
          ...kExperts.take(3).map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _MiniExpertCard(expert: e),
              )),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text('Browse All Experts →',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: AppTheme.primaryBlue,
                    fontWeight: FontWeight.w700,
                    fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

class _GlowCircle extends StatelessWidget {
  final double size;
  final Color color;
  const _GlowCircle({required this.size, required this.color});
  @override
  Widget build(BuildContext context) => Container(
        width: size, height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      );
}

class _AvatarStack extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const initials = ['S', 'M', 'J', 'A'];
    return SizedBox(
      width: 88,
      height: 30,
      child: Stack(
        children: List.generate(
          initials.length,
          (i) => Positioned(
            left: i * 20.0,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryBlue.withValues(alpha: 0.8 - i * 0.1),
                border: const Border.fromBorderSide(BorderSide(color: Colors.white, width: 2)),
              ),
              child: Center(
                child: Text(initials[i],
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniExpertCard extends StatelessWidget {
  final Expert expert;
  const _MiniExpertCard({required this.expert});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.white.withValues(alpha: 0.25),
            child: Text(expert.name[0],
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(expert.name,
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                Text(expert.title,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.65), fontSize: 10)),
              ],
            ),
          ),
          Row(
            children: [
              const Icon(Icons.star_rounded, size: 12, color: AppTheme.warningAmber),
              const SizedBox(width: 3),
              Text('${expert.rating}',
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(width: 6),
          if (expert.isOnline)
            Container(
              width: 8, height: 8,
              decoration: const BoxDecoration(color: AppTheme.successGreen, shape: BoxShape.circle),
            ),
        ],
      ),
    );
  }
}

class _StatsSection extends StatelessWidget {
  static const _stats = [
    ('500+', 'Verified Experts', Icons.people_outline_rounded, AppTheme.primaryBlue),
    ('12+', 'Service Sectors', Icons.category_outlined, Color(0xFF7C3AED)),
    ('4.9★', 'Average Rating', Icons.star_outline_rounded, Color(0xFFF59E0B)),
    ('10K+', 'Projects Done', Icons.check_circle_outline_rounded, Color(0xFF059669)),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 24, offset: const Offset(0, 8)),
        ],
      ),
      child: LayoutBuilder(builder: (_, c) {
        return Wrap(
          alignment: WrapAlignment.spaceEvenly,
          runSpacing: 16,
          children: _stats.map((s) => SizedBox(
            width: c.maxWidth > 600 ? c.maxWidth / 4 - 8 : c.maxWidth / 2 - 16,
            child: Column(
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: s.$4.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(s.$3, color: s.$4, size: 24),
                ),
                const SizedBox(height: 10),
                Text(s.$1,
                    style: TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w900, color: s.$4, letterSpacing: -0.5)),
                const SizedBox(height: 4),
                Text(s.$2,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12, color: AppTheme.textMuted, fontWeight: FontWeight.w500)),
              ],
            ),
          )).toList(),
        );
      }),
    );
  }
}

class _HowItWorksSection extends StatelessWidget {
  static const _steps = [
    (
      '01',
      Icons.search_rounded,
      'Browse Experts',
      'Search by skill, rating, or sector. Filter by availability and price to find your perfect match.',
      Color(0xFF1A56DB),
    ),
    (
      '02',
      Icons.calendar_month_rounded,
      'Book Instantly',
      'Pick a time slot that works for you and confirm your booking in seconds. No back-and-forth.',
      Color(0xFF7C3AED),
    ),
    (
      '03',
      Icons.handshake_outlined,
      'Get Results',
      'Work with your expert and receive deliverables. Pay securely only when you\'re satisfied.',
      Color(0xFF059669),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8F9FB),
      padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 24),
      child: Column(
        children: [
          _SectionTag(label: 'Simple Process'),
          const SizedBox(height: 12),
          const Text('How HireWise Works',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 32, fontWeight: FontWeight.w900,
                  color: AppTheme.textDark, letterSpacing: -0.8)),
          const SizedBox(height: 8),
          const Text('Three steps to get expert help on anything',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: AppTheme.textMuted)),
          const SizedBox(height: 48),
          LayoutBuilder(builder: (_, c) {
            if (c.maxWidth > 700) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _steps.asMap().entries.map((e) {
                  final i = e.key;
                  return Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _StepCard(step: e.value)),
                        if (i < _steps.length - 1)
                          Padding(
                            padding: const EdgeInsets.only(top: 36),
                            child: Icon(Icons.arrow_forward_rounded,
                                color: Colors.grey.shade300, size: 28),
                          ),
                      ],
                    ),
                  );
                }).toList(),
              );
            }
            return Column(
              children: _steps
                  .map((s) => Padding(padding: const EdgeInsets.only(bottom: 16), child: _StepCard(step: s)))
                  .toList(),
            );
          }),
        ],
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  final (String, IconData, String, String, Color) step;
  const _StepCard({required this.step});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 16, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: step.$5.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(step.$2, color: step.$5, size: 26),
              ),
              const Spacer(),
              Text(step.$1,
                  style: TextStyle(
                      fontSize: 28, fontWeight: FontWeight.w900,
                      color: step.$5.withValues(alpha: 0.15), letterSpacing: -1)),
            ],
          ),
          const SizedBox(height: 16),
          Text(step.$3,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
          const SizedBox(height: 8),
          Text(step.$4,
              style: const TextStyle(fontSize: 13, color: AppTheme.textMuted, height: 1.5)),
        ],
      ),
    );
  }
}

class _CategoriesSection extends StatelessWidget {
  static const _cats = [
    ('Tech & Dev', Icons.code_rounded, Color(0xFF1A56DB), '120+ Experts'),
    ('UI/UX Design', Icons.palette_outlined, Color(0xFF7C3AED), '85+ Experts'),
    ('Legal', Icons.gavel_rounded, Color(0xFF0891B2), '60+ Experts'),
    ('Finance', Icons.bar_chart_rounded, Color(0xFF059669), '75+ Experts'),
    ('Education', Icons.school_outlined, Color(0xFFD97706), '50+ Experts'),
    ('Marketing', Icons.campaign_outlined, Color(0xFFDC2626), '45+ Experts'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 24),
      child: Column(
        children: [
          _SectionTag(label: 'What We Cover'),
          const SizedBox(height: 12),
          const Text('Explore Every Sector',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900,
                  color: AppTheme.textDark, letterSpacing: -0.8)),
          const SizedBox(height: 8),
          const Text('From code to contracts — we have the right expert for every challenge',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: AppTheme.textMuted)),
          const SizedBox(height: 40),
          LayoutBuilder(builder: (_, c) {
            final cols = c.maxWidth > 700 ? 3 : 2;
            final w = (c.maxWidth - (cols + 1) * 12) / cols;
            return Wrap(
              spacing: 12, runSpacing: 12,
              children: _cats.map((cat) => SizedBox(
                width: w,
                child: _CategoryCard(cat: cat),
              )).toList(),
            );
          }),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final (String, IconData, Color, String) cat;
  const _CategoryCard({required this.cat});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cat.$3.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cat.$3.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: cat.$3.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(cat.$2, color: cat.$3, size: 24),
          ),
          const SizedBox(height: 12),
          Text(cat.$1,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
          const SizedBox(height: 4),
          Text(cat.$4,
              style: TextStyle(fontSize: 12, color: cat.$3, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _FeaturedExpertsSection extends StatelessWidget {
  final VoidCallback onTap;
  const _FeaturedExpertsSection({required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8F9FB),
      padding: const EdgeInsets.symmetric(vertical: 56),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionTag(label: 'Our Best'),
                    const SizedBox(height: 8),
                    const Text('Featured Experts',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900,
                            color: AppTheme.textDark, letterSpacing: -0.5)),
                  ],
                ),
                TextButton(
                  onPressed: onTap,
                  child: const Text('View All →',
                      style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 220,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: kExperts.length,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (_, i) => _LandingExpertCard(expert: kExperts[i], onTap: onTap),
            ),
          ),
        ],
      ),
    );
  }
}

class _LandingExpertCard extends StatelessWidget {
  final Expert expert;
  final VoidCallback onTap;
  const _LandingExpertCard({required this.expert, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 175,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.12),
                  child: Text(expert.name[0],
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
                ),
                if (expert.isOnline)
                  Positioned(
                    right: 2, bottom: 2,
                    child: Container(
                      width: 12, height: 12,
                      decoration: BoxDecoration(
                          color: AppTheme.successGreen, shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2)),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(expert.name.split(' ').first,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppTheme.textDark)),
            const SizedBox(height: 2),
            Text(expert.title,
                textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star_rounded, size: 13, color: AppTheme.warningAmber),
                const SizedBox(width: 3),
                Text('${expert.rating}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
                Text(' (${expert.reviewCount})',
                    style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 7),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text('View Profile',
                    style: TextStyle(color: AppTheme.primaryBlue, fontSize: 12, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TestimonialsSection extends StatelessWidget {
  static const _reviews = [
    ('Sarah Chen', 'Startup Founder', 'S', Color(0xFF1A56DB),
        'HireWise helped us find an incredible Flutter developer in just 2 days. Exceptional quality and seamless process!'),
    ('David Okafor', 'Product Manager', 'D', Color(0xFF7C3AED),
        'Our legal contracts were reviewed by a top consultant. Saved us thousands and gave real peace of mind.'),
    ('Amina Ibrahim', 'E-commerce Owner', 'A', Color(0xFF059669),
        'Found an amazing UI designer who transformed our brand. Conversion rate went up 40% after the redesign!'),
    ('James Woodley', 'Tech Lead', 'J', Color(0xFF0891B2),
        'The verification system ensures you always work with legit experts. No time wasted on unqualified candidates.'),
    ('Priya Nair', 'Marketing Director', 'P', Color(0xFFD97706),
        'Booked a marketing strategist within an hour. The campaign exceeded all targets. Absolutely brilliant platform.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 56),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                _SectionTag(label: 'Social Proof'),
                const SizedBox(height: 12),
                const Text('What Our Clients Say',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900,
                        color: AppTheme.textDark, letterSpacing: -0.8)),
                const SizedBox(height: 8),
                const Text('Real results from real people',
                    style: TextStyle(fontSize: 15, color: AppTheme.textMuted)),
              ],
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 200,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: _reviews.length,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (_, i) {
                final r = _reviews[i];
                return Container(
                  width: 290,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.07),
                          blurRadius: 16, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          ...List.generate(5, (_) => const Icon(Icons.star_rounded,
                              size: 14, color: AppTheme.warningAmber)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text('"${r.$5}"',
                          maxLines: 3, overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13, color: AppTheme.textDark, height: 1.5)),
                      const Spacer(),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: r.$4.withValues(alpha: 0.15),
                            child: Text(r.$3,
                                style: TextStyle(color: r.$4, fontWeight: FontWeight.bold, fontSize: 13)),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(r.$1,
                                  style: const TextStyle(fontWeight: FontWeight.w700,
                                      fontSize: 12, color: AppTheme.textDark)),
                              Text(r.$2,
                                  style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AboutSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return Container(
      color: const Color(0xFF0F1B3D),
      padding: EdgeInsets.symmetric(vertical: 64, horizontal: w > 700 ? 80 : 24),
      child: LayoutBuilder(builder: (_, c) {
        final isWide = c.maxWidth > 600;
        return isWide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 5, child: _aboutText()),
                  const SizedBox(width: 60),
                  Expanded(flex: 4, child: _aboutValues()),
                ],
              )
            : Column(children: [_aboutText(), const SizedBox(height: 40), _aboutValues()]);
      }),
    );
  }

  Widget _aboutText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text('About Us',
              style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
        ),
        const SizedBox(height: 16),
        const Text('We\'re Rethinking\nHow People Hire.',
            style: TextStyle(
                color: Colors.white, fontSize: 34,
                fontWeight: FontWeight.w900, height: 1.1, letterSpacing: -1)),
        const SizedBox(height: 20),
        Text(
          'HireWise was born from a simple frustration: hiring skilled professionals shouldn\'t be complicated, risky, or expensive.\n\nWe built a curated marketplace where every expert is vetted, every booking is protected, and every project gets done right. Whether you need a developer for a day or a legal advisor for a month — we connect you in minutes, not weeks.',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.72), fontSize: 14, height: 1.7),
        ),
        const SizedBox(height: 28),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryBlue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
          child: const Text('Our Story →', style: TextStyle(fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }

  Widget _aboutValues() {
    const values = [
      (Icons.verified_rounded, 'Verified Only', 'Every expert passes a rigorous background and skills check.'),
      (Icons.security_rounded, 'Secure Payments', 'Funds held in escrow — released only when you\'re satisfied.'),
      (Icons.support_agent_rounded, '24/7 Support', 'Our team is always here if something doesn\'t go right.'),
    ];
    return Column(
      children: values.map((v) => Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withValues(alpha: 0.30),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(v.$1, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(v.$2,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(v.$3,
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.62), fontSize: 12, height: 1.4)),
                ],
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }
}

class _ContactSection extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameCtrl, emailCtrl, msgCtrl;
  final bool messageSent, sending;
  final VoidCallback onSend;

  const _ContactSection({
    required this.formKey, required this.nameCtrl, required this.emailCtrl,
    required this.msgCtrl, required this.messageSent, required this.sending,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return Container(
      color: const Color(0xFFF8F9FB),
      padding: EdgeInsets.symmetric(vertical: 64, horizontal: w > 700 ? 80 : 24),
      child: LayoutBuilder(builder: (_, c) {
        final isWide = c.maxWidth > 600;
        final content = [_contactInfo(), const SizedBox(width: 48, height: 40), _contactForm()];
        return isWide
            ? Row(crossAxisAlignment: CrossAxisAlignment.start,
                children: [Expanded(child: content[0]), content[1], Expanded(child: content[2])])
            : Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [content[0], content[1], content[2]]);
      }),
    );
  }

  Widget _contactInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTag(label: 'Get In Touch'),
        const SizedBox(height: 12),
        const Text('We\'d Love to\nHear From You.',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900,
                color: AppTheme.textDark, height: 1.1, letterSpacing: -0.8)),
        const SizedBox(height: 16),
        const Text(
          'Have a question, a partnership idea, or just want to say hello? Drop us a message and we\'ll get back within 24 hours.',
          style: TextStyle(fontSize: 14, color: AppTheme.textMuted, height: 1.6),
        ),
        const SizedBox(height: 28),
        _ContactInfo(icon: Icons.mail_outline_rounded, text: 'hello@hirewise.io'),
        const SizedBox(height: 12),
        _ContactInfo(icon: Icons.phone_outlined, text: '+234 800 HIREWISE'),
        const SizedBox(height: 12),
        _ContactInfo(icon: Icons.location_on_outlined, text: 'Lagos, Nigeria  •  Remote-first'),
      ],
    );
  }

  Widget _contactForm() {
    if (messageSent) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 16, offset: const Offset(0, 4))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(color: Color(0xFFECFDF5), shape: BoxShape.circle),
              child: const Icon(Icons.check_rounded, color: Color(0xFF059669), size: 40),
            ),
            const SizedBox(height: 20),
            const Text('Message Sent!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
            const SizedBox(height: 8),
            const Text("We'll get back to you within 24 hours.",
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textMuted, fontSize: 14)),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Form(
        key: formKey,
        child: Column(
          children: [
            _FormField(ctrl: nameCtrl, label: 'Your Name', hint: 'Alex Johnson',
                icon: Icons.person_outline_rounded,
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null),
            const SizedBox(height: 16),
            _FormField(ctrl: emailCtrl, label: 'Email Address', hint: 'you@example.com',
                icon: Icons.mail_outline_rounded,
                validator: (v) => (v == null || !v.contains('@')) ? 'Valid email required' : null),
            const SizedBox(height: 16),
            _FormField(ctrl: msgCtrl, label: 'Message', hint: 'Tell us how we can help...',
                icon: Icons.chat_bubble_outline_rounded, maxLines: 4,
                validator: (v) => (v == null || v.length < 10) ? 'Please write at least 10 chars' : null),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: sending ? null : onSend,
                child: sending
                    ? const SizedBox(width: 20, height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Send Message', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactInfo extends StatelessWidget {
  final IconData icon;
  final String text;
  const _ContactInfo({required this.icon, required this.text});
  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: AppTheme.primaryBlue),
          ),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(fontSize: 13, color: AppTheme.textDark, fontWeight: FontWeight.w500)),
        ],
      );
}

class _FormField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label, hint;
  final IconData icon;
  final int maxLines;
  final String? Function(String?)? validator;

  const _FormField({
    required this.ctrl, required this.label, required this.hint,
    required this.icon, this.maxLines = 1, this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            prefixIcon: maxLines == 1 ? Icon(icon, size: 18, color: Colors.grey.shade400) : null,
            filled: true,
            fillColor: const Color(0xFFF7F8FA),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: maxLines > 1 ? 14 : 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2)),
          ),
        ),
      ],
    );
  }
}

class _FooterSection extends StatelessWidget {
  final VoidCallback onNav;
  const _FooterSection({required this.onNav});
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0A1628),
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [AppTheme.primaryBlue, AppTheme.accentPurple]),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 8),
                  const Text('HireWise',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                ],
              ),
              Wrap(
                spacing: 24,
                children: ['About', 'How It Works', 'Experts', 'Contact'].map((label) =>
                    GestureDetector(
                      onTap: onNav,
                      child: Text(label,
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 13, fontWeight: FontWeight.w500)),
                    )).toList(),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Divider(color: Colors.white.withValues(alpha: 0.08), thickness: 1),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('© 2025 HireWise. All rights reserved.',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12)),
              Text('Made with ♥ in Lagos',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionTag extends StatelessWidget {
  final String label;
  const _SectionTag({required this.label});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.primaryBlue.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
            style: const TextStyle(
                color: AppTheme.primaryBlue, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.3)),
      );
}
