extends Control

const DIALOG := preload("res://components/DialogPanel.tscn")

const WORDS := {
	"ANIMALS": ["TIGER", "ZEBRA", "PANDA"],
	"SPACE": ["PLANET", "COMET", "GALAXY"],
	"MUSIC": ["JAZZ", "BLUES", "RHYTHM"]
}

class HangmanCanvas:
	extends Node2D
	var stage := 0
	func set_stage(s: int) -> void:
		stage = s
		queue_redraw()
	func _draw() -> void:
		draw_line(Vector2(20, 200), Vector2(120, 200), AppTheme.TEXT_PRIMARY, 4)
		draw_line(Vector2(50, 200), Vector2(50, 20), AppTheme.TEXT_PRIMARY, 4)
		draw_line(Vector2(50, 20), Vector2(130, 20), AppTheme.TEXT_PRIMARY, 4)
		if stage >= 1: draw_arc(Vector2(130, 45), 20, 0, TAU, 24, AppTheme.TEXT_PRIMARY, 3)
		if stage >= 2: draw_line(Vector2(130, 65), Vector2(130, 120), AppTheme.TEXT_PRIMARY, 3)
		if stage >= 3: draw_line(Vector2(130, 80), Vector2(100, 105), AppTheme.TEXT_PRIMARY, 3)
		if stage >= 4: draw_line(Vector2(130, 80), Vector2(160, 105), AppTheme.TEXT_PRIMARY, 3)
		if stage >= 5: draw_line(Vector2(130, 120), Vector2(105, 155), AppTheme.TEXT_PRIMARY, 3)
		if stage >= 6: draw_line(Vector2(130, 120), Vector2(155, 155), AppTheme.TEXT_PRIMARY, 3)

var category := ""
var word := ""
var guessed: Dictionary = {}
var wrong := 0
var word_label: Label
var wrong_label: Label
var drawing: HangmanCanvas
var dialog

func _ready() -> void:
	_pick_word()
	_build_ui()
	_refresh_word()

func _pick_word() -> void:
	var keys := WORDS.keys()
	category = keys[randi() % keys.size()]
	var list: Array = WORDS[category]
	word = list[randi() % list.size()]

func _build_ui() -> void:
	var bg := ColorRect.new(); bg.color = AppTheme.BG_DARK; bg.anchor_right = 1.0; bg.anchor_bottom = 1.0; add_child(bg)
	var root := VBoxContainer.new(); root.anchor_right = 1.0; root.anchor_bottom = 1.0; root.add_theme_constant_override("separation", 8); add_child(root)
	root.add_child(_top_bar("Hangman"))
	var hint := Label.new(); hint.text = "Category: %s" % category; root.add_child(hint)
	drawing = HangmanCanvas.new(); drawing.custom_minimum_size = Vector2(220, 220); root.add_child(drawing)
	word_label = Label.new(); word_label.add_theme_font_size_override("font_size", 28); root.add_child(word_label)
	wrong_label = Label.new(); root.add_child(wrong_label)
	var letters := GridContainer.new(); letters.columns = 7; root.add_child(letters)
	for ch in "ABCDEFGHIJKLMNOPQRSTUVWXYZ":
		var b := Button.new()
		b.text = ch
		b.custom_minimum_size = Vector2(44, 44)
		b.pressed.connect(func(letter := ch, btn := b) -> void:
			btn.disabled = true
			_guess(letter))
		letters.add_child(b)
	dialog = DIALOG.instantiate()
	add_child(dialog)

func _top_bar(title: String) -> Control:
	var row := HBoxContainer.new()
	var back := Button.new(); back.text = "←"; back.pressed.connect(func() -> void: SceneManager.go_to("res://scenes/Home.tscn")); row.add_child(back)
	var l := Label.new(); l.text = title; l.add_theme_font_size_override("font_size", 28); row.add_child(l)
	return row

func _guess(letter: String) -> void:
	guessed[letter] = true
	if not word.contains(letter):
		wrong += 1
		drawing.set_stage(wrong)
		wrong_label.text = "Wrong: %d / 6" % wrong
		if wrong >= 6:
			dialog.show_result("Game over", "Word: %s" % word, "Home")
			dialog.confirmed.connect(func() -> void: SceneManager.go_to("res://scenes/Home.tscn"), CONNECT_ONE_SHOT)
	else:
		_refresh_word()
		if not word_label.text.contains("_"):
			GameManager.mark_complete("hangman")
			dialog.show_result("Saved!", "You guessed %s" % word, "Home")
			dialog.confirmed.connect(func() -> void: SceneManager.go_to("res://scenes/Home.tscn"), CONNECT_ONE_SHOT)

func _refresh_word() -> void:
	var t := ""
	for i in range(word.length()):
		var ch := word.substr(i, 1)
		t += ch + " " if guessed.has(ch) else "_ "
	word_label.text = t.strip_edges()
