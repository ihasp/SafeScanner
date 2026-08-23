import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/l10n.dart';
import '../../../shared/constants/app_colors.dart';
import '../../results/models/scan_result.dart';
import '../../results/providers/scan_results_notifier.dart';
import '../../security/models/analysis.dart';
import '../../security/models/crypto_wallet_scan.dart';
import '../../settings/providers/settings_notifier.dart';
import '../models/ai_security_explanation.dart';
import '../providers/ai_providers.dart';
import '../services/gemini_ai_service.dart';

class AiExplanationSheet extends ConsumerStatefulWidget {
  final String data;
  final String? scanId;
  final Analysis? urlAnalysis;
  final CryptoWalletScan? cryptoScan;
  final AiSecurityExplanation? initialExplanation;

  const AiExplanationSheet({
    super.key,
    required this.data,
    this.scanId,
    this.urlAnalysis,
    this.cryptoScan,
    this.initialExplanation,
  });

  static Future<void> show(BuildContext context, {required ScanResult scan}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        if (scan is UrlScanResult) {
          return AiExplanationSheet(
            data: scan.data,
            scanId: scan.id,
            urlAnalysis: scan.analysis,
            initialExplanation: scan.aiExplanation,
          );
        } else if (scan is CryptoScanResult) {
          return AiExplanationSheet(
            data: scan.data,
            scanId: scan.id,
            cryptoScan: scan.cryptoScan,
            initialExplanation: scan.aiExplanation,
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  static Future<void> showForLiveScan(
    BuildContext context, {
    required String data,
    Analysis? urlAnalysis,
    CryptoWalletScan? cryptoScan,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AiExplanationSheet(
        data: data,
        urlAnalysis: urlAnalysis,
        cryptoScan: cryptoScan,
      ),
    );
  }

  @override
  ConsumerState<AiExplanationSheet> createState() => _AiExplanationSheetState();
}

class _AiExplanationSheetState extends ConsumerState<AiExplanationSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _pulseAnimation;

  AiSecurityExplanation? _explanation;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );

    _explanation = widget.initialExplanation;
    if (_explanation == null) {
      _fetchAiExplanation();
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _fetchAiExplanation() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final selectedLanguageCode = ref.read(settingsProvider).languageCode;
    final activeLanguageCode =
        selectedLanguageCode ?? Localizations.localeOf(context).languageCode;
    final geminiService = ref.read(geminiAiServiceProvider);

    try {
      AiSecurityExplanation result;
      if (widget.cryptoScan != null) {
        result = await geminiService.explainCryptoScan(
          scan: widget.cryptoScan!,
          languageCode: activeLanguageCode,
        );
      } else if (widget.urlAnalysis != null) {
        result = await geminiService.explainUrlScan(
          url: widget.data,
          analysis: widget.urlAnalysis!,
          languageCode: activeLanguageCode,
        );
      } else {
        throw const GeminiGenericException('No scan intelligence available.');
      }

      if (!mounted) return;
      setState(() {
        _explanation = result;
        _isLoading = false;
      });

      if (widget.scanId != null) {
        ref
            .read(scanResultsProvider.notifier)
            .updateAiExplanation(widget.scanId!, result);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        if (e is GeminiMissingApiKeyException) {
          _errorMessage = context.l10n.apiKeyMissingDesc;
        } else if (e is GeminiRateLimitException) {
          _errorMessage = e.message;
        } else {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        }
      });
    }
  }

  ({Color color, Color bg, IconData icon}) _getRiskStyles(
    AiRiskLevel level,
    bool isDark,
  ) {
    return switch (level) {
      AiRiskLevel.safe => (
        color: AppColors.safe,
        bg: isDark ? AppColors.safe.withAlpha(35) : AppColors.safeBg,
        icon: Icons.check_circle_outline_rounded,
      ),
      AiRiskLevel.warning => (
        color: AppColors.warning,
        bg: isDark ? AppColors.warning.withAlpha(35) : AppColors.warningBg,
        icon: Icons.warning_amber_rounded,
      ),
      AiRiskLevel.malicious => (
        color: AppColors.malicious,
        bg: isDark ? AppColors.malicious.withAlpha(35) : AppColors.maliciousBg,
        icon: Icons.gpp_bad_outlined,
      ),
      AiRiskLevel.unverified => (
        color: AppColors.phishing,
        bg: isDark ? AppColors.phishing.withAlpha(35) : const Color(0xFFFFF8E1),
        icon: Icons.info_outline_rounded,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = context.l10n;
    final sheetBg = isDark ? const Color(0xFF1E2022) : Colors.white;
    final headerTextColor = isDark ? AppColors.textDark : AppColors.textLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.border;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 12,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top drag handle with close button
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 16, right: 16),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF444444)
                          : const Color(0xFFDDDDDD),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      size: 24,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    splashRadius: 20,
                  ),
                ),
              ],
            ),
          ),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFFA855F7)],
                ).createShader(bounds),
                child: const Icon(
                  Icons.auto_awesome,
                  size: 22,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                l10n.hybridAiReport,
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: headerTextColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Target Preview
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              widget.data,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Body
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: _buildBody(isDark, l10n, headerTextColor, borderColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(
    bool isDark,
    AppLocalizations l10n,
    Color headerTextColor,
    Color borderColor,
  ) {
    if (_isLoading) {
      return _buildLoadingState(isDark, l10n);
    }

    if (_errorMessage != null) {
      return _buildErrorState(isDark, l10n);
    }

    if (_explanation != null) {
      return _buildExplanationContent(
        _explanation!,
        isDark,
        l10n,
        headerTextColor,
        borderColor,
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildLoadingState(bool isDark, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _pulseAnimation,
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFFA855F7)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withAlpha(80),
                      blurRadius: 18,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  size: 36,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.analyzingWithHybridAi,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textDark : AppColors.textLight,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: 140,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: const LinearProgressIndicator(
                  minHeight: 3,
                  backgroundColor: Colors.transparent,
                  color: Color(0xFF6366F1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(bool isDark, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.malicious.withAlpha(30)
              : AppColors.maliciousBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark
                ? AppColors.malicious.withAlpha(80)
                : AppColors.malicious.withAlpha(60),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: AppColors.malicious,
                  size: 24,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.aiAnalysisFailed,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.malicious,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? '',
              style: TextStyle(
                fontSize: 13,
                height: 1.35,
                color: isDark
                    ? const Color(0xFFE2E8F0)
                    : const Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 42,
              child: OutlinedButton.icon(
                onPressed: () {
                  _fetchAiExplanation();
                },
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(l10n.regenerate),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExplanationContent(
    AiSecurityExplanation exp,
    bool isDark,
    AppLocalizations l10n,
    Color headerTextColor,
    Color borderColor,
  ) {
    final riskStyles = _getRiskStyles(exp.riskLevel, isDark);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Headline / Verdict Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: riskStyles.bg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: riskStyles.color.withAlpha(80)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(riskStyles.icon, size: 28, color: riskStyles.color),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exp.headline,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: riskStyles.color,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      exp.summary,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: isDark
                            ? const Color(0xFFE0E0E0)
                            : const Color(0xFF333333),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Key Findings
        if (exp.keyFindings.isNotEmpty) ...[
          Text(
            l10n.keyFindings,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: headerTextColor,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF242628) : const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              children: exp.keyFindings.map((finding) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Icon(
                          Icons.circle,
                          size: 6,
                          color: riskStyles.color,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          finding,
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.3,
                            color: isDark
                                ? const Color(0xFFD0D0D0)
                                : const Color(0xFF444444),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 18),
        ],

        // Recommended Action
        if (exp.recommendedAction.isNotEmpty) ...[
          Text(
            l10n.recommendedAction,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: headerTextColor,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF334155)
                    : const Color(0xFFBBF7D0),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.shield_outlined,
                  size: 20,
                  color: AppColors.primaryLight,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    exp.recommendedAction,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                      color: isDark
                          ? const Color(0xFFE2E8F0)
                          : const Color(0xFF1E293B),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],

        // Bottom Actions (Regenerate)
        Center(
          child: TextButton.icon(
            onPressed: () {
              _fetchAiExplanation();
            },
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: Text(
              l10n.regenerate,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
