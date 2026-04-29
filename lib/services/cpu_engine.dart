import 'dart:math';
import '../models/game_state.dart';
import '../models/tile_model.dart';
import '../controllers/game_controller.dart';
import 'move_validator.dart';

class CpuEngine {
  static Future<List<TilePlacement>?> findMove(GameState state, Set<String> dictionary) async {
    if (dictionary.isEmpty) return null;
    
    // Get all tiles already on board
    List<Point<int>> boardTiles = [];
    for (int y = 0; y < 15; y++) {
      for (int x = 0; x < 15; x++) {
        if (state.board[y][x].tile != null) boardTiles.add(Point(x, y));
      }
    }

    if (boardTiles.isEmpty) {
      // First move must be in center (7,7)
      return _tryFindWordFromRack(state.cpuRack, dictionary, 7, 7);
    }

    // Shuffle board tiles to try different connection points each time
    final searchPoints = List<Point<int>>.from(boardTiles)..shuffle();
    
    // Try up to 30 board tiles to find a connection
    for (var point in searchPoints.take(30)) {
      final tileOnBoard = state.board[point.y][point.x].tile!;
      
      final move = _tryFindConnection(state, point.x, point.y, tileOnBoard, dictionary);
      if (move != null) return move;
    }

    return null;
  }

  static List<TilePlacement>? _tryFindConnection(
    GameState state,
    int x,
    int y,
    ScrabbleTile tileOnBoard,
    Set<String> dictionary,
  ) {
    final random = Random();
    
    List<String> rackChars = state.cpuRack.map((e) => e.letter).toList();
    
    // Get a larger slice and shuffle it to avoid alphabetical bias
    final wordList = dictionary.toList();
    wordList.shuffle();

    for (var word in wordList.take(2000)) { 
      if (word.length < 2 || word.length > rackChars.length + 1) continue;
      if (!word.contains(tileOnBoard.letter)) continue;
      
      // Check if we have rest of letters
      final needed = word.split('');
      bool hasAll = true;
      List<String> tempRack = List.from(rackChars);
      
      // Remove one instance of tileOnBoard from needed since it's already on board
      int indexOnBoard = word.indexOf(tileOnBoard.letter);
      needed.removeAt(indexOnBoard);

      for (var char in needed) {
        if (tempRack.contains(char)) {
          tempRack.remove(char);
        } else {
          hasAll = false;
          break;
        }
      }

      if (hasAll) {
        // Try to place it
        bool horizontal = random.nextBool();
        final placements = _getPlacementsForWord(word, indexOnBoard, x, y, horizontal, state);
        
        if (placements != null) {
           // Basic validation (must connect correctly)
           final words = MoveValidator.findFormedWords(state.board, placements);
           if (words.isNotEmpty) return placements;
        }
      }
    }
    return null;
  }

  static List<TilePlacement>? _getPlacementsForWord(
    String word,
    int charIndex,
    int x,
    int y,
    bool horizontal,
    GameState state,
  ) {
    List<TilePlacement> placements = [];
    int startX = horizontal ? x - charIndex : x;
    int startY = horizontal ? y : y - charIndex;

    if (startX < 0 || startY < 0) return null;

    for (int i = 0; i < word.length; i++) {
      int curX = horizontal ? startX + i : startX;
      int curY = horizontal ? startY : startY + i;

      if (curX > 14 || curY > 14) return null;
      
      final char = word[i];
      final existingTile = state.board[curY][curX].tile;

      if (existingTile != null) {
        if (existingTile.letter != char) return null; // Mismatch
        // Else it matches existing, so we don't need to place anything here
        continue;
      }

      // Need to place a tile from rack
      try {
        final tile = state.cpuRack.firstWhere((t) => t.letter == char && !placements.any((p) => p.tile == t));
        placements.add(TilePlacement(tile: tile, x: curX, y: curY));
      } catch (e) {
        return null; // Don't have the letter in rack
      }
    }
    
    return placements;
  }

  static List<TilePlacement>? _tryFindWordFromRack(
    List<ScrabbleTile> rack,
    Set<String> dictionary,
    int startX,
    int startY,
  ) {
    final rackChars = rack.map((e) => e.letter).toList();
    final wordList = dictionary.toList();
    wordList.shuffle();

    for (var word in wordList.take(1000)) {
      if (word.length < 2 || word.length > 7) continue;

      // Check if we can form this word from our rack
      final needed = word.split('');
      bool canForm = true;
      final tempRack = List<String>.from(rackChars);
      
      for (var char in needed) {
        if (tempRack.contains(char)) {
          tempRack.remove(char);
        } else {
          canForm = false;
          break;
        }
      }

      if (canForm) {
        // Just place it horizontally starting at center
        List<TilePlacement> placements = [];
        for (int i = 0; i < word.length; i++) {
          final char = word[i];
          final tile = rack.firstWhere((t) => t.letter == char);
          placements.add(TilePlacement(tile: tile, x: startX + i, y: startY));
        }
        return placements;
      }
    }
    return null;
  }
}
