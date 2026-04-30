import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const background = Color(0xFFFAFAF7);
  static const surface = Color(0xFFFFFFFF);
  static const border = Color(0xFFE0DFD8);
  static const textPrimary = Color(0xFF1A1A18);
  static const textSecondary = Color(0xFF6B6B66);
  static const textMuted = Color(0xFF9B9B94);
  static const green = Color(0xFF2D6A4F);
  static const purple = Color(0xFF5E548E);
  static const yellow = Color(0xFFF0C940);
  static const navy = Color(0xFF1D3557);

  static ThemeData themeData() {
    final base = ThemeData.light();
    return base.copyWith(
      scaffoldBackgroundColor: background,
      cardColor: surface,
      canvasColor: background,
      colorScheme: ColorScheme.light(
        background: background,
        surface: surface,
        primary: green,
        secondary: purple,
        onPrimary: surface,
        onSurface: textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        surfaceTintColor: background,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.playfairDisplay(
          fontSize: 42,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: -1,
        ),
        headlineSmall: GoogleFonts.playfairDisplay(
          fontSize: 26,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        titleMedium: GoogleFonts.dmSans(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        bodyLarge: GoogleFonts.dmSans(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: textPrimary,
        ),
        bodyMedium: GoogleFonts.dmSans(
          fontSize: 14,
          fontWeight: FontWeight.w300,
          color: textSecondary,
        ),
        labelSmall: GoogleFonts.dmSans(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: textMuted,
          letterSpacing: 1.2,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: surface,
          foregroundColor: textPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: border, width: 1),
          ),
          textStyle: GoogleFonts.dmSans(
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 22),
        ),
      ),
    );
  }
}
