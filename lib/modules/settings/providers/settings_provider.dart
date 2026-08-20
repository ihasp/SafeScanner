import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/scan_mode.dart';
import '../models/app_settings.dart';
import '../services/settings_service.dart';

final settingsServiceProvider = Provider<SettingsService>((ref) {
  return SettingsService();
});

class SettingsNotifier extends Notifier<AppSettings> {
  late final SettingsService _service;

  @override
  AppSettings build() {
    _service = ref.watch(settingsServiceProvider);
    _init();
    return const AppSettings();
  }

  Future<void> _init() async {
    final saved = await _service.getSettings();
    state = saved;
  }

  Future<void> _update(AppSettings newSettings) async {
    state = newSettings;
    await _service.persistSettings(newSettings);
  }

  void setDefaultCameraFacing(AppCameraFacing facing) {
    _update(state.copyWith(defaultCameraFacing: facing));
  }

  void setDefaultScanMode(ScanMode mode) {
    _update(state.copyWith(defaultScanMode: mode));
  }

  void setHapticsEnabled(bool enabled) {
    _update(state.copyWith(hapticsEnabled: enabled));
  }

  void setAutoOpenSafeLinks(bool enabled) {
    _update(state.copyWith(autoOpenSafeLinks: enabled));
  }

  void setIncognitoMode(bool enabled) {
    _update(state.copyWith(incognitoMode: enabled));
  }

  void setHistorySizeLimit(int limit) {
    _update(state.copyWith(historySizeLimit: limit));
  }

  void setApiPollingRate(int rate) {
    _update(state.copyWith(apiPollingRate: rate));
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(
  SettingsNotifier.new,
);
