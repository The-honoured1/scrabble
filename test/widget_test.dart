import 'package:flutter_test/flutter_test.dart';

import 'package:wordie/app/wordie_app.dart';

void main() {
  testWidgets('renders the Wordie home hub', (WidgetTester tester) async {
    await tester.pumpWidget(const WordieApp());
    await tester.pumpAndSettle();

    expect(find.text('Today\'s Games'), findsOneWidget);
    expect(find.text('wordie'), findsOneWidget);
    expect(find.text('Wordle'), findsOneWidget);
    expect(find.text('Connections'), findsOneWidget);
    expect(find.text('Completed today'), findsOneWidget);
  });
}
