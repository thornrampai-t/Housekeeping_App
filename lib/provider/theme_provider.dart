import 'package:flutter/material.dart';
import 'package:project/widget/theme.dart';

class ThemeProvider with ChangeNotifier {
  ThemeData _themeData = lighMode;
  ThemeData get themeData => _themeData;

  set themeData(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();
  }

  void toggleTheme() {
    if (_themeData == lighMode) {
      themeData = darkMode;
    } else {
      themeData = lighMode;
    }
  }
}
