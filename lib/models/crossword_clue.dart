import 'clue_direction.dart';
import 'grid_position.dart';

class CrosswordClue {
  const CrosswordClue({
    required this.number,
    required this.direction,
    required this.row,
    required this.column,
    required this.length,
    required this.clue,
    required this.answer,
  });

  final int number;
  final ClueDirection direction;
  final int row;
  final int column;
  final int length;
  final String clue;
  final String answer;

  String get id => '${direction.name}-$number';

  List<GridPosition> get cells {
    return List<GridPosition>.generate(length, (index) {
      if (direction == ClueDirection.across) {
        return GridPosition(row, column + index);
      }
      return GridPosition(row + index, column);
    });
  }

  bool contains(GridPosition position) => cells.contains(position);

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'direction': direction.storageValue,
      'row': row,
      'column': column,
      'length': length,
      'clue': clue,
      'answer': answer,
    };
  }

  static CrosswordClue fromJson(Map<String, dynamic> json) {
    return CrosswordClue(
      number: (json['number'] as num?)?.toInt() ?? 0,
      direction: ClueDirectionX.fromStorageValue(
        json['direction'] as String? ?? ClueDirection.across.storageValue,
      ),
      row: (json['row'] as num?)?.toInt() ?? 0,
      column: (json['column'] as num?)?.toInt() ?? 0,
      length: (json['length'] as num?)?.toInt() ?? 0,
      clue: json['clue'] as String? ?? '',
      answer: json['answer'] as String? ?? '',
    );
  }
}
