import 'package:flutter/services.dart';

abstract final class HapticService {
  static Future<void> success({required bool enabled}) async {
    if (!enabled) return;
    await HapticFeedback.vibrate();
  }

  static Future<void> error({required bool enabled}) async {
    if (!enabled) return;
    await HapticFeedback.vibrate();
  }

  static Future<void> selection({required bool enabled}) async {
    if (!enabled) return;
    await HapticFeedback.selectionClick();
  }

  static Future<void> vibrate({required bool enabled}) async {
    if (!enabled) return;
    await HapticFeedback.vibrate();
  }
}
