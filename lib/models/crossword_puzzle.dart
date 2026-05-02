import 'clue_direction.dart';
import 'crossword_clue.dart';
import 'grid_position.dart';

class CrosswordPuzzle {
  const CrosswordPuzzle({
    required this.id,
    required this.title,
    required this.rows,
    required this.clues,
    this.publishedDate,
  });

  final String id;
  final String title;
  final List<String> rows;
  final List<CrosswordClue> clues;
  final DateTime? publishedDate;

  int get size => rows.length;

  List<CrosswordClue> get acrossClues => clues
      .where((clue) => clue.direction == ClueDirection.across)
      .toList()
    ..sort((a, b) => a.number.compareTo(b.number));

  List<CrosswordClue> get downClues => clues
      .where((clue) => clue.direction == ClueDirection.down)
      .toList()
    ..sort((a, b) => a.number.compareTo(b.number));

  bool isInBounds(GridPosition position) {
    return position.row >= 0 &&
        position.column >= 0 &&
        position.row < size &&
        position.column < rows[position.row].length;
  }

  bool isBlock(GridPosition position) {
    if (!isInBounds(position)) {
      return true;
    }
    return rows[position.row][position.column] == '#';
  }

  String solutionAt(GridPosition position) {
    if (!isInBounds(position) || isBlock(position)) {
      return '';
    }
    return rows[position.row][position.column].toUpperCase();
  }

  List<GridPosition> get playableCells {
    final cells = <GridPosition>[];
    for (var row = 0; row < rows.length; row++) {
      for (var column = 0; column < rows[row].length; column++) {
        final position = GridPosition(row, column);
        if (!isBlock(position)) {
          cells.add(position);
        }
      }
    }
    return cells;
  }

  CrosswordClue? clueForCell(GridPosition position, ClueDirection direction) {
    for (final clue in clues) {
      if (clue.direction == direction && clue.contains(position)) {
        return clue;
      }
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'rows': rows,
      'clues': clues.map((clue) => clue.toJson()).toList(),
      'publishedDate': publishedDate?.toIso8601String(),
    };
  }

  static CrosswordPuzzle fromJson(Map<String, dynamic> json) {
    final cluesJson = (json['clues'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .toList();

    return CrosswordPuzzle(
      id: json['id'] as String? ?? 'wordie-puzzle',
      title: json['title'] as String? ?? 'Wordie Puzzle',
      rows: (json['rows'] as List<dynamic>? ?? []).whereType<String>().toList(),
      clues: cluesJson.map(CrosswordClue.fromJson).toList(),
      publishedDate: DateTime.tryParse(json['publishedDate'] as String? ?? ''),
    );
  }
}
