import 'package:flutter/material.dart';

//класс для управления темой приложения
abstract class AppTheme {
  AppTheme._();

  static final lightTheme = ThemeData(
    primarySwatch: greenCustom,
    snackBarTheme: const SnackBarThemeData(
      shape: StadiumBorder(),
      backgroundColor: Colors.black,
      behavior: SnackBarBehavior.floating,
      actionTextColor: Colors.white,
    ),
  );
}

MaterialColor greenCustom = MaterialColor(0xFF006E17, greenColor);

Map<int, Color> greenColor = {
  50: const Color.fromRGBO(0, 110, 23, 0.1),
  100: const Color.fromRGBO(0, 110, 23, 0.2),
  200: const Color.fromRGBO(0, 110, 23, 0.3),
  300: const Color.fromRGBO(0, 110, 23, 0.4),
  400: const Color.fromRGBO(0, 110, 23, 0.5),
  500: const Color.fromRGBO(0, 110, 23, 0.6),
  600: const Color.fromRGBO(0, 110, 23, 0.7),
  700: const Color.fromRGBO(0, 110, 23, 0.8),
  800: const Color.fromRGBO(0, 110, 23, 0.9),
  900: const Color.fromRGBO(0, 110, 23, 1),
};
