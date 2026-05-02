import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/wordie_game.dart';
import '../theme/wordie_theme.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({required this.game, required this.totalGames, super.key});

  final WordieGame game;
  final int totalGames;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: Text(game.title),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: game.color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  game.mode == WordieMode.daily ? 'Daily' : 'Unlimited',
                  style: Theme.of(
                    context,
                  ).textTheme.labelMedium?.copyWith(color: game.color),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _instructionFor(game.id),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 6),
            Text(
              '${game.id.index + 1} of $totalGames',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: WordieTheme.card,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: WordieTheme.border),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _GameBody(game: game),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _instructionFor(WordieGameId id) {
    return switch (id) {
      WordieGameId.wordle =>
        'Make six guesses to find the hidden five-letter word.',
      WordieGameId.connections =>
        'Pick four related words at a time and sort all four groups.',
      WordieGameId.spellingBee =>
        'Use the center letter in every word and keep building your score.',
      WordieGameId.miniCrossword =>
        'Tap a clue or cell, switch Across and Down, and fill the mini like a real crossword.',
      WordieGameId.wordSearch =>
        'Trace a word through touching letters, then submit the path.',
      WordieGameId.hangman => 'Guess letters before you run out of misses.',
      WordieGameId.boggle =>
        'Build words from touching letters and submit each one once.',
      WordieGameId.wordLadder =>
        'Change one letter at a time until you reach the target word.',
      WordieGameId.typeRacer =>
        'Type the full prompt as fast and cleanly as you can.',
      WordieGameId.anagram =>
        'Rebuild the original word from the scrambled letters.',
    };
  }
}

class _GameBody extends StatelessWidget {
  const _GameBody({required this.game});

  final WordieGame game;

  @override
  Widget build(BuildContext context) {
    return switch (game.id) {
      WordieGameId.wordle => const _WordleGame(),
      WordieGameId.connections => const _ConnectionsGame(),
      WordieGameId.spellingBee => const _SpellingBeeGame(),
      WordieGameId.miniCrossword => const _MiniCrosswordGame(),
      WordieGameId.wordSearch => const _WordSearchGame(),
      WordieGameId.hangman => const _HangmanGame(),
      WordieGameId.boggle => const _BoggleGame(),
      WordieGameId.wordLadder => const _WordLadderGame(),
      WordieGameId.typeRacer => const _TypeRacerGame(),
      WordieGameId.anagram => const _AnagramGame(),
    };
  }
}

enum _LetterState { absent, present, correct }

class _WordleGame extends StatefulWidget {
  const _WordleGame();

  @override
  State<_WordleGame> createState() => _WordleGameState();
}

class _WordleGameState extends State<_WordleGame> {
  static const List<String> _answers = [
    'PLANT',
    'CRANE',
    'SMILE',
    'BRICK',
    'SHARE',
    'GHOST',
    'MANGO',
    'STONE',
    'LIGHT',
    'ROUND',
  ];

  late String _solution;
  final List<String> _guesses = [];
  String _currentGuess = '';
  String _message = 'Build a five-letter word.';

  bool get _won => _guesses.contains(_solution);
  bool get _complete => _won || _guesses.length >= 6;

  @override
  void initState() {
    super.initState();
    _reset();
  }

  void _reset() {
    final today = DateTime.now();
    final index = (today.year + today.month + today.day) % _answers.length;
    setState(() {
      _solution = _answers[index];
      _guesses.clear();
      _currentGuess = '';
      _message = 'Build a five-letter word.';
    });
  }

  void _addLetter(String letter) {
    if (_complete || _currentGuess.length >= 5) {
      return;
    }
    setState(() {
      _currentGuess += letter;
    });
  }

  void _deleteLetter() {
    if (_complete || _currentGuess.isEmpty) {
      return;
    }
    setState(() {
      _currentGuess = _currentGuess.substring(0, _currentGuess.length - 1);
    });
  }

  void _submitGuess() {
    if (_complete) {
      return;
    }
    if (_currentGuess.length != 5) {
      setState(() {
        _message = 'The guess needs five letters.';
      });
      return;
    }

    final guess = _currentGuess.toUpperCase();
    if (!_answers.contains(guess)) {
      setState(() {
        _message = 'That word is not in this small demo list.';
      });
      return;
    }

    setState(() {
      _guesses.add(guess);
      _currentGuess = '';
      if (guess == _solution) {
        _message = 'Solved.';
      } else if (_guesses.length >= 6) {
        _message = 'Out of turns. The word was $_solution.';
      } else {
        _message = '${6 - _guesses.length} guesses left.';
      }
    });
  }

  Map<String, _LetterState> _keyboardStates() {
    final states = <String, _LetterState>{};
    for (final guess in _guesses) {
      final result = _scoreGuess(guess);
      for (var i = 0; i < guess.length; i++) {
        final letter = guess[i];
        final current = states[letter];
        final next = result[i];
        if (current == _LetterState.correct || current == next) {
          continue;
        }
        if (current == _LetterState.present && next == _LetterState.absent) {
          continue;
        }
        states[letter] = next;
      }
    }
    return states;
  }

  List<_LetterState> _scoreGuess(String guess) {
    final result = List<_LetterState>.filled(5, _LetterState.absent);
    final counts = <String, int>{};
    for (var i = 0; i < _solution.length; i++) {
      final letter = _solution[i];
      counts[letter] = (counts[letter] ?? 0) + 1;
    }
    for (var i = 0; i < guess.length; i++) {
      if (guess[i] == _solution[i]) {
        result[i] = _LetterState.correct;
        counts[guess[i]] = (counts[guess[i]] ?? 1) - 1;
      }
    }
    for (var i = 0; i < guess.length; i++) {
      if (result[i] == _LetterState.correct) {
        continue;
      }
      final remaining = counts[guess[i]] ?? 0;
      if (remaining > 0) {
        result[i] = _LetterState.present;
        counts[guess[i]] = remaining - 1;
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final keyboardStates = _keyboardStates();
    const rows = ['QWERTYUIOP', 'ASDFGHJKL', 'ZXCVBNM'];

    return SingleChildScrollView(
      child: Column(
        children: [
          _MessageBar(
            message: _message,
            trailing: _TinyButton(label: 'Reset', onPressed: _reset),
          ),
          const SizedBox(height: 16),
          for (var row = 0; row < 6; row++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var column = 0; column < 5; column++)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: _WordleTile(
                        letter: _tileLetter(row, column),
                        state: _tileState(row, column),
                      ),
                    ),
                ],
              ),
            ),
          const SizedBox(height: 20),
          for (final row in rows)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (row == rows.last)
                    _KeyboardKey(label: 'ENTER', onTap: _submitGuess, flex: 14),
                  for (final char in row.split(''))
                    _KeyboardKey(
                      label: char,
                      onTap: () => _addLetter(char),
                      state: keyboardStates[char],
                    ),
                  if (row == rows.last)
                    _KeyboardKey(label: '⌫', onTap: _deleteLetter, flex: 10),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _tileLetter(int row, int column) {
    if (row < _guesses.length) {
      return _guesses[row][column];
    }
    if (row == _guesses.length && column < _currentGuess.length) {
      return _currentGuess[column];
    }
    return '';
  }

  _LetterState? _tileState(int row, int column) {
    if (row < _guesses.length) {
      return _scoreGuess(_guesses[row])[column];
    }
    return null;
  }
}

class _WordleTile extends StatelessWidget {
  const _WordleTile({required this.letter, required this.state});

  final String letter;
  final _LetterState? state;

  @override
  Widget build(BuildContext context) {
    final color = switch (state) {
      _LetterState.correct => WordieTheme.brandGreen,
      _LetterState.present => const Color(0xFFD4A24C),
      _LetterState.absent => WordieTheme.cardAlt,
      null => Colors.transparent,
    };

    return Container(
      width: 48,
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: state == null ? WordieTheme.border : color),
      ),
      child: Text(
        letter,
        style: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _KeyboardKey extends StatelessWidget {
  const _KeyboardKey({
    required this.label,
    required this.onTap,
    this.state,
    this.flex = 8,
  });

  final String label;
  final VoidCallback onTap;
  final _LetterState? state;
  final int flex;

  @override
  Widget build(BuildContext context) {
    final background = switch (state) {
      _LetterState.correct => WordieTheme.brandGreen,
      _LetterState.present => const Color(0xFFD4A24C),
      _LetterState.absent => WordieTheme.cardAlt,
      null => WordieTheme.cardAlt,
    };

    return Flexible(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: SizedBox(
          height: 44,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: background,
              foregroundColor: Colors.white,
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: onTap,
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}

class _ConnectionsGame extends StatefulWidget {
  const _ConnectionsGame();

  @override
  State<_ConnectionsGame> createState() => _ConnectionsGameState();
}

class _ConnectionsGameState extends State<_ConnectionsGame> {
  static const List<_ConnectionsGroup> _groups = [
    _ConnectionsGroup('Colors', ['BLUE', 'GREEN', 'RED', 'YELLOW']),
    _ConnectionsGroup('Planets', ['EARTH', 'MARS', 'SATURN', 'VENUS']),
    _ConnectionsGroup('Pets', ['CAT', 'DOG', 'FISH', 'MOUSE']),
    _ConnectionsGroup('Weather', ['CLOUD', 'RAIN', 'SNOW', 'WIND']),
  ];

  late List<String> _tiles;
  final Set<String> _selected = <String>{};
  final List<_ConnectionsGroup> _solved = [];
  int _mistakesLeft = 4;
  String _message = 'Find four groups of four.';

  @override
  void initState() {
    super.initState();
    _reset();
  }

  void _reset() {
    final shuffled = _groups.expand((group) => group.words).toList()
      ..shuffle(math.Random(4));
    setState(() {
      _tiles = shuffled;
      _selected.clear();
      _solved.clear();
      _mistakesLeft = 4;
      _message = 'Find four groups of four.';
    });
  }

  void _toggle(String word) {
    if (_mistakesLeft == 0 || _solved.length == _groups.length) {
      return;
    }
    setState(() {
      if (_selected.contains(word)) {
        _selected.remove(word);
      } else if (_selected.length < 4) {
        _selected.add(word);
      }
    });
  }

  void _submit() {
    if (_selected.length != 4) {
      setState(() {
        _message = 'Select exactly four words.';
      });
      return;
    }

    final match = _groups
        .where((group) => !_solved.contains(group))
        .cast<_ConnectionsGroup?>()
        .firstWhere(
          (group) => group!.words.every(_selected.contains),
          orElse: () => null,
        );

    if (match != null) {
      setState(() {
        _solved.add(match);
        _tiles.removeWhere(match.words.contains);
        _selected.clear();
        _message = _solved.length == _groups.length
            ? 'Board solved.'
            : 'Correct group: ${match.title}.';
      });
      return;
    }

    setState(() {
      _mistakesLeft -= 1;
      _selected.clear();
      _message = _mistakesLeft == 0
          ? 'No mistakes left. Reset to try again.'
          : 'Not a group. $_mistakesLeft mistakes left.';
    });
  }

  void _shuffle() {
    setState(() {
      _tiles.shuffle(math.Random());
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MessageBar(
            message: _message,
            trailing: Text(
              'Mistakes: $_mistakesLeft',
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
          const SizedBox(height: 16),
          for (final group in _solved) ...[
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: WordieTheme.cardAlt,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: WordieTheme.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    group.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    group.words.join('  '),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _tiles.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1.45,
            ),
            itemBuilder: (context, index) {
              final tile = _tiles[index];
              final selected = _selected.contains(tile);
              return OutlinedButton(
                style: OutlinedButton.styleFrom(
                  backgroundColor: selected
                      ? WordieTheme.brandGreen.withValues(alpha: 0.18)
                      : WordieTheme.cardAlt,
                  foregroundColor: WordieTheme.textPrimary,
                  side: BorderSide(
                    color: selected
                        ? WordieTheme.brandGreen
                        : WordieTheme.border,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => _toggle(tile),
                child: FittedBox(child: Text(tile)),
              );
            },
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _TinyButton(label: 'Submit', onPressed: _submit),
              _TinyButton(
                label: 'Clear',
                onPressed: () => setState(_selected.clear),
              ),
              _TinyButton(label: 'Shuffle', onPressed: _shuffle),
              _TinyButton(label: 'Reset', onPressed: _reset),
            ],
          ),
        ],
      ),
    );
  }
}

class _ConnectionsGroup {
  const _ConnectionsGroup(this.title, this.words);

  final String title;
  final List<String> words;
}

class _SpellingBeeGame extends StatefulWidget {
  const _SpellingBeeGame();

  @override
  State<_SpellingBeeGame> createState() => _SpellingBeeGameState();
}

class _SpellingBeeGameState extends State<_SpellingBeeGame> {
  static const String _center = 'A';
  static const List<String> _letters = ['A', 'P', 'L', 'E', 'S', 'T', 'C'];
  static const Set<String> _validWords = {
    'CASTE',
    'CLEAT',
    'LEAP',
    'LEAST',
    'PALE',
    'PALES',
    'PALETTE',
    'PASTEL',
    'PETAL',
    'PLACE',
    'PLATE',
    'PLEA',
    'PLEAS',
    'PLEAT',
    'SALE',
    'SEAL',
    'SLATE',
    'SPACE',
    'STALE',
    'STEAL',
    'STAPLE',
    'TEAL',
  };

  final TextEditingController _controller = TextEditingController();
  final Set<String> _found = <String>{};
  String _message = 'Use A in every word.';
  int _score = 0;

  int get _targetScore =>
      _validWords.fold(0, (sum, word) => sum + _wordScore(word));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final word = _controller.text.trim().toUpperCase();
    if (word.length < 4) {
      setState(() {
        _message = 'Words need at least four letters.';
      });
      return;
    }
    if (!word.contains(_center)) {
      setState(() {
        _message = 'Every word must include A.';
      });
      return;
    }
    if (word.split('').any((letter) => !_letters.contains(letter))) {
      setState(() {
        _message = 'Use only the seven hive letters.';
      });
      return;
    }
    if (!_validWords.contains(word)) {
      setState(() {
        _message = 'That word is not in this round.';
      });
      return;
    }
    if (_found.contains(word)) {
      setState(() {
        _message = 'Already found.';
      });
      return;
    }

    setState(() {
      _found.add(word);
      _score += _wordScore(word);
      _controller.clear();
      _message = _isPangram(word) ? 'Pangram.' : 'Accepted.';
    });
  }

  void _reset() {
    setState(() {
      _found.clear();
      _controller.clear();
      _score = 0;
      _message = 'Use A in every word.';
    });
  }

  static int _wordScore(String word) {
    final base = word.length == 4 ? 1 : word.length;
    return _isPangram(word) ? base + 7 : base;
  }

  static bool _isPangram(String word) {
    return _letters.every(word.contains);
  }

  String _rankLabel() {
    final ratio = _targetScore == 0 ? 0.0 : _score / _targetScore;
    if (ratio >= 0.9) {
      return 'Genius';
    }
    if (ratio >= 0.65) {
      return 'Great';
    }
    if (ratio >= 0.4) {
      return 'Nice';
    }
    if (ratio >= 0.2) {
      return 'Good start';
    }
    return 'Beginner';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MessageBar(
            message: _message,
            trailing: Text(
              '$_score pts',
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              runSpacing: 10,
              children: _letters
                  .map(
                    (letter) => Container(
                      width: 58,
                      height: 58,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: letter == _center
                            ? const Color(0xFFD4A24C)
                            : WordieTheme.cardAlt,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        letter,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            textCapitalization: TextCapitalization.characters,
            onSubmitted: (_) => _submit(),
            decoration: const InputDecoration(
              hintText: 'Enter a word',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _TinyButton(label: 'Submit', onPressed: _submit),
              _TinyButton(label: 'Reset', onPressed: _reset),
              Text(
                _rankLabel(),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Found words', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _found.isEmpty
                ? [
                    Text(
                      'None yet.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ]
                : (_found.toList()..sort()).map((word) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: WordieTheme.cardAlt,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(word),
                    );
                  }).toList(),
          ),
        ],
      ),
    );
  }
}

class _MiniCrosswordGame extends StatefulWidget {
  const _MiniCrosswordGame();

  @override
  State<_MiniCrosswordGame> createState() => _MiniCrosswordGameState();
}

enum _CrosswordDirection { across, down }

class _MiniCrosswordEntry {
  const _MiniCrosswordEntry({
    required this.number,
    required this.direction,
    required this.row,
    required this.column,
    required this.answer,
    required this.clue,
  });

  final int number;
  final _CrosswordDirection direction;
  final int row;
  final int column;
  final String answer;
  final String clue;
}

class _MiniCrosswordGameState extends State<_MiniCrosswordGame> {
  static const List<String> _solution = [
    'STONE',
    'TRAIL',
    'OARED',
    'NIECE',
    'ELDER',
  ];
  static const List<_MiniCrosswordEntry> _acrossEntries = [
    _MiniCrosswordEntry(
      number: 1,
      direction: _CrosswordDirection.across,
      row: 0,
      column: 0,
      answer: 'STONE',
      clue: 'Hard piece of granite, say',
    ),
    _MiniCrosswordEntry(
      number: 6,
      direction: _CrosswordDirection.across,
      row: 1,
      column: 0,
      answer: 'TRAIL',
      clue: 'Hiking path through the woods',
    ),
    _MiniCrosswordEntry(
      number: 7,
      direction: _CrosswordDirection.across,
      row: 2,
      column: 0,
      answer: 'OARED',
      clue: 'Propelled a boat with paddles',
    ),
    _MiniCrosswordEntry(
      number: 8,
      direction: _CrosswordDirection.across,
      row: 3,
      column: 0,
      answer: 'NIECE',
      clue: 'Daughter of one\'s sibling',
    ),
    _MiniCrosswordEntry(
      number: 9,
      direction: _CrosswordDirection.across,
      row: 4,
      column: 0,
      answer: 'ELDER',
      clue: 'Older or senior',
    ),
  ];
  static const List<_MiniCrosswordEntry> _downEntries = [
    _MiniCrosswordEntry(
      number: 1,
      direction: _CrosswordDirection.down,
      row: 0,
      column: 0,
      answer: 'STONE',
      clue: 'Pebble or boulder',
    ),
    _MiniCrosswordEntry(
      number: 2,
      direction: _CrosswordDirection.down,
      row: 0,
      column: 1,
      answer: 'TRAIL',
      clue: 'Follow behind',
    ),
    _MiniCrosswordEntry(
      number: 3,
      direction: _CrosswordDirection.down,
      row: 0,
      column: 2,
      answer: 'OARED',
      clue: 'Moved a skiff with rowing power',
    ),
    _MiniCrosswordEntry(
      number: 4,
      direction: _CrosswordDirection.down,
      row: 0,
      column: 3,
      answer: 'NIECE',
      clue: 'Family member in the next generation',
    ),
    _MiniCrosswordEntry(
      number: 5,
      direction: _CrosswordDirection.down,
      row: 0,
      column: 4,
      answer: 'ELDER',
      clue: 'More mature',
    ),
  ];
  static const Map<String, int> _cellNumbers = {
    '0,0': 1,
    '0,1': 2,
    '0,2': 3,
    '0,3': 4,
    '0,4': 5,
    '1,0': 6,
    '2,0': 7,
    '3,0': 8,
    '4,0': 9,
  };

  late List<List<String>> _letters;
  _GridPoint _selected = const _GridPoint(0, 0);
  _CrosswordDirection _direction = _CrosswordDirection.across;
  String _message = 'Fill the mini. Tap the same cell to switch direction.';
  bool _checked = false;

  @override
  void initState() {
    super.initState();
    _letters = List.generate(5, (_) => List<String>.filled(5, ''));
  }

  void _check() {
    final solved = _isSolved();
    setState(() {
      _checked = true;
      _message = solved
          ? 'Solved. Nice clean mini.'
          : 'Some squares are still off.';
    });
  }

  void _reset() {
    for (final row in _letters) {
      for (var column = 0; column < row.length; column++) {
        row[column] = '';
      }
    }
    setState(() {
      _checked = false;
      _selected = const _GridPoint(0, 0);
      _direction = _CrosswordDirection.across;
      _message = 'Grid cleared.';
    });
  }

  bool _isSolved() {
    for (var row = 0; row < 5; row++) {
      for (var column = 0; column < 5; column++) {
        if (_letters[row][column] != _solution[row][column]) {
          return false;
        }
      }
    }
    return true;
  }

  bool _isCorrectCell(_GridPoint cell) {
    return _letters[cell.row][cell.column] == _solution[cell.row][cell.column];
  }

  _MiniCrosswordEntry get _activeEntry => _entryForCell(_selected, _direction);

  _MiniCrosswordEntry _entryForCell(
    _GridPoint cell,
    _CrosswordDirection direction,
  ) {
    return direction == _CrosswordDirection.across
        ? _acrossEntries[cell.row]
        : _downEntries[cell.column];
  }

  List<_GridPoint> _cellsForEntry(_MiniCrosswordEntry entry) {
    return List.generate(entry.answer.length, (index) {
      return entry.direction == _CrosswordDirection.across
          ? _GridPoint(entry.row, entry.column + index)
          : _GridPoint(entry.row + index, entry.column);
    });
  }

  bool _entrySolved(_MiniCrosswordEntry entry) {
    final cells = _cellsForEntry(entry);
    for (var i = 0; i < cells.length; i++) {
      final cell = cells[i];
      if (_letters[cell.row][cell.column] != entry.answer[i]) {
        return false;
      }
    }
    return true;
  }

  String _entryFill(_MiniCrosswordEntry entry) {
    final cells = _cellsForEntry(entry);
    return cells
        .map(
          (cell) => _letters[cell.row][cell.column].isEmpty
              ? '·'
              : _letters[cell.row][cell.column],
        )
        .join();
  }

  bool _cellInActiveEntry(_GridPoint cell) {
    return _cellsForEntry(_activeEntry).contains(cell);
  }

  void _selectCell(_GridPoint cell, {bool toggleIfSame = false}) {
    setState(() {
      if (_selected == cell && toggleIfSame) {
        _direction = _direction == _CrosswordDirection.across
            ? _CrosswordDirection.down
            : _CrosswordDirection.across;
      } else {
        _selected = cell;
      }
      _message =
          '${_activeEntry.number}${_direction == _CrosswordDirection.across ? 'A' : 'D'}: ${_activeEntry.clue}';
    });
  }

  void _jumpToEntry(_MiniCrosswordEntry entry) {
    setState(() {
      _selected = _GridPoint(entry.row, entry.column);
      _direction = entry.direction;
      _message =
          '${entry.number}${entry.direction == _CrosswordDirection.across ? 'A' : 'D'}: ${entry.clue}';
    });
  }

  void _toggleDirection() {
    setState(() {
      _direction = _direction == _CrosswordDirection.across
          ? _CrosswordDirection.down
          : _CrosswordDirection.across;
      _message =
          '${_activeEntry.number}${_direction == _CrosswordDirection.across ? 'A' : 'D'}: ${_activeEntry.clue}';
    });
  }

  void _enterLetter(String letter) {
    setState(() {
      _checked = false;
      _letters[_selected.row][_selected.column] = letter;
      _moveForward();
      if (_isSolved()) {
        _message = 'Solved. Nice clean mini.';
      }
    });
  }

  void _moveForward() {
    final entry = _activeEntry;
    final cells = _cellsForEntry(entry);
    final index = cells.indexOf(_selected);
    if (index >= 0 && index < cells.length - 1) {
      _selected = cells[index + 1];
    }
  }

  void _moveBackward() {
    final entry = _activeEntry;
    final cells = _cellsForEntry(entry);
    final index = cells.indexOf(_selected);
    if (index > 0) {
      _selected = cells[index - 1];
    }
  }

  void _deleteLetter() {
    setState(() {
      _checked = false;
      if (_letters[_selected.row][_selected.column].isNotEmpty) {
        _letters[_selected.row][_selected.column] = '';
      } else {
        _moveBackward();
        _letters[_selected.row][_selected.column] = '';
      }
    });
  }

  void _clearWord() {
    final entry = _activeEntry;
    final cells = _cellsForEntry(entry);
    setState(() {
      _checked = false;
      for (final cell in cells) {
        _letters[cell.row][cell.column] = '';
      }
      _selected = cells.first;
      _message =
          '${entry.number}${entry.direction == _CrosswordDirection.across ? 'A' : 'D'} cleared.';
    });
  }

  void _revealWord() {
    final entry = _activeEntry;
    final cells = _cellsForEntry(entry);
    setState(() {
      _checked = true;
      for (var i = 0; i < cells.length; i++) {
        final cell = cells[i];
        _letters[cell.row][cell.column] = entry.answer[i];
      }
      _message =
          '${entry.number}${entry.direction == _CrosswordDirection.across ? 'A' : 'D'} revealed.';
    });
  }

  double _completion() {
    var filled = 0;
    for (final row in _letters) {
      for (final letter in row) {
        if (letter.isNotEmpty) {
          filled += 1;
        }
      }
    }
    return filled / 25;
  }

  Color _cellBackground(_GridPoint cell) {
    if (_selected == cell) {
      return const Color(0xFFFFD447);
    }
    if (_checked && _isCorrectCell(cell)) {
      return WordieTheme.brandGreen.withValues(alpha: 0.35);
    }
    if (_cellInActiveEntry(cell)) {
      return const Color(0xFF9ED7FF);
    }
    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    final activeEntry = _activeEntry;
    final completion = _completion();

    return LayoutBuilder(
      builder: (context, constraints) {
        final boardSize = math.min(constraints.maxWidth, 360.0);
        final splitLayout = constraints.maxWidth >= 780;

        final board = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F3E8),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFF161616), width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${activeEntry.number}${_direction == _CrosswordDirection.across ? 'A' : 'D'}',
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(color: const Color(0xFF161616)),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              activeEntry.clue,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(color: const Color(0xFF161616)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      _MiniCrosswordMeta(
                        label: 'Fill',
                        value: '${(completion * 100).round()}%',
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Center(
                    child: SizedBox(
                      width: boardSize,
                      height: boardSize,
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 5,
                            ),
                        itemCount: 25,
                        itemBuilder: (context, index) {
                          final row = index ~/ 5;
                          final column = index % 5;
                          final cell = _GridPoint(row, column);
                          final number = _cellNumbers['$row,$column'];
                          return GestureDetector(
                            onTap: () => _selectCell(cell, toggleIfSame: true),
                            child: Container(
                              decoration: BoxDecoration(
                                color: _cellBackground(cell),
                                border: Border.all(
                                  color: const Color(0xFF161616),
                                  width: 1.2,
                                ),
                              ),
                              child: Stack(
                                children: [
                                  if (number != null)
                                    Positioned(
                                      left: 4,
                                      top: 3,
                                      child: Text(
                                        '$number',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF161616),
                                        ),
                                      ),
                                    ),
                                  Center(
                                    child: Text(
                                      _letters[row][column],
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall
                                          ?.copyWith(
                                            color: const Color(0xFF161616),
                                            fontWeight: FontWeight.w800,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _TinyButton(
                  label: _direction == _CrosswordDirection.across
                      ? 'Switch to Down'
                      : 'Switch to Across',
                  onPressed: _toggleDirection,
                ),
                _TinyButton(label: 'Clear Word', onPressed: _clearWord),
                _TinyButton(label: 'Reveal Word', onPressed: _revealWord),
                _TinyButton(label: 'Check', onPressed: _check),
                _TinyButton(label: 'Reset', onPressed: _reset),
              ],
            ),
            const SizedBox(height: 12),
            _MessageBar(message: _message),
            const SizedBox(height: 12),
            _CrosswordKeyboard(
              onLetter: _enterLetter,
              onBackspace: _deleteLetter,
            ),
          ],
        );

        final clues = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ClueSection(
              title: 'Across',
              entries: _acrossEntries,
              activeEntry: activeEntry,
              entryFill: _entryFill,
              entrySolved: _entrySolved,
              onTap: _jumpToEntry,
            ),
            const SizedBox(height: 16),
            _ClueSection(
              title: 'Down',
              entries: _downEntries,
              activeEntry: activeEntry,
              entryFill: _entryFill,
              entrySolved: _entrySolved,
              onTap: _jumpToEntry,
            ),
          ],
        );

        return SingleChildScrollView(
          child: splitLayout
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 11, child: board),
                    const SizedBox(width: 16),
                    Expanded(flex: 9, child: clues),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [board, const SizedBox(height: 16), clues],
                ),
        );
      },
    );
  }
}

class _MiniCrosswordMeta extends StatelessWidget {
  const _MiniCrosswordMeta({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _ClueSection extends StatelessWidget {
  const _ClueSection({
    required this.title,
    required this.entries,
    required this.activeEntry,
    required this.entryFill,
    required this.entrySolved,
    required this.onTap,
  });

  final String title;
  final List<_MiniCrosswordEntry> entries;
  final _MiniCrosswordEntry activeEntry;
  final String Function(_MiniCrosswordEntry entry) entryFill;
  final bool Function(_MiniCrosswordEntry entry) entrySolved;
  final void Function(_MiniCrosswordEntry entry) onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 10),
        for (final entry in entries)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => onTap(entry),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: entry == activeEntry
                      ? const Color(0xFF283F7F)
                      : WordieTheme.cardAlt,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: entry == activeEntry
                        ? const Color(0xFF9ED7FF)
                        : WordieTheme.border,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${entry.number}${entry.direction == _CrosswordDirection.across ? 'A' : 'D'}',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const Spacer(),
                        if (entrySolved(entry))
                          const Icon(
                            Icons.check_circle_rounded,
                            size: 18,
                            color: WordieTheme.brandGreen,
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      entry.clue,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      entryFill(entry),
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: const Color(0xFF9ED7FF),
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _CrosswordKeyboard extends StatelessWidget {
  const _CrosswordKeyboard({required this.onLetter, required this.onBackspace});

  final void Function(String letter) onLetter;
  final VoidCallback onBackspace;

  @override
  Widget build(BuildContext context) {
    const rows = ['QWERTYUIOP', 'ASDFGHJKL', 'ZXCVBNM'];
    return Column(
      children: [
        for (final row in rows)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (row == rows.last)
                  _CrosswordKey(label: '⌫', flex: 12, onTap: onBackspace),
                for (final letter in row.split(''))
                  _CrosswordKey(label: letter, onTap: () => onLetter(letter)),
              ],
            ),
          ),
      ],
    );
  }
}

class _CrosswordKey extends StatelessWidget {
  const _CrosswordKey({
    required this.label,
    required this.onTap,
    this.flex = 8,
  });

  final String label;
  final VoidCallback onTap;
  final int flex;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: SizedBox(
          height: 46,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: WordieTheme.cardAlt,
              foregroundColor: WordieTheme.textPrimary,
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: onTap,
            child: Text(label),
          ),
        ),
      ),
    );
  }
}

class _WordSearchGame extends StatefulWidget {
  const _WordSearchGame();

  @override
  State<_WordSearchGame> createState() => _WordSearchGameState();
}

class _WordSearchGameState extends State<_WordSearchGame> {
  static const List<String> _rows = [
    'PLAYTO',
    'XGAMEN',
    'QWORDS',
    'HONEYU',
    'BEEKLM',
    'RAINPC',
  ];
  static const Set<String> _targets = {
    'PLAY',
    'GAME',
    'WORD',
    'HONEY',
    'BEE',
    'RAIN',
  };

  final List<_GridPoint> _selected = [];
  final Set<String> _found = <String>{};
  String _message = 'Select touching letters in a line.';

  void _toggle(_GridPoint point) {
    final existingIndex = _selected.indexWhere((cell) => cell == point);
    if (existingIndex == _selected.length - 1) {
      setState(() {
        _selected.removeLast();
      });
      return;
    }

    if (_selected.contains(point)) {
      return;
    }

    if (_selected.isEmpty) {
      setState(() {
        _selected.add(point);
      });
      return;
    }

    final last = _selected.last;
    if (!_isAdjacent(last, point)) {
      return;
    }

    if (_selected.length >= 2) {
      final step = _stepBetween(_selected[0], _selected[1]);
      final nextStep = _stepBetween(last, point);
      if (step != nextStep) {
        return;
      }
    }

    setState(() {
      _selected.add(point);
    });
  }

  void _submit() {
    final word = _selected.map((cell) => _rows[cell.row][cell.column]).join();
    final reversed = word.split('').reversed.join();
    final match = _targets.contains(word)
        ? word
        : _targets.contains(reversed)
        ? reversed
        : null;
    if (match == null) {
      setState(() {
        _message = 'That path is not one of the target words.';
        _selected.clear();
      });
      return;
    }
    if (_found.contains(match)) {
      setState(() {
        _message = 'Already found.';
        _selected.clear();
      });
      return;
    }

    setState(() {
      _found.add(match);
      _message = _found.length == _targets.length
          ? 'All words found.'
          : '$match found.';
      _selected.clear();
    });
  }

  void _clear() {
    setState(() {
      _selected.clear();
    });
  }

  _GridPoint _stepBetween(_GridPoint a, _GridPoint b) {
    final rowDelta = (b.row - a.row).sign;
    final columnDelta = (b.column - a.column).sign;
    return _GridPoint(rowDelta, columnDelta);
  }

  bool _isAdjacent(_GridPoint a, _GridPoint b) {
    final rowDelta = (a.row - b.row).abs();
    final columnDelta = (a.column - b.column).abs();
    return rowDelta <= 1 && columnDelta <= 1 && (rowDelta + columnDelta > 0);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MessageBar(message: _message),
          const SizedBox(height: 16),
          Center(
            child: Column(
              children: [
                for (var row = 0; row < _rows.length; row++)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var column = 0; column < _rows[row].length; column++)
                        Padding(
                          padding: const EdgeInsets.all(3),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () => _toggle(_GridPoint(row, column)),
                            child: Container(
                              width: 46,
                              height: 46,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: _cellColor(row, column),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: WordieTheme.border),
                              ),
                              child: Text(
                                _rows[row][column],
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _TinyButton(label: 'Submit path', onPressed: _submit),
              _TinyButton(label: 'Clear path', onPressed: _clear),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _targets.map((word) {
              final found = _found.contains(word);
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: found
                      ? WordieTheme.brandGreen.withValues(alpha: 0.18)
                      : WordieTheme.cardAlt,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(word),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Color _cellColor(int row, int column) {
    final point = _GridPoint(row, column);
    if (_selected.contains(point)) {
      return const Color(0xFFD4A24C).withValues(alpha: 0.28);
    }
    return WordieTheme.cardAlt;
  }
}

class _HangmanGame extends StatefulWidget {
  const _HangmanGame();

  @override
  State<_HangmanGame> createState() => _HangmanGameState();
}

class _HangmanGameState extends State<_HangmanGame> {
  static const List<_HintWord> _words = [
    _HintWord('FLUTTER', 'Framework'),
    _HintWord('PUZZLE', 'Brain teaser'),
    _HintWord('KEYBOARD', 'Input device'),
    _HintWord('ORANGE', 'Fruit'),
  ];

  late _HintWord _round;
  final Set<String> _guessed = <String>{};
  int _misses = 0;
  String _message = 'Choose a letter.';

  bool get _won => _round.word.split('').every(_guessed.contains);
  bool get _lost => _misses >= 6;

  @override
  void initState() {
    super.initState();
    _reset();
  }

  void _reset() {
    final today = DateTime.now();
    final index = (today.day + today.month) % _words.length;
    setState(() {
      _round = _words[index];
      _guessed.clear();
      _misses = 0;
      _message = 'Choose a letter.';
    });
  }

  void _guess(String letter) {
    if (_guessed.contains(letter) || _won || _lost) {
      return;
    }
    setState(() {
      _guessed.add(letter);
      if (_round.word.contains(letter)) {
        _message = _won ? 'You saved it.' : 'Correct.';
      } else {
        _misses += 1;
        _message = _lost
            ? 'You lost. The word was ${_round.word}.'
            : 'Wrong guess.';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MessageBar(
            message: _message,
            trailing: _TinyButton(label: 'Reset', onPressed: _reset),
          ),
          const SizedBox(height: 14),
          Text(
            'Hint: ${_round.hint}',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              List.generate(
                _round.word.length,
                (index) => _guessed.contains(_round.word[index])
                    ? _round.word[index]
                    : '_',
              ).join(' '),
              style: Theme.of(
                context,
              ).textTheme.displaySmall?.copyWith(letterSpacing: 2),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              'Misses: $_misses / 6',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('').map((letter) {
              final used = _guessed.contains(letter);
              return SizedBox(
                width: 44,
                height: 44,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: used
                        ? WordieTheme.cardAlt
                        : WordieTheme.cardAlt,
                    foregroundColor: used
                        ? WordieTheme.textMuted
                        : WordieTheme.textPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: used ? null : () => _guess(letter),
                  child: Text(letter),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _HintWord {
  const _HintWord(this.word, this.hint);

  final String word;
  final String hint;
}

class _BoggleGame extends StatefulWidget {
  const _BoggleGame();

  @override
  State<_BoggleGame> createState() => _BoggleGameState();
}

class _BoggleGameState extends State<_BoggleGame> {
  static const List<String> _rows = ['TONE', 'ARSD', 'PLAY', 'MINT'];
  static const Set<String> _validWords = {
    'TONE',
    'TONES',
    'PLAY',
    'MINT',
    'TARP',
    'RAIN',
    'PLAIN',
    'MINTY',
    'LINT',
  };

  final List<_GridPoint> _selected = [];
  final Set<String> _found = <String>{};
  String _message = 'Tap touching letters to build a word.';

  void _toggle(_GridPoint point) {
    final existingIndex = _selected.indexWhere((cell) => cell == point);
    if (existingIndex == _selected.length - 1) {
      setState(() {
        _selected.removeLast();
      });
      return;
    }
    if (_selected.contains(point)) {
      return;
    }
    if (_selected.isNotEmpty && !_isAdjacent(_selected.last, point)) {
      return;
    }
    setState(() {
      _selected.add(point);
    });
  }

  bool _isAdjacent(_GridPoint a, _GridPoint b) {
    final rowDelta = (a.row - b.row).abs();
    final columnDelta = (a.column - b.column).abs();
    return rowDelta <= 1 && columnDelta <= 1 && (rowDelta + columnDelta > 0);
  }

  void _submit() {
    final word = _selected.map((cell) => _rows[cell.row][cell.column]).join();
    if (word.length < 3) {
      setState(() {
        _message = 'Use at least three letters.';
      });
      return;
    }
    if (!_validWords.contains(word)) {
      setState(() {
        _message = '$word is not in this board list.';
        _selected.clear();
      });
      return;
    }
    if (_found.contains(word)) {
      setState(() {
        _message = 'Already found.';
        _selected.clear();
      });
      return;
    }
    setState(() {
      _found.add(word);
      _message = '$word accepted.';
      _selected.clear();
    });
  }

  void _clear() {
    setState(() {
      _selected.clear();
    });
  }

  int _score() {
    return _found.fold(0, (sum, word) => sum + math.max(word.length - 2, 1));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MessageBar(
            message: _message,
            trailing: Text(
              '${_score()} pts',
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Column(
              children: [
                for (var row = 0; row < _rows.length; row++)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var column = 0; column < _rows[row].length; column++)
                        Padding(
                          padding: const EdgeInsets.all(4),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => _toggle(_GridPoint(row, column)),
                            child: Container(
                              width: 56,
                              height: 56,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color:
                                    _selected.contains(_GridPoint(row, column))
                                    ? WordieTheme.brandGreen.withValues(
                                        alpha: 0.2,
                                      )
                                    : WordieTheme.cardAlt,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _rows[row][column],
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _TinyButton(label: 'Submit', onPressed: _submit),
              _TinyButton(label: 'Clear', onPressed: _clear),
            ],
          ),
          const SizedBox(height: 16),
          Text('Found', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _found.isEmpty
                ? [
                    Text(
                      'None yet.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ]
                : (_found.toList()..sort()).map((word) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: WordieTheme.cardAlt,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(word),
                    );
                  }).toList(),
          ),
        ],
      ),
    );
  }
}

class _WordLadderGame extends StatefulWidget {
  const _WordLadderGame();

  @override
  State<_WordLadderGame> createState() => _WordLadderGameState();
}

class _WordLadderGameState extends State<_WordLadderGame> {
  static const String _start = 'COLD';
  static const String _target = 'WARM';
  static const Set<String> _dictionary = {
    'COLD',
    'CORD',
    'CARD',
    'WARD',
    'WARM',
    'WORD',
    'WORE',
    'WORM',
    'FORM',
    'CORM',
    'BOLD',
    'GOLD',
  };

  final TextEditingController _controller = TextEditingController();
  final List<String> _path = [_start];
  String _message = 'Change one letter at a time.';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final word = _controller.text.trim().toUpperCase();
    if (word.length != _start.length) {
      setState(() {
        _message = 'Use four-letter words.';
      });
      return;
    }
    if (!_dictionary.contains(word)) {
      setState(() {
        _message = 'That word is outside this round dictionary.';
      });
      return;
    }
    if (_path.contains(word)) {
      setState(() {
        _message = 'Use a new word.';
      });
      return;
    }
    if (_difference(_path.last, word) != 1) {
      setState(() {
        _message = 'Change exactly one letter.';
      });
      return;
    }
    setState(() {
      _path.add(word);
      _controller.clear();
      _message = word == _target ? 'Ladder complete.' : 'Good step.';
    });
  }

  void _reset() {
    setState(() {
      _path
        ..clear()
        ..add(_start);
      _controller.clear();
      _message = 'Change one letter at a time.';
    });
  }

  int _difference(String a, String b) {
    var count = 0;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) {
        count += 1;
      }
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MessageBar(
            message: _message,
            trailing: _TinyButton(label: 'Reset', onPressed: _reset),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _LadderWord(label: 'Start', word: _start),
              const SizedBox(width: 12),
              _LadderWord(label: 'Goal', word: _target),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            textCapitalization: TextCapitalization.characters,
            onSubmitted: (_) => _submit(),
            decoration: const InputDecoration(
              hintText: 'Next word',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          _TinyButton(label: 'Add step', onPressed: _submit),
          const SizedBox(height: 16),
          for (var i = 0; i < _path.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Text(
                    '${i + 1}.',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(width: 8),
                  _LadderWord(
                    label: i == 0
                        ? 'Start'
                        : i == _path.length - 1 && _path.last == _target
                        ? 'Finish'
                        : 'Step',
                    word: _path[i],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _LadderWord extends StatelessWidget {
  const _LadderWord({required this.label, required this.word});

  final String label;
  final String word;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: WordieTheme.cardAlt,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 2),
          Text(word, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}

class _TypeRacerGame extends StatefulWidget {
  const _TypeRacerGame();

  @override
  State<_TypeRacerGame> createState() => _TypeRacerGameState();
}

class _TypeRacerGameState extends State<_TypeRacerGame> {
  static const String _prompt =
      'Fast fingers find words faster when every letter lands in the right place.';

  final TextEditingController _controller = TextEditingController();
  Timer? _timer;
  int _seconds = 60;
  bool _started = false;
  bool _finished = false;

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _startTimer() {
    if (_started) {
      return;
    }
    _started = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_seconds > 1 && !_finished) {
          _seconds -= 1;
        } else {
          _seconds = math.max(_seconds - 1, 0);
          _finished = true;
          timer.cancel();
        }
      });
    });
  }

  void _reset() {
    _timer?.cancel();
    setState(() {
      _controller.clear();
      _seconds = 60;
      _started = false;
      _finished = false;
    });
  }

  int _correctCharacters() {
    final typed = _controller.text;
    var matches = 0;
    for (var i = 0; i < math.min(typed.length, _prompt.length); i++) {
      if (typed[i] == _prompt[i]) {
        matches += 1;
      }
    }
    return matches;
  }

  double _accuracy() {
    final typedLength = _controller.text.length;
    if (typedLength == 0) {
      return 100;
    }
    return (_correctCharacters() / typedLength) * 100;
  }

  double _wpm() {
    final elapsed = _started ? math.max(60 - _seconds, 1) : 1;
    final minutes = elapsed / 60;
    return (_correctCharacters() / 5) / minutes;
  }

  @override
  Widget build(BuildContext context) {
    final completed = _controller.text == _prompt;
    if (completed && !_finished) {
      _finished = true;
      _timer?.cancel();
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MessageBar(
            message: completed
                ? 'Finished.'
                : 'Start typing to begin the timer.',
            trailing: _TinyButton(label: 'Reset', onPressed: _reset),
          ),
          const SizedBox(height: 16),
          Text(_prompt, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            maxLines: 4,
            onChanged: (_) {
              _startTimer();
              setState(() {});
            },
            decoration: const InputDecoration(
              hintText: 'Type here',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _StatBadge(label: 'Time', value: '$_seconds s'),
              _StatBadge(label: 'WPM', value: _wpm().toStringAsFixed(1)),
              _StatBadge(
                label: 'Accuracy',
                value: '${_accuracy().toStringAsFixed(0)}%',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  const _StatBadge({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: WordieTheme.cardAlt,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 2),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}

class _AnagramGame extends StatefulWidget {
  const _AnagramGame();

  @override
  State<_AnagramGame> createState() => _AnagramGameState();
}

class _AnagramGameState extends State<_AnagramGame> {
  static const List<String> _answers = ['REACT', 'STONE', 'MARKET', 'PLANET'];

  late String _answer;
  late List<String> _available;
  final List<String> _picked = [];
  String _message = 'Rebuild the word.';
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _loadRound();
  }

  void _loadRound() {
    _answer = _answers[_index % _answers.length];
    _available = _answer.split('')..shuffle(math.Random(_index + 1));
    _picked.clear();
  }

  void _pick(int index) {
    setState(() {
      _picked.add(_available.removeAt(index));
    });
  }

  void _removePicked(int index) {
    setState(() {
      _available.add(_picked.removeAt(index));
    });
  }

  void _check() {
    final guess = _picked.join();
    setState(() {
      if (guess == _answer) {
        _message = 'Solved.';
      } else {
        _message = 'Not yet.';
      }
    });
  }

  void _shuffle() {
    setState(() {
      _available.shuffle(math.Random());
    });
  }

  void _clear() {
    setState(() {
      _available.addAll(_picked);
      _picked.clear();
      _message = 'Rebuild the word.';
    });
  }

  void _next() {
    setState(() {
      _index += 1;
      _message = 'Rebuild the word.';
      _loadRound();
    });
  }

  @override
  Widget build(BuildContext context) {
    final solved = _picked.join() == _answer;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MessageBar(
            message: _message,
            trailing: solved
                ? _TinyButton(label: 'Next', onPressed: _next)
                : null,
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: WordieTheme.cardAlt,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _picked.isEmpty ? 'Tap letters below.' : _picked.join(),
              style: Theme.of(context).textTheme.displaySmall,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          Text('Letters', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(_available.length, (index) {
              return _LetterChip(
                label: _available[index],
                onTap: () => _pick(index),
              );
            }),
          ),
          const SizedBox(height: 16),
          Text('Answer', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(_picked.length, (index) {
              return _LetterChip(
                label: _picked[index],
                onTap: () => _removePicked(index),
              );
            }),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _TinyButton(label: 'Check', onPressed: _check),
              _TinyButton(label: 'Shuffle', onPressed: _shuffle),
              _TinyButton(label: 'Clear', onPressed: _clear),
            ],
          ),
        ],
      ),
    );
  }
}

class _LetterChip extends StatelessWidget {
  const _LetterChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: WordieTheme.cardAlt,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(label, style: Theme.of(context).textTheme.titleMedium),
      ),
    );
  }
}

class _GridPoint {
  const _GridPoint(this.row, this.column);

  final int row;
  final int column;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is _GridPoint && other.row == row && other.column == column;
  }

  @override
  int get hashCode => Object.hash(row, column);
}

class _MessageBar extends StatelessWidget {
  const _MessageBar({required this.message, this.trailing});

  final String message;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: WordieTheme.cardAlt,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(message, style: Theme.of(context).textTheme.bodyMedium),
          ),
          if (trailing != null) ...[const SizedBox(width: 12), trailing!],
        ],
      ),
    );
  }
}

class _TinyButton extends StatelessWidget {
  const _TinyButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: WordieTheme.textPrimary,
        side: const BorderSide(color: WordieTheme.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(label),
    );
  }
}
