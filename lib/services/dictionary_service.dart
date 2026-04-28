import 'package:flutter/services.dart';

class DictionaryService {
  static final DictionaryService _instance = DictionaryService._internal();
  factory DictionaryService() => _instance;
  DictionaryService._internal();

  Set<String>? _words;
  bool _isLoading = false;

  bool get isLoaded => _words != null;

  Future<void> loadDictionary() async {
    if (_words != null || _isLoading) return;
    _isLoading = true;
    
    try {
      final String data = await rootBundle.loadString('assets/dictionary.txt');
      // SOWPODS is usually line-separated. Some files might have carriage returns.
      _words = data.split('\n').map((w) => w.trim().toUpperCase()).toSet();
      print('Dictionary loaded: ${_words!.length} words');
    } catch (e) {
      print('Error loading dictionary: $e');
    } finally {
      _isLoading = false;
    }
  }

  bool isValidWord(String word) {
    if (_words == null) return true; // Fail open if not loaded yet for demo
    return _words!.contains(word.trim().toUpperCase());
  }
}
