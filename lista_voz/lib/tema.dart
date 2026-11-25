import 'package:flutter/material.dart';

/// Paleta de colores morada usada en toda la app.
class Paleta {
  static const c50 = Color(0xFFF3EBF9);
  static const c100 = Color(0xFFDDC8EF);
  static const c200 = Color(0xFFC8A4E5);
  static const c300 = Color(0xFFB281DA);
  static const c400 = Color(0xFF9C5DD0);
  static const c500 = Color(0xFF8739C6);
  static const c600 = Color(0xFF7934B3);
  static const c700 = Color(0xFF56257E);
  static const c800 = Color(0xFF3E1A5B);
  static const c900 = Color(0xFF261037);
  static const c950 = Color(0xFF0D0614);
}

/// Tema general: fondos, botones y avisos con la paleta.
ThemeData temaMorado() {
  final esquema = ColorScheme.fromSeed(seedColor: Paleta.c500).copyWith(
    primary: Paleta.c600,
    onPrimary: Colors.white,
    primaryContainer: Paleta.c100,
    onPrimaryContainer: Paleta.c900,
    secondary: Paleta.c400,
    onSecondary: Colors.white,
    surface: Paleta.c50,
    onSurface: Paleta.c950,
    outline: Paleta.c300,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: esquema,
    scaffoldBackgroundColor: Paleta.c50,
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: Paleta.c600,
        foregroundColor: Colors.white,
      ),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: Paleta.c800,
      contentTextStyle: TextStyle(color: Colors.white),
      actionTextColor: Paleta.c200,
      behavior: SnackBarBehavior.floating,
    ),
  );
}