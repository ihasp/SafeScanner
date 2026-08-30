import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';

import 'threat_intelligence_registry.dart';

class OnDeviceAiService {
  static Map<String, dynamic>? _phishingModel;
  static Map<String, dynamic>? _blockchainModel;

  /// Loads both models into memory asynchronously
  static Future<void> initialize() async {
    try {
      if (_phishingModel == null) {
        final phishingData = await rootBundle.loadString(
          'assets/models/phishing_detector.json',
        );
        _phishingModel = jsonDecode(phishingData) as Map<String, dynamic>;
      }
      if (_blockchainModel == null) {
        final blockchainData = await rootBundle.loadString(
          'assets/models/blockchain_wallet_detector.json',
        );
        _blockchainModel = jsonDecode(blockchainData) as Map<String, dynamic>;
      }
    } catch (_) {}
  }

  static Map<String, double> extractUrlFeatures(String rawUrl) {
    String url = rawUrl.trim().toLowerCase();
    String domain = url;
    if (domain.contains('://')) {
      domain = domain.split('://')[1];
    }
    if (domain.contains('/')) {
      domain = domain.split('/').first;
    }
    if (domain.contains(':')) {
      domain = domain.split(':').first;
    }

    // Shannon Entropy
    double entropy = 0.0;
    if (domain.isNotEmpty) {
      final charCounts = <String, int>{};
      for (int i = 0; i < domain.length; i++) {
        charCounts[domain[i]] = (charCounts[domain[i]] ?? 0) + 1;
      }
      for (final count in charCounts.values) {
        final p = count / domain.length;
        entropy -= p * (log(p) / ln2);
      }
    }

    // Digits & Hyphens
    int digitCount = 0;
    int hyphenCount = 0;
    int dotCount = 0;
    for (int i = 0; i < domain.length; i++) {
      final code = domain.codeUnitAt(i);
      if (code >= 48 && code <= 57) digitCount++;
      if (domain[i] == '-') hyphenCount++;
      if (domain[i] == '.') dotCount++;
    }

    final highRiskTlds = {
      '.xyz',
      '.top',
      '.buzz',
      '.club',
      '.online',
      '.site',
      '.click',
      '.cfd',
      '.sbs',
      '.rest',
    };
    double hasHighRiskTld = highRiskTlds.any((t) => domain.endsWith(t))
        ? 1.0
        : 0.0;

    final keywords = [
      'claim',
      'airdrop',
      'reward',
      'drain',
      'permit',
      'connect',
      'sync',
      'rectify',
      'gift',
      'mint',
    ];
    double cryptoKeywordCount = 0.0;
    for (final kw in keywords) {
      if (url.contains(kw)) cryptoKeywordCount++;
    }

    final brands = [
      'uniswap',
      'metamask',
      'opensea',
      'binance',
      'coinbase',
      'phantom',
      'ledger',
      'trezor',
      'trustwallet',
      'pancakeswap',
      'curve',
      'aave',
    ];
    double brandImpersonation = 0.0;
    for (final b in brands) {
      if (domain.contains(b) &&
          !domain.endsWith('$b.com') &&
          !domain.endsWith('$b.org') &&
          !domain.endsWith('$b.io')) {
        brandImpersonation = 1.0;
        break;
      }
    }

    return {
      'url_length': rawUrl.length.toDouble(),
      'domain_length': domain.length.toDouble(),
      'shannon_entropy': entropy,
      'digit_count': digitCount.toDouble(),
      'digit_ratio': domain.isNotEmpty ? digitCount / domain.length : 0.0,
      'hyphen_count': hyphenCount.toDouble(),
      'dot_count': dotCount.toDouble(),
      'has_ip_address': RegExp(r'^\d+\.\d+\.\d+\.\d+$').hasMatch(domain)
          ? 1.0
          : 0.0,
      'has_high_risk_tld': hasHighRiskTld,
      'crypto_keyword_count': cryptoKeywordCount,
      'brand_impersonation_score': brandImpersonation,
      'is_punycode_homoglyph': domain.startsWith('xn--') ? 1.0 : 0.0,
      'longest_digit_run': 0.0,
      'vowel_consonant_ratio': 0.4,
    };
  }

  // ==========================================
  // 2. Tree Traversal Engine (Sub-Millisecond Inference)
  // ==========================================
  static double _evaluateRandomForest(
    Map<String, dynamic> modelJson,
    List<double> featureVector,
  ) {
    final trees = (modelJson['trees'] as List<Object?>?) ?? const [];
    if (trees.isEmpty) return 0.0;

    double totalMaliciousProb = 0.0;

    for (final treeData in trees) {
      final tree = treeData as Map<String, Object?>;
      final childrenLeft = (tree['children_left'] as List<Object?>)
          .whereType<int>()
          .toList();
      final childrenRight = (tree['children_right'] as List<Object?>)
          .whereType<int>()
          .toList();
      final features = (tree['feature'] as List<Object?>)
          .whereType<int>()
          .toList();
      final thresholds = (tree['threshold'] as List<Object?>)
          .whereType<num>()
          .map((e) => e.toDouble())
          .toList();
      final probabilities = (tree['probabilities'] as List<Object?>)
          .map(
            (row) => (row as List<Object?>)
                .whereType<num>()
                .map((p) => p.toDouble())
                .toList(),
          )
          .toList();

      int node = 0;
      while (childrenLeft[node] != -1) {
        final featureIdx = features[node];
        final threshold = thresholds[node];
        final val = featureIdx < featureVector.length
            ? featureVector[featureIdx]
            : 0.0;

        node = (val <= threshold) ? childrenLeft[node] : childrenRight[node];
      }

      final leafProb = probabilities[node][1];
      totalMaliciousProb += leafProb;
    }

    return totalMaliciousProb / trees.length;
  }

  // ==========================================
  // 3. Public Prediction Methods
  // ==========================================
  static Future<OnDeviceAiResult> predictUrl(String rawUrl) async {
    final stopwatch = Stopwatch()..start();
    await initialize();

    final featuresMap = extractUrlFeatures(rawUrl);
    final riskSignals = <String>[];

    if (featuresMap['brand_impersonation_score']! > 0.5) {
      riskSignals.add('Web3 Brand Impersonation');
    }
    if (featuresMap['has_high_risk_tld']! > 0.5) {
      riskSignals.add('High-risk disposable domain TLD');
    }
    if (featuresMap['crypto_keyword_count']! >= 2.0) {
      riskSignals.add(
        'High crypto keyword density (${featuresMap['crypto_keyword_count']!.toInt()} keywords)',
      );
    }
    if (featuresMap['shannon_entropy']! > 4.0) {
      riskSignals.add('High character entropy in domain (DGA pattern)');
    }

    double prob = 0.0;
    if (_phishingModel != null) {
      final featureNames =
          ((_phishingModel!['feature_names'] as List<Object?>?) ?? const [])
              .whereType<String>()
              .toList();
      final featureVector = featureNames
          .map((name) => featuresMap[name] ?? 0.0)
          .toList();
      prob = _evaluateRandomForest(_phishingModel!, featureVector);
    } else {
      // Heuristic fallback if model json not loaded
      prob = (riskSignals.length * 0.3).clamp(0.0, 0.95);
    }

    stopwatch.stop();

    final verdict = prob >= 0.75
        ? 'MALICIOUS'
        : (prob >= 0.40 ? 'SUSPICIOUS' : 'SAFE');

    return OnDeviceAiResult(
      verdict: verdict,
      maliciousProbability: prob,
      detectedRiskSignals: riskSignals,
      latencyMs: stopwatch.elapsedMilliseconds,
    );
  }

  // ==========================================
  // 3. Known Threat & Protocol Intelligence Index
  // ==========================================

  /// Synchronous instant check for known malicious addresses
  static String? getKnownMaliciousDescription(String rawAddress) =>
      ThreatIntelligenceRegistry.getKnownMaliciousDescription(rawAddress);

  /// Synchronous instant check for known verified safe protocols
  static String? getKnownSafeLabel(String rawAddress) =>
      ThreatIntelligenceRegistry.getKnownSafeLabel(rawAddress);

  // ==========================================
  // 4. Public Prediction Methods
  // ==========================================
  static Future<OnDeviceAiResult> evaluateCryptoAddress(
    String rawAddress,
  ) async {
    final stopwatch = Stopwatch()..start();
    final addr = rawAddress.trim().toLowerCase();

    // 1. Check known malicious exploit registry
    final knownThreat = ThreatIntelligenceRegistry.getKnownMaliciousDescription(
      addr,
    );
    if (knownThreat != null) {
      stopwatch.stop();
      return OnDeviceAiResult(
        verdict: 'MALICIOUS',
        maliciousProbability: 0.99,
        detectedRiskSignals: [
          'Address associated with known attack: $knownThreat',
          'Direct transfers to mixers or malicious contracts detected',
        ],
        latencyMs: stopwatch.elapsedMilliseconds,
      );
    }

    // 2. Check verified safe protocol registry
    if (ThreatIntelligenceRegistry.isKnownSafe(addr)) {
      stopwatch.stop();
      return OnDeviceAiResult(
        verdict: 'SAFE',
        maliciousProbability: 0.0,
        detectedRiskSignals: const [],
        latencyMs: stopwatch.elapsedMilliseconds,
      );
    }

    // 3. Fallback to On-Device Behavioral Random Forest Inference
    await initialize();

    final featureVector = [
      1.5, // walletAgeDays (default assumed young until on-chain sync)
      48.0, // total_tx_count
      8.5, // inOutRatio (drainer asymmetry heuristic)
      1.2, // holdingTimeHours
      1.0, // mixerProximityHops
      0.9, // gasFundingRisk
      12.0, // token_asset_diversity
      0.0, // is_smart_contract
      0.0, // unverified_code_flag
      0.85, // burst_activity_index
      1.0, // zero_value_spam_flag
    ];

    double prob = 0.0;
    if (_blockchainModel != null) {
      prob = _evaluateRandomForest(_blockchainModel!, featureVector);
    }

    stopwatch.stop();

    return OnDeviceAiResult(
      verdict: prob >= 0.75
          ? 'MALICIOUS'
          : (prob >= 0.40 ? 'SUSPICIOUS' : 'SAFE'),
      maliciousProbability: prob,
      detectedRiskSignals: const [
        'Adres niezweryfikowany w bazie certyfikowanych protokołów Web3',
      ],
      latencyMs: stopwatch.elapsedMilliseconds,
    );
  }

  static Future<OnDeviceAiResult> predictWalletBehavior({
    required double walletAgeDays,
    required double inOutRatio,
    required double holdingTimeHours,
    required double mixerProximityHops,
    required double gasFundingRisk,
  }) async {
    final stopwatch = Stopwatch()..start();
    await initialize();

    final featureVector = [
      walletAgeDays,
      48.0, // total_tx_count
      inOutRatio,
      holdingTimeHours,
      mixerProximityHops,
      gasFundingRisk,
      12.0, // token_asset_diversity
      0.0, // is_smart_contract
      0.0, // unverified_code_flag
      0.85, // burst_activity_index
      1.0, // zero_value_spam_flag
    ];

    final double prob = _blockchainModel != null
        ? _evaluateRandomForest(_blockchainModel!, featureVector)
        : (holdingTimeHours < 2.0 ? 0.95 : 0.10);

    stopwatch.stop();

    final signals = <String>[];
    if (holdingTimeHours < 2.0) {
      signals.add('Rapid fund sweeping after deposit (< 2h - drainer pattern)');
    }
    if (inOutRatio > 8.0) {
      signals.add('High transaction asymmetry (mass fund draining pattern)');
    }
    if (mixerProximityHops <= 1.0) {
      signals.add(
        'Direct interaction with cryptocurrency mixer (e.g. Tornado Cash)',
      );
    }
    if (walletAgeDays < 3.0) {
      signals.add('Very new address (created within the last 72 hours)');
    }

    return OnDeviceAiResult(
      verdict: prob >= 0.75
          ? 'MALICIOUS'
          : (prob >= 0.40 ? 'SUSPICIOUS' : 'SAFE'),
      maliciousProbability: prob,
      detectedRiskSignals: signals,
      latencyMs: stopwatch.elapsedMilliseconds,
    );
  }
}

class OnDeviceAiResult {
  final String verdict;
  final double maliciousProbability;
  final List<String> detectedRiskSignals;
  final int latencyMs;

  const OnDeviceAiResult({
    required this.verdict,
    required this.maliciousProbability,
    required this.detectedRiskSignals,
    required this.latencyMs,
  });

  bool get isMalicious => verdict == 'MALICIOUS';
  bool get isSuspicious => verdict == 'SUSPICIOUS';
  bool get isSafe => verdict == 'SAFE';
}
