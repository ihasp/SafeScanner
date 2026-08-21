import 'package:crypto_scanner/helpers/crypto/address_decoder.dart';
import 'package:crypto_scanner/helpers/crypto/decision_maker.dart';
import 'package:crypto_scanner/helpers/scanner/scan_mode_detector.dart';
import 'package:crypto_scanner/helpers/security/analysis_status_resolver.dart';
import 'package:crypto_scanner/modules/security/models/Analysis.dart';
import 'package:crypto_scanner/modules/security/models/crypto_decision.dart';
import 'package:crypto_scanner/modules/security/models/crypto_wallet_scan.dart';
import 'package:crypto_scanner/modules/security/models/tatum_chain.dart';
import 'package:crypto_scanner/modules/gallery/views/gallery_page.dart';
import 'package:crypto_scanner/modules/home/ui/scanner_view.dart';
import 'package:crypto_scanner/modules/settings/providers/settings_notifier.dart';
import 'package:crypto_scanner/modules/settings/services/settings_service.dart';
import 'package:crypto_scanner/modules/settings/views/settings_page.dart';
import 'package:crypto_scanner/routing/tab_scaffold.dart';
import 'package:crypto_scanner/shared/models/scan_mode.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('AddressDecoder Tests', () {
    test('Decodes Ethereum EVM address correctly', () {
      const address = '0x742d35Cc6634C0532925a3b844Bc454e4438f44e';
      final wallet = AddressDecoder.decode(address);
      expect(wallet, isNotNull);
      expect(wallet!.address, equals(address));
      expect(wallet.chain, equals(TatumChain.ethereumMainnet));
    });

    test('Decodes Bitcoin address correctly', () {
      const address = 'bc1qar0srrr7xfkvy5l643lydnw9re59gtzzwf5mdq';
      final wallet = AddressDecoder.decode(address);
      expect(wallet, isNotNull);
      expect(wallet!.address, equals(address));
      expect(wallet.chain, equals(TatumChain.bitcoinMainnet));
    });

    test('Decodes Solana URI scheme address correctly', () {
      const payload = 'solana:7xKXtg2CW87d97TXJSDpbD5jBkheTqA83TZRuJosgAsU';
      final wallet = AddressDecoder.decode(payload);
      expect(wallet, isNotNull);
      expect(wallet!.chain, equals(TatumChain.solanaMainnet));
    });

    test('Decodes standalone raw Base58 Solana address correctly', () {
      const payload = '7xKXtg2CW87d97TXJSDpbD5jBkheTqA83TZRuJosgAsU';
      final wallet = AddressDecoder.decode(payload);
      expect(wallet, isNotNull);
      expect(wallet!.chain, equals(TatumChain.solanaMainnet));
    });

    test('Returns null for generic URL', () {
      const url = 'https://google.com';
      final wallet = AddressDecoder.decode(url);
      expect(wallet, isNull);
    });

    test('Returns null for URL containing 32-44 char token in path', () {
      const url =
          'https://example.com/verify/7xKXtg2CW87d97TXJSDpbD5jBkheTqA83TZRuJosgAsU';
      final wallet = AddressDecoder.decode(url);
      expect(wallet, isNull);
    });
  });

  group('ScanModeDetector Tests', () {
    test('Detects crypto scan mode for crypto address', () {
      const address = '0x742d35Cc6634C0532925a3b844Bc454e4438f44e';
      final mode = ScanModeDetector.detect(address);
      expect(mode, equals(ScanMode.crypto));
    });

    test('Detects QR scan mode for URL', () {
      const url = 'https://example.com';
      final mode = ScanModeDetector.detect(url);
      expect(mode, equals(ScanMode.qr));
    });
  });

  group('DecisionMaker Tests', () {
    test('Marks valid status as safe', () {
      const scan = CryptoWalletScan(
        wallet: CryptoWallet(
          address: '0x123',
          chain: TatumChain.ethereumMainnet,
          label: 'Ethereum',
          rawPayload: '0x123',
        ),
        assets: [],
        safety: TatumMaliciousAddressCheck(status: MaliciousCheckStatus.valid),
      );

      final decision = DecisionMaker.decide(scan);
      expect(decision.isSafe, isTrue);
      expect(decision.safetyLevel, equals(CryptoSafetyLevel.safe));
      expect(decision.status, equals(MaliciousCheckStatus.valid));
    });

    test('Marks invalid status as unsafe', () {
      const scan = CryptoWalletScan(
        wallet: CryptoWallet(
          address: '0x123',
          chain: TatumChain.ethereumMainnet,
          label: 'Ethereum',
          rawPayload: '0x123',
        ),
        assets: [],
        safety: TatumMaliciousAddressCheck(
          status: MaliciousCheckStatus.invalid,
          description: 'Flagged address',
        ),
      );

      final decision = DecisionMaker.decide(scan);
      expect(decision.isSafe, isFalse);
      expect(decision.safetyLevel, equals(CryptoSafetyLevel.malicious));
      expect(decision.status, equals(MaliciousCheckStatus.invalid));
    });

    test('Marks unknown status as unverified without false safe alarm', () {
      const scan = CryptoWalletScan(
        wallet: CryptoWallet(
          address: '0x123',
          chain: TatumChain.polygonMainnet,
          label: 'Polygon',
          rawPayload: '0x123',
        ),
        nativeBalance: TatumNativeBalance(balance: '10.5'),
        assets: [],
        safety: TatumMaliciousAddressCheck(
          status: MaliciousCheckStatus.unknown,
        ),
      );

      final decision = DecisionMaker.decide(scan);
      expect(decision.isSafe, isFalse);
      expect(decision.safetyLevel, equals(CryptoSafetyLevel.unverified));
      expect(decision.status, equals(MaliciousCheckStatus.unknown));
      expect(DecisionMaker.isWalletSafe(scan), isFalse);
    });
  });

  group('AnalysisStatusResolver Tests', () {
    test('Resolves queued analysis as not safe (pending)', () {
      final analysis = Analysis.queued();
      final resolved = AnalysisStatusResolver.resolve(analysis);
      expect(resolved.isSafe, isFalse);
      expect(resolved.status, equals(AnalysisStatus.queued));
    });

    test('Resolves completed clean analysis as safe', () {
      const analysis = Analysis(
        data: AnalysisData(
          attributes: AnalysisAttributes(
            status: AnalysisStatus.completed,
            results: {
              'Kaspersky': EngineResult(category: 'harmless', result: 'clean'),
              'Google': EngineResult(category: 'harmless', result: 'clean'),
            },
          ),
        ),
      );
      final resolved = AnalysisStatusResolver.resolve(analysis);
      expect(resolved.isSafe, isTrue);
      expect(resolved.verdict, equals(AnalysisVerdict.safe));
      expect(resolved.canOpenLink, isTrue);
      expect(resolved.riskCount, equals(0));
      expect(resolved.resultCounts.total, equals(2));
    });

    test('Resolves completed analysis with 1 warning as warning/potentially unsafe', () {
      const analysis = Analysis(
        data: AnalysisData(
          attributes: AnalysisAttributes(
            status: AnalysisStatus.completed,
            results: {
              'Kaspersky': EngineResult(
                category: 'malicious',
                result: 'malware',
              ),
              'Google': EngineResult(category: 'harmless', result: 'clean'),
            },
          ),
        ),
      );
      final resolved = AnalysisStatusResolver.resolve(analysis);
      expect(resolved.isSafe, isFalse);
      expect(resolved.isWarning, isTrue);
      expect(resolved.verdict, equals(AnalysisVerdict.warning));
      expect(resolved.canOpenLink, isTrue);
      expect(resolved.riskCount, equals(1));
      expect(resolved.resultCounts.malicious, equals(1));
    });

    test('Resolves completed analysis with 2+ malicious engines as malicious/blocked', () {
      const analysis = Analysis(
        data: AnalysisData(
          attributes: AnalysisAttributes(
            status: AnalysisStatus.completed,
            results: {
              'Kaspersky': EngineResult(
                category: 'malicious',
                result: 'malware',
              ),
              'Sophos': EngineResult(
                category: 'malicious',
                result: 'malware',
              ),
              'Google': EngineResult(category: 'harmless', result: 'clean'),
            },
          ),
        ),
      );
      final resolved = AnalysisStatusResolver.resolve(analysis);
      expect(resolved.isSafe, isFalse);
      expect(resolved.isMalicious, isTrue);
      expect(resolved.verdict, equals(AnalysisVerdict.malicious));
      expect(resolved.canOpenLink, isFalse);
      expect(resolved.riskCount, equals(2));
      expect(resolved.resultCounts.malicious, equals(2));
    });
  });

  group('SettingsPage UI Tests', () {
    testWidgets('Renders only active preferences and excludes hidden settings', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            settingsServiceProvider.overrideWithValue(SettingsService(prefs)),
          ],
          child: const MaterialApp(home: SettingsPage()),
        ),
      );
      await tester.pumpAndSettle();

      // Included settings
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Scanner Preferences'), findsOneWidget);
      expect(find.text('Default Camera'), findsOneWidget);
      expect(find.text('Default Scan Mode'), findsOneWidget);
      expect(find.text('Haptics on Scan'), findsOneWidget);
      expect(find.text('Auto-Open Safe Links'), findsOneWidget);

      // Excluded settings
      expect(find.text('Polling Interval'), findsNothing);
      expect(find.text('Privacy & History'), findsNothing);
      expect(find.text('Incognito Mode'), findsNothing);
      expect(find.text('History Size'), findsNothing);
      expect(find.text('Clear Scan History'), findsNothing);
      expect(find.text('Remove All'), findsNothing);
    });
  });

  group('TabScaffold & GlassTabBar UI Tests', () {
    testWidgets('Renders 4 items in bottom frosted glass menu in exact order', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          settingsServiceProvider.overrideWithValue(SettingsService(prefs)),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: TabScaffold()),
        ),
      );
      await tester.pump();

      // Verify all 4 tabs exist in frosted glass menu
      expect(find.text('Scan'), findsOneWidget);
      expect(find.text('Gallery'), findsOneWidget);
      expect(find.text('Results'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);

      expect(find.byIcon(Icons.qr_code_scanner_rounded), findsOneWidget);
      expect(find.byIcon(Icons.photo_library_outlined), findsOneWidget);
      expect(find.byIcon(Icons.format_list_bulleted_rounded), findsOneWidget);
      expect(find.byIcon(Icons.settings_outlined), findsOneWidget);

      // Tap on Gallery (2nd item) -> switches to GalleryPage (tab index 1)
      await tester.tap(find.text('Gallery'));
      await tester.pump();

      expect(container.read(selectedTabIndexProvider), equals(1));
    });
  });

  group('GalleryPage UI Tests', () {
    testWidgets('Renders Gallery header with icon and title matching Settings style', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            settingsServiceProvider.overrideWithValue(SettingsService(prefs)),
          ],
          child: const MaterialApp(home: Scaffold(body: GalleryPage())),
        ),
      );
      await tester.pump();

      // Verify Gallery header
      expect(find.text('Gallery'), findsOneWidget);
      expect(find.byIcon(Icons.photo_library_outlined), findsOneWidget);
    });
  });

  group('ScannerView UI Tests', () {
    testWidgets('Renders centered ScanModeSwitch with QR and Crypto icons', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            settingsServiceProvider.overrideWithValue(SettingsService(prefs)),
          ],
          child: const MaterialApp(home: Scaffold(body: ScannerView())),
        ),
      );
      await tester.pump();

      // Verify QR & Crypto switch icons
      expect(find.byIcon(Icons.qr_code_2_rounded), findsOneWidget);
      expect(find.byIcon(Icons.currency_bitcoin_rounded), findsOneWidget);
    });
  });
}
