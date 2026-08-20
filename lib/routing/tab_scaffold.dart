import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../modules/home/views/home_page.dart';
import '../modules/results/views/results_page.dart';
import '../modules/settings/views/settings_page.dart';
import '../shared/widgets/glass_tab_bar.dart';

class TabScaffold extends ConsumerWidget {
  const TabScaffold({super.key});

  static const List<TabBarItem> _tabItems = [
    TabBarItem(icon: Icons.qr_code_scanner_rounded, label: 'Scan'),
    TabBarItem(icon: Icons.format_list_bulleted_rounded, label: 'Results'),
    TabBarItem(icon: Icons.settings_outlined, label: 'Settings'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedTabIndexProvider);

    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: selectedIndex,
            children: const [HomePage(), ResultsPage(), SettingsPage()],
          ),
          GlassTabBar(
            selectedIndex: selectedIndex,
            onTabSelected: (index) {
              ref.read(selectedTabIndexProvider.notifier).setIndex(index);
            },
            items: _tabItems,
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
