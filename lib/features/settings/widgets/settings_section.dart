import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';

/// Container that wraps a list of settings tiles inside a bordered card.
///
/// Renders each child separated by a light divider, with no excess padding.
class SettingsSection extends StatelessWidget {
  const SettingsSection({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.darkElevated : AppColors.border;
    final bgColor = isDark ? AppColors.darkSurface : AppColors.surface;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppRadius.circularLg,
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1)
              Divider(
                height: 1,
                thickness: 1,
                color: isDark ? AppColors.darkElevated : AppColors.divider,
                indent: AppSpacing.md + AppSpacing.xl + AppSpacing.sm,
              ),
          ],
        ],
      ),
    );
  }
}
