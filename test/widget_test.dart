// Basic Flutter widget test for GastosController.

import 'package:flutter_test/flutter_test.dart';
import 'package:gastoscontroller/main.dart';

void main() {
  testWidgets('App basic smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the app launches and does not crash.
    expect(find.byType(MyApp), findsOneWidget);
  });
}
