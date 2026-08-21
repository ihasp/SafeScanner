import '../../../shared/models/scan_mode.dart';
import '../../security/logic/address_decoder.dart';

abstract final class ScanModeDetector {
  static ScanMode detect(String payload) {
    final wallet = AddressDecoder.decode(payload);
    return wallet != null ? ScanMode.crypto : ScanMode.qr;
  }
}
