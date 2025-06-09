import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeManager with ChangeNotifier {
  // --- Persisted colors ---
  Color primaryColor = Colors.blue;
  Color backgroundColor = Colors.white;
  Color textColor = Colors.black;

  // --- Dark mode flag ---
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  // --- Computed getters para MainView, etc. ---
  Color get scaffoldBackground => backgroundColor;
  Color get textOnPrimary => textColor;
  Color get primary => primaryColor;

  // --- Carga inicial desde SharedPreferences ---
  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    primaryColor =
        Color(prefs.getInt('primaryColor') ?? Colors.blue.value);
    backgroundColor =
        Color(prefs.getInt('backgroundColor') ?? Colors.white.value);
    textColor =
        Color(prefs.getInt('textColor') ?? Colors.black.value);
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    notifyListeners();
  }

  // --- Guarda nuevos valores en SharedPreferences ---
  Future<void> updateTheme(
      Color newPrimary, Color newBackground, Color newText) async {
    primaryColor = newPrimary;
    backgroundColor = newBackground;
    textColor = newText;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('primaryColor', primaryColor.value);
    await prefs.setInt('backgroundColor', backgroundColor.value);
    await prefs.setInt('textColor', textColor.value);
    await prefs.setBool('isDarkMode', _isDarkMode);

    notifyListeners();
  }

  // --- Alterna light ↔ dark con valores por defecto ---
  void toggleTheme() {
    if (_isDarkMode) {
      _isDarkMode = false;
      updateTheme(
        Colors.blue,    // primary light
        Colors.white,   // background light
        Colors.black,   // text light
      );
    } else {
      _isDarkMode = true;
      updateTheme(
        Colors.tealAccent.shade700, // primary dark
        Colors.grey.shade900,       // background dark
        Colors.white,               // text dark
      );
    }
  }

  // --- ThemeData global para la app ---
  ThemeData get themeData => ThemeData(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: textColor),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: textColor,
      iconTheme: IconThemeData(color: textColor),
      titleTextStyle: TextStyle(
        color: textColor,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),

    // Aquí definimos el estilo de todos los TextField/InputDecorations
    inputDecorationTheme: InputDecorationTheme(
      hintStyle: TextStyle(color: textColor.withOpacity(0.6)),
      labelStyle: TextStyle(color: textColor.withOpacity(0.8)),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: textColor.withOpacity(0.4)),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: primaryColor),
        borderRadius: BorderRadius.circular(8),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.redAccent),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(
            color: Colors.redAccent.shade700),
        borderRadius: BorderRadius.circular(8),
      ),
      contentPadding:
      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    ),
  );
}
