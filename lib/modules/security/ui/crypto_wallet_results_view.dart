import 'package:flutter/material.dart';

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
  ) {
    return switch (safety.status) {
      MaliciousCheckStatus.valid => (label: 'Safe', color: AppColors.safe),
      MaliciousCheckStatus.invalid => (
        label: 'Malicious',
        color: AppColors.malicious,
      ),
      MaliciousCheckStatus.unknown => (
        label: 'Unverified',
        color: AppColors.phishing,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final safetyDisplay = _getSafetyDisplay(scan.safety);
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.border;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Safety row
          _buildSummaryRow(
            'Safety',
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
                scan.safety.description ?? 'This wallet was reported by a malicious-address data source.',
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
              child: const Text(
                'Address unverified in threat databases. Verify recipient before sending funds.',
                style: TextStyle(
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
            'Network',
            scan.wallet.label,
            defaultTextColor: textColor,
          ),

          // Native balance row
          _buildSummaryRow(
            'Native balance',
            BalanceFormatter.format(scan.nativeBalance?.balance),
            defaultTextColor: textColor,
          ),

          const SizedBox(height: 18),
          Text(
            'Wallet assets',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),

          // Assets list
          if (scan.assets.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'No assets found for this wallet.',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
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
