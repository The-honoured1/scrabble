import 'package:flutter/material.dart';

import '../data/game_catalog.dart';
import '../screens/game_screen.dart';
import '../screens/home_screen.dart';
import '../theme/wordie_theme.dart';

class WordieApp extends StatelessWidget {
  const WordieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'wordie.',
      debugShowCheckedModeBanner: false,
      theme: WordieTheme.theme,
      home: HomeScreen(
        games: wordieGames,
        streakDays: 5,
        completedToday: 3,
        onGameSelected: (context, game) => Navigator.of(context).push(
          _fadeRoute(GameScreen(game: game, totalGames: wordieGames.length)),
        ),
      ),
    );
  }

  Route<void> _fadeRoute(Widget child) {
    return PageRouteBuilder<void>(
      transitionDuration: const Duration(milliseconds: 200),
      reverseTransitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );

        return FadeTransition(opacity: curved, child: child);
      },
    );
  }
}
