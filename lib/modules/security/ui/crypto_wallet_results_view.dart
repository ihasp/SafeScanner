import 'package:flutter/material.dart';

import '../../../l10n/l10n.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/helpers/balance_formatter.dart';
import '../models/crypto_wallet_scan.dart';
import '../models/tatum_chain.dart';

class CryptoWalletResultsView extends StatelessWidget {
  final CryptoWalletScan scan;

  const CryptoWalletResultsView({super.key, required this.scan});

  String _getAssetName(TatumAssetBalance asset) {
    return asset.metadata?.name ?? asset.symbol ?? asset.id ?? asset.type;
  }

  ({String label, Color color}) _getSafetyDisplay(
    TatumMaliciousAddressCheck safety,
    AppLocalizations l10n,
  ) {
    return switch (safety.status) {
      MaliciousCheckStatus.valid => (label: l10n.safe, color: AppColors.safe),
      MaliciousCheckStatus.invalid => (
        label: l10n.malicious,
        color: AppColors.malicious,
      ),
      MaliciousCheckStatus.unknown => (
        label: l10n.unverified,
        color: AppColors.phishing,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final safetyDisplay = _getSafetyDisplay(scan.safety, l10n);
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.border;

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

          // Warning banner if invalid
          if (scan.safety.status == MaliciousCheckStatus.invalid) ...[
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
                scan.safety.description ?? l10n.maliciousReportedDesc,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.malicious,
                ),
              ),
            ),
            const SizedBox(height: 6),
          ] else if (scan.safety.status == MaliciousCheckStatus.unknown) ...[
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
          if (scan.safety.signals != null &&
              scan.safety.signals!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Center(
              child: Text(
                scan.safety.signals!.join(' | '),
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
