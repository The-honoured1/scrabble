import 'package:flutter/material.dart';

class WordieTheme {
  static const Color background = Color(0xFF0B1020);
  static const Color card = Color(0xFF141B34);
  static const Color cardAlt = Color(0xFF202A4D);
  static const Color border = Color(0xFF32406F);
  static const Color textPrimary = Color(0xFFF7F9FF);
  static const Color textMuted = Color(0xFFB5C0E0);
  static const Color brandGreen = Color(0xFFB7F542);

  static ThemeData get theme {
    const base = TextTheme(
      displaySmall: TextStyle(
        fontSize: 34,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.8,
        color: textPrimary,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.4,
        color: textPrimary,
      ),
      headlineSmall: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: textPrimary,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: textPrimary,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: textPrimary,
      ),
      bodyLarge: TextStyle(fontSize: 16, height: 1.45, color: textPrimary),
      bodyMedium: TextStyle(fontSize: 14, height: 1.45, color: textMuted),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: textPrimary,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
        color: textMuted,
      ),
    );

    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: brandGreen,
          brightness: Brightness.dark,
        ).copyWith(
          surface: card,
          surfaceContainerHighest: cardAlt,
          primary: brandGreen,
          onPrimary: background,
          onSurface: textPrimary,
        );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: colorScheme,
      textTheme: base,
      cardTheme: CardThemeData(
        color: card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: border),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }
}
