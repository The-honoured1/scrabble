import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StatsService {
  static const String _key = 'scrabble_stats';

  static Future<Map<String, dynamic>> getStats() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_key);
    if (data == null) return _defaultStats();
    return jsonDecode(data);
  }

  static Future<void> recordGame({required int score, required bool won, required int bestWord}) async {
    final stats = await getStats();
    stats['gamesPlayed'] = (stats['gamesPlayed'] ?? 0) + 1;
    if (won) stats['wins'] = (stats['wins'] ?? 0) + 1;
    
    final currentBest = stats['bestWord'] ?? 0;
    if (bestWord > currentBest) stats['bestWord'] = bestWord;
    
    final totalPoints = (stats['totalPoints'] ?? 0) + score;
    stats['totalPoints'] = totalPoints;
    stats['avgScore'] = totalPoints ~/ stats['gamesPlayed'];

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(stats));
  }

  static Map<String, dynamic> _defaultStats() {
    return {
      'gamesPlayed': 0,
      'wins': 0,
      'avgScore': 0,
      'bestWord': 0,
      'totalPoints': 0,
    };
  }
}
