import '../models/board_model.dart';
import '../models/tile_model.dart';
import '../controllers/game_controller.dart';

class MoveValidator {
  static List<FormedWord> findFormedWords(
    List<List<BoardSquare>> board,
    List<TilePlacement> placements,
  ) {
    if (placements.isEmpty) return [];

    // 1. Check alignment (all in same row or same column)
    bool sameRow = placements.every((p) => p.y == placements[0].y);
    bool sameCol = placements.every((p) => p.x == placements[0].x);

    if (!sameRow && !sameCol) return [];

    List<FormedWord> words = [];

    // 2. Find primary word
    final primary = _getPrimaryWord(board, placements, sameRow);
    if (primary != null) words.add(primary);

    // 3. Find secondary words for each placement
    for (var p in placements) {
      final secondary = _getSecondaryWord(board, p, sameRow);
      if (secondary != null) words.add(secondary);
    }

    return words;
  }

  static FormedWord? _getPrimaryWord(
    List<List<BoardSquare>> board,
    List<TilePlacement> placements,
    bool isHorizontal,
  ) {
    // Sort placements by position
    placements.sort((a, b) => isHorizontal ? a.x.compareTo(b.x) : a.y.compareTo(b.y));

    int minPos = isHorizontal ? placements.first.x : placements.first.y;
    int maxPos = isHorizontal ? placements.last.x : placements.last.y;
    int fixedPos = isHorizontal ? placements.first.y : placements.first.x;

    // Expand search to include existing tiles connected to the ends
    int start = minPos;
    while (start > 0) {
      final nextTile = isHorizontal ? board[fixedPos][start - 1].tile : board[start - 1][fixedPos].tile;
      if (nextTile == null) break;
      start--;
    }

    int end = maxPos;
    while (end < 14) {
      final nextTile = isHorizontal ? board[fixedPos][end + 1].tile : board[end + 1][fixedPos].tile;
      if (nextTile == null) break;
      end++;
    }

    // Double check that all tiles in [start, end] are present (either pending or existing)
    List<TilePlacement> spots = [];
    StringBuffer sb = StringBuffer();

    for (int i = start; i <= end; i++) {
       final x = isHorizontal ? i : fixedPos;
       final y = isHorizontal ? fixedPos : i;
       
       final pending = placements.where((p) => p.x == x && p.y == y).firstOrNull;
       final tile = pending?.tile ?? board[y][x].tile;
       
       if (tile == null) return null; // Gap found
       
       spots.add(TilePlacement(tile: tile, x: x, y: y));
       sb.write(tile.letter);
    }

    if (sb.length <= 1) return null; // Single tile doesn't count as primary word on its own

    return FormedWord(text: sb.toString(), spots: spots);
  }

  static FormedWord? _getSecondaryWord(
    List<List<BoardSquare>> board,
    TilePlacement placement,
    bool primaryIsHorizontal,
  ) {
    bool isHorizontal = !primaryIsHorizontal;
    int start = isHorizontal ? placement.x : placement.y;
    int end = start;
    int fixedPos = isHorizontal ? placement.y : placement.x;

    // Expand
    while (start > 0) {
      final nextTile = isHorizontal ? board[fixedPos][start - 1].tile : board[start - 1][fixedPos].tile;
      if (nextTile == null) break;
      start--;
    }
    while (end < 14) {
      final nextTile = isHorizontal ? board[fixedPos][end + 1].tile : board[end + 1][fixedPos].tile;
      if (nextTile == null) break;
      end++;
    }

    if (start == end) return null;

    List<TilePlacement> spots = [];
    StringBuffer sb = StringBuffer();

    for (int i = start; i <= end; i++) {
       final x = isHorizontal ? i : fixedPos;
       final y = isHorizontal ? fixedPos : i;
       
       final tile = (x == placement.x && y == placement.y) ? placement.tile : board[y][x].tile;
       if (tile == null) return null;
       
       spots.add(TilePlacement(tile: tile, x: x, y: y));
       sb.write(tile.letter);
    }

    return FormedWord(text: sb.toString(), spots: spots);
  }
}
