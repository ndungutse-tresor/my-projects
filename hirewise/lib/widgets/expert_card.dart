import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/expert.dart';
import '../theme/app_theme.dart';
import '../core/providers/auth_provider.dart';

class ExpertCard extends ConsumerWidget {
  final Expert expert;
  final VoidCallback onTap;

  const ExpertCard({super.key, required this.expert, required this.onTap});

  String _formatPrice(int price) {
    if (price >= 1000) return '${(price / 1000).toStringAsFixed(0)}K';
    return price.toString();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    final isSaved = user?.savedExpertIds.contains(expert.id) ?? false;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor:
                      AppTheme.primaryBlue.withValues(alpha: 0.15),
                  child: Text(
                    expert.name[0],
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryBlue),
                  ),
                ),
                if (expert.isOnline)
                  Positioned(
                    right: 2,
                    bottom: 2,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppTheme.successGreen,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(expert.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: AppTheme.textDark)),
                      ),
                      if (expert.isVerified) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.verified,
                            size: 15, color: AppTheme.primaryBlue),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(expert.title,
                      style: const TextStyle(
                          fontSize: 12, color: AppTheme.textMuted)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          size: 14, color: AppTheme.warningAmber),
                      const SizedBox(width: 2),
                      Text('${expert.rating}',
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textDark)),
                      Text(' (${expert.reviewCount})',
                          style: const TextStyle(
                              fontSize: 12, color: AppTheme.textMuted)),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () {
                    final uid = user?.uid;
                    if (uid == null) return;
                    ref
                        .read(userServiceProvider)
                        .toggleSaveExpert(uid, expert.id);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      isSaved ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                      size: 20,
                      color: isSaved
                          ? const Color(0xFFDC2626)
                          : Colors.grey.shade400,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Starting at',
                  style: TextStyle(fontSize: 10, color: AppTheme.textMuted),
                ),
                Text(
                  'RWF ${_formatPrice(expert.startingPrice)}',
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryBlue),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.arrow_forward_ios_rounded,
                      size: 12, color: AppTheme.primaryBlue),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
