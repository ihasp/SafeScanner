import 'package:crypto_scanner/modules/results/providers/scan_results_notifier.dart';
import 'package:crypto_scanner/modules/results/services/scan_results_storage_service.dart';
import 'package:crypto_scanner/modules/security/models/analysis.dart';
import 'package:crypto_scanner/modules/settings/providers/settings_notifier.dart';
import 'package:crypto_scanner/modules/settings/services/settings_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Riverpod ScanResultsNotifier Unit Tests', () {
    test('Adds scan, respects limit, and clears scans', () async {
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          settingsServiceProvider.overrideWithValue(SettingsService(prefs)),
          scanResultsStorageServiceProvider.overrideWithValue(
            ScanResultsStorageService(prefs),
          ),
        ],
      );
      addTearDown(container.dispose);

      // Set history limit to 2
      container.read(settingsProvider.notifier).setHistorySizeLimit(2);

      // Add 3 scans
      container
          .read(scanResultsProvider.notifier)
          .addUrlScan(data: 'https://site1.com', analysis: Analysis.queued());
      container
          .read(scanResultsProvider.notifier)
          .addUrlScan(data: 'https://site2.com', analysis: Analysis.queued());
      container
          .read(scanResultsProvider.notifier)
          .addUrlScan(data: 'https://site3.com', analysis: Analysis.queued());

      final scans = container.read(scanResultsProvider);
      expect(scans.length, equals(2));
      expect(scans.first.data, equals('https://site3.com'));

      // Clear scans
      container.read(scanResultsProvider.notifier).clearScans();
      expect(container.read(scanResultsProvider), isEmpty);
    });

    test('Bypasses scan storage when incognito mode is enabled', () async {
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          settingsServiceProvider.overrideWithValue(SettingsService(prefs)),
          scanResultsStorageServiceProvider.overrideWithValue(
            ScanResultsStorageService(prefs),
          ),
        ],
      );
      addTearDown(container.dispose);

      container.read(settingsProvider.notifier).setIncognitoMode(true);
      container
          .read(scanResultsProvider.notifier)
          .addUrlScan(
            data: 'https://incognito-test.com',
            analysis: Analysis.queued(),
          );

      expect(container.read(scanResultsProvider), isEmpty);
    });
  });
}
