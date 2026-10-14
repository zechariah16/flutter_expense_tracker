import 'package:flutter/material.dart';

import '../constants/app_constants.dart';

class AppColors {
  AppColors._();

  static const Color navy = Color(0xFF0F1B2D);
  static const Color accent = Color(0xFF3B5BDB);

  static Color income(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF4CD08A)
          : const Color(0xFF1E8E5A);

  static Color expense(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFFFF8080)
          : const Color(0xFFD64545);
}

class AppTheme {
  AppTheme._();

  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isLight = brightness == Brightness.light;
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.accent,
      brightness: brightness,
    );
    final base = ThemeData(useMaterial3: true, colorScheme: scheme);
    final scaffoldColor = isLight ? const Color(0xFFF6F7FB) : scheme.surface;

    return base.copyWith(
      scaffoldBackgroundColor: scaffoldColor,
      textTheme: base.textTheme.apply(
        bodyColor: isLight ? AppColors.navy : null,
        displayColor: isLight ? AppColors.navy : null,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scaffoldColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: base.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: isLight ? AppColors.navy : scheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: isLight ? Colors.white : scheme.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.field),
          ),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
    );
  }

  /// Shared look for text fields (kept here instead of per-widget styling).
  static InputDecoration fieldDecoration({
    String? labelText,
    String? hintText,
    String? prefixText,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixText: prefixText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.field),
        borderSide: BorderSide.none,
      ),
    );
  }
}
