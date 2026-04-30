import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/game_model.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
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
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text('wordie.', style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 40)),
                  ),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 12,
                    runSpacing: 10,
                    children: [
                      TextButton(onPressed: () {}, child: const Text('Archive')),
                      TextButton(onPressed: () {}, child: const Text('Leaderboard')),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppTheme.green.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(32),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.local_fire_department, size: 16, color: AppTheme.green),
                            const SizedBox(width: 8),
                            Text('${appState.streak} day streak', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.green, fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Games', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 38, letterSpacing: -1)),
                        const SizedBox(height: 10),
                        Text('New puzzles reset at midnight', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.textSecondary, fontWeight: FontWeight.w400)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.green.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text('THURSDAY, APRIL 30', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.green, fontWeight: FontWeight.w700, letterSpacing: 0.7)),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Text('FEATURED', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.textMuted, letterSpacing: 2)),
              const SizedBox(height: 18),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: featured
                    .map(
                      (game) => Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: FeaturedGameCard(
                            game: game,
                            onTap: () => context.push(game.route),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 32),
              Text('MORE GAMES', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.textMuted, letterSpacing: 2)),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.1,
                children: moreGames
                    .map(
                      (game) => GameCard(
                        game: game,
                        onTap: () => context.push(game.route),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomStatsBar(
        games: allGames.length,
        streak: appState.streak,
        today: appState.todayCompleted,
      ),
    );
  }
}
