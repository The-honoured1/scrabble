import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class CrosswordScreen extends StatefulWidget {
  const CrosswordScreen({super.key});

  @override
  State<CrosswordScreen> createState() => _CrosswordScreenState();
}

class _CrosswordScreenState extends State<CrosswordScreen> {
  final List<List<String?>> _grid = List.generate(5, (_) => List.generate(5, (_) => ''));
  final List<List<bool>> _black = List.generate(5, (_) => List.generate(5, (_) => false));
  List<Map<String, dynamic>> _across = [];
  List<Map<String, dynamic>> _down = [];
  int _selectedRow = 0;
  int _selectedCol = 0;
  bool _acrossMode = true;
  String _message = '';

  @override
  void initState() {
    super.initState();
    _loadPuzzle();
  }

  Future<void> _loadPuzzle() async {
    final raw = await rootBundle.loadString('assets/puzzles/crossword.json');
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final puzzles = (decoded['puzzles'] as List).cast<Map<String, dynamic>>();
    final index = DateTime.now().day % puzzles.length;
    final puzzle = puzzles[index];
    final gridData = (puzzle['grid'] as List).cast<List>().map((row) => row.cast<String?>()).toList();
    setState(() {
      for (var r = 0; r < 5; r++) {
        for (var c = 0; c < 5; c++) {
          final value = gridData[r][c];
          _black[r][c] = value == null;
          _grid[r][c] = value == '' ? '' : value;
        }
      }
      _across = (puzzle['clues']['across'] as List).cast<Map<String, dynamic>>();
      _down = (puzzle['clues']['down'] as List).cast<Map<String, dynamic>>();
      _selectedRow = 0;
      _selectedCol = 0;
      _acrossMode = true;
    });
  }

  bool _isValidCell(int row, int col) => row >= 0 && row < 5 && col >= 0 && col < 5 && !_black[row][col];

  void _selectCell(int row, int col) {
    if (!_isValidCell(row, col)) return;
    setState(() {
      if (_selectedRow == row && _selectedCol == col) {
        _acrossMode = !_acrossMode;
      }
      _selectedRow = row;
      _selectedCol = col;
    });
  }

  void _updateLetter(String letter) {
    if (!_isValidCell(_selectedRow, _selectedCol)) return;
    setState(() {
      _grid[_selectedRow][_selectedCol] = letter.toUpperCase();
      _message = '';
      _moveCursor();
    });
  }

  void _moveCursor() {
    if (_acrossMode) {
      final nextCol = _selectedCol + 1;
      if (_isValidCell(_selectedRow, nextCol)) {
        _selectedCol = nextCol;
      }
    } else {
      final nextRow = _selectedRow + 1;
      if (_isValidCell(nextRow, _selectedCol)) {
        _selectedRow = nextRow;
      }
    }
  }

  void _checkAnswers() {
    final raw = rootBundle.loadString('assets/puzzles/crossword.json');
    raw.then((json) {
      final decoded = jsonDecode(json) as Map<String, dynamic>;
      final puzzles = (decoded['puzzles'] as List).cast<Map<String, dynamic>>();
      final index = DateTime.now().day % puzzles.length;
      final solution = puzzles[index];
      final answerGrid = (solution['grid'] as List).cast<List>().map((row) => row.cast<String?>()).toList();
      final errors = <String>[];
      for (var r = 0; r < 5; r++) {
        for (var c = 0; c < 5; c++) {
          if (answerGrid[r][c] != null && answerGrid[r][c] != _grid[r][c]) {
            errors.add('cell $r,$c');
          }
        }
      }
      setState(() {
        _message = errors.isEmpty ? 'Nice work!' : 'Keep going. Some letters are off.';
      });
    });
  }

  void _reveal() {
    final raw = rootBundle.loadString('assets/puzzles/crossword.json');
    raw.then((json) {
      final decoded = jsonDecode(json) as Map<String, dynamic>;
      final puzzles = (decoded['puzzles'] as List).cast<Map<String, dynamic>>();
      final index = DateTime.now().day % puzzles.length;
      final solution = puzzles[index];
      final answerGrid = (solution['grid'] as List).cast<List>().map((row) => row.cast<String?>()).toList();
      setState(() {
        for (var r = 0; r < 5; r++) {
          for (var c = 0; c < 5; c++) {
            if (!_black[r][c]) {
              _grid[r][c] = answerGrid[r][c] ?? '';
            }
          }
        }
        _message = 'Revealed answers.';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mini Crossword'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).pop()),
        backgroundColor: AppTheme.background,
        foregroundColor: AppTheme.textPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Tap a square to fill it, then use the on-screen keyboard.', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: BoxDecoration(border: Border.all(color: AppTheme.border), borderRadius: BorderRadius.circular(14)),
                child: Column(
                  children: List.generate(5, (row) {
                    return Expanded(
                      child: Row(
                        children: List.generate(5, (col) {
                          final isBlack = _black[row][col];
                          final selected = row == _selectedRow && col == _selectedCol;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () => _selectCell(row, col),
                              child: Container(
                                decoration: BoxDecoration(
                                    color: isBlack ? AppTheme.textPrimary : selected ? AppTheme.purple.withValues(alpha: 0.15) : AppTheme.surface,
                                  border: Border.all(color: AppTheme.border, width: 1),
                                ),
                                alignment: Alignment.center,
                                child: isBlack
                                    ? const SizedBox.shrink()
                                    : Text(_grid[row][col] ?? '', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                              ),
                            ),
                          );
                        }),
                      ),
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(_message, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.textSecondary)),
            const SizedBox(height: 12),
            Expanded(
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('').map((letter) {
                  return SizedBox(
                    width: 34,
                    height: 44,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.surface,
                        foregroundColor: AppTheme.textPrimary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => _updateLetter(letter),
                      child: Text(letter, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: ElevatedButton(onPressed: _checkAnswers, child: const Text('Check'))),
                const SizedBox(width: 10),
                Expanded(child: ElevatedButton(onPressed: _reveal, child: const Text('Reveal'))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
