import 'package:flutter/material.dart';

class AppTheme {
  static const _seedColor = Color(0xFF006B5B);

  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      colorSchemeSeed: _seedColor,
      brightness: Brightness.light,
      fontFamily: 'Roboto',
    );
  }

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      colorSchemeSeed: _seedColor,
      brightness: Brightness.dark,
      fontFamily: 'Roboto',
    );
  }
}
