import 'package:crypto_scanner/helpers/crypto/address_decoder.dart';
import 'package:crypto_scanner/helpers/crypto/decision_maker.dart';
import 'package:crypto_scanner/helpers/scanner/scan_mode_detector.dart';
import 'package:crypto_scanner/helpers/security/analysis_status_resolver.dart';
import 'package:crypto_scanner/modules/security/models/analysis_model.dart';
import 'package:crypto_scanner/modules/security/models/crypto_decision.dart';
import 'package:crypto_scanner/modules/security/models/crypto_wallet_scan.dart';
import 'package:crypto_scanner/modules/security/models/tatum_models.dart';
import 'package:crypto_scanner/shared/models/scan_mode.dart';
import 'package:flutter_test/flutter_test.dart';

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
      const url = 'https://example.com/verify/7xKXtg2CW87d97TXJSDpbD5jBkheTqA83TZRuJosgAsU';
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
        safety: TatumMaliciousAddressCheck(status: MaliciousCheckStatus.unknown),
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
      expect(resolved.riskCount, equals(0));
      expect(resolved.resultCounts.total, equals(2));
    });

    test('Resolves completed analysis with malicious engine as unsafe', () {
      const analysis = Analysis(
        data: AnalysisData(
          attributes: AnalysisAttributes(
            status: AnalysisStatus.completed,
            results: {
              'Kaspersky': EngineResult(category: 'malicious', result: 'malware'),
              'Google': EngineResult(category: 'harmless', result: 'clean'),
            },
          ),
        ),
      );
      final resolved = AnalysisStatusResolver.resolve(analysis);
      expect(resolved.isSafe, isFalse);
      expect(resolved.riskCount, equals(1));
      expect(resolved.resultCounts.malicious, equals(1));
    });
  });
}
