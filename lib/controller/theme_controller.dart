import 'package:flutter/material.dart';

class ThemeController extends ChangeNotifier {
  // 🟢 SAFE SINGLETON PATTERN (No 'late', No 'init' needed)
  static final ThemeController instance = ThemeController._internal();

  // Private constructor ensures only one instance exists
  ThemeController._internal();

  bool _isDarkMode = true;

  bool get isDarkMode => _isDarkMode;

  // Colors based on theme
  Color get primaryBackground => _isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF5F7FA);
  Color get dialogBackground => _isDarkMode ? const Color(0xFF1E293B) : Colors.white;
  Color get textColor => _isDarkMode ? Colors.white : const Color(0xFF1E293B);
  Color get secondaryText => _isDarkMode ? Colors.white54 : Colors.grey[600]!;
  Color get iconColor => _isDarkMode ? Colors.white : const Color(0xFF1E293B);

  void toggleTheme(bool isDark) {
    _isDarkMode = isDark;
    notifyListeners();
  }
}