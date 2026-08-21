import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/tatum_service.dart';
import '../services/virustotal_service.dart';

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
