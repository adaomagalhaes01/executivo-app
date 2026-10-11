import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_theme.dart';

/// Colours and Material theme used only by the Rent a Car service.
abstract final class RentCarColors {
  static const Color primary = Color(0xFFE8000D);
}

abstract final class RentCarTheme {
  static ThemeData get light => _from(AppTheme.light);

  static Widget wrap(Widget child) => Theme(data: light, child: child);

  static ThemeData _from(ThemeData base) {
    final scheme = base.colorScheme.copyWith(
      brightness: Brightness.light,
      primary: RentCarColors.primary,
      onPrimary: Colors.white,
      secondary: RentCarColors.primary,
      onSecondary: Colors.white,
      surface: Colors.white,
      onSurface: Colors.black,
      surfaceContainerHighest: AppColors.surfaceVariant,
      onSurfaceVariant: AppColors.textSecondary,
      outline: AppColors.border,
    );

    return base.copyWith(
      brightness: Brightness.light,
      colorScheme: scheme,
      scaffoldBackgroundColor: Colors.white,
      textTheme: base.textTheme.apply(
        bodyColor: Colors.black,
        displayColor: Colors.black,
      ),
      iconTheme: base.iconTheme.copyWith(color: Colors.black),
      appBarTheme: base.appBarTheme.copyWith(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: base.appBarTheme.titleTextStyle?.copyWith(
          color: Colors.black,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: base.elevatedButtonTheme.style?.copyWith(
          backgroundColor: const WidgetStatePropertyAll(RentCarColors.primary),
          foregroundColor: const WidgetStatePropertyAll(Colors.white),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: base.filledButtonTheme.style?.copyWith(
          backgroundColor: const WidgetStatePropertyAll(RentCarColors.primary),
          foregroundColor: const WidgetStatePropertyAll(Colors.white),
        ),
      ),
    );
  }
}
