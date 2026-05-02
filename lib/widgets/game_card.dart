import 'package:flutter/material.dart';

import '../models/wordie_game.dart';
import '../theme/wordie_theme.dart';
import 'pressable_scale.dart';

class FeaturedGameCard extends StatelessWidget {
  const FeaturedGameCard({
    required this.game,
    required this.onTap,
    super.key,
  });

  final WordieGame game;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return PressableScale(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: WordieTheme.card.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: WordieTheme.border),
          boxShadow: [
            BoxShadow(
              color: game.color.withValues(alpha: 0.16),
              blurRadius: 28,
              spreadRadius: -12,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _AccentBar(color: game.color),
              const SizedBox(height: 18),
              Row(
                children: [
                  Text(
                    game.emoji,
                    style: const TextStyle(fontSize: 28),
                  ),
                  const Spacer(),
                  _ModePill(game: game),
                ],
              ),
              const SizedBox(height: 16),
              Text(game.title, style: textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(game.description, style: textTheme.bodyMedium),
              const Spacer(),
              Row(
                children: [
                  Text(
                    '${game.playLabel} →',
                    style: textTheme.labelLarge?.copyWith(color: game.color),
                  ),
                  const Spacer(),
                  if (game.isCompletedToday && game.resultLabel != null)
                    _ResultChip(label: game.resultLabel!),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CompactGameCard extends StatelessWidget {
  const CompactGameCard({
    required this.game,
    required this.onTap,
    super.key,
  });

  final WordieGame game;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return PressableScale(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: WordieTheme.card.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: WordieTheme.border),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _AccentBar(color: game.color),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(game.emoji, style: const TextStyle(fontSize: 24)),
                  const Spacer(),
                  if (game.isCompletedToday)
                    Icon(
                      Icons.check_circle_rounded,
                      color: game.color,
                      size: 20,
                    ),
                ],
              ),
              const SizedBox(height: 14),
              Text(game.title, style: textTheme.titleLarge),
              const SizedBox(height: 6),
              Text(
                game.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodyMedium,
              ),
              const Spacer(),
              Text(
                game.modeLabel,
                style: textTheme.labelMedium?.copyWith(color: game.color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccentBar extends StatelessWidget {
  const _AccentBar({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(999)),
      child: Container(
        height: 3,
        color: color,
      ),
    );
  }
}

class _ModePill extends StatelessWidget {
  const _ModePill({required this.game});

  final WordieGame game;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: game.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: game.color.withValues(alpha: 0.35)),
      ),
      child: Text(
        game.mode == WordieMode.daily ? 'Daily' : 'Unlimited',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: game.color,
            ),
      ),
    );
  }
}

class _ResultChip extends StatelessWidget {
  const _ResultChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: WordieTheme.textPrimary,
            ),
      ),
    );
  }
}
