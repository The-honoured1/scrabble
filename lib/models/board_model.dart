import 'tile_model.dart';

enum MultiplierType { none, doubleLetter, tripleLetter, doubleWord, tripleWord }

class BoardSquare {
  final int x;
  final int y;
  final MultiplierType multiplier;
  ScrabbleTile? tile;
  bool isPremiumUsed;

  BoardSquare({
    required this.x,
    required this.y,
    this.multiplier = MultiplierType.none,
    this.tile,
    this.isPremiumUsed = false,
  });

  static List<List<BoardSquare>> createStandardBoard() {
    return List.generate(15, (y) {
      return List.generate(15, (x) {
        MultiplierType type = MultiplierType.none;

        // Triple Word Squares
        if ((x == 0 || x == 7 || x == 14) && (y == 0 || y == 7 || y == 14) && !(x == 7 && y == 7)) {
          type = MultiplierType.tripleWord;
        }
        // Double Word Squares
        else if ((x == y || x == 14 - y) && ((x >= 1 && x <= 4) || (x >= 10 && x <= 13))) {
          type = MultiplierType.doubleWord;
        } else if (x == 7 && y == 7) {
          type = MultiplierType.doubleWord; // Center is usually double word
        }
        // Triple Letter Squares
        else if (((x == 1 || x == 5 || x == 9 || x == 13) && (y == 1 || y == 5 || y == 9 || y == 13)) &&
            ((x == 5 || x == 9) || (y == 5 || y == 9))) {
          // This is a simplified version of the pattern
          if ((x == 5 || x == 9) && (y == 1 || y == 5 || y == 9 || y == 13)) type = MultiplierType.tripleLetter;
          if ((y == 5 || y == 9) && (x == 1 || x == 5 || x == 9 || x == 13)) type = MultiplierType.tripleLetter;
        }
        // Double Letter Squares
        else if ((x == 0 || x == 7 || x == 14) && (y == 3 || y == 11)) type = MultiplierType.doubleLetter;
        else if ((y == 0 || y == 7 || y == 14) && (x == 3 || x == 11)) type = MultiplierType.doubleLetter;
        else if ((x == 2 || x == 6 || x == 8 || x == 12) && (y == 6 || y == 8)) type = MultiplierType.doubleLetter;
        else if ((y == 2 || y == 6 || y == 8 || y == 12) && (x == 6 || x == 8)) type = MultiplierType.doubleLetter;

        return BoardSquare(x: x, y: y, multiplier: type);
      });
    });
  }
}
