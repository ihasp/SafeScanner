import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constants/app_colors.dart';
import '../models/scan_result.dart';
import '../providers/scan_results_provider.dart';
import '../ui/crypto_scan_accordion.dart';
import '../ui/url_scan_accordion.dart';

class ResultsPage extends ConsumerWidget {
  const ResultsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupedScans = ref.watch(groupedScansProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 36),
              const Center(
                child: Text(
                  'Scan results',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textLight,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: groupedScans.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'No scan results yet',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textLight,
                              ),
                            ),
                            SizedBox(height: 8),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 24),
                              child: Text(
                                'Scan a QR code to save results and view them here.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
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
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF555555),
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
