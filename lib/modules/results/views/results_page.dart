import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/l10n.dart';
import '../../../shared/constants/app_colors.dart';
import '../models/scan_result.dart';
import '../providers/scan_results_notifier.dart';
import '../ui/crypto_scan_accordion.dart';
import '../ui/url_scan_accordion.dart';

class ResultsPage extends ConsumerWidget {
  const ResultsPage({super.key});

  Future<void> _confirmClearAll(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.removeAllResultsTitle),
        content: Text(l10n.removeAllResultsContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.malicious),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.removeAll),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      ref.read(scanResultsProvider.notifier).clearScans();
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.allResultsRemoved)));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final groupedScans = ref.watch(groupedScansProvider);
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 40),
                  Text(
                    l10n.scanResults,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  if (groupedScans.isNotEmpty)
                    IconButton(
                      icon: const Icon(
                        Icons.delete_sweep_outlined,
                        color: AppColors.malicious,
                        size: 26,
                      ),
                      tooltip: l10n.removeAllResults,
                      onPressed: () => _confirmClearAll(context, ref),
                    )
                  else
                    const SizedBox(width: 40),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: groupedScans.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.history_rounded,
                              size: 64,
                              color: isDark
                                  ? AppColors.textSecondary.withAlpha(120)
                                  : AppColors.textSecondary.withAlpha(150),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              l10n.noScanResultsYet,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              child: Text(
                                l10n.noScanResultsDesc,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 120),
                        physics: const BouncingScrollPhysics(),
                        itemCount: groupedScans.length,
                        itemBuilder: (context, groupIndex) {
                          final group = groupedScans[groupIndex];
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 12,
                                  bottom: 10,
                                ),
                                child: Text(
                                  group.title,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? const Color(0xFFAAAAAA)
                                        : const Color(0xFF555555),
                                  ),
                                ),
                              ),
                              ...group.scans.map((scan) {
                                if (scan is CryptoScanResult) {
                                  return CryptoScanAccordion(
                                    key: ValueKey(scan.id),
                                    scan: scan,
                                  );
                                } else if (scan is UrlScanResult) {
                                  return UrlScanAccordion(
                                    key: ValueKey(scan.id),
                                    scan: scan,
                                  );
                                }
                                return const SizedBox.shrink();
                              }),
                              const SizedBox(height: 12),
                            ],
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
