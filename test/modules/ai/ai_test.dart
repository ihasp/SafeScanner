import 'package:crypto_scanner/modules/ai/models/ai_security_explanation.dart';
import 'package:crypto_scanner/modules/ai/services/gemini_ai_service.dart';
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

  group('AiSecurityExplanation Model Tests', () {
    test('Serializes to JSON and deserializes back accurately', () {
      final original = AiSecurityExplanation(
        headline: 'Phishing Threat Detected',
        summary: 'This site mimics a bank login to steal credentials.',
        riskLevel: AiRiskLevel.malicious,
        keyFindings: ['Flagged by 3 security engines', 'Spoofed domain name'],
        recommendedAction: 'Do not enter passwords.',
        generatedAt: DateTime(2026, 8, 21, 22, 0),
      );

      final json = original.toJson();
      final fromJson = AiSecurityExplanation.fromJson(json);

      expect(fromJson.headline, equals(original.headline));
      expect(fromJson.summary, equals(original.summary));
      expect(fromJson.riskLevel, equals(AiRiskLevel.malicious));
      expect(fromJson.keyFindings, equals(original.keyFindings));
      expect(fromJson.recommendedAction, equals(original.recommendedAction));
      expect(fromJson.generatedAt, equals(original.generatedAt));
    });

    test('AiRiskLevel maps various strings properly', () {
      expect(AiRiskLevel.fromString('safe'), equals(AiRiskLevel.safe));
      expect(AiRiskLevel.fromString('clean'), equals(AiRiskLevel.safe));
      expect(AiRiskLevel.fromString('low'), equals(AiRiskLevel.safe));
      expect(AiRiskLevel.fromString('warning'), equals(AiRiskLevel.warning));
      expect(AiRiskLevel.fromString('suspicious'), equals(AiRiskLevel.warning));
      expect(AiRiskLevel.fromString('malicious'), equals(AiRiskLevel.malicious));
      expect(AiRiskLevel.fromString('dangerous'), equals(AiRiskLevel.malicious));
      expect(AiRiskLevel.fromString('critical'), equals(AiRiskLevel.malicious));
      expect(AiRiskLevel.fromString('other'), equals(AiRiskLevel.unverified));
    });
  });

  group('GeminiAiService Unit Tests', () {
    test('Throws GeminiMissingApiKeyException when no API key is set', () async {
      const service = GeminiAiService(apiKey: '');
      expect(
        () => service.explainUrlScan(
          url: 'https://test.com',
          analysis: Analysis.queued(),
          languageCode: 'en',
        ),
        throwsA(isA<GeminiMissingApiKeyException>()),
      );
    });
  });

  group('ScanResultsNotifier AI Caching Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Attaches AI explanation to scan result and persists it', () async {
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

      container
          .read(scanResultsProvider.notifier)
          .addUrlScan(data: 'https://phishing.com', analysis: Analysis.queued());

      final scan = container.read(scanResultsProvider).first;
      expect(scan.aiExplanation, isNull);

      final explanation = AiSecurityExplanation(
        headline: 'Phishing Threat',
        summary: 'Dangerous link.',
        riskLevel: AiRiskLevel.malicious,
        keyFindings: ['Flagged by engines'],
        recommendedAction: 'Close tab.',
        generatedAt: DateTime.now(),
      );

      container
          .read(scanResultsProvider.notifier)
          .updateAiExplanation(scan.id, explanation);

      final updatedScan = container.read(scanResultsProvider).first;
      expect(updatedScan.aiExplanation, isNotNull);
      expect(updatedScan.aiExplanation!.headline, equals('Phishing Threat'));

      // Check persistence in SharedPreferences
      final storage = ScanResultsStorageService(prefs);
      final persistedScans = storage.loadScansSync();
      expect(persistedScans.first.aiExplanation, isNotNull);
      expect(
        persistedScans.first.aiExplanation!.headline,
        equals('Phishing Threat'),
      );
    });
  });
}
