import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scrabble/core/theme.dart';
import 'package:scrabble/core/motion.dart';
import 'package:scrabble/presentation/screens/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _barsController;
  late Animation<double> _logoAnimation;
  late Animation<double> _topBarAnimation;
  late Animation<double> _bottomBarAnimation;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _barsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _logoAnimation = Tween<double>(begin: -300, end: 0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.bounceOut),
    );

    _topBarAnimation = Tween<double>(begin: 0, end: -1).animate(
      CurvedAnimation(parent: _barsController, curve: Curves.easeInOutExpo),
    );

    _bottomBarAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _barsController, curve: Curves.easeInOutExpo),
    );

    _startSequence();
  }

  Future<void> _startSequence() async {
    await _logoController.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    _barsController.forward();
    await Future.delayed(const Duration(milliseconds: 800));
    _navigateToHome();
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      ScaleFadePageRoute(page: const HomeScreen()),
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    _barsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedBuilder(
          animation: _logoController,
          builder: (context, child) {
            final opacity = (_logoController.value).clamp(0.0, 1.0);
            return Opacity(
              opacity: opacity,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'The Scrabble Game',
                    style: GoogleFonts.frankRuhlLibre(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textBody,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: 60,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
