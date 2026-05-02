import 'package:flutter/material.dart';

class WordieTheme {
  static const Color background = Color(0xFF1A1A18);
  static const Color card = Color(0xFF242420);
  static const Color cardAlt = Color(0xFF2D2D28);
  static const Color border = Color(0xFF3C3B34);
  static const Color textPrimary = Color(0xFFF5F1E8);
  static const Color textMuted = Color(0xFFB7B2A8);
  static const Color brandGreen = Color(0xFF52B788);

  static ThemeData get theme {
    const base = TextTheme(
      displaySmall: TextStyle(
        fontFamily: 'Playfair Display',
        fontSize: 42,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.2,
        color: textPrimary,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'Playfair Display',
        fontSize: 30,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.6,
        color: textPrimary,
      ),
      headlineSmall: TextStyle(
        fontFamily: 'Playfair Display',
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: textPrimary,
      ),
      titleLarge: TextStyle(
        fontFamily: 'Playfair Display',
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: textPrimary,
      ),
      titleMedium: TextStyle(
        fontFamily: 'DM Sans',
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: textPrimary,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'DM Sans',
        fontSize: 16,
        height: 1.45,
        color: textPrimary,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'DM Sans',
        fontSize: 14,
        height: 1.45,
        color: textMuted,
      ),
      labelLarge: TextStyle(
        fontFamily: 'DM Sans',
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: textPrimary,
      ),
      labelMedium: TextStyle(
        fontFamily: 'DM Sans',
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
        shadowColor: Colors.black.withValues(alpha: 0.35),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
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
