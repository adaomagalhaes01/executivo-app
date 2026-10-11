import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

/// A settings tile with a toggle switch at the trailing end.
///
/// The [onChanged] callback receives the new switch value.
/// Use [value] to control the current state.
class SettingsSwitchTile extends StatelessWidget {
  const SettingsSwitchTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.value,
    this.onChanged,
    this.iconColor,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
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

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm + 2,
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
                    style: AppTextStyles.caption.copyWith(color: subtitleColor),
                  ),
                ],
              ],
            ),
          ),

          // Switch
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
