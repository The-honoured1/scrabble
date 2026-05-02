extends Node

const SAVE_PATH := "user://save.cfg"
const GAME_IDS := [
	"wordle", "connections", "spelling_bee", "crossword", "word_search",
	"hangman", "boggle", "word_ladder", "type_racer", "anagram"
]

var streak := 0
var last_played := ""
var today_completed: Dictionary = {}

func _ready() -> void:
	_load_save()
	_reset_if_new_day()

func _today_key() -> String:
	return Time.get_date_string_from_system()

func _reset_if_new_day() -> void:
	var today := _today_key()
	if last_played != today:
		for game in GAME_IDS:
			today_completed[game] = false
		_save()

func _was_yesterday(prev_date: String, current_date: String) -> bool:
	if prev_date.is_empty():
		return false
	var prev_unix := Time.get_unix_time_from_datetime_string(prev_date + "T00:00:00")
	var cur_unix := Time.get_unix_time_from_datetime_string(current_date + "T00:00:00")
	return int((cur_unix - prev_unix) / 86400.0) == 1

func mark_complete(game_name: String) -> void:
	var today := _today_key()
	var had_any_today := get_today_completed_count() > 0
	if not had_any_today:
		if _was_yesterday(last_played, today):
			streak += 1
		elif last_played != today:
			streak = 1
	last_played = today
	today_completed[game_name] = true
	_save()

func get_today_completed_count() -> int:
	var count := 0
	for game in GAME_IDS:
		if today_completed.get(game, false):
			count += 1
	return count

func get_daily_index(puzzle_count: int) -> int:
	if puzzle_count <= 0:
		return 0
	var d := Time.get_date_dict_from_system()
	return int(d.day) % puzzle_count

func _load_save() -> void:
	for game in GAME_IDS:
		today_completed[game] = false
	var cfg := ConfigFile.new()
	var err := cfg.load(SAVE_PATH)
	if err != OK:
		return
	streak = int(cfg.get_value("progress", "streak", 0))
	last_played = str(cfg.get_value("progress", "last_played", ""))
	var stored: Dictionary = cfg.get_value("progress", "today_completed", {})
	for game in GAME_IDS:
		today_completed[game] = bool(stored.get(game, false))

func _save() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("progress", "streak", streak)
	cfg.set_value("progress", "last_played", last_played)
	cfg.set_value("progress", "today_completed", today_completed)
	cfg.save(SAVE_PATH)
