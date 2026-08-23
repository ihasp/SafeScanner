import 'package:crypto_scanner/modules/security/services/threat_intelligence_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ThreatIntelligenceRegistry Tests', () {
    test('Identifies Euler Finance exploit address case-insensitively', () {
      const lower = '0xb66cd966670d962c227b3eabe305290249014aed';
      const upper = '0xB66CD966670D962C227B3EABE305290249014AED';

      expect(
        ThreatIntelligenceRegistry.getKnownMaliciousDescription(lower),
        contains('Euler Finance'),
      );
      expect(
        ThreatIntelligenceRegistry.getKnownMaliciousDescription(upper),
        contains('Euler Finance'),
      );
      expect(ThreatIntelligenceRegistry.isKnownMalicious(lower), isTrue);
      expect(ThreatIntelligenceRegistry.isKnownMalicious(upper), isTrue);
    });

    test('Identifies Nomad Bridge and Lazarus attacks correctly', () {
      expect(
        ThreatIntelligenceRegistry.getKnownMaliciousDescription(
          '0x5b5e2bf3606ecd00ea47a74f73f2d91af24ca939',
        ),
        contains('Nomad Bridge'),
      );
      expect(
        ThreatIntelligenceRegistry.getKnownMaliciousDescription(
          '0x098b716b8aaf21512996dc57eb0615e2383e2f96',
        ),
        contains('Ronin Bridge'),
      );
      expect(
        ThreatIntelligenceRegistry.getKnownMaliciousDescription(
          '0x6b306b301a5d6a2f4c398418f731a59cb4a589f6',
        ),
        contains('WazirX'),
      );
    });

    test('Identifies Bitcoin Ransomware and Drainers correctly', () {
      expect(
        ThreatIntelligenceRegistry.getKnownMaliciousDescription(
          '1ez69snzzmepmykjxlifgu4vkxrwbcuubj',
        ),
        contains('WannaCry'),
      );
      expect(
        ThreatIntelligenceRegistry.getKnownMaliciousDescription(
          '0x0000db5c8b030ae20308ac975898e09741e70000',
        ),
        contains('Inferno Drainer'),
      );
    });

    test('Identifies verified protocols and official infrastructure correctly', () {
      const uniswapRouter = '0x7a250d5630b4cf539739df2c5dacb4c659f2488d';
      const vitalikEth = '0xd8da6bf26964af9d7eed9e03e53415d37aa96045';
      const chainlinkEth = '0x5f4ec3df9cbd43714fe2740f5e3616155c5b8419';
      const oneInchV6 = '0x111111125421ca6dc452d289314280a0f8842a65';

      expect(
        ThreatIntelligenceRegistry.getKnownSafeLabel(uniswapRouter),
        contains('Uniswap'),
      );
      expect(
        ThreatIntelligenceRegistry.getKnownSafeLabel(vitalikEth),
        contains('vitalik.eth'),
      );
      expect(
        ThreatIntelligenceRegistry.getKnownSafeLabel(chainlinkEth),
        contains('Chainlink'),
      );
      expect(
        ThreatIntelligenceRegistry.getKnownSafeLabel(oneInchV6),
        contains('1inch'),
      );
      expect(
        ThreatIntelligenceRegistry.isKnownSafe(uniswapRouter),
        isTrue,
      );
      expect(
        ThreatIntelligenceRegistry.isKnownSafe(chainlinkEth),
        isTrue,
      );
    });

    test('Returns null for unknown random addresses', () {
      const randomAddr = '0x1111111111111111111111111111111111111111';

      expect(
        ThreatIntelligenceRegistry.getKnownMaliciousDescription(randomAddr),
        isNull,
      );
      expect(
        ThreatIntelligenceRegistry.getKnownSafeLabel(randomAddr),
        isNull,
      );
      expect(
        ThreatIntelligenceRegistry.isKnownMalicious(randomAddr),
        isFalse,
      );
      expect(
        ThreatIntelligenceRegistry.isKnownSafe(randomAddr),
        isFalse,
      );
    });

    test('All maps are unmodifiable and contain extensive datasets', () {
      expect(ThreatIntelligenceRegistry.allMaliciousWallets.length, greaterThan(30));
      expect(ThreatIntelligenceRegistry.allSafeWallets.length, greaterThan(30));
      expect(
        () => ThreatIntelligenceRegistry.allMaliciousWallets['test'] = 'test',
        throwsUnsupportedError,
      );
    });
  });
}
