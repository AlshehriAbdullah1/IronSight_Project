import 'package:flutter/material.dart';

class MyTextTheme {
  MyTextTheme._();

  static TextTheme lightTextTheme = const TextTheme();

  static TextTheme darkTextTheme = TextTheme(
    titleLarge: const TextStyle().copyWith(
      fontSize: 24.0,
      fontWeight: FontWeight.bold,
      color: Colors.white,
      fontFamily: "Inter",
    ),
    titleMedium: const TextStyle().copyWith(
      fontSize: 18.0,
      fontWeight: FontWeight.bold,
      color: Colors.white,
      fontFamily: "Inter",
    ),
    titleSmall: const TextStyle().copyWith(
      //for buttons
      fontSize: 14.0,
      fontWeight: FontWeight.bold,
      color: Colors.white,
      fontFamily: "Inter",
    ),
    bodyLarge: const TextStyle().copyWith(
      fontSize: 13.0,
      color: Colors.white,
      fontFamily: "Inter",
    ),
    bodyMedium: const TextStyle().copyWith(
      fontSize: 12.0,
      color: Colors.white,
      fontFamily: "Inter",
    ),
    bodySmall: const TextStyle().copyWith(
      fontSize: 10.0,
      color: Colors.white,
      fontFamily: "Inter",
    ),
    labelMedium: const TextStyle().copyWith(
      //For @accounts
      fontSize: 13.0,
      color: Colors.grey,
      fontFamily: "Inter",
    ),
  );
}
