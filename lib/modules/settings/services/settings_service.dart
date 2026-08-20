import '../../../helpers/settings/settings_storage_helper.dart';
import '../models/app_settings.dart';

class SettingsService {
  Future<AppSettings> getSettings() => SettingsStorageHelper.loadSettings();

  Future<void> persistSettings(AppSettings settings) =>
      SettingsStorageHelper.saveSettings(settings);
}
