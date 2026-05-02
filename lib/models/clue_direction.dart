enum ClueDirection { across, down }

extension ClueDirectionX on ClueDirection {
  String get shortLabel => this == ClueDirection.across ? 'A' : 'D';
  String get title => this == ClueDirection.across ? 'Across' : 'Down';

  String get storageValue => name;

  static ClueDirection fromStorageValue(String value) {
    return value == ClueDirection.down.name
        ? ClueDirection.down
        : ClueDirection.across;
  }
}
