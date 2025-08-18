
import 'package:flutter_test/flutter_test.dart';

import 'package:z_parking/main.dart';
import 'package:z_parking/core/locator.dart';

void main() {
  testWidgets('App builds smoke test', (WidgetTester tester) async {
    await setupLocator();
    await tester.pumpWidget(const MyApp());
    expect(find.text('Login'), findsOneWidget);
  });
}
