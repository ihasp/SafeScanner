import 'package:crypto_scanner/modules/settings/providers/settings_notifier.dart';
import 'package:crypto_scanner/modules/settings/services/settings_service.dart';
import 'package:crypto_scanner/routing/tab_scaffold.dart';
import 'package:crypto_scanner/shared/widgets/glass_tab_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('TabScaffold & GlassTabBar UI Tests', () {
    testWidgets('Renders 4 items in bottom frosted glass menu in exact order', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          settingsServiceProvider.overrideWithValue(SettingsService(prefs)),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: TabScaffold()),
        ),
      );
      await tester.pump();

      // Verify all 4 tabs exist in frosted glass menu
      expect(find.text('Scan'), findsOneWidget);
      expect(find.text('Gallery'), findsOneWidget);
      expect(find.text('Results'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);

      expect(find.byIcon(Icons.qr_code_scanner_rounded), findsOneWidget);
      expect(find.byIcon(Icons.photo_library_outlined), findsOneWidget);
      expect(find.byIcon(Icons.format_list_bulleted_rounded), findsOneWidget);
      expect(find.byIcon(Icons.settings_outlined), findsOneWidget);

      // Tap on Gallery (2nd item) -> switches to GalleryPage (tab index 1)
      await tester.tap(find.text('Gallery'));
      await tester.pump();

      expect(container.read(selectedTabIndexProvider), equals(1));
    });

    testWidgets('GlassTabBar animates sliding indicator when tab selection changes', (
      tester,
    ) async {
      int selectedTab = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                body: Stack(
                  children: [
                    GlassTabBar(
                      selectedIndex: selectedTab,
                      onTabSelected: (index) {
                        setState(() => selectedTab = index);
                      },
                      items: const [
                        TabBarItem(icon: Icons.qr_code, label: 'Scan'),
                        TabBarItem(icon: Icons.photo, label: 'Gallery'),
                        TabBarItem(icon: Icons.list, label: 'Results'),
                        TabBarItem(icon: Icons.settings, label: 'Settings'),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      final animatedPositionedFinder = find.byType(AnimatedPositioned);
      expect(animatedPositionedFinder, findsOneWidget);

      AnimatedPositioned positioned = tester.widget(animatedPositionedFinder);
      expect(positioned.left, equals(0.0));

      // Tap on the 3rd tab (Results, index 2)
      await tester.tap(find.text('Results'));
      await tester.pump(); // Start animation

      // Pump mid-animation frame
      await tester.pump(const Duration(milliseconds: 100));

      // Settle animation to completion
      await tester.pumpAndSettle();

      positioned = tester.widget(animatedPositionedFinder);
      expect(positioned.left, isPositive);
    });
  });
}

