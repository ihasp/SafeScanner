import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../settings/providers/settings_notifier.dart';
import '../services/badblock_whitelist_service.dart';
import '../services/tatum_service.dart';
import '../services/virustotal_service.dart';

final badBlockWhitelistServiceProvider = Provider<BadBlockWhitelistService>((
  ref,
) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final service = BadBlockWhitelistService(prefs: prefs);
  ref.onDispose(service.close);
  return service;
});

final virusTotalServiceProvider = Provider<VirusTotalService>((ref) {
  final service = VirusTotalService();
  ref.onDispose(service.close);
  return service;
});

final tatumServiceProvider = Provider<TatumService>((ref) {
  final service = TatumService();
  ref.onDispose(service.close);
  return service;
});
