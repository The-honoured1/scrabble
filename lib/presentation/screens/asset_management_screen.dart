import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scrabble/core/theme.dart';
import 'package:scrabble/core/motion.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class AssetManagementScreen extends StatefulWidget {
  const AssetManagementScreen({super.key});

  @override
  State<AssetManagementScreen> createState() => _AssetManagementScreenState();
}

class _AssetManagementScreenState extends State<AssetManagementScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.8);
  int _currentPack = 0;

  final List<AssetPack> _packs = [
    AssetPack(
      name: 'CLASSIC WOOD',
      tileColor: const Color(0xFFD4A373),
      textColor: const Color(0xFF432818),
      boardColor: const Color(0xFFFEFAE0),
      premiumColor: const Color(0xFFBC6C25),
    ),
    AssetPack(
      name: 'MIDNIGHT PREMIUM',
      tileColor: AppColors.primary,
      textColor: AppColors.background,
      boardColor: AppColors.surface,
      premiumColor: AppColors.secondary,
    ),
    AssetPack(
      name: 'NEON PULSE',
      tileColor: const Color(0xFF00FFD1),
      textColor: Colors.black,
      boardColor: const Color(0xFF0D0221),
      premiumColor: const Color(0xFFFF006E),
    ),
  ];

  void _applyPack() async {
    HapticService.medium();
    // In a real app, this would update a global theme provider
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_packs[_currentPack].name} APPLIED!'),
        backgroundColor: _packs[_currentPack].tileColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
    await Future.delayed(const Duration(milliseconds: 400));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'ASSETS',
          style: GoogleFonts.jetBrainsMono(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 4,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 40),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) => setState(() => _currentPack = index),
              itemCount: _packs.length,
              itemBuilder: (context, index) {
                final pack = _packs[index];
                return AnimatedBuilder(
                  animation: _pageController,
                  builder: (context, child) {
                    double value = 1.0;
                    if (_pageController.position.haveDimensions) {
                      value = _pageController.page! - index;
                      value = (1 - (value.abs() * 0.2)).clamp(0.0, 1.0);
                    }
                    return Transform.scale(
                      scale: value,
                      child: _PackPreviewCard(pack: pack),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 60),
          
          // Apply Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: SpringyFeedback(
              onTap: _applyPack,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: _packs[_currentPack].tileColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: _packs[_currentPack].tileColor.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'APPLY THEME',
                    style: TextStyle(
                      color: _packs[_currentPack].textColor,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 60),
        ],
      ),
    );
  }
}

class _PackPreviewCard extends StatelessWidget {
  final AssetPack pack;

  const _PackPreviewCard({required this.pack});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: pack.boardColor,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            pack.name,
            style: GoogleFonts.playfairDisplay(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: pack.tileColor,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 40),
          // 3x3 Sample Board
          Expanded(
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              itemCount: 9,
              itemBuilder: (context, index) {
                final isTile = index % 2 == 0;
                final isPremium = index == 4;
                return Container(
                  decoration: BoxDecoration(
                    color: isTile
                        ? pack.tileColor
                        : isPremium
                            ? pack.premiumColor.withOpacity(0.4)
                            : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: isTile
                      ? Center(
                          child: Text(
                            String.fromCharCode(65 + index),
                            style: TextStyle(
                              color: pack.textColor,
                              fontWeight: FontWeight.w900,
                              fontSize: 24,
                            ),
                          ),
                        )
                      : null,
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'PREVIEW',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 10,
              color: Colors.white30,
              letterSpacing: 4,
            ),
          ),
        ],
      ),
    );
  }
}

class AssetPack {
  final String name;
  final Color tileColor;
  final Color textColor;
  final Color boardColor;
  final Color premiumColor;

  AssetPack({
    required this.name,
    required this.tileColor,
    required this.textColor,
    required this.boardColor,
    required this.premiumColor,
  });
}
