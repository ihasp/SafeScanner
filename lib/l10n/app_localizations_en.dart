// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'QR Scanner';

  @override
  String get navScan => 'Scan';

  @override
  String get navGallery => 'Gallery';

  @override
  String get navResults => 'Results';

  @override
  String get navSettings => 'Settings';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get scannerPreferences => 'Scanner Preferences';

  @override
  String get defaultCamera => 'Default Camera';

  @override
  String get cameraBack => 'Back';

  @override
  String get cameraFront => 'Front';

  @override
  String get defaultScanMode => 'Default Scan Mode';

  @override
  String get scanModeQr => 'QR';

  @override
  String get scanModeCrypto => 'Crypto';

  @override
  String get hapticsOnScan => 'Haptics on Scan';

  @override
  String get hapticsSubtitle => 'Vibrate on success/error';

  @override
  String get autoOpenSafeLinks => 'Auto-Open Safe Links';

  @override
  String get autoOpenSubtitle => 'Open browser if 0 flags';

  @override
  String get language => 'Language';

  @override
  String get languageSubtitle => 'Choose application language';

  @override
  String get systemLanguage => 'System Default';

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
  String get cameraAccessRequired => 'Camera Access Required';

  @override
  String get cameraAccessDesc =>
      'The app needs camera access to scan QR codes and cryptocurrency addresses.';

  @override
  String get grantPermission => 'Grant Permission';

  @override
  String get galleryPermissionNeeded => 'Gallery Permission Needed';

  @override
  String get galleryPermissionDesc =>
      'Allow access to your photos to scan QR codes and crypto addresses from images.';

  @override
  String get openSettings => 'Open Settings';

  @override
  String get selectPhotos => 'Select Photos';

  @override
  String get manageInSettings => 'Manage in Settings';

  @override
  String get addPhotos => 'Add Photos';

  @override
  String get noPhotosSelected => 'No Photos Selected';

  @override
  String get noPhotosSelectedDesc =>
      'You gave limited gallery access without selecting any photos. Choose photos from Android gallery to scan them.';

  @override
  String get noPhotosFound => 'No photos found';

  @override
  String get scanSelectedImage => 'Scan Selected Image';

  @override
  String get unableToReadPhoto => 'Unable to read selected photo.';

  @override
  String get noQrFoundInImage => 'No QR code found in the selected image.';

  @override
  String get failedToAnalyzeImage => 'Failed to analyze the selected image.';

  @override
  String get qrEmptyContent => 'Scanned QR code contains no readable content.';

  @override
  String get scanResults => 'Scan results';

  @override
  String get removeAllResults => 'Remove all results';

  @override
  String get removeAllResultsTitle => 'Remove All Scan Results?';

  @override
  String get removeAllResultsContent =>
      'This will permanently delete all scan results. This action cannot be undone.';

  @override
  String get cancel => 'Cancel';

  @override
  String get removeAll => 'Remove All';

  @override
  String get allResultsRemoved => 'All scan results removed.';

  @override
  String get noScanResultsYet => 'No scan results yet';

  @override
  String get noScanResultsDesc =>
      'Scan a QR code or crypto address to save results and view them here.';

  @override
  String get cryptoWalletTitle => 'Crypto wallet:';

  @override
  String get scannedLinkTitle => 'Scanned link:';

  @override
  String get scanningLink => 'Scanning the link...';

  @override
  String get scanningWallet => 'Scanning crypto wallet...';

  @override
  String get openLinkInBrowser => 'Open Link in Browser';

  @override
  String get blockedLinkDesc =>
      'Opening this link is blocked due to detected security threats.';

  @override
  String get analysisTimedOut =>
      'Analysis timed out. The service is taking longer than expected.';

  @override
  String get unableToScanLink => 'Unable to scan this link.';

  @override
  String get unableToScanWallet => 'Unable to scan this crypto wallet.';

  @override
  String get plainTextNotLink =>
      'Scanned content is plain text, not a web link.';

  @override
  String get scanError => 'Scan Error';

  @override
  String get safe => 'Safe';

  @override
  String get safeDesc => 'No security issues were found for this link.';

  @override
  String get potentiallyUnsafe => 'Potentially unsafe';

  @override
  String get potentiallyUnsafeDesc =>
      'Security checks found warning signs. Only open this link if you trust the source.';

  @override
  String get dangerousLink => 'Dangerous link';

  @override
  String get dangerousLinkDesc =>
      'Multiple security engines flagged this link as dangerous or malicious. Opening this link is strongly discouraged.';

  @override
  String get malicious => 'Malicious';

  @override
  String get unverified => 'Unverified';

  @override
  String get unverifiedDesc =>
      'Address unverified in threat databases. Verify recipient before sending funds.';

  @override
  String get maliciousReportedDesc =>
      'This wallet was reported by a malicious-address data source.';

  @override
  String get safety => 'Safety';

  @override
  String get chain => 'Chain';

  @override
  String get balance => 'Balance';

  @override
  String get transactions => 'Transactions';

  @override
  String get signals => 'Signals';

  @override
  String get enginesScanning => 'Engines Scanning';

  @override
  String get showAllEngines => 'Show All Engines';

  @override
  String get showLess => 'Show Less';

  @override
  String get checksCompleted => 'checks completed';

  @override
  String get warningsFound => 'warnings found';

  @override
  String get phishing => 'Phishing';

  @override
  String get suspicious => 'Suspicious';

  @override
  String get scannerResults => 'Scanner results';

  @override
  String enginesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count engines',
      one: '1 engine',
    );
    return '$_temp0';
  }

  @override
  String get showFewerEngines => 'Show fewer engines';

  @override
  String showAllEnginesCount(int count) {
    return 'Show all $count engines';
  }

  @override
  String warningsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count warnings',
      one: '1 warning',
    );
    return '$_temp0';
  }

  @override
  String threatsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count threats',
      one: '1 threat',
    );
    return '$_temp0';
  }

  @override
  String get tapToOpenInBrowser => 'Tap link to open in browser';

  @override
  String get reviewWarningsBeforeOpening => 'Review warnings before opening';

  @override
  String get linkBlockedDueToThreats => 'Link blocked due to security threats';

  @override
  String walletType(String label) {
    return '$label wallet';
  }

  @override
  String assetsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count assets',
      one: '1 asset',
    );
    return '$_temp0';
  }

  @override
  String get network => 'Network';

  @override
  String get nativeBalance => 'Native balance';

  @override
  String get walletAssets => 'Wallet assets';

  @override
  String get noAssetsFound => 'No assets found for this wallet.';

  @override
  String get explainWithAi => 'Explain with AI';

  @override
  String get aiSecurityReport => 'AI Security Report';

  @override
  String get analyzingWithAi => 'Gemini AI is analyzing security data...';

  @override
  String get aiAnalysisFailed => 'AI analysis could not be completed';

  @override
  String get keyFindings => 'Key Findings';

  @override
  String get recommendedAction => 'Recommended Action';

  @override
  String get regenerate => 'Regenerate';

  @override
  String get apiKeyMissingDesc =>
      'Gemini API key is not configured. Run the app with --dart-define=GEMINI_API_KEY=your_key.';

  @override
  String get hybridAiAnalysis => 'Hybrid AI Analysis';

  @override
  String get hybridAiReport => 'Hybrid AI Security Report';

  @override
  String get analyzingWithHybridAi =>
      'Multi-Engine AI is synthesizing on-chain & model intelligence...';

  @override
  String knownExploitThreat(String exploit) {
    return 'Address associated with confirmed on-chain attack: $exploit';
  }

  @override
  String verifiedProtocolLabel(String protocol) {
    return 'Verified protocol / official address: $protocol';
  }

  @override
  String get signalMixerInteraction =>
      'Direct interaction with cryptocurrency mixer (e.g. Tornado Cash)';

  @override
  String get signalFastDrain =>
      'Immediate withdrawal of funds after deposit (< 2h - drainer pattern)';

  @override
  String get signalAsymmetricFlow =>
      'High transaction asymmetry (mass asset draining from multiple users)';

  @override
  String get signalYoungWallet =>
      'Very new address (created within the last 72 hours)';

  @override
  String get signalBrandImpersonation =>
      'Impersonating known Web3 brand (Brand Impersonation)';

  @override
  String get signalHighRiskTld =>
      'High-risk disposable domain TLD (.xyz, .top)';

  @override
  String get signalDgaEntropy =>
      'High character entropy in domain (DGA pattern)';
}
