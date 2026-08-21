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
  String get scanResults => 'Wyniki skanowania';

  @override
  String get removeAllResults => 'Usuń wszystkie wyniki';

  @override
  String get removeAllResultsTitle => 'Usunąć wszystkie wyniki?';

  @override
  String get removeAllResultsContent =>
      'Spowoduje to trwałe usunięcie wszystkich wyników skanowania. Tej operacji nie można cofnąć.';

  @override
  String get cancel => 'Anuluj';

  @override
  String get removeAll => 'Usuń wszystkie';

  @override
  String get allResultsRemoved => 'Usunięto wszystkie wyniki skanowania.';

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
}
