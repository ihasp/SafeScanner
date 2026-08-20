import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/scan_result.dart';

class ScanResultsStorageService {
  static const String _storageKey = 'scan_results_history';
  final SharedPreferences? _prefs;

  ScanResultsStorageService([this._prefs]);

  List<ScanResult> loadScansSync() {
    if (_prefs == null) return const [];
    try {
      final jsonString = _prefs.getString(_storageKey);
      if (jsonString != null && jsonString.isNotEmpty) {
        final decoded = jsonDecode(jsonString) as List<Object?>;
        return decoded
            .whereType<Map<String, dynamic>>()
            .map(ScanResult.fromJson)
            .toList();
      }
    } catch (_) {}
    return const [];
  }

  Future<List<ScanResult>> loadScans() async {
    if (_prefs != null) return loadScansSync();
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);
      if (jsonString != null && jsonString.isNotEmpty) {
        final decoded = jsonDecode(jsonString) as List<Object?>;
        return decoded
            .whereType<Map<String, dynamic>>()
            .map(ScanResult.fromJson)
            .toList();
      }
    } catch (_) {}
    return const [];
  }

  Future<void> saveScans(List<ScanResult> scans) async {
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      final list = scans.map((s) => s.toJson()).toList();
      final jsonString = jsonEncode(list);
      await prefs.setString(_storageKey, jsonString);
    } catch (_) {}
  }

  Future<void> clearScans() async {
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
    } catch (_) {}
  }
}
