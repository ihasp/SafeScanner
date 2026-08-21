import 'package:crypto_scanner/modules/gallery/views/gallery_page.dart';
import 'package:crypto_scanner/modules/settings/providers/settings_notifier.dart';
import 'package:crypto_scanner/modules/settings/services/settings_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('GalleryPage UI Tests', () {
    testWidgets('Renders Gallery header with icon and title matching Settings style', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            settingsServiceProvider.overrideWithValue(SettingsService(prefs)),
          ],
          child: const MaterialApp(home: Scaffold(body: GalleryPage())),
        ),
      );
      await tester.pump();

      // Verify Gallery header
      expect(find.text('Gallery'), findsOneWidget);
      expect(find.byIcon(Icons.photo_library_outlined), findsWidgets);
    });
  });
}
