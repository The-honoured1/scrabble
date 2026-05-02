extends Label
@onready var theme: Variant = get_node("/root/AppTheme")

func _ready() -> void:
	anchor_left = 0.2
	anchor_right = 0.8
	anchor_top = 0.82
	anchor_bottom = 0.9
	horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	add_theme_font_size_override("font_size", 13)
	modulate = theme.TEXT_PRIMARY
	var sb := theme.style_card(theme.BG_SURFACE)
	add_theme_stylebox_override("normal", sb)

func show_toast(msg: String, duration := 1.2) -> void:
	text = msg
	visible = true
	modulate.a = 0.0
	var t := create_tween()
	t.tween_property(self, "modulate:a", 1.0, 0.15)
	await get_tree().create_timer(duration).timeout
	var t2 := create_tween()
	t2.tween_property(self, "modulate:a", 0.0, 0.2)
	await t2.finished
	visible = false
