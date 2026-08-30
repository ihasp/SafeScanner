import 'package:crypto_scanner/modules/security/logic/analysis_status_resolver.dart';
import 'package:crypto_scanner/modules/security/models/analysis.dart';
import 'package:crypto_scanner/modules/security/services/badblock_whitelist_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BadBlockWhitelistService ABP Parsing Tests', () {
    test('Correctly parses standard and modified ABP whitelist rules', () {
      const mockRules = r'''
! Title: ✋ BadBlock - Whitelist (ABP)
! Version: 02July2026v1
! Expires: 1 hour
! Description: Unblock the good!
---
@@|accrescent.app^
@@|android.clients.google.com^
@@|app.futo.org^
@@||aainflight.com^$important
||0.datadog.pool.ntp.org^$important
@@|crl*.amazontrust.com^$important
@@|apple.com^$important
''';

      final parsed = BadBlockWhitelistService.parseRules(mockRules);

      expect(parsed.exactDomains, contains('accrescent.app'));
      expect(parsed.exactDomains, contains('android.clients.google.com'));
      expect(parsed.exactDomains, contains('app.futo.org'));
      expect(parsed.exactDomains, contains('aainflight.com'));
      expect(parsed.exactDomains, contains('0.datadog.pool.ntp.org'));
      expect(parsed.exactDomains, contains('apple.com'));
      expect(parsed.wildcardPatterns.length, 1);
      expect(
        parsed.wildcardPatterns.first.hasMatch('crl1.amazontrust.com'),
        isTrue,
      );
      expect(
        parsed.wildcardPatterns.first.hasMatch('crl-prod.amazontrust.com'),
        isTrue,
      );
      expect(
        parsed.wildcardPatterns.first.hasMatch('other.amazontrust.com'),
        isFalse,
      );
    });

    test('extractDomain correctly normalizes and parses URLs and hosts', () {
      expect(
        BadBlockWhitelistService.extractDomain('https://accrescent.app/docs'),
        'accrescent.app',
      );
      expect(
        BadBlockWhitelistService.extractDomain(
          'http://android.clients.google.com:8080/auth?token=1#hash',
        ),
        'android.clients.google.com',
      );
      expect(
        BadBlockWhitelistService.extractDomain('apple.com'),
        'apple.com',
      );
      expect(
        BadBlockWhitelistService.extractDomain(''),
        isNull,
      );
    });
  });

  group('BadBlockWhitelistService Matching Tests', () {
    test(
      'isWhitelisted returns true for exact and subdomains of whitelisted rules',
      () async {
        const mockRules = r'''
@@|accrescent.app^
@@|android.clients.google.com^
@@|apple.com^$important
@@|crl*.amazontrust.com^$important
''';
        SharedPreferences.setMockInitialValues({
          'badblock_whitelist_cache': mockRules,
          'badblock_whitelist_last_sync': DateTime.now().millisecondsSinceEpoch,
        });
        final prefs = await SharedPreferences.getInstance();
        final testService = BadBlockWhitelistService(prefs: prefs);
        await testService.loadFromCache();

        // Specific formatting requirement: @@|android.clients.google.com^
        expect(
          testService.isWhitelisted('https://android.clients.google.com/test'),
          isTrue,
        );
        expect(
          testService.isWhitelisted('http://android.clients.google.com'),
          isTrue,
        );
        expect(
          testService.isWhitelisted('android.clients.google.com'),
          isTrue,
        );

        // Exact domain
        expect(
          testService.isWhitelisted('https://accrescent.app/download'),
          isTrue,
        );
        expect(
          testService.isWhitelisted('https://www.accrescent.app'),
          isTrue,
        );

        // Parent domain hierarchy (apple.com matches apps.apple.com)
        expect(
          testService.isWhitelisted('https://apps.apple.com/app/id123'),
          isTrue,
        );
        expect(
          testService.isWhitelisted('https://developer.apple.com'),
          isTrue,
        );

        // Wildcard matching
        expect(
          testService.isWhitelisted('https://crl1.amazontrust.com/root.crl'),
          isTrue,
        );

        // Non-whitelisted domain
        expect(
          testService.isWhitelisted('https://malicious-crypto-drainer.xyz'),
          isFalse,
        );
        expect(
          testService.isWhitelisted('https://untrusted-site.com'),
          isFalse,
        );
      },
    );
  });

  group('Analysis.whitelisted and Status Resolver Tests', () {
    test(
      'Creates safe analysis verdict instantly without external engines',
      () {
        final analysis = Analysis.whitelisted(
          url: 'https://android.clients.google.com',
        );

        expect(analysis.error, isNull);
        expect(analysis.data.attributes.status, AnalysisStatus.completed);
        expect(
          analysis.data.attributes.results.containsKey('BadBlock Whitelist'),
          isTrue,
        );

        final resolved = AnalysisStatusResolver.resolve(analysis);
        expect(resolved.isSafe, isTrue);
        expect(resolved.isMalicious, isFalse);
        expect(resolved.isWarning, isFalse);
        expect(resolved.canOpenLink, isTrue);
        expect(resolved.verdict, AnalysisVerdict.safe);
        expect(resolved.riskCount, 0);
        expect(resolved.sortedResults.first.key, 'BadBlock Whitelist');
        expect(resolved.sortedResults.first.text, 'Safe');
      },
    );
  });

  group('BadBlockWhitelistService Network Sync and Caching Tests', () {
    test(
      'syncWhitelist downloads remote rules and updates persistent cache',
      () async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();

        final mockClient = MockClient((request) async {
          if (request.url.toString() ==
              'https://badblock.celenity.dev/abp/whitelist.txt') {
            return http.Response(
              '@@|android.clients.google.com^\n@@|f-droid.org^',
              200,
            );
          }
          return http.Response('Not found', 404);
        });

        final service = BadBlockWhitelistService(
          client: mockClient,
          prefs: prefs,
        );

        expect(service.domainCount, 0);

        final synced = await service.syncWhitelist(force: true);
        expect(synced, isTrue);
        expect(service.domainCount, 2);
        expect(service.isWhitelisted('https://f-droid.org'), isTrue);
        expect(
          service.isWhitelisted('https://android.clients.google.com'),
          isTrue,
        );

        // Verify cached in SharedPreferences
        expect(
          prefs.getString('badblock_whitelist_cache'),
          '@@|android.clients.google.com^\n@@|f-droid.org^',
        );
        expect(prefs.getInt('badblock_whitelist_last_sync'), isNotNull);
      },
    );

    test(
      'syncWhitelist handles network errors gracefully without crashing',
      () async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();

        final mockClient = MockClient((request) async {
          return http.Response('Server Error', 500);
        });

        final service = BadBlockWhitelistService(
          client: mockClient,
          prefs: prefs,
        );

        final synced = await service.syncWhitelist(force: true);
        expect(synced, isFalse);
      },
    );
  });
}
