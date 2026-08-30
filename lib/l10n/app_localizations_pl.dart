// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get appName => 'Skaner QR';

  @override
  String get navScan => 'Skanuj';

  @override
  String get navGallery => 'Galeria';

  @override
  String get navResults => 'Wyniki';

  @override
  String get navSettings => 'Ustawienia';

  @override
  String get settingsTitle => 'Ustawienia';

  @override
  String get scannerPreferences => 'Preferencje skanera';

  @override
  String get defaultCamera => 'Domyślna kamera';

  @override
  String get cameraBack => 'Tylna';

  @override
  String get cameraFront => 'Przednia';

  @override
  String get defaultScanMode => 'Domyślny tryb';

  @override
  String get scanModeQr => 'QR';

  @override
  String get scanModeCrypto => 'Krypto';

  @override
  String get hapticsOnScan => 'Wibracje przy skanowaniu';

  @override
  String get hapticsSubtitle => 'Wibracje przy sukcesie/błędzie';

  @override
  String get autoOpenSafeLinks => 'Automatyczne otwieranie linków';

  @override
  String get autoOpenSubtitle => 'Otwórz bezpieczne linki automatycznie';

  @override
  String get language => 'Język';

  @override
  String get languageSubtitle => 'Wybierz język aplikacji';

  @override
  String get systemLanguage => 'Domyślny systemu';

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
  String get cameraAccessRequired => 'Wymagany dostęp do aparatu';

  @override
  String get cameraAccessDesc =>
      'Aplikacja potrzebuje dostępu do aparatu, aby skanować kody QR.';

  @override
  String get grantPermission => 'Przyznaj uprawnienie';

  @override
  String get galleryPermissionNeeded => 'Wymagany dostęp do galerii';

  @override
  String get galleryPermissionDesc =>
      'Zezwól na dostęp do zdjęć, aby skanować kody QR i adresy krypto z obrazów.';

  @override
  String get openSettings => 'Otwórz ustawienia';

  @override
  String get selectPhotos => 'Wybierz zdjęcia';

  @override
  String get manageInSettings => 'Zarządzaj w ustawieniach';

  @override
  String get addPhotos => 'Dodaj zdjęcia';

  @override
  String get noPhotosSelected => 'Nie wybrano zdjęć';

  @override
  String get noPhotosSelectedDesc =>
      'Udzielono ograniczonego dostępu bez wybrania zdjęć. Wybierz zdjęcia z galerii, aby je przeskanować.';

  @override
  String get noPhotosFound => 'Nie znaleziono zdjęć';

  @override
  String get scanSelectedImage => 'Skanuj wybrane zdjęcie';

  @override
  String get unableToReadPhoto => 'Nie można odczytać wybranego zdjęcia.';

  @override
  String get noQrFoundInImage => 'Nie znaleziono kodu QR na wybranym zdjęciu.';

  @override
  String get failedToAnalyzeImage =>
      'Nie udało się przeanalizować wybranego zdjęcia.';

  @override
  String get qrEmptyContent =>
      'Zeskanowany kod QR nie zawiera czytelnej treści.';

  @override
  String get scanResults => 'Wyniki skanowań';

  @override
  String get removeAllResults => 'Usuń wszystkie wyniki';

  @override
  String get removeAllResultsTitle => 'Usunąć wszystkie wyniki?';

  @override
  String get removeAllResultsContent =>
      'Spowoduje to trwałe usunięcie wszystkich wyników skanowań. Tej operacji nie można cofnąć.';

  @override
  String get cancel => 'Anuluj';

  @override
  String get removeAll => 'Usuń wszystkie';

  @override
  String get allResultsRemoved => 'Usunięto wszystkie wyniki skanowań';

  @override
  String get noScanResultsYet => 'Brak wyników skanowania';

  @override
  String get noScanResultsDesc =>
      'Zeskanuj kod QR, aby zapisać wyniki i zobaczyć je tutaj.';

  @override
  String get cryptoWalletTitle => 'Portfel:';

  @override
  String get scannedLinkTitle => 'Zeskanowany link:';

  @override
  String get scanningLink => 'Skanowanie linku...';

  @override
  String get scanningWallet => 'Skanowanie portfela...';

  @override
  String get openLinkInBrowser => 'Otwórz link w przeglądarce';

  @override
  String get blockedLinkDesc =>
      'Otwarcie tego linku zostało zablokowane ze względu na wykryte zagrożenia bezpieczeństwa.';

  @override
  String get analysisTimedOut =>
      'Upłynął limit czasu analizy. Usługa odpowiada dłużej niż oczekiwano.';

  @override
  String get unableToScanLink => 'Nie można przeskanować tego linku.';

  @override
  String get unableToScanWallet =>
      'Nie można przeskanować tego portfela krypto.';

  @override
  String get plainTextNotLink => 'Zeskanowana treść nie jest linkiem.';

  @override
  String get scanError => 'Błąd skanowania';

  @override
  String get safe => 'Bezpieczny';

  @override
  String get safeDesc => 'Nie znaleziono zagrożeń.';

  @override
  String get potentiallyUnsafe => 'Potencjalnie niebezpieczny';

  @override
  String get potentiallyUnsafeDesc => 'Wykryto potencjalne niebezpieczeństwo.';

  @override
  String get dangerousLink => 'Niebezpieczny link';

  @override
  String get dangerousLinkDesc =>
      'Wiele silników bezpieczeństwa uznało ten link za niebezpieczny lub złośliwy.';

  @override
  String get malicious => 'Złośliwy';

  @override
  String get unverified => 'Niezweryfikowany';

  @override
  String get unverifiedDesc =>
      'Adres niezweryfikowany w bazach zagrożeń. Sprawdź odbiorcę przed wysłaniem środków.';

  @override
  String get maliciousReportedDesc =>
      'Ten portfel został zgłoszony w bazach złośliwych adresów.';

  @override
  String get safety => 'Bezpieczeństwo';

  @override
  String get chain => 'Sieć';

  @override
  String get balance => 'Saldo';

  @override
  String get transactions => 'Transakcje';

  @override
  String get signals => 'Sygnały';

  @override
  String get enginesScanning => 'Silniki skanujące';

  @override
  String get showAllEngines => 'Pokaż wszystkie silniki';

  @override
  String get showLess => 'Pokaż mniej';

  @override
  String get checksCompleted => 'zakończonych testów';

  @override
  String get warningsFound => 'wykrytych ostrzeżeń';

  @override
  String get phishing => 'Phishing';

  @override
  String get suspicious => 'Podejrzany';

  @override
  String get scannerResults => 'Wyniki skanerów';

  @override
  String enginesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count silników',
      many: '$count silników',
      few: '$count silniki',
      one: '1 silnik',
    );
    return '$_temp0';
  }

  @override
  String get showFewerEngines => 'Pokaż mniej silników';

  @override
  String showAllEnginesCount(int count) {
    return 'Pokaż wszystkie ($count) silniki';
  }

  @override
  String warningsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ostrzeżeń',
      many: '$count ostrzeżeń',
      few: '$count ostrzeżenia',
      one: '1 ostrzeżenie',
    );
    return '$_temp0';
  }

  @override
  String threatsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count zagrożeń',
      many: '$count zagrożeń',
      few: '$count zagrożenia',
      one: '1 zagrożenie',
    );
    return '$_temp0';
  }

  @override
  String get tapToOpenInBrowser => 'Dotknij linku, aby otworzyć w przeglądarce';

  @override
  String get reviewWarningsBeforeOpening =>
      'Zweryfikuj ostrzeżenia przed otwarciem';

  @override
  String get linkBlockedDueToThreats =>
      'Link zablokowany z powodu zagrożeń bezpieczeństwa';

  @override
  String walletType(String label) {
    return 'Portfel $label';
  }

  @override
  String assetsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count aktywów',
      many: '$count aktywów',
      few: '$count aktywa',
      one: '1 aktyw',
    );
    return '$_temp0';
  }

  @override
  String get network => 'Sieć';

  @override
  String get nativeBalance => 'Saldo natywne';

  @override
  String get walletAssets => 'Aktywa portfela';

  @override
  String get noAssetsFound => 'Nie znaleziono aktywów dla tego portfela.';

  @override
  String get explainWithAi => 'Wyjaśnij z AI';

  @override
  String get aiSecurityReport => 'Raport bezpieczeństwa AI';

  @override
  String get analyzingWithAi => 'Gemini AI analizuje dane bezpieczeństwa...';

  @override
  String get aiAnalysisFailed => 'Nie udało się ukończyć analizy AI';

  @override
  String get keyFindings => 'Kluczowe ustalenia';

  @override
  String get recommendedAction => 'Zalecane działanie';

  @override
  String get regenerate => 'Wygeneruj ponownie';

  @override
  String get apiKeyMissingDesc => 'Klucz API Gemini nie jest skonfigurowany.';

  @override
  String get hybridAiAnalysis => 'Analiza hybrydowa AI';

  @override
  String get hybridAiReport => 'Raport bezpieczeństwa';

  @override
  String get analyzingWithHybridAi => 'Trwa synteza Multi-Engine...';

  @override
  String knownExploitThreat(String exploit) {
    return 'Adres powiązany ze znanym atakiem: $exploit';
  }

  @override
  String verifiedProtocolLabel(String protocol) {
    return 'Zweryfikowany protokół / oficjalny adres: $protocol';
  }

  @override
  String get signalMixerInteraction =>
      'Bezpośrednia interakcja z mikserem kryptowalut (np. Tornado Cash)';

  @override
  String get signalFastDrain =>
      'Błyskawiczne wypłacanie środków po wpłacie (< 2h - schemat drainera)';

  @override
  String get signalAsymmetricFlow =>
      'Wysoka asymetria transakcji (masowe ściąganie środków od wielu użytkowników)';

  @override
  String get signalYoungWallet =>
      'Bardzo młody adres (utworzony w ciągu ostatnich 72 godzin)';

  @override
  String get signalBrandImpersonation =>
      'Podszywanie pod znaną markę Web3 (Brand Impersonation)';

  @override
  String get signalHighRiskTld =>
      'Jednorazowa domena wysokiego ryzyka (.xyz, .top)';

  @override
  String get signalDgaEntropy =>
      'Wysoka losowość znaków w domenie (wzorzec DGA)';
}
