import 'package:flutter/material.dart';

import '../models/wordie_game.dart';
import '../theme/wordie_theme.dart';
import '../widgets/game_card.dart';
import '../widgets/mesh_background.dart';

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
      body: Stack(
        children: [
          const Positioned.fill(child: MeshBackground()),
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  pinned: true,
                  toolbarHeight: 78,
                  backgroundColor: WordieTheme.background.withValues(
                    alpha: 0.86,
                  ),
                  surfaceTintColor: Colors.transparent,
                  titleSpacing: 24,
                  title: Row(
                    children: [
                      RichText(
                        text: TextSpan(
                          style: textTheme.headlineMedium?.copyWith(
                            fontSize: 28,
                          ),
                          children: const [
                            TextSpan(text: 'wordie'),
                            TextSpan(
                              text: '.',
                              style: TextStyle(color: WordieTheme.brandGreen),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: WordieTheme.border),
                        ),
                        child: Text(
                          '🔥 $streakDays days',
                          style: textTheme.labelLarge,
                        ),
                      ),
                    ],
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 18, 24, 18),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Today\'s Games',
                          style: textTheme.displaySmall?.copyWith(fontSize: 38),
                        ),
                        const SizedBox(height: 8),
                        Text(date, style: textTheme.bodyLarge),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.04),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.06),
                            ),
                          ),
                          child: Text(
                            'Ten beloved word games, one editorial home. Daily ritual up top, replayable favorites below.',
                            style: textTheme.bodyLarge?.copyWith(
                              color: WordieTheme.textPrimary.withValues(
                                alpha: 0.88,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverToBoxAdapter(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isSingleColumn = constraints.maxWidth < 720;
                        if (isSingleColumn) {
                          return Column(
                            children: featuredGames
                                .map(
                                  (game) => Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: SizedBox(
                                      height: 260,
                                      child: FeaturedGameCard(
                                        game: game,
                                        onTap: () =>
                                            onGameSelected(context, game),
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
                                  height: 280,
                                  child: FeaturedGameCard(
                                    game: featuredGames[i],
                                    onTap: () => onGameSelected(
                                      context,
                                      featuredGames[i],
                                    ),
                                  ),
                                ),
                              ),
                              if (i < featuredGames.length - 1)
                                const SizedBox(width: 16),
                            ],
                          ],
                        );
                      },
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final game = standardGames[index];
                      return CompactGameCard(
                        game: game,
                        onTap: () => onGameSelected(context, game),
                      );
                    }, childCount: standardGames.length),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 260,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 0.86,
                        ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
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
        ],
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
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(26),
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
