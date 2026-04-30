import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppState extends ChangeNotifier {
  static const _streakKey = 'wordie_streak';
  static const _completedKey = 'wordie_completed';
  static const _lastResetKey = 'wordie_last_reset';

  int streak = 1;
  Map<String, bool> completed = {};
  int todayCompleted = 0;
  DateTime referenceDate = DateTime.now();
  bool loaded = false;

  AppState() {
    load();
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    streak = prefs.getInt(_streakKey) ?? 1;
    final completedJson = prefs.getString(_completedKey);
    if (completedJson != null) {
      try {
        final decoded = jsonDecode(completedJson) as Map<String, dynamic>;
        completed = decoded.map((key, value) => MapEntry(key, value as bool));
      } catch (_) {
        completed = {};
      }
    }
    final lastReset = prefs.getString(_lastResetKey);
    if (lastReset != null) {
      referenceDate = DateTime.tryParse(lastReset) ?? DateTime.now();
    }
    _resetIfNeeded();
    loaded = true;
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_streakKey, streak);
    await prefs.setString(_completedKey, jsonEncode(completed));
    await prefs.setString(_lastResetKey, referenceDate.toIso8601String());
  }

  void _resetIfNeeded() {
    final now = DateTime.now();
    if (now.year != referenceDate.year || now.month != referenceDate.month || now.day != referenceDate.day) {
      referenceDate = DateTime(now.year, now.month, now.day);
      completed = {};
      todayCompleted = 0;
      _save();
    } else {
      todayCompleted = completed.values.where((v) => v).length;
    }
  }

  bool isCompleted(String gameId) {
    return completed[gameId] == true;
  }

  void markComplete(String gameId) {
    if (!isCompleted(gameId)) {
      completed[gameId] = true;
      todayCompleted = completed.values.where((v) => v).length;
      streak += 1;
      _save();
      notifyListeners();
    }
  }

  void resetProgress() {
    completed = {};
    todayCompleted = 0;
    referenceDate = DateTime.now();
    _save();
    notifyListeners();
  }
}
