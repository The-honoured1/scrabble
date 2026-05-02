import 'package:flutter/material.dart';

import '../models/wordie_game.dart';
import '../theme/wordie_theme.dart';
import '../widgets/game_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    required this.games,
    required this.streakDays,
    required this.completedToday,
    required this.onGameSelected,
    super.key,
  });

  final List<WordieGame> games;
  final int streakDays;
  final int completedToday;
  final void Function(BuildContext context, WordieGame game) onGameSelected;

  @override
  Widget build(BuildContext context) {
    final featuredGames = games.where((game) => game.isFeatured).toList();
    final standardGames = games.where((game) => !game.isFeatured).toList();
    final textTheme = Theme.of(context).textTheme;
    final date = _formatDate(DateTime.now());

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              sliver: SliverToBoxAdapter(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final stackedHeader = constraints.maxWidth < 340;
                    return Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: WordieTheme.cardAlt,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: WordieTheme.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (stackedHeader)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RichText(
                                  text: TextSpan(
                                    style: textTheme.headlineMedium,
                                    children: const [
                                      TextSpan(text: 'wordie'),
                                      TextSpan(
                                        text: '.',
                                        style: TextStyle(
                                          color: WordieTheme.brandGreen,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _StreakChip(
                                  streakDays: streakDays,
                                  textTheme: textTheme,
                                ),
                              ],
                            )
                          else
                            Row(
                              children: [
                                RichText(
                                  text: TextSpan(
                                    style: textTheme.headlineMedium,
                                    children: const [
                                      TextSpan(text: 'wordie'),
                                      TextSpan(
                                        text: '.',
                                        style: TextStyle(
                                          color: WordieTheme.brandGreen,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Spacer(),
                                _StreakChip(
                                  streakDays: streakDays,
                                  textTheme: textTheme,
                                ),
                              ],
                            ),
                          const SizedBox(height: 18),
                          Text('Today\'s Games', style: textTheme.displaySmall),
                          const SizedBox(height: 6),
                          Text(date, style: textTheme.bodyMedium),
                          const SizedBox(height: 8),
                          Text(
                            'Tap a game and play.',
                            style: textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              sliver: SliverToBoxAdapter(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final stacked = constraints.maxWidth < 760;
                    if (stacked) {
                      return Column(
                        children: featuredGames
                            .map(
                              (game) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: SizedBox(
                                  height: 150,
                                  child: FeaturedGameCard(
                                    game: game,
                                    onTap: () => onGameSelected(context, game),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      );
                    }

                    return Row(
                      children: [
                        for (var i = 0; i < featuredGames.length; i++) ...[
                          Expanded(
                            child: SizedBox(
                              height: 150,
                              child: FeaturedGameCard(
                                game: featuredGames[i],
                                onTap: () =>
                                    onGameSelected(context, featuredGames[i]),
                              ),
                            ),
                          ),
                          if (i < featuredGames.length - 1)
                            const SizedBox(width: 12),
                        ],
                      ],
                    );
                  },
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
              sliver: SliverToBoxAdapter(
                child: Text('More Games', style: textTheme.headlineSmall),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              sliver: SliverLayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.crossAxisExtent;
                  if (width <= 220) {
                    return SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final game = standardGames[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: SizedBox(
                            height: 120,
                            child: CompactGameCard(
                              game: game,
                              onTap: () => onGameSelected(context, game),
                            ),
                          ),
                        );
                      }, childCount: standardGames.length),
                    );
                  }

                  final crossAxisCount = (width / 220).floor().clamp(1, 4);
                  return SliverGrid(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final game = standardGames[index];
                      return CompactGameCard(
                        game: game,
                        onTap: () => onGameSelected(context, game),
                      );
                    }, childCount: standardGames.length),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: width < 320 ? 1.4 : 1.15,
                    ),
                  );
                },
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
              sliver: SliverToBoxAdapter(
                child: _StatsBar(
                  totalGames: games.length,
                  streakDays: streakDays,
                  completedToday: completedToday,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
  }
}

class _StatsBar extends StatelessWidget {
  const _StatsBar({
    required this.totalGames,
    required this.streakDays,
    required this.completedToday,
  });

  final int totalGames;
  final int streakDays;
  final int completedToday;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: WordieTheme.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: WordieTheme.border),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 440;
          final children = [
            _StatItem(label: 'Total games', value: '$totalGames'),
            _StatItem(label: 'Current streak', value: '$streakDays'),
            _StatItem(
              label: 'Completed today',
              value: '$completedToday/$totalGames',
            ),
          ];

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < children.length; i++) ...[
                  children[i],
                  if (i < children.length - 1) const SizedBox(height: 14),
                ],
              ],
            );
          }

          return Row(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                Expanded(child: children[i]),
                if (i < children.length - 1)
                  Container(
                    width: 1,
                    height: 44,
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _StreakChip extends StatelessWidget {
  const _StreakChip({required this.streakDays, required this.textTheme});

  final int streakDays;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: WordieTheme.brandGreen,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$streakDays day streak',
        style: textTheme.labelLarge?.copyWith(color: WordieTheme.background),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: textTheme.headlineSmall?.copyWith(fontSize: 24)),
        const SizedBox(height: 6),
        Text(label, style: textTheme.bodyMedium),
      ],
    );
  }
}
