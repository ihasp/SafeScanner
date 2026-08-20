enum ScanMode {
  qr,
  crypto;

  String get label => switch (this) {
    ScanMode.qr => 'QR',
    ScanMode.crypto => 'Crypto',
  };
}
