extends Button

@export var is_center := false
@onready var theme: Variant = get_node("/root/AppTheme")

func _ready() -> void:
	focus_mode = Control.FOCUS_NONE
	_update_style()

func _update_style() -> void:
	var sb := theme.style_card(theme.ACCENT_YELLOW if is_center else theme.BG_SURFACE)
	sb.corner_radius_top_left = 24
	sb.corner_radius_top_right = 24
	sb.corner_radius_bottom_left = 24
	sb.corner_radius_bottom_right = 24
	add_theme_stylebox_override("normal", sb)
	add_theme_stylebox_override("pressed", theme.style_card(sb.bg_color.darkened(0.1)))
