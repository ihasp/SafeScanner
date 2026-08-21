import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constants/app_colors.dart';
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
                'Settings',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Scanner Preferences Section
            Text(
              'Scanner Preferences',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 12),

            SettingRow(
              title: 'Default Camera',
              trailing: SegmentButtonGroup<AppCameraFacing>(
                selectedValue: settings.defaultCameraFacing,
                items: const [
                  SegmentItem(value: AppCameraFacing.back, label: 'Back'),
                  SegmentItem(value: AppCameraFacing.front, label: 'Front'),
                ],
                onSelected: notifier.setDefaultCameraFacing,
              ),
            ),

            SettingRow(
              title: 'Default Scan Mode',
              trailing: SegmentButtonGroup<ScanMode>(
                selectedValue: settings.defaultScanMode,
                items: const [
                  SegmentItem(value: ScanMode.qr, label: 'QR'),
                  SegmentItem(value: ScanMode.crypto, label: 'Crypto'),
                ],
                onSelected: notifier.setDefaultScanMode,
              ),
            ),

            SettingRow(
              title: 'Haptics on Scan',
              subtitle: 'Vibrate on success/error',
              trailing: Switch.adaptive(
                value: settings.hapticsEnabled,
                onChanged: notifier.setHapticsEnabled,
                activeTrackColor: AppColors.primary,
              ),
            ),

            SettingRow(
              title: 'Auto-Open Safe Links',
              subtitle: 'Open browser if 0 flags',
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
