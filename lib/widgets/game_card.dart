import 'package:flutter/material.dart';

import '../models/wordie_game.dart';
import '../theme/wordie_theme.dart';
import 'pressable_scale.dart';

class FeaturedGameCard extends StatelessWidget {
  const FeaturedGameCard({required this.game, required this.onTap, super.key});

  final WordieGame game;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return PressableScale(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: game.color.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: game.color.withValues(alpha: 0.7)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(game.emoji, style: const TextStyle(fontSize: 26)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(game.title, style: textTheme.headlineSmall),
                  ),
                  _ModePill(game: game),
                ],
              ),
              const Spacer(),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (game.isCompletedToday && game.resultLabel != null)
                    _ResultChip(label: game.resultLabel!),
                  Text(
                    game.playLabel,
                    style: textTheme.labelLarge?.copyWith(color: game.color),
                  ),
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
  const CompactGameCard({required this.game, required this.onTap, super.key});

  final WordieGame game;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return PressableScale(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: game.color.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: game.color.withValues(alpha: 0.5)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(game.emoji, style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(game.title, style: textTheme.titleLarge),
                  ),
                  if (game.isCompletedToday)
                    Icon(
                      Icons.check_circle_rounded,
                      color: game.color,
                      size: 20,
                    ),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    game.modeLabel,
                    style: textTheme.labelMedium?.copyWith(color: game.color),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    game.playLabel,
                    style: textTheme.labelLarge?.copyWith(color: game.color),
                  ),
                ],
              ),
            ],
          ),
        ),
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
        color: game.color.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        game.mode == WordieMode.daily ? 'Daily' : 'Unlimited',
        style: Theme.of(
          context,
        ).textTheme.labelMedium?.copyWith(color: game.color),
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
        color: Colors.black.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.labelMedium?.copyWith(color: WordieTheme.textPrimary),
      ),
    );
  }
}
