import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color background = Color(0xFF010A1A);
  static const Color surface = Color(0xFF111D2D);
  static const Color primary = Color(0xFFF5A623); // Electric Gold
  static const Color secondary = Color(0xFFFF5E5E); // Vivid Coral
  static const Color accent = Color(0xFF00E5FF); // Sky Cyan
  static const Color textBody = Colors.white;
  static const Color textMuted = Color(0xFFA0AEC0);
  
  // Premium square colors
  static const Color doubleLetter = Color(0xFF2D3748);
  static const Color tripleLetter = Color(0xFF4A5568);
  static const Color doubleWord = Color(0xFFFF9F1C);
  static const Color tripleWord = Color(0xFFFF4D4D);
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        background: AppColors.background,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.playfairDisplay(
          fontSize: 48,
          fontWeight: FontWeight.bold,
          color: AppColors.textBody,
        ),
        displayMedium: GoogleFonts.playfairDisplay(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.textBody,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 18,
          color: AppColors.textBody,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 16,
          color: AppColors.textBody,
        ),
        labelLarge: GoogleFonts.jetBrainsMono(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.textMuted,
        ),
      ),
    );
  }
}
