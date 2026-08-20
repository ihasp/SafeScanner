import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../../helpers/shared/balance_formatter.dart';
import '../models/crypto_wallet_scan.dart';
import '../models/tatum_models.dart';

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
        label: 'Unknown',
        color: AppColors.unknown,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final safetyDisplay = _getSafetyDisplay(scan.safety);

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
          ),

          // Warning banner if invalid
          if (scan.safety.status == MaliciousCheckStatus.invalid) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.maliciousBg,
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
          _buildSummaryRow('Network', scan.wallet.label),

          // Native balance row
          _buildSummaryRow(
            'Native balance',
            BalanceFormatter.format(scan.nativeBalance?.balance),
          ),

          const SizedBox(height: 18),
          const Text(
            'Wallet assets',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.textLight,
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
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: AppColors.border)),
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
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textLight,
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
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textLight,
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

  Widget _buildSummaryRow(String label, String value, {Color? valueColor}) {
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
              color: valueColor ?? AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }
}
