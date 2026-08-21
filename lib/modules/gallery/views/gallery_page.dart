import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:photo_manager/photo_manager.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/app_constants.dart';
import '../../../helpers/crypto/address_decoder.dart';
import '../../../helpers/scanner/qr_payload_parser.dart';
import '../../../shared/models/scan_mode.dart';
import '../../../shared/services/haptic_service.dart';
import '../../home/models/crypto_scan_state.dart';
import '../../home/ui/asset_thumbnail.dart';
import '../../home/ui/scanner_view.dart';
import '../../results/providers/scan_results_notifier.dart';
import '../../security/models/Analysis.dart';
import '../../security/ui/scanned_layout_sheet.dart';
import '../../settings/providers/settings_notifier.dart';

class GalleryPage extends ConsumerStatefulWidget {
  const GalleryPage({super.key});

  @override
  ConsumerState<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends ConsumerState<GalleryPage> {
  late final MobileScannerController _scannerController;
  bool _isLoading = true;
  bool _permissionDenied = false;
  bool _isAnalyzing = false;
  bool _showScannedLayout = false;
  List<AssetEntity> _assets = [];
  AssetEntity? _selectedAsset;

  String? _scannedData;
  Analysis? _analysisData;
  CryptoScanState? _cryptoScanData;
  String? _currentAnalysisId;
  ScanMode _scanMode = ScanMode.qr;
  bool _isRetrying = false;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(autoStart: false);
    _loadGalleryAssets();
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _loadGalleryAssets() async {
    setState(() {
      _isLoading = true;
      _permissionDenied = false;
    });

    final permission = await PhotoManager.requestPermissionExtend();
    if (!permission.isAuth && !permission.hasAccess) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _permissionDenied = true;
        });
      }
      return;
    }

    try {
      final paths = await PhotoManager.getAssetPathList(
        type: RequestType.image,
        onlyAll: true,
      );

      if (paths.isEmpty) {
        if (mounted) {
          setState(() {
            _assets = [];
            _isLoading = false;
          });
        }
        return;
      }

      // Load assets ordered from newest to oldest
      final recentAlbum = paths.first;
      final assetCount = await recentAlbum.assetCountAsync;
      final assets = await recentAlbum.getAssetListPaged(
        page: 0,
        size: assetCount > 120 ? 120 : assetCount,
      );

      if (mounted) {
        setState(() {
          _assets = assets;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _permissionDenied = true;
        });
      }
    }
  }

  void _handleCloseStart() {
    _isAnalyzing = false;
  }

  void _handleClose() {
    if (!mounted) return;
    setState(() {
      _showScannedLayout = false;
      _scannedData = null;
      _analysisData = null;
      _cryptoScanData = null;
      _currentAnalysisId = null;
      _selectedAsset = null;
    });
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

  Future<void> _scanSelectedImage() async {
    if (_selectedAsset == null || _isAnalyzing) return;

    setState(() {
      _isAnalyzing = true;
    });

    try {
      final file = await _selectedAsset!.file;
      if (file == null) {
        if (mounted) {
          setState(() {
            _isAnalyzing = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Unable to read selected photo.'),
              duration: Duration(seconds: 3),
            ),
          );
        }
        return;
      }

      final capture = await _scannerController.analyzeImage(file.path);
      final barcode = capture?.barcodes.firstOrNull?.rawValue;

      if (barcode != null && barcode.isNotEmpty) {
        await _onBarcodeScanned(barcode);
      } else {
        if (mounted) {
          setState(() {
            _isAnalyzing = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No QR code found in the selected image.'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to analyze the selected image.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _onBarcodeScanned(String rawData) async {
    final sanitized = QrPayloadParser.sanitize(rawData);
    if (sanitized.isEmpty) {
      setState(() {
        _isAnalyzing = false;
      });
      return;
    }

    setState(() {
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
            _isAnalyzing = false;
          });
        }
      }
    } else {
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
          _isAnalyzing = false;
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
            _isAnalyzing = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? AppColors.surfaceDark : Colors.white;
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;

    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 16),
                const Center(
                  child: Icon(
                    Icons.photo_library_outlined,
                    size: 72,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    'Gallery',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        )
                      : _permissionDenied
                      ? _buildPermissionView(isDark)
                      : _assets.isEmpty
                      ? _buildEmptyView(isDark)
                      : _buildThumbnailGrid(bottomInset),
                ),
              ],
            ),
          ),

          // Confirmation button when photo is selected
          if (_selectedAsset != null && !_showScannedLayout)
            Positioned(
              left: 20,
              right: 20,
              bottom: bottomInset + 84,
              child: _buildConfirmButton(),
            ),

          // Scanned Layout Sheet modal overlay
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
      ),
    );
  }

  Widget _buildConfirmButton() {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(80),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isAnalyzing
            ? null
            : () {
                unawaited(_scanSelectedImage());
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isAnalyzing
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.qr_code_scanner_rounded, size: 22),
                  SizedBox(width: 8),
                  Text(
                    'Scan Selected Image',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildThumbnailGrid(double bottomInset) {
    return GridView.builder(
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        top: 4,
        bottom: bottomInset + 150,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
      ),
      itemCount: _assets.length,
      itemBuilder: (context, index) {
        final asset = _assets[index];
        final isSelected = _selectedAsset?.id == asset.id;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedAsset = isSelected ? null : asset;
            });
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              fit: StackFit.expand,
              children: [
                AssetThumbnail(asset: asset),
                if (isSelected) ...[
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(80),
                      border: Border.all(color: AppColors.primary, width: 3.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const Positioned(
                    top: 6,
                    right: 6,
                    child: CircleAvatar(
                      radius: 12,
                      backgroundColor: AppColors.primary,
                      child: Icon(
                        Icons.check_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPermissionView(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.photo_library_outlined,
              size: 56,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'Gallery Permission Needed',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textDark : AppColors.textLight,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Allow access to your photos to scan QR codes and crypto addresses from images.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                unawaited(PhotoManager.openSetting());
              },
              icon: const Icon(Icons.settings_rounded, size: 18),
              label: const Text('Open Settings'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.image_not_supported_outlined,
            size: 56,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'No photos found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textDark : AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }
}
