import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

/// Shared app bar for the EXECUTIVO design system.
///
/// Implements [PreferredSizeWidget] so it can be used directly
/// as [Scaffold.appBar]. Defaults to no elevation, transparent
/// surface tint, and Inter typography.
class ExecutiveAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ExecutiveAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.actions,
    this.showBack = true,
    this.backgroundColor,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final List<Widget>? actions;
  final bool showBack;
  final Color? backgroundColor;

  @override
  Size get preferredSize =>
      Size.fromHeight(subtitle != null ? 72 : kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final canPop = Navigator.canPop(context);
    final effectiveBg = backgroundColor ??
        (isDark ? AppColors.darkSecondary : AppColors.backgroundLight);

    return AppBar(
      backgroundColor: effectiveBg,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      leading: leading ??
          (showBack && canPop
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                  onPressed: () => Navigator.maybePop(context),
                  tooltip: 'Voltar',
                )
              : null),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: AppTextStyles.titleLg),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: AppTextStyles.bodySm.copyWith(
                color: isDark
                    ? AppColors.textOnDarkSecondary
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
      actions: actions != null
          ? [
              ...actions!,
              const SizedBox(width: AppSpacing.sm),
            ]
          : null,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Divider(
          height: 1,
          thickness: 1,
          color: isDark ? AppColors.darkElevated : AppColors.border,
        ),
      ),
    );
  }
}
