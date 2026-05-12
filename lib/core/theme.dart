import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color primary = Color(0xFF570013);
  static const Color primaryContainer = Color(0xFF800020);
  static const Color secondary = Color(0xFF7B5800);
  static const Color background = Color(0xFFFBF9F5);
  static const Color surface = Color(0xFFFBF9F5);
  static const Color surfaceLow = Color(0xFFF5F3EF);
  static const Color onSurface = Color(0xFF1B1C1A);
  static const Color onSurfaceVariant = Color(0xFF584141);
}

class FynBridalTheme {
  static final ThemeData theme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.background,
    primaryColor: AppColors.primary,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.surface,
    ),
    textTheme: GoogleFonts.manropeTextTheme().copyWith(
      displayLarge: GoogleFonts.notoSerif(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 48),
      displayMedium: GoogleFonts.notoSerif(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 36),
      headlineMedium: GoogleFonts.notoSerif(color: AppColors.primary, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
      labelSmall: GoogleFonts.manrope(color: AppColors.secondary, letterSpacing: 2.0, fontWeight: FontWeight.bold, fontSize: 10),
    ),
  );
}
