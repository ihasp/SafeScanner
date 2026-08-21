import 'package:flutter/material.dart';

abstract final class AppColors {
  // Theme colors
  static const Color primary = Color.fromARGB(255, 12, 114, 204);
  static const Color primaryLight = Color.fromARGB(255, 100, 135, 210);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF151718);
  static const Color textLight = Color(0xFF11181C);
  static const Color textDark = Color(0xFFECEDEE);
  static const Color textMuted = Color(0xFF777777);
  static const Color textSecondary = Color(0xFF687076);
  static const Color border = Color(0xFFEEEEEE);
  static const Color borderDark = Color(0xFF2C2C2E);

  // Status colors
  static const Color safe = Color(0xFF00A83B);
  static const Color safeBg = Color(0xFFEEFAF2);
  static const Color warning = Color(0xFFFF8F00);
  static const Color warningBg = Color(0xFFFFF4E5);
  static const Color malicious = Color(0xFFD72845);
  static const Color maliciousBg = Color(0xFFFFF1F3);
  static const Color phishing = Color(0xFFFF8F00);
  static const Color suspicious = Color(0xFFFFBE00);
  static const Color unknown = Color(0xFF777777);

  // Switch button & overlay colors
  static const Color switchBackground = Color.fromARGB(77, 9, 9, 9);
  static const Color glowSafe = Color(0x9F00FF00);
  static const Color glowWarning = Color(0x9FFF8F00);
  static const Color glowMalicious = Color(0x9FFF0000);
}
