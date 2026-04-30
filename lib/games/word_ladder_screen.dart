import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class WordLadderScreen extends StatefulWidget {
  const WordLadderScreen({super.key});

  @override
  State<WordLadderScreen> createState() => _WordLadderScreenState();
}

class _WordLadderScreenState extends State<WordLadderScreen> {
  final List<Map<String, String>> _puzzles = [
    {'start': 'COLD', 'target': 'WARM'},
    {'start': 'HEAD', 'target': 'TAIL'},
    {'start': 'FIRE', 'target': 'WATER'},
    {'start': 'SUMM', 'target': 'FALL'},
    {'start': 'PORT', 'target': 'STAR'},
  ];
  late final Map<String, String> _active;
  late String _current;
  final TextEditingController _controller = TextEditingController();
  final List<String> _path = [];
  String _feedback = '';

  @override
  void initState() {
    super.initState();
    _active = _puzzles[DateTime.now().day % _puzzles.length];
    _current = _active['start']!;
    _path.add(_current);
  }

  bool _isOneLetterDifferent(String a, String b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) diff += 1;
      if (diff > 1) return false;
    }
    return diff == 1;
  }

  void _submitStep() {
    final attempt = _controller.text.toUpperCase();
    if (!_isOneLetterDifferent(_current, attempt)) {
      setState(() => _feedback = 'Change exactly one letter.');
      return;
    }
    setState(() {
      _current = attempt;
      _path.add(_current);
      _controller.clear();
      if (_current == _active['target']) {
        _feedback = 'Done in ${_path.length - 1} steps!';
      } else {
        _feedback = 'Good step.';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Word Ladder'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).pop()),
        backgroundColor: AppTheme.background,
        foregroundColor: AppTheme.textPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Change one letter at a time to reach the target.', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 14),
            Text('Start: ${_active['start']}  →  Target: ${_active['target']}', style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                border: Border.all(color: AppTheme.border),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(_current, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 32, letterSpacing: 4)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Enter next word'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _submitStep, child: const Text('Submit step')),
            const SizedBox(height: 12),
            Text(_feedback, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.textSecondary)),
            const SizedBox(height: 14),
            const Text('Path so far:', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: _path.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(_path[index], style: Theme.of(context).textTheme.bodyLarge),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
