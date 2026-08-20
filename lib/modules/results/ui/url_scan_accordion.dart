import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../../helpers/security/analysis_status_resolver.dart';
import '../../../helpers/shared/url_open_helper.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final status = AnalysisStatusResolver.resolve(widget.scan.analysis);
    final resultLabel = status.isSafe
        ? 'Safe'
        : '${status.riskCount} warning${status.riskCount == 1 ? '' : 's'}';
    final resultColor = status.isSafe ? AppColors.safe : AppColors.malicious;

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
                // Entire Link Area is directly touchable to navigate
                Expanded(
                  child: InkWell(
                    onTap: () => _openUrl(widget.scan.data),
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
                                    color: status.isSafe
                                        ? (isDark
                                            ? const Color(0xFF58A6FF)
                                            : AppColors.primaryLight)
                                        : (isDark
                                            ? AppColors.textDark
                                            : AppColors.textLight),
                                    decoration: status.isSafe
                                        ? TextDecoration.underline
                                        : TextDecoration.none,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Icon(
                                Icons.open_in_new_rounded,
                                size: 14,
                                color: status.isSafe
                                    ? (isDark
                                        ? const Color(0xFF58A6FF)
                                        : AppColors.primaryLight)
                                    : AppColors.textSecondary,
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            status.isSafe
                                ? 'Tap link to open in browser'
                                : 'Review threats before opening',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
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

