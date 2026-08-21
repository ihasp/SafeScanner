import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../constants/app_constants.dart';
import '../../../routing/tab_scaffold.dart';
import '../../../shared/models/scan_mode.dart';
import '../../../shared/services/haptic_service.dart';
import '../../results/providers/scan_results_notifier.dart';
import '../../security/logic/address_decoder.dart';
import '../../security/models/analysis.dart';
import '../../security/models/crypto_scan_state.dart';
import '../../security/providers/security_providers.dart';
import '../../security/ui/scanned_layout_sheet.dart';
import '../../settings/models/app_settings.dart';
import '../../settings/providers/settings_notifier.dart';
import '../logic/qr_payload_parser.dart';
import 'scan_mode_switch.dart';

class ScannerView extends ConsumerStatefulWidget {
  const ScannerView({super.key});

  @override
  ConsumerState<ScannerView> createState() => _ScannerViewState();
}

class _ScannerViewState extends ConsumerState<ScannerView>
    with WidgetsBindingObserver {
  late MobileScannerController _cameraController;
  Timer? _lockTimer;
  bool _qrLock = false;
  bool _isProcessingScan = false;
  bool _showScannedLayout = false;
  String? _scannedData;
  Analysis? _analysisData;
  CryptoScanState? _cryptoScanData;
  String? _currentAnalysisId;
  late ScanMode _scanMode;
  bool _isRetrying = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final settings = ref.read(settingsProvider);
    _scanMode = settings.defaultScanMode;
    _initCameraController(settings.defaultCameraFacing);
  }

  void _initCameraController(AppCameraFacing facing) {
    _cameraController = MobileScannerController(
      facing: facing == AppCameraFacing.front
          ? CameraFacing.front
          : CameraFacing.back,
      detectionSpeed: DetectionSpeed.normal,
      returnImage: false,
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted) return;
    final currentTab = ref.read(selectedTabIndexProvider);
    if (state == AppLifecycleState.resumed && currentTab == 0) {
      _cameraController.start();
    } else if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      _cameraController.stop();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _lockTimer?.cancel();
    _cameraController.dispose();
    super.dispose();
  }

  void _handleCloseStart() {
    _qrLock = true;
  }

  void _handleClose() {
    if (!mounted) return;
    setState(() {
      _isProcessingScan = false;
      _showScannedLayout = false;
      _scannedData = null;
      _analysisData = null;
      _cryptoScanData = null;
      _currentAnalysisId = null;
    });

    _lockTimer?.cancel();
    _lockTimer = Timer(
      const Duration(milliseconds: AppConstants.lockTimeoutMs),
      () {
        if (mounted) {
          _qrLock = false;
        }
      },
    );
  }

  Future<void> _handleRetry() async {
    if (_scannedData != null && _currentAnalysisId != null && !_isRetrying) {
      _isRetrying = true;
      try {
        final vtService = ref.read(virusTotalServiceProvider);
        final analysis = await vtService.getAnalysis(_currentAnalysisId!);
        if (mounted) {
          setState(() {
            _analysisData = analysis;
          });
        }
        ref
            .read(scanResultsProvider.notifier)
            .updateUrlScan(_scannedData!, analysis);
      } catch (_) {}
      _isRetrying = false;
    }
  }

  Future<void> _onBarcodeScanned(String rawData) async {
    final sanitized = QrPayloadParser.sanitize(rawData);
    if (sanitized.isEmpty || _qrLock) return;

    _qrLock = true;
    setState(() {
      _isProcessingScan = true;
      _scannedData = sanitized;
    });

    final settings = ref.read(settingsProvider);
    await HapticService.success(enabled: settings.hapticsEnabled);

    final wallet = AddressDecoder.decode(sanitized);
    final detectedMode = wallet != null ? ScanMode.crypto : ScanMode.qr;

    if (!mounted) return;
    setState(() {
      _scanMode = detectedMode;
    });

    await Future<void>.delayed(
      const Duration(milliseconds: AppConstants.scannedLayoutDelayMs),
    );

    if (detectedMode == ScanMode.crypto && wallet != null) {
      if (!mounted) return;
      setState(() {
        _cryptoScanData = CryptoScanState.queued();
        _showScannedLayout = true;
      });

      try {
        final tatumService = ref.read(tatumServiceProvider);
        final cryptoScan = await tatumService.getCryptoWalletAnalysis(wallet);
        if (!mounted) return;
        setState(() {
          _cryptoScanData = CryptoScanState.completed(cryptoScan);
        });
        ref
            .read(scanResultsProvider.notifier)
            .addCryptoScan(data: sanitized, cryptoScan: cryptoScan);
      } catch (e) {
        await HapticService.error(enabled: settings.hapticsEnabled);
        if (!mounted) return;
        setState(() {
          _cryptoScanData = CryptoScanState.failed(
            e is Exception
                ? e.toString().replaceFirst('Exception: ', '')
                : 'Unable to scan this crypto wallet.',
          );
        });
      } finally {
        if (mounted) {
          setState(() {
            _isProcessingScan = false;
          });
        }
      }
    } else {
      // URL / QR Mode
      final uri = Uri.tryParse(sanitized);
      final isLikelyUrl =
          uri != null &&
          ((uri.hasScheme &&
                  (uri.scheme == 'http' ||
                      uri.scheme == 'https' ||
                      uri.scheme == 'ftp') &&
                  uri.host.isNotEmpty) ||
              (!uri.hasScheme &&
                  !sanitized.contains('@') &&
                  !sanitized.contains(' ') &&
                  !sanitized.contains('\n') &&
                  !sanitized.startsWith('WIFI:') &&
                  !sanitized.startsWith('BEGIN:VCARD') &&
                  RegExp(r'^(?:[a-zA-Z0-9-]+\.)+[a-zA-Z]{2,}(?::\d+)?(?:/.*)?$')
                      .hasMatch(sanitized)));

      if (!isLikelyUrl) {
        if (!mounted) return;
        setState(() {
          _analysisData = Analysis.failed(
            error: 'Scanned content is plain text, not a web link.',
          );
          _showScannedLayout = true;
          _isProcessingScan = false;
        });
        return;
      }

      if (!mounted) return;
      setState(() {
        _analysisData = Analysis.queued();
        _showScannedLayout = true;
      });

      try {
        final vtService = ref.read(virusTotalServiceProvider);
        final analysisId = await vtService.scanUrl(sanitized);
        _currentAnalysisId = analysisId;
        final analysis = await vtService.getAnalysis(analysisId);
        if (!mounted) return;
        setState(() {
          _analysisData = analysis;
        });
        ref
            .read(scanResultsProvider.notifier)
            .addUrlScan(data: sanitized, analysis: analysis);
      } catch (e) {
        await HapticService.error(enabled: settings.hapticsEnabled);
        if (!mounted) return;
        setState(() {
          _analysisData = Analysis.failed(
            error: e is Exception
                ? e.toString().replaceFirst('Exception: ', '')
                : 'Unable to scan this link.',
          );
        });
      } finally {
        if (mounted) {
          setState(() {
            _isProcessingScan = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<int>(selectedTabIndexProvider, (previous, next) {
      if (next == 0) {
        _cameraController.start();
      } else {
        _cameraController.stop();
      }
    });

    ref.listen<AppSettings>(settingsProvider, (previous, next) {
      if (previous?.defaultCameraFacing != next.defaultCameraFacing) {
        if ((next.defaultCameraFacing == AppCameraFacing.front &&
                _cameraController.facing != CameraFacing.front) ||
            (next.defaultCameraFacing == AppCameraFacing.back &&
                _cameraController.facing != CameraFacing.back)) {
          _cameraController.switchCamera();
        }
      }
    });

    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Stack(
      children: [
        // Camera View
        Positioned.fill(
          child: MobileScanner(
            controller: _cameraController,
            onDetect: (capture) {
              final barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                final rawValue = barcode.rawValue;
                if (rawValue != null && rawValue.isNotEmpty) {
                  _onBarcodeScanned(rawValue);
                  break;
                }
              }
            },
          ),
        ),

        // QR / Crypto Switch at bottom center
        if (!_showScannedLayout)
          Positioned(
            bottom: bottomInset + 88,
            left: 0,
            right: 0,
            child: Center(
              child: ScanModeSwitch(
                scanMode: _scanMode,
                disabled: _isProcessingScan,
                onModeChanged: (mode) {
                  setState(() {
                    _scanMode = mode;
                  });
                },
              ),
            ),
          ),

        // Scanned Layout Sheet
        if (_showScannedLayout && _scannedData != null)
          ScannedLayoutSheet(
            data: _scannedData!,
            analysis: _analysisData,
            cryptoScan: _cryptoScanData,
            scanMode: _scanMode,
            onCloseStart: _handleCloseStart,
            onClose: _handleClose,
            onRetry: _handleRetry,
          ),
      ],
    );
  }
}
