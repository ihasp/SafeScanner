import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../security/models/tatum_models.dart';
import '../../security/ui/crypto_wallet_results_view.dart';
import '../models/scan_result.dart';

class CryptoScanAccordion extends StatefulWidget {
  final CryptoScanResult scan;

  const CryptoScanAccordion({super.key, required this.scan});

  @override
  State<CryptoScanAccordion> createState() => _CryptoScanAccordionState();
}

class _CryptoScanAccordionState extends State<CryptoScanAccordion> {
  bool _isOpen = false;

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
    final safety = _getSafetyDisplay(widget.scan.cryptoScan.safety);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2022) : Colors.white,
        border: Border.all(
          color: isDark ? AppColors.borderDark : const Color(0xFFE7E7E7),
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Header (entire row is clickable to expand)
          InkWell(
            onTap: () {
              setState(() {
                _isOpen = !_isOpen;
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.scan.cryptoScan.wallet.address,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.textDark
                                : AppColors.textLight,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${widget.scan.cryptoScan.wallet.label} wallet',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            safety.label,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: safety.color,
                            ),
                          ),
                          const SizedBox(width: 4),
                          AnimatedRotation(
                            duration: const Duration(milliseconds: 200),
                            turns: _isOpen ? 0.5 : 0.0,
                            child: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 22,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${widget.scan.cryptoScan.assets.length} assets',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Smoothly Animated Expanded Content
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.fastOutSlowIn,
            alignment: Alignment.topCenter,
            child: _isOpen
                ? Container(
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: isDark
                              ? AppColors.borderDark
                              : AppColors.border,
                        ),
                      ),
                    ),
                    padding: const EdgeInsets.only(top: 8),
                    child: CryptoWalletResultsView(
                      scan: widget.scan.cryptoScan,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
