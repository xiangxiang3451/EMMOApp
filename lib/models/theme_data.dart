import 'package:flutter/material.dart';

class AppTheme {
  static final lightTheme = ThemeData(
    primarySwatch: Colors.blue,
    brightness: Brightness.light,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.blue,
      titleTextStyle: TextStyle(
          color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black),
      bodyMedium: TextStyle(color: Colors.black54),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.all(Colors.white),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return Colors.blue;
        }
        return Colors.grey;
      }),
    ),
  );

  static final darkTheme = ThemeData(
    primarySwatch: Colors.blue,
    brightness: Brightness.dark,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.black,
      titleTextStyle: TextStyle(
          color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white70),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.all(Colors.white),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return Colors.blue;
        }
        return Colors.grey;
      }),
    ),
  );
}
