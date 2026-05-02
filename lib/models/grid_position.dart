class GridPosition {
  const GridPosition(this.row, this.column);

  final int row;
  final int column;

  String get key => '$row,$column';

  static GridPosition fromKey(String value) {
    final split = value.split(',');
    if (split.length != 2) {
      return const GridPosition(0, 0);
    }
    return GridPosition(
      int.tryParse(split[0]) ?? 0,
      int.tryParse(split[1]) ?? 0,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is GridPosition && other.row == row && other.column == column;
  }

  @override
  int get hashCode => Object.hash(row, column);
}
