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

  Future<dynamic> _tatumFetch(
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

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Tatum request failed (${response.statusCode}): ${response.body}',
      );
    }

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

      final balances = data['balances'] as List<dynamic>? ?? [];
      return balances
          .map((e) => TatumAssetBalance.fromJson(e as Map<String, dynamic>))
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

    final nativeBalance = results[0] as TatumNativeBalance?;
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
}
