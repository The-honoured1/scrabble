extends Control

const DIALOG := preload("res://components/DialogPanel.tscn")

const TARGET_WORDS := ["CAT", "DOG", "RAIN", "SUN", "WIND", "FUNK"]
const SIZE := 12

var grid: Array = []
var labels: Array = []
var found: Dictionary = {}
var selected_cells: Array[Vector2i] = []
var grid_container: GridContainer
var word_list: VBoxContainer
var timer_label: Label
var elapsed := 0.0
var dialog

func _ready() -> void:
	_build_grid_data()
	_build_ui()

func _process(delta: float) -> void:
	elapsed += delta
	timer_label.text = "⏱ %ds" % int(elapsed)

func _build_ui() -> void:
	var bg := ColorRect.new(); bg.color = AppTheme.BG_DARK; bg.anchor_right = 1.0; bg.anchor_bottom = 1.0; add_child(bg)
	var root := VBoxContainer.new(); root.anchor_right = 1.0; root.anchor_bottom = 1.0; root.add_theme_constant_override("separation", 8); add_child(root)
	root.add_child(_top_bar("Word Search"))
	timer_label = Label.new(); root.add_child(timer_label)

	grid_container = GridContainer.new()
	grid_container.columns = SIZE
	grid_container.add_theme_constant_override("h_separation", 2)
	grid_container.add_theme_constant_override("v_separation", 2)
	root.add_child(grid_container)

	for r in range(SIZE):
		var row: Array = []
		for c in range(SIZE):
			var b := Button.new()
			b.text = grid[r][c]
			b.custom_minimum_size = Vector2(26, 26)
			b.pressed.connect(func(rr := r, cc := c) -> void: _select_cell(Vector2i(rr, cc)))
			grid_container.add_child(b)
			row.append(b)
		labels.append(row)

	word_list = VBoxContainer.new()
	root.add_child(word_list)
	_refresh_word_list()
	dialog = DIALOG.instantiate()
	add_child(dialog)

func _top_bar(title: String) -> Control:
	var row := HBoxContainer.new()
	var back := Button.new(); back.text = "←"; back.pressed.connect(func() -> void: SceneManager.go_to("res://scenes/Home.tscn")); row.add_child(back)
	var l := Label.new(); l.text = title; l.add_theme_font_size_override("font_size", 28); row.add_child(l)
	return row

func _build_grid_data() -> void:
	for r in range(SIZE):
		var row: Array = []
		for c in range(SIZE):
			row.append(String.chr(65 + randi() % 26))
		grid.append(row)
	for w in TARGET_WORDS:
		_place_word(w)

func _place_word(word: String) -> void:
	var dirs := [Vector2i(1,0), Vector2i(0,1), Vector2i(1,1), Vector2i(-1,1), Vector2i(-1,0), Vector2i(0,-1), Vector2i(-1,-1), Vector2i(1,-1)]
	for _i in range(100):
		var d: Vector2i = dirs[randi() % dirs.size()]
		var start := Vector2i(randi() % SIZE, randi() % SIZE)
		var ok := true
		for i in range(word.length()):
			var p := start + d * i
			if p.x < 0 or p.y < 0 or p.x >= SIZE or p.y >= SIZE:
				ok = false
				break
		if not ok:
			continue
		for i in range(word.length()):
			var p := start + d * i
			grid[p.x][p.y] = word.substr(i, 1)
		return

func _select_cell(p: Vector2i) -> void:
	selected_cells.append(p)
	labels[p.x][p.y].add_theme_stylebox_override("normal", AppTheme.style_card(AppTheme.ACCENT_AMBER))
	var w := ""
	for c in selected_cells:
		w += labels[c.x][c.y].text
	if TARGET_WORDS.has(w) and not found.has(w):
		found[w] = true
		for c in selected_cells:
			labels[c.x][c.y].add_theme_stylebox_override("normal", AppTheme.style_card(AppTheme.ACCENT_GREEN))
		selected_cells.clear()
		_refresh_word_list()
		if found.size() == TARGET_WORDS.size():
			GameManager.mark_complete("word_search")
			dialog.show_result("All found!", "Time: %ds" % int(elapsed), "Home")
			dialog.confirmed.connect(func() -> void: SceneManager.go_to("res://scenes/Home.tscn"), CONNECT_ONE_SHOT)
	elif w.length() >= 8:
		selected_cells.clear()

func _refresh_word_list() -> void:
	for c in word_list.get_children():
		c.queue_free()
	for w in TARGET_WORDS:
		var l := Label.new()
		l.text = "✓ %s" % w if found.has(w) else w
		l.modulate = AppTheme.ACCENT_GREEN if found.has(w) else AppTheme.TEXT_PRIMARY
		word_list.add_child(l)
