import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'history_service.dart';

class StatsService {
  static const String _key = 'scrabble_stats';

  static Future<Map<String, dynamic>> getStats() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_key);
    if (data == null) return _defaultStats();
    return jsonDecode(data);
  }

  static Future<void> recordGame({
    required int score,
    required int cpuScore,
    required bool won,
    required int bestWord,
    required String mode,
  }) async {
    final stats = await getStats();
    stats['gamesPlayed'] = (stats['gamesPlayed'] ?? 0) + 1;
    if (won) {
      stats['wins'] = (stats['wins'] ?? 0) + 1;
      stats['currentStreak'] = (stats['currentStreak'] ?? 0) + 1;
      if (stats['currentStreak'] > (stats['maxStreak'] ?? 0)) {
        stats['maxStreak'] = stats['currentStreak'];
      }
    } else {
      stats['currentStreak'] = 0;
    }
    
    final currentBest = stats['bestWord'] ?? 0;
    if (bestWord > currentBest) stats['bestWord'] = bestWord;
    
    final totalPoints = (stats['totalPoints'] ?? 0) + score;
    stats['totalPoints'] = totalPoints;
    stats['avgScore'] = totalPoints ~/ stats['gamesPlayed'];

    // Update score distribution (bins of 100)
    final bin = (score ~/ 100).clamp(0, 5);
    List<int> distribution = List<int>.from(stats['scoreDistribution'] ?? [0, 0, 0, 0, 0, 0]);
    distribution[bin]++;
    stats['scoreDistribution'] = distribution;

    // Record history
    await HistoryService.addHistoryItem(HistoryItem(
      date: DateTime.now(),
      playerScore: score,
      cpuScore: cpuScore,
      won: won,
      mode: mode,
    ));

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
      'currentStreak': 0,
      'maxStreak': 0,
      'scoreDistribution': [0, 0, 0, 0, 0, 0],
    };
  }
}
