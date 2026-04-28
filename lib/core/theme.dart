import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF7F7F7);
  static const Color primary = Color(0xFF121212); // Deep Black for text
  static const Color secondary = Color(0xFFAC87ED); // Soft Purple
  static const Color accent = Color(0xFF5E90E0); // Soft Blue
  static const Color textBody = Color(0xFF121212);
  static const Color textMuted = Color(0xFF757575);
  
  // Design shapes
  static const Color green = Color(0xFF63A160);
  static const Color yellow = Color(0xFFF2C144);
  static const Color orange = Color(0xFFF39233);
  
  // Premium square colors
  static const Color doubleLetter = Color(0xFFD3E6F5);
  static const Color tripleLetter = Color(0xFFB0D4F1);
  static const Color doubleWord = Color(0xFFF5D3D3);
  static const Color tripleWord = Color(0xFFF1B0B0);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        onSurface: AppColors.primary,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.frankRuhlLibre(
          fontSize: 48,
          fontWeight: FontWeight.w900,
          color: AppColors.textBody,
        ),
        displayMedium: GoogleFonts.frankRuhlLibre(
          fontSize: 32,
          fontWeight: FontWeight.w900,
          color: AppColors.textBody,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: AppColors.textBody,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 16,
          color: AppColors.textBody,
        ),
        labelLarge: GoogleFonts.jetBrainsMono(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppColors.textMuted,
          letterSpacing: 2,
        ),
      ),
    );
  }
}
