import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../../helpers/security/analysis_status_resolver.dart';
import '../models/analysis_model.dart';

enum CustomFlatlistVariant { summary, details }

class CustomFlatlistView extends StatefulWidget {
  final Analysis analysis;
  final CustomFlatlistVariant variant;
  final bool scrollEnabled;

  const CustomFlatlistView({
    super.key,
    required this.analysis,
    this.variant = CustomFlatlistVariant.summary,
    this.scrollEnabled = true,
  });

  @override
  State<CustomFlatlistView> createState() => _CustomFlatlistViewState();
}

class _CustomFlatlistViewState extends State<CustomFlatlistView> {
  bool _showAllEngines = false;

  @override
  Widget build(BuildContext context) {
    final status = AnalysisStatusResolver.resolve(widget.analysis);

    final verdictTitle = status.isSafe ? 'Safe' : 'Potentially unsafe';
    final verdictMessage = status.isSafe
        ? 'No security issues were found for this link.'
        : 'Security checks found warning signs. Only open this link if you trust the source.';
    final verdictColor = status.isSafe ? AppColors.safe : AppColors.malicious;
    final verdictBg = status.isSafe ? AppColors.safeBg : AppColors.maliciousBg;
    final verdictIcon = status.isSafe
        ? Icons.verified_user_outlined
        : Icons.gpp_bad_outlined;

    final resultsToShow = _showAllEngines || status.sortedResults.length <= 5
        ? status.sortedResults
        : status.sortedResults.take(5).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Verdict banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: verdictBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(verdictIcon, size: 34, color: verdictColor),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        verdictTitle,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: verdictColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        verdictMessage,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.35,
                          color: Color(0xFF4F4F4F),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Summary grid
          Row(
            children: [
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(minHeight: 72),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${status.resultCounts.total}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textLight,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'checks completed',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(minHeight: 72),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${status.riskCount}',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: status.riskCount > 0
                              ? AppColors.malicious
                              : AppColors.safe,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'warnings found',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Warning Breakdown
          if (!status.isSafe) ...[
            const SizedBox(height: 14),
            Container(
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: Column(
                children: [
                  if (status.resultCounts.malicious > 0)
                    _buildWarningRow(
                      'Malicious',
                      '${status.resultCounts.malicious}',
                    ),
                  if (status.resultCounts.phishing > 0)
                    _buildWarningRow(
                      'Phishing',
                      '${status.resultCounts.phishing}',
                    ),
                  if (status.resultCounts.suspicious > 0)
                    _buildWarningRow(
                      'Suspicious',
                      '${status.resultCounts.suspicious}',
                    ),
                ],
              ),
            ),
          ],

          // Details breakdown if requested
          if (widget.variant == CustomFlatlistVariant.details) ...[
            const SizedBox(height: 18),
            Container(
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Scanner results',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textLight,
                        ),
                      ),
                      Text(
                        '${status.sortedResults.length} engines',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.fastOutSlowIn,
                    alignment: Alignment.topCenter,
                    child: Column(
                      children: resultsToShow
                          .map((item) => _buildScannerRow(item))
                          .toList(),
                    ),
                  ),
                  if (status.sortedResults.length > 5) ...[
                    const SizedBox(height: 8),
                    Center(
                      child: TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _showAllEngines = !_showAllEngines;
                          });
                        },
                        icon: Icon(
                          _showAllEngines
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          size: 18,
                          color: AppColors.primary,
                        ),
                        label: Text(
                          _showAllEngines
                              ? 'Show fewer engines'
                              : 'Show all ${status.sortedResults.length} engines',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWarningRow(String label, String value) {
    return Container(
      constraints: const BoxConstraints(minHeight: 42),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF333333),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.malicious,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScannerRow(FormattedEngineResult item) {
    return Container(
      constraints: const BoxConstraints(minHeight: 38),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF1F1F1))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              item.key,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF333333),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            item.text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: item.color,
            ),
          ),
        ],
      ),
    );
  }
}
