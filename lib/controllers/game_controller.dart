import 'package:flutter/foundation.dart';
import '../models/game_state.dart';
import '../models/tile_model.dart';
import '../models/board_model.dart';
import '../services/dictionary_service.dart';
import '../services/move_validator.dart';
import '../services/cpu_engine.dart';
import '../services/stats_service.dart';

class GameController extends ChangeNotifier {
  late GameState state;
  final DictionaryService _dictionary = DictionaryService();

  List<TilePlacement> pendingPlacements = [];

  GameController() {
    state = GameState.initialize();
  }

  void placeTile(ScrabbleTile tile, int x, int y) {
    if (state.board[y][x].tile != null) return;
    
    // Check if it's already in pending
    pendingPlacements.removeWhere((p) => p.x == x && p.y == y);
    pendingPlacements.add(TilePlacement(tile: tile, x: x, y: y));
    notifyListeners();
  }

  void commitMove() {
    if (pendingPlacements.isEmpty) return;

    // 1. Detect words formed
    final words = _detectWords();
    
    // 2. Validate words
    bool allValid = true;
    for (var word in words) {
      if (!_dictionary.isValidWord(word.text)) {
        allValid = false;
        break;
      }
    }

    if (allValid && words.isNotEmpty) {
      // 3. Score words
      int moveScore = _calculateScore(words);
      
      // 4. Update board and score
      for (var p in pendingPlacements) {
        state.board[p.y][p.x].tile = p.tile;
        state.playerRack.remove(p.tile);
      }
      
      state.playerScore += moveScore;
      state.moveCount++;
      pendingPlacements.clear();
      
      // 5. Refill rack
      _refillRack(state.playerRack);
      
      // 6. Switch turn (CPU turn would trigger here)
      state.isPlayerTurn = false;
      notifyListeners();
      
      _triggerCpuTurn();
    } else {
      // Invalid move - shake UI or show error
      // For now just clear pending for simplicity in prototype
      notifyListeners();
    }
  }

  List<FormedWord> _detectWords() {
    return MoveValidator.findFormedWords(state.board, pendingPlacements);
  }

  int _calculateScore(List<FormedWord> words) {
    int total = 0;
    for (var word in words) {
      int wordMultiplier = 1;
      int wordPoints = 0;
      
      for (var spot in word.spots) {
        int charPoints = spot.tile.points;
        final square = state.board[spot.y][spot.x];
        
        if (!square.isPremiumUsed) {
          if (square.multiplier == MultiplierType.doubleLetter) charPoints *= 2;
          if (square.multiplier == MultiplierType.tripleLetter) charPoints *= 3;
          if (square.multiplier == MultiplierType.doubleWord) wordMultiplier *= 2;
          if (square.multiplier == MultiplierType.tripleWord) wordMultiplier *= 3;
        }
        wordPoints += charPoints;
      }
      total += (wordPoints * wordMultiplier);
    }
    return total;
  }

  void _refillRack(List<ScrabbleTile> rack) {
    while (rack.length < 7 && state.bag.isNotEmpty) {
      rack.add(state.bag.removeLast());
    }
  }

  void _triggerCpuTurn() async {
    if (state.isPlayerTurn) return;

    await Future.delayed(const Duration(seconds: 2));
    
    final cpuMove = await CpuEngine.findMove(state, _dictionary.words ?? {});
    
    if (cpuMove != null) {
      final words = MoveValidator.findFormedWords(state.board, cpuMove);
      if (words.isNotEmpty) {
        int moveScore = _calculateScore(words);
        
        for (var p in cpuMove) {
          state.board[p.y][p.x].tile = p.tile;
          state.cpuRack.remove(p.tile);
        }
        
        state.cpuScore += moveScore;
        _refillRack(state.cpuRack);
      }
    }
    
    state.isPlayerTurn = true;
    state.moveCount++;
    notifyListeners();
    _checkEndGame();
  }

  void _checkEndGame() {
    bool bagEmpty = state.bag.isEmpty;
    bool playerDone = state.playerRack.isEmpty;
    bool cpuDone = state.cpuRack.isEmpty;

    if (bagEmpty && (playerDone || cpuDone)) {
      StatsService.recordGame(
        score: state.playerScore,
        won: state.playerScore > state.cpuScore,
        bestWord: 0, // Would need actual best word tracking
      );
      // Navigate to results screen or show overlay
    }
  }
}

class TilePlacement {
  final ScrabbleTile tile;
  final int x;
  final int y;
  TilePlacement({required this.tile, required this.x, required this.y});
}

class FormedWord {
  final String text;
  final List<TilePlacement> spots;
  FormedWord({required this.text, required this.spots});
}
