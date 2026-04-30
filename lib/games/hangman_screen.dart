import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class HangmanScreen extends StatefulWidget {
  const HangmanScreen({super.key});

  @override
  State<HangmanScreen> createState() => _HangmanScreenState();
}

class _HangmanScreenState extends State<HangmanScreen> {
  final String _word = 'ANIMAL';
  final String _hint = 'Animal';
  final Set<String> _guessed = {};
  int _wrong = 0;
  bool _finished = false;
  String _resultMessage = '';

  void _guess(String letter) {
    if (_finished) return;
    if (_guessed.contains(letter)) return;
    setState(() {
      _guessed.add(letter);
      if (!_word.contains(letter)) {
        _wrong += 1;
      }
      if (_wrong >= 6) {
        _finished = true;
        _resultMessage = 'You lost. $_word';
      } else if (_word.split('').every((c) => _guessed.contains(c))) {
        _finished = true;
        _resultMessage = 'You won!';
      }
    });
  }

  Color _letterColor(String letter) {
    if (_guessed.contains(letter)) {
      return _word.contains(letter) ? AppTheme.green : Colors.red.shade300;
    }
    return AppTheme.textPrimary;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hangman'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).pop()),
        backgroundColor: AppTheme.background,
        foregroundColor: AppTheme.textPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Guess the word before the figure is complete.', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Text('Hint: $_hint', style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 20),
            SizedBox(
              height: 220,
              child: CustomPaint(
                painter: _HangmanPainter(parts: _wrong),
                child: const SizedBox.expand(),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _word.split('').map((letter) {
                final visible = _guessed.contains(letter) || _finished;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AppTheme.border, width: 2))),
                  child: Text(visible ? letter : '_', style: const TextStyle(fontSize: 24, letterSpacing: 3, fontWeight: FontWeight.w700)),
                );
              }).toList(),
            ),
            const SizedBox(height: 22),
            Expanded(
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('').map((letter) {
                  return SizedBox(
                    width: 34,
                    height: 42,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.surface,
                        foregroundColor: _letterColor(letter),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: _guessed.contains(letter) || _finished ? null : () => _guess(letter),
                      child: Text(letter, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 10),
            if (_finished)
              Text(_resultMessage, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: _resultMessage.contains('won') ? AppTheme.green : Colors.red)),
          ],
        ),
      ),
    );
  }
}

class _HangmanPainter extends CustomPainter {
  final int parts;

  _HangmanPainter({required this.parts});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.textPrimary
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;
    final base = Offset(size.width * 0.1, size.height * 0.95);
    final top = Offset(size.width * 0.4, size.height * 0.95);
    canvas.drawLine(base, top, paint);
    canvas.drawLine(top, Offset(top.dx, size.height * 0.1), paint);
    canvas.drawLine(Offset(top.dx, size.height * 0.1), Offset(size.width * 0.7, size.height * 0.1), paint);
    canvas.drawLine(Offset(size.width * 0.7, size.height * 0.1), Offset(size.width * 0.7, size.height * 0.18), paint);
    if (parts > 0) {
      canvas.drawCircle(Offset(size.width * 0.7, size.height * 0.27), 24, paint);
    }
    if (parts > 1) {
      canvas.drawLine(Offset(size.width * 0.7, size.height * 0.31), Offset(size.width * 0.7, size.height * 0.55), paint);
    }
    if (parts > 2) {
      canvas.drawLine(Offset(size.width * 0.7, size.height * 0.36), Offset(size.width * 0.62, size.height * 0.45), paint);
    }
    if (parts > 3) {
      canvas.drawLine(Offset(size.width * 0.7, size.height * 0.36), Offset(size.width * 0.78, size.height * 0.45), paint);
    }
    if (parts > 4) {
      canvas.drawLine(Offset(size.width * 0.7, size.height * 0.55), Offset(size.width * 0.62, size.height * 0.72), paint);
    }
    if (parts > 5) {
      canvas.drawLine(Offset(size.width * 0.7, size.height * 0.55), Offset(size.width * 0.78, size.height * 0.72), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _HangmanPainter oldDelegate) => oldDelegate.parts != parts;
}
