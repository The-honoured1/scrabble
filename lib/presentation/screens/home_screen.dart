import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:scrabble/core/theme.dart';
import 'package:scrabble/core/motion.dart';
import 'package:scrabble/presentation/screens/game_screen.dart';
import 'package:intl/intl.dart';

import 'package:scrabble/presentation/screens/stats_screen.dart';
import 'package:scrabble/presentation/screens/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Parallax Background
          const _ParallaxBackground(),

          IndexedStack(
            index: _selectedIndex,
            children: [
              _HomeContent(),
              const StatsScreen(),
              const StatsScreen(), // History placeholder
              const SettingsScreen(),
            ],
          ),

          // Bottom Nav
          Align(
            alignment: Alignment.bottomCenter,
            child: CustomBottomNav(
              selectedIndex: _selectedIndex,
              onItemSelected: (index) => setState(() => _selectedIndex = index),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: AnimationConfiguration.toStaggeredList(
            duration: const Duration(milliseconds: 600),
            childAnimationBuilder: (widget) => SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(child: widget),
            ),
            children: [
              const SizedBox(height: 40),
              const _AnimatedWordmark(),
              const SizedBox(height: 8),
              const _TypewriterDate(),
              const SizedBox(height: 40),
              const DailyChallengeCard(),
              const SizedBox(height: 24),
              const _SecondaryButtons(),
              const SizedBox(height: 40),
              const Text(
                'STREAK',
                style: TextStyle(
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 16),
              const StreakDisplay(),
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }
}

class _ParallaxBackground extends StatelessWidget {
  const _ParallaxBackground();

  @override
  Widget build(BuildContext context) {
    // In a real app with sensors_plus, we'd use sensor data to offset this.
    // For now, we'll use a slow subtle animation or just a static grid.
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        image: DecorationImage(
          image: const NetworkImage('https://www.transparenttextures.com/patterns/carbon-fibre.png'),
          opacity: 0.1,
          repeat: ImageRepeat.repeat,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.5,
            colors: [
              AppColors.surface.withOpacity(0.5),
              AppColors.background,
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedWordmark extends StatelessWidget {
  const _AnimatedWordmark();

  @override
  Widget build(BuildContext context) {
    const text = 'SCRABBLE';
    return Row(
      children: text.split('').asMap().entries.map((entry) {
        return AnimationConfiguration.staggeredList(
          position: entry.key,
          duration: const Duration(milliseconds: 600),
          child: SlideAnimation(
            verticalOffset: -50.0,
            child: ScaleAnimation(
              scale: 0.5,
              child: Text(
                entry.value,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                  letterSpacing: 4,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
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

class DailyChallengeCard extends StatelessWidget {
  const DailyChallengeCard({super.key});

  @override
  Widget build(BuildContext context) {
    return SpringyFeedback(
      onTap: () {
        Navigator.of(context).push(
          ScaleFadePageRoute(page: const GameScreen()),
        );
      },
      child: Container(
        height: MediaQuery.of(context).size.height * 0.4,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Mini Board Preview
            const Positioned.fill(child: _MiniBoardPreview()),
            // Overlay gradient
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      AppColors.surface.withOpacity(0.9),
                    ],
                  ),
                ),
              ),
            ),
            // Labels
            const Positioned(
              left: 20,
              bottom: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DAILY CHALLENGE',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      letterSpacing: 1,
                    ),
                  ),
                  SizedBox(height: 4),
                  _PulsingPlayLabel(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniBoardPreview extends StatelessWidget {
  const _MiniBoardPreview();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
      ),
      itemCount: 49,
      itemBuilder: (context, index) {
        final hasTile = index % 5 == 0;
        return AnimationConfiguration.staggeredGrid(
          position: index,
          duration: const Duration(milliseconds: 500),
          columnCount: 7,
          child: ScaleAnimation(
            scale: 0.5,
            child: Container(
              decoration: BoxDecoration(
                color: hasTile ? AppColors.primary : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(4),
              ),
              child: hasTile
                  ? Center(
                      child: Text(
                        'A',
                        style: TextStyle(
                          color: AppColors.background,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    )
                  : null,
            ),
          ),
        );
      },
    );
  }
}

class _PulsingPlayLabel extends StatefulWidget {
  const _PulsingPlayLabel();

  @override
  State<_PulsingPlayLabel> createState() => _PulsingPlayLabelState();
}

class _PulsingPlayLabelState extends State<_PulsingPlayLabel> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Text(
        'PLAY TODAY',
        style: TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _SecondaryButtons extends StatelessWidget {
  const _SecondaryButtons();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ModeButton(
            label: 'PRACTICE',
            icon: Icons.fitness_center,
            onTap: () {},
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _ModeButton(
            label: 'VS COMPUTER',
            icon: Icons.computer,
            onTap: () {},
          ),
        ),
      ],
    );
  }
}

class _ModeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _ModeButton({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SpringyFeedback(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StreakDisplay extends StatelessWidget {
  const StreakDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (index) {
        final isFilled = index < 3;
        final isCurrent = index == 3;
        return AnimationConfiguration.staggeredList(
          position: index,
          duration: const Duration(milliseconds: 600),
          child: SlideAnimation(
            horizontalOffset: 20,
            child: ElasticInAnimation(
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
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      margin: const EdgeInsets.only(bottom: 24, left: 24, right: 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
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
            curve: Curves.backOut,
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
