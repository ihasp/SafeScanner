import 'package:shared_preferences/shared_preferences.dart';

import '../../../helpers/settings/settings_storage_helper.dart';
import '../models/app_settings.dart';

class SettingsService {
  final SharedPreferences? _prefs;

  SettingsService([this._prefs]);

  AppSettings getSettingsSync() {
    if (_prefs != null) {
      return SettingsStorageHelper.loadFromPrefs(_prefs);
    }
    return const AppSettings();
  }

  Future<AppSettings> getSettings() async {
    if (_prefs != null) {
      return SettingsStorageHelper.loadFromPrefs(_prefs);
    }
    return SettingsStorageHelper.loadSettings();
  }

  Future<void> persistSettings(AppSettings settings) =>
      SettingsStorageHelper.saveSettings(settings, _prefs);
}
