extends PanelContainer

enum TileState {EMPTY, FILLED, CORRECT, PRESENT, ABSENT, REVEALED}

var state := TileState.EMPTY
var letter := ""
var label: Label
var glow_mat: ShaderMaterial
var base_pos := Vector2.ZERO

func _ready() -> void:
	base_pos = position
	_update_style()
	label = Label.new()
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 28)
	if AppTheme.sans_medium:
		label.add_theme_font_override("font", AppTheme.sans_medium)
	label.modulate = AppTheme.TEXT_PRIMARY
	add_child(label)
	label.anchor_right = 1.0
	label.anchor_bottom = 1.0
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	glow_mat = ShaderMaterial.new()
	glow_mat.shader = load("res://shaders/tile_glow.gdshader")

func set_letter(v: String) -> void:
	letter = v.to_upper()
	label.text = letter
	if letter.is_empty():
		set_state(TileState.EMPTY)
	else:
		set_state(TileState.FILLED)
		pop_anim()

func clear_letter() -> void:
	letter = ""
	label.text = ""
	set_state(TileState.EMPTY)

func set_state(new_state: TileState) -> void:
	state = new_state
	_update_style()

func reveal(new_state: TileState) -> void:
	var t := create_tween()
	t.tween_property(self, "scale:x", 0.0, 0.25)
	await t.finished
	set_state(new_state)
	var t2 := create_tween()
	t2.tween_property(self, "scale:x", 1.0, 0.25)
	SoundManager.play_sfx("flip")

func shake_anim() -> void:
	var t := create_tween()
	t.tween_property(self, "position:x", base_pos.x - 8.0, 0.08)
	t.tween_property(self, "position:x", base_pos.x + 8.0, 0.08)
	t.tween_property(self, "position:x", base_pos.x - 6.0, 0.08)
	t.tween_property(self, "position:x", base_pos.x + 6.0, 0.08)
	t.tween_property(self, "position:x", base_pos.x, 0.08)

func pop_anim() -> void:
	var t := create_tween()
	t.tween_property(self, "scale", Vector2(1.08, 1.08), 0.05)
	t.tween_property(self, "scale", Vector2.ONE, 0.05)

func _update_style() -> void:
	var sb := AppTheme.style_card(AppTheme.TILE_EMPTY)
	match state:
		TileState.EMPTY:
			sb.bg_color = AppTheme.TILE_EMPTY
		TileState.FILLED:
			sb.bg_color = AppTheme.BG_SURFACE
		TileState.CORRECT:
			sb.bg_color = AppTheme.TILE_CORRECT
		TileState.PRESENT:
			sb.bg_color = AppTheme.TILE_PRESENT
		TileState.ABSENT:
			sb.bg_color = AppTheme.TILE_ABSENT
		TileState.REVEALED:
			sb.bg_color = AppTheme.ACCENT_NAVY
	add_theme_stylebox_override("panel", sb)
	material = glow_mat if state == TileState.CORRECT else null
