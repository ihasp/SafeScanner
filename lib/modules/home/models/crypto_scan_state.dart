import '../../security/models/crypto_wallet_scan.dart';

class CryptoScanState {
  final CryptoScanStatus status;
  final CryptoWalletScan? result;
  final String? error;

  const CryptoScanState({required this.status, this.result, this.error});

  factory CryptoScanState.queued() =>
      const CryptoScanState(status: CryptoScanStatus.queued);

  factory CryptoScanState.completed(CryptoWalletScan result) =>
      CryptoScanState(status: CryptoScanStatus.completed, result: result);

  factory CryptoScanState.failed(String error) =>
      CryptoScanState(status: CryptoScanStatus.failed, error: error);
}

enum CryptoScanStatus { queued, completed, failed }
