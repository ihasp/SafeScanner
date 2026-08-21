import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constants/app_colors.dart';
import '../../../helpers/shared/url_open_helper.dart';
import '../../../shared/models/scan_mode.dart';
import '../../settings/providers/settings_notifier.dart';
import '../logic/analysis_status_resolver.dart';
import '../logic/decision_maker.dart';
import '../models/analysis.dart';
import '../models/crypto_scan_state.dart';
import '../models/tatum_chain.dart';
import 'crypto_wallet_results_view.dart';
import 'custom_flatlist_view.dart';
import 'glow_overlay_view.dart';
import 'scanning_progress_view.dart';

class ScannedLayoutSheet extends ConsumerStatefulWidget {
  final String data;
  final Analysis? analysis;
  final CryptoScanState? cryptoScan;
  final ScanMode scanMode;
  final VoidCallback onClose;
  final VoidCallback onCloseStart;
  final Future<void> Function() onRetry;

  const ScannedLayoutSheet({
    super.key,
    required this.data,
    this.analysis,
    this.cryptoScan,
    required this.scanMode,
    required this.onClose,
    required this.onCloseStart,
    required this.onRetry,
  });

  @override
  ConsumerState<ScannedLayoutSheet> createState() => _ScannedLayoutSheetState();
}

class _ScannedLayoutSheetState extends ConsumerState<ScannedLayoutSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _slideController;
  late final Animation<Offset> _slideAnimation;

  Timer? _pollingTimer;
  Timer? _glowTimer;
  bool _isPolling = false;
  bool _showGlow = false;
  GlowSeverity _glowSeverity = GlowSeverity.safe;
  bool _hasTriggeredGlow = false;
  bool _hasOpenedAutoLink = false;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _slideController.forward();
    _checkInitialState();
  }

  @override
  void didUpdateWidget(covariant ScannedLayoutSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      _hasTriggeredGlow = false;
      _hasOpenedAutoLink = false;
    }
    _onWidgetUpdated();
  }

  void _checkInitialState() {
    final settings = ref.read(settingsProvider);

    if (widget.scanMode == ScanMode.qr) {
      final isCompleted =
          widget.analysis?.data.attributes.status == AnalysisStatus.completed;

      if (isCompleted) {
        _applyGlowState(widget.analysis);
      } else {
        _startPolling(settings.apiPollingRate);
      }
    } else {
      if (widget.cryptoScan?.status == CryptoScanStatus.completed) {
        _applyCryptoGlowState(widget.cryptoScan);
      }
    }
  }

  void _onWidgetUpdated() {
    if (widget.scanMode == ScanMode.qr) {
      final isCompleted =
          widget.analysis?.data.attributes.status == AnalysisStatus.completed;

      if (isCompleted) {
        _pollingTimer?.cancel();
        if (!_hasTriggeredGlow) {
          _applyGlowState(widget.analysis);
        }
      }
    } else {
      if (widget.cryptoScan?.status == CryptoScanStatus.completed &&
          !_hasTriggeredGlow) {
        _applyCryptoGlowState(widget.cryptoScan);
      }
    }
  }

  void _startPolling(int pollingRate) {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(Duration(milliseconds: pollingRate), (
      timer,
    ) {
      _pollAnalysis(timer);
    });
  }

  Future<void> _pollAnalysis(Timer timer) async {
    if (_isPolling) return;
    final isCompleted =
        widget.analysis?.data.attributes.status == AnalysisStatus.completed;
    if (isCompleted) {
      timer.cancel();
      if (!_hasTriggeredGlow) {
        _triggerGlow(widget.analysis);
      }
    } else {
      _isPolling = true;
      try {
        await widget.onRetry();
      } finally {
        _isPolling = false;
      }
    }
  }

  void _applyGlowState(Analysis? analysis) {
    if (analysis == null || _hasTriggeredGlow) return;
    _hasTriggeredGlow = true;

    final resolved = AnalysisStatusResolver.resolve(analysis);
    _glowSeverity = switch (resolved.verdict) {
      AnalysisVerdict.safe => GlowSeverity.safe,
      AnalysisVerdict.warning => GlowSeverity.warning,
      AnalysisVerdict.malicious => GlowSeverity.malicious,
    };
    _showGlow = true;

    final settings = ref.read(settingsProvider);
    final isCompleted =
        analysis.data.attributes.status == AnalysisStatus.completed;
    if (settings.autoOpenSafeLinks &&
        isCompleted &&
        resolved.isSafe &&
        !_hasOpenedAutoLink) {
      _hasOpenedAutoLink = true;
      _openUrl(widget.data);
    }

    _glowTimer?.cancel();
    _glowTimer = Timer(const Duration(milliseconds: 2000), () {
      if (mounted) {
        setState(() {
          _showGlow = false;
        });
      }
    });
  }

  void _applyCryptoGlowState(CryptoScanState? cryptoState) {
    if (cryptoState?.result == null || _hasTriggeredGlow) return;
    _hasTriggeredGlow = true;

    final isSafe = DecisionMaker.isWalletSafe(cryptoState!.result!);
    final isMalicious =
        cryptoState.result!.safety.status == MaliciousCheckStatus.invalid;
    _glowSeverity = isSafe
        ? GlowSeverity.safe
        : (isMalicious ? GlowSeverity.malicious : GlowSeverity.warning);
    _showGlow = true;

    _glowTimer?.cancel();
    _glowTimer = Timer(const Duration(milliseconds: 2000), () {
      if (mounted) {
        setState(() {
          _showGlow = false;
        });
      }
    });
  }

  void _triggerGlow(Analysis? analysis) {
    if (analysis == null || _hasTriggeredGlow || !mounted) return;
    setState(() {
      _applyGlowState(analysis);
    });
  }

  Future<void> _openUrl(String url) async {
    await UrlOpenHelper.openUrl(url);
  }

  Future<void> _handleDismiss() async {
    widget.onCloseStart();
    await _slideController.reverse();
    widget.onClose();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _glowTimer?.cancel();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isCrypto = widget.scanMode == ScanMode.crypto;
    final resolvedUrl = widget.analysis != null
        ? AnalysisStatusResolver.resolve(widget.analysis!)
        : null;

    final canOpenLink =
        !isCrypto && resolvedUrl != null && resolvedUrl.canOpenLink;

    final isUrlCompleted =
        widget.analysis?.data.attributes.status == AnalysisStatus.completed;
    final isUrlFailed =
        widget.analysis?.data.attributes.status == AnalysisStatus.failed;

    final isCryptoCompleted =
        widget.cryptoScan?.status == CryptoScanStatus.completed &&
        widget.cryptoScan?.result != null;
    final isCryptoFailed = widget.cryptoScan?.status == CryptoScanStatus.failed;

    final isScanning = isCrypto
        ? (!isCryptoCompleted && !isCryptoFailed)
        : (!isUrlCompleted && !isUrlFailed);

    final sheetBg = isDark ? const Color(0xFF1E2022) : Colors.white;
    final headerTextColor = isDark ? AppColors.textDark : AppColors.textLight;

    return Stack(
      children: [
        SlideTransition(
          position: _slideAnimation,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.70,
              width: double.infinity,
              decoration: BoxDecoration(
                color: sheetBg,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Top drag handle with close button
                  GestureDetector(
                    onVerticalDragEnd: (details) {
                      if (details.primaryVelocity != null &&
                          details.primaryVelocity! > 100) {
                        _handleDismiss();
                      }
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 8,
                        left: 16,
                        right: 16,
                      ),
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
                              onPressed: () {
                                _handleDismiss();
                              },
                              splashRadius: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Title
                  Text(
                    isCrypto ? 'Crypto wallet:' : 'Scanned link:',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: headerTextColor,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Scanned link/address text
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: isCrypto
                        ? Text(
                            widget.data,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          )
                        : InkWell(
                            onTap: canOpenLink
                                ? () => _openUrl(widget.data)
                                : null,
                            borderRadius: BorderRadius.circular(6),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Flexible(
                                    child: Text(
                                      widget.data,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: canOpenLink
                                            ? AppColors.primaryLight
                                            : AppColors.textSecondary,
                                        decoration: canOpenLink
                                            ? TextDecoration.underline
                                            : TextDecoration.none,
                                      ),
                                    ),
                                  ),
                                  if (canOpenLink) ...[
                                    const SizedBox(width: 4),
                                    const Icon(
                                      Icons.open_in_new_rounded,
                                      size: 14,
                                      color: AppColors.primaryLight,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(height: 12),

                  // Content
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          if (isScanning)
                            const ScanningProgressView()
                          else if (!isCrypto &&
                              isUrlCompleted &&
                              widget.analysis != null) ...[
                            CustomFlatlistView(analysis: widget.analysis!),
                            if (canOpenLink)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 8,
                                ),
                                child: SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: ElevatedButton.icon(
                                    onPressed: () => _openUrl(widget.data),
                                    icon: const Icon(
                                      Icons.open_in_browser_rounded,
                                      color: Colors.white,
                                    ),
                                    label: const Text(
                                      'Open Link in Browser',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: resolvedUrl.isWarning
                                          ? AppColors.warning
                                          : AppColors.primary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      elevation: 0,
                                    ),
                                  ),
                                ),
                              )
                            else if (resolvedUrl != null &&
                                resolvedUrl.isMalicious)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 8,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? AppColors.malicious.withAlpha(30)
                                        : AppColors.maliciousBg,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isDark
                                          ? AppColors.malicious.withAlpha(80)
                                          : AppColors.malicious.withAlpha(50),
                                    ),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(
                                        Icons.block_rounded,
                                        size: 20,
                                        color: AppColors.malicious,
                                      ),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          'Opening this link is blocked due to detected security threats.',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.malicious,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ] else if (!isCrypto &&
                              isUrlFailed &&
                              widget.analysis != null)
                            Padding(
                              padding: const EdgeInsets.all(24),
                              child: Text(
                                widget.analysis!.error ??
                                    'Unable to scan this link.',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.malicious,
                                ),
                              ),
                            )
                          else if (isCrypto &&
                              isCryptoCompleted &&
                              widget.cryptoScan?.result != null)
                            CryptoWalletResultsView(
                              scan: widget.cryptoScan!.result!,
                            )
                          else if (isCrypto && isCryptoFailed)
                            Padding(
                              padding: const EdgeInsets.all(24),
                              child: Text(
                                widget.cryptoScan?.error ??
                                    'Unable to scan this crypto wallet.',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.malicious,
                                ),
                              ),
                            ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: GlowOverlayView(severity: _glowSeverity, visible: _showGlow),
        ),
      ],
    );
  }
}
