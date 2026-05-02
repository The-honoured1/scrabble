extends Button

signal game_selected(game_id: String)

@export var game_id := ""
@export var game_title := "Game"
@export var game_desc := "Description"
@export var game_emoji := "🎮"
@export var accent_color := Color.WHITE

var title_label: Label
var desc_label: Label
var emoji_label: Label
var accent_bar: ColorRect
@onready var theme: Variant = get_node("/root/AppTheme")

func _ready() -> void:
	flat = true
	focus_mode = Control.FOCUS_NONE
	_update_style()
	_build_ui()
	pressed.connect(_on_pressed)
	button_down.connect(func() -> void: _scale_to(0.97))
	button_up.connect(func() -> void: _scale_to(1.0))

func configure(id: String, title: String, desc: String, emoji: String, accent: Color) -> void:
	game_id = id
	game_title = title
	game_desc = desc
	game_emoji = emoji
	accent_color = accent
	if is_node_ready():
		_update_style()
		title_label.text = game_title
		desc_label.text = game_desc
		emoji_label.text = game_emoji
		accent_bar.color = accent_color

func _build_ui() -> void:
	var root := MarginContainer.new()
	root.add_theme_constant_override("margin_left", 14)
	root.add_theme_constant_override("margin_right", 14)
	root.add_theme_constant_override("margin_top", 10)
	root.add_theme_constant_override("margin_bottom", 10)
	add_child(root)

	var vb := VBoxContainer.new()
	vb.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vb.add_theme_constant_override("separation", 6)
	root.add_child(vb)

	accent_bar = ColorRect.new()
	accent_bar.custom_minimum_size = Vector2(0, 3)
	accent_bar.color = accent_color
	vb.add_child(accent_bar)

	emoji_label = Label.new()
	emoji_label.text = game_emoji
	emoji_label.add_theme_font_size_override("font_size", 24)
	vb.add_child(emoji_label)

	title_label = Label.new()
	title_label.text = game_title
	title_label.modulate = theme.TEXT_PRIMARY
	title_label.add_theme_font_size_override("font_size", 14)
	if theme.sans_medium:
		title_label.add_theme_font_override("font", theme.sans_medium)
	vb.add_child(title_label)

	desc_label = Label.new()
	desc_label.text = game_desc
	desc_label.modulate = theme.TEXT_MUTED
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_label.add_theme_font_size_override("font_size", 11)
	if theme.sans_regular:
		desc_label.add_theme_font_override("font", theme.sans_regular)
	vb.add_child(desc_label)

func _update_style() -> void:
	var normal := theme.style_card(theme.BG_CARD)
	var press := theme.style_card(theme.BG_SURFACE)
	add_theme_stylebox_override("normal", normal)
	add_theme_stylebox_override("hover", normal)
	add_theme_stylebox_override("pressed", press)
	add_theme_stylebox_override("focus", normal)
	modulate = Color.WHITE

func _scale_to(s: float) -> void:
	var t := create_tween()
	t.tween_property(self, "scale", Vector2.ONE * s, 0.05)

func _on_pressed() -> void:
	SoundManager.play_sfx("tap")
	game_selected.emit(game_id)
