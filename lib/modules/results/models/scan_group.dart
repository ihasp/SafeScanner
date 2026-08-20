import 'scan_result.dart';

class ScanGroup {
  final String key;
  final String title;
  final List<ScanResult> scans;

  const ScanGroup({
    required this.key,
    required this.title,
    required this.scans,
  });
}
