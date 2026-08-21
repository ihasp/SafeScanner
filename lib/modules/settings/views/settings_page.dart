import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constants/app_colors.dart';
import '../../../shared/models/scan_mode.dart';
import '../../results/providers/scan_results_notifier.dart';
import '../models/app_settings.dart';
import '../providers/settings_notifier.dart';
import '../ui/segment_button_group.dart';
import '../ui/setting_row.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  Future<void> _confirmClearHistory(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Scan History?'),
        content: const Text(
          'This will permanently delete all saved scan results from this device. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.malicious),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      ref.read(scanResultsProvider.notifier).clearScans();
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Scan history cleared.')));
      }
    }
  }

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

            SettingRow(
              title: 'Polling Interval',
              subtitle: 'API check rate',
              trailing: SegmentButtonGroup<int>(
                selectedValue: settings.apiPollingRate,
                items: const [
                  SegmentItem(value: 500, label: '0.5s'),
                  SegmentItem(value: 1000, label: '1s'),
                  SegmentItem(value: 3000, label: '3s'),
                ],
                onSelected: notifier.setApiPollingRate,
              ),
            ),

            const SizedBox(height: 32),

            // Privacy & History Section
            Text(
              'Privacy & History',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 12),

            SettingRow(
              title: 'Incognito Mode',
              subtitle: 'Do not save scans to history',
              trailing: Switch.adaptive(
                value: settings.incognitoMode,
                onChanged: notifier.setIncognitoMode,
                activeTrackColor: AppColors.primary,
              ),
            ),

            SettingRow(
              title: 'History Size',
              subtitle: 'Max saved scans',
              trailing: SegmentButtonGroup<int>(
                selectedValue: settings.historySizeLimit,
                items: const [
                  SegmentItem(value: 5, label: '5'),
                  SegmentItem(value: 10, label: '10'),
                  SegmentItem(value: 20, label: '20'),
                ],
                onSelected: notifier.setHistorySizeLimit,
              ),
            ),

            SettingRow(
              title: 'Clear Scan History',
              subtitle: 'Permanently remove all saved results',
              trailing: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.malicious,
                  side: const BorderSide(color: AppColors.malicious),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                onPressed: () => _confirmClearHistory(context, ref),
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                label: const Text(
                  'Remove All',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
