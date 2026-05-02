extends Control

const LETTER_TILE := preload("res://components/LetterTile.tscn")
const KEYBOARD := preload("res://components/Keyboard.tscn")
const TOAST := preload("res://components/ToastNotif.tscn")
const DIALOG := preload("res://components/DialogPanel.tscn")

var answer := ""
var current_row := 0
var current_col := 0
var guesses: Array[String] = []
var tiles: Array = []
var keyboard
var toast
var dialog
var confetti: CPUParticles2D

func _ready() -> void:
	answer = WordBank.get_daily_word()
	_build_ui()

func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.color = AppTheme.BG_DARK
	bg.anchor_right = 1.0
	bg.anchor_bottom = 1.0
	add_child(bg)

	var root := VBoxContainer.new()
	root.anchor_right = 1.0
	root.anchor_bottom = 1.0
	root.add_theme_constant_override("separation", 12)
	add_child(root)

	root.add_child(_top_bar("Wordle"))
	var grid := GridContainer.new()
	grid.columns = 5
	grid.add_theme_constant_override("h_separation", 6)
	grid.add_theme_constant_override("v_separation", 6)
	root.add_child(grid)

	for r in range(6):
		var row_tiles: Array = []
		guesses.append("")
		for c in range(5):
			var tile = LETTER_TILE.instantiate()
			grid.add_child(tile)
			row_tiles.append(tile)
		tiles.append(row_tiles)

	keyboard = KEYBOARD.instantiate()
	keyboard.key_pressed.connect(_on_key_pressed)
	root.add_child(keyboard)

	toast = TOAST.instantiate()
	add_child(toast)
	dialog = DIALOG.instantiate()
	add_child(dialog)

	confetti = CPUParticles2D.new()
	confetti.one_shot = true
	confetti.amount = 120
	confetti.lifetime = 1.0
	confetti.emitting = false
	confetti.direction = Vector2(0, 1)
	confetti.spread = 180.0
	confetti.initial_velocity_min = 220.0
	confetti.initial_velocity_max = 360.0
	confetti.anchor_left = 0.5
	confetti.anchor_top = 0.2
	add_child(confetti)

func _top_bar(title: String) -> Control:
	var row := HBoxContainer.new()
	var back := Button.new()
	back.text = "←"
	back.pressed.connect(func() -> void: SceneManager.go_to("res://scenes/Home.tscn"))
	row.add_child(back)
	var label := Label.new()
	label.text = title
	label.add_theme_font_size_override("font_size", 28)
	if AppTheme.display_font:
		label.add_theme_font_override("font", AppTheme.display_font)
	row.add_child(label)
	return row

func _on_key_pressed(key: String) -> void:
	if current_row > 5:
		return
	if key == "ENTER":
		_submit_guess()
	elif key == "DEL":
		if current_col > 0:
			current_col -= 1
			tiles[current_row][current_col].clear_letter()
			guesses[current_row] = guesses[current_row].substr(0, current_col)
	elif current_col < 5 and key.length() == 1:
		tiles[current_row][current_col].set_letter(key)
		guesses[current_row] += key
		current_col += 1

func _submit_guess() -> void:
	var guess := guesses[current_row]
	if guess.length() != 5:
		toast.show_toast("Not enough letters")
		return
	if not WordBank.is_valid_word(guess):
		toast.show_toast("Not in word list")
		for t in tiles[current_row]:
			t.shake_anim()
		return
	await _reveal_guess(guess)
	if guess == answer:
		_win()
		return
	current_row += 1
	current_col = 0
	if current_row >= 6:
		_lose()

func _reveal_guess(guess: String) -> void:
	var states: Array[int] = []
	var used := {}
	for i in range(5):
		var g := guess.substr(i, 1)
		if g == answer.substr(i, 1):
			states.append(2)
			used[i] = true
		else:
			states.append(0)
	for i in range(5):
		if states[i] == 2:
			continue
		var g := guess.substr(i, 1)
		var present := false
		for j in range(5):
			if used.get(j, false):
				continue
			if answer.substr(j, 1) == g:
				used[j] = true
				present = true
				break
		states[i] = 1 if present else -1

	for i in range(5):
		await get_tree().create_timer(i * 0.15).timeout
		var tile = tiles[current_row][i]
		var letter := guess.substr(i, 1)
		if states[i] == 2:
			await tile.reveal(tile.TileState.CORRECT)
			keyboard.set_key_state(letter, "CORRECT")
		elif states[i] == 1:
			await tile.reveal(tile.TileState.PRESENT)
			keyboard.set_key_state(letter, "PRESENT")
		else:
			await tile.reveal(tile.TileState.ABSENT)
			keyboard.set_key_state(letter, "ABSENT")

func _win() -> void:
	confetti.emitting = true
	GameManager.mark_complete("wordle")
	SoundManager.play_sfx("win")
	dialog.show_result("Brilliant!", "You solved today's Wordle in %d/6." % (current_row + 1), "Home")
	dialog.confirmed.connect(func() -> void: SceneManager.go_to("res://scenes/Home.tscn"), CONNECT_ONE_SHOT)
	current_row = 10

func _lose() -> void:
	dialog.show_result("So close", "Answer: %s" % answer, "Home")
	dialog.confirmed.connect(func() -> void: SceneManager.go_to("res://scenes/Home.tscn"), CONNECT_ONE_SHOT)
	current_row = 10
