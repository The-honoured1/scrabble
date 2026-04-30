import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class SpellingBeeScreen extends StatefulWidget {
  const SpellingBeeScreen({super.key});

  @override
  State<SpellingBeeScreen> createState() => _SpellingBeeScreenState();
}

class _SpellingBeeScreenState extends State<SpellingBeeScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _dictionary = [];
  final List<Map<String, dynamic>> _puzzles = [
    {
      'center': 'E',
      'letters': ['E', 'A', 'R', 'T', 'H', 'S', 'N'],
      'answerCount': 28,
    },
    {
      'center': 'L',
      'letters': ['L', 'I', 'N', 'E', 'S', 'T', 'R'],
      'answerCount': 24,
    },
    {
      'center': 'O',
      'letters': ['O', 'C', 'A', 'T', 'N', 'E', 'R'],
      'answerCount': 22,
    },
    {
      'center': 'P',
      'letters': ['P', 'A', 'R', 'T', 'E', 'N', 'S'],
      'answerCount': 26,
    },
    {
      'center': 'M',
      'letters': ['M', 'I', 'N', 'D', 'E', 'R', 'S'],
      'answerCount': 20,
    },
  ];

  late final Map<String, dynamic> _activePuzzle;
  String _message = '';
  final List<String> _found = [];

  @override
  void initState() {
    super.initState();
    _activePuzzle = _puzzles[DateTime.now().day % _puzzles.length];
    _loadDictionary();
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
        _dictionary.addAll(['EARTH', 'HEART', 'RATEN', 'START', 'ANTS', 'NEARS', 'STRAND', 'MASTER', 'PRESENT', 'PAINTER', 'MINDS', 'TIMES']);
      });
    }
  }

  void _appendLetter(String letter) {
    setState(() {
      _controller.text += letter;
    });
  }

  void _deleteLetter() {
    if (_controller.text.isEmpty) return;
    setState(() {
      _controller.text = _controller.text.substring(0, _controller.text.length - 1);
    });
  }

  void _shuffleLetters() {
    final letters = List<String>.from(_activePuzzle['letters'] as List<String>);
    letters.shuffle();
    setState(() {
      _activePuzzle['letters'] = letters;
    });
  }

  void _submitWord() {
    final word = _controller.text.toUpperCase();
    final center = _activePuzzle['center'] as String;
    final letters = (_activePuzzle['letters'] as List<String>).toSet();
    if (word.length < 4) {
      setState(() => _message = 'Try a longer word.');
      return;
    }
    if (!word.contains(center)) {
      setState(() => _message = 'Every word needs the center letter.');
      return;
    }
    if (word.split('').any((letter) => !letters.contains(letter))) {
      setState(() => _message = 'Use only the letters shown.');
      return;
    }
    if (!_dictionary.contains(word)) {
      setState(() => _message = 'Not a valid word.');
      return;
    }
    if (_found.contains(word)) {
      setState(() => _message = 'Already found that word.');
      return;
    }
    setState(() {
      _found.add(word);
      _message = 'Nice!';
      _controller.clear();
    });
  }

  String _progressLabel() {
    final count = _found.length;
    if (count >= 24) return 'Amazing';
    if (count >= 20) return 'Great';
    if (count >= 16) return 'Solid';
    if (count >= 12) return 'Good';
    if (count >= 8) return 'Moving Up';
    if (count >= 4) return 'Good Start';
    return 'Beginner';
  }

  @override
  Widget build(BuildContext context) {
    final letters = List<String>.from(_activePuzzle['letters'] as List<String>);
    final center = _activePuzzle['center'] as String;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spelling Bee'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).pop()),
        backgroundColor: AppTheme.background,
        foregroundColor: AppTheme.textPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Make words from 7 letters. Use the center letter every time.', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            Center(
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 12,
                children: letters.map((letter) {
                  final isCenter = letter == center;
                  return GestureDetector(
                    onTap: () => _appendLetter(letter),
                    child: Container(
                      width: isCenter ? 72 : 60,
                      height: isCenter ? 72 : 60,
                      decoration: BoxDecoration(
                        color: isCenter ? AppTheme.green : AppTheme.surface,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppTheme.border),
                      ),
                      alignment: Alignment.center,
                      child: Text(letter, style: TextStyle(fontSize: isCenter ? 28 : 22, fontWeight: FontWeight.w700, color: isCenter ? Colors.white : AppTheme.textPrimary)),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              readOnly: true,
              decoration: InputDecoration(
                border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(14))),
                hintText: 'Tap letters to build a word',
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(icon: const Icon(Icons.shuffle), onPressed: _shuffleLetters),
                    IconButton(icon: const Icon(Icons.backspace), onPressed: _deleteLetter),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(onPressed: _submitWord, child: const Text('Submit')), 
            const SizedBox(height: 8),
            Text(_message, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: _message == 'Nice!' ? AppTheme.green : AppTheme.textSecondary)),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${_found.length}/${_activePuzzle['answerCount']}', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 20)),
                Text(_progressLabel(), style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.textSecondary)),
              ],
            ),
            const SizedBox(height: 12),
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
