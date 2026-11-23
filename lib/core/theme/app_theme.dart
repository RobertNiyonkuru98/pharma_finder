import 'package:flutter/material.dart';

/// Design tokens sampled directly from the MediMatch Figma exports.
///
/// Every screen reads from here. No hardcoded colours anywhere else, or five
/// people produce five slightly different greens.
class AppColors {
  AppColors._();

  static const primary = Color(0xFF016960);
  static const primaryDark = Color(0xFF00645B);
  static const primaryTint = Color(0xFFD8F7F8);
  static const primaryTintAlt = Color(0xFFE3F7FA);
  static const lavender = Color(0xFFEFF0FD);
  static const lavenderDeep = Color(0xFFE6E9FB);
  static const danger = Color(0xFFCE5150);
  static const dangerTint = Color(0xFFFFDAD6);
  static const surface = Color(0xFFFFFFFF);
  static const background = Color(0xFFF7F7FB);
  static const ink = Color(0xFF161325);
  static const muted = Color(0xFF6B7280);
  static const border = Color(0xFFE9E6F5);
}

class AppSpacing {
  AppSpacing._();

  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const radius = 16.0;
}

ThemeData buildAppTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: Brightness.light,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme.copyWith(primary: AppColors.primary),
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.ink,
      elevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radius),
        side: const BorderSide(color: AppColors.border),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    textTheme: const TextTheme(
      headlineSmall: TextStyle(
        color: AppColors.ink,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w600),
      bodyMedium: TextStyle(color: AppColors.ink),
      bodySmall: TextStyle(color: AppColors.muted),
    ),
  );
}

/// Dark counterpart used when the saved theme preference is `dark`.
///
/// Screens that paint explicit light cards keep their brand colours; Material
/// surfaces, dialogs and inputs switch to the dark scheme.
ThemeData buildDarkAppTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: Brightness.dark,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: scheme,
    scaffoldBackgroundColor: const Color(0xFF111318),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF111318),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF1B1F2A),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radius),
        side: const BorderSide(color: Color(0xFF2A303C)),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
  );
}
