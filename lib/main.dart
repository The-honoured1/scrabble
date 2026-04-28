import 'package:flutter/material.dart';
import 'package:scrabble/core/theme.dart';
import 'package:scrabble/presentation/screens/splash_screen.dart';

import 'package:scrabble/services/dictionary_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DictionaryService().loadDictionary();
  runApp(const ScrabbleApp());
}

class ScrabbleApp extends StatelessWidget {
  const ScrabbleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scrabble Dynamic',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}
