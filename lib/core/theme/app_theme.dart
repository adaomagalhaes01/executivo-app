import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_radius.dart';
import 'app_spacing.dart';

/// EXECUTIVO Design System — Material 3 Theme Configuration
///
/// Exports [AppTheme.light] and [AppTheme.dark].
/// Both themes share the same [ColorScheme] structure and differ only
/// in surface/background colors and tonal mappings.
abstract final class AppTheme {
  // ─── Light Theme ──────────────────────────────────────────────────────────
  static ThemeData get light => _build(brightness: Brightness.light);

  // ─── Dark Theme ───────────────────────────────────────────────────────────
  static ThemeData get dark => _build(brightness: Brightness.dark);

  // ─── Builder ──────────────────────────────────────────────────────────────
  static ThemeData _build({required Brightness brightness}) {
    final isDark = brightness == Brightness.dark;

    final colorScheme = isDark ? _darkColorScheme : _lightColorScheme;

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
    );

    return base.copyWith(
      scaffoldBackgroundColor: isDark
          ? AppColors.dark
          : AppColors.backgroundLight,

      // ─── Text Theme ─────────────────────────────────────────────────────
      textTheme: GoogleFonts.interTextTheme(base.textTheme).copyWith(
        displayLarge: GoogleFonts.inter(
          fontSize: 36,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
          color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
        ),
        displayMedium: GoogleFonts.inter(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
          color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
        ),
        headlineLarge: GoogleFonts.inter(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
          color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
          color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
        ),
        titleSmall: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: isDark
              ? AppColors.textOnDarkSecondary
              : AppColors.textSecondary,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: isDark
              ? AppColors.textOnDarkSecondary
              : AppColors.textSecondary,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: isDark
              ? AppColors.textOnDarkSecondary
              : AppColors.textTertiary,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
          color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
        ),
        labelMedium: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.2,
          color: isDark
              ? AppColors.textOnDarkSecondary
              : AppColors.textSecondary,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.4,
          color: isDark
              ? AppColors.textOnDarkSecondary
              : AppColors.textTertiary,
        ),
      ),

      // ─── AppBar ─────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        backgroundColor: isDark
            ? AppColors.darkSecondary
            : AppColors.backgroundLight,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
        ),
        iconTheme: IconThemeData(
          color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
          size: AppSpacing.iconSize,
        ),
      ),

      // ─── Card ───────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        elevation: 0,
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.circularCard,
          side: BorderSide(
            color: isDark ? AppColors.darkElevated : AppColors.border,
            width: 1,
          ),
        ),
        margin: EdgeInsets.zero,
      ),

      // ─── ElevatedButton ─────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          minimumSize: const Size(double.infinity, 52),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.circularButton),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
      ),

      // ─── FilledButton ───────────────────────────────────────────────────
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(double.infinity, 52),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.circularButton),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
      ),

      // ─── OutlinedButton ─────────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: isDark
              ? AppColors.textOnDark
              : AppColors.textPrimary,
          side: BorderSide(
            color: isDark ? AppColors.darkElevated : AppColors.border,
            width: 1.5,
          ),
          minimumSize: const Size(double.infinity, 52),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.circularButton),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
      ),

      // ─── Switch ─────────────────────────────────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return isDark ? AppColors.darkElevated : AppColors.textTertiary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return isDark ? AppColors.darkSurface : AppColors.border;
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),

      // ─── InputDecoration ────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        // Inputs stay readable on the light onboarding/auth screens even
        // when the app is running with its dark theme enabled.
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.circularMd,
          borderSide: BorderSide(
            color: isDark ? AppColors.darkElevated : AppColors.border,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.circularMd,
          borderSide: BorderSide(
            color: isDark ? AppColors.darkElevated : AppColors.border,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.circularMd,
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        hintStyle: GoogleFonts.inter(
          fontSize: 14,
          color: AppColors.textTertiary,
        ),
      ),

      // ─── BottomSheet ────────────────────────────────────────────────────
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadius.bottomSheetTop,
        ),
      ),

      // ─── ListTile ───────────────────────────────────────────────────────
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        minLeadingWidth: 0,
        iconColor: isDark
            ? AppColors.textOnDarkSecondary
            : AppColors.iconDefault,
      ),

      // ─── Divider ────────────────────────────────────────────────────────
      dividerTheme: DividerThemeData(
        color: isDark ? AppColors.darkElevated : AppColors.divider,
        thickness: 1,
        space: 1,
      ),
    );
  }

  // ─── Light ColorScheme ────────────────────────────────────────────────────
  static const ColorScheme _lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: Colors.white,
    primaryContainer: AppColors.primaryContainer,
    onPrimaryContainer: AppColors.primaryDark,
    secondary: AppColors.primaryDark,
    onSecondary: Colors.white,
    secondaryContainer: AppColors.primaryLight,
    onSecondaryContainer: AppColors.primaryDark,
    tertiary: AppColors.info,
    onTertiary: Colors.white,
    tertiaryContainer: Color(0xFFE0F2FE),
    onTertiaryContainer: Color(0xFF0369A1),
    error: AppColors.error,
    onError: Colors.white,
    errorContainer: Color(0xFFFFE4E4),
    onErrorContainer: Color(0xFFC0292D),
    surface: AppColors.surface,
    onSurface: AppColors.textPrimary,
    surfaceContainerHighest: AppColors.surfaceVariant,
    onSurfaceVariant: AppColors.textSecondary,
    outline: AppColors.border,
    outlineVariant: AppColors.borderLight,
    shadow: AppColors.shadow,
    scrim: Colors.black,
    inverseSurface: AppColors.dark,
    onInverseSurface: AppColors.textOnDark,
    inversePrimary: AppColors.primaryLight,
  );

  // ─── Dark ColorScheme ─────────────────────────────────────────────────────
  static const ColorScheme _darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.primary,
    onPrimary: AppColors.dark,
    primaryContainer: AppColors.primaryDark,
    onPrimaryContainer: AppColors.primaryLight,
    secondary: AppColors.primary,
    onSecondary: AppColors.dark,
    secondaryContainer: AppColors.darkElevated,
    onSecondaryContainer: AppColors.primaryLight,
    tertiary: AppColors.info,
    onTertiary: Colors.white,
    tertiaryContainer: Color(0xFF0C4A6E),
    onTertiaryContainer: Color(0xFFBAE6FD),
    error: AppColors.error,
    onError: Colors.white,
    errorContainer: Color(0xFF7F1D1D),
    onErrorContainer: Color(0xFFFECACA),
    surface: AppColors.darkSurface,
    onSurface: AppColors.textOnDark,
    surfaceContainerHighest: AppColors.darkElevated,
    onSurfaceVariant: AppColors.textOnDarkSecondary,
    outline: AppColors.darkElevated,
    outlineVariant: AppColors.darkSecondary,
    shadow: Colors.black,
    scrim: Colors.black,
    inverseSurface: AppColors.surface,
    onInverseSurface: AppColors.textPrimary,
    inversePrimary: AppColors.primaryDark,
  );
}
