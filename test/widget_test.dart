import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:wordie/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('home screen shows the full game directory', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const WordieApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('wordie.'), findsOneWidget);
    expect(find.textContaining('Find your next'), findsOneWidget);
    expect(find.text('Everything in one place'), findsOneWidget);

    for (final title in const [
      'Wordle',
      'Connections',
      'Spelling Bee',
      'Mini Crossword',
      'Word Search',
      'Hangman',
      'Boggle',
      'Word Ladder',
      'Type Racer',
      'Anagram',
    ]) {
      expect(find.text(title), findsWidgets);
    }
  });
}
