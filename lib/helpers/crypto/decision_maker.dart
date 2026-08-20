import '../../modules/security/models/crypto_decision.dart';
import '../../modules/security/models/crypto_wallet_scan.dart';
import '../../modules/security/models/tatum_models.dart';

abstract final class DecisionMaker {
  static double _parseBalance(String? balance) {
    if (balance == null || balance.isEmpty) return 0.0;
    return double.tryParse(balance) ?? 0.0;
  }

  static CryptoDecision decide(CryptoWalletScan scan) {
    final status = scan.safety.status;
    final signals = scan.safety.signals;
    final reasons = <String>[];

    final nativeBalance = _parseBalance(scan.nativeBalance?.balance);
    final hasAssets = scan.assets.isNotEmpty;

    if (status == MaliciousCheckStatus.invalid) {
      reasons.add('Address flagged by malicious-address data source');
      if (scan.safety.description != null &&
          scan.safety.description!.isNotEmpty) {
        reasons.add(scan.safety.description!);
      }
      return CryptoDecision(
        status: status,
        safetyLevel: CryptoSafetyLevel.malicious,
        isSafe: false,
        reasons: reasons,
        signals: signals,
      );
    }

    if (status == MaliciousCheckStatus.valid) {
      reasons.add('Address reported as valid by malicious-address data source');
      return CryptoDecision(
        status: status,
        safetyLevel: CryptoSafetyLevel.safe,
        isSafe: true,
        reasons: reasons,
        signals: signals,
      );
    }

    // Status is unknown / unverified
    if (nativeBalance > 0 || hasAssets) {
      if (nativeBalance > 0) {
        reasons.add('Active native balance: $nativeBalance.');
      }
      if (hasAssets) {
        reasons.add('Contains ${scan.assets.length} asset(s).');
      }
    } else {
      reasons.add('Wallet holds no detectable balance or assets.');
    }
    reasons.add('Address is unverified in threat intelligence databases.');
    reasons.add('Always double-check the recipient address before transferring funds.');

    return CryptoDecision(
      status: MaliciousCheckStatus.unknown,
      safetyLevel: CryptoSafetyLevel.unverified,
      isSafe: false,
      reasons: reasons,
      signals: signals,
    );
  }

  static bool isWalletSafe(CryptoWalletScan scan) {
    return decide(scan).safetyLevel == CryptoSafetyLevel.safe;
  }
}
