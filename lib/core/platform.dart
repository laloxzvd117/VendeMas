import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';

/// Solo para pruebas: fuerza la vista de celular aunque corran en Linux.
bool debugForceMobile = false;

/// Linux, Windows o macOS: solo consulta de reportes (F-23).
bool get isDesktop =>
    !debugForceMobile &&
    !kIsWeb &&
    (Platform.isLinux || Platform.isWindows || Platform.isMacOS);

/// El celular con app nativa comparte sus datos en la red local.
bool get canServeLan => !kIsWeb && !isDesktop;
