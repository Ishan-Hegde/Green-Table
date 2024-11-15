import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:green_table/themes/dark_mode.dart';
import 'package:green_table/themes/light_mode.dart';

class ThemeProvider with ChangeNotifier {
  // Box instance for storing theme data
  late Box _box;

  // Default theme is light mode, but it will be loaded from Hive
  ThemeData _themeData = lightMode;

  ThemeData get themeData => _themeData;

  bool get isDarkMode => _themeData == darkMode;

  ThemeProvider() {
    _initialize();
  }

  // Initialize Hive box and load saved theme preference
  Future<void> _initialize() async {
    // Open the box to store app settings
    _box = await Hive.openBox('appSettings');

    // Load saved theme preference (default to lightMode if not set)
    _themeData =
        _box.get('isDarkMode', defaultValue: false) ? darkMode : lightMode;
    notifyListeners();
  }

  // Setter method to change the theme dynamically
  set themeData(ThemeData themeData) {
    _themeData = themeData;
    _saveThemePreference(themeData == darkMode);
    notifyListeners();
  }

  // Toggle between light and dark mode
  void toggleTheme() {
    if (_themeData == lightMode) {
      themeData = darkMode;
    } else {
      themeData = lightMode;
    }
  }

  // Save the theme preference in Hive
  void _saveThemePreference(bool isDarkMode) {
    _box.put('isDarkMode', isDarkMode);
  }
}
