extends Control

const DIALOG := preload("res://components/DialogPanel.tscn")

const PASSAGES := [
	"Small steps every day build uncommon momentum.",
	"Words can shape worlds when timed with care.",
	"Typing speed grows when accuracy comes first.",
	"Practice with intention and your hands will follow.",
	"Curiosity turns ordinary moments into learning."
]

var passage := ""
var words: Array[String] = []
var current_index := 0
var correct_words := 0
var total_chars := 0
var correct_chars := 0
var elapsed := 0.0
var time_left := 60.0
var text_view: RichTextLabel
var input: LineEdit
var stats: Label
var dialog

func _ready() -> void:
	passage = PASSAGES[randi() % PASSAGES.size()]
	words = passage.split(" ")
	_build_ui()
	_render_passage()
	input.grab_focus()

func _process(delta: float) -> void:
	elapsed += delta
	time_left -= delta
	_update_stats()
	if time_left <= 0:
		set_process(false)
		_finish()

func _build_ui() -> void:
	var bg := ColorRect.new(); bg.color = AppTheme.BG_DARK; bg.anchor_right = 1.0; bg.anchor_bottom = 1.0; add_child(bg)
	var root := VBoxContainer.new(); root.anchor_right = 1.0; root.anchor_bottom = 1.0; root.add_theme_constant_override("separation", 8); add_child(root)
	root.add_child(_top_bar("Type Racer"))
	text_view = RichTextLabel.new()
	text_view.bbcode_enabled = true
	text_view.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(text_view)
	stats = Label.new()
	root.add_child(stats)
	input = LineEdit.new()
	input.placeholder_text = "Type here..."
	input.text_submitted.connect(_on_submit)
	root.add_child(input)
	dialog = DIALOG.instantiate()
	add_child(dialog)

func _top_bar(title: String) -> Control:
	var row := HBoxContainer.new()
	var back := Button.new(); back.text = "←"; back.pressed.connect(func() -> void: SceneManager.go_to("res://scenes/Home.tscn")); row.add_child(back)
	var l := Label.new(); l.text = title; l.add_theme_font_size_override("font_size", 28); row.add_child(l)
	return row

func _on_submit(value: String) -> void:
	var typed := value.strip_edges()
	if current_index >= words.size():
		return
	var expected := words[current_index]
	total_chars += typed.length()
	var matching := 0
	for i in range(min(typed.length(), expected.length())):
		if typed[i] == expected[i]:
			matching += 1
	correct_chars += matching
	if typed == expected:
		correct_words += 1
	current_index += 1
	input.clear()
	_render_passage()
	if current_index >= words.size():
		_finish()

func _render_passage() -> void:
	var bb := ""
	for i in range(words.size()):
		var w := words[i]
		if i < current_index:
			bb += "[color=#52B788]%s[/color] " % w
		elif i == current_index:
			bb += "[u]%s[/u] " % w
		else:
			bb += "%s " % w
	text_view.text = bb.strip_edges()

func _wpm() -> int:
	if elapsed <= 0.1:
		return 0
	return int((float(correct_words) / elapsed) * 60.0)

func _accuracy() -> float:
	if total_chars == 0:
		return 100.0
	return (float(correct_chars) / float(total_chars)) * 100.0

func _update_stats() -> void:
	stats.text = "WPM: %d   Accuracy: %.1f%%   Time: %d" % [_wpm(), _accuracy(), max(0, int(time_left))]

func _rank(wpm: int) -> String:
	if wpm < 25:
		return "Novice"
	if wpm < 40:
		return "Average"
	if wpm < 60:
		return "Fast"
	if wpm < 80:
		return "Expert"
	return "Legendary"

func _finish() -> void:
	GameManager.mark_complete("type_racer")
	dialog.show_result("Time!", "WPM: %d\nAccuracy: %.1f%%\nRank: %s" % [_wpm(), _accuracy(), _rank(_wpm())], "Home")
	dialog.confirmed.connect(func() -> void: SceneManager.go_to("res://scenes/Home.tscn"), CONNECT_ONE_SHOT)
