import 'package:crypto_scanner/shared/services/haptic_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HapticService Unit Tests', () {
    test('Does not trigger haptic feedback when enabled is false', () async {
      final log = <MethodCall>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (call) async {
            log.add(call);
            return null;
          });

      await HapticService.success(enabled: false);
      await HapticService.error(enabled: false);
      await HapticService.selection(enabled: false);
      await HapticService.vibrate(enabled: false);

      expect(log, isEmpty);
    });

    test('Triggers haptic feedback when enabled is true', () async {
      final log = <MethodCall>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (call) async {
            log.add(call);
            return null;
          });

      await HapticService.success(enabled: true);
      await HapticService.error(enabled: true);
      await HapticService.selection(enabled: true);
      await HapticService.vibrate(enabled: true);

      expect(log.length, equals(4));
      expect(
        log.map((call) => call.method).toList(),
        everyElement(equals('HapticFeedback.vibrate')),
      );
    });
  });
}
