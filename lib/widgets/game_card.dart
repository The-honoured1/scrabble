import 'package:flutter/material.dart';
import '../models/game_model.dart';
import '../theme/app_theme.dart';

class GameCard extends StatelessWidget {
  final GameModel game;
  final VoidCallback onTap;

  const GameCard({super.key, required this.game, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.border),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28,
                height: 3,
                decoration: BoxDecoration(
                  color: game.accentColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              Text(game.emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(height: 12),
              Text(game.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 13, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(game.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11, height: 1.4)),
            ],
          ),
        ),
      ),
    );
  }
}
