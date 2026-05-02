extends Control

const GAME_CARD := preload("res://components/GameCard.tscn")

var GAME_ENTRIES := [
	{"id":"wordle","title":"Wordle","desc":"Guess the daily 5-letter word.","emoji":"🟩","accent":AppTheme.ACCENT_GREEN,"scene":"res://games/Wordle.tscn"},
	{"id":"connections","title":"Connections","desc":"Group 16 words into 4 sets.","emoji":"🟪","accent":AppTheme.ACCENT_PURPLE,"scene":"res://games/Connections.tscn"},
	{"id":"spelling_bee","title":"Spelling Bee","desc":"Build words from seven letters.","emoji":"🐝","accent":AppTheme.ACCENT_YELLOW,"scene":"res://games/SpellingBee.tscn"},
	{"id":"crossword","title":"Crossword","desc":"Fill mini clues fast.","emoji":"🧩","accent":AppTheme.ACCENT_NAVY,"scene":"res://games/Crossword.tscn"},
	{"id":"word_search","title":"Word Search","desc":"Find hidden words in the grid.","emoji":"🔎","accent":AppTheme.ACCENT_AMBER,"scene":"res://games/WordSearch.tscn"},
	{"id":"hangman","title":"Hangman","desc":"Save the stick figure.","emoji":"🪢","accent":AppTheme.ACCENT_RED,"scene":"res://games/Hangman.tscn"},
	{"id":"boggle","title":"Boggle","desc":"Trace adjacent letters.","emoji":"🔤","accent":AppTheme.ACCENT_AMBER,"scene":"res://games/Boggle.tscn"},
	{"id":"word_ladder","title":"Word Ladder","desc":"Change one letter each step.","emoji":"🪜","accent":AppTheme.ACCENT_GREEN,"scene":"res://games/WordLadder.tscn"},
	{"id":"type_racer","title":"Type Racer","desc":"Race your typing speed.","emoji":"⌨️","accent":AppTheme.ACCENT_NAVY,"scene":"res://games/TypeRacer.tscn"},
	{"id":"anagram","title":"Anagram","desc":"Unscramble the letters.","emoji":"🔀","accent":AppTheme.ACCENT_PURPLE,"scene":"res://games/Anagram.tscn"}
]
const GAME_SCENE_BY_ID := {
	"wordle": "res://games/Wordle.tscn",
	"connections": "res://games/Connections.tscn",
	"spelling_bee": "res://games/SpellingBee.tscn",
	"crossword": "res://games/Crossword.tscn",
	"word_search": "res://games/WordSearch.tscn",
	"hangman": "res://games/Hangman.tscn",
	"boggle": "res://games/Boggle.tscn",
	"word_ladder": "res://games/WordLadder.tscn",
	"type_racer": "res://games/TypeRacer.tscn",
	"anagram": "res://games/Anagram.tscn"
}

func _ready() -> void:
	_build_ui()

func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.color = AppTheme.BG_DARK
	bg.anchor_right = 1.0
	bg.anchor_bottom = 1.0
	add_child(bg)

	var root := ScrollContainer.new()
	root.anchor_right = 1.0
	root.anchor_bottom = 1.0
	root.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(root)

	var page := VBoxContainer.new()
	page.custom_minimum_size.x = 390
	page.add_theme_constant_override("separation", 12)
	root.add_child(page)

	var header := _header_bar()
	page.add_child(header)
	page.add_child(_hero())
	page.add_child(_featured())

	var games_label := Label.new()
	games_label.text = "GAMES"
	games_label.modulate = AppTheme.TEXT_MUTED
	games_label.add_theme_font_size_override("font_size", 10)
	page.add_child(games_label)

	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 10)
	page.add_child(grid)
	for data in GAME_ENTRIES:
		var card = GAME_CARD.instantiate()
		card.configure(data.id, data.title, data.desc, data.emoji, data.accent)
		card.game_selected.connect(_on_game_selected)
		grid.add_child(card)

	page.add_child(_bottom_bar())

func _header_bar() -> Control:
	var h := HBoxContainer.new()
	h.custom_minimum_size.y = 60
	h.add_theme_constant_override("separation", 8)

	var title := RichTextLabel.new()
	title.bbcode_enabled = true
	title.fit_content = true
	title.text = "[font_size=28][color=#F5F4EF]wordie[/color][color=#52B788].[/color][/font_size]"
	if AppTheme.display_font:
		title.add_theme_font_override("normal_font", AppTheme.display_font)
	h.add_child(title)

	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	h.add_child(spacer)

	var streak := Label.new()
	streak.text = "🔥 %d days" % GameManager.streak
	streak.add_theme_font_size_override("font_size", 13)
	h.add_child(streak)
	return h

func _hero() -> Control:
	var p := PanelContainer.new()
	p.custom_minimum_size.y = 180
	p.add_theme_stylebox_override("panel", AppTheme.style_card(AppTheme.BG_SURFACE))

	var grad := ColorRect.new()
	grad.anchor_right = 1.0
	grad.anchor_bottom = 1.0
	var mat := ShaderMaterial.new()
	mat.shader = load("res://shaders/bg_gradient.gdshader")
	grad.material = mat
	p.add_child(grad)

	var m := MarginContainer.new()
	m.anchor_right = 1.0
	m.anchor_bottom = 1.0
	m.add_theme_constant_override("margin_left", 24)
	m.add_theme_constant_override("margin_top", 24)
	p.add_child(m)

	var vb := VBoxContainer.new()
	m.add_child(vb)
	var t := Label.new()
	t.text = "Today's\nGames"
	t.add_theme_font_size_override("font_size", 42)
	if AppTheme.display_font:
		t.add_theme_font_override("font", AppTheme.display_font)
	vb.add_child(t)
	var d := Label.new()
	d.text = Time.get_date_string_from_system()
	d.modulate = AppTheme.TEXT_MUTED
	d.add_theme_font_size_override("font_size", 13)
	vb.add_child(d)
	return p

func _featured() -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	for id in ["wordle", "connections"]:
		for data in GAME_ENTRIES:
			if data.id == id:
				var card = GAME_CARD.instantiate()
				card.configure(data.id, data.title, data.desc, data.emoji, data.accent)
				card.game_selected.connect(_on_game_selected)
				row.add_child(card)
	return row

func _bottom_bar() -> Control:
	var h := HBoxContainer.new()
	h.custom_minimum_size.y = 44
	h.add_theme_constant_override("separation", 12)
	var l := Label.new()
	l.text = "Games: 10   |   Streak: %d   |   Today: %d/10" % [GameManager.streak, GameManager.get_today_completed_count()]
	l.modulate = AppTheme.TEXT_MUTED
	h.add_child(l)
	return h

func _on_game_selected(game_id: String) -> void:
	var scene_path := str(GAME_SCENE_BY_ID.get(game_id, ""))
	if scene_path.is_empty():
		return
	if not ResourceLoader.exists(scene_path):
		return
	SceneManager.go_to(scene_path)
