import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class WordSearchScreen extends StatefulWidget {
  const WordSearchScreen({super.key});

  @override
  State<WordSearchScreen> createState() => _WordSearchScreenState();
}

class _WordSearchScreenState extends State<WordSearchScreen> {
  static const int gridSize = 12;
  final List<String> _words = ['PUZZLE', 'SEARCH', 'LETTER', 'GRID', 'WORDS', 'DAILY', 'HIDDEN', 'MAGIC'];
  late List<List<String>> _grid;
  final Set<String> _found = {};
  final List<Point<int>> _selection = [];
  bool _completed = false;
  int _seconds = 0;
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _grid = List.generate(gridSize, (_) => List.generate(gridSize, (_) => ''));
    _generatePuzzle();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _seconds += 1;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _generatePuzzle() {
    final rand = Random(123);
    _grid = List.generate(gridSize, (_) => List.generate(gridSize, (_) => ''));
    for (final word in _words) {
      final placed = _placeWord(rand, word);
      if (!placed) {
        _words.shuffle();
      }
    }
    const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    for (var r = 0; r < gridSize; r++) {
      for (var c = 0; c < gridSize; c++) {
        if (_grid[r][c].isEmpty) {
          _grid[r][c] = letters[rand.nextInt(letters.length)];
        }
      }
    }
  }

  bool _placeWord(Random rand, String word) {
    final directions = [Point(1, 0), Point(0, 1), Point(1, 1), Point(-1, 1)];
    for (var attempt = 0; attempt < 100; attempt++) {
      final dir = directions[rand.nextInt(directions.length)];
      final row = rand.nextInt(gridSize);
      final col = rand.nextInt(gridSize);
      final endRow = row + dir.x * (word.length - 1);
      final endCol = col + dir.y * (word.length - 1);
      if (endRow < 0 || endRow >= gridSize || endCol < 0 || endCol >= gridSize) continue;
      var valid = true;
      for (var i = 0; i < word.length; i++) {
        final r = row + dir.x * i;
        final c = col + dir.y * i;
        if (_grid[r][c].isNotEmpty && _grid[r][c] != word[i]) {
          valid = false;
          break;
        }
      }
      if (!valid) continue;
      for (var i = 0; i < word.length; i++) {
        final r = row + dir.x * i;
        final c = col + dir.y * i;
        _grid[r][c] = word[i];
      }
      return true;
    }
    return false;
  }

  Point<int> _positionFromOffset(Offset localPosition, double tileSize) {
    final col = (localPosition.dx ~/ tileSize).clamp(0, gridSize - 1);
    final row = (localPosition.dy ~/ tileSize).clamp(0, gridSize - 1);
    return Point(row, col);
  }

  void _startSelection(Point<int> point) {
    setState(() {
      _selection.clear();
      _selection.add(point);
    });
  }

  void _updateSelection(Point<int> point) {
    if (_selection.isEmpty) return;
    final last = _selection.last;
    if ((point.x - last.x).abs() <= 1 && (point.y - last.y).abs() <= 1) {
      if (_selection.isEmpty || _selection.last != point) {
        setState(() {
          _selection.add(point);
        });
      }
    }
  }

  void _finishSelection() {
    final candidate = _selection.map((p) => _grid[p.x][p.y]).join();
    if (_words.contains(candidate) && !_found.contains(candidate)) {
      setState(() {
        _found.add(candidate);
        if (_found.length == _words.length) {
          _completed = true;
        }
      });
    }
    setState(() {
      _selection.clear();
    });
  }

  bool _isSelected(int row, int col) {
    return _selection.contains(Point(row, col));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Word Search'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).pop()),
        backgroundColor: AppTheme.background,
        foregroundColor: AppTheme.textPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Find all hidden words in the letter grid.', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Time: ${_seconds}s', style: Theme.of(context).textTheme.bodyLarge),
                Text('${_found.length}/${_words.length} found', style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final tileSize = constraints.maxWidth / gridSize;
                  return GestureDetector(
                    onPanStart: (details) => _startSelection(_positionFromOffset(details.localPosition, tileSize)),
                    onPanUpdate: (details) => _updateSelection(_positionFromOffset(details.localPosition, tileSize)),
                    onPanEnd: (_) => _finishSelection(),
                    child: Column(
                      children: List.generate(gridSize, (row) {
                        return Row(
                          children: List.generate(gridSize, (col) {
                            final selected = _isSelected(row, col);
                            return Container(
                              width: tileSize,
                              height: tileSize,
                              margin: const EdgeInsets.all(1),
                              decoration: BoxDecoration(
                                color: selected ? AppTheme.yellow.withValues(alpha: 0.4) : AppTheme.surface,
                                border: Border.all(color: AppTheme.border),
                              ),
                              alignment: Alignment.center,
                              child: Text(_grid[row][col], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                            );
                          }),
                        );
                      }),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _words.map((word) {
                return Chip(
                  label: Text(word, style: TextStyle(color: _found.contains(word) ? Colors.white : AppTheme.textPrimary)),
                  backgroundColor: _found.contains(word) ? AppTheme.green : AppTheme.surface,
                );
              }).toList(),
            ),
            if (_completed)
              Padding(
                padding: const EdgeInsets.only(top: 14),
                child: Text('All words found! Nice work.', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.green)),
              ),
          ],
        ),
      ),
    );
  }
}
