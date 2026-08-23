import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_pl.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
    Locale('pl'),
    Locale('pt'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'QR Scanner'**
  String get appName;

  /// Bottom navigation label for scanner tab
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get navScan;

  /// Bottom navigation label for gallery tab
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get navGallery;

  /// Bottom navigation label for results tab
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get navResults;

  /// Bottom navigation label for settings tab
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// Title on the settings screen
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// Header for scanner preferences section
  ///
  /// In en, this message translates to:
  /// **'Scanner Preferences'**
  String get scannerPreferences;

  /// Setting label for default camera facing
  ///
  /// In en, this message translates to:
  /// **'Default Camera'**
  String get defaultCamera;

  /// Back camera label
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get cameraBack;

  /// Front camera label
  ///
  /// In en, this message translates to:
  /// **'Front'**
  String get cameraFront;

  /// Setting label for default scan mode
  ///
  /// In en, this message translates to:
  /// **'Default Scan Mode'**
  String get defaultScanMode;

  /// QR scan mode label
  ///
  /// In en, this message translates to:
  /// **'QR'**
  String get scanModeQr;

  /// Crypto scan mode label
  ///
  /// In en, this message translates to:
  /// **'Crypto'**
  String get scanModeCrypto;

  /// Setting label for haptic vibration feedback
  ///
  /// In en, this message translates to:
  /// **'Haptics on Scan'**
  String get hapticsOnScan;

  /// Subtitle describing haptic vibration behavior
  ///
  /// In en, this message translates to:
  /// **'Vibrate on success/error'**
  String get hapticsSubtitle;

  /// Setting label for automatically opening safe links
  ///
  /// In en, this message translates to:
  /// **'Auto-Open Safe Links'**
  String get autoOpenSafeLinks;

  /// Subtitle explaining auto-open safe links behavior
  ///
  /// In en, this message translates to:
  /// **'Open browser if 0 flags'**
  String get autoOpenSubtitle;

  /// Setting label for language selection
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Subtitle describing language selection
  ///
  /// In en, this message translates to:
  /// **'Choose application language'**
  String get languageSubtitle;

  /// Option to follow system default language
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get systemLanguage;

  /// Language name for English
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get langEn;

  /// Language name for Polish
  ///
  /// In en, this message translates to:
  /// **'Polski'**
  String get langPl;

  /// Language name for Spanish
  ///
  /// In en, this message translates to:
  /// **'Español'**
  String get langEs;

  /// Language name for German
  ///
  /// In en, this message translates to:
  /// **'Deutsch'**
  String get langDe;

  /// Language name for French
  ///
  /// In en, this message translates to:
  /// **'Français'**
  String get langFr;

  /// Language name for Italian
  ///
  /// In en, this message translates to:
  /// **'Italiano'**
  String get langIt;

  /// Language name for Portuguese
  ///
  /// In en, this message translates to:
  /// **'Português'**
  String get langPt;

  /// Title when camera permission is needed
  ///
  /// In en, this message translates to:
  /// **'Camera Access Required'**
  String get cameraAccessRequired;

  /// Description explaining why camera permission is required
  ///
  /// In en, this message translates to:
  /// **'The app needs camera access to scan QR codes and cryptocurrency addresses.'**
  String get cameraAccessDesc;

  /// Button label to request camera permission
  ///
  /// In en, this message translates to:
  /// **'Grant Permission'**
  String get grantPermission;

  /// Title when photo gallery permission is needed
  ///
  /// In en, this message translates to:
  /// **'Gallery Permission Needed'**
  String get galleryPermissionNeeded;

  /// Description explaining why photo library access is required
  ///
  /// In en, this message translates to:
  /// **'Allow access to your photos to scan QR codes and crypto addresses from images.'**
  String get galleryPermissionDesc;

  /// Button label to open system app settings
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// Button label to select specific photos under limited permission
  ///
  /// In en, this message translates to:
  /// **'Select Photos'**
  String get selectPhotos;

  /// Button label to manage permissions in OS settings
  ///
  /// In en, this message translates to:
  /// **'Manage in Settings'**
  String get manageInSettings;

  /// Label on the gallery tile to add more photos
  ///
  /// In en, this message translates to:
  /// **'Add Photos'**
  String get addPhotos;

  /// Title when limited permission is granted with zero photos
  ///
  /// In en, this message translates to:
  /// **'No Photos Selected'**
  String get noPhotosSelected;

  /// Explanation when user granted limited access with no photos selected
  ///
  /// In en, this message translates to:
  /// **'You gave limited gallery access without selecting any photos. Choose photos from Android gallery to scan them.'**
  String get noPhotosSelectedDesc;

  /// Message displayed when the gallery is empty
  ///
  /// In en, this message translates to:
  /// **'No photos found'**
  String get noPhotosFound;

  /// Button label to scan the selected gallery photo
  ///
  /// In en, this message translates to:
  /// **'Scan Selected Image'**
  String get scanSelectedImage;

  /// Error message when selected photo file cannot be loaded
  ///
  /// In en, this message translates to:
  /// **'Unable to read selected photo.'**
  String get unableToReadPhoto;

  /// Notification message when image contains no barcode or QR code
  ///
  /// In en, this message translates to:
  /// **'No QR code found in the selected image.'**
  String get noQrFoundInImage;

  /// Error message when image scanning fails
  ///
  /// In en, this message translates to:
  /// **'Failed to analyze the selected image.'**
  String get failedToAnalyzeImage;

  /// Notification message when scanned QR code has empty payload
  ///
  /// In en, this message translates to:
  /// **'Scanned QR code contains no readable content.'**
  String get qrEmptyContent;

  /// Title of the scan results history page
  ///
  /// In en, this message translates to:
  /// **'Scan results'**
  String get scanResults;

  /// Tooltip for removing all scan history items
  ///
  /// In en, this message translates to:
  /// **'Remove all results'**
  String get removeAllResults;

  /// Confirmation dialog title for clearing scan history
  ///
  /// In en, this message translates to:
  /// **'Remove All Scan Results?'**
  String get removeAllResultsTitle;

  /// Confirmation dialog body explaining scan results deletion
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete all scan results. This action cannot be undone.'**
  String get removeAllResultsContent;

  /// Generic cancel button label
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Confirm button label in clear history dialog
  ///
  /// In en, this message translates to:
  /// **'Remove All'**
  String get removeAll;

  /// Snackbar message shown after clearing scan history
  ///
  /// In en, this message translates to:
  /// **'All scan results removed.'**
  String get allResultsRemoved;

  /// Title when scan history is empty
  ///
  /// In en, this message translates to:
  /// **'No scan results yet'**
  String get noScanResultsYet;

  /// Subtitle encouraging user to scan something
  ///
  /// In en, this message translates to:
  /// **'Scan a QR code or crypto address to save results and view them here.'**
  String get noScanResultsDesc;

  /// Header label for cryptocurrency wallet sheet
  ///
  /// In en, this message translates to:
  /// **'Crypto wallet:'**
  String get cryptoWalletTitle;

  /// Header label for URL scan sheet
  ///
  /// In en, this message translates to:
  /// **'Scanned link:'**
  String get scannedLinkTitle;

  /// Progress indicator text while scanning URL
  ///
  /// In en, this message translates to:
  /// **'Scanning the link...'**
  String get scanningLink;

  /// Progress indicator text while scanning crypto address
  ///
  /// In en, this message translates to:
  /// **'Scanning crypto wallet...'**
  String get scanningWallet;

  /// Button label to open scanned URL in default browser
  ///
  /// In en, this message translates to:
  /// **'Open Link in Browser'**
  String get openLinkInBrowser;

  /// Warning message when opening a malicious link is blocked
  ///
  /// In en, this message translates to:
  /// **'Opening this link is blocked due to detected security threats.'**
  String get blockedLinkDesc;

  /// Error message when security analysis exceeds time limit
  ///
  /// In en, this message translates to:
  /// **'Analysis timed out. The service is taking longer than expected.'**
  String get analysisTimedOut;

  /// Generic error message when link security check fails
  ///
  /// In en, this message translates to:
  /// **'Unable to scan this link.'**
  String get unableToScanLink;

  /// Generic error message when crypto wallet check fails
  ///
  /// In en, this message translates to:
  /// **'Unable to scan this crypto wallet.'**
  String get unableToScanWallet;

  /// Message when scanned QR contains plain text instead of a URL
  ///
  /// In en, this message translates to:
  /// **'Scanned content is plain text, not a web link.'**
  String get plainTextNotLink;

  /// Error header title in scan sheet
  ///
  /// In en, this message translates to:
  /// **'Scan Error'**
  String get scanError;

  /// Verdict label for safe links
  ///
  /// In en, this message translates to:
  /// **'Safe'**
  String get safe;

  /// Description explaining safe link verdict
  ///
  /// In en, this message translates to:
  /// **'No security issues were found for this link.'**
  String get safeDesc;

  /// Verdict label for suspicious links
  ///
  /// In en, this message translates to:
  /// **'Potentially unsafe'**
  String get potentiallyUnsafe;

  /// Description explaining warning link verdict
  ///
  /// In en, this message translates to:
  /// **'Security checks found warning signs. Only open this link if you trust the source.'**
  String get potentiallyUnsafeDesc;

  /// Verdict label for dangerous/malicious links
  ///
  /// In en, this message translates to:
  /// **'Dangerous link'**
  String get dangerousLink;

  /// Description explaining malicious link verdict
  ///
  /// In en, this message translates to:
  /// **'Multiple security engines flagged this link as dangerous or malicious. Opening this link is strongly discouraged.'**
  String get dangerousLinkDesc;

  /// Status label for malicious crypto wallet
  ///
  /// In en, this message translates to:
  /// **'Malicious'**
  String get malicious;

  /// Status label for unverified crypto wallet
  ///
  /// In en, this message translates to:
  /// **'Unverified'**
  String get unverified;

  /// Description for unverified crypto wallet
  ///
  /// In en, this message translates to:
  /// **'Address unverified in threat databases. Verify recipient before sending funds.'**
  String get unverifiedDesc;

  /// Description for flagged malicious crypto wallet
  ///
  /// In en, this message translates to:
  /// **'This wallet was reported by a malicious-address data source.'**
  String get maliciousReportedDesc;

  /// Label for wallet safety check
  ///
  /// In en, this message translates to:
  /// **'Safety'**
  String get safety;

  /// Label for blockchain network name
  ///
  /// In en, this message translates to:
  /// **'Chain'**
  String get chain;

  /// Label for wallet balance
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get balance;

  /// Label for transaction history count
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactions;

  /// Label for wallet threat signals
  ///
  /// In en, this message translates to:
  /// **'Signals'**
  String get signals;

  /// Label for number of scanning engines
  ///
  /// In en, this message translates to:
  /// **'Engines Scanning'**
  String get enginesScanning;

  /// Button to expand all security engine results
  ///
  /// In en, this message translates to:
  /// **'Show All Engines'**
  String get showAllEngines;

  /// Button to collapse security engine results
  ///
  /// In en, this message translates to:
  /// **'Show Less'**
  String get showLess;

  /// Label indicating number of security checks completed
  ///
  /// In en, this message translates to:
  /// **'checks completed'**
  String get checksCompleted;

  /// Label indicating number of warnings found
  ///
  /// In en, this message translates to:
  /// **'warnings found'**
  String get warningsFound;

  /// Verdict or category label for phishing
  ///
  /// In en, this message translates to:
  /// **'Phishing'**
  String get phishing;

  /// Verdict or category label for suspicious
  ///
  /// In en, this message translates to:
  /// **'Suspicious'**
  String get suspicious;

  /// Section header for scanner engines results
  ///
  /// In en, this message translates to:
  /// **'Scanner results'**
  String get scannerResults;

  /// Count of scanner engines
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 engine} other{{count} engines}}'**
  String enginesCount(num count);

  /// Button to collapse list of security engines
  ///
  /// In en, this message translates to:
  /// **'Show fewer engines'**
  String get showFewerEngines;

  /// Button to expand list of all security engines
  ///
  /// In en, this message translates to:
  /// **'Show all {count} engines'**
  String showAllEnginesCount(int count);

  /// Badge text for number of warnings in accordion header
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 warning} other{{count} warnings}}'**
  String warningsCount(num count);

  /// Badge text for number of threats in accordion header
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 threat} other{{count} threats}}'**
  String threatsCount(num count);

  /// Subtext for safe URL item in results
  ///
  /// In en, this message translates to:
  /// **'Tap link to open in browser'**
  String get tapToOpenInBrowser;

  /// Subtext for warning URL item in results
  ///
  /// In en, this message translates to:
  /// **'Review warnings before opening'**
  String get reviewWarningsBeforeOpening;

  /// Subtext for malicious URL item in results
  ///
  /// In en, this message translates to:
  /// **'Link blocked due to security threats'**
  String get linkBlockedDueToThreats;

  /// Crypto wallet subtitle with network/chain label
  ///
  /// In en, this message translates to:
  /// **'{label} wallet'**
  String walletType(String label);

  /// Number of assets in wallet accordion header
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 asset} other{{count} assets}}'**
  String assetsCount(num count);

  /// Label for blockchain network
  ///
  /// In en, this message translates to:
  /// **'Network'**
  String get network;

  /// Label for wallet native balance
  ///
  /// In en, this message translates to:
  /// **'Native balance'**
  String get nativeBalance;

  /// Section header for wallet assets
  ///
  /// In en, this message translates to:
  /// **'Wallet assets'**
  String get walletAssets;

  /// Message when no assets are found for wallet
  ///
  /// In en, this message translates to:
  /// **'No assets found for this wallet.'**
  String get noAssetsFound;

  /// Button label to request Gemini AI security explanation
  ///
  /// In en, this message translates to:
  /// **'Explain with AI'**
  String get explainWithAi;

  /// Title of the AI security modal
  ///
  /// In en, this message translates to:
  /// **'AI Security Report'**
  String get aiSecurityReport;

  /// Loading state message while generating AI explanation
  ///
  /// In en, this message translates to:
  /// **'Gemini AI is analyzing security data...'**
  String get analyzingWithAi;

  /// Error title when AI analysis fails
  ///
  /// In en, this message translates to:
  /// **'AI analysis could not be completed'**
  String get aiAnalysisFailed;

  /// Section header for AI key security findings
  ///
  /// In en, this message translates to:
  /// **'Key Findings'**
  String get keyFindings;

  /// Section header for AI recommended action
  ///
  /// In en, this message translates to:
  /// **'Recommended Action'**
  String get recommendedAction;

  /// Button to re-run AI analysis
  ///
  /// In en, this message translates to:
  /// **'Regenerate'**
  String get regenerate;

  /// Explanation when Gemini API key is missing
  ///
  /// In en, this message translates to:
  /// **'Gemini API key is not configured. Run the app with --dart-define=GEMINI_API_KEY=your_key.'**
  String get apiKeyMissingDesc;

  /// Button label for hybrid AI security analysis
  ///
  /// In en, this message translates to:
  /// **'Hybrid AI Analysis'**
  String get hybridAiAnalysis;

  /// Title for hybrid AI security analysis sheet
  ///
  /// In en, this message translates to:
  /// **'Hybrid AI Security Report'**
  String get hybridAiReport;

  /// Loading message during multi-engine AI analysis
  ///
  /// In en, this message translates to:
  /// **'Multi-Engine AI is synthesizing on-chain & model intelligence...'**
  String get analyzingWithHybridAi;

  /// Warning when wallet is identified on threat intelligence index
  ///
  /// In en, this message translates to:
  /// **'Address associated with confirmed on-chain attack: {exploit}'**
  String knownExploitThreat(String exploit);

  /// Info label for verified safe Web3 protocol
  ///
  /// In en, this message translates to:
  /// **'Verified protocol / official address: {protocol}'**
  String verifiedProtocolLabel(String protocol);

  /// Threat signal for crypto mixer interaction
  ///
  /// In en, this message translates to:
  /// **'Direct interaction with cryptocurrency mixer (e.g. Tornado Cash)'**
  String get signalMixerInteraction;

  /// Threat signal for fast draining pattern
  ///
  /// In en, this message translates to:
  /// **'Immediate withdrawal of funds after deposit (< 2h - drainer pattern)'**
  String get signalFastDrain;

  /// Threat signal for high inflow/outflow transaction asymmetry
  ///
  /// In en, this message translates to:
  /// **'High transaction asymmetry (mass asset draining from multiple users)'**
  String get signalAsymmetricFlow;

  /// Threat signal for freshly created wallet address
  ///
  /// In en, this message translates to:
  /// **'Very new address (created within the last 72 hours)'**
  String get signalYoungWallet;

  /// Threat signal for Web3 brand impersonation in URL
  ///
  /// In en, this message translates to:
  /// **'Impersonating known Web3 brand (Brand Impersonation)'**
  String get signalBrandImpersonation;

  /// Threat signal for high-risk TLD
  ///
  /// In en, this message translates to:
  /// **'High-risk disposable domain TLD (.xyz, .top)'**
  String get signalHighRiskTld;

  /// Threat signal for high entropy domain name
  ///
  /// In en, this message translates to:
  /// **'High character entropy in domain (DGA pattern)'**
  String get signalDgaEntropy;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'fr',
    'it',
    'pl',
    'pt',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
    case 'pl':
      return AppLocalizationsPl();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
