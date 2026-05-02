extends Node

var wordle_words: Array[String] = []
var dictionary: Dictionary = {}

func _ready() -> void:
	_load_wordle_words()
	_load_dictionary()

func _load_wordle_words() -> void:
	var p := "res://assets/words/wordle_words.json"
	if not FileAccess.file_exists(p):
		wordle_words = ["CRANE", "SLATE", "BRICK", "GHOST", "PLANT"]
		return
	var txt := FileAccess.get_file_as_string(p)
	var data = JSON.parse_string(txt)
	if data is Array:
		wordle_words.clear()
		for w in data:
			wordle_words.append(str(w).to_upper())

func _load_dictionary() -> void:
	var p := "res://assets/words/dictionary.json"
	if not FileAccess.file_exists(p):
		dictionary = {"CRANE": true, "SLATE": true, "BRICK": true, "GHOST": true, "PLANT": true}
		return
	var txt := FileAccess.get_file_as_string(p)
	var data = JSON.parse_string(txt)
	if data is Dictionary:
		dictionary = data

func is_valid_word(word: String) -> bool:
	return dictionary.has(word.to_upper())

func get_daily_word() -> String:
	if wordle_words.is_empty():
		return "CRANE"
	return wordle_words[GameManager.get_daily_index(wordle_words.size())]
