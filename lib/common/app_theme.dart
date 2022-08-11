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
  50: Color.fromRGBO(0, 110, 23, .1),
  100: Color.fromRGBO(0, 110, 23, .2),
  200: Color.fromRGBO(0, 110, 23, .3),
  300: Color.fromRGBO(0, 110, 23, .4),
  400: Color.fromRGBO(0, 110, 23, .5),
  500: Color.fromRGBO(0, 110, 23, .6),
  600: Color.fromRGBO(0, 110, 23, .7),
  700: Color.fromRGBO(0, 110, 23, .8),
  800: Color.fromRGBO(0, 110, 23, .9),
  900: Color.fromRGBO(0, 110, 23, 1),
};
