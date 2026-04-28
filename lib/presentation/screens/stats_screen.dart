import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scrabble/core/theme.dart';
import 'package:scrabble/core/motion.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import 'package:scrabble/services/stats_service.dart';
import 'package:scrabble/services/history_service.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  Map<String, dynamic>? _stats;
  List<HistoryItem>? _history;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final s = await StatsService.getStats();
    final h = await HistoryService.getHistory();
    if (mounted) setState(() {
      _stats = s;
      _history = h;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: AnimationConfiguration.toStaggeredList(
              duration: const Duration(milliseconds: 600),
              childAnimationBuilder: (widget) => FadeInAnimation(
                child: SlideAnimation(
                  verticalOffset: 30,
                  child: widget,
                ),
              ),
              children: [
                const SizedBox(height: 20),
                Text(
                  'Your Stats',
                  style: GoogleFonts.frankRuhlLibre(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textBody,
                  ),
                ),
                const SizedBox(height: 32),
                
                // 2x2 Grid
                _stats == null 
                  ? const Center(child: CircularProgressIndicator())
                  : _StatsGrid(stats: _stats!),
                const SizedBox(height: 48),

                // Bar Chart
                const Text(
                  'SCORE DISTRIBUTION',
                  style: TextStyle(
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 24),
                _stats == null 
                    ? const SizedBox()
                    : _ScoreDistributionChart(distribution: _stats!['scoreDistribution']),
                const SizedBox(height: 48),

                // Calendar Grid
                const Text(
                  'COMPLETION CALENDAR',
                  style: TextStyle(
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 24),
                _history == null
                    ? const SizedBox()
                    : _CalendarGrid(history: _history!),
                
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final Map<String, dynamic> stats;
  const _StatsGrid({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          _StatItem(label: 'Games', value: stats['gamesPlayed'].toString()),
          const Divider(height: 32, color: Colors.black12),
          _StatItem(label: 'Wins', value: stats['wins'].toString()),
          const Divider(height: 32, color: Colors.black12),
          _StatItem(label: 'Avg Score', value: stats['avgScore'].toString()),
          const Divider(height: 32, color: Colors.black12),
          _StatItem(label: 'Best Word', value: stats['bestWord'].toString()),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.jetBrainsMono(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.textMuted,
            letterSpacing: 2,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.frankRuhlLibre(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: AppColors.textBody,
          ),
        ),
      ],
    );
  }
}

class _CountingNumber extends StatefulWidget {
  final int value;

  const _CountingNumber({required this.value});

  @override
  State<_CountingNumber> createState() => _CountingNumberState();
}

class _CountingNumberState extends State<_CountingNumber> with SingleTickerProviderStateMixin {
  late Animation<int> _animation;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animation = IntTween(begin: 0, end: widget.value).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutExpo),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Text(
          '${_animation.value}',
          style: GoogleFonts.jetBrainsMono(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: AppColors.primary,
          ),
        );
      },
    );
  }
}

class _ScoreDistributionChart extends StatelessWidget {
  const _ScoreDistributionChart({this.distribution});
  final List<dynamic>? distribution;

  @override
  Widget build(BuildContext context) {
    final List<int> values = List<int>.from(distribution ?? [0, 0, 0, 0, 0, 0]);
    final maxVal = values.isEmpty ? 1 : values.reduce((a, b) => a > b ? a : b);
    final labels = ['0-100', '101-200', '201-300', '301-400', '401-500', '500+'];

    return Column(
      children: List.generate(values.length, (index) {
        final ratio = maxVal == 0 ? 0.0 : values[index] / maxVal;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              SizedBox(
                width: 60,
                child: Text(
                  labels[index],
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 10,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _GrowBar(
                  value: ratio.clamp(0.05, 1.0), // Min width for visibility
                  isCurrent: false,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${values[index]}',
                style: GoogleFonts.jetBrainsMono(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _GrowBar extends StatelessWidget {
  final double value;
  final bool isCurrent;
  const _GrowBar({required this.value, required this.isCurrent});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 12,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(6),
      ),
      alignment: Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: value,
        child: Container(
class _GrowBar extends StatefulWidget {
  final double value;
  final bool isCurrent;

  const _GrowBar({required this.value, this.isCurrent = false});

  @override
  State<_GrowBar> createState() => _GrowBarState();
}

class _GrowBarState extends State<_GrowBar> with SingleTickerProviderStateMixin {
  late Animation<double> _animation;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animation = Tween<double>(begin: 0, end: widget.value).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          height: 12,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            color: Colors.black.withOpacity(0.05),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: _animation.value,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: widget.isCurrent ? AppColors.primary : AppColors.accent,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CalendarGrid extends StatelessWidget {
  final List<HistoryItem> history;
  const _CalendarGrid({required this.history});

  @override
  Widget build(BuildContext context) {
    // Generate last 28 days
    final now = DateTime.now();
    final days = List.generate(28, (i) => now.subtract(Duration(days: 27 - i)));

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: 28,
      itemBuilder: (context, index) {
        final day = days[index];
        final playedOnDay = history.any((h) => 
          h.date.year == day.year && h.date.month == day.month && h.date.day == day.day
        );

        return AnimationConfiguration.staggeredGrid(
          position: index,
          duration: const Duration(milliseconds: 400),
          columnCount: 7,
          child: ScaleAnimation(
            child: FadeInAnimation(
              child: Container(
                decoration: BoxDecoration(
                  color: playedOnDay ? AppColors.accent : Colors.black.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
