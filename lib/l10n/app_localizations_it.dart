// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appName => 'Scanner QR';

  @override
  String get navScan => 'Scansiona';

  @override
  String get navGallery => 'Galleria';

  @override
  String get navResults => 'Risultati';

  @override
  String get navSettings => 'Impostazioni';

  @override
  String get settingsTitle => 'Impostazioni';

  @override
  String get scannerPreferences => 'Preferenze scanner';

  @override
  String get defaultCamera => 'Fotocamera predefinita';

  @override
  String get cameraBack => 'Posteriore';

  @override
  String get cameraFront => 'Anteriore';

  @override
  String get defaultScanMode => 'Modalità predefinita';

  @override
  String get scanModeQr => 'QR';

  @override
  String get scanModeCrypto => 'Crypto';

  @override
  String get hapticsOnScan => 'Feedback tattile al scan';

  @override
  String get hapticsSubtitle => 'Vibra su successo/errore';

  @override
  String get autoOpenSafeLinks => 'Apri link sicuri automaticamente';

  @override
  String get autoOpenSubtitle => 'Apri nel browser se 0 minacce';

  @override
  String get language => 'Lingua';

  @override
  String get languageSubtitle => 'Scegli la lingua dell\'applicazione';

  @override
  String get systemLanguage => 'Predefinita di sistema';

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
  String get cameraAccessRequired => 'Accesso fotocamera richiesto';

  @override
  String get cameraAccessDesc =>
      'L\'app necessita dell\'accesso alla fotocamera per scansionare codici QR e indirizzi crypto.';

  @override
  String get grantPermission => 'Concedi autorizzazione';

  @override
  String get galleryPermissionNeeded => 'Autorizzazione galleria necessaria';

  @override
  String get galleryPermissionDesc =>
      'Consenti l\'accesso alle foto per scansionare codici QR e indirizzi crypto dalle immagini.';

  @override
  String get openSettings => 'Apri impostazioni';

  @override
  String get selectPhotos => 'Seleziona foto';

  @override
  String get manageInSettings => 'Gestisci nelle impostazioni';

  @override
  String get addPhotos => 'Aggiungi foto';

  @override
  String get noPhotosSelected => 'Nessuna foto selezionata';

  @override
  String get noPhotosSelectedDesc =>
      'Hai concesso accesso limitato senza selezionare foto. Scegli le foto dalla galleria.';

  @override
  String get noPhotosFound => 'Nessuna foto trovata';

  @override
  String get scanSelectedImage => 'Scansiona immagine selezionata';

  @override
  String get unableToReadPhoto => 'Impossibile leggere la foto selezionata.';

  @override
  String get noQrFoundInImage => 'Nessun codice QR trovato nell\'immagine.';

  @override
  String get failedToAnalyzeImage =>
      'Analisi dell\'immagine selezionata non riuscita.';

  @override
  String get qrEmptyContent =>
      'Il codice QR scansionato non contiene dati leggibili.';

  @override
  String get scanResults => 'Risultati scansione';

  @override
  String get removeAllResults => 'Rimuovi tutti i risultati';

  @override
  String get removeAllResultsTitle => 'Rimuovere tutti i risultati?';

  @override
  String get removeAllResultsContent =>
      'Tutti i risultati di scansione verranno eliminati definitivamente. Questa azione non può essere annullata.';

  @override
  String get cancel => 'Annulla';

  @override
  String get removeAll => 'Rimuovi tutto';

  @override
  String get allResultsRemoved => 'Tutti i risultati sono stati rimossi.';

  @override
  String get noScanResultsYet => 'Nessun risultato di scansione';

  @override
  String get noScanResultsDesc =>
      'Scansiona un codice QR o un indirizzo crypto per visualizzare i risultati qui.';

  @override
  String get cryptoWalletTitle => 'Portafoglio crypto:';

  @override
  String get scannedLinkTitle => 'Link scansionato:';

  @override
  String get scanningLink => 'Scansione del link in corso...';

  @override
  String get scanningWallet => 'Scansione portafoglio crypto...';

  @override
  String get openLinkInBrowser => 'Apri link nel browser';

  @override
  String get blockedLinkDesc =>
      'L\'apertura di questo link è bloccata a causa di minacce di sicurezza rilevate.';

  @override
  String get analysisTimedOut =>
      'Timeout analisi. Il servizio sta impiegando più tempo del previsto.';

  @override
  String get unableToScanLink => 'Impossibile scansionare questo link.';

  @override
  String get unableToScanWallet =>
      'Impossibile scansionare questo portafoglio crypto.';

  @override
  String get plainTextNotLink =>
      'Il contenuto scansionato è testo normale, non un link web.';

  @override
  String get scanError => 'Errore di scansione';

  @override
  String get safe => 'Sicuro';

  @override
  String get safeDesc =>
      'Nessun problema di sicurezza rilevato per questo link.';

  @override
  String get potentiallyUnsafe => 'Potenzialmente non sicuro';

  @override
  String get potentiallyUnsafeDesc =>
      'Rilevati segnali di avviso. Apri solo se ti fidi della fonte.';

  @override
  String get dangerousLink => 'Link pericoloso';

  @override
  String get dangerousLinkDesc =>
      'Più motori di sicurezza hanno contrassegnato questo link come pericoloso o dannoso.';

  @override
  String get malicious => 'Dannoso';

  @override
  String get unverified => 'Non verificato';

  @override
  String get unverifiedDesc =>
      'Indirizzo non verificato nei database delle minacce. Verifica il destinatario prima di inviare fondi.';

  @override
  String get maliciousReportedDesc =>
      'Questo portafoglio è stato segnalato nei database degli indirizzi dannosi.';

  @override
  String get safety => 'Sicurezza';

  @override
  String get chain => 'Rete';

  @override
  String get balance => 'Saldo';

  @override
  String get transactions => 'Transazioni';

  @override
  String get signals => 'Segnali';

  @override
  String get enginesScanning => 'Motori di scansione';

  @override
  String get showAllEngines => 'Mostra tutti i motori';

  @override
  String get showLess => 'Mostra meno';

  @override
  String get checksCompleted => 'controlli completati';

  @override
  String get warningsFound => 'avvisi trovati';

  @override
  String get phishing => 'Phishing';

  @override
  String get suspicious => 'Sospetto';

  @override
  String get scannerResults => 'Risultati dello scanner';

  @override
  String enginesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count motori',
      one: '1 motore',
    );
    return '$_temp0';
  }

  @override
  String get showFewerEngines => 'Mostra meno motori';

  @override
  String showAllEnginesCount(int count) {
    return 'Mostra tutti i $count motori';
  }

  @override
  String warningsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count avvisi',
      one: '1 avviso',
    );
    return '$_temp0';
  }

  @override
  String threatsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minacce',
      one: '1 minaccia',
    );
    return '$_temp0';
  }

  @override
  String get tapToOpenInBrowser => 'Tocca il link per aprirlo nel browser';

  @override
  String get reviewWarningsBeforeOpening =>
      'Controlla gli avvisi prima di aprire';

  @override
  String get linkBlockedDueToThreats =>
      'Link bloccato a causa di minacce alla sicurezza';

  @override
  String walletType(String label) {
    return 'Portafoglio $label';
  }

  @override
  String assetsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count asset',
      one: '1 asset',
    );
    return '$_temp0';
  }

  @override
  String get network => 'Rete';

  @override
  String get nativeBalance => 'Saldo nativo';

  @override
  String get walletAssets => 'Asset del portafoglio';

  @override
  String get noAssetsFound => 'Nessun asset trovato per questo portafoglio.';

  @override
  String get explainWithAi => 'Spiega con l\'IA';

  @override
  String get aiSecurityReport => 'Rapporto di sicurezza IA';

  @override
  String get analyzingWithAi =>
      'Gemini IA sta analizzando i dati di sicurezza...';

  @override
  String get aiAnalysisFailed => 'Impossibile completare l\'analisi IA';

  @override
  String get keyFindings => 'Risultati principali';

  @override
  String get recommendedAction => 'Azione consigliata';

  @override
  String get regenerate => 'Rigenera';

  @override
  String get apiKeyMissingDesc =>
      'La chiave API Gemini non è configurata. Esegui l\'app con --dart-define=GEMINI_API_KEY=tua_chiave.';
}
