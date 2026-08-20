import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../constants/api_keys.dart';
import '../../../constants/app_constants.dart';
import '../models/crypto_wallet_scan.dart';
import '../models/tatum_models.dart';

class TatumService {
  final http.Client _client;
  final String _apiKey;

  TatumService({http.Client? client, String? apiKey})
    : _client = client ?? http.Client(),
      _apiKey = apiKey ?? ApiKeys.tatumApiKey;

  static const Set<TatumChain> _portfolioChains = {
    TatumChain.ethereumMainnet,
    TatumChain.solanaMainnet,
    TatumChain.polygonMainnet,
    TatumChain.bscMainnet,
    TatumChain.baseMainnet,
    TatumChain.arbOneMainnet,
    TatumChain.optimismMainnet,
    TatumChain.celoMainnet,
    TatumChain.tezosMainnet,
  };

  static const Set<TatumChain> _maliciousCheckChains = {
    TatumChain.ethereumMainnet,
    TatumChain.bitcoinMainnet,
    TatumChain.solanaMainnet,
  };

  void _handleStatusCode(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;
    switch (response.statusCode) {
      case 400:
        throw const TatumBadRequestException();
      case 401:
        throw const TatumAuthException();
      case 403:
        throw const TatumForbiddenException();
      case 404:
        throw const TatumNotFoundException();
      case 429:
        throw const TatumRateLimitException();
      case 500 || 502 || 503 || 504:
        throw const TatumServerException();
      default:
        throw TatumGenericException(
          'Tatum request failed (${response.statusCode}): ${response.body}',
          response.statusCode,
        );
    }
  }

  Future<Object?> _tatumFetch(
    String path, {
    Map<String, String>? queryParams,
  }) async {
    final baseUri = Uri.parse(AppConstants.tatumApiUrl);
    final uri = Uri(
      scheme: baseUri.scheme,
      host: baseUri.host,
      port: baseUri.port,
      path: path,
      queryParameters: queryParams,
    );

    final response = await _client.get(
      uri,
      headers: {'accept': 'application/json', 'x-api-key': _apiKey},
    );

    _handleStatusCode(response);

    return jsonDecode(response.body);
  }

  Future<TatumNativeBalance?> getNativeBalance(CryptoWallet wallet) async {
    try {
      final data = await _tatumFetch(
        '/v4/data/blockchains/balance',
        queryParams: {'chain': wallet.chain.value, 'address': wallet.address},
      ) as Map<String, dynamic>;

      return TatumNativeBalance.fromJson(data);
    } catch (_) {
      return null;
    }
  }

  Future<List<TatumAssetBalance>> getPortfolioBalances(
    CryptoWallet wallet,
    String tokenTypes,
  ) async {
    if (!_portfolioChains.contains(wallet.chain)) {
      return const [];
    }

    try {
      final data = await _tatumFetch(
        '/v4/data/wallet/portfolio',
        queryParams: {
          'chain': wallet.chain.value,
          'addresses': wallet.address,
          'tokenTypes': tokenTypes,
          'pageSize': '50',
          'offset': '0',
        },
      ) as Map<String, dynamic>;

      final balances = data['balances'] as List<Object?>? ?? [];
      return balances
          .whereType<Map<String, dynamic>>()
          .map(TatumAssetBalance.fromJson)
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<TatumMaliciousAddressCheck> checkMaliciousAddress(
    CryptoWallet wallet,
  ) async {
    if (!_maliciousCheckChains.contains(wallet.chain)) {
      return const TatumMaliciousAddressCheck(
        status: MaliciousCheckStatus.unknown,
        source: 'Tatum',
      );
    }

    try {
      final data = await _tatumFetch(
        '/v3/security/address/${Uri.encodeComponent(wallet.address)}',
      ) as Map<String, dynamic>;

      return TatumMaliciousAddressCheck.fromJson(data);
    } catch (_) {
      return const TatumMaliciousAddressCheck(
        status: MaliciousCheckStatus.unknown,
        source: 'Tatum',
      );
    }
  }

  Future<CryptoWalletScan> getCryptoWalletAnalysis(CryptoWallet wallet) async {
    final results = await Future.wait([
      getNativeBalance(wallet),
      getPortfolioBalances(wallet, 'native'),
      getPortfolioBalances(wallet, 'fungible'),
      getPortfolioBalances(wallet, 'nft,multitoken'),
      checkMaliciousAddress(wallet),
    ]);

    final nativeBalance = results.first as TatumNativeBalance?;
    final nativeAssets = results[1] as List<TatumAssetBalance>;
    final fungibleAssets = results[2] as List<TatumAssetBalance>;
    final collectibleAssets = results[3] as List<TatumAssetBalance>;
    final safety = results[4] as TatumMaliciousAddressCheck;

    final allAssets = <TatumAssetBalance>[
      ...nativeAssets,
      ...fungibleAssets,
      ...collectibleAssets,
    ];

    return CryptoWalletScan(
      wallet: wallet,
      nativeBalance: nativeBalance,
      assets: allAssets,
      safety: safety,
    );
  }

  void close() {
    _client.close();
  }
}

sealed class TatumException implements Exception {
  final String message;
  final int? statusCode;

  const TatumException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

class TatumAuthException extends TatumException {
  const TatumAuthException([
    String message = 'Invalid or missing Tatum API key.',
  ]) : super(message, 401);
}

class TatumForbiddenException extends TatumException {
  const TatumForbiddenException([
    String message = 'Access to Tatum API was forbidden.',
  ]) : super(message, 403);
}

class TatumRateLimitException extends TatumException {
  const TatumRateLimitException([
    String message = 'Tatum rate limit reached. Please try again shortly.',
  ]) : super(message, 429);
}

class TatumBadRequestException extends TatumException {
  const TatumBadRequestException([
    String message = 'Invalid wallet or request format for Tatum API.',
  ]) : super(message, 400);
}

class TatumNotFoundException extends TatumException {
  const TatumNotFoundException([
    String message = 'Wallet or resource not found on Tatum.',
  ]) : super(message, 404);
}

class TatumServerException extends TatumException {
  const TatumServerException([
    String message = 'Tatum service is temporarily unavailable.',
  ]) : super(message, 500);
}

class TatumGenericException extends TatumException {
  const TatumGenericException(super.message, [super.statusCode]);
}
