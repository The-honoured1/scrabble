import 'package:flutter/material.dart';

class GameModel {
  final String id;
  final String title;
  final String route;
  final String description;
  final String emoji;
  final Color accentColor;
  final bool featured;
  final String tag;

  const GameModel({
    required this.id,
    required this.title,
    required this.route,
    required this.description,
    required this.emoji,
    required this.accentColor,
    required this.featured,
    required this.tag,
  });
}

const List<GameModel> allGames = [
  GameModel(
    id: 'wordle',
    title: 'Wordle',
    route: '/wordle',
    description: 'Guess the 5-letter word in 6 tries. One new word every day.',
    emoji: '🟩',
    accentColor: Color(0xFF2D6A4F),
    featured: true,
    tag: 'DAILY',
  ),
  GameModel(
    id: 'connections',
    title: 'Connections',
    route: '/connections',
    description: 'Group 16 words into 4 hidden categories. Watch out for tricks.',
    emoji: '🔗',
    accentColor: Color(0xFF5E548E),
    featured: true,
    tag: 'DAILY',
  ),
  GameModel(
    id: 'spelling_bee',
    title: 'Spelling Bee',
    route: '/spelling-bee',
    description: 'Make words from 7 letters. Use the center letter every time.',
    emoji: '🐝',
    accentColor: Color(0xFFF0C940),
    featured: false,
    tag: 'BEES',
  ),
  GameModel(
    id: 'crossword',
    title: 'Mini Crossword',
    route: '/crossword',
    description: '5×5 clues. Solve it before your coffee gets cold.',
    emoji: '✏️',
    accentColor: Color(0xFF1D3557),
    featured: false,
    tag: 'GRID',
  ),
  GameModel(
    id: 'word_search',
    title: 'Word Search',
    route: '/word-search',
    description: 'Find all hidden words in the letter grid.',
    emoji: '🔍',
    accentColor: Color(0xFF6B6B66),
    featured: false,
    tag: 'SEARCH',
  ),
  GameModel(
    id: 'hangman',
    title: 'Hangman',
    route: '/hangman',
    description: 'Classic letter-guessing before time runs out.',
    emoji: '🎯',
    accentColor: Color(0xFF9B9B94),
    featured: false,
    tag: 'CLASSIC',
  ),
  GameModel(
    id: 'boggle',
    title: 'Boggle',
    route: '/boggle',
    description: 'Chain letters in the 4×4 grid before time’s up.',
    emoji: '🎲',
    accentColor: Color(0xFF9C6644),
    featured: false,
    tag: 'RUSH',
  ),
  GameModel(
    id: 'word_ladder',
    title: 'Word Ladder',
    route: '/word-ladder',
    description: 'Change one letter at a time to reach the target.',
    emoji: '🪜',
    accentColor: Color(0xFF4A4A4A),
    featured: false,
    tag: 'PUZZLE',
  ),
  GameModel(
    id: 'type_racer',
    title: 'Type Racer',
    route: '/type-racer',
    description: 'Race the clock. Type as fast and clean as you can.',
    emoji: '⌨️',
    accentColor: Color(0xFF2A4D69),
    featured: false,
    tag: 'SPEED',
  ),
  GameModel(
    id: 'anagram',
    title: 'Anagram',
    route: '/anagram',
    description: 'Unscramble the letters into the correct word.',
    emoji: '🔀',
    accentColor: Color(0xFFB74F07),
    featured: false,
    tag: 'SCRAMBLE',
  ),
];
