import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import 'executive_button.dart';

enum ExecutiveStateKind { loading, empty, error }

/// Loading / empty / error placeholder for any list or detail screen.
///
/// Keeping the three states in one place means the Rent a Car screens never
/// invent their own spinner or "nothing here" artwork.
class ExecutiveStateView extends StatelessWidget {
  /// Spinner with an optional caption.
  const ExecutiveStateView.loading({
    super.key,
    this.message = 'A carregar…',
  })  : kind = ExecutiveStateKind.loading,
        icon = null,
        title = null,
        actionLabel = null,
        onAction = null;

  /// "Nothing here yet" panel.
  const ExecutiveStateView.empty({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
  }) : kind = ExecutiveStateKind.empty;

  /// Failure panel with a retry affordance.
  const ExecutiveStateView.error({
    super.key,
    this.title = 'Algo correu mal',
    this.message,
    this.actionLabel = 'Tentar novamente',
    this.onAction,
  }) : kind = ExecutiveStateKind.error,
        icon = null;

  final ExecutiveStateKind kind;
  final IconData? icon;
  final String? title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textOnDark : AppColors.textPrimary;
    final mutedColor =
        isDark ? AppColors.textOnDarkSecondary : AppColors.textSecondary;

    if (kind == ExecutiveStateKind.loading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: AppColors.primary,
                ),
              ),
              if ((message ?? '').isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySm.copyWith(color: mutedColor),
                ),
              ],
            ],
          ),
        ),
      );
    }

    final isError = kind == ExecutiveStateKind.error;
    final accent = isError ? AppColors.error : AppColors.primary;
    final glyph =
        icon ?? (isError ? Icons.error_outline_rounded : Icons.inbox_outlined);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: accent.withAlpha(isDark ? 30 : 16),
                shape: BoxShape.circle,
              ),
              child: Icon(glyph, size: 32, color: accent),
            ),
            if ((title ?? '').isNotEmpty) ...[
              const SizedBox(height: AppSpacing.lg),
              Text(
                title!,
                textAlign: TextAlign.center,
                style: AppTextStyles.titleLg.copyWith(color: textColor),
              ),
            ],
            if ((message ?? '').isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMd.copyWith(color: mutedColor),
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: 230,
                child: ExecutiveButton(
                  label: actionLabel!,
                  onPressed: onAction,
                  variant: ExecutiveButtonVariant.outlined,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}