import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/scan_result.dart';

class ScanResultsStorageService {
  static const String _storageKey = 'scan_results_history';

  Future<List<ScanResult>> loadScans() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);
      if (jsonString != null && jsonString.isNotEmpty) {
        final decoded = jsonDecode(jsonString) as List<dynamic>;
        return decoded
            .map((item) => ScanResult.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
    return const [];
  }

  Future<void> saveScans(List<ScanResult> scans) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = scans.map((s) => s.toJson()).toList();
      final jsonString = jsonEncode(list);
      await prefs.setString(_storageKey, jsonString);
    } catch (_) {}
  }
}
