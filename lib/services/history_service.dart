import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryItem {
  final DateTime date;
  final int playerScore;
  final int cpuScore;
  final bool won;
  final String mode;

  HistoryItem({
    required this.date,
    required this.playerScore,
    required this.cpuScore,
    required this.won,
    required this.mode,
  });

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'playerScore': playerScore,
    'cpuScore': cpuScore,
    'won': won,
    'mode': mode,
  };

  factory HistoryItem.fromJson(Map<String, dynamic> json) => HistoryItem(
    date: DateTime.parse(json['date']),
    playerScore: json['playerScore'],
    cpuScore: json['cpuScore'],
    won: json['won'],
    mode: json['mode'] ?? 'VS COMPUTER',
  );
}

class HistoryService {
  static const String _key = 'scrabble_history';

  static Future<List<HistoryItem>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_key);
    if (data == null) return [];
    return data.map((item) => HistoryItem.fromJson(jsonDecode(item))).toList();
  }

  static Future<void> addHistoryItem(HistoryItem item) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getHistory();
    history.insert(0, item); // Newest first
    
    // Keep only last 50 games
    final limitedHistory = history.take(50).toList();
    
    await prefs.setStringList(
      _key,
      limitedHistory.map((e) => jsonEncode(e.toJson())).toList(),
    );
  }
}
