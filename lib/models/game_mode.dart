enum WordieGameMode {
  dailyChallenge,
  classic,
  speed,
  hard,
  streak,
  practice,
}

extension WordieGameModeX on WordieGameMode {
  String get storageValue => name;

  String get title => switch (this) {
    WordieGameMode.dailyChallenge => 'Daily Challenge',
    WordieGameMode.classic => 'Classic Mode',
    WordieGameMode.speed => 'Speed Mode',
    WordieGameMode.hard => 'Hard Mode',
    WordieGameMode.streak => 'Streak Mode',
    WordieGameMode.practice => 'Practice Mode',
  };

  String get subtitle => switch (this) {
    WordieGameMode.dailyChallenge => 'One global puzzle each day',
    WordieGameMode.classic => 'Traditional across/down crossword',
    WordieGameMode.speed => 'Beat the countdown clock',
    WordieGameMode.hard => 'No hints, minimal clues',
    WordieGameMode.streak => 'Keep your daily chain alive',
    WordieGameMode.practice => 'Unlimited local puzzle practice',
  };

  bool get isPremiumMode => switch (this) {
    WordieGameMode.dailyChallenge => false,
    WordieGameMode.classic => false,
    WordieGameMode.practice => false,
    WordieGameMode.speed => true,
    WordieGameMode.hard => true,
    WordieGameMode.streak => true,
  };

  static WordieGameMode fromStorageValue(String value) {
    return WordieGameMode.values.firstWhere(
      (mode) => mode.name == value,
      orElse: () => WordieGameMode.classic,
    );
  }
}
