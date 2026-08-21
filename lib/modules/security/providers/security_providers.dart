import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/tatum_service.dart';
import '../services/virustotal_service.dart';

final virusTotalServiceProvider = Provider<VirusTotalService>((ref) {
  return VirusTotalService();
});

final tatumServiceProvider = Provider<TatumService>((ref) {
  return TatumService();
});
