import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';

enum LetterState { empty, filled, correct, present, absent }

class WordleScreen extends StatefulWidget {
  const WordleScreen({super.key});

  @override
  State<WordleScreen> createState() => _WordleScreenState();
}

class _WordleScreenState extends State<WordleScreen> with TickerProviderStateMixin {
  late final AnimationController _flipController;
  late final AnimationController _shakeController;
  List<String> _wordList = [];
  String _target = 'PRESS';
  int _currentRow = 0;
  int _currentCol = 0;
  final List<List<String>> _board = List.generate(6, (_) => List.filled(5, ''));
  final List<List<LetterState>> _tileStates = List.generate(6, (_) => List.filled(5, LetterState.empty));
  String _message = '';
  bool _won = false;
  final List<String> _keyboard = ['QWERTYUIOP', 'ASDFGHJKL', 'ZXCVBNM'];
  int _revealCol = -1;
  int _revealRow = -1;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(vsync: this, duration: const Duration(milliseconds: 260));
    _shakeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _loadWords();
  }

  @override
  void dispose() {
    _flipController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  Future<void> _loadWords() async {
    final raw = await rootBundle.loadString('assets/words/wordle_words.json');
    final words = (jsonDecode(raw) as List).cast<String>().map((e) => e.toUpperCase()).where((w) => w.length == 5).toList();
    setState(() {
      _wordList = words;
      final index = DateTime.now().day % (_wordList.isEmpty ? 1 : _wordList.length);
      _target = _wordList.isNotEmpty ? _wordList[index] : 'PRESS';
    });
  }

  void _appendLetter(String letter) {
    if (_won || _currentRow >= 6 || _currentCol >= 5) return;
    setState(() {
      _board[_currentRow][_currentCol] = letter;
      _currentCol += 1;
    });
  }

  void _deleteLetter() {
    if (_won || _currentCol == 0) return;
    setState(() {
      _currentCol -= 1;
      _board[_currentRow][_currentCol] = '';
    });
  }

  Future<void> _submitGuess() async {
    if (_currentCol != 5) {
      _showInvalid('Not enough letters');
      return;
    }
    final guess = _board[_currentRow].join();
    if (!_wordList.contains(guess)) {
      _showInvalid('Not in word list');
      return;
    }
    _revealRow = _currentRow;
    for (var i = 0; i < 5; i++) {
      _revealCol = i;
      await _flipController.forward(from: 0);
      final letter = guess[i];
      if (letter == _target[i]) {
        _tileStates[_currentRow][i] = LetterState.correct;
      } else if (_target.contains(letter)) {
        _tileStates[_currentRow][i] = LetterState.present;
      } else {
        _tileStates[_currentRow][i] = LetterState.absent;
      }
      setState(() {});
      await Future.delayed(const Duration(milliseconds: 120));
    }
    _revealCol = -1;
    if (guess == _target) {
      setState(() {
        _won = true;
        _message = 'Great! You got it.';
      });
      Provider.of<AppState>(context, listen: false).markComplete('wordle');
      _showResultDialog(true);
      return;
    }
    if (_currentRow == 5) {
      _showResultDialog(false);
      return;
    }
    setState(() {
      _currentRow += 1;
      _currentCol = 0;
      _message = '';
    });
  }

  void _showInvalid(String text) {
    setState(() {
      _message = text;
    });
    _shakeController.forward(from: 0);
  }

  Future<void> _showResultDialog(bool won) async {
    final title = won ? 'You won!' : 'Game over';
    final content = won ? 'Correct answer: $_target' : 'The word was $_target';
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () async {
                final shareText = _board
                    .where((row) => row.any((c) => c.isNotEmpty))
                    .map((row) => row.map((letter) {
                          final state = _tileStates[_board.indexOf(row)][row.indexOf(letter)];
                          switch (state) {
                            case LetterState.correct:
                              return '🟩';
                            case LetterState.present:
                              return '🟨';
                            case LetterState.absent:
                              return '⬛';
                            default:
                              return '⬜';
                          }
                        }).join())
                    .join('\n');
                await Clipboard.setData(ClipboardData(text: shareText));
                if (mounted) Navigator.of(context).pop();
              },
              child: const Text('Share'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Color _tileColor(LetterState state) {
    switch (state) {
      case LetterState.correct:
        return AppTheme.green;
      case LetterState.present:
        return const Color(0xFFE9A84C);
      case LetterState.absent:
        return const Color(0xFF787878);
      default:
        return AppTheme.surface;
    }
  }

  Color _tileBorder(LetterState state) {
    switch (state) {
      case LetterState.empty:
        return const Color(0xFFBDBDBD);
      default:
        return Colors.transparent;
    }
  }

  Widget _buildTile(int row, int col) {
    final letter = _board[row][col];
    final state = _tileStates[row][col];
    final revealing = row == _revealRow && col == _revealCol;
    final animation = revealing ? _flipController : AlwaysStoppedAnimation(1.0);
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final value = animation.value;
        final angle = revealing ? pi * value : 0.0;
        final transform = Matrix4.identity()..rotateY(angle);
        return Transform(
          transform: transform,
          alignment: Alignment.center,
          child: child,
        );
      },
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: state == LetterState.empty ? AppTheme.surface : _tileColor(state),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _tileBorder(state), width: 1.5),
        ),
        child: Text(
          letter,
          style: TextStyle(
            color: state == LetterState.empty ? AppTheme.textPrimary : Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 22,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rowWidgets = List.generate(
      6,
      (row) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int col = 0; col < 5; col++) ...[
              SizedBox(width: 50, height: 60, child: _buildTile(row, col)),
              if (col < 4) const SizedBox(width: 8),
            ]
          ],
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wordle'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).pop()),
        backgroundColor: AppTheme.background,
        foregroundColor: AppTheme.textPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Guess the 5-letter word in 6 tries', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            if (_message.isNotEmpty)
              AnimatedBuilder(
                animation: _shakeController,
                builder: (context, child) {
                  final offset = sin(_shakeController.value * pi * 4) * 10;
                  return Transform.translate(offset: Offset(offset, 0), child: child);
                },
                child: Text(_message, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.red)),
              ),
            const SizedBox(height: 14),
            Column(children: rowWidgets),
            const Spacer(),
            ..._keyboard.map((row) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: row.split('').map((letter) {
                    final state = _tileStates.expand((r) => r).firstWhere(
                          (s) => _board.any((r) => r.contains(letter)) && _board[_tileStates.indexWhere((r) => r.contains(letter))].contains(letter),
                          orElse: () => LetterState.empty,
                        );
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: SizedBox(
                        width: 34,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: state == LetterState.empty ? AppTheme.surface : _tileColor(state),
                            foregroundColor: state == LetterState.empty ? AppTheme.textPrimary : Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: EdgeInsets.zero,
                            elevation: 0,
                          ),
                          onPressed: () => _appendLetter(letter),
                          child: Text(letter, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                        ),
                      ),
                    );
                  }).toList()
                    ..addAll([
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: SizedBox(
                          width: 64,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.surface, foregroundColor: AppTheme.textPrimary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), elevation: 0),
                            onPressed: _deleteLetter,
                            child: const Text('Delete', style: TextStyle(fontSize: 12)),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: SizedBox(
                          width: 64,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.green, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), elevation: 0),
                            onPressed: _submitGuess,
                            child: const Text('Enter', style: TextStyle(fontSize: 12)),
                          ),
                        ),
                      ),
                    ]),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
