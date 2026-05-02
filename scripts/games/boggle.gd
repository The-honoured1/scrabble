extends Control

const TOAST := preload("res://components/ToastNotif.tscn")
const DIALOG := preload("res://components/DialogPanel.tscn")

const SIZE := 4
const LETTER_POOL := "EEEEAAAAIIIONNRRTTLSSUDGBCMPFHVWYKJXQZ"

var grid_letters: Array = []
var selected: Array[Vector2i] = []
var found: Dictionary = {}
var score := 0
var time_left := 90.0
var grid_buttons: Array = []
var score_label: Label
var timer_label: Label
var word_label: Label
var toast
var dialog
@onready var theme: Variant = get_node("/root/AppTheme")

func _ready() -> void:
	_generate_grid()
	_build_ui()

func _process(delta: float) -> void:
	time_left -= delta
	timer_label.text = "⏳ %d" % max(0, int(ceil(time_left)))
	if time_left <= 0:
		set_process(false)
		dialog.show_result("Time!", "Score: %d\nWords: %d" % [score, found.size()], "Home")
		dialog.confirmed.connect(func() -> void: SceneManager.go_to("res://scenes/Home.tscn"), CONNECT_ONE_SHOT)

func _generate_grid() -> void:
	for r in range(SIZE):
		var row: Array = []
		for _c in range(SIZE):
			var idx := randi() % LETTER_POOL.length()
			row.append(LETTER_POOL.substr(idx, 1))
		grid_letters.append(row)

func _build_ui() -> void:
	var bg := ColorRect.new(); bg.color = theme.BG_DARK; bg.anchor_right = 1.0; bg.anchor_bottom = 1.0; add_child(bg)
	var root := VBoxContainer.new(); root.anchor_right = 1.0; root.anchor_bottom = 1.0; root.add_theme_constant_override("separation", 8); add_child(root)
	root.add_child(_top_bar("Boggle"))
	timer_label = Label.new(); root.add_child(timer_label)
	score_label = Label.new(); root.add_child(score_label)
	word_label = Label.new(); word_label.add_theme_font_size_override("font_size", 24); root.add_child(word_label)

	var grid := GridContainer.new(); grid.columns = SIZE; grid.add_theme_constant_override("h_separation", 4); grid.add_theme_constant_override("v_separation", 4); root.add_child(grid)
	for r in range(SIZE):
		var row: Array = []
		for c in range(SIZE):
			var b := Button.new()
			b.text = grid_letters[r][c]
			b.custom_minimum_size = Vector2(72, 72)
			b.pressed.connect(func(rr := r, cc := c) -> void: _pick(Vector2i(rr, cc)))
			grid.add_child(b)
			row.append(b)
		grid_buttons.append(row)

	var actions := HBoxContainer.new()
	var submit := Button.new(); submit.text = "Submit"; submit.pressed.connect(_submit_word); actions.add_child(submit)
	var clear := Button.new(); clear.text = "Clear"; clear.pressed.connect(_clear_selection); actions.add_child(clear)
	root.add_child(actions)

	toast = TOAST.instantiate(); add_child(toast)
	dialog = DIALOG.instantiate(); add_child(dialog)
	_refresh_meta()

func _top_bar(title: String) -> Control:
	var row := HBoxContainer.new()
	var back := Button.new(); back.text = "←"; back.pressed.connect(func() -> void: SceneManager.go_to("res://scenes/Home.tscn")); row.add_child(back)
	var l := Label.new(); l.text = title; l.add_theme_font_size_override("font_size", 28); row.add_child(l)
	return row

func are_adjacent(a: Vector2i, b: Vector2i) -> bool:
	return abs(a.x - b.x) <= 1 and abs(a.y - b.y) <= 1 and a != b

func _pick(p: Vector2i) -> void:
	if selected.has(p):
		return
	if selected.size() > 0 and not are_adjacent(selected[-1], p):
		toast.show_toast("Must be adjacent")
		return
	selected.append(p)
	grid_buttons[p.x][p.y].add_theme_stylebox_override("normal", theme.style_card(theme.ACCENT_AMBER))
	_refresh_word()

func _submit_word() -> void:
	var w := word_label.text
	if w.length() < 3:
		toast.show_toast("Too short")
		return
	if found.has(w):
		toast.show_toast("Already found")
		_clear_selection()
		return
	if not WordBank.is_valid_word(w):
		toast.show_toast("Invalid word")
		_clear_selection()
		return
	found[w] = true
	score += max(1, w.length() - 2)
	_clear_selection(false)
	_refresh_meta()
	if found.size() >= 8:
		GameManager.mark_complete("boggle")

func _clear_selection(reset_word := true) -> void:
	for p in selected:
		grid_buttons[p.x][p.y].add_theme_stylebox_override("normal", theme.style_card(theme.BG_SURFACE))
	selected.clear()
	if reset_word:
		word_label.text = ""

func _refresh_word() -> void:
	var w := ""
	for p in selected:
		w += grid_letters[p.x][p.y]
	word_label.text = w

func _refresh_meta() -> void:
	score_label.text = "Score: %d | Found: %d" % [score, found.size()]
