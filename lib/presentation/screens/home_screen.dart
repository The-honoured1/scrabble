import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:scrabble/core/theme.dart';
import 'package:scrabble/core/motion.dart';
import 'package:scrabble/presentation/screens/game_screen.dart';
import 'package:scrabble/models/game_mode.dart';
import 'package:intl/intl.dart';
import 'package:animate_do/animate_do.dart';

import 'package:scrabble/presentation/screens/stats_screen.dart';
import 'package:scrabble/presentation/screens/history_screen.dart';
import 'package:scrabble/presentation/screens/settings_screen.dart';
import 'package:scrabble/services/stats_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  int _streak = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final s = await StatsService.getStats();
    if (mounted) setState(() => _streak = s['currentStreak'] ?? 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _HomeContent(streak: _streak),
          const StatsScreen(),
          const HistoryScreen(),
          const SettingsScreen(),
        ],
      ),
      bottomNavigationBar: CustomBottomNav(
        selectedIndex: _selectedIndex,
        onItemSelected: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  final int streak;
  const _HomeContent({required this.streak});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              const _NytWordmark(),
              const SizedBox(height: 8),
              const _TypewriterDate(),
              const Divider(height: 60, thickness: 1, color: Colors.black12),
              const _ZenHeading(),
              const SizedBox(height: 32),
              const _SubscribeButton(),
              const Divider(height: 80, thickness: 1, color: Colors.black12),
              const _EditorialMenu(),
              const Divider(height: 80, thickness: 1, color: Colors.black12),
              const Text(
                'STATISTICS',
                style: TextStyle(
                  letterSpacing: 4,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  color: AppColors.textBody,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                '$streak DAY STREAK',
                style: GoogleFonts.frankRuhlLibre(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: AppColors.orange,
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _NytWordmark extends StatelessWidget {
  const _NytWordmark();

  @override
  Widget build(BuildContext context) {
    return Text(
      'The Scrabble Games',
      style: GoogleFonts.frankRuhlLibre(
        fontSize: 24,
        fontWeight: FontWeight.w900,
        color: AppColors.textBody,
        letterSpacing: -0.5,
      ),
    );
  }
}

class _ZenHeading extends StatelessWidget {
  const _ZenHeading();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Find\nyour\nzen.',
      textAlign: TextAlign.center,
      style: GoogleFonts.frankRuhlLibre(
        fontSize: 56,
        fontWeight: FontWeight.w900,
        height: 1.05,
        color: AppColors.textBody,
      ),
    );
  }
}

class _SubscribeButton extends StatelessWidget {
  const _SubscribeButton();

  @override
  Widget build(BuildContext context) {
    return SpringyFeedback(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: AppColors.primary, width: 2),
        ),
        child: const Text(
          'PLAY NOW',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 14,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}

class _EditorialMenu extends StatelessWidget {
  const _EditorialMenu();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _MenuTile(
          title: 'Daily Challenge',
          subtitle: 'A new board every day.',
          onTap: () => Navigator.push(context, ScaleFadePageRoute(page: const GameScreen(mode: GameMode.dailyChallenge))),
        ),
        const Divider(color: Colors.black12),
        _MenuTile(
          title: 'Versus Computer',
          subtitle: 'Challenge the AI engine.',
          onTap: () => Navigator.push(context, ScaleFadePageRoute(page: const GameScreen(mode: GameMode.vsComputer))),
        ),
        const Divider(color: Colors.black12),
        _MenuTile(
          title: 'Zen Practice',
          subtitle: 'Improve your vocabulary.',
          onTap: () => Navigator.push(context, ScaleFadePageRoute(page: const GameScreen(mode: GameMode.practice))),
        ),
      ],
    );
  }
}

class _MenuTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuTile({required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      onTap: onTap,
      title: Text(
        title,
        style: GoogleFonts.frankRuhlLibre(
          fontSize: 24,
          fontWeight: FontWeight.w900,
          color: AppColors.textBody,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.inter(
          fontSize: 14,
          color: AppColors.textMuted,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textBody),
    );
  }
}


class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.02)
      ..strokeWidth = 1;

    const spacing = 30.0;

    for (double i = 0; i < size.width; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += spacing) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TypewriterDate extends StatelessWidget {
  const _TypewriterDate();

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('EEEE, MMMM d').format(DateTime.now()).toUpperCase();
    return AnimatedTextKit(
      animatedTexts: [
        TypewriterAnimatedText(
          dateStr,
          textStyle: GoogleFonts.jetBrainsMono(
            fontSize: 14,
            color: AppColors.textMuted,
            letterSpacing: 1.5,
          ),
          speed: const Duration(milliseconds: 40),
        ),
      ],
      isRepeatingAnimation: false,
    );
  }
}

class StreakDisplay extends StatelessWidget {
  final int streak;
  const StreakDisplay({super.key, required this.streak});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (index) {
        final isFilled = index < streak;
        final isCurrent = index == streak;
        return AnimationConfiguration.staggeredList(
          position: index,
          duration: const Duration(milliseconds: 600),
          child: SlideAnimation(
            horizontalOffset: 20,
            child: ElasticIn(
              child: _StreakSquare(
                isFilled: isFilled,
                isCurrent: isCurrent,
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _StreakSquare extends StatelessWidget {
  final bool isFilled;
  final bool isCurrent;

  const _StreakSquare({required this.isFilled, required this.isCurrent});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: isFilled ? AppColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isFilled ? AppColors.primary : Colors.white.withOpacity(0.1),
          width: 2,
        ),
      ),
      child: isFilled
          ? Icon(Icons.check, color: AppColors.background, size: 20)
          : isCurrent
              ? const _CurrentDayPulse()
              : null,
    );
  }
}

class _CurrentDayPulse extends StatefulWidget {
  const _CurrentDayPulse();

  @override
  State<_CurrentDayPulse> createState() => _CurrentDayPulseState();
}

class _CurrentDayPulseState extends State<_CurrentDayPulse> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.2, end: 1.0).animate(_controller),
      child: Center(
        child: Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

class CustomBottomNav extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const CustomBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    final icons = [Icons.home_filled, Icons.leaderboard, Icons.history, Icons.settings];
    final labels = ['HOME', 'STATS', 'HISTORY', 'SETTINGS'];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.black12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(4, (index) {
          final isSelected = selectedIndex == index;
          return _NavIcon(
            icon: icons[index],
            label: labels[index],
            isSelected: isSelected,
            onTap: () => onItemSelected(index),
          );
        }),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavIcon({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SpringyFeedback(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedScale(
            scale: isSelected ? 1.2 : 1.0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutBack,
            child: Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 4),
          AnimatedOpacity(
            opacity: isSelected ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
