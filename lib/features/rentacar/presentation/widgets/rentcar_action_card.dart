import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/rentcar_theme.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Full-width tappable row used across the Rent a Car hub and profile menus.
class RentCarActionCard extends StatelessWidget {
  const RentCarActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.trailing,
    this.emphasised = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  /// Overrides the default chevron, e.g. to show a pending-count badge.
  final Widget? trailing;

  /// Fills the icon tile with the brand colour — used for the primary action.
  final bool emphasised;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textOnDark : AppColors.textPrimary;
    final mutedColor =
        isDark ? AppColors.textOnDarkSecondary : AppColors.textSecondary;
    final borderColor = isDark ? AppColors.darkElevated : AppColors.border;

    return Material(
      color: isDark ? AppColors.darkSurface : Colors.white,
      borderRadius: AppRadius.circularCardLg,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.circularCardLg,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: AppRadius.circularCardLg,
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: emphasised
                      ? RentCarColors.primary
                      : RentCarColors.primary.withAlpha(isDark ? 26 : 14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  size: 22,
                  color: emphasised ? Colors.white : RentCarColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.titleSm.copyWith(color: textColor),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTextStyles.captionSm.copyWith(color: mutedColor),
                    ),
                  ],
                ),
              ),
              trailing ??
                  Icon(
                    Icons.chevron_right_rounded,
                    color: mutedColor,
                    size: 22,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small circular count badge for the "Meus carros" row.
class RentCarCountBadge extends StatelessWidget {
  const RentCarCountBadge({super.key, required this.count, this.zeroLabel});

  final int count;
  final String? zeroLabel;

  @override
  Widget build(BuildContext context) {
    if (count == 0 && zeroLabel == null) return const SizedBox.shrink();
    if (count == 0) {
      return Text(
        zeroLabel!,
        style: AppTextStyles.captionSm.copyWith(
          color: AppColors.textSecondary,
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: RentCarColors.primary,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$count',
        style: AppTextStyles.labelSm.copyWith(color: Colors.white),
      ),
    );
  }
}
