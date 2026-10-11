import 'package:flutter/material.dart';

/// EXECUTIVO Design System — Border Radius Scale
///
/// Consistent rounding values used across all components.
abstract final class AppRadius {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double full = 999.0;

  // ─── Semantic aliases ─────────────────────────────────────────────────────
  static const double button = 16.0;
  static const double card = 16.0;
  static const double cardLg = 20.0;
  static const double bottomSheet = 24.0;
  static const double chip = 8.0;
  static const double input = 12.0;
  static const double logo = 20.0;

  // ─── BorderRadius helpers ─────────────────────────────────────────────────
  static BorderRadius circularSm = BorderRadius.circular(sm);
  static BorderRadius circularMd = BorderRadius.circular(md);
  static BorderRadius circularLg = BorderRadius.circular(lg);
  static BorderRadius circularXl = BorderRadius.circular(xl);
  static BorderRadius circularXxl = BorderRadius.circular(xxl);
  static BorderRadius circularFull = BorderRadius.circular(full);
  static BorderRadius circularButton = BorderRadius.circular(button);
  static BorderRadius circularCard = BorderRadius.circular(card);
  static BorderRadius circularCardLg = BorderRadius.circular(cardLg);
  static BorderRadius circularInput = BorderRadius.circular(input);
  static BorderRadius circularChip = BorderRadius.circular(chip);

  static const BorderRadius bottomSheetTop = BorderRadius.only(
    topLeft: Radius.circular(bottomSheet),
    topRight: Radius.circular(bottomSheet),
  );
}
