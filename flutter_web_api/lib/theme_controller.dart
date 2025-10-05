import 'package:flutter/material.dart';

class ThemeController {
  static final ValueNotifier<ThemeData> themeNotifier =
      ValueNotifier(_lightTheme);

  static final ThemeData _lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.blue,
  );

  static final ThemeData _darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.blue,
  );

  static void toggleTheme() {
    themeNotifier.value =
        themeNotifier.value.brightness == Brightness.light
            ? _darkTheme
            : _lightTheme;
  }
}
