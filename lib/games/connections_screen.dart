import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class ConnectionsScreen extends StatefulWidget {
  const ConnectionsScreen({super.key});

  @override
  State<ConnectionsScreen> createState() => _ConnectionsScreenState();
}

class _ConnectionsScreenState extends State<ConnectionsScreen> with TickerProviderStateMixin {
  List<String> _tiles = [];
  List<List<String>> _groups = [];
  List<String> _groupNames = [];
  List<bool> _selected = [];
  List<bool> _completedGroups = [];
  int _lives = 4;
  String _message = '';
  int _puzzleIndex = 0;
  late final AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    _loadPuzzle();
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  Future<void> _loadPuzzle() async {
    final raw = await rootBundle.loadString('assets/puzzles/connections.json');
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final puzzles = (decoded['puzzles'] as List).cast<Map<String, dynamic>>();
    _puzzleIndex = DateTime.now().day % puzzles.length;
    final puzzle = puzzles[_puzzleIndex];
    final words = (puzzle['words'] as List).cast<String>().map((e) => e.toUpperCase()).toList();
    final groups = (puzzle['groups'] as List).cast<Map<String, dynamic>>();
    setState(() {
      _tiles = words;
      _groups = groups.map((group) => (group['words'] as List).cast<String>().map((e) => e.toUpperCase()).toList()).toList();
      _groupNames = groups.map((group) => group['name'] as String).toList();
      _selected = List.filled(_tiles.length, false);
      _completedGroups = List.filled(_groups.length, false);
      _message = '';
    });
  }

  void _toggleTile(int index) {
    if (_selected.where((value) => value).length == 4 && !_selected[index]) return;
    setState(() {
      _selected[index] = !_selected[index];
      _message = '';
    });
  }

  void _submitGroup() {
    final selectedWords = [for (var i = 0; i < _tiles.length; i++) if (_selected[i]) _tiles[i]];
    if (selectedWords.length != 4) {
      setState(() {
        _message = 'Select 4 words to submit.';
      });
      return;
    }
    final selectedSet = selectedWords.toSet();
    final matchIndex = _groups.indexWhere((group) {
      return group.toSet().containsAll(selectedSet) && selectedSet.containsAll(group);
    });
    if (matchIndex >= 0 && !_completedGroups[matchIndex]) {
      setState(() {
        _completedGroups[matchIndex] = true;
        _selected = List.filled(_tiles.length, false);
        _message = 'Nice! ${_groupNames[matchIndex]} found.';
      });
    } else {
      _shakeController.forward(from: 0);
      setState(() {
        _lives -= 1;
        _message = 'Not quite. Try another group.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connections'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).pop()),
        backgroundColor: AppTheme.background,
        foregroundColor: AppTheme.textPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Group 16 words into 4 hidden categories.', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Text('Lives: ${'● ' * _lives}${'○ ' * (4 - _lives)}', style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 14),
            AnimatedBuilder(
              animation: _shakeController,
              builder: (context, child) {
                final offset = sin(_shakeController.value * pi * 4) * 12;
                return Transform.translate(offset: Offset(offset, 0), child: child);
              },
              child: Text(_message, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: _message.contains('Not quite') ? Colors.red : AppTheme.textSecondary)),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.zero,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 2.5),
                itemCount: _tiles.length,
                itemBuilder: (context, index) {
                  final selected = _selected[index];
                  return GestureDetector(
                    onTap: () => _toggleTile(index),
                    child: Container(
                      decoration: BoxDecoration(
                        color: selected ? AppTheme.purple.withOpacity(0.14) : AppTheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: selected ? AppTheme.purple : AppTheme.border),
                      ),
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(_tiles[index], style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700)),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _submitGroup, child: const Text('Submit group')),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List.generate(_groups.length, (index) {
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                  decoration: BoxDecoration(
                    color: _completedGroups[index] ? AppTheme.green.withOpacity(0.16) : AppTheme.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _completedGroups[index] ? AppTheme.green : AppTheme.border),
                  ),
                  child: Text(_completedGroups[index] ? _groupNames[index] : '????', style: Theme.of(context).textTheme.bodyMedium),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
