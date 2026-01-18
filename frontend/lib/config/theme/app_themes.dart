import 'package:flutter/material.dart';

const Color primaryColor = Color(0xFFDDB8E4);

ThemeData theme() {
  return ThemeData(
    scaffoldBackgroundColor: Colors.white,
    fontFamily: 'Muli',
    appBarTheme: appBarTheme(),
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: primaryColor,
    ),
  );
}

ThemeData darkTheme() {
  return ThemeData(
    scaffoldBackgroundColor: const Color(0xFF121212),
    fontFamily: 'Muli',
    appBarTheme: darkAppBarTheme(),
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      secondary: primaryColor,
      surface: Color(0xFF1E1E1E),
    ),
  );
}

AppBarTheme appBarTheme() {
  return const AppBarTheme(
    color: Colors.white,
    elevation: 0,
    centerTitle: true,
    iconTheme: IconThemeData(color: Color(0XFF8B8B8B)),
    titleTextStyle: TextStyle(color: Color(0XFF8B8B8B), fontSize: 18),
  );
}

AppBarTheme darkAppBarTheme() {
  return const AppBarTheme(
    color: Color(0xFF1E1E1E),
    elevation: 0,
    centerTitle: true,
    iconTheme: IconThemeData(color: Colors.white70),
    titleTextStyle: TextStyle(color: Colors.white70, fontSize: 18),
  );
}
