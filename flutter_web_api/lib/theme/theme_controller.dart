import 'package:flutter/material.dart';
import 'theme.dart'; // your new AppThemes class

class ThemeController {
  static final ValueNotifier<ThemeData> themeNotifier =
      ValueNotifier(AppThemes.lightTheme);

  static void toggleTheme() {
    themeNotifier.value =
        themeNotifier.value.brightness == Brightness.light
            ? AppThemes.darkTheme
            : AppThemes.lightTheme;
  }
}
