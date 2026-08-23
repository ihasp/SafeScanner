import '../models/crypto_decision.dart';
import '../models/crypto_wallet_scan.dart';
import '../models/tatum_chain.dart';
import '../services/threat_intelligence_registry.dart';

abstract final class DecisionMaker {
  static double _parseBalance(String? balance) {
    if (balance == null || balance.isEmpty) return 0.0;
    return double.tryParse(balance) ?? 0.0;
  }

  static CryptoDecision decide(CryptoWalletScan scan) {
    final status = scan.safety.status;
    final signals = scan.safety.signals ?? <String>[];
    final reasons = <String>[];

    final nativeBalance = _parseBalance(scan.nativeBalance?.balance);
    final hasAssets = scan.assets.isNotEmpty;

    // Check On-Device Threat Intelligence (Known Exploits & Drainers)
    final exploitDesc = ThreatIntelligenceRegistry.getKnownMaliciousDescription(
      scan.wallet.address,
    );
    if (exploitDesc != null) {
      reasons.add('Identified confirmed on-chain threat: $exploitDesc');
      return CryptoDecision(
        status: MaliciousCheckStatus.invalid,
        safetyLevel: CryptoSafetyLevel.malicious,
        isSafe: false,
        reasons: reasons,
        signals: [
          'Address associated with known attack: $exploitDesc',
          'Direct transfers to mixers or malicious contracts detected',
        ],
      );
    }

    // Check Tatum Malicious Status (Reported blacklist)
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

    // Check Known Verified Safe Protocols
    final safeLabel = ThreatIntelligenceRegistry.getKnownSafeLabel(
      scan.wallet.address,
    );
    if (safeLabel != null) {
      reasons.add('Verified protocol / official address: $safeLabel');
      return CryptoDecision(
        status: MaliciousCheckStatus.valid,
        safetyLevel: CryptoSafetyLevel.safe,
        isSafe: true,
        reasons: reasons,
        signals: signals,
      );
    }

    // Check Tatum Valid Status (Verified as valid / clean)
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

    // Status is unverified (Tatum valid syntax, but not in verified whitelist)
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
    reasons.add('Address is unverified in official protocol registries.');
    reasons.add(
      'Always double-check the recipient address before transferring funds.',
    );

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
