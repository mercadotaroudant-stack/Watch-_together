import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watchtogether/app.dart';
import 'package:watchtogether/providers/storage_service_provider.dart';
import 'package:watchtogether/services/local_storage_service.dart';

Future<Widget> buildTestApp() async {
  SharedPreferences.setMockInitialValues({});
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return ProviderScope(
    overrides: [
      localStorageServiceProvider.overrideWithValue(LocalStorageService(prefs)),
    ],
    child: const WatchTogetherApp(),
  );
}

void main() {
  testWidgets(
    'App boots on the splash screen, then navigates to onboarding '
    'after its fixed delay',
    (tester) async {
      await tester.pumpWidget(await buildTestApp());

      // A single `pump()`, never `pumpAndSettle()` here: the splash
      // screen's CircularProgressIndicator animates indefinitely, so
      // pumpAndSettle would never converge and the test would time out.
      await tester.pump();

      expect(find.text('WatchTogether'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Advance exactly the splash screen's navigation delay (this also
      // fires its internal Timer), then let the route swap build.
      await tester.pump(const Duration(milliseconds: 2500));
      await tester.pump();

      // Landed on the onboarding screen: no more spinner, and its
      // entrance animations are all finite, so pumpAndSettle is safe now.
      expect(find.byType(CircularProgressIndicator), findsNothing);
      await tester.pumpAndSettle();

      expect(find.text('Watch Together'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);
    },
  );

  testWidgets('Onboarding: Next advances pages and the last page reads Get Started',
      (tester) async {
      await tester.pumpWidget(await buildTestApp());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 2500));
      await tester.pumpAndSettle();

      // Page 1 -> 2
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.text('Private & Secure'), findsOneWidget);
      expect(find.text('Back'), findsOneWidget);

      // Page 2 -> 3 (last page)
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.text('Chat & Enjoy'), findsOneWidget);
      expect(find.text('Get Started'), findsOneWidget);
    },
  );
}
