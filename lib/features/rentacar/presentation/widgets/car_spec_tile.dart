import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/rentcar_theme.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// One spec tile: icon on top, value below, caption underneath.
class CarSpecTile extends StatelessWidget {
  const CarSpecTile({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final valueColor = isDark ? AppColors.textOnDark : AppColors.textPrimary;
    final labelColor =
        isDark ? AppColors.textOnDarkSecondary : AppColors.textTertiary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: RentCarColors.primary.withAlpha(isDark ? 28 : 14),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 19, color: RentCarColors.primary),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: AppTextStyles.titleSm.copyWith(color: valueColor, fontSize: 13),
        ),
        const SizedBox(height: 1),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: AppTextStyles.captionSm.copyWith(color: labelColor),
        ),
      ],
    );
  }
}

/// Responsive grid of [CarSpecTile]s.
///
/// Falls back to two or three columns depending on the available width so the
/// row never overflows on small phones and never looks sparse on tablets.
class CarSpecsGrid extends StatelessWidget {
  const CarSpecsGrid({
    super.key,
    required this.tiles,
    this.minTileWidth = 92,
  });

  final List<CarSpecTile> tiles;
  final double minTileWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = (constraints.maxWidth / minTileWidth)
            .floor()
            .clamp(2, 4);
        return GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppSpacing.md,
          crossAxisSpacing: AppSpacing.sm,
          childAspectRatio: 0.86,
          padding: EdgeInsets.zero,
          children: tiles,
        );
      },
    );
  }
}