import 'package:flutter/material.dart';

class ThemeModeData extends ChangeNotifier {
  //Inisialisasi variabel _themeMode dengan nilai ThemeMode.system
  ThemeMode _themeMode = ThemeMode.system;

  // Getter untuk mendapatkan nilai _themeMode
  ThemeMode get themeMode => _themeMode;
  bool get isDarkModeActive => _themeMode == ThemeMode.dark;

  //Fungsi untuk mengubah tema dan memberi tahu pemantau perubahan
  void changeTheme(ThemeMode themeMode) {
    _themeMode = themeMode;
    notifyListeners();
  }
}
