import 'package:flutter/material.dart';

class AppColors {
  // Surface hierarchy
  static const Color surface = Color(0xFF0E150F);
  static const Color surfaceDim = Color(0xFF0E150F);
  static const Color surfaceContainerLowest = Color(0xFF09100A);
  static const Color surfaceContainerLow = Color(0xFF161D17);
  static const Color surfaceContainer = Color(0xFF1A211B);
  static const Color surfaceContainerHigh = Color(0xFF242C25);
  static const Color surfaceContainerHighest = Color(0xFF2F372F);
  static const Color surfaceBright = Color(0xFF333B34);
  static const Color surfaceVariant = Color(0xFF2F372F);

  // Primary
  static const Color primary = Color(0xFF54E98A);
  static const Color primaryContainer = Color(0xFF2ECC71);
  static const Color primaryFixed = Color(0xFF6BFE9C);
  static const Color primaryFixedDim = Color(0xFF4AE183);
  static const Color onPrimary = Color(0xFF003919);
  static const Color onPrimaryContainer = Color(0xFF005027);
  static const Color inversePrimary = Color(0xFF006D37);
  static const Color surfaceTint = Color(0xFF4AE183);

  // Secondary
  static const Color secondary = Color(0xFF9AD4A5);
  static const Color secondaryContainer = Color(0xFF19512D);
  static const Color secondaryFixed = Color(0xFFB5F1C0);
  static const Color secondaryFixedDim = Color(0xFF9AD4A5);
  static const Color onSecondary = Color(0xFF003919);
  static const Color onSecondaryContainer = Color(0xFF89C294);

  // Tertiary
  static const Color tertiary = Color(0xFFFFC0AC);
  static const Color tertiaryContainer = Color(0xFFFF9875);
  static const Color tertiaryFixed = Color(0xFFFFDBD0);
  static const Color tertiaryFixedDim = Color(0xFFFFB59D);
  static const Color onTertiary = Color(0xFF5B1A02);
  static const Color onTertiaryContainer = Color(0xFF772E14);

  // On-surface
  static const Color onSurface = Color(0xFFDCE5DA);
  static const Color onSurfaceVariant = Color(0xFFBBCBBB);
  static const Color inverseSurface = Color(0xFFDCE5DA);
  static const Color inverseOnSurface = Color(0xFF2B322B);

  // Background
  static const Color background = Color(0xFF0E150F);
  static const Color onBackground = Color(0xFFDCE5DA);

  // Error
  static const Color error = Color(0xFFFFB4AB);
  static const Color errorContainer = Color(0xFF93000A);
  static const Color onError = Color(0xFF690005);
  static const Color onErrorContainer = Color(0xFFFFDAD6);

  // Outline
  static const Color outline = Color(0xFF869486);
  static const Color outlineVariant = Color(0xFF3D4A3E);

  // Gradient for primary CTA
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryContainer],
    transform: GradientRotation(135 * 3.14159 / 180),
  );
}
