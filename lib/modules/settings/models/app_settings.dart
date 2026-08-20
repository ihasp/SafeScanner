import '../../../shared/models/scan_mode.dart';

enum AppCameraFacing {
  back('back'),
  front('front');

  final String value;
  const AppCameraFacing(this.value);

  static AppCameraFacing fromString(String? value) {
    return switch (value?.toLowerCase()) {
      'front' => AppCameraFacing.front,
      _ => AppCameraFacing.back,
    };
  }
}

class AppSettings {
  final AppCameraFacing defaultCameraFacing;
  final ScanMode defaultScanMode;
  final bool hapticsEnabled;
  final bool autoOpenSafeLinks;
  final bool incognitoMode;
  final int historySizeLimit;
  final int apiPollingRate;

  const AppSettings({
    this.defaultCameraFacing = AppCameraFacing.back,
    this.defaultScanMode = ScanMode.qr,
    this.hapticsEnabled = true,
    this.autoOpenSafeLinks = false,
    this.incognitoMode = false,
    this.historySizeLimit = 10,
    this.apiPollingRate = 1000,
  });

  AppSettings copyWith({
    AppCameraFacing? defaultCameraFacing,
    ScanMode? defaultScanMode,
    bool? hapticsEnabled,
    bool? autoOpenSafeLinks,
    bool? incognitoMode,
    int? historySizeLimit,
    int? apiPollingRate,
  }) {
    return AppSettings(
      defaultCameraFacing: defaultCameraFacing ?? this.defaultCameraFacing,
      defaultScanMode: defaultScanMode ?? this.defaultScanMode,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      autoOpenSafeLinks: autoOpenSafeLinks ?? this.autoOpenSafeLinks,
      incognitoMode: incognitoMode ?? this.incognitoMode,
      historySizeLimit: historySizeLimit ?? this.historySizeLimit,
      apiPollingRate: apiPollingRate ?? this.apiPollingRate,
    );
  }

  Map<String, dynamic> toJson() => {
    'defaultCameraFacing': defaultCameraFacing.value,
    'defaultScanMode': defaultScanMode.name,
    'hapticsEnabled': hapticsEnabled,
    'autoOpenSafeLinks': autoOpenSafeLinks,
    'incognitoMode': incognitoMode,
    'historySizeLimit': historySizeLimit,
    'apiPollingRate': apiPollingRate,
  };

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      defaultCameraFacing: AppCameraFacing.fromString(
        json['defaultCameraFacing'] as String?,
      ),
      defaultScanMode: json['defaultScanMode'] == 'crypto'
          ? ScanMode.crypto
          : ScanMode.qr,
      hapticsEnabled: json['hapticsEnabled'] as bool? ?? true,
      autoOpenSafeLinks: json['autoOpenSafeLinks'] as bool? ?? false,
      incognitoMode: json['incognitoMode'] as bool? ?? false,
      historySizeLimit: json['historySizeLimit'] as int? ?? 10,
      apiPollingRate: json['apiPollingRate'] as int? ?? 1000,
    );
  }
}
