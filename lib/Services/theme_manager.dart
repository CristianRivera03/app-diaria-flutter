import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeManager with ChangeNotifier {
  Color primaryColor = Colors.blue;
  Color backgroundColor = Colors.white;
  Color textColor = Colors.black;

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    primaryColor = Color(prefs.getInt('primaryColor') ?? Colors.blue.value);
    backgroundColor = Color(prefs.getInt('backgroundColor') ?? Colors.white.value);
    textColor = Color(prefs.getInt('textColor') ?? Colors.black.value);
    notifyListeners();
  }

  Future<void> updateTheme(Color primary, Color background, Color text) async {
    primaryColor = primary;
    backgroundColor = background;
    textColor = text;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('primaryColor', primary.value);
    await prefs.setInt('backgroundColor', background.value);
    await prefs.setInt('textColor', text.value);

    notifyListeners();
  }

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
  );
}