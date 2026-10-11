import 'package:flutter/material.dart';

/// EXECUTIVO Design System — Color Palette
///
/// All brand colors are defined here as static constants.
/// Use these references everywhere instead of hardcoded hex values.
abstract final class AppColors {
  // ─── Brand ────────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFFFF2B71);
  static const Color primaryDark = Color(0xFFD61858);
  static const Color primaryLight = Color(0xFFFFE0E9);
  static const Color primaryContainer = Color(0xFFFFF0F5);

  // ─── Dark Backgrounds ─────────────────────────────────────────────────────
  static const Color dark = Color(0xFF121212);
  static const Color darkSecondary = Color(0xFF161616);
  static const Color darkSurface = Color(0xFF1C1C1E);
  static const Color darkElevated = Color(0xFF2C2C2E);

  // ─── Light Backgrounds ────────────────────────────────────────────────────
  static const Color backgroundLight = Color(0xFFF7F8FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF0F2F5);

  // ─── Text ─────────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF101820);
  static const Color textSecondary = Color(0xFF667085);
  static const Color textTertiary = Color(0xFF98A2B3);
  static const Color textDisabled = Color(0xFFD0D5DD);

  // ─── Text on Dark ─────────────────────────────────────────────────────────
  static const Color textOnDark = Color(0xFFFFFFFF);
  static const Color textOnDarkSecondary = Color(0xFFB0BEC5);

  // ─── Borders & Dividers ───────────────────────────────────────────────────
  static const Color border = Color(0xFFE6E8EC);
  static const Color borderLight = Color(0xFFF2F4F7);
  static const Color divider = Color(0xFFEEF0F4);

  // ─── Semantic ─────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF35C978);
  static const Color error = Color(0xFFE5484D);
  static const Color warning = Color(0xFFF79009);
  static const Color info = Color(0xFF0EA5E9);

  // ─── Icon Tint ────────────────────────────────────────────────────────────
  static const Color iconDefault = Color(0xFF667085);
  static const Color iconSubtle = Color(0xFF98A2B3);

  // ─── Shadow ───────────────────────────────────────────────────────────────
  static const Color shadow = Color(0x0F101820);
  static const Color shadowMedium = Color(0x1A101820);
}
