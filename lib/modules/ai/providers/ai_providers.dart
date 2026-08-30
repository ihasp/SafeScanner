import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/gemini_ai_service.dart';

final geminiAiServiceProvider = Provider<GeminiAiService>((ref) {
  return const GeminiAiService();
});
