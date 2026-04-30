import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'streak_badge.dart';

class AppHeader extends StatelessWidget {
  final int streakDays;

  const AppHeader({super.key, required this.streakDays});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: const BoxDecoration(
        color: AppTheme.background,
        border: Border(bottom: BorderSide(color: AppTheme.border, width: 1)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          RichText(
            text: TextSpan(
              text: 'wordie',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 26, fontWeight: FontWeight.w900),
              children: [
                TextSpan(text: '.', style: TextStyle(color: AppTheme.green, fontSize: 26, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: () {},
            child: const Text('Archive'),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () {},
            child: const Text('Leaderboard'),
          ),
          const SizedBox(width: 12),
          StreakBadge(days: streakDays),
        ],
      ),
    );
  }
}
