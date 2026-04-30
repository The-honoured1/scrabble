import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/game_model.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/bottom_stats_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final featured = allGames.where((game) => game.featured).toList();
    final todayLabel = _formatDate(DateTime.now());

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth >= 900 ? 40.0 : 20.0;

            return ListView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                24,
                horizontalPadding,
                132,
              ),
              children: [
                _HomeHeader(
                  streak: appState.streak,
                  completedToday: appState.todayCompleted,
                  todayLabel: todayLabel,
                ),
                const SizedBox(height: 24),
                _HeroShowcase(
                  games: allGames,
                  todayLabel: todayLabel,
                  streak: appState.streak,
                  completedToday: appState.todayCompleted,
                ),
                const SizedBox(height: 32),
                _SectionHeading(
                  eyebrow: 'FEATURED',
                  title: 'Editors\' picks',
                  subtitle:
                      'A few strong starts if you want the closest thing to the NYT front page vibe.',
                ),
                const SizedBox(height: 16),
                for (var i = 0; i < featured.length; i++) ...[
                  _FeaturedEditorialCard(
                    game: featured[i],
                    isCompleted: appState.isCompleted(featured[i].id),
                    onTap: () => context.push(featured[i].route),
                  ),
                  if (i < featured.length - 1) const SizedBox(height: 12),
                ],
                const SizedBox(height: 32),
                _SectionHeading(
                  eyebrow: 'ALL GAMES',
                  title: 'Everything in one place',
                  subtitle:
                      'Every puzzle is available here, so you do not have to hunt through separate screens.',
                ),
                const SizedBox(height: 16),
                for (var i = 0; i < allGames.length; i++) ...[
                  _LibraryGameCard(
                    game: allGames[i],
                    isCompleted: appState.isCompleted(allGames[i].id),
                    onTap: () => context.push(allGames[i].route),
                  ),
                  if (i < allGames.length - 1) const SizedBox(height: 12),
                ],
              ],
            );
          },
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

class _HomeHeader extends StatelessWidget {
  final int streak;
  final int completedToday;
  final String todayLabel;

  const _HomeHeader({
    required this.streak,
    required this.completedToday,
    required this.todayLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'wordie.',
          style: Theme.of(
            context,
          ).textTheme.displayLarge?.copyWith(fontSize: 42),
        ),
        const SizedBox(height: 8),
        Text(
          'Daily word games with a cleaner, newspaper-inspired home.',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _InfoPill(label: todayLabel, icon: Icons.calendar_today_outlined),
            _InfoPill(
              label: '$streak day streak',
              icon: Icons.local_fire_department_outlined,
              tint: AppTheme.green,
            ),
            _InfoPill(
              label: '$completedToday finished today',
              icon: Icons.check_circle_outline,
            ),
          ],
        ),
      ],
    );
  }
}

class _HeroShowcase extends StatelessWidget {
  final List<GameModel> games;
  final String todayLabel;
  final int streak;
  final int completedToday;

  const _HeroShowcase({
    required this.games,
    required this.todayLabel,
    required this.streak,
    required this.completedToday,
  });

  @override
  Widget build(BuildContext context) {
    final split = (games.length / 2).ceil();

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppTheme.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: games
                  .take(split)
                  .map((game) => _HeroGameBadge(game: game))
                  .toList(),
            ),
            const SizedBox(height: 24),
            Text(
              'WORDIE GAMES',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.8,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Find your next\nword fix.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontSize: 48,
                height: 0.96,
                fontWeight: FontWeight.w900,
                letterSpacing: -1.5,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Featured favorites up top, the full archive below, and enough variety to keep the blank screen feeling gone for good.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.textSecondary,
                height: 1.55,
              ),
            ),
            const SizedBox(height: 18),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              runSpacing: 10,
              children: [
                _HighlightChip(label: todayLabel),
                _HighlightChip(label: '$streak streak'),
                _HighlightChip(label: '${games.length} games live'),
                _HighlightChip(label: '$completedToday solved today'),
              ],
            ),
            const SizedBox(height: 24),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: games
                  .skip(split)
                  .map((game) => _HeroGameBadge(game: game))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String subtitle;

  const _SectionHeading({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppTheme.textMuted,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.8,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontSize: 32,
            letterSpacing: -0.8,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppTheme.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _FeaturedEditorialCard extends StatelessWidget {
  final GameModel game;
  final bool isCompleted;
  final VoidCallback onTap;

  const _FeaturedEditorialCard({
    required this.game,
    required this.isCompleted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppTheme.border),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final stacked = constraints.maxWidth < 560;

              final textColumn = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _TagPill(label: game.tag, tint: game.accentColor),
                      if (isCompleted)
                        _TagPill(label: 'DONE TODAY', tint: AppTheme.green),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    game.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    game.description,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textSecondary,
                      height: 1.55,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isCompleted ? 'Play again' : 'Play now',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward, size: 18),
                    ],
                  ),
                ],
              );

              final artwork = Container(
                width: stacked ? double.infinity : 110,
                height: stacked ? 100 : 110,
                decoration: BoxDecoration(
                  color: game.accentColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Center(
                  child: Text(game.emoji, style: const TextStyle(fontSize: 48)),
                ),
              );

              return Padding(
                padding: const EdgeInsets.all(20),
                child: stacked
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          artwork,
                          const SizedBox(height: 18),
                          textColumn,
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(child: textColumn),
                          const SizedBox(width: 20),
                          artwork,
                        ],
                      ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _LibraryGameCard extends StatelessWidget {
  final GameModel game;
  final bool isCompleted;
  final VoidCallback onTap;

  const _LibraryGameCard({
    required this.game,
    required this.isCompleted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.border),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: game.accentColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(game.emoji, style: const TextStyle(fontSize: 34)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          game.title,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        _TagPill(label: game.tag, tint: game.accentColor),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      game.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      isCompleted ? 'Completed today' : 'Open puzzle',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: isCompleted
                            ? AppTheme.green
                            : AppTheme.textMuted,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Icon(
                Icons.arrow_forward,
                color: isCompleted ? AppTheme.green : AppTheme.textPrimary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroGameBadge extends StatelessWidget {
  final GameModel game;

  const _HeroGameBadge({required this.game});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: game.accentColor.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(game.emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 8),
          Text(
            game.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _HighlightChip extends StatelessWidget {
  final String label;

  const _HighlightChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppTheme.border),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppTheme.textPrimary,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color? tint;

  const _InfoPill({required this.label, required this.icon, this.tint});

  @override
  Widget build(BuildContext context) {
    final color = tint ?? AppTheme.textPrimary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _TagPill extends StatelessWidget {
  final String label;
  final Color tint;

  const _TagPill({required this.label, required this.tint});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: tint,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}

String _formatDate(DateTime date) {
  const weekdays = [
    'MONDAY',
    'TUESDAY',
    'WEDNESDAY',
    'THURSDAY',
    'FRIDAY',
    'SATURDAY',
    'SUNDAY',
  ];
  const months = [
    'JANUARY',
    'FEBRUARY',
    'MARCH',
    'APRIL',
    'MAY',
    'JUNE',
    'JULY',
    'AUGUST',
    'SEPTEMBER',
    'OCTOBER',
    'NOVEMBER',
    'DECEMBER',
  ];

  return '${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
}
