import '../../security/models/Analysis.dart';
import '../../security/models/crypto_wallet_scan.dart';

sealed class ScanResult {
  final String id;
  final String data;
  final DateTime scannedAt;

  const ScanResult({
    required this.id,
    required this.data,
    required this.scannedAt,
  });

  Map<String, dynamic> toJson();

  factory ScanResult.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    if (type == 'crypto') {
      return CryptoScanResult.fromJson(json);
    }
    return UrlScanResult.fromJson(json);
  }
}

class UrlScanResult extends ScanResult {
  final Analysis analysis;

  const UrlScanResult({
    required super.id,
    required super.data,
    required super.scannedAt,
    required this.analysis,
  });

  UrlScanResult copyWith({
    String? id,
    String? data,
    DateTime? scannedAt,
    Analysis? analysis,
  }) {
    return UrlScanResult(
      id: id ?? this.id,
      data: data ?? this.data,
      scannedAt: scannedAt ?? this.scannedAt,
      analysis: analysis ?? this.analysis,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'type': 'url',
    'data': data,
    'analysis': analysis.toJson(),
    'scannedAt': scannedAt.toIso8601String(),
  };

  factory UrlScanResult.fromJson(Map<String, dynamic> json) {
    return UrlScanResult(
      id: json['id'] as String? ?? '',
      data: json['data'] as String? ?? '',
      scannedAt:
          DateTime.tryParse(json['scannedAt'] as String? ?? '') ??
          DateTime.now(),
      analysis: Analysis.fromJson(
        json['analysis'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

class CryptoScanResult extends ScanResult {
  final CryptoWalletScan cryptoScan;

  const CryptoScanResult({
    required super.id,
    required super.data,
    required super.scannedAt,
    required this.cryptoScan,
  });

  CryptoScanResult copyWith({
    String? id,
    String? data,
    DateTime? scannedAt,
    CryptoWalletScan? cryptoScan,
  }) {
    return CryptoScanResult(
      id: id ?? this.id,
      data: data ?? this.data,
      scannedAt: scannedAt ?? this.scannedAt,
      cryptoScan: cryptoScan ?? this.cryptoScan,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'type': 'crypto',
    'data': data,
    'cryptoScan': cryptoScan.toJson(),
    'scannedAt': scannedAt.toIso8601String(),
  };

  factory CryptoScanResult.fromJson(Map<String, dynamic> json) {
    return CryptoScanResult(
      id: json['id'] as String? ?? '',
      data: json['data'] as String? ?? '',
      scannedAt:
          DateTime.tryParse(json['scannedAt'] as String? ?? '') ??
          DateTime.now(),
      cryptoScan: CryptoWalletScan.fromJson(
        json['cryptoScan'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}
