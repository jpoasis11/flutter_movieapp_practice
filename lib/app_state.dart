import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

final ValueNotifier<bool> isDarkMode = ValueNotifier<bool>(false);

Future<void> loadThemePreference() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    isDarkMode.value = prefs.getBool('isDark') ?? false;
  } catch (_) {}
}

Future<void> saveThemePreference(bool value) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDark', value);
  } catch (_) {}
}
