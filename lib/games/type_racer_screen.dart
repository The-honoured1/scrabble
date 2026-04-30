import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class TypeRacerScreen extends StatefulWidget {
  const TypeRacerScreen({super.key});

  @override
  State<TypeRacerScreen> createState() => _TypeRacerScreenState();
}

class _TypeRacerScreenState extends State<TypeRacerScreen> {
  final List<String> _passages = [
    'The quick brown fox jumps over the lazy dog.',
    'A quiet morning in the library held a secret rhythm of turning pages.',
    'Sunlight glimmered through the window as the city slowly woke.',
  ];
  late String _passage;
  final TextEditingController _controller = TextEditingController();
  int _seconds = 60;
  late Timer _timer;
  bool _running = false;
  int _mistakes = 0;

  @override
  void initState() {
    super.initState();
    _passage = _passages[DateTime.now().day % _passages.length];
  }

  void _startTimer() {
    if (_running) return;
    _running = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_seconds > 0) {
        setState(() => _seconds -= 1);
      } else {
        timer.cancel();
        _running = false;
      }
    });
  }

  void _onChanged(String text) {
    if (!_running) {
      _startTimer();
    }
    final target = _passage.substring(0, min(text.length, _passage.length));
    if (text != target) {
      setState(() => _mistakes = _mistakes + 1);
    }
  }

  int get _correctWords {
    final typed = _controller.text.trim();
    final words = typed.split(RegExp(r'\s+')).where((word) => word.isNotEmpty).toList();
    final passageWords = _passage.split(RegExp(r'\s+'));
    var count = 0;
    for (var i = 0; i < min(words.length, passageWords.length); i++) {
      if (words[i] == passageWords[i]) count += 1;
    }
    return count;
  }

  double get _wpm {
    final minutes = (60 - _seconds) / 60;
    if (minutes <= 0) return 0;
    return _correctWords / minutes;
  }

  double get _accuracy {
    final typed = _controller.text.replaceAll(RegExp(r'\s+'), '');
    if (typed.isEmpty) return 100;
    final correct = _passage.replaceAll(RegExp(r'\s+'), '');
    final matched = List.generate(min(typed.length, correct.length), (i) => typed[i] == correct[i] ? 1 : 0).fold(0, (sum, v) => sum + v);
    return matched / typed.length * 100;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Type Racer'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).pop()),
        backgroundColor: AppTheme.background,
        foregroundColor: AppTheme.textPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Race the clock. Type as fast and clean as you can.', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.border)),
              child: Text(_passage, style: Theme.of(context).textTheme.bodyLarge),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              minLines: 3,
              maxLines: 5,
              onChanged: _onChanged,
              decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Start typing here…'),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Time: $_seconds', style: Theme.of(context).textTheme.bodyLarge),
                Text('WPM: ${_wpm.toStringAsFixed(0)}', style: Theme.of(context).textTheme.bodyLarge),
                Text('Acc: ${_accuracy.toStringAsFixed(0)}%', style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
            const SizedBox(height: 18),
            if (!_running && _seconds == 0)
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _seconds = 60;
                    _controller.clear();
                    _mistakes = 0;
                    _running = false;
                  });
                },
                child: const Text('Restart'),
              ),
          ],
        ),
      ),
    );
  }
}
