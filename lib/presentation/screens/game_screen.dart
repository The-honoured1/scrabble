import 'dart:math';
import 'package:flutter/material.dart';
import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:confetti/confetti.dart';
import 'package:scrabble/core/theme.dart';
import 'package:scrabble/core/motion.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:shimmer/shimmer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scrabble/services/dictionary_service.dart';
import 'package:scrabble/controllers/game_controller.dart';
import 'package:scrabble/models/tile_model.dart';
import 'package:scrabble/models/board_model.dart';
import 'package:scrabble/models/game_mode.dart';

class GameScreen extends StatefulWidget {
  final GameMode mode;
  const GameScreen({super.key, this.mode = GameMode.vsComputer});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late GameController _gameController;
  late ConfettiController _confettiController;
  late AnimationController _boardController;
  late AnimationController _rackController;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _gameController = GameController(mode: widget.mode);
    _gameController.addListener(() => setState(() {}));
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
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              _GameHUD(
                playerScore: _gameController.state.playerScore.toDouble(),
                opponentScore: _gameController.state.cpuScore.toDouble(),
                moveCount: _gameController.state.moveCount,
              ),
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      child: InteractiveViewer(
                        boundaryMargin: const EdgeInsets.all(100),
                        minScale: 0.5,
                        maxScale: 2.5,
                        child: _ScrabbleBoard(
                          controller: _boardController,
                          gameController: _gameController,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topCenter,
                      child: ConfettiWidget(
                        confettiController: _confettiController,
                        blastDirectionality: BlastDirectionality.explosive,
                        colors: const [AppColors.accent, AppColors.secondary, AppColors.orange],
                      ),
                    ),
                  ],
                ),
              ),
              _TileRack(
                controller: _rackController,
                gameController: _gameController,
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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.black.withOpacity(0.05), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _HUDScoreItem(label: 'YOU', score: playerScore, isPlayer: true),
          Column(
            children: [
              Text(
                'MOVE $moveCount',
                style: GoogleFonts.frankRuhlLibre(
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                  color: AppColors.textBody,
                ),
              ),
              const SizedBox(height: 2),
              Container(
                width: 40,
                height: 3,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(2),
                ),
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
        Text(
          label,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 4),
        AnimatedFlipCounter(
          value: score,
          textStyle: GoogleFonts.frankRuhlLibre(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: isPlayer ? AppColors.accent : AppColors.primary,
          ),
        ),
      ],
    );
  }
}

class _ScrabbleBoard extends StatefulWidget {
  final AnimationController controller;
  final GameController gameController;

  const _ScrabbleBoard({required this.controller, required this.gameController});

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
          final size = min(constraints.maxWidth, constraints.maxHeight) - 40;
          final board = Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            padding: const EdgeInsets.all(4),
            child: RepaintBoundary(
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
                        final square = widget.gameController.state.board[y][x];
                        
                        return _BoardCell(
                          square: square,
                          onTileDropped: (tile) => widget.gameController.placeTile(tile, x, y),
                        );
                      },
                    ),
                    // Render permanent tiles
                    ..._buildPlacedTiles(size),
                    // Render pending tiles
                    ..._buildPendingTiles(size),
                  ],
                ),
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

    List<Widget> _buildPlacedTiles(double size) {
      final cellSize = (size - 8) / 15;
      List<Widget> tiles = [];
      for (int y = 0; y < 15; y++) {
        for (int x = 0; x < 15; x++) {
          final tile = widget.gameController.state.board[y][x].tile;
          if (tile != null) {
            tiles.add(Positioned(
              left: x * (cellSize + 2),
              top: y * (cellSize + 2),
              child: _TileWidget(tile: tile, size: cellSize),
            ));
          }
        }
      }
      return tiles;
    }

    List<Widget> _buildPendingTiles(double size) {
      final cellSize = (size - 8) / 15;
      return widget.gameController.pendingPlacements.map((p) {
        return Positioned(
          left: p.x * (cellSize + 2),
          top: p.y * (cellSize + 2),
          child: _TileWidget(tile: p.tile, size: cellSize),
        );
      }).toList();
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
  final BoardSquare square;
  final Function(ScrabbleTile) onTileDropped;

  const _BoardCell({required this.square, required this.onTileDropped});

  @override
  Widget build(BuildContext context) {
    return DragTarget<ScrabbleTile>(
      onWillAccept: (data) => square.tile == null,
      onAccept: onTileDropped,
      builder: (context, candidateData, rejectedData) {
        final isPremium = square.multiplier != MultiplierType.none;
        final color = _getMultiplierColor();
        
        return Container(
          decoration: BoxDecoration(
            color: isPremium ? color : Colors.black.withOpacity(0.02),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.black.withOpacity(0.03), width: 0.5),
          ),
          child: Stack(
            children: [
              if (isPremium) Center(
                child: Text(
                  _getMultiplierText(),
                  style: const TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
              if (candidateData.isNotEmpty) Container(
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getMultiplierColor() {
    switch (square.multiplier) {
      case MultiplierType.doubleLetter: return AppColors.accent;
      case MultiplierType.tripleLetter: return Colors.blueAccent;
      case MultiplierType.doubleWord: return AppColors.primary;
      case MultiplierType.tripleWord: return AppColors.secondary;
      default: return Colors.transparent;
    }
  }

  String _getMultiplierText() {
    switch (square.multiplier) {
      case MultiplierType.doubleLetter: return '2L';
      case MultiplierType.tripleLetter: return '3L';
      case MultiplierType.doubleWord: return '2W';
      case MultiplierType.tripleWord: return '3W';
      default: return '';
    }
  }
}


class _TileWidget extends StatelessWidget {
  final ScrabbleTile tile;
  final double size;
  final bool isRack;

  const _TileWidget({required this.tile, required this.size, this.isRack = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isRack ? Colors.white : AppColors.primary,
        borderRadius: BorderRadius.circular(isRack ? 12 : 4),
        border: isRack ? Border.all(color: Colors.black12, width: 2) : null,
        boxShadow: isRack ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, 4),
            blurRadius: 0,
          )
        ] : null,
      ),
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              tile.letter,
              style: GoogleFonts.frankRuhlLibre(
                color: isRack ? AppColors.textBody : Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: size * 0.6,
              ),
            ),
            Positioned(
              right: size * 0.12,
              bottom: size * 0.12,
              child: Text(
                '${tile.points}',
                style: TextStyle(
                  color: (isRack ? AppColors.textBody : Colors.white).withOpacity(0.5),
                  fontWeight: FontWeight.bold,
                  fontSize: size * 0.22,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TileRack extends StatelessWidget {
  final AnimationController controller;
  final GameController gameController;

  const _TileRack({
    required this.controller,
    required this.gameController,
  });

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeOutBack),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 40,
              offset: Offset(0, -10),
            ),
          ],
        ),
        child: Column(
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: gameController.state.playerRack.asMap().entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: AnimationConfiguration.staggeredList(
                      position: entry.key,
                      duration: const Duration(milliseconds: 600),
                      child: SlideAnimation(
                        verticalOffset: 20,
                        child: _DraggableTile(tile: entry.value, gameController: gameController),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),
            SpringyFeedback(
              onTap: gameController.commitMove,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 22),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(40),
                ),
                child: const Center(
                  child: Text(
                    'SUBMIT WORD',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
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
  final ScrabbleTile tile;
  final GameController gameController;

  const _DraggableTile({required this.tile, required this.gameController});

  @override
  State<_DraggableTile> createState() => _DraggableTileState();
}

class _DraggableTileState extends State<_DraggableTile> {
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    // Check if tile is in pending placements
    final isPending = widget.gameController.pendingPlacements.any((p) => p.tile == widget.tile);

    return LongPressDraggable<ScrabbleTile>(
      data: widget.tile,
      feedback: Transform.rotate(
        angle: 0.05,
        child: Material(
          color: Colors.transparent,
          child: _TileWidget(tile: widget.tile, size: 64, isRack: true),
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
        opacity: (_isDragging || isPending) ? 0.3 : 1.0,
        child: _TileWidget(tile: widget.tile, size: 48, isRack: true),
      ),
    );
  }
}

