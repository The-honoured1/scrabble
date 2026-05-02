import 'package:flutter/material.dart';

enum WordieMode { daily, unlimited }

enum WordieGameId {
  wordle,
  connections,
  spellingBee,
  miniCrossword,
  wordSearch,
  hangman,
  boggle,
  wordLadder,
  typeRacer,
  anagram,
}

class WordieGame {
  const WordieGame({
    required this.id,
    required this.title,
    required this.emoji,
    required this.description,
    required this.color,
    required this.mode,
    required this.highlights,
    required this.playLabel,
    this.resultLabel,
    this.isFeatured = false,
    this.isCompletedToday = false,
  });

  final WordieGameId id;
  final String title;
  final String emoji;
  final String description;
  final Color color;
  final WordieMode mode;
  final List<String> highlights;
  final String playLabel;
  final String? resultLabel;
  final bool isFeatured;
  final bool isCompletedToday;

  String get modeLabel => switch (mode) {
        WordieMode.daily => 'Daily puzzle',
        WordieMode.unlimited => 'Unlimited play',
      };
}
