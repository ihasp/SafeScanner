import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/l10n.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/models/scan_mode.dart';
import '../models/app_settings.dart';
import '../providers/settings_notifier.dart';
import '../ui/segment_button_group.dart';
import '../ui/setting_row.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          children: [
            const SizedBox(height: 16),
            const Center(
              child: Icon(
                Icons.settings_outlined,
                size: 72,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                l10n.settingsTitle,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Language Section / Setting
            SettingRow(
              title: l10n.language,
              subtitle: l10n.languageSubtitle,
              trailing: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF24272B)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.border,
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String?>(
                    value: settings.languageCode,
                    dropdownColor: isDark
                        ? const Color(0xFF24272B)
                        : Colors.white,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textDark : AppColors.textLight,
                    ),
                    icon: const Icon(
                      Icons.arrow_drop_down_rounded,
                      color: AppColors.primary,
                    ),
                    items: [
                      DropdownMenuItem(
                        value: null,
                        child: Text(l10n.systemLanguage),
                      ),
                      DropdownMenuItem(value: 'en', child: Text(l10n.langEn)),
                      DropdownMenuItem(value: 'pl', child: Text(l10n.langPl)),
                      DropdownMenuItem(value: 'es', child: Text(l10n.langEs)),
                      DropdownMenuItem(value: 'de', child: Text(l10n.langDe)),
                      DropdownMenuItem(value: 'fr', child: Text(l10n.langFr)),
                      DropdownMenuItem(value: 'it', child: Text(l10n.langIt)),
                      DropdownMenuItem(value: 'pt', child: Text(l10n.langPt)),
                    ],
                    onChanged: notifier.setLanguageCode,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Scanner Preferences Section
            Text(
              l10n.scannerPreferences,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 12),

            SettingRow(
              title: l10n.defaultCamera,
              trailing: SegmentButtonGroup<AppCameraFacing>(
                selectedValue: settings.defaultCameraFacing,
                items: [
                  SegmentItem(
                    value: AppCameraFacing.back,
                    label: l10n.cameraBack,
                  ),
                  SegmentItem(
                    value: AppCameraFacing.front,
                    label: l10n.cameraFront,
                  ),
                ],
                onSelected: notifier.setDefaultCameraFacing,
              ),
            ),

            SettingRow(
              title: l10n.defaultScanMode,
              trailing: SegmentButtonGroup<ScanMode>(
                selectedValue: settings.defaultScanMode,
                items: [
                  SegmentItem(value: ScanMode.qr, label: l10n.scanModeQr),
                  SegmentItem(
                    value: ScanMode.crypto,
                    label: l10n.scanModeCrypto,
                  ),
                ],
                onSelected: notifier.setDefaultScanMode,
              ),
            ),

            SettingRow(
              title: l10n.hapticsOnScan,
              subtitle: l10n.hapticsSubtitle,
              trailing: Switch.adaptive(
                value: settings.hapticsEnabled,
                onChanged: notifier.setHapticsEnabled,
                activeTrackColor: AppColors.primary,
              ),
            ),

            SettingRow(
              title: l10n.autoOpenSafeLinks,
              subtitle: l10n.autoOpenSubtitle,
              trailing: Switch.adaptive(
                value: settings.autoOpenSafeLinks,
                onChanged: notifier.setAutoOpenSafeLinks,
                activeTrackColor: AppColors.primary,
              ),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
