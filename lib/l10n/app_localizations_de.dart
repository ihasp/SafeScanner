// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appName => 'QR-Scanner';

  @override
  String get navScan => 'Scannen';

  @override
  String get navGallery => 'Galerie';

  @override
  String get navResults => 'Ergebnisse';

  @override
  String get navSettings => 'Einstellungen';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get scannerPreferences => 'Scanner-Einstellungen';

  @override
  String get defaultCamera => 'Standardkamera';

  @override
  String get cameraBack => 'Rückseite';

  @override
  String get cameraFront => 'Vorderseite';

  @override
  String get defaultScanMode => 'Standardmodus';

  @override
  String get scanModeQr => 'QR';

  @override
  String get scanModeCrypto => 'Krypto';

  @override
  String get hapticsOnScan => 'Vibration beim Scannen';

  @override
  String get hapticsSubtitle => 'Bei Erfolg/Fehler vibrieren';

  @override
  String get autoOpenSafeLinks => 'Sichere Links automatisch öffnen';

  @override
  String get autoOpenSubtitle => 'Im Browser öffnen, wenn 0 Bedrohungen';

  @override
  String get language => 'Sprache';

  @override
  String get languageSubtitle => 'App-Sprache auswählen';

  @override
  String get systemLanguage => 'Systemstandard';

  @override
  String get langEn => 'English';

  @override
  String get langPl => 'Polski';

  @override
  String get langEs => 'Español';

  @override
  String get langDe => 'Deutsch';

  @override
  String get langFr => 'Français';

  @override
  String get langIt => 'Italiano';

  @override
  String get langPt => 'Português';

  @override
  String get cameraAccessRequired => 'Kamerazugriff erforderlich';

  @override
  String get cameraAccessDesc =>
      'Die App benötigt Kamerazugriff, um QR-Codes und Kryptowährungsadressen zu scannen.';

  @override
  String get grantPermission => 'Berechtigung erteilen';

  @override
  String get galleryPermissionNeeded => 'Galerie-Berechtigung erforderlich';

  @override
  String get galleryPermissionDesc =>
      'Erlauben Sie den Zugriff auf Ihre Fotos, um QR-Codes und Krypto-Adressen aus Bildern zu scannen.';

  @override
  String get openSettings => 'Einstellungen öffnen';

  @override
  String get selectPhotos => 'Fotos auswählen';

  @override
  String get manageInSettings => 'In Einstellungen verwalten';

  @override
  String get addPhotos => 'Fotos hinzufügen';

  @override
  String get noPhotosSelected => 'Keine Fotos ausgewählt';

  @override
  String get noPhotosSelectedDesc =>
      'Sie haben eingeschränkten Zugriff gewährt, ohne Fotos auszuwählen. Wählen Sie Fotos aus der Galerie aus.';

  @override
  String get noPhotosFound => 'Keine Fotos gefunden';

  @override
  String get scanSelectedImage => 'Ausgewähltes Bild scannen';

  @override
  String get unableToReadPhoto =>
      'Ausgewähltes Foto kann nicht gelesen werden.';

  @override
  String get noQrFoundInImage => 'Kein QR-Code im ausgewählten Bild gefunden.';

  @override
  String get failedToAnalyzeImage =>
      'Analyse des ausgewählten Bildes fehlgeschlagen.';

  @override
  String get qrEmptyContent =>
      'Der gescannte QR-Code enthält keinen lesbaren Inhalt.';

  @override
  String get scanResults => 'Scan-Ergebnisse';

  @override
  String get removeAllResults => 'Alle Ergebnisse löschen';

  @override
  String get removeAllResultsTitle => 'Alle Scan-Ergebnisse löschen?';

  @override
  String get removeAllResultsContent =>
      'Dadurch werden alle Ergebnisse dauerhaft gelöscht. Dies kann nicht rückgängig gemacht werden.';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get removeAll => 'Alle löschen';

  @override
  String get allResultsRemoved => 'Alle Scan-Ergebnisse wurden gelöscht.';

  @override
  String get noScanResultsYet => 'Noch keine Scan-Ergebnisse';

  @override
  String get noScanResultsDesc =>
      'Scannen Sie einen QR-Code oder eine Krypto-Adresse, um Ergebnisse hier zu speichern.';

  @override
  String get cryptoWalletTitle => 'Krypto-Wallet:';

  @override
  String get scannedLinkTitle => 'Gescannter Link:';

  @override
  String get scanningLink => 'Link wird gescannt...';

  @override
  String get scanningWallet => 'Krypto-Wallet wird gescannt...';

  @override
  String get openLinkInBrowser => 'Link im Browser öffnen';

  @override
  String get blockedLinkDesc =>
      'Das Öffnen dieses Links wurde aufgrund erkannter Sicherheitsbedrohungen blockiert.';

  @override
  String get analysisTimedOut =>
      'Zeitüberschreitung bei der Analyse. Der Dienst benötigt länger als erwartet.';

  @override
  String get unableToScanLink => 'Dieser Link kann nicht gescannt werden.';

  @override
  String get unableToScanWallet =>
      'Dieses Krypto-Wallet kann nicht gescannt werden.';

  @override
  String get plainTextNotLink =>
      'Der gescannte Inhalt ist reiner Text, kein Weblink.';

  @override
  String get scanError => 'Scan-Fehler';

  @override
  String get safe => 'Sicher';

  @override
  String get safeDesc =>
      'Für diesen Link wurden keine Sicherheitsprobleme gefunden.';

  @override
  String get potentiallyUnsafe => 'Potenziell unsicher';

  @override
  String get potentiallyUnsafeDesc =>
      'Sicherheitsprüfungen ergaben Warnhinweise. Nur öffnen, wenn Sie der Quelle vertrauen.';

  @override
  String get dangerousLink => 'Gefährlicher Link';

  @override
  String get dangerousLinkDesc =>
      'Mehrere Sicherheitsdienste haben diesen Link als gefährlich oder bösartig eingestuft.';

  @override
  String get malicious => 'Bösartig';

  @override
  String get unverified => 'Unverifiziert';

  @override
  String get unverifiedDesc =>
      'Adresse nicht in Bedrohungsdatenbanken verifiziert. Überprüfen Sie den Empfänger vor dem Senden.';

  @override
  String get maliciousReportedDesc =>
      'Dieses Wallet wurde in Datenbanken für bösartige Adressen gemeldet.';

  @override
  String get safety => 'Sicherheit';

  @override
  String get chain => 'Netzwerk';

  @override
  String get balance => 'Guthaben';

  @override
  String get transactions => 'Transaktionen';

  @override
  String get signals => 'Signale';

  @override
  String get enginesScanning => 'Scan-Engines';

  @override
  String get showAllEngines => 'Alle Engines anzeigen';

  @override
  String get showLess => 'Weniger anzeigen';

  @override
  String get checksCompleted => 'Prüfungen abgeschlossen';

  @override
  String get warningsFound => 'Warnungen gefunden';

  @override
  String get phishing => 'Phishing';

  @override
  String get suspicious => 'Verdächtig';

  @override
  String get scannerResults => 'Scanner-Ergebnisse';

  @override
  String enginesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Engines',
      one: '1 Engine',
    );
    return '$_temp0';
  }

  @override
  String get showFewerEngines => 'Weniger Engines anzeigen';

  @override
  String showAllEnginesCount(int count) {
    return 'Alle $count Engines anzeigen';
  }

  @override
  String warningsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Warnungen',
      one: '1 Warnung',
    );
    return '$_temp0';
  }

  @override
  String threatsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Bedrohungen',
      one: '1 Bedrohung',
    );
    return '$_temp0';
  }

  @override
  String get tapToOpenInBrowser => 'Tippen, um im Browser zu öffnen';

  @override
  String get reviewWarningsBeforeOpening => 'Warnungen vor dem Öffnen prüfen';

  @override
  String get linkBlockedDueToThreats =>
      'Link aufgrund von Bedrohungen blockiert';

  @override
  String walletType(String label) {
    return '$label-Wallet';
  }

  @override
  String assetsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Assets',
      one: '1 Asset',
    );
    return '$_temp0';
  }

  @override
  String get network => 'Netzwerk';

  @override
  String get nativeBalance => 'Natives Guthaben';

  @override
  String get walletAssets => 'Wallet-Assets';

  @override
  String get noAssetsFound => 'Keine Assets für dieses Wallet gefunden.';
}
