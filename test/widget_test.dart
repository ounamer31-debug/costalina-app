import 'package:flutter_test/flutter_test.dart';

import 'package:costalina_app/main.dart';

void main() {
  testWidgets('App boots', (WidgetTester tester) async {
    await tester.pumpWidget(const CostalinaApp());
    expect(find.byType(CostalinaApp), findsOneWidget);
  });
}
