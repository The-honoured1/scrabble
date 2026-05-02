import 'package:flutter_test/flutter_test.dart';

import 'package:wordie/app/wordie_app.dart';

void main() {
  testWidgets('renders the Wordie home hub', (WidgetTester tester) async {
    await tester.pumpWidget(const WordieApp());
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('Today\'s Games'), findsOneWidget);
    expect(find.textContaining('days'), findsOneWidget);
    expect(find.text('Wordle'), findsOneWidget);
    expect(find.text('Connections'), findsOneWidget);
    expect(find.textContaining('Ten beloved word games'), findsOneWidget);
  });
}
