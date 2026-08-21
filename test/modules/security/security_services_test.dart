import 'dart:convert';

import 'package:crypto_scanner/modules/security/models/analysis.dart';
import 'package:crypto_scanner/modules/security/models/tatum_chain.dart';
import 'package:crypto_scanner/modules/security/services/tatum_service.dart';
import 'package:crypto_scanner/modules/security/services/virustotal_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('VirusTotalService API Status Code Tests', () {
    test(
      '200 OK: scanUrl successfully submits URL and parses analysis id',
      () async {
        final mockClient = MockClient((request) async {
          expect(request.method, equals('POST'));
          expect(request.url.path, endsWith('/urls'));
          expect(request.headers['x-apikey'], equals('test-vt-key'));
          return http.Response(
            jsonEncode({
              'data': {'id': 'u-abcdef123456-analysis'},
            }),
            200,
          );
        });

        final service = VirusTotalService(
          client: mockClient,
          apiKey: 'test-vt-key',
        );
        final id = await service.scanUrl('https://example.com');
        expect(id, equals('u-abcdef123456-analysis'));
      },
    );

    test('200 OK: getAnalysis returns completed analysis model', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, equals('GET'));
        expect(request.url.path, endsWith('/analyses/test-id'));
        return http.Response(
          jsonEncode({
            'data': {
              'attributes': {
                'status': 'completed',
                'results': {
                  'Google': {'category': 'harmless', 'result': 'clean'},
                  'Kaspersky': {'category': 'harmless', 'result': 'clean'},
                },
              },
            },
          }),
          200,
        );
      });

      final service = VirusTotalService(
        client: mockClient,
        apiKey: 'test-vt-key',
      );
      final analysis = await service.getAnalysis('test-id');
      expect(analysis.data.attributes.status, equals(AnalysisStatus.completed));
      expect(analysis.data.attributes.results.length, equals(2));
      expect(
        analysis.data.attributes.results['Google']?.result,
        equals('clean'),
      );
    });

    test('400 Bad Request: throws VirusTotalBadRequestException', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'error': {'message': 'Invalid URL format'},
          }),
          400,
        );
      });

      final service = VirusTotalService(
        client: mockClient,
        apiKey: 'test-vt-key',
      );
      expect(
        () => service.scanUrl('invalid url'),
        throwsA(isA<VirusTotalBadRequestException>()),
      );
    });

    test('401 Unauthorized: throws VirusTotalAuthException', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'error': {'message': 'Wrong API key'},
          }),
          401,
        );
      });

      final service = VirusTotalService(
        client: mockClient,
        apiKey: 'invalid-key',
      );
      expect(
        () => service.scanUrl('https://example.com'),
        throwsA(isA<VirusTotalAuthException>()),
      );
      expect(
        () => service.getAnalysis('any-id'),
        throwsA(isA<VirusTotalAuthException>()),
      );
    });

    test('403 Forbidden: throws VirusTotalForbiddenException', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'error': {'message': 'Forbidden'},
          }),
          403,
        );
      });

      final service = VirusTotalService(
        client: mockClient,
        apiKey: 'test-vt-key',
      );
      expect(
        () => service.scanUrl('https://example.com'),
        throwsA(isA<VirusTotalForbiddenException>()),
      );
    });

    test('404 Not Found: throws VirusTotalNotFoundException', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'error': {'message': 'Resource not found'},
          }),
          404,
        );
      });

      final service = VirusTotalService(
        client: mockClient,
        apiKey: 'test-vt-key',
      );
      expect(
        () => service.getAnalysis('non-existent-id'),
        throwsA(isA<VirusTotalNotFoundException>()),
      );
    });

    test(
      '429 Rate Limit Exceeded: throws VirusTotalRateLimitException',
      () async {
        final mockClient = MockClient((request) async {
          return http.Response(
            jsonEncode({
              'error': {'message': 'Quota exceeded'},
            }),
            429,
          );
        });

        final service = VirusTotalService(
          client: mockClient,
          apiKey: 'test-vt-key',
        );
        expect(
          () => service.scanUrl('https://example.com'),
          throwsA(isA<VirusTotalRateLimitException>()),
        );
      },
    );

    test('500 Server Error: throws VirusTotalServerException', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Internal Server Error', 500);
      });

      final service = VirusTotalService(
        client: mockClient,
        apiKey: 'test-vt-key',
      );
      expect(
        () => service.scanUrl('https://example.com'),
        throwsA(isA<VirusTotalServerException>()),
      );
    });
  });

  group('TatumService API Status Code Tests', () {
    const testWallet = CryptoWallet(
      address: '0x742d35Cc6634C0532925a3b844Bc454e4438f44e',
      chain: TatumChain.ethereumMainnet,
      label: 'Ethereum',
      rawPayload: '0x742d35Cc6634C0532925a3b844Bc454e4438f44e',
    );

    test(
      '200 OK: getCryptoWalletAnalysis parses native balance, assets & safety',
      () async {
        final mockClient = MockClient((request) async {
          expect(request.headers['x-api-key'], equals('test-tatum-key'));
          if (request.url.path.contains('/v4/data/blockchains/balance')) {
            return http.Response(
              jsonEncode({
                'balance': '3.75',
                'incoming': '10',
                'outgoing': '6.25',
              }),
              200,
            );
          } else if (request.url.path.contains('/v4/data/wallet/portfolio')) {
            final tokenTypes = request.url.queryParameters['tokenTypes'];
            if (tokenTypes == 'native') {
              return http.Response(
                jsonEncode({
                  'balances': [
                    {
                      'type': 'native',
                      'balance': '3.75',
                      'symbol': 'ETH',
                      'decimals': 18,
                    },
                  ],
                }),
                200,
              );
            } else if (tokenTypes == 'fungible') {
              return http.Response(
                jsonEncode({
                  'balances': [
                    {
                      'type': 'fungible',
                      'balance': '250.0',
                      'symbol': 'USDT',
                      'decimals': 6,
                      'metadata': {'name': 'Tether USD'},
                    },
                  ],
                }),
                200,
              );
            }
            return http.Response(jsonEncode({'balances': []}), 200);
          } else if (request.url.path.contains('/v3/security/address')) {
            return http.Response(
              jsonEncode({
                'status': 'valid',
                'source': 'Tatum',
                'description': 'Clean wallet address',
              }),
              200,
            );
          }
          return http.Response('Not Found', 404);
        });

        final service = TatumService(
          client: mockClient,
          apiKey: 'test-tatum-key',
        );
        final scan = await service.getCryptoWalletAnalysis(testWallet);

        expect(scan.wallet.address, equals(testWallet.address));
        expect(scan.nativeBalance?.balance, equals('3.75'));
        expect(scan.assets.length, equals(2));
        expect(scan.assets.first.symbol, equals('ETH'));
        expect(scan.assets[1].symbol, equals('USDT'));
        expect(scan.safety.status, equals(MaliciousCheckStatus.valid));
      },
    );

    test(
      '400 Bad Request: checkMaliciousAddress safely handles 400 error',
      () async {
        final mockClient = MockClient((request) async {
          return http.Response(
            jsonEncode({'message': 'Validation error on address'}),
            400,
          );
        });

        final service = TatumService(
          client: mockClient,
          apiKey: 'test-tatum-key',
        );
        final safety = await service.checkMaliciousAddress(testWallet);
        expect(safety.status, equals(MaliciousCheckStatus.unknown));
      },
    );

    test(
      '401 Unauthorized: checkMaliciousAddress fallback returns unknown status',
      () async {
        final mockClient = MockClient((request) async {
          return http.Response(jsonEncode({'message': 'Unauthorized'}), 401);
        });

        final service = TatumService(
          client: mockClient,
          apiKey: 'invalid-tatum-key',
        );
        final safety = await service.checkMaliciousAddress(testWallet);
        expect(safety.status, equals(MaliciousCheckStatus.unknown));
      },
    );

    test(
      '403 Forbidden: checkMaliciousAddress fallback returns unknown status',
      () async {
        final mockClient = MockClient((request) async {
          return http.Response(jsonEncode({'message': 'Forbidden'}), 403);
        });

        final service = TatumService(
          client: mockClient,
          apiKey: 'test-tatum-key',
        );
        final safety = await service.checkMaliciousAddress(testWallet);
        expect(safety.status, equals(MaliciousCheckStatus.unknown));
      },
    );

    test(
      '429 Rate Limit: checkMaliciousAddress fallback returns unknown status',
      () async {
        final mockClient = MockClient((request) async {
          return http.Response(
            jsonEncode({'message': 'Too Many Requests'}),
            429,
          );
        });

        final service = TatumService(
          client: mockClient,
          apiKey: 'test-tatum-key',
        );
        final safety = await service.checkMaliciousAddress(testWallet);
        expect(safety.status, equals(MaliciousCheckStatus.unknown));
      },
    );

    test(
      '500 Server Error: checkMaliciousAddress fallback returns unknown status',
      () async {
        final mockClient = MockClient((request) async {
          return http.Response('Internal Server Error', 500);
        });

        final service = TatumService(
          client: mockClient,
          apiKey: 'test-tatum-key',
        );
        final safety = await service.checkMaliciousAddress(testWallet);
        expect(safety.status, equals(MaliciousCheckStatus.unknown));
      },
    );
  });
}
