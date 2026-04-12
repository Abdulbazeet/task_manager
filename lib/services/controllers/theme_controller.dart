import 'package:flutter_riverpod/flutter_riverpod.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, bool>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<bool> {
  ThemeNotifier() : super(false); // false = light mode, true = dark mode

  void toggleTheme() {
    state = !state;
  }

  void setDarkMode(bool isDark) {
    state = isDark;
  }
}
