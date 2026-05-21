import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Brand colors (direct port of CSS variables) ───────────────────────────────
class RqwstColors {
  static const brand    = Color(0xFF35B54B);
  static const brand2   = Color(0xFF22913A);
  static const brandL   = Color(0x2435B54B); // rgba(53,181,75,.14)
  static const sky      = Color(0xFF0EA5E9);
  static const skyL     = Color(0x1F0EA5E9);
  static const amber    = Color(0xFFF59E0B);
  static const amberL   = Color(0x1FF59E0B);
  static const rose     = Color(0xFFF43F5E);
  static const roseL    = Color(0x1FF43F5E);
  static const slate    = Color(0xFF64748B);
  static const slateL   = Color(0x1A64748B);
  static const invert   = Color(0xFF6366F1);
  static const invertL  = Color(0x1A6366F1);
}

// ── Light theme ───────────────────────────────────────────────────────────────
final lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    primary: RqwstColors.brand,
    secondary: RqwstColors.invert,
    surface: const Color(0xFFFFFFFF),
    surfaceContainerHighest: const Color(0xFFF1F5F9),
  ),
  scaffoldBackgroundColor: const Color(0xFFF8FAFC),
  textTheme: GoogleFonts.cairoTextTheme().apply(
    bodyColor: const Color(0xFF0F172A),
    displayColor: const Color(0xFF0F172A),
  ),
  cardTheme: CardTheme(
    color: Colors.white,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: const BorderSide(color: Color(0x120F172A)),
    ),
    margin: EdgeInsets.zero,
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFFF1F5F9),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0x120F172A), width: 1.5),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0x120F172A), width: 1.5),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: RqwstColors.brand, width: 1.5),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: RqwstColors.brand,
      foregroundColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      textStyle: GoogleFonts.cairo(fontWeight: FontWeight.w700, fontSize: 14),
    ),
  ),
  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: Colors.white,
    indicatorColor: RqwstColors.brandL,
    labelTextStyle: WidgetStateProperty.resolveWith((s) =>
      GoogleFonts.cairo(fontSize: 10, fontWeight: FontWeight.w700)),
  ),
);

// ── Dark theme ────────────────────────────────────────────────────────────────
final darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    primary: RqwstColors.brand,
    secondary: RqwstColors.invert,
    surface: const Color(0xFF111827),
    surfaceContainerHighest: const Color(0xFF1E2840),
  ),
  scaffoldBackgroundColor: const Color(0xFF0A0F1E),
  textTheme: GoogleFonts.cairoTextTheme().apply(
    bodyColor: const Color(0xFFF0F6FF),
    displayColor: const Color(0xFFF0F6FF),
  ),
  cardTheme: CardTheme(
    color: const Color(0xFF111827),
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: const BorderSide(color: Color(0x0FFFFFFF)),
    ),
    margin: EdgeInsets.zero,
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF1E2840),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0x0FFFFFFF), width: 1.5),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0x0FFFFFFF), width: 1.5),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: RqwstColors.brand, width: 1.5),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: RqwstColors.brand,
      foregroundColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      textStyle: GoogleFonts.cairo(fontWeight: FontWeight.w700, fontSize: 14),
    ),
  ),
  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: const Color(0xFF111827),
    indicatorColor: RqwstColors.brandL,
    labelTextStyle: WidgetStateProperty.resolveWith((s) =>
      GoogleFonts.cairo(fontSize: 10, fontWeight: FontWeight.w700)),
  ),
);
