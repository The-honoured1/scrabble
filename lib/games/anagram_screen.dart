import 'dart:convert';
import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class AnagramScreen extends StatefulWidget {
  const AnagramScreen({super.key});

  @override
  State<AnagramScreen> createState() => _AnagramScreenState();
}

class _AnagramScreenState extends State<AnagramScreen> {
  late ConfettiController _confetti;
  List<Map<String, String>> _problems = [];
  late Map<String, String> _active;
  List<String> _remaining = [];
  String _answer = '';
  int _score = 0;
  String _feedback = '';

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 1));
    _loadPuzzles();
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  Future<void> _loadPuzzles() async {
    final raw = await rootBundle.loadString('assets/puzzles/anagram.json');
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    _problems = (decoded['puzzles'] as List).cast<Map<String, dynamic>>().map((item) {
      return {
        'answer': (item['answer'] as String).toUpperCase(),
        'scramble': (item['scramble'] as String).toUpperCase(),
      };
    }).toList();
    setState(() {
      _active = _problems[DateTime.now().day % _problems.length];
      _remaining = _active['scramble']!.split('');
    });
  }

  void _tapLetter(int index) {
    setState(() {
      final letter = _remaining.removeAt(index);
      _answer += letter;
    });
  }

  void _removeLetter(int index) {
    setState(() {
      _remaining.add(_answer[index]);
      _answer = _answer.substring(0, index) + _answer.substring(index + 1);
    });
  }

  void _shuffle() {
    setState(() {
      _remaining.shuffle();
    });
  }

  void _hint() {
    if (_answer.isNotEmpty) return;
    final first = _active['answer']![0];
    setState(() {
      _answer = first;
      _remaining.remove(first);
      _score = max(0, _score - 1);
    });
  }

  void _submit() {
    if (_answer == _active['answer']) {
      setState(() {
        _feedback = 'Correct!';
        _score += 5;
      });
      _confetti.play();
    } else {
      setState(() {
        _feedback = 'Try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Anagram'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).pop()),
        backgroundColor: AppTheme.background,
        foregroundColor: AppTheme.textPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Unscramble the letters into the correct word.', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 20),
            Stack(
              alignment: Alignment.topCenter,
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: ConfettiWidget(
                    confettiController: _confetti,
                    blastDirectionality: BlastDirectionality.explosive,
                    shouldLoop: false,
                    colors: const [AppTheme.green, AppTheme.purple, AppTheme.yellow],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.border)),
                  child: Text(_answer, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 28, letterSpacing: 3)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List.generate(_remaining.length, (index) {
                return ActionChip(
                  label: Text(_remaining[index], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  onPressed: () => _tapLetter(index),
                  backgroundColor: AppTheme.surface,
                );
              }),
            ),
            const SizedBox(height: 16),
            if (_answer.isNotEmpty)
              Wrap(
                spacing: 10,
                children: List.generate(_answer.length, (index) {
                  return ActionChip(
                    label: Text(_answer[index], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    onPressed: () => _removeLetter(index),
                    backgroundColor: AppTheme.yellow.withValues(alpha: 0.2),
                  );
                }),
              ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(child: ElevatedButton(onPressed: _shuffle, child: const Text('Shuffle'))),
                const SizedBox(width: 10),
                Expanded(child: ElevatedButton(onPressed: _hint, child: const Text('Hint'))),
              ],
            ),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _submit, child: const Text('Submit')),
            const SizedBox(height: 12),
            Text(_feedback, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.textSecondary)),
            const SizedBox(height: 12),
            Text('Score: $_score', style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}
