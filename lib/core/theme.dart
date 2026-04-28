import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color background = Color(0xFFFCFCFC); // Warmer white
  static const Color surface = Color(0xFFF5F5F5);
  static const Color primary = Color(0xFF1A1A1A); 
  static const Color secondary = Color(0xFF9E6CF5); // More vivid purple
  static const Color accent = Color(0xFF4C84F5); // More vivid blue
  static const Color textBody = Color(0xFF1A1A1A);
  static const Color textMuted = Color(0xFF888888);
  
  // Design shapes
  static const Color green = Color(0xFF4DA149); // Vivid green
  static const Color yellow = Color(0xFFF2B705); // Vivid yellow
  static const Color orange = Color(0xFFF28705); // Vivid orange
  static const Color error = Color(0xFFD32F2F); // NYT Red
  
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
