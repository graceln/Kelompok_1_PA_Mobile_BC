import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    // Selanjutnya, simpan _isDarkMode ke Shared Preferences atau storage lainnya
    notifyListeners();
  }
}