extends Control

const TOAST := preload("res://components/ToastNotif.tscn")
const DIALOG := preload("res://components/DialogPanel.tscn")

const PAIRS := [
	{"start":"COLD","target":"WARM"},
	{"start":"CAT","target":"DOG"},
	{"start":"HEAT","target":"COOL"}
]

var puzzle: Dictionary
var steps: Array[String] = []
var list_box: VBoxContainer
var input: LineEdit
var toast
var dialog

func _ready() -> void:
	puzzle = PAIRS[GameManager.get_daily_index(PAIRS.size())]
	steps = [puzzle.start]
	_build_ui()
	_refresh_steps()

func _build_ui() -> void:
	var bg := ColorRect.new(); bg.color = AppTheme.BG_DARK; bg.anchor_right = 1.0; bg.anchor_bottom = 1.0; add_child(bg)
	var root := VBoxContainer.new(); root.anchor_right = 1.0; root.anchor_bottom = 1.0; root.add_theme_constant_override("separation", 10); add_child(root)
	root.add_child(_top_bar("Word Ladder"))
	var start_label := Label.new(); start_label.text = "START: %s" % puzzle.start; start_label.modulate = AppTheme.ACCENT_GREEN; root.add_child(start_label)
	var target_label := Label.new(); target_label.text = "TARGET: %s" % puzzle.target; target_label.modulate = AppTheme.ACCENT_AMBER; root.add_child(target_label)
	list_box = VBoxContainer.new(); list_box.size_flags_vertical = Control.SIZE_EXPAND_FILL; root.add_child(list_box)
	input = LineEdit.new(); input.placeholder_text = "Enter next step"; input.max_length = puzzle.start.length(); root.add_child(input)
	var submit := Button.new(); submit.text = "Submit Step"; submit.pressed.connect(_submit); root.add_child(submit)
	toast = TOAST.instantiate(); add_child(toast)
	dialog = DIALOG.instantiate(); add_child(dialog)

func _top_bar(title: String) -> Control:
	var row := HBoxContainer.new()
	var back := Button.new(); back.text = "←"; back.pressed.connect(func() -> void: SceneManager.go_to("res://scenes/Home.tscn")); row.add_child(back)
	var l := Label.new(); l.text = title; l.add_theme_font_size_override("font_size", 28); row.add_child(l)
	return row

func _submit() -> void:
	var w := input.text.strip_edges().to_upper()
	var prev := steps[-1]
	if w.length() != prev.length():
		toast.show_toast("Length must match")
		return
	if not WordBank.is_valid_word(w):
		toast.show_toast("Not in dictionary")
		return
	if _diff_count(prev, w) != 1:
		toast.show_toast("Change exactly one letter")
		return
	steps.append(w)
	input.clear()
	_refresh_steps()
	if w == puzzle.target:
		GameManager.mark_complete("word_ladder")
		dialog.show_result("Ladder complete", "Solved in %d steps." % (steps.size() - 1), "Home")
		dialog.confirmed.connect(func() -> void: SceneManager.go_to("res://scenes/Home.tscn"), CONNECT_ONE_SHOT)

func _diff_count(a: String, b: String) -> int:
	var d := 0
	for i in range(a.length()):
		if a[i] != b[i]:
			d += 1
	return d

func _refresh_steps() -> void:
	for c in list_box.get_children():
		c.queue_free()
	for i in range(steps.size()):
		var l := Label.new()
		l.text = "%d. %s" % [i + 1, steps[i]]
		list_box.add_child(l)
