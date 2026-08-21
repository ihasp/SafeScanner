import 'tatum_chain.dart';

class CryptoDecision {
  final MaliciousCheckStatus status;
  final CryptoSafetyLevel safetyLevel;
  final bool isSafe;
  final List<String> reasons;
  final List<String>? signals;

  const CryptoDecision({
    required this.status,
    required this.safetyLevel,
    required this.isSafe,
    required this.reasons,
    this.signals,
  });
}

enum CryptoSafetyLevel { safe, malicious, unverified }
