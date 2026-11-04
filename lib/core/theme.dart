import 'package:flutter/material.dart';

const _seed = Color(0xFF006B5B);

ThemeData buildTheme(Brightness b) => ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: _seed, brightness: b),
      visualDensity: VisualDensity.standard,
    );
