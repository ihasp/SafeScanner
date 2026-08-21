import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/l10n.dart';
import '../modules/gallery/views/gallery_page.dart';
import '../modules/results/views/results_page.dart';
import '../modules/scanner/views/scanner_page.dart';
import '../modules/settings/views/settings_page.dart';
import '../shared/widgets/glass_tab_bar.dart';

class TabScaffold extends ConsumerWidget {
  const TabScaffold({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedTabIndexProvider);
    final l10n = context.l10n;

    final tabItems = [
      TabBarItem(icon: Icons.qr_code_scanner_rounded, label: l10n.navScan),
      TabBarItem(icon: Icons.photo_library_outlined, label: l10n.navGallery),
      TabBarItem(
        icon: Icons.format_list_bulleted_rounded,
        label: l10n.navResults,
      ),
      TabBarItem(icon: Icons.settings_outlined, label: l10n.navSettings),
    ];

    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: selectedIndex,
            children: const [
              ScannerPage(),
              GalleryPage(),
              ResultsPage(),
              SettingsPage(),
            ],
          ),
          GlassTabBar(
            selectedIndex: selectedIndex,
            onTabSelected: (index) {
              ref.read(selectedTabIndexProvider.notifier).setIndex(index);
            },
            items: tabItems,
          ),
        ],
      ),
    );
  }
}

class SelectedTabIndexNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setIndex(int index) => state = index;
}

final selectedTabIndexProvider =
    NotifierProvider<SelectedTabIndexNotifier, int>(
      SelectedTabIndexNotifier.new,
    );
