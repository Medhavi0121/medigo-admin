import 'package:flutter_test/flutter_test.dart';
import 'package:medigo_admin/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // Note: MedigoAdminApp initializes Firebase and other services in initState.
    // For this test to pass in a real environment, you'd typically mock these services.
    await tester.pumpWidget(const MedigoAdminApp());

    // Basic verification that the app widget is created.
    expect(find.byType(MedigoAdminApp), findsOneWidget);
  });
}
