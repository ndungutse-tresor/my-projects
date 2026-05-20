import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/expert.dart';
import '../models/message.dart';
import '../theme/app_theme.dart';
import 'inbox_screen.dart';

class ExpertProfileScreen extends StatelessWidget {
  final Expert expert;

  const ExpertProfileScreen({super.key, required this.expert});

  String _formatPrice(int price) {
    if (price >= 1000) return 'RWF ${(price / 1000).toStringAsFixed(0)}K';
    return 'RWF $price';
  }

  void _openMessage(BuildContext context) {
    final conversation = Conversation.newThread(
      id: expert.id,
      participantName: expert.name,
      isOnline: expert.isOnline,
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ExpertChatScreen(conversation: conversation),
      ),
    );
  }

  void _openShare(BuildContext context) {
    final url = 'https://hirewise.com/expert/${expert.id}';
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
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
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Share ${expert.name}\'s Profile',
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textDark)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F6FB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.link_rounded,
                      size: 18, color: AppTheme.textMuted),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(url,
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.textMuted),
                        overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _shareOption(
                    context,
                    icon: Icons.copy_rounded,
                    label: 'Copy Link',
                    color: AppTheme.primaryBlue,
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: url));
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Link copied to clipboard'),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          margin: const EdgeInsets.all(16),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _shareOption(
                    context,
                    icon: Icons.message_rounded,
                    label: 'WhatsApp',
                    color: const Color(0xFF25D366),
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Opening WhatsApp for ${expert.name}…'),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          margin: const EdgeInsets.all(16),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _shareOption(
                    context,
                    icon: Icons.email_outlined,
                    label: 'Email',
                    color: const Color(0xFFD97706),
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Opening email client…'),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          margin: const EdgeInsets.all(16),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _shareOption(BuildContext context,
      {required IconData icon,
      required String label,
      required Color color,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 5),
            Text(label,
                style: TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGrey,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: Colors.white,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 6)
                  ],
                ),
                child: const Icon(Icons.arrow_back_ios_new,
                    size: 16, color: AppTheme.textDark),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.share_outlined,
                      size: 18, color: AppTheme.textDark),
                ),
                onPressed: () => _openShare(context),
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryBlue.withValues(alpha: 0.9),
                      AppTheme.accentPurple.withValues(alpha: 0.9)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60),
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white.withValues(alpha: 0.3),
                          child: Text(
                            expert.name[0],
                            style: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                        if (expert.isVerified)
                          Positioned(
                            right: 2,
                            bottom: 2,
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                  color: AppTheme.primaryBlue,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: Colors.white, width: 2)),
                              child: const Icon(Icons.check,
                                  size: 12, color: Colors.white),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded,
                              size: 14, color: AppTheme.warningAmber),
                          const SizedBox(width: 4),
                          Text(
                              '${expert.rating} (${expert.reviewCount} reviews)',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(expert.name,
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textDark)),
                  const SizedBox(height: 4),
                  Text(expert.title,
                      style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.primaryBlue,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _StatItem(
                          label: 'Experience',
                          value: '${expert.yearsExp} Years'),
                      const _StatDivider(),
                      _StatItem(label: 'Response', value: expert.responseTime),
                      const _StatDivider(),
                      _StatItem(
                          label: 'Completed',
                          value: '${expert.completedJobs}+'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(child: _buildSection('About', _buildAbout())),
          SliverToBoxAdapter(
              child: _buildSection('Services', _buildServices())),
          SliverToBoxAdapter(
            child: _buildSection(
              'Client Feedback',
              _buildReviews(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _openMessage(context),
                      icon: const Icon(Icons.chat_bubble_outline),
                      label: const Text('Message'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primaryBlue,
                        side: const BorderSide(color: AppTheme.primaryBlue),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pushNamed(context, '/book',
                          arguments: expert),
                      child: Text(
                          'Book Now  \u2022  ${_formatPrice(expert.startingPrice)}'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, Widget child, {Widget? trailing}) {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark)),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildAbout() {
    return Text(expert.about,
        style: const TextStyle(
            fontSize: 14, color: AppTheme.textMuted, height: 1.6));
  }

  Widget _buildServices() {
    if (expert.services.isEmpty) {
      return const Text('No services listed.',
          style: TextStyle(color: AppTheme.textMuted, fontSize: 14));
    }
    return Column(
      children: expert.services.map((service) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.backgroundGrey,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.work_outline_rounded,
                    size: 20, color: AppTheme.primaryBlue),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(service.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: AppTheme.textDark)),
                    const SizedBox(height: 2),
                    Text(service.description,
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.textMuted)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'RWF ${(service.price / 1000).toStringAsFixed(0)}K',
                style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppTheme.primaryBlue),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildReviews() {
    if (expert.reviews.isEmpty) {
      return const Text('No reviews yet.',
          style: TextStyle(color: AppTheme.textMuted, fontSize: 14));
    }
    return Column(
      children: expert.reviews.map((review) {
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.backgroundGrey,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor:
                        AppTheme.primaryBlue.withValues(alpha: 0.15),
                    child: Text(review.clientName[0],
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryBlue)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(review.clientName,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: AppTheme.textDark)),
                  ),
                  Row(
                    children: List.generate(
                        review.stars,
                        (_) => const Icon(Icons.star_rounded,
                            size: 13, color: AppTheme.warningAmber)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(review.comment,
                  style: const TextStyle(
                      fontSize: 13, color: AppTheme.textMuted, height: 1.5)),
              const SizedBox(height: 6),
              Text(review.date,
                  style:
                      const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDark)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return Container(height: 30, width: 1, color: Colors.grey.shade200);
  }
}
