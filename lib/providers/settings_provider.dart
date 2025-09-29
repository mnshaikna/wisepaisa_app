import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class SettingsProvider extends ChangeNotifier {
  static const String _themeKey = "themeMode";
  static const String _currencyKey = "currency";
  static const String _reminderTimeKey = "reminderTime"; // HH:mm

  late Box _box;

  ThemeMode _themeMode = ThemeMode.system;
  String _currency = "INR";
  String _reminderTime = "09:00"; // default 9 AM

  ThemeMode get themeMode => _themeMode;
  String get currency => _currency;
  String get reminderTime => _reminderTime; // HH:mm

  SettingsProvider() {
    _init();
  }

  Future<void> _init() async {
    _box = Hive.box('settings');

    // Load saved values
    final savedTheme = _box.get(_themeKey, defaultValue: "system");
    final savedCurrency = _box.get(_currencyKey, defaultValue: "INR");
    final savedReminderTime = _box.get(
      _reminderTimeKey,
      defaultValue: _reminderTime,
    );

    _themeMode = _stringToThemeMode(savedTheme);
    _currency = savedCurrency;
    _reminderTime = savedReminderTime;

    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    _box.put(_themeKey, _themeMode.name); // save as string
    notifyListeners();
  }

  void setCurrency(String currency) {
    _currency = currency;
    _box.put(_currencyKey, _currency);
    notifyListeners();
  }

  void setReminderTime(String hhmm) {
    _reminderTime = hhmm;
    _box.put(_reminderTimeKey, _reminderTime);
    notifyListeners();
  }

  // Helper
  ThemeMode _stringToThemeMode(String value) {
    switch (value) {
      case "light":
        return ThemeMode.light;
      case "dark":
        return ThemeMode.dark;
      case "system":
      default:
        return ThemeMode.system;
    }
  }
}
