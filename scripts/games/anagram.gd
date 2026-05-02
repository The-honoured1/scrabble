extends Control

const DIALOG := preload("res://components/DialogPanel.tscn")
const TOAST := preload("res://components/ToastNotif.tscn")

var puzzles: Array = []
var puzzle: Dictionary
var answer_slots: Array[Button] = []
var source_buttons: Array[Button] = []
var dialog
var toast
var clue_label: Label

func _ready() -> void:
	var txt := FileAccess.get_file_as_string("res://assets/puzzles/anagram.json")
	puzzles = JSON.parse_string(txt)
	puzzle = puzzles[GameManager.get_daily_index(puzzles.size())]
	_build_ui()

func _build_ui() -> void:
	var bg := ColorRect.new(); bg.color = AppTheme.BG_DARK; bg.anchor_right = 1.0; bg.anchor_bottom = 1.0; add_child(bg)
	var root := VBoxContainer.new(); root.anchor_right = 1.0; root.anchor_bottom = 1.0; root.add_theme_constant_override("separation", 10); add_child(root)
	root.add_child(_top_bar("Anagram"))
	clue_label = Label.new(); clue_label.text = "Clue: %s" % puzzle.clue; root.add_child(clue_label)

	var source_row := HBoxContainer.new()
	root.add_child(source_row)
	for ch in str(puzzle.scrambled):
		var b := Button.new()
		b.text = ch
		b.custom_minimum_size = Vector2(44, 44)
		b.pressed.connect(func(btn := b) -> void: _pick_from_source(btn))
		source_row.add_child(b)
		source_buttons.append(b)

	var answer_row := HBoxContainer.new()
	root.add_child(answer_row)
	for _i in range(puzzle.word.length()):
		var s := Button.new()
		s.text = "_"
		s.custom_minimum_size = Vector2(44, 44)
		s.pressed.connect(func(slot := s) -> void: _return_to_source(slot))
		answer_row.add_child(s)
		answer_slots.append(s)

	var actions := HBoxContainer.new()
	var shuffle := Button.new(); shuffle.text = "SHUFFLE"; shuffle.pressed.connect(_shuffle_remaining); actions.add_child(shuffle)
	var hint := Button.new(); hint.text = "HINT"; hint.pressed.connect(_hint); actions.add_child(hint)
	var check := Button.new(); check.text = "CHECK"; check.pressed.connect(_check); actions.add_child(check)
	root.add_child(actions)

	dialog = DIALOG.instantiate(); add_child(dialog)
	toast = TOAST.instantiate(); add_child(toast)

func _top_bar(title: String) -> Control:
	var row := HBoxContainer.new()
	var back := Button.new(); back.text = "←"; back.pressed.connect(func() -> void: SceneManager.go_to("res://scenes/Home.tscn")); row.add_child(back)
	var l := Label.new(); l.text = title; l.add_theme_font_size_override("font_size", 28); row.add_child(l)
	return row

func _pick_from_source(btn: Button) -> void:
	if btn.text == "":
		return
	for slot in answer_slots:
		if slot.text == "_":
			slot.text = btn.text
			btn.text = ""
			break

func _return_to_source(slot: Button) -> void:
	if slot.text == "_":
		return
	for b in source_buttons:
		if b.text == "":
			b.text = slot.text
			slot.text = "_"
			break

func _shuffle_remaining() -> void:
	var letters: Array = []
	for b in source_buttons:
		if b.text != "":
			letters.append(b.text)
	letters.shuffle()
	var idx := 0
	for b in source_buttons:
		if b.text != "":
			b.text = letters[idx]
			idx += 1

func _hint() -> void:
	for i in range(puzzle.word.length()):
		if answer_slots[i].text == "_":
			answer_slots[i].text = str(puzzle.word).substr(i, 1)
			return

func _check() -> void:
	var built := ""
	for s in answer_slots:
		built += s.text if s.text != "_" else ""
	if built.length() != puzzle.word.length():
		toast.show_toast("Fill all slots")
		return
	if built == puzzle.word:
		for s in answer_slots:
			s.add_theme_stylebox_override("normal", AppTheme.style_card(AppTheme.ACCENT_GREEN))
		GameManager.mark_complete("anagram")
		dialog.show_result("Solved!", "Correct: %s" % puzzle.word, "Home")
		dialog.confirmed.connect(func() -> void: SceneManager.go_to("res://scenes/Home.tscn"), CONNECT_ONE_SHOT)
	else:
		toast.show_toast("Try again")
		for s in answer_slots:
			var tw := create_tween()
			tw.tween_property(s, "position:x", s.position.x - 5, 0.04)
			tw.tween_property(s, "position:x", s.position.x + 5, 0.04)
			tw.tween_property(s, "position:x", s.position.x, 0.04)
