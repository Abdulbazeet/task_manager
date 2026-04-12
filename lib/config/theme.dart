import 'package:flutter/material.dart';

// final Color primaryColor = const Color()

final seedColor = const Color(0xFF00E5C0);
final primaryColor = const Color(0xFF00E5C0);
final secondaryColor = const Color(0xFF00BFA5);
// final backgroundColor = const Color(0xFFF8FAFC);
final Color bgLight = Color.fromARGB(255, 215, 214, 216);
final Color bgDark = Color(0xFF0F0E14);
final Color textLight = Colors.black54;
final Color backGWhite = Colors.white;

class AppThemes {
  static ThemeData lightTheme() {
    final scheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      primary: primaryColor,
      secondary: secondaryColor,
      surface: bgLight,

      brightness: Brightness.light,
     // onSurface: backGWhite,
    );
    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      textTheme: TextTheme(
        headlineSmall: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w800,
        ),
        titleMedium: TextStyle(
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
}
