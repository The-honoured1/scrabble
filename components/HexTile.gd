extends Button

@export var is_center := false

func _ready() -> void:
	focus_mode = Control.FOCUS_NONE
	_update_style()

func _update_style() -> void:
	var sb := AppTheme.style_card(AppTheme.ACCENT_YELLOW if is_center else AppTheme.BG_SURFACE)
	sb.corner_radius_top_left = 24
	sb.corner_radius_top_right = 24
	sb.corner_radius_bottom_left = 24
	sb.corner_radius_bottom_right = 24
	add_theme_stylebox_override("normal", sb)
	add_theme_stylebox_override("pressed", AppTheme.style_card(sb.bg_color.darkened(0.1)))
