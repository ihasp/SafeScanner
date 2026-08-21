import 'package:flutter/material.dart';

import '../../../l10n/l10n.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/helpers/url_open_helper.dart';
import '../../security/logic/analysis_status_resolver.dart';
import '../../security/ui/custom_flatlist_view.dart';
import '../models/scan_result.dart';

class UrlScanAccordion extends StatefulWidget {
  final UrlScanResult scan;

  const UrlScanAccordion({super.key, required this.scan});

  @override
  State<UrlScanAccordion> createState() => _UrlScanAccordionState();
}

class _UrlScanAccordionState extends State<UrlScanAccordion> {
  bool _isOpen = false;

  Future<void> _openUrl(String url) async {
    await UrlOpenHelper.openUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final status = AnalysisStatusResolver.resolve(widget.scan.analysis);
    final (resultLabel, resultColor) = switch (status.verdict) {
      AnalysisVerdict.safe => (l10n.safe, AppColors.safe),
      AnalysisVerdict.warning => (
        l10n.warningsCount(status.riskCount),
        AppColors.warning,
      ),
      AnalysisVerdict.malicious => (
        l10n.threatsCount(status.resultCounts.malicious),
        AppColors.malicious,
      ),
    };

    final canOpenLink = status.canOpenLink;
    final linkColor = status.isSafe
        ? (isDark ? const Color(0xFF58A6FF) : AppColors.primaryLight)
        : (status.isWarning
              ? AppColors.warning
              : (isDark ? AppColors.textSecondary : const Color(0xFF888888)));
    final linkSubtext = status.isSafe
        ? l10n.tapToOpenInBrowser
        : (status.isWarning
              ? l10n.reviewWarningsBeforeOpening
              : l10n.linkBlockedDueToThreats);

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
          // Header Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                // Entire Link Area is touchable if link is not malicious
                Expanded(
                  child: InkWell(
                    onTap: canOpenLink
                        ? () => _openUrl(widget.scan.data)
                        : null,
                    borderRadius: BorderRadius.circular(6),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 2,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  widget.scan.data,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: linkColor,
                                    decoration: canOpenLink
                                        ? TextDecoration.underline
                                        : TextDecoration.none,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Icon(
                                canOpenLink
                                    ? Icons.open_in_new_rounded
                                    : Icons.block_rounded,
                                size: 14,
                                color: canOpenLink
                                    ? linkColor
                                    : AppColors.malicious,
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            linkSubtext,
                            style: TextStyle(
                              fontSize: 11,
                              color: status.isMalicious
                                  ? AppColors.malicious
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Chevron & Badge area toggles accordion details
                InkWell(
                  onTap: () {
                    setState(() {
                      _isOpen = !_isOpen;
                    });
                  },
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 6,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          resultLabel,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: resultColor,
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
                  ),
                ),
              ],
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
                    child: CustomFlatlistView(
                      analysis: widget.scan.analysis,
                      variant: CustomFlatlistVariant.details,
                      scrollEnabled: false,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
