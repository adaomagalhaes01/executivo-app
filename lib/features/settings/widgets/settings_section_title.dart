import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

/// Small all-caps section header used above each group in the settings screen.
class SettingsSectionTitle extends StatelessWidget {
  const SettingsSectionTitle({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.md,
        bottom: AppSpacing.sm,
        top: AppSpacing.sm,
      ),
      child: Text(
        title.toUpperCase(),
        style: AppTextStyles.sectionHeader.copyWith(
          color: isDark ? AppColors.textOnDarkSecondary : AppColors.textTertiary,
        ),
      ),
    );
  }
}
