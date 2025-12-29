import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod

import 'package:flutter_application_1/main.dart'; // Corrected import based on project name

void main() {
  testWidgets('App title is displayed', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // Wrap MyApp with ProviderScope
    await tester.pumpWidget(const ProviderScope(child: MyApp()));

    // Verify that the app title is displayed.
    expect(find.text('한국 문학'), findsOneWidget);
  });
}
