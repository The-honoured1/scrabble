extends Control

const HEX_TILE := preload("res://components/HexTile.tscn")
const TOAST := preload("res://components/ToastNotif.tscn")

const PUZZLES := [
	{"center":"A","outer":["N","E","L","T","P","R"]},
	{"center":"O","outer":["W","R","D","G","L","M"]}
]
const RANKS := [
	{"name":"Beginner","score":0},{"name":"Good Start","score":2},{"name":"Moving Up","score":5},
	{"name":"Good","score":8},{"name":"Solid","score":15},{"name":"Nice","score":25},
	{"name":"Great","score":40},{"name":"Amazing","score":60},{"name":"Genius","score":100}
]

var puzzle: Dictionary
var current_word := ""
var found: Dictionary = {}
var score := 0
var display_word: Label
var score_label: Label
var rank_label: Label
var found_list: VBoxContainer
var toast

func _ready() -> void:
	puzzle = PUZZLES[GameManager.get_daily_index(PUZZLES.size())]
	_build_ui()
	_update_labels()

func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.color = AppTheme.BG_DARK
	bg.anchor_right = 1.0
	bg.anchor_bottom = 1.0
	add_child(bg)
	var root := VBoxContainer.new()
	root.anchor_right = 1.0
	root.anchor_bottom = 1.0
	root.add_theme_constant_override("separation", 10)
	add_child(root)
	root.add_child(_top_bar("Spelling Bee"))

	display_word = Label.new()
	display_word.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	display_word.add_theme_font_size_override("font_size", 28)
	root.add_child(display_word)

	score_label = Label.new()
	root.add_child(score_label)
	rank_label = Label.new()
	root.add_child(rank_label)

	var center := Vector2(195, 300)
	var outer_offsets := [
		Vector2(0, -104), Vector2(90, -52), Vector2(90, 52),
		Vector2(0, 104), Vector2(-90, 52), Vector2(-90, -52)
	]
	var center_tile = HEX_TILE.instantiate()
	center_tile.position = center
	center_tile.text = puzzle.center
	center_tile.is_center = true
	center_tile._update_style()
	center_tile.pressed.connect(func() -> void: _append_letter(puzzle.center))
	add_child(center_tile)
	for i in range(6):
		var t = HEX_TILE.instantiate()
		t.position = center + outer_offsets[i]
		t.text = puzzle.outer[i]
		t.pressed.connect(func(letter := puzzle.outer[i]) -> void: _append_letter(letter))
		add_child(t)

	var actions := HBoxContainer.new()
	var del := Button.new(); del.text = "DELETE"; del.pressed.connect(func() -> void: current_word = current_word.substr(0, max(0, current_word.length() - 1)); _update_labels())
	var shuf := Button.new(); shuf.text = "SHUFFLE"; shuf.pressed.connect(_shuffle_outer)
	var enter := Button.new(); enter.text = "ENTER"; enter.pressed.connect(_submit_word)
	actions.add_child(del); actions.add_child(shuf); actions.add_child(enter)
	root.add_child(actions)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(scroll)
	found_list = VBoxContainer.new()
	scroll.add_child(found_list)

	toast = TOAST.instantiate()
	add_child(toast)

func _top_bar(title: String) -> Control:
	var row := HBoxContainer.new()
	var back := Button.new(); back.text = "←"; back.pressed.connect(func() -> void: SceneManager.go_to("res://scenes/Home.tscn")); row.add_child(back)
	var label := Label.new(); label.text = title; label.add_theme_font_size_override("font_size", 28); row.add_child(label)
	return row

func _append_letter(letter: String) -> void:
	current_word += letter
	_update_labels()

func _shuffle_outer() -> void:
	puzzle.outer.shuffle()
	toast.show_toast("Shuffled")

func _submit_word() -> void:
	var w := current_word.to_upper()
	if w.length() < 4:
		toast.show_toast("Word too short")
		return
	if not w.contains(puzzle.center):
		toast.show_toast("Must include center letter")
		return
	if found.has(w):
		toast.show_toast("Already found")
		return
	if not WordBank.is_valid_word(w):
		toast.show_toast("Not in dictionary")
		return
	var pts := 1 if w.length() == 4 else min(w.length(), 7)
	if _is_pangram(w):
		pts += 7
	found[w] = true
	score += pts
	var l := Label.new()
	l.text = "%s (+%d)" % [w, pts]
	found_list.add_child(l)
	current_word = ""
	_update_labels()
	if found.size() >= 5:
		GameManager.mark_complete("spelling_bee")

func _is_pangram(w: String) -> bool:
	var all_letters: Array = [puzzle.center]
	all_letters.append_array(puzzle.outer)
	for letter in all_letters:
		if not w.contains(letter):
			return false
	return true

func _rank_name() -> String:
	var rank := "Beginner"
	for r in RANKS:
		if score >= int(r.score):
			rank = r.name
	return rank

func _update_labels() -> void:
	display_word.text = current_word
	score_label.text = "Score: %d" % score
	rank_label.text = "Rank: %s" % _rank_name()
