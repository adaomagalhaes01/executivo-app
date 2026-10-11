import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_text_styles.dart';

/// Semantic tone of an [ExecutiveBadge].
enum ExecutiveBadgeTone { neutral, success, warning, danger, info, primary }

/// Small pill used for statuses, counts and category labels.
///
/// Rental and listing states are rendered with this so "Pendente",
/// "Confirmada", "Ativo"… always look the same across the module.
class ExecutiveBadge extends StatelessWidget {
  const ExecutiveBadge({
    super.key,
    required this.label,
    this.tone = ExecutiveBadgeTone.neutral,
    this.icon,
    this.dense = false,
  });

  /// Convenience factory that resolves the tone from a semantic status name.
  factory ExecutiveBadge.status(String label, {required bool isPositive}) {
    return ExecutiveBadge(
      label: label,
      tone: isPositive
          ? ExecutiveBadgeTone.success
          : ExecutiveBadgeTone.neutral,
    );
  }

  final String label;
  final ExecutiveBadgeTone tone;
  final IconData? icon;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final foreground = _foreground(tone, isDark);
    final background = _background(tone, isDark);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 8 : 10,
        vertical: dense ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppRadius.circularChip,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: dense ? 11 : 13, color: foreground),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: (dense ? AppTextStyles.captionSm : AppTextStyles.labelSm)
                .copyWith(
              color: foreground,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  static Color _foreground(ExecutiveBadgeTone tone, bool isDark) {
    return switch (tone) {
      ExecutiveBadgeTone.success => isDark
          ? const Color(0xFF5BE49B)
          : const Color(0xFF1B7F47),
      ExecutiveBadgeTone.warning => isDark
          ? const Color(0xFFFFC24B)
          : const Color(0xFF9A5B00),
      ExecutiveBadgeTone.danger => isDark
          ? const Color(0xFFFF8A8E)
          : AppColors.error,
      ExecutiveBadgeTone.info => isDark
          ? const Color(0xFF7CD4FD)
          : const Color(0xFF0369A1),
      ExecutiveBadgeTone.primary => AppColors.primary,
      ExecutiveBadgeTone.neutral => isDark
          ? AppColors.textOnDarkSecondary
          : AppColors.textSecondary,
    };
  }

  static Color _background(ExecutiveBadgeTone tone, bool isDark) {
    return switch (tone) {
      ExecutiveBadgeTone.success =>
        isDark ? const Color(0x1F5BE49B) : const Color(0xFFE6F6ED),
      ExecutiveBadgeTone.warning =>
        isDark ? const Color(0x24FFC24B) : const Color(0xFFFFF4E0),
      ExecutiveBadgeTone.danger =>
        isDark ? const Color(0x24FF8A8E) : const Color(0xFFFDECEC),
      ExecutiveBadgeTone.info =>
        isDark ? const Color(0x247CD4FD) : const Color(0xFFE5F4FE),
      ExecutiveBadgeTone.primary => AppColors.primary.withAlpha(isDark ? 32 : 22),
      ExecutiveBadgeTone.neutral => isDark
          ? AppColors.darkElevated
          : AppColors.surfaceVariant,
    };
  }
}