extends Control

const TOAST := preload("res://components/ToastNotif.tscn")
const DIALOG := preload("res://components/DialogPanel.tscn")

const DIFF_COLORS := [
	Color("#F0C940"),
	Color("#52B788"),
	Color("#4A7FBF"),
	Color("#9D8FD4")
]

var puzzle: Dictionary = {}
var selected: Array = []
var solved_categories: Array = []
var lives := 4
var word_buttons: Dictionary = {}
var life_row: HBoxContainer
var solved_box: VBoxContainer
var toast
var dialog

func _ready() -> void:
	_load_puzzle()
	_build_ui()

func _load_puzzle() -> void:
	var txt := FileAccess.get_file_as_string("res://assets/puzzles/connections.json")
	var arr = JSON.parse_string(txt)
	if arr is Array and arr.size() > 0:
		puzzle = arr[GameManager.get_daily_index(arr.size())]

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
	root.add_child(_top_bar("Connections"))

	life_row = HBoxContainer.new()
	root.add_child(life_row)
	_refresh_lives()

	solved_box = VBoxContainer.new()
	root.add_child(solved_box)

	var grid := GridContainer.new()
	grid.columns = 4
	grid.add_theme_constant_override("h_separation", 6)
	grid.add_theme_constant_override("v_separation", 6)
	root.add_child(grid)

	var words: Array = []
	for cat in puzzle.categories:
		for w in cat.words:
			words.append(w)
	words.shuffle()

	for w in words:
		var b := Button.new()
		b.text = w
		b.custom_minimum_size = Vector2(0, 54)
		b.add_theme_stylebox_override("normal", AppTheme.style_card(AppTheme.BG_SURFACE))
		b.pressed.connect(func(word := w) -> void: _toggle_word(word))
		grid.add_child(b)
		word_buttons[w] = b

	var actions := HBoxContainer.new()
	var submit := Button.new()
	submit.text = "Submit"
	submit.pressed.connect(_submit_selection)
	actions.add_child(submit)
	var clear := Button.new()
	clear.text = "Deselect All"
	clear.pressed.connect(_clear_selection)
	actions.add_child(clear)
	root.add_child(actions)

	toast = TOAST.instantiate()
	add_child(toast)
	dialog = DIALOG.instantiate()
	add_child(dialog)

func _top_bar(title: String) -> Control:
	var row := HBoxContainer.new()
	var back := Button.new()
	back.text = "←"
	back.pressed.connect(func() -> void: SceneManager.go_to("res://scenes/Home.tscn"))
	row.add_child(back)
	var label := Label.new()
	label.text = title
	label.add_theme_font_size_override("font_size", 28)
	row.add_child(label)
	return row

func _toggle_word(word: String) -> void:
	if solved_categories.any(func(c): return word in c.words):
		return
	if selected.has(word):
		selected.erase(word)
	else:
		if selected.size() >= 4:
			return
		selected.append(word)
	_update_selected_styles()

func _update_selected_styles() -> void:
	for w in word_buttons.keys():
		var b: Button = word_buttons[w]
		if selected.has(w):
			b.scale = Vector2(1.03, 1.03)
			b.add_theme_stylebox_override("normal", AppTheme.style_card(AppTheme.BG_CARD.lightened(0.2)))
		else:
			b.scale = Vector2.ONE
			if not b.disabled:
				b.add_theme_stylebox_override("normal", AppTheme.style_card(AppTheme.BG_SURFACE))

func _submit_selection() -> void:
	if selected.size() != 4:
		toast.show_toast("Pick exactly 4 words")
		return
	for cat in puzzle.categories:
		var target: Array = cat.words.duplicate()
		target.sort()
		var guess := selected.duplicate()
		guess.sort()
		if guess == target:
			_mark_category_solved(cat)
			return
	var best := 0
	for cat in puzzle.categories:
		var hits := 0
		for s in selected:
			if s in cat.words:
				hits += 1
		best = max(best, hits)
	if best == 3:
		toast.show_toast("One away")
	for s in selected:
		var tw := create_tween()
		tw.tween_property(word_buttons[s], "position:x", word_buttons[s].position.x - 6, 0.06)
		tw.tween_property(word_buttons[s], "position:x", word_buttons[s].position.x + 6, 0.06)
		tw.tween_property(word_buttons[s], "position:x", word_buttons[s].position.x, 0.06)
	lives -= 1
	_refresh_lives()
	selected.clear()
	_update_selected_styles()
	if lives <= 0:
		dialog.show_result("Out of lives", "Try tomorrow's puzzle for a new challenge.")
		dialog.confirmed.connect(func() -> void: SceneManager.go_to("res://scenes/Home.tscn"), CONNECT_ONE_SHOT)

func _mark_category_solved(cat: Dictionary) -> void:
	solved_categories.append(cat)
	var row := Label.new()
	row.text = "%s — %s" % [cat.name, ", ".join(cat.words)]
	row.add_theme_font_size_override("font_size", 14)
	row.modulate = DIFF_COLORS[int(cat.difficulty)]
	solved_box.add_child(row)
	for w in cat.words:
		var b: Button = word_buttons[w]
		b.disabled = true
		b.add_theme_stylebox_override("normal", AppTheme.style_card(DIFF_COLORS[int(cat.difficulty)]))
	selected.clear()
	_update_selected_styles()
	if solved_categories.size() == 4:
		GameManager.mark_complete("connections")
		dialog.show_result("Perfect solve", "All categories completed.")
		dialog.confirmed.connect(func() -> void: SceneManager.go_to("res://scenes/Home.tscn"), CONNECT_ONE_SHOT)

func _clear_selection() -> void:
	selected.clear()
	_update_selected_styles()

func _refresh_lives() -> void:
	for c in life_row.get_children():
		c.queue_free()
	for i in range(4):
		var dot := Label.new()
		dot.text = "●"
		dot.modulate = AppTheme.ACCENT_RED if i < lives else AppTheme.BORDER
		life_row.add_child(dot)
