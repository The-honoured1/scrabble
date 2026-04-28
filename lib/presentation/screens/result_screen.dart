import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scrabble/core/theme.dart';
import 'package:scrabble/core/motion.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class ResultScreen extends StatefulWidget {
  final bool isWin;
  final int score;

  const ResultScreen({super.key, required this.isWin, required this.score});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 4));
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    if (widget.isWin) {
      _confettiController.play();
    }
    _animationController.forward();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          if (widget.isWin)
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: true,
                colors: const [Colors.gold, Colors.blue, Colors.pink, Colors.orange, Colors.purple],
              ),
            ),
          
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Score Slam
                  ScaleTransition(
                    scale: Tween<double>(begin: 0.0, end: 1.0).animate(
                      CurvedAnimation(parent: _animationController, curve: Curves.bounceOut),
                    ),
                    child: Column(
                      children: [
                        Text(
                          widget.isWin ? 'YOU WIN' : 'NEXT TIME',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 48,
                            fontWeight: FontWeight.w900,
                            color: widget.isWin ? AppColors.primary : AppColors.textMuted,
                            letterSpacing: 2,
                          ),
                        ),
                        Text(
                          '${widget.score}',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 120,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const Text(
                          'POINTS',
                          style: TextStyle(
                            letterSpacing: 8,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 60),

                  // Words Played
                  const Text(
                    'WORDS PLAYED',
                    style: TextStyle(
                      letterSpacing: 2,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 50,
                    child: AnimationLimiter(
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 5,
                        itemBuilder: (context, index) {
                          final words = ['SCRABBLE', 'DYNAMIC', 'BOARD', 'TILES', 'MOTION'];
                          return AnimationConfiguration.staggeredList(
                            position: index,
                            duration: const Duration(milliseconds: 500),
                            child: SlideAnimation(
                              horizontalOffset: 50.0,
                              child: FadeInAnimation(
                                child: _WordChip(
                                  word: words[index],
                                  isBest: index == 0,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 60),

                  // CTAs
                  Row(
                    children: [
                      Expanded(
                        child: SpringyFeedback(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white24),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Center(
                              child: Text(
                                'SHARE',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: SpringyFeedback(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Center(
                              child: Text(
                                'PLAY AGAIN',
                                style: TextStyle(
                                  color: AppColors.background,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WordChip extends StatelessWidget {
  final String word;
  final bool isBest;

  const _WordChip({required this.word, this.isBest = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: isBest ? AppColors.primary : AppColors.surface,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: isBest ? AppColors.primary : Colors.white10,
        ),
      ),
      child: Center(
        child: Text(
          word,
          style: TextStyle(
            color: isBest ? AppColors.background : Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
