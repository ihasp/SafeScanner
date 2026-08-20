// ignore_for_file: prefer-match-file-name
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../helpers/shared/date_group_helper.dart';
import '../../security/models/analysis_model.dart';
import '../../security/models/crypto_wallet_scan.dart';
import '../../settings/providers/settings_provider.dart';
import '../models/scan_group.dart';
import '../models/scan_result.dart';
import '../services/scan_results_storage_service.dart';

final scanResultsStorageServiceProvider = Provider<ScanResultsStorageService>((
  ref,
) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ScanResultsStorageService(prefs);
});

class ScanResultsNotifier extends Notifier<List<ScanResult>> {
  late final ScanResultsStorageService _storageService;

  @override
  List<ScanResult> build() {
    _storageService = ref.watch(scanResultsStorageServiceProvider);
    return _storageService.loadScansSync();
  }

  Future<void> _persist() async {
    await _storageService.saveScans(state);
  }

  void addUrlScan({required String data, required Analysis analysis}) {
    final settings = ref.read(settingsProvider);
    if (settings.incognitoMode) return;

    final newScan = UrlScanResult(
      id: '${DateTime.now().millisecondsSinceEpoch}-${state.length}',
      data: data,
      scannedAt: DateTime.now(),
      analysis: analysis,
    );

    final updated = [newScan, ...state];
    final limit = settings.historySizeLimit;
    state = updated.length > limit ? updated.sublist(0, limit) : updated;
    _persist();
  }

  void updateUrlScan(String data, Analysis analysis) {
    final index = state.indexWhere((s) => s is UrlScanResult && s.data == data);
    if (index != -1) {
      final updated = List<ScanResult>.of(state);
      final existing = updated[index] as UrlScanResult;
      updated[index] = existing.copyWith(analysis: analysis);
      state = updated;
      _persist();
    }
  }

  void addCryptoScan({
    required String data,
    required CryptoWalletScan cryptoScan,
  }) {
    final settings = ref.read(settingsProvider);
    if (settings.incognitoMode) return;

    final newScan = CryptoScanResult(
      id: '${DateTime.now().millisecondsSinceEpoch}-${state.length}',
      data: data,
      scannedAt: DateTime.now(),
      cryptoScan: cryptoScan,
    );

    final updated = [newScan, ...state];
    final limit = settings.historySizeLimit;
    state = updated.length > limit ? updated.sublist(0, limit) : updated;
    _persist();
  }

  void clearScans() {
    state = const [];
    _storageService.clearScans();
  }
}

final scanResultsProvider =
    NotifierProvider<ScanResultsNotifier, List<ScanResult>>(
      ScanResultsNotifier.new,
    );

final groupedScansProvider = Provider<List<ScanGroup>>((ref) {
  final scans = ref.watch(scanResultsProvider);
  final groupsMap = <String, List<ScanResult>>{};

  for (final scan in scans) {
    final key = DateGroupHelper.getGroupKey(scan.scannedAt);
    groupsMap.putIfAbsent(key, () => <ScanResult>[]).add(scan);
  }

  return groupsMap.entries.map((entry) {
    final firstScan = entry.value.first;
    return ScanGroup(
      key: entry.key,
      title: DateGroupHelper.getGroupTitle(firstScan.scannedAt),
      scans: List.unmodifiable(entry.value),
    );
  }).toList();
});
