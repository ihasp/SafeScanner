import 'package:crypto_scanner/modules/scanner/logic/qr_payload_parser.dart';
import 'package:crypto_scanner/modules/scanner/logic/scan_mode_detector.dart';
import 'package:crypto_scanner/shared/models/scan_mode.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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

  group('QrPayloadParser Tests', () {
    test('Sanitizes leading and trailing whitespace', () {
      expect(
        QrPayloadParser.sanitize('  https://example.com  '),
        equals('https://example.com'),
      );
    });

    test('Validates non-empty payload correctly', () {
      expect(QrPayloadParser.isValid('https://example.com'), isTrue);
      expect(QrPayloadParser.isValid(''), isFalse);
      expect(QrPayloadParser.isValid('   '), isFalse);
      expect(QrPayloadParser.isValid(null), isFalse);
    });
  });
}
