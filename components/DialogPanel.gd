extends PanelContainer

signal confirmed
signal closed

var title_label: Label
var body_label: Label
var ok_btn: Button
var close_btn: Button
@onready var theme: Variant = get_node("/root/AppTheme")

func _ready() -> void:
	anchor_left = 0.08
	anchor_top = 0.3
	anchor_right = 0.92
	anchor_bottom = 0.7
	add_theme_stylebox_override("panel", theme.style_card(theme.BG_CARD))
	var root := MarginContainer.new()
	root.anchor_right = 1.0
	root.anchor_bottom = 1.0
	root.add_theme_constant_override("margin_left", 20)
	root.add_theme_constant_override("margin_right", 20)
	root.add_theme_constant_override("margin_top", 20)
	root.add_theme_constant_override("margin_bottom", 20)
	add_child(root)

	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 12)
	root.add_child(vb)

	title_label = Label.new()
	title_label.add_theme_font_size_override("font_size", 24)
	title_label.modulate = theme.TEXT_PRIMARY
	if theme.display_font:
		title_label.add_theme_font_override("font", theme.display_font)
	vb.add_child(title_label)

	body_label = Label.new()
	body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body_label.modulate = theme.TEXT_MUTED
	vb.add_child(body_label)

	var actions := HBoxContainer.new()
	actions.alignment = BoxContainer.ALIGNMENT_END
	actions.add_theme_constant_override("separation", 8)
	vb.add_child(actions)

	close_btn = Button.new()
	close_btn.text = "Close"
	close_btn.pressed.connect(func() -> void:
		hide()
		closed.emit())
	actions.add_child(close_btn)

	ok_btn = Button.new()
	ok_btn.text = "OK"
	ok_btn.pressed.connect(func() -> void:
		hide()
		confirmed.emit())
	actions.add_child(ok_btn)

func show_result(title: String, body: String, confirm_text := "OK") -> void:
	title_label.text = title
	body_label.text = body
	ok_btn.text = confirm_text
	visible = true
	scale = Vector2(0.95, 0.95)
	modulate.a = 0.0
	var t := create_tween()
	t.parallel().tween_property(self, "scale", Vector2.ONE, 0.16)
	t.parallel().tween_property(self, "modulate:a", 1.0, 0.16)
