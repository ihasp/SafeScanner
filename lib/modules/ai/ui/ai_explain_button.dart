import 'package:flutter/material.dart';

import '../../../l10n/l10n.dart';
import '../../results/models/scan_result.dart';
import '../../security/models/analysis.dart';
import '../../security/models/crypto_wallet_scan.dart';
import 'ai_explanation_sheet.dart';

class AiExplainButton extends StatelessWidget {
  final ScanResult? scan;
  final String? liveData;
  final Analysis? liveUrlAnalysis;
  final CryptoWalletScan? liveCryptoScan;
  final bool compact;

  const AiExplainButton({super.key, required this.scan, this.compact = false})
    : liveData = null,
      liveUrlAnalysis = null,
      liveCryptoScan = null;

  const AiExplainButton.forLiveScan({
    super.key,
    required this.liveData,
    this.liveUrlAnalysis,
    this.liveCryptoScan,
    this.compact = false,
  }) : scan = null;

  void _onPressed(BuildContext context) {
    if (scan != null) {
      AiExplanationSheet.show(context, scan: scan!);
    } else if (liveData != null) {
      AiExplanationSheet.showForLiveScan(
        context,
        data: liveData!,
        urlAnalysis: liveUrlAnalysis,
        cryptoScan: liveCryptoScan,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (compact) {
      return IconButton(
        icon: const Icon(
          Icons.auto_awesome_rounded,
          size: 20,
          color: Color(0xFF8B5CF6),
        ),
        tooltip: l10n.hybridAiAnalysis,
        onPressed: () => _onPressed(context),
      );
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: LinearGradient(
          colors: isDark
              ? [
                  const Color(0xFF6366F1).withAlpha(40),
                  const Color(0xFFA855F7).withAlpha(40),
                ]
              : [
                  const Color(0xFF6366F1).withAlpha(25),
                  const Color(0xFFA855F7).withAlpha(25),
                ],
        ),
        border: Border.all(
          color: isDark
              ? const Color(0xFF818CF8).withAlpha(80)
              : const Color(0xFF6366F1).withAlpha(90),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onPressed(context),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFFA855F7)],
                  ).createShader(bounds),
                  child: const Icon(
                    Icons.auto_awesome,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.hybridAiAnalysis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? const Color(0xFFC7D2FE)
                        : const Color(0xFF4F46E5),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
