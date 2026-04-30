import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'games/wordle_screen.dart';
import 'games/connections_screen.dart';
import 'games/spelling_bee_screen.dart';
import 'games/crossword_screen.dart';
import 'games/word_search_screen.dart';
import 'games/hangman_screen.dart';
import 'games/boggle_screen.dart';
import 'games/word_ladder_screen.dart';
import 'games/type_racer_screen.dart';
import 'games/anagram_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const WordieApp());
}

class WordieApp extends StatelessWidget {
  const WordieApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const HomeScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        ),
        GoRoute(path: '/wordle', pageBuilder: _buildPage(const WordleScreen())),
        GoRoute(path: '/connections', pageBuilder: _buildPage(const ConnectionsScreen())),
        GoRoute(path: '/spelling-bee', pageBuilder: _buildPage(const SpellingBeeScreen())),
        GoRoute(path: '/crossword', pageBuilder: _buildPage(const CrosswordScreen())),
        GoRoute(path: '/word-search', pageBuilder: _buildPage(const WordSearchScreen())),
        GoRoute(path: '/hangman', pageBuilder: _buildPage(const HangmanScreen())),
        GoRoute(path: '/boggle', pageBuilder: _buildPage(const BoggleScreen())),
        GoRoute(path: '/word-ladder', pageBuilder: _buildPage(const WordLadderScreen())),
        GoRoute(path: '/type-racer', pageBuilder: _buildPage(const TypeRacerScreen())),
        GoRoute(path: '/anagram', pageBuilder: _buildPage(const AnagramScreen())),
      ],
    );

    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: MaterialApp.router(
        title: 'Wordie',
        routerConfig: router,
        theme: AppTheme.themeData(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

PageBuilder _buildPage(Widget child) {
  return (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: child,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween(begin: const Offset(0, 0.08), end: Offset.zero).animate(animation),
              child: child,
            ),
          );
        },
      );
}
