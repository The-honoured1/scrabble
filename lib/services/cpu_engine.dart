import 'dart:math';
import '../models/game_state.dart';
import '../models/tile_model.dart';
import '../controllers/game_controller.dart';
import 'move_validator.dart';

class CpuEngine {
  static Future<List<TilePlacement>?> findMove(GameState state, Set<String> dictionary) async {
    final random = Random();
    
    // Get all tiles already on board
    List<Point<int>> boardTiles = [];
    for (int y = 0; y < 15; y++) {
      for (int x = 0; x < 15; x++) {
        if (state.board[y][x].tile != null) boardTiles.add(Point(x, y));
      }
    }

    if (boardTiles.isEmpty) {
      // First move must be in center (7,7)
      return _tryFindWordFromRack(state.cpuRack, dictionary, 7, 7, true);
    }

    boardTiles.shuffle();
    
    // Try first 20 board tiles to find a connection (performance)
    for (var point in boardTiles.take(20)) {
      final tileOnBoard = state.board[point.y][point.x].tile!;
      
      // Try to find a word using rack + tileOnBoard
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
    
    // Simple greedy: look for words that start or end with tileOnBoard
    // but that's too simple. Let's just try to place a word horizontally or vertically
    // passing through (x,y).
    
    List<String> rackChars = state.cpuRack.map((e) => e.letter).toList();
    
    for (var word in dictionary.take(1000)) { // Just a slice for speed in prototype
      if (word.length < 2 || word.length > 7) continue;
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
      
      if (curX == x && curY == y) continue; // Skip the one already there

      if (state.board[curY][curX].tile != null) return null; // Clash

      final char = word[i];
      final tile = state.cpuRack.firstWhere((t) => t.letter == char);
      placements.add(TilePlacement(tile: tile, x: curX, y: curY));
    }
    
    return placements;
  }

  static List<TilePlacement>? _tryFindWordFromRack(
    List<ScrabbleTile> rack,
    Set<String> dictionary,
    int startX,
    int startY,
    bool horizontal,
  ) {
    // Simple logic for first move
    return null; // For now
  }
}
