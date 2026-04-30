import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class BottomStatsBar extends StatelessWidget {
  final int games;
  final int streak;
  final int today;

  const BottomStatsBar({super.key, required this.games, required this.streak, required this.today});

  Widget _buildStat(BuildContext context, String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 20, fontWeight: FontWeight.w900)),
        const SizedBox(height: 4),
        Text(label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.textMuted, fontSize: 10)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(top: BorderSide(color: AppTheme.border, width: 1)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          _buildStat(context, '$games', 'GAMES'),
          Container(width: 1, height: 24, margin: const EdgeInsets.symmetric(horizontal: 16), color: AppTheme.border),
          _buildStat(context, '$streak', 'STREAK'),
          Container(width: 1, height: 24, margin: const EdgeInsets.symmetric(horizontal: 16), color: AppTheme.border),
          _buildStat(context, '$today', 'TODAY'),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Made with ♥ · Wordie 2026',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.textMuted),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
