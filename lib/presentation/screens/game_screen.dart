import 'dart:math';
import 'package:flutter/material.dart';
import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:confetti/confetti.dart';
import 'package:scrabble/core/theme.dart';
import 'package:scrabble/core/motion.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:shimmer/shimmer.dart';
import 'package:scrabble/services/dictionary_service.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _boardController;
  late AnimationController _rackController;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  
  double _playerScore = 124;
  double _opponentScore = 98;
  int _moveCount = 14;

  final List<String> _rackTiles = ['S', 'C', 'R', 'A', 'B', 'B', 'L'];
  final List<PlacedTile> _boardTiles = [];

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _boardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _rackController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: -10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut));

    _startEntrance();
    _initMockBoard();
  }

  void _initMockBoard() {
    _boardTiles.addAll([
      PlacedTile(letter: 'W', x: 7, y: 7),
      PlacedTile(letter: 'O', x: 8, y: 7),
      PlacedTile(letter: 'R', x: 9, y: 7),
      PlacedTile(letter: 'D', x: 10, y: 7),
      PlacedTile(letter: 'G', x: 7, y: 8),
      PlacedTile(letter: 'A', x: 7, y: 9),
      PlacedTile(letter: 'M', x: 7, y: 10),
      PlacedTile(letter: 'E', x: 7, y: 11),
    ]);
  }

  Future<void> _startEntrance() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _boardController.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    _rackController.forward();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _boardController.dispose();
    _rackController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _onCommit() async {
    HapticService.medium();
    
    // In a real game, logic would extract the word from placed tiles
    const String simulatedWord = 'SCRABBLE';
    final isValid = DictionaryService().isValidWord(simulatedWord);

    await Future.delayed(const Duration(milliseconds: 200));
    
    if (isValid) {
      _confettiController.play();
      HapticService.success();
      setState(() {
        _playerScore += 88;
        _moveCount++;
      });
    } else {
      _shakeController.forward(from: 0);
      HapticService.heavy();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeAnimation.value, 0),
          child: child,
        );
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              _GameHUD(
                playerScore: _playerScore,
                opponentScore: _opponentScore,
                moveCount: _moveCount,
              ),
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    _ScrabbleBoard(
                      controller: _boardController,
                      placedTiles: _boardTiles,
                    ),
                    Align(
                      alignment: Alignment.topCenter,
                      child: ConfettiWidget(
                        confettiController: _confettiController,
                        blastDirectionality: BlastDirectionality.explosive,
                        colors: const [Colors.gold, Colors.white, Colors.orange],
                      ),
                    ),
                  ],
                ),
              ),
              _TileRack(
                controller: _rackController,
                tiles: _rackTiles,
                onCommit: _onCommit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GameHUD extends StatelessWidget {
  final double playerScore;
  final double opponentScore;
  final int moveCount;

  const _GameHUD({
    required this.playerScore,
    required this.opponentScore,
    required this.moveCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white10, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _HUDScoreItem(label: 'YOU', score: playerScore, isPlayer: true),
          Column(
            children: [
              Text(
                'DAILY CHALLENGE',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10,
                  color: AppColors.textMuted,
                  letterSpacing: 1.5,
                ),
              ),
              Text(
                'MOVE $moveCount',
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
              ),
            ],
          ),
          _HUDScoreItem(label: 'CPU', score: opponentScore, isPlayer: false),
        ],
      ),
    );
  }
}

class _HUDScoreItem extends StatelessWidget {
  final String label;
  final double score;
  final bool isPlayer;

  const _HUDScoreItem({required this.label, required this.score, required this.isPlayer});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: isPlayer ? AppColors.primary : AppColors.surface,
          child: Text(
            label[0],
            style: TextStyle(
              color: isPlayer ? AppColors.background : Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(height: 4),
        AnimatedFlipCounter(
          value: score,
          textStyle: GoogleFonts.jetBrainsMono(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isPlayer ? AppColors.primary : Colors.white,
          ),
        ),
      ],
    );
  }
}

class _ScrabbleBoard extends StatefulWidget {
  final AnimationController controller;
  final List<PlacedTile> placedTiles;

  const _ScrabbleBoard({required this.controller, required this.placedTiles});

  @override
  State<_ScrabbleBoard> createState() => _ScrabbleBoardState();
}

class _ScrabbleBoardState extends State<_ScrabbleBoard> {
  bool _shimmerActive = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _shimmerActive = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.92, end: 1.0).animate(
        CurvedAnimation(parent: widget.controller, curve: Curves.easeOutExpo),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = min(constraints.maxWidth, constraints.maxHeight) - 32;
          final board = Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10),
            ),
            padding: const EdgeInsets.all(4),
            child: Stack(
              children: [
                GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 15,
                    mainAxisSpacing: 2,
                    crossAxisSpacing: 2,
                  ),
                  itemCount: 225,
                  itemBuilder: (context, index) {
                    final x = index % 15;
                    final y = index ~/ 15;
                    final isPremium = (x == 0 || x == 7 || x == 14) && (y == 0 || y == 7 || y == 14);
                    if (isPremium && !(x == 7 && y == 7)) {
                      return const _PremiumSquare();
                    }
                    return const _BoardCell();
                  },
                ),
                ...widget.placedTiles.map((tile) {
                  return _AnimatedPlacedTile(
                    tile: tile,
                    boardController: widget.controller,
                    cellSize: (size - 8) / 15,
                  );
                }),
              ],
            ),
          );

          if (_shimmerActive) {
            return Shimmer.fromColors(
              baseColor: Colors.transparent,
              highlightColor: Colors.white.withOpacity(0.1),
              period: const Duration(seconds: 1),
              child: board,
            );
          }
          return board;
        },
      ),
    );
  }
}

class _PremiumSquare extends StatefulWidget {
  const _PremiumSquare();

  @override
  State<_PremiumSquare> createState() => _PremiumSquareState();
}

class _PremiumSquareState extends State<_PremiumSquare> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
          vsync: this,
          duration: const Duration(seconds: 3),
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
      opacity: Tween<double>(begin: 1.0, end: 0.85).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.secondary.withOpacity(0.2),
          borderRadius: BorderRadius.circular(2),
        ),
        child: Center(
          child: Container(
            width: 4,
            height: 4,
            decoration: const BoxDecoration(
              color: AppColors.secondary,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

class _BoardCell extends StatelessWidget {
  const _BoardCell();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _AnimatedPlacedTile extends StatelessWidget {
  final PlacedTile tile;
  final AnimationController boardController;
  final double cellSize;

  const _AnimatedPlacedTile({
    required this.tile,
    required this.boardController,
    required this.cellSize,
  });

  @override
  Widget build(BuildContext context) {
    final random = Random();
    final startX = (random.nextDouble() * 2 - 1) * 300;
    final startY = (random.nextDouble() * 2 - 1) * 300;

    return AnimatedBuilder(
      animation: boardController,
      builder: (context, child) {
        final t = CurvedAnimation(
          parent: boardController,
          curve: Interval(
            (tile.x + tile.y) / 30,
            1.0,
            curve: Curves.elasticOut,
          ),
        ).value;

        final currentX = startX + (tile.x * (cellSize + 2) - startX) * t;
        final currentY = startY + (tile.y * (cellSize + 2) - startY) * t;

        return Positioned(
          left: currentX,
          top: currentY,
          child: Opacity(
            opacity: t.clamp(0.0, 1.0),
            child: _TileWidget(
              letter: tile.letter,
              size: cellSize,
            ),
          ),
        );
      },
    );
  }
}

class _TileWidget extends StatelessWidget {
  final String letter;
  final double size;
  final bool isRack;

  const _TileWidget({required this.letter, required this.size, this.isRack = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(4),
        boxShadow: isRack ? [
          const BoxShadow(
            color: Colors.black26,
            offset: Offset(0, 4),
            blurRadius: 0,
          )
        ] : null,
      ),
      child: Center(
        child: Text(
          letter,
          style: TextStyle(
            color: AppColors.background,
            fontWeight: FontWeight.w900,
            fontSize: size * 0.6,
          ),
        ),
      ),
    );
  }
}

class _TileRack extends StatelessWidget {
  final AnimationController controller;
  final List<String> tiles;
  final VoidCallback onCommit;

  const _TileRack({
    required this.controller,
    required this.tiles,
    required this.onCommit,
  });

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeOutBack),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: tiles.asMap().entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: AnimationConfiguration.staggeredList(
                    position: entry.key,
                    duration: const Duration(milliseconds: 600),
                    child: SlideAnimation(
                      verticalOffset: 20,
                      child: _DraggableTile(letter: entry.value),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            SpringyFeedback(
              onTap: onCommit,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text(
                    'PLAY WORD',
                    style: TextStyle(
                      color: AppColors.background,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DraggableTile extends StatefulWidget {
  final String letter;

  const _DraggableTile({required this.letter});

  @override
  State<_DraggableTile> createState() => _DraggableTileState();
}

class _DraggableTileState extends State<_DraggableTile> {
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    return LongPressDraggable<String>(
      data: widget.letter,
      feedback: Transform.rotate(
        angle: 0.05,
        child: Material(
          color: Colors.transparent,
          child: _TileWidget(letter: widget.letter, size: 64, isRack: true),
        ),
      ),
      onDragStarted: () {
        HapticService.light();
        setState(() => _isDragging = true);
      },
      onDragEnd: (details) {
        setState(() => _isDragging = false);
      },
      child: Opacity(
        opacity: _isDragging ? 0.3 : 1.0,
        child: _TileWidget(letter: widget.letter, size: 48, isRack: true),
      ),
    );
  }
}

class PlacedTile {
  final String letter;
  final int x;
  final int y;

  PlacedTile({required this.letter, required this.x, required this.y});
}
