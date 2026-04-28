import 'package:flutter/material.dart';
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
      backgroundColor: AppColors.background,
      body: GestureDetector(
        onTap: _navigateToHome,
        child: Stack(
          children: [
            // Letterbox Bars (Revealing Home underneath)
            Center(
              child: AnimatedBuilder(
                animation: _logoController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _logoAnimation.value),
                    child: Text(
                      'SCRABBLE',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            letterSpacing: 8,
                            color: AppColors.primary,
                          ),
                    ),
                  );
                },
              ),
            ),

            // Top Bar
            AnimatedBuilder(
              animation: _barsController,
              builder: (context, child) {
                return FractionalTranslation(
                  translation: Offset(0, _topBarAnimation.value),
                  child: Container(
                    height: MediaQuery.of(context).size.height / 2,
                    width: double.infinity,
                    color: AppColors.background,
                  ),
                );
              },
            ),

            // Bottom Bar
            Align(
              alignment: Alignment.bottomCenter,
              child: AnimatedBuilder(
                animation: _barsController,
                builder: (context, child) {
                  return FractionalTranslation(
                    translation: Offset(0, _bottomBarAnimation.value),
                    child: Container(
                      height: MediaQuery.of(context).size.height / 2,
                      width: double.infinity,
                      color: AppColors.background,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
