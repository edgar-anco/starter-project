import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  static const String _themeKey = 'theme_mode';
  final SharedPreferences _prefs;

  ThemeCubit(this._prefs)
      : super(ThemeState(themeMode: _loadThemeMode(_prefs)));

  static ThemeMode _loadThemeMode(SharedPreferences prefs) {
    final isDark = prefs.getBool(_themeKey) ?? false;
    return isDark ? ThemeMode.dark : ThemeMode.light;
  }

  void toggleTheme() {
    final newMode =
        state.themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    _prefs.setBool(_themeKey, newMode == ThemeMode.dark);
    emit(ThemeState(themeMode: newMode));
  }
}
