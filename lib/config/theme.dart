import 'package:flutter/material.dart';

final seedColor = const Color(0xFF00E5C0);
final primaryColor = const Color(0xFF00E5C0);
final secondaryColor = const Color(0xFF00BFA5);
final Color bgLight = Color.fromARGB(255, 215, 214, 216);
final Color bgDark = Color(0xFF0F0E14);
final Color textLight = Colors.black54;
final Color textDark = Colors.white70;

class AppThemes {
  static ThemeData lightTheme() {
    final scheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      primary: primaryColor,
      secondary: secondaryColor,
      surface: bgLight,
      brightness: Brightness.light,
    );
    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
      ),
      cardColor: Colors.white,
      textTheme: TextTheme(
        headlineSmall: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w800,
        ),
        titleMedium: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: TextStyle(color: textLight, fontSize: 18),
        bodyMedium: TextStyle(color: textLight, fontSize: 16),
        bodySmall: TextStyle(color: textLight, fontSize: 14),
        labelLarge: TextStyle(
          color: textLight,
          fontSize: 12,
          fontWeight: FontWeight.normal,
        ),
      ),
    );
  }

  static ThemeData darkTheme() {
    final scheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      primary: primaryColor,
      secondary: secondaryColor,
      surface: bgDark,
      brightness: Brightness.dark,
    );
    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      scaffoldBackgroundColor: bgDark,
      appBarTheme: AppBarTheme(
        backgroundColor: bgDark,
        surfaceTintColor: bgDark,
        elevation: 0,
      ),
      cardColor: const Color(0xFF1A1A20),
      textTheme: TextTheme(
        headlineSmall: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
        ),
        titleMedium: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: TextStyle(color: textDark, fontSize: 18),
        bodyMedium: TextStyle(color: textDark, fontSize: 16),
        bodySmall: TextStyle(color: textDark, fontSize: 14),
        labelLarge: TextStyle(
          color: textDark,
          fontSize: 12,
          fontWeight: FontWeight.normal,
        ),
      ),
    );
  }
}
