import 'package:flutter/material.dart';
import 'package:iron_sight/theme/custom_themes/text_theme.dart';

class MyAppTheme {
  MyAppTheme._();

  static ThemeData lightTheme = ThemeData();

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor:const Color.fromRGBO(91, 41, 143, 1),
    textTheme: MyTextTheme.darkTextTheme,
  );
}
