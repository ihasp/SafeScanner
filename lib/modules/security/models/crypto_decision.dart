import 'tatum_models.dart';

class CryptoDecision {
  final MaliciousCheckStatus status;
  final bool isSafe;
  final List<String> reasons;
  final List<String>? signals;

  const CryptoDecision({
    required this.status,
    required this.isSafe,
    required this.reasons,
    this.signals,
  });
}
