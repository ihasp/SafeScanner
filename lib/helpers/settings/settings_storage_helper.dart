import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../modules/settings/models/app_settings.dart';

abstract final class SettingsStorageHelper {
  static const String _settingsKey = 'app_settings_data';

  static AppSettings loadFromPrefs(SharedPreferences prefs) {
    try {
      final jsonString = prefs.getString(_settingsKey);
      if (jsonString != null && jsonString.isNotEmpty) {
        final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
        return AppSettings.fromJson(decoded);
      }
    } catch (_) {}
    return const AppSettings();
  }

  static Future<AppSettings> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return loadFromPrefs(prefs);
    } catch (_) {}
    return const AppSettings();
  }

  static Future<void> saveSettings(
    AppSettings settings, [
    SharedPreferences? prefs,
  ]) async {
    try {
      final p = prefs ?? await SharedPreferences.getInstance();
      final jsonString = jsonEncode(settings.toJson());
      await p.setString(_settingsKey, jsonString);
    } catch (_) {}
  }
}
