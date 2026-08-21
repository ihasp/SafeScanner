import 'package:flutter/services.dart';

abstract final class HapticService {
  static Future<void> success({required bool enabled}) async {
    if (!enabled) return;
    await HapticFeedback.lightImpact();
  }

  static Future<void> warning({required bool enabled}) async {
    if (!enabled) return;
    await HapticFeedback.mediumImpact();
  }

  static Future<void> error({required bool enabled}) async {
    if (!enabled) return;
    await HapticFeedback.heavyImpact();
    await Future<void>.delayed(const Duration(milliseconds: 120));
    await HapticFeedback.heavyImpact();
  }

  static Future<void> threat({required bool enabled}) async {
    if (!enabled) return;
    await HapticFeedback.heavyImpact();
    await Future<void>.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.heavyImpact();
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
