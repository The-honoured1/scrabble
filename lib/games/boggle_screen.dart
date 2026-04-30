import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class BoggleScreen extends StatefulWidget {
  const BoggleScreen({super.key});

  @override
  State<BoggleScreen> createState() => _BoggleScreenState();
}

class _BoggleScreenState extends State<BoggleScreen> {
  static const int size = 4;
  final List<List<String>> _grid = List.generate(size, (_) => List.filled(size, ''));
  final List<String> _dictionary = [];
  final List<Point<int>> _selection = [];
  final Set<String> _found = {};
  int _seconds = 90;
  int _score = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _generateBoard();
    _loadDictionary();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_seconds > 0) {
        setState(() => _seconds -= 1);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _loadDictionary() async {
    try {
      final raw = await rootBundle.loadString('assets/words/dictionary.json');
      final words = (jsonDecode(raw) as List).cast<String>();
      setState(() {
        _dictionary.addAll(words.map((e) => e.toUpperCase()));
      });
    } catch (_) {
      setState(() {
        _dictionary.addAll(['TREE', 'TIME', 'NOTE', 'TONE', 'MAGIC', 'STONE', 'BELL', 'LIME']);
      });
    }
  }

  void _generateBoard() {
    const letters = 'EEEEEEEEEEEEAAAAAAAIIIIIIIIOOOOOOOO' 'NNNNNRRRRR' 'TTTTTLLLLSS' 'UUUU' 'GG' 'DD' 'CC' 'MM' 'BB' 'PP' 'FF' 'HH' 'VV' 'WW' 'YY' 'K' 'J' 'X' 'Q' 'Z';
    final rand = Random();
    for (var r = 0; r < size; r++) {
      for (var c = 0; c < size; c++) {
        _grid[r][c] = letters[rand.nextInt(letters.length)];
      }
    }
  }

  Point<int> _positionFrom(Offset localPosition, double tileSize) {
    final col = (localPosition.dx ~/ tileSize).clamp(0, size - 1);
    final row = (localPosition.dy ~/ tileSize).clamp(0, size - 1);
    return Point(row, col);
  }

  void _startDrag(Point<int> point) {
    setState(() {
      _selection.clear();
      _selection.add(point);
    });
  }

  void _updateDrag(Point<int> point) {
    if (_selection.isEmpty) return;
    final last = _selection.last;
    if ((point.x - last.x).abs() <= 1 && (point.y - last.y).abs() <= 1 && !_selection.contains(point)) {
      setState(() {
        _selection.add(point);
      });
    }
  }

  void _endDrag() {
    final word = _selection.map((p) => _grid[p.x][p.y]).join();
    if (word.length >= 3 && _dictionary.contains(word) && !_found.contains(word)) {
      setState(() {
        _found.add(word);
        _score += _scoreFor(word.length);
      });
    }
    setState(() {
      _selection.clear();
    });
  }

  int _scoreFor(int length) {
    if (length <= 4) return 1;
    if (length == 5) return 2;
    if (length == 6) return 3;
    if (length == 7) return 5;
    return 11;
  }

  bool _selected(int row, int col) => _selection.contains(Point(row, col));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Boggle'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).pop()),
        backgroundColor: AppTheme.background,
        foregroundColor: AppTheme.textPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Drag through adjacent tiles to form words.', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Time: $_seconds', style: Theme.of(context).textTheme.bodyLarge),
                Text('Score: $_score', style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
            const SizedBox(height: 18),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final tileSize = (constraints.maxWidth - 10) / size;
                  return GestureDetector(
                    onPanStart: (event) => _startDrag(_positionFrom(event.localPosition, tileSize)),
                    onPanUpdate: (event) => _updateDrag(_positionFrom(event.localPosition, tileSize)),
                    onPanEnd: (_) => _endDrag(),
                    child: Column(
                      children: List.generate(size, (row) {
                        return Row(
                          children: List.generate(size, (col) {
                            final selected = _selected(row, col);
                            return Container(
                              width: tileSize,
                              height: tileSize,
                              margin: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: selected ? AppTheme.green.withOpacity(0.4) : AppTheme.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppTheme.border),
                              ),
                              alignment: Alignment.center,
                              child: Text(_grid[row][col], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
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
            Text('Found words:', style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: _found.map((word) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(word, style: Theme.of(context).textTheme.bodyLarge),
                )).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
