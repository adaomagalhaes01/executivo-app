import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

/// Button variant for [ExecutiveButton].
enum ExecutiveButtonVariant { filled, outlined, ghost }

/// Shared button component for the EXECUTIVO design system.
///
/// Supports [filled] (primary), [outlined] (secondary), and [ghost] (text)
/// variants. Automatically applies disabled state styling.
class ExecutiveButton extends StatelessWidget {
  const ExecutiveButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = ExecutiveButtonVariant.filled,
    this.leadingIcon,
    this.trailingIcon,
    this.isLoading = false,
    this.expand = true,
    this.height = 52,
  });

  final String label;
  final VoidCallback? onPressed;
  final ExecutiveButtonVariant variant;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final bool isLoading;
  final bool expand;
  final double height;

  bool get _isDisabled => onPressed == null || isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: expand ? double.infinity : null,
      height: height,
      child: switch (variant) {
        ExecutiveButtonVariant.filled => _FilledButton(
            label: label,
            onPressed: _isDisabled ? null : onPressed,
            leadingIcon: leadingIcon,
            trailingIcon: trailingIcon,
            isLoading: isLoading,
          ),
        ExecutiveButtonVariant.outlined => _OutlinedButton(
            label: label,
            onPressed: _isDisabled ? null : onPressed,
            leadingIcon: leadingIcon,
            trailingIcon: trailingIcon,
            isLoading: isLoading,
          ),
        ExecutiveButtonVariant.ghost => _GhostButton(
            label: label,
            onPressed: _isDisabled ? null : onPressed,
            leadingIcon: leadingIcon,
            trailingIcon: trailingIcon,
            isLoading: isLoading,
          ),
      },
    );
  }
}

// ─── Filled ───────────────────────────────────────────────────────────────────

class _FilledButton extends StatelessWidget {
  const _FilledButton({
    required this.label,
    this.onPressed,
    this.leadingIcon,
    this.trailingIcon,
    required this.isLoading,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        disabledBackgroundColor: AppColors.primaryLight,
        disabledForegroundColor: AppColors.primaryDark.withAlpha(100),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.circularButton,
        ),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      ),
      child: _ButtonContent(
        label: label,
        leadingIcon: leadingIcon,
        trailingIcon: trailingIcon,
        isLoading: isLoading,
        textStyle: AppTextStyles.buttonLg.copyWith(color: Colors.white),
        loadingColor: Colors.white,
      ),
    );
  }
}

// ─── Outlined ─────────────────────────────────────────────────────────────────

class _OutlinedButton extends StatelessWidget {
  const _OutlinedButton({
    required this.label,
    this.onPressed,
    this.leadingIcon,
    this.trailingIcon,
    required this.isLoading,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.textOnDark : AppColors.textPrimary;

    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: textColor,
        side: BorderSide(
          color: isDark ? AppColors.darkElevated : AppColors.border,
          width: 1.5,
        ),
        disabledForegroundColor: AppColors.textDisabled,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.circularButton,
        ),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      ),
      child: _ButtonContent(
        label: label,
        leadingIcon: leadingIcon,
        trailingIcon: trailingIcon,
        isLoading: isLoading,
        textStyle: AppTextStyles.buttonLg.copyWith(color: textColor),
        loadingColor: textColor,
      ),
    );
  }
}

// ─── Ghost ────────────────────────────────────────────────────────────────────

class _GhostButton extends StatelessWidget {
  const _GhostButton({
    required this.label,
    this.onPressed,
    this.leadingIcon,
    this.trailingIcon,
    required this.isLoading,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.circularButton,
        ),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      ),
      child: _ButtonContent(
        label: label,
        leadingIcon: leadingIcon,
        trailingIcon: trailingIcon,
        isLoading: isLoading,
        textStyle: AppTextStyles.buttonLg.copyWith(color: AppColors.primary),
        loadingColor: AppColors.primary,
      ),
    );
  }
}

// ─── Shared content ───────────────────────────────────────────────────────────

class _ButtonContent extends StatelessWidget {
  const _ButtonContent({
    required this.label,
    this.leadingIcon,
    this.trailingIcon,
    required this.isLoading,
    required this.textStyle,
    required this.loadingColor,
  });

  final String label;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final bool isLoading;
  final TextStyle textStyle;
  final Color loadingColor;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: loadingColor,
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (leadingIcon != null) ...[
          Icon(leadingIcon, size: 18),
          const SizedBox(width: AppSpacing.sm),
        ],
        Text(label, style: textStyle),
        if (trailingIcon != null) ...[
          const SizedBox(width: AppSpacing.sm),
          Icon(trailingIcon, size: 18),
        ],
      ],
    );
  }
}
