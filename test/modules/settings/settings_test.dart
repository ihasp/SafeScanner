import 'package:crypto_scanner/modules/settings/models/app_settings.dart';
import 'package:crypto_scanner/modules/settings/providers/settings_notifier.dart';
import 'package:crypto_scanner/modules/settings/services/settings_service.dart';
import 'package:crypto_scanner/modules/settings/views/settings_page.dart';
import 'package:crypto_scanner/shared/models/scan_mode.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Riverpod SettingsNotifier Unit Tests', () {
    test('Reads default settings and updates correctly', () async {
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          settingsServiceProvider.overrideWithValue(SettingsService(prefs)),
        ],
      );
      addTearDown(container.dispose);

      final initialSettings = container.read(settingsProvider);
      expect(initialSettings.defaultCameraFacing, equals(AppCameraFacing.back));
      expect(initialSettings.defaultScanMode, equals(ScanMode.qr));
      expect(initialSettings.hapticsEnabled, isTrue);
      expect(initialSettings.autoOpenSafeLinks, isFalse);
      expect(initialSettings.historySizeLimit, equals(20));

      container
          .read(settingsProvider.notifier)
          .setDefaultCameraFacing(AppCameraFacing.front);
      expect(
        container.read(settingsProvider).defaultCameraFacing,
        equals(AppCameraFacing.front),
      );

      container.read(settingsProvider.notifier).setIncognitoMode(true);
      expect(container.read(settingsProvider).incognitoMode, isTrue);

      container.read(settingsProvider.notifier).setHistorySizeLimit(5);
      expect(container.read(settingsProvider).historySizeLimit, equals(5));
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
}
