import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/wordie_game.dart';
import '../theme/wordie_theme.dart';
import '../widgets/mesh_background.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({required this.game, required this.totalGames, super.key});

  final WordieGame game;
  final int totalGames;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: MeshBackground()),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    game.color.withValues(alpha: 0.14),
                    Colors.transparent,
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _TopButton(
                        icon: Icons.arrow_back_rounded,
                        onTap: () => Navigator.of(context).pop(),
                      ),
                      const Spacer(),
                      _TopButton(icon: Icons.ios_share_rounded, onTap: () {}),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Text(game.emoji, style: const TextStyle(fontSize: 42)),
                  const SizedBox(height: 12),
                  Text(game.title, style: textTheme.displaySmall),
                  const SizedBox(height: 10),
                  Text(
                    game.description,
                    style: textTheme.bodyLarge?.copyWith(
                      color: WordieTheme.textPrimary.withValues(alpha: 0.88),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _Badge(
                        label: game.mode == WordieMode.daily
                            ? 'Daily ritual'
                            : 'Replay anytime',
                        color: game.color,
                      ),
                      _Badge(
                        label: game.isCompletedToday
                            ? game.resultLabel ?? 'Completed today'
                            : 'Ready to play',
                        color: Colors.white,
                      ),
                      _Badge(
                        label:
                            '${game.id.index + 1} of $totalGames in the collection',
                        color: Colors.white,
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  _PreviewPanel(game: game),
                  const SizedBox(height: 24),
                  Text('Why it feels good', style: textTheme.headlineSmall),
                  const SizedBox(height: 14),
                  for (final highlight in game.highlights) ...[
                    _HighlightRow(color: game.color, text: highlight),
                    const SizedBox(height: 12),
                  ],
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: WordieTheme.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Signature motion', style: textTheme.titleLarge),
                        const SizedBox(height: 12),
                        Text(
                          'Card taps compress to 97%, transitions fade softly, and wins are designed to land like a small celebration.',
                          style: textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 18),
                        FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: game.color,
                            foregroundColor: WordieTheme.background,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          onPressed: () {},
                          child: Text(game.playLabel),
                        ),
                      ],
                    ),
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

class _TopButton extends StatelessWidget {
  const _TopButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      onPressed: onTap,
      style: IconButton.styleFrom(
        backgroundColor: Colors.white.withValues(alpha: 0.07),
        foregroundColor: WordieTheme.textPrimary,
        minimumSize: const Size(48, 48),
      ),
      icon: Icon(icon),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: color == Colors.white ? 0.07 : 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: color.withValues(alpha: color == Colors.white ? 0.1 : 0.28),
        ),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: color == Colors.white ? WordieTheme.textPrimary : color,
        ),
      ),
    );
  }
}

class _HighlightRow extends StatelessWidget {
  const _HighlightRow({required this.color, required this.text});

  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.only(top: 7),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            boxShadow: [
              BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 14),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text, style: Theme.of(context).textTheme.bodyLarge),
        ),
      ],
    );
  }
}

class _PreviewPanel extends StatelessWidget {
  const _PreviewPanel({required this.game});

  final WordieGame game;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: WordieTheme.card.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: WordieTheme.border),
        boxShadow: [
          BoxShadow(
            color: game.color.withValues(alpha: 0.16),
            blurRadius: 28,
            spreadRadius: -14,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Preview', style: Theme.of(context).textTheme.titleLarge),
              const Spacer(),
              Icon(Icons.auto_awesome_rounded, color: game.color),
            ],
          ),
          const SizedBox(height: 18),
          _previewContent(game),
        ],
      ),
    );
  }

  Widget _previewContent(WordieGame game) {
    return switch (game.id) {
      WordieGameId.wordle => _WordlePreview(color: game.color),
      WordieGameId.connections => _ConnectionsPreview(color: game.color),
      WordieGameId.spellingBee => _SpellingBeePreview(color: game.color),
      WordieGameId.miniCrossword => _CrosswordPreview(color: game.color),
      WordieGameId.wordSearch => _WordSearchPreview(color: game.color),
      WordieGameId.hangman => _HangmanPreview(color: game.color),
      WordieGameId.boggle => _BogglePreview(color: game.color),
      WordieGameId.wordLadder => _WordLadderPreview(color: game.color),
      WordieGameId.typeRacer => _TypeRacerPreview(color: game.color),
      WordieGameId.anagram => _AnagramPreview(color: game.color),
    };
  }
}

class _WordlePreview extends StatelessWidget {
  const _WordlePreview({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    const rows = [
      ['S', 'T', 'A', 'R', 'E'],
      ['P', 'L', 'A', 'N', 'T'],
      ['G', 'R', 'O', 'W', 'N'],
    ];
    final fills = [
      [0, 0, 2, 2, 0],
      [0, 2, 0, 0, 0],
      [1, 1, 1, 1, 1],
    ];

    return Column(
      children: [
        for (var r = 0; r < rows.length; r++) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var c = 0; c < rows[r].length; c++)
                Container(
                  width: 48,
                  height: 48,
                  margin: const EdgeInsets.all(4),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: switch (fills[r][c]) {
                      1 => color,
                      2 => const Color(0xFFE9A84C),
                      _ => Colors.white.withValues(alpha: 0.06),
                    },
                    boxShadow: fills[r][c] == 1
                        ? [
                            BoxShadow(
                              color: color.withValues(alpha: 0.28),
                              blurRadius: 18,
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    rows[r][c],
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _ConnectionsPreview extends StatelessWidget {
  const _ConnectionsPreview({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    final tiles = [
      'MINT',
      'BARK',
      'RING',
      'WAVE',
      'FIR',
      'PALM',
      'BELL',
      'NOTE',
      'PINE',
      'CHIME',
      'TIDE',
      'SURF',
      'DRUM',
      'OAK',
      'REEF',
      'SONG',
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final tile in tiles)
          Container(
            width: 68,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: WordieTheme.border),
            ),
            child: Text(
              tile,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
      ],
    );
  }
}

class _SpellingBeePreview extends StatelessWidget {
  const _SpellingBeePreview({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    const letters = ['A', 'L', 'N', 'R', 'E', 'T', 'G'];

    return Center(
      child: SizedBox(
        width: 240,
        height: 210,
        child: Stack(
          alignment: Alignment.center,
          children: [
            for (var i = 0; i < 6; i++)
              _HexLetter(
                letter: letters[i],
                offset: Offset(
                  math.cos((math.pi / 3) * i - math.pi / 2) * 70,
                  math.sin((math.pi / 3) * i - math.pi / 2) * 70,
                ),
                color: const Color(0xFFF2E2A0),
              ),
            _HexLetter(
              letter: letters.last,
              offset: Offset.zero,
              color: color,
              textColor: WordieTheme.background,
            ),
          ],
        ),
      ),
    );
  }
}

class _HexLetter extends StatelessWidget {
  const _HexLetter({
    required this.letter,
    required this.offset,
    required this.color,
    this.textColor = WordieTheme.textPrimary,
  });

  final String letter;
  final Offset offset;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: offset,
      child: ClipPath(
        clipper: _HexagonClipper(),
        child: Container(
          width: 72,
          height: 72,
          color: color,
          alignment: Alignment.center,
          child: Text(
            letter,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: textColor),
          ),
        ),
      ),
    );
  }
}

class _CrosswordPreview extends StatelessWidget {
  const _CrosswordPreview({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    const cells = [
      [1, 1, 1, 0, 1],
      [0, 1, 1, 1, 1],
      [1, 1, 0, 1, 1],
      [1, 0, 1, 1, 1],
      [1, 1, 1, 1, 0],
    ];

    return Column(
      children: [
        for (var row = 0; row < cells.length; row++) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var col = 0; col < cells[row].length; col++)
                Container(
                  width: 36,
                  height: 36,
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: cells[row][col] == 1
                        ? Colors.white.withValues(
                            alpha: row == 1 && col < 4 ? 0.16 : 0.08,
                          )
                        : Colors.black.withValues(alpha: 0.42),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: row == 1 && col < 4 ? color : WordieTheme.border,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _WordSearchPreview extends StatelessWidget {
  const _WordSearchPreview({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    const rows = ['WAVES', 'OCEAN', 'RIDGE', 'EMBER', 'SHELL'];

    return Column(
      children: [
        for (var r = 0; r < rows.length; r++) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var c = 0; c < rows[r].length; c++)
                Container(
                  width: 36,
                  height: 36,
                  margin: const EdgeInsets.all(3),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: r == 1
                        ? color.withValues(alpha: 0.22)
                        : Colors.white.withValues(alpha: 0.05),
                  ),
                  child: Text(rows[r][c]),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _HangmanPreview extends StatelessWidget {
  const _HangmanPreview({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Category: Animal',
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(color: color),
              ),
              const SizedBox(height: 14),
              Text(
                '_ _ A _ T _ R',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ['A', 'E', 'R', 'T', 'S', 'N']
                    .map(
                      (letter) => Container(
                        width: 36,
                        height: 36,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(letter),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 90,
          height: 120,
          child: CustomPaint(painter: _HangmanPainter(color: color)),
        ),
      ],
    );
  }
}

class _BogglePreview extends StatelessWidget {
  const _BogglePreview({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    const rows = ['S T O R', 'L A E N', 'P I D U', 'M O V E'];

    return Column(
      children: [
        for (var r = 0; r < rows.length; r++) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: rows[r].split(' ').map((letter) {
              final active =
                  (r == 0 || r == 1) &&
                  (letter == 'S' ||
                      letter == 'T' ||
                      letter == 'A' ||
                      letter == 'R');
              return Container(
                width: 46,
                height: 46,
                margin: const EdgeInsets.all(4),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: active
                      ? color.withValues(alpha: 0.22)
                      : Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: active ? color : WordieTheme.border,
                  ),
                ),
                child: Text(letter),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}

class _WordLadderPreview extends StatelessWidget {
  const _WordLadderPreview({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    const words = ['COLD', 'CORD', 'CARD', 'WARD', 'WARM'];

    return Column(
      children: [
        for (var i = 0; i < words.length; i++) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: i == words.length - 1
                  ? color.withValues(alpha: 0.2)
                  : Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              words[i],
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ],
      ],
    );
  }
}

class _TypeRacerPreview extends StatelessWidget {
  const _TypeRacerPreview({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.bodyLarge,
            children: [
              TextSpan(
                text: 'Quick',
                style: TextStyle(color: color, fontWeight: FontWeight.w700),
              ),
              const TextSpan(
                text:
                    ' words sharpen the mind and steady the hands for faster rounds.',
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _MetricChip(label: 'WPM 72', color: color),
            const SizedBox(width: 10),
            const _MetricChip(label: '98% accuracy', color: Colors.white),
          ],
        ),
      ],
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: color == Colors.white ? 0.06 : 0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: color == Colors.white ? WordieTheme.textPrimary : color,
        ),
      ),
    );
  }
}

class _AnagramPreview extends StatelessWidget {
  const _AnagramPreview({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    const letters = ['R', 'E', 'A', 'D'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: letters
              .map(
                (letter) => Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    letter,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            for (var i = 0; i < letters.length; i++) ...[
              Expanded(
                child: Container(
                  height: 52,
                  margin: EdgeInsets.only(
                    right: i == letters.length - 1 ? 0 : 10,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: color.withValues(alpha: 0.35)),
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _HexagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final radius = size.width / 2;
    final center = Offset(size.width / 2, size.height / 2);

    for (var i = 0; i < 6; i++) {
      final angle = (math.pi / 3) * i - math.pi / 2;
      final point = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }

    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _HangmanPainter extends CustomPainter {
  const _HangmanPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(size.width * 0.1, size.height * 0.92),
      Offset(size.width * 0.72, size.height * 0.92),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.24, size.height * 0.92),
      Offset(size.width * 0.24, size.height * 0.12),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.24, size.height * 0.12),
      Offset(size.width * 0.62, size.height * 0.12),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.62, size.height * 0.12),
      Offset(size.width * 0.62, size.height * 0.22),
      paint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.62, size.height * 0.34),
      size.width * 0.1,
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.62, size.height * 0.44),
      Offset(size.width * 0.62, size.height * 0.67),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.62, size.height * 0.5),
      Offset(size.width * 0.47, size.height * 0.6),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.62, size.height * 0.5),
      Offset(size.width * 0.76, size.height * 0.6),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.62, size.height * 0.67),
      Offset(size.width * 0.48, size.height * 0.82),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.62, size.height * 0.67),
      Offset(size.width * 0.75, size.height * 0.82),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _HangmanPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
