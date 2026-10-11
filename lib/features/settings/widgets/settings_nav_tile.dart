import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

/// A navigation-style settings tile with icon, title, optional subtitle,
/// and a trailing chevron indicating it opens a new screen.
class SettingsNavTile extends StatelessWidget {
  const SettingsNavTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.trailing,
    this.iconColor,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveIconColor = iconColor ??
        (isDark ? AppColors.textOnDarkSecondary : AppColors.iconDefault);
    final titleColor =
        isDark ? AppColors.textOnDark : AppColors.textPrimary;
    final subtitleColor =
        isDark ? AppColors.textOnDarkSecondary : AppColors.textSecondary;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            // Icon container
            Container(
              width: AppSpacing.xl,
              height: AppSpacing.xl,
              decoration: BoxDecoration(
                color: effectiveIconColor.withAlpha(18),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: AppSpacing.iconSize,
                color: effectiveIconColor,
              ),
            ),

            const SizedBox(width: AppSpacing.md),

            // Title + subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.titleSm.copyWith(color: titleColor),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style:
                          AppTextStyles.caption.copyWith(color: subtitleColor),
                    ),
                  ],
                ],
              ),
            ),

            // Trailing
            trailing ??
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: isDark
                      ? AppColors.textOnDarkSecondary
                      : AppColors.iconSubtle,
                ),
          ],
        ),
      ),
    );
  }
}
