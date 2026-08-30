// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'Scanner QR';

  @override
  String get navScan => 'Scanner';

  @override
  String get navGallery => 'Galerie';

  @override
  String get navResults => 'Résultats';

  @override
  String get navSettings => 'Paramètres';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get scannerPreferences => 'Préférences du scanner';

  @override
  String get defaultCamera => 'Caméra par défaut';

  @override
  String get cameraBack => 'Arrière';

  @override
  String get cameraFront => 'Avant';

  @override
  String get defaultScanMode => 'Mode par défaut';

  @override
  String get scanModeQr => 'QR';

  @override
  String get scanModeCrypto => 'Crypto';

  @override
  String get hapticsOnScan => 'Vibrations au scan';

  @override
  String get hapticsSubtitle => 'Vibrer lors du succès/erreur';

  @override
  String get autoOpenSafeLinks => 'Ouvrir auto. les liens sûrs';

  @override
  String get autoOpenSubtitle => 'Ouvrir dans le navigateur si 0 menace';

  @override
  String get language => 'Langue';

  @override
  String get languageSubtitle => 'Choisir la langue de l\'application';

  @override
  String get systemLanguage => 'Par défaut du système';

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
  String get cameraAccessRequired => 'Accès caméra requis';

  @override
  String get cameraAccessDesc =>
      'L\'application a besoin d\'accéder à la caméra pour scanner les codes QR et les adresses crypto.';

  @override
  String get grantPermission => 'Accorder l\'autorisation';

  @override
  String get galleryPermissionNeeded => 'Autorisation galerie requise';

  @override
  String get galleryPermissionDesc =>
      'Autorisez l\'accès à vos photos pour scanner les codes QR et adresses crypto à partir d\'images.';

  @override
  String get openSettings => 'Ouvrir les paramètres';

  @override
  String get selectPhotos => 'Sélectionner des photos';

  @override
  String get manageInSettings => 'Gérer dans les paramètres';

  @override
  String get addPhotos => 'Ajouter des photos';

  @override
  String get noPhotosSelected => 'Aucune photo sélectionnée';

  @override
  String get noPhotosSelectedDesc =>
      'Vous avez accordé un accès limité sans sélectionner de photo. Choisissez des photos dans la galerie.';

  @override
  String get noPhotosFound => 'Aucune photo trouvée';

  @override
  String get scanSelectedImage => 'Scanner l\'image sélectionnée';

  @override
  String get unableToReadPhoto => 'Impossible de lire la photo sélectionnée.';

  @override
  String get noQrFoundInImage =>
      'Aucun code QR trouvé dans l\'image sélectionnée.';

  @override
  String get failedToAnalyzeImage =>
      'Échec de l\'analyse de l\'image sélectionnée.';

  @override
  String get qrEmptyContent =>
      'Le code QR scanné ne contient aucun contenu lisible.';

  @override
  String get scanResults => 'Résultats du scan';

  @override
  String get removeAllResults => 'Supprimer tous les résultats';

  @override
  String get removeAllResultsTitle => 'Supprimer tous les résultats ?';

  @override
  String get removeAllResultsContent =>
      'Cette action supprimera définitivement tous les résultats. Cette opération est irréversible.';

  @override
  String get cancel => 'Annuler';

  @override
  String get removeAll => 'Tout supprimer';

  @override
  String get allResultsRemoved => 'Tous les résultats ont été supprimés.';

  @override
  String get noScanResultsYet => 'Aucun résultat pour le moment';

  @override
  String get noScanResultsDesc =>
      'Scannez un code QR ou une adresse crypto pour enregistrer et voir les résultats ici.';

  @override
  String get cryptoWalletTitle => 'Portefeuille crypto :';

  @override
  String get scannedLinkTitle => 'Lien scanné :';

  @override
  String get scanningLink => 'Scan du lien en cours...';

  @override
  String get scanningWallet => 'Scan du portefeuille crypto...';

  @override
  String get openLinkInBrowser => 'Ouvrir le lien dans le navigateur';

  @override
  String get blockedLinkDesc =>
      'L\'ouverture de ce lien est bloquée en raison de menaces de sécurité détectées.';

  @override
  String get analysisTimedOut =>
      'Délai d\'analyse dépassé. Le service prend plus de temps que prévu.';

  @override
  String get unableToScanLink => 'Impossible de scanner ce lien.';

  @override
  String get unableToScanWallet =>
      'Impossible de scanner ce portefeuille crypto.';

  @override
  String get plainTextNotLink =>
      'Le contenu scanné est du texte brut, pas un lien web.';

  @override
  String get scanError => 'Erreur de scan';

  @override
  String get safe => 'Sûr';

  @override
  String get safeDesc =>
      'Aucun problème de sécurité n\'a été détecté pour ce lien.';

  @override
  String get potentiallyUnsafe => 'Potentiellement dangereux';

  @override
  String get potentiallyUnsafeDesc =>
      'Des signaux d\'avertissement ont été détectés. N\'ouvrez que si vous faites confiance à la source.';

  @override
  String get dangerousLink => 'Lien dangereux';

  @override
  String get dangerousLinkDesc =>
      'Plusieurs moteurs de sécurité ont signalé ce lien comme dangereux ou malveillant.';

  @override
  String get malicious => 'Malveillant';

  @override
  String get unverified => 'Non vérifié';

  @override
  String get unverifiedDesc =>
      'Adresse non vérifiée dans les bases de menaces. Vérifiez le destinataire avant tout transfert.';

  @override
  String get maliciousReportedDesc =>
      'Ce portefeuille a été signalé dans les bases d\'adresses malveillantes.';

  @override
  String get safety => 'Sécurité';

  @override
  String get chain => 'Réseau';

  @override
  String get balance => 'Solde';

  @override
  String get transactions => 'Transactions';

  @override
  String get signals => 'Signaux';

  @override
  String get enginesScanning => 'Moteurs de scan';

  @override
  String get showAllEngines => 'Afficher tous les moteurs';

  @override
  String get showLess => 'Afficher moins';

  @override
  String get checksCompleted => 'analyses terminées';

  @override
  String get warningsFound => 'avertissements trouvés';

  @override
  String get phishing => 'Phishing';

  @override
  String get suspicious => 'Suspect';

  @override
  String get scannerResults => 'Résultats d\'analyse';

  @override
  String enginesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count moteurs',
      one: '1 moteur',
    );
    return '$_temp0';
  }

  @override
  String get showFewerEngines => 'Afficher moins de moteurs';

  @override
  String showAllEnginesCount(int count) {
    return 'Afficher les $count moteurs';
  }

  @override
  String warningsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count avertissements',
      one: '1 avertissement',
    );
    return '$_temp0';
  }

  @override
  String threatsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count menaces',
      one: '1 menace',
    );
    return '$_temp0';
  }

  @override
  String get tapToOpenInBrowser =>
      'Appuyez sur le lien pour l\'ouvrir dans le navigateur';

  @override
  String get reviewWarningsBeforeOpening =>
      'Vérifiez les avertissements avant d\'ouvrir';

  @override
  String get linkBlockedDueToThreats =>
      'Lien bloqué en raison de menaces de sécurité';

  @override
  String walletType(String label) {
    return 'Portefeuille $label';
  }

  @override
  String assetsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count actifs',
      one: '1 actif',
    );
    return '$_temp0';
  }

  @override
  String get network => 'Réseau';

  @override
  String get nativeBalance => 'Solde natif';

  @override
  String get walletAssets => 'Activos du portefeuille';

  @override
  String get noAssetsFound => 'Aucun actif trouvé pour ce portefeuille.';

  @override
  String get explainWithAi => 'Expliquer avec l\'IA';

  @override
  String get aiSecurityReport => 'Rapport de sécurité IA';

  @override
  String get analyzingWithAi => 'Gemini IA analyse les données de sécurité...';

  @override
  String get aiAnalysisFailed => 'L\'analyse IA n\'a pas pu aboutir';

  @override
  String get keyFindings => 'Principaux constats';

  @override
  String get recommendedAction => 'Action recommandée';

  @override
  String get regenerate => 'Régénérer';

  @override
  String get apiKeyMissingDesc =>
      'La clé API Gemini n\'est pas configurée. Lancez l\'application avec --dart-define=GEMINI_API_KEY=votre_cle.';

  @override
  String get hybridAiAnalysis => 'Analyse IA hybride';

  @override
  String get hybridAiReport => 'Rapport de sécurité IA Multi-Engine';

  @override
  String get analyzingWithHybridAi =>
      'L\'IA Multi-Engine synthétise les données on-chain et du modèle...';

  @override
  String knownExploitThreat(String exploit) {
    return 'Adresse associée à une attaque on-chain confirmée : $exploit';
  }

  @override
  String verifiedProtocolLabel(String protocol) {
    return 'Protocole vérifié / adresse officielle : $protocol';
  }

  @override
  String get signalMixerInteraction =>
      'Interaction directe avec un mixeur de cryptomonnaies (ex. Tornado Cash)';

  @override
  String get signalFastDrain =>
      'Retrait immédiat des fonds après dépôt (< 2h - schéma de drainer)';

  @override
  String get signalAsymmetricFlow =>
      'Forte asymétrie de transactions (drainage massif de fonds de multiples utilisateurs)';

  @override
  String get signalYoungWallet =>
      'Adresse très récente (créée au cours des 72 dernières heures)';

  @override
  String get signalBrandImpersonation =>
      'Usurpation d\'une marque Web3 connue (Brand Impersonation)';

  @override
  String get signalHighRiskTld => 'Domaine jetable à haut risque (.xyz, .top)';

  @override
  String get signalDgaEntropy =>
      'Entropie élevée des caractères dans le domaine (motif DGA)';
}
