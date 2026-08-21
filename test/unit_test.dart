import 'package:crypto_scanner/helpers/crypto/address_decoder.dart';
import 'package:crypto_scanner/modules/results/providers/scan_results_notifier.dart';
import 'package:crypto_scanner/modules/results/services/scan_results_storage_service.dart';
import 'package:crypto_scanner/modules/security/models/Analysis.dart';
import 'package:crypto_scanner/modules/security/models/tatum_chain.dart';
import 'package:crypto_scanner/modules/settings/models/app_settings.dart';
import 'package:crypto_scanner/modules/settings/providers/settings_notifier.dart';
import 'package:crypto_scanner/modules/settings/services/settings_service.dart';
import 'package:crypto_scanner/shared/models/scan_mode.dart';
import 'package:crypto_scanner/shared/services/haptic_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AddressDecoder Word Boundary Tests', () {
    test('EVM regex does not match 64-char transaction hashes as standard address', () {
      // 64-char hex transaction hash
      const txHash =
          '0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef';
      final wallet = AddressDecoder.decode(txHash);
      expect(wallet, isNull);
    });

    test('EVM regex accurately decodes 40-char EVM address with 0x prefix', () {
      const validAddress = '0x1234567890abcdef1234567890abcdef12345678';
      final wallet = AddressDecoder.decode(validAddress);
      expect(wallet, isNotNull);
      expect(wallet!.address, equals(validAddress));
      expect(wallet.chain, equals(TatumChain.ethereumMainnet));
    });
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

  group('HapticService Unit Tests', () {
    test('Does not trigger haptic feedback when enabled is false', () async {
      final log = <MethodCall>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (call) async {
            log.add(call);
            return null;
          });

      await HapticService.success(enabled: false);
      await HapticService.error(enabled: false);
      await HapticService.selection(enabled: false);
      await HapticService.vibrate(enabled: false);

      expect(log, isEmpty);
    });

    test('Triggers haptic feedback when enabled is true', () async {
      final log = <MethodCall>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (call) async {
            log.add(call);
            return null;
          });

      await HapticService.success(enabled: true);
      await HapticService.error(enabled: true);
      await HapticService.selection(enabled: true);
      await HapticService.vibrate(enabled: true);

      expect(log.length, equals(4));
      expect(
        log.map((call) => call.method).toList(),
        everyElement(equals('HapticFeedback.vibrate')),
      );
    });
  });
}
