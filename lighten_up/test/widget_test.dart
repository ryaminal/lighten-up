// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lighten_up/main.dart';

void main() {
  testWidgets('App loads and shows login screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: MyApp()));

    // Wait for the first frame
    await tester.pump();

    // Wait a bit more for async operations
    await tester.pump(const Duration(seconds: 1));

    // Verify that the login screen elements are present
    expect(find.text('Lighten Up'), findsWidgets);
    expect(find.text('Medical Office Communication'), findsOneWidget);
  });
}
