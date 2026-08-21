import 'package:crypto_scanner/l10n/l10n.dart';
import 'package:crypto_scanner/modules/security/models/analysis.dart';
import 'package:crypto_scanner/modules/security/models/crypto_scan_state.dart';
import 'package:crypto_scanner/modules/security/ui/scanned_layout_sheet.dart';
import 'package:crypto_scanner/modules/settings/providers/settings_notifier.dart';
import 'package:crypto_scanner/modules/settings/services/settings_service.dart';
import 'package:crypto_scanner/shared/models/scan_mode.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('ScannedLayoutSheet Tests', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    testWidgets('Displays styled error box when analysis fails', (
      tester,
    ) async {
      final failedAnalysis = Analysis.failed(
        error: 'VirusTotal rate limit exceeded. Please try again in a moment.',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            settingsServiceProvider.overrideWithValue(SettingsService(prefs)),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: ScannedLayoutSheet(
                data: 'https://example.com',
                analysis: failedAnalysis,
                scanMode: ScanMode.qr,
                onClose: () {},
                onCloseStart: () {},
                onRetry: () async {},
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Scan Error'), findsOneWidget);
      expect(
        find.text(
          'VirusTotal rate limit exceeded. Please try again in a moment.',
        ),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
    });

    testWidgets('Displays styled error box when crypto wallet scan fails', (
      tester,
    ) async {
      final cryptoScan = CryptoScanState.failed(
        'Unable to scan this crypto wallet.',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            settingsServiceProvider.overrideWithValue(SettingsService(prefs)),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: ScannedLayoutSheet(
                data: '0x1234567890abcdef1234567890abcdef12345678',
                cryptoScan: cryptoScan,
                scanMode: ScanMode.crypto,
                onClose: () {},
                onCloseStart: () {},
                onRetry: () async {},
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Scan Error'), findsOneWidget);
      expect(
        find.text('Unable to scan this crypto wallet.'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
    });

    testWidgets('Stops polling and displays error when updated to failed state', (
      tester,
    ) async {
      int retryCalls = 0;
      final queuedAnalysis = Analysis.queued();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            settingsServiceProvider.overrideWithValue(SettingsService(prefs)),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: ScannedLayoutSheet(
                data: 'https://example.com',
                analysis: queuedAnalysis,
                scanMode: ScanMode.qr,
                onClose: () {},
                onCloseStart: () {},
                onRetry: () async {
                  retryCalls++;
                },
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1050));
      expect(retryCalls, greaterThanOrEqualTo(1));

      // Update widget with failed analysis
      final failedAnalysis = Analysis.failed(error: 'Network connection lost.');
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            settingsServiceProvider.overrideWithValue(SettingsService(prefs)),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: ScannedLayoutSheet(
                data: 'https://example.com',
                analysis: failedAnalysis,
                scanMode: ScanMode.qr,
                onClose: () {},
                onCloseStart: () {},
                onRetry: () async {
                  retryCalls++;
                },
              ),
            ),
          ),
        ),
      );

      final callsAfterFail = retryCalls;
      await tester.pump(const Duration(milliseconds: 2000));
      expect(retryCalls, equals(callsAfterFail));
      expect(find.text('Scan Error'), findsOneWidget);
      expect(find.text('Network connection lost.'), findsOneWidget);
    });
  });
}
