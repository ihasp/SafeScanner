import 'package:flutter/material.dart';

import '../../../l10n/l10n.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/helpers/balance_formatter.dart';
import '../logic/decision_maker.dart';
import '../models/crypto_decision.dart';
import '../models/crypto_wallet_scan.dart';
import '../models/tatum_chain.dart';
import '../services/threat_intelligence_registry.dart';

class CryptoWalletResultsView extends StatelessWidget {
  final CryptoWalletScan scan;

  const CryptoWalletResultsView({super.key, required this.scan});

  String _getAssetName(TatumAssetBalance asset) {
    return asset.metadata?.name ?? asset.symbol ?? asset.id ?? asset.type;
  }

  ({String label, Color color}) _getSafetyDisplay(
    CryptoDecision decision,
    AppLocalizations l10n,
  ) {
    return switch (decision.safetyLevel) {
      CryptoSafetyLevel.safe => (label: l10n.safe, color: AppColors.safe),
      CryptoSafetyLevel.malicious => (
        label: l10n.malicious,
        color: AppColors.malicious,
      ),
      CryptoSafetyLevel.unverified => (
        label: l10n.unverified,
        color: AppColors.phishing,
      ),
    };
  }

  String _getMaliciousBannerText(CryptoWalletScan scan, AppLocalizations l10n) {
    final exploitDesc = ThreatIntelligenceRegistry.getKnownMaliciousDescription(
      scan.wallet.address,
    );
    if (exploitDesc != null) {
      return l10n.knownExploitThreat(exploitDesc);
    }
    return scan.safety.description ?? l10n.maliciousReportedDesc;
  }

  String _localizeSignal(String signal, AppLocalizations l10n) {
    if (signal.contains('Rapid fund sweeping') ||
        signal.contains('drainer pattern')) {
      return l10n.signalFastDrain;
    }
    if (signal.contains('High transaction asymmetry') ||
        signal.contains('mass fund draining')) {
      return l10n.signalAsymmetricFlow;
    }
    if (signal.contains('Direct interaction with cryptocurrency mixer') ||
        signal.contains('Tornado Cash') ||
        signal.contains('Direct transfers to mixers')) {
      return l10n.signalMixerInteraction;
    }
    if (signal.contains('Very new address') || signal.contains('72 hours')) {
      return l10n.signalYoungWallet;
    }
    if (signal.contains('Web3 Brand Impersonation')) {
      return l10n.signalBrandImpersonation;
    }
    if (signal.contains('High-risk disposable')) {
      return l10n.signalHighRiskTld;
    }
    if (signal.contains('High character entropy') ||
        signal.contains('DGA pattern')) {
      return l10n.signalDgaEntropy;
    }
    if (signal.startsWith('Address associated with known attack:')) {
      final exploit = signal
          .replaceFirst('Address associated with known attack:', '')
          .trim();
      return l10n.knownExploitThreat(exploit);
    }
    return signal;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final decision = DecisionMaker.decide(scan);
    final safetyDisplay = _getSafetyDisplay(decision, l10n);
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.border;

    final displaySignals =
        decision.signals
            ?.where(
              (s) => !s.startsWith('Address associated with known attack:'),
            )
            .map((s) => _localizeSignal(s, l10n))
            .toSet()
            .toList() ??
        const <String>[];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Safety row
          _buildSummaryRow(
            l10n.safety,
            safetyDisplay.label,
            valueColor: safetyDisplay.color,
            defaultTextColor: textColor,
          ),

          // Safe Protocol banner if verified
          if (decision.safetyLevel == CryptoSafetyLevel.safe) ...[
            if (ThreatIntelligenceRegistry.getKnownSafeLabel(
                  scan.wallet.address,
                )
                case final safeLabel?) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.safe.withAlpha(35)
                      : const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  l10n.verifiedProtocolLabel(safeLabel),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.safe,
                  ),
                ),
              ),
              const SizedBox(height: 6),
            ],
          ] else if (decision.safetyLevel == CryptoSafetyLevel.malicious) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.malicious.withAlpha(40)
                    : AppColors.maliciousBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _getMaliciousBannerText(scan, l10n),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.malicious,
                ),
              ),
            ),
            const SizedBox(height: 6),
          ] else if (decision.safetyLevel == CryptoSafetyLevel.unverified) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.phishing.withAlpha(35)
                    : const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                l10n.unverifiedDesc,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.phishing,
                ),
              ),
            ),
            const SizedBox(height: 6),
          ],

          // Signals
          if (displaySignals.isNotEmpty) ...[
            const SizedBox(height: 4),
            Center(
              child: Text(
                displaySignals.join(' • '),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 6),
          ],

          // Network row
          _buildSummaryRow(
            l10n.network,
            scan.wallet.label,
            defaultTextColor: textColor,
          ),

          // Native balance row
          _buildSummaryRow(
            l10n.nativeBalance,
            BalanceFormatter.format(scan.nativeBalance?.balance),
            defaultTextColor: textColor,
          ),

          const SizedBox(height: 18),
          Text(
            l10n.walletAssets,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),

          // Assets list
          if (scan.assets.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                l10n.noAssetsFound,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            )
          else
            Column(
              children: scan.assets.map((asset) {
                return Container(
                  constraints: const BoxConstraints(minHeight: 54),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: borderColor)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getAssetName(asset),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              asset.type.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${BalanceFormatter.format(asset.balance)} ${asset.symbol ?? ''}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    Color? valueColor,
    Color defaultTextColor = AppColors.textLight,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: valueColor ?? defaultTextColor,
            ),
          ),
        ],
      ),
    );
  }
}
