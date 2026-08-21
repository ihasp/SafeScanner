import 'package:crypto_scanner/modules/scanner/ui/scanner_view.dart';
import 'package:crypto_scanner/modules/settings/providers/settings_notifier.dart';
import 'package:crypto_scanner/modules/settings/services/settings_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
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
