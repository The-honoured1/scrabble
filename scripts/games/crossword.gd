extends Control

const KEYBOARD := preload("res://components/Keyboard.tscn")
const TOAST := preload("res://components/ToastNotif.tscn")

var puzzle: Dictionary
var cells: Array = []
var selected := Vector2i(0, 0)
var keyboard
var toast

func _ready() -> void:
	var txt := FileAccess.get_file_as_string("res://assets/puzzles/crossword.json")
	var arr = JSON.parse_string(txt)
	puzzle = arr[0]
	_build_ui()

func _build_ui() -> void:
	var bg := ColorRect.new(); bg.color = AppTheme.BG_DARK; bg.anchor_right = 1.0; bg.anchor_bottom = 1.0; add_child(bg)
	var root := VBoxContainer.new(); root.anchor_right = 1.0; root.anchor_bottom = 1.0; root.add_theme_constant_override("separation", 8); add_child(root)
	root.add_child(_top_bar("Crossword"))

	var grid := GridContainer.new()
	grid.columns = 5
	grid.add_theme_constant_override("h_separation", 2)
	grid.add_theme_constant_override("v_separation", 2)
	root.add_child(grid)
	for r in range(5):
		var row: Array = []
		for c in range(5):
			if puzzle.grid[r][c] == null:
				var b := ColorRect.new()
				b.custom_minimum_size = Vector2(48, 48)
				b.color = Color.BLACK
				grid.add_child(b)
				row.append(null)
			else:
				var e := LineEdit.new()
				e.custom_minimum_size = Vector2(48, 48)
				e.max_length = 1
				e.alignment = HORIZONTAL_ALIGNMENT_CENTER
				e.text_submitted.connect(func(_v := "", rr := r, cc := c) -> void: _select(rr, cc))
				e.gui_input.connect(func(ev: InputEvent, rr := r, cc := c) -> void:
					if ev is InputEventMouseButton and ev.pressed:
						_select(rr, cc))
				grid.add_child(e)
				row.append(e)
		cells.append(row)

	var clue_title := Label.new()
	clue_title.text = "Across / Down clues"
	root.add_child(clue_title)
	var clues := RichTextLabel.new()
	clues.custom_minimum_size.y = 120
	clues.bbcode_enabled = true
	clues.text = _clues_text()
	root.add_child(clues)

	var actions := HBoxContainer.new()
	var check := Button.new(); check.text = "Check"; check.pressed.connect(_check)
	var reveal := Button.new(); reveal.text = "Reveal"; reveal.pressed.connect(_reveal_selected)
	actions.add_child(check); actions.add_child(reveal)
	root.add_child(actions)

	keyboard = KEYBOARD.instantiate()
	keyboard.key_pressed.connect(_on_key)
	root.add_child(keyboard)
	toast = TOAST.instantiate()
	add_child(toast)

func _top_bar(title: String) -> Control:
	var row := HBoxContainer.new()
	var back := Button.new(); back.text = "←"; back.pressed.connect(func() -> void: SceneManager.go_to("res://scenes/Home.tscn")); row.add_child(back)
	var l := Label.new(); l.text = title; l.add_theme_font_size_override("font_size", 28); row.add_child(l)
	return row

func _clues_text() -> String:
	var t := "[b]Across[/b]\n"
	for c in puzzle.clues.across:
		t += "%d. %s\n" % [c.number, c.clue]
	t += "\n[b]Down[/b]\n"
	for c in puzzle.clues.down:
		t += "%d. %s\n" % [c.number, c.clue]
	return t

func _select(r: int, c: int) -> void:
	selected = Vector2i(r, c)
	for rr in range(5):
		for cc in range(5):
			var e = cells[rr][cc]
			if e:
				e.add_theme_color_override("font_color", AppTheme.TEXT_PRIMARY)
	var selected_cell = cells[r][c]
	if selected_cell:
		selected_cell.add_theme_color_override("font_color", AppTheme.ACCENT_NAVY)

func _on_key(key: String) -> void:
	var e = cells[selected.x][selected.y]
	if e == null:
		return
	if key == "DEL":
		e.text = ""
	elif key.length() == 1:
		e.text = key
		_advance()

func _advance() -> void:
	var c := selected.y + 1
	while c < 5:
		if cells[selected.x][c] != null:
			selected.y = c
			return
		c += 1

func _check() -> void:
	var wrong := 0
	for r in range(5):
		for c in range(5):
			var e = cells[r][c]
			if e != null and e.text != "" and e.text.to_upper() != str(puzzle.grid[r][c]):
				e.add_theme_color_override("font_color", AppTheme.ACCENT_RED)
				wrong += 1
	if wrong == 0:
		toast.show_toast("Looks good!")
	else:
		toast.show_toast("%d incorrect" % wrong)

func _reveal_selected() -> void:
	var e = cells[selected.x][selected.y]
	if e and puzzle.grid[selected.x][selected.y] != null:
		e.text = str(puzzle.grid[selected.x][selected.y])
