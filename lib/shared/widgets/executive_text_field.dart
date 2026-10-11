import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

/// Labelled text input for the EXECUTIVO design system.
///
/// The app theme only styles the raw [TextField]; this wrapper adds the
/// field label, the optional helper/error line and the read-only variant used
/// by tappable fields that open a picker (dates, location).
class ExecutiveTextField extends StatelessWidget {
  const ExecutiveTextField({
    super.key,
    required this.label,
    this.controller,
    this.initialValue,
    this.suffixText,
    this.hint,
    this.helper,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.onTap,
    this.onChanged,
    this.onSubmitted,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.maxLength,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.textCapitalization = TextCapitalization.none,
    this.filled = true,
    this.maxLines = 1,
    this.focusNode,
  });

  final String label;
  final TextEditingController? controller;

  /// Seed content for a field the caller does not control with a controller.
  ///
  /// Mutually exclusive with [controller] — the controller wins when both are
  /// supplied.
  final String? initialValue;

  /// Static unit shown inside the field ("Kz", "km", ...).
  final String? suffixText;
  final String? hint;
  final String? helper;
  final String? errorText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;
  final TextCapitalization textCapitalization;
  final bool filled;
  final int maxLines;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasError = errorText != null && errorText!.isNotEmpty;
    final labelColor = isDark
        ? AppColors.textOnDarkSecondary
        : AppColors.textSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm, left: 2),
          child: Text(
            label,
            style: AppTextStyles.labelMd.copyWith(color: labelColor),
          ),
        ),
        TextFormField(
          controller: controller,
          initialValue: controller == null ? initialValue : null,
          focusNode: focusNode,
          onTap: onTap,
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          inputFormatters: inputFormatters,
          maxLength: maxLength,
          enabled: enabled,
          readOnly: readOnly,
          autofocus: autofocus,
          textCapitalization: textCapitalization,
          maxLines: maxLines,
          style: AppTextStyles.bodyLg.copyWith(
            color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
          ),
          cursorColor: AppColors.primary,
          decoration: InputDecoration(
            filled: filled,
            hintText: hint,
            counterText: '',
            prefixIcon: prefixIcon == null
                ? null
                : Icon(
                    prefixIcon,
                    size: 20,
                    color: labelColor,
                  ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 44,
              minHeight: 44,
            ),
            suffixIcon: suffixIcon,
            suffixText: suffixText,
            errorText: null,
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.circularInput,
              borderSide: BorderSide(
                color: hasError
                    ? AppColors.error
                    : (isDark ? AppColors.darkElevated : AppColors.border),
              ),
            ),
          ),
        ),
        if (hasError || (helper != null && helper!.isNotEmpty))
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 2),
            child: Text(
              hasError ? errorText! : helper!,
              style: AppTextStyles.captionSm.copyWith(
                color: hasError ? AppColors.error : labelColor,
              ),
            ),
          ),
      ],
    );
  }
}