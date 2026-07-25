import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'cortex_colors.dart';

abstract final class CortexTheme {
  static ThemeData dark() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: CortexColors.background,
      colorScheme: const ColorScheme.dark(
        surface: CortexColors.surface,
        primary: CortexColors.accent,
        secondary: CortexColors.secondaryGlow,
        error: CortexColors.danger,
        onPrimary: CortexColors.background,
        onSecondary: CortexColors.background,
        onSurface: CortexColors.text,
        onError: CortexColors.background,
      ),
    );

    final inter = GoogleFonts.interTextTheme(base.textTheme).apply(
      bodyColor: CortexColors.text,
      displayColor: CortexColors.text,
    );

    return base.copyWith(
      textTheme: inter,
      appBarTheme: AppBarTheme(
        backgroundColor: CortexColors.background,
        foregroundColor: CortexColors.text,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: GoogleFonts.orbitron(
          color: CortexColors.accent,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: CortexColors.accent,
        foregroundColor: CortexColors.background,
        elevation: 0,
      ),
      dividerTheme: const DividerThemeData(
        color: CortexColors.hairline,
        thickness: 1,
        space: 1,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: CortexColors.surface,
        selectedItemColor: CortexColors.accent,
        unselectedItemColor: CortexColors.muted,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: GoogleFonts.jetBrainsMono(fontSize: 11),
        unselectedLabelStyle: GoogleFonts.jetBrainsMono(fontSize: 11),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: CortexColors.elevated,
        contentTextStyle: GoogleFonts.inter(color: CortexColors.text),
        actionTextColor: CortexColors.accent,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: CortexColors.elevated,
        titleTextStyle: GoogleFonts.orbitron(
          color: CortexColors.text,
          fontSize: 16,
          letterSpacing: 1.2,
        ),
        contentTextStyle: GoogleFonts.inter(color: CortexColors.text),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: CortexColors.hairline),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: CortexColors.surface,
        hintStyle: GoogleFonts.inter(color: CortexColors.muted),
        labelStyle: GoogleFonts.inter(color: CortexColors.muted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: CortexColors.hairline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: CortexColors.hairline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: CortexColors.accent),
        ),
      ),
      cardTheme: CardThemeData(
        color: CortexColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: CortexColors.hairline),
        ),
      ),
    );
  }

  static TextStyle orbitron({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w600,
    Color color = CortexColors.text,
    double letterSpacing = 1.2,
  }) =>
      GoogleFonts.orbitron(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
      );

  static TextStyle mono({
    double fontSize = 12,
    FontWeight fontWeight = FontWeight.w400,
    Color color = CortexColors.muted,
  }) =>
      GoogleFonts.jetBrainsMono(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
      );

  static TextStyle body({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    Color color = CortexColors.text,
  }) =>
      GoogleFonts.inter(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
      );
}
