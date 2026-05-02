extends Control

signal key_pressed(key: String)

const ROWS := ["QWERTYUIOP", "ASDFGHJKL", "DELZXCVBNMENTER"]

var key_buttons: Dictionary = {}
var state_priority := {"DEFAULT": 0, "ABSENT": 1, "PRESENT": 2, "CORRECT": 3}
var key_states: Dictionary = {}

func _ready() -> void:
	_build()

func _build() -> void:
	var root := VBoxContainer.new()
	root.anchor_right = 1.0
	root.anchor_bottom = 1.0
	root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.alignment = BoxContainer.ALIGNMENT_END
	root.add_theme_constant_override("separation", 6)
	add_child(root)

	for i in range(3):
		var row := HBoxContainer.new()
		row.alignment = BoxContainer.ALIGNMENT_CENTER
		row.add_theme_constant_override("separation", 4)
		root.add_child(row)
		var keys: Array[String] = []
		if i == 0:
			keys = ["Q","W","E","R","T","Y","U","I","O","P"]
		elif i == 1:
			keys = ["A","S","D","F","G","H","J","K","L"]
		else:
			keys = ["DEL","Z","X","C","V","B","N","M","ENTER"]
		for key in keys:
			var b := Button.new()
			b.text = key
			b.custom_minimum_size = Vector2(40, 44)
			b.focus_mode = Control.FOCUS_NONE
			if key == "DEL" or key == "ENTER":
				b.custom_minimum_size.x = 58
			_style_key(b, "DEFAULT")
			b.pressed.connect(func(k := key, btn := b) -> void:
				var tw := create_tween()
				tw.tween_property(btn, "scale", Vector2(0.92, 0.92), 0.05)
				tw.tween_property(btn, "scale", Vector2.ONE, 0.05)
				key_pressed.emit(k))
			row.add_child(b)
			key_buttons[key] = b
			key_states[key] = "DEFAULT"

func _style_key(button: Button, state_name: String) -> void:
	var c := AppTheme.BG_SURFACE
	if state_name == "CORRECT":
		c = AppTheme.ACCENT_GREEN
	elif state_name == "PRESENT":
		c = AppTheme.ACCENT_AMBER
	elif state_name == "ABSENT":
		c = AppTheme.TILE_ABSENT
	var sb := AppTheme.style_card(c)
	button.add_theme_stylebox_override("normal", sb)
	button.add_theme_stylebox_override("pressed", AppTheme.style_card(c.darkened(0.1)))
	button.add_theme_stylebox_override("hover", sb)
	button.modulate = AppTheme.TEXT_PRIMARY

func set_key_state(key: String, state_name: String) -> void:
	key = key.to_upper()
	if not key_buttons.has(key):
		return
	var prev := str(key_states.get(key, "DEFAULT"))
	if state_priority[state_name] < state_priority[prev]:
		return
	key_states[key] = state_name
	_style_key(key_buttons[key], state_name)
