import 'dart:async';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../shared/constants/app_constants.dart';

class BadBlockWhitelistService {
  static const String _prefCacheKey = 'badblock_whitelist_cache';
  static const String _prefLastSyncKey = 'badblock_whitelist_last_sync';
  static const String _seedAssetPath =
      'assets/whitelist/badblock_whitelist.txt';

  final http.Client _client;
  final SharedPreferences? prefs;

  final Set<String> _exactDomains = <String>{};
  final List<RegExp> _wildcardPatterns = <RegExp>[];
  bool _isSyncing = false;
  bool _isInitialized = false;

  BadBlockWhitelistService({http.Client? client, this.prefs})
    : _client = client ?? http.Client();

  int get domainCount => _exactDomains.length;
  int get wildcardCount => _wildcardPatterns.length;
  bool get isInitialized => _isInitialized;

  /// Parses ABP whitelist rules into exact domains and wildcard regexes.
  static ({Set<String> exactDomains, List<RegExp> wildcardPatterns}) parseRules(
    String rawContent,
  ) {
    final exact = <String>{};
    final wildcards = <RegExp>[];

    final lines = rawContent.split(RegExp(r'\r?\n'));
    for (final rawLine in lines) {
      final trimmed = rawLine.trim();
      if (trimmed.isEmpty ||
          trimmed.startsWith('!') ||
          trimmed.startsWith('#') ||
          trimmed.startsWith('[') ||
          trimmed.startsWith('Source:') ||
          trimmed == '---') {
        continue;
      }

      // Strip ABP options / modifiers at end, e.g. $important, $document
      var cleaned = trimmed.contains('\$')
          ? trimmed.split('\$').first.trim()
          : trimmed;

      // Strip ABP whitelist and domain matching prefixes
      if (cleaned.startsWith('@@||')) {
        cleaned = cleaned.substring(4);
      } else if (cleaned.startsWith('@@|')) {
        cleaned = cleaned.substring(3);
      } else if (cleaned.startsWith('||')) {
        cleaned = cleaned.substring(2);
      } else if (cleaned.startsWith('|')) {
        cleaned = cleaned.substring(1);
      } else if (cleaned.startsWith('@@')) {
        cleaned = cleaned.substring(2);
      }

      // Strip ABP separators and anchors at end
      if (cleaned.endsWith('^|')) {
        cleaned = cleaned.substring(0, cleaned.length - 2);
      } else if (cleaned.endsWith('^') || cleaned.endsWith('|')) {
        cleaned = cleaned.substring(0, cleaned.length - 1);
      }

      cleaned = cleaned.trim().toLowerCase();
      if (cleaned.isEmpty) continue;

      if (cleaned.contains('*')) {
        final regexPattern =
            '^${cleaned.split('*').map(RegExp.escape).join('.*')}\$';
        try {
          wildcards.add(RegExp(regexPattern, caseSensitive: false));
        } catch (_) {}
      } else {
        exact.add(cleaned);
      }
    }

    return (exactDomains: exact, wildcardPatterns: wildcards);
  }

  /// Normalizes and extracts the domain / host from a URL or raw string.
  static String? extractDomain(String rawUrl) {
    var url = rawUrl.trim().toLowerCase();
    if (url.isEmpty) return null;

    if (url.contains('://')) {
      final uri = Uri.tryParse(url);
      if (uri != null && uri.host.isNotEmpty) {
        return uri.host;
      }
      url = url.split('://')[1];
    }

    // Strip path, query params, hash
    if (url.contains('/')) {
      url = url.split('/').first;
    }
    if (url.contains('?')) {
      url = url.split('?').first;
    }
    if (url.contains('#')) {
      url = url.split('#').first;
    }
    // Strip port
    if (url.contains(':')) {
      url = url.split(':').first;
    }

    // Trim dots
    url = url.replaceAll(RegExp(r'^\.+|\.+$'), '');
    return url.isEmpty ? null : url;
  }

  /// Initializes the service by loading cached rules (or seed asset) and triggering background sync.
  Future<void> initialize() async {
    await loadFromCache();
    unawaited(syncWhitelist());
  }

  /// Loads rules from SharedPreferences cache or fallback seed asset.
  Future<void> loadFromCache() async {
    final cached = prefs?.getString(_prefCacheKey);
    if (cached != null && cached.isNotEmpty) {
      _applyRawRules(cached);
      _isInitialized = true;
      return;
    }

    try {
      final seedData = await rootBundle.loadString(_seedAssetPath);
      if (seedData.isNotEmpty) {
        _applyRawRules(seedData);
      }
    } catch (_) {}

    _isInitialized = true;
  }

  void _applyRawRules(String rawContent) {
    final parsed = parseRules(rawContent);
    _exactDomains.clear();
    _exactDomains.addAll(parsed.exactDomains);
    _wildcardPatterns.clear();
    _wildcardPatterns.addAll(parsed.wildcardPatterns);
  }

  /// Dynamically synchronizes latest whitelist from remote endpoint.
  Future<bool> syncWhitelist({bool force = false}) async {
    if (_isSyncing) return false;

    if (!force && prefs != null) {
      final lastSync = prefs!.getInt(_prefLastSyncKey) ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;
      final ttlMs = Duration(hours: AppConstants.badBlockWhitelistTtlHours)
          .inMilliseconds;
      if (now - lastSync < ttlMs && _exactDomains.isNotEmpty) {
        return false;
      }
    }

    _isSyncing = true;
    try {
      final uri = Uri.parse(AppConstants.badBlockWhitelistUrl);
      final response = await _client
          .get(uri)
          .timeout(const Duration(seconds: 10));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final body = response.body;
        if (body.isNotEmpty) {
          _applyRawRules(body);
          if (prefs != null) {
            await prefs!.setString(_prefCacheKey, body);
            await prefs!.setInt(
              _prefLastSyncKey,
              DateTime.now().millisecondsSinceEpoch,
            );
          }
          _isInitialized = true;
          return true;
        }
      }
    } catch (_) {
      // Graceful fallback to existing in-memory / cache rules
    } finally {
      _isSyncing = false;
    }
    return false;
  }

  /// Synchronously checks whether a URL or domain is present in the BadBlock whitelist.
  bool isWhitelisted(String rawUrl) {
    final domain = extractDomain(rawUrl);
    if (domain == null || domain.isEmpty) return false;

    // 1. Exact match
    if (_exactDomains.contains(domain)) {
      return true;
    }

    // 2. Parent domain hierarchy match (e.g. apps.apple.com matches apple.com)
    final parts = domain.split('.');
    if (parts.length > 2) {
      for (int i = 1; i < parts.length - 1; i++) {
        final parent = parts.sublist(i).join('.');
        if (_exactDomains.contains(parent)) {
          return true;
        }
      }
    }

    // 3. WWW prefix handling
    if (domain.startsWith('www.')) {
      final withoutWww = domain.substring(4);
      if (_exactDomains.contains(withoutWww)) {
        return true;
      }
    } else {
      final withWww = 'www.$domain';
      if (_exactDomains.contains(withWww)) {
        return true;
      }
    }

    // 4. Wildcard patterns
    for (final pattern in _wildcardPatterns) {
      if (pattern.hasMatch(domain)) {
        return true;
      }
    }

    return false;
  }

  void close() {
    _client.close();
  }
}
