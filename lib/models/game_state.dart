import 'dart:math';
import 'tile_model.dart';
import 'board_model.dart';

class GameState {
  final List<List<BoardSquare>> board;
  final List<ScrabbleTile> bag;
  final List<ScrabbleTile> playerRack;
  final List<ScrabbleTile> cpuRack;
  int playerScore;
  int cpuScore;
  bool isPlayerTurn;
  int moveCount;

  GameState({
    required this.board,
    required this.bag,
    required this.playerRack,
    required this.cpuRack,
    this.playerScore = 0,
    this.cpuScore = 0,
    this.isPlayerTurn = true,
    this.moveCount = 1,
  });

  static GameState initialize() {
    final bag = <ScrabbleTile>[];
    ScrabbleTile.distribution.forEach((letter, count) {
      for (var i = 0; i < count; i++) {
        bag.add(ScrabbleTile.fromLetter(letter));
      }
    });
    bag.shuffle();

    final playerRack = <ScrabbleTile>[];
    final cpuRack = <ScrabbleTile>[];

    for (var i = 0; i < 7; i++) {
      playerRack.add(bag.removeLast());
      cpuRack.add(bag.removeLast());
    }

    return GameState(
      board: BoardSquare.createStandardBoard(),
      bag: bag,
      playerRack: playerRack,
      cpuRack: cpuRack,
    );
  }
}
