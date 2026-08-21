import 'package:crypto_scanner/modules/scanner/logic/qr_payload_parser.dart';
import 'package:crypto_scanner/modules/scanner/logic/scan_mode_detector.dart';
import 'package:crypto_scanner/modules/scanner/logic/url_validator.dart';
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

  group('UrlValidator Tests', () {
    test('Identifies standard HTTP and HTTPS URLs', () {
      expect(UrlValidator.isLikelyUrl('https://google.com'), isTrue);
      expect(UrlValidator.isLikelyUrl('http://example.com/test?q=1'), isTrue);
      expect(UrlValidator.isLikelyUrl('ftp://files.example.com'), isTrue);
    });

    test('Identifies schemeless domains', () {
      expect(UrlValidator.isLikelyUrl('subdomain.example.com/path'), isTrue);
      expect(UrlValidator.isLikelyUrl('example.org:8080'), isTrue);
    });

    test('Rejects plain text, wifi credentials, and contacts', () {
      expect(UrlValidator.isLikelyUrl('hello world'), isFalse);
      expect(UrlValidator.isLikelyUrl('user@email.com'), isFalse);
      expect(UrlValidator.isLikelyUrl('WIFI:S:MyNet;T:WPA;P:pass;;'), isFalse);
      expect(UrlValidator.isLikelyUrl('BEGIN:VCARD\nVERSION:3.0\nEND:VCARD'), isFalse);
      expect(UrlValidator.isLikelyUrl(''), isFalse);
    });
  });
}
