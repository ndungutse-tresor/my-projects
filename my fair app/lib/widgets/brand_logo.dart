import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A simple text-based logo mark for Mayfair Rwanda.
///
/// Placeholder for a real logo asset — swap in an Image when brand assets
/// are available.
class BrandLogo extends StatelessWidget {
  final double size;
  final bool light;

  const BrandLogo({super.key, this.size = 40, this.light = false});

  @override
  Widget build(BuildContext context) {
    final markColor = light ? Colors.white : AppColors.navy;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.gold, AppColors.goldDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(size * 0.28),
          ),
          alignment: Alignment.center,
          child: Text(
            'M',
            style: TextStyle(
              color: AppColors.navyDark,
              fontWeight: FontWeight.w900,
              fontSize: size * 0.55,
            ),
          ),
        ),
        SizedBox(width: size * 0.3),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'MAYFAIR',
              style: TextStyle(
                color: markColor,
                fontWeight: FontWeight.w900,
                fontSize: size * 0.42,
                letterSpacing: 1.5,
                height: 1,
              ),
            ),
            Text(
              'INSURANCE • RWANDA',
              style: TextStyle(
                color: light ? Colors.white70 : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: size * 0.2,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
