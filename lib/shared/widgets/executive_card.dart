import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';

/// Shared card component for the EXECUTIVO design system.
///
/// Renders a surface card with a subtle border, no elevation shadow,
/// and consistent border radius. Use [padding] to control inner spacing.
class ExecutiveCard extends StatelessWidget {
  const ExecutiveCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.cardPadding),
    this.margin = EdgeInsets.zero,
    this.borderRadius,
    this.onTap,
    this.color,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveBorderRadius = borderRadius ?? AppRadius.circularCard;
    final effectiveColor = color ??
        (isDark ? AppColors.darkSurface : AppColors.surface);

    return Padding(
      padding: margin,
      child: Material(
        color: effectiveColor,
        borderRadius: effectiveBorderRadius,
        child: InkWell(
          onTap: onTap,
          borderRadius: effectiveBorderRadius,
          splashColor: AppColors.primary.withAlpha(15),
          highlightColor: AppColors.primary.withAlpha(8),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: effectiveBorderRadius,
              border: Border.all(
                color: isDark ? AppColors.darkElevated : AppColors.border,
                width: 1,
              ),
            ),
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}
