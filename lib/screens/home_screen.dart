import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/game_model.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';
import '../widgets/bottom_stats_bar.dart';
import '../widgets/featured_game_card.dart';
import '../widgets/game_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final featured = allGames.where((game) => game.featured).toList();
    final moreGames = allGames.where((game) => !game.featured).toList();

    return Scaffold(
      body: Column(
        children: [
          AppHeader(streakDays: appState.streak),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppTheme.border, width: 1)),
              color: AppTheme.background,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Today\'s\nGames', style: Theme.of(context).textTheme.displayLarge),
                      const SizedBox(height: 14),
                      Text('New puzzles reset at midnight', style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('THURSDAY, APRIL 30', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.green, fontWeight: FontWeight.w700, letterSpacing: 0.7)),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('FEATURED', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.textMuted, letterSpacing: 2)),
                  const SizedBox(height: 14),
                  Row(
                    children: featured
                        .map(
                          (game) => Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: FeaturedGameCard(
                                game: game,
                                onTap: () => context.push(game.route),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 28),
                  Text('MORE GAMES', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.textMuted, letterSpacing: 2)),
                  const SizedBox(height: 10),
                  GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 1.15,
                    children: moreGames
                        .map((game) => GameCard(
                              game: game,
                              onTap: () => context.push(game.route),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomStatsBar(
        games: allGames.length,
        streak: appState.streak,
        today: appState.todayCompleted,
      ),
    );
  }
}
