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
    final status = AnalysisStatusResolver.resolve(widget.scan.analysis);
    final resultLabel = status.isSafe
        ? 'Safe'
        : '${status.riskCount} warning${status.riskCount == 1 ? '' : 's'}';
    final resultColor = status.isSafe ? AppColors.safe : AppColors.malicious;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE7E7E7)),
        borderRadius: BorderRadius.circular(8),
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
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                widget.scan.data,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textLight,
                                ),
                              ),
                            ),
                            if (status.isSafe) ...[
                              const SizedBox(width: 6),
                              GestureDetector(
                                onTap: () => _openUrl(widget.scan.data),
                                child: const Icon(
                                  Icons.open_in_new_rounded,
                                  size: 16,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          status.isSafe
                              ? 'No threats found'
                              : 'Review before opening',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Row(
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
                    decoration: const BoxDecoration(
                      border: Border(top: BorderSide(color: AppColors.border)),
                    ),
                    padding: const EdgeInsets.only(top: 12),
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
