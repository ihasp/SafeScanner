import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:photo_manager/photo_manager.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/app_constants.dart';
import '../../../shared/models/scan_mode.dart';
import '../../../shared/services/haptic_service.dart';
import '../../results/providers/scan_results_notifier.dart';
import '../../scanner/logic/qr_payload_parser.dart';
import '../../scanner/logic/url_validator.dart';
import '../../security/logic/address_decoder.dart';
import '../../security/models/analysis.dart';
import '../../security/models/crypto_scan_state.dart';
import '../../security/providers/security_providers.dart';
import '../../security/ui/scanned_layout_sheet.dart';
import '../../settings/providers/settings_notifier.dart';
import '../ui/asset_thumbnail.dart';

class GalleryPage extends ConsumerStatefulWidget {
  const GalleryPage({super.key});

  @override
  ConsumerState<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends ConsumerState<GalleryPage>
    with WidgetsBindingObserver {
  late final MobileScannerController _scannerController;
  bool _isLoading = true;
  bool _permissionDenied = false;
  bool _isLimitedPermission = false;
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
    WidgetsBinding.instance.addObserver(this);
    _scannerController = MobileScannerController(autoStart: false);
    PhotoManager.addChangeCallback(_onPhotoManagerChange);
    _loadGalleryAssets();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    PhotoManager.removeChangeCallback(_onPhotoManagerChange);
    _scannerController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadGalleryAssets();
    }
  }

  void _onPhotoManagerChange(MethodCall call) {
    if (mounted) {
      _loadGalleryAssets();
    }
  }

  Future<void> _openLimitedMediaPicker() async {
    try {
      await PhotoManager.presentLimited();
      if (mounted) {
        await _loadGalleryAssets();
      }
    } catch (_) {}
  }

  Future<void> _loadGalleryAssets() async {
    if (_assets.isEmpty) {
      setState(() {
        _isLoading = true;
        _permissionDenied = false;
      });
    }

    final permission = await PhotoManager.requestPermissionExtend(
      requestOption: const PermissionRequestOption(
        androidPermission: AndroidPermission(
          type: RequestType.image,
          mediaLocation: false,
        ),
      ),
    );
    final hasAccess = permission.isAuth || permission.hasAccess;
    final isLimited = permission == PermissionState.limited;

    if (!hasAccess) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _permissionDenied = true;
          _isLimitedPermission = false;
          _selectedAsset = null;
        });
      }
      return;
    }

    try {
      final filterOption = FilterOptionGroup(
        orders: [
          const OrderOption(type: OrderOptionType.createDate, asc: false),
        ],
      );

      final paths = await PhotoManager.getAssetPathList(
        type: RequestType.image,
        onlyAll: true,
        filterOption: filterOption,
      );

      if (paths.isEmpty) {
        if (mounted) {
          setState(() {
            _assets = [];
            _selectedAsset = null;
            _isLimitedPermission = isLimited;
            _isLoading = false;
          });
        }
        return;
      }

      // Load assets ordered from newest to oldest
      final recentAlbum = paths.firstWhere(
        (p) => p.isAll,
        orElse: () => paths.first,
      );
      final assetCount = await recentAlbum.assetCountAsync;
      final assets = await recentAlbum.getAssetListPaged(
        page: 0,
        size: assetCount > 120 ? 120 : assetCount,
      );

      assets.sort((a, b) {
        final cmp = b.createDateTime.compareTo(a.createDateTime);
        if (cmp != 0) return cmp;
        return b.modifiedDateTime.compareTo(a.modifiedDateTime);
      });

      if (mounted) {
        setState(() {
          _assets = assets;
          _isLimitedPermission = isLimited;
          _isLoading = false;
          if (_selectedAsset != null &&
              !_assets.any((a) => a.id == _selectedAsset!.id)) {
            _selectedAsset = null;
          }
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isLimitedPermission = isLimited;
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
      } catch (e) {
        if (mounted) {
          final failedAnalysis = Analysis.failed(
            error: e is Exception
                ? e.toString().replaceFirst('Exception: ', '')
                : 'Unable to scan this link.',
          );
          setState(() {
            _analysisData = failedAnalysis;
          });
          ref
              .read(scanResultsProvider.notifier)
              .updateUrlScan(_scannedData!, failedAnalysis);
        }
      } finally {
        _isRetrying = false;
      }
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
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Scanned QR code contains no readable content.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
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
      final isLikelyUrl = UrlValidator.isLikelyUrl(sanitized);

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
                const SizedBox(height: 16),
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
                      : _buildThumbnailGrid(bottomInset, isDark),
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

  Widget _buildThumbnailGrid(double bottomInset, bool isDark) {
    final showAddTile = _isLimitedPermission;
    final totalCount = _assets.length + (showAddTile ? 1 : 0);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1B1D1F) : const Color(0xFFF7F9FB),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: GridView.builder(
          padding: EdgeInsets.only(
            left: 12,
            right: 12,
            top: 12,
            bottom: bottomInset + 120,
          ),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: totalCount,
          itemBuilder: (context, index) {
            if (showAddTile && index == 0) {
              return _buildAddPhotosTile(
                isDark,
                key: const ValueKey('gallery_add_photos_tile'),
              );
            }

            final assetIndex = showAddTile ? index - 1 : index;
            final asset = _assets[assetIndex];
            final isSelected = _selectedAsset?.id == asset.id;

            return GestureDetector(
              key: ValueKey(asset.id),
              onTap: () {
                setState(() {
                  _selectedAsset = isSelected ? null : asset;
                });
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    AssetThumbnail(
                      key: ValueKey('thumb_${asset.id}'),
                      asset: asset,
                    ),
                    if (isSelected) ...[
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(80),
                          border: Border.all(
                            color: AppColors.primary,
                            width: 3.5,
                          ),
                          borderRadius: BorderRadius.circular(12),
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
        ),
      ),
    );
  }

  Widget _buildAddPhotosTile(bool isDark, {Key? key}) {
    return Material(
      key: key,
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          unawaited(_openLimitedMediaPicker());
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF24272B) : const Color(0xFFEDF2F7),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? const Color(0xFF383E48) : const Color(0xFFCBD5E1),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(isDark ? 50 : 30),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add_photo_alternate_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Add Photos',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textDark : AppColors.textLight,
                ),
              ),
            ],
          ),
        ),
      ),
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
    if (_isLimitedPermission) {
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
                'No Photos Selected',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textDark : AppColors.textLight,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'You gave limited gallery access without selecting any photos. Choose photos from Android gallery to scan them.',
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
                  unawaited(_openLimitedMediaPicker());
                },
                icon: const Icon(Icons.add_photo_alternate_outlined, size: 18),
                label: const Text('Select Photos'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  unawaited(PhotoManager.openSetting());
                },
                child: const Text('Manage in Settings'),
              ),
            ],
          ),
        ),
      );
    }

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
