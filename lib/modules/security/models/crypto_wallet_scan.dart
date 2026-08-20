import 'tatum_models.dart';

class CryptoWalletScan {
  final CryptoWallet wallet;
  final TatumNativeBalance? nativeBalance;
  final List<TatumAssetBalance> assets;
  final TatumMaliciousAddressCheck safety;

  const CryptoWalletScan({
    required this.wallet,
    this.nativeBalance,
    required this.assets,
    required this.safety,
  });

  factory CryptoWalletScan.fromJson(Map<String, dynamic> json) {
    final rawAssets = json['assets'] as List<Object?>? ?? [];
    return CryptoWalletScan(
      wallet: CryptoWallet.fromJson(
        json['wallet'] as Map<String, dynamic>? ?? {},
      ),
      nativeBalance: json['nativeBalance'] != null
          ? TatumNativeBalance.fromJson(
              json['nativeBalance'] as Map<String, dynamic>,
            )
          : null,
      assets: rawAssets
          .whereType<Map<String, dynamic>>()
          .map(TatumAssetBalance.fromJson)
          .toList(),
      safety: TatumMaliciousAddressCheck.fromJson(
        json['safety'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'wallet': wallet.toJson(),
    if (nativeBalance != null) 'nativeBalance': nativeBalance!.toJson(),
    'assets': assets.map((e) => e.toJson()).toList(),
    'safety': safety.toJson(),
  };
}
