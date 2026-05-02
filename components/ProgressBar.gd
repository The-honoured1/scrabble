extends Control

@export var value := 0.0
@export var max_value := 1.0
@export var fill_color := Color("#52B788")

func _ready() -> void:
	queue_redraw()

func set_progress(v: float, m: float = max_value) -> void:
	value = clamp(v, 0.0, m)
	max_value = max(m, 0.001)
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), AppTheme.BORDER, true)
	var pct := clamp(value / max_value, 0.0, 1.0)
	draw_rect(Rect2(Vector2.ZERO, Vector2(size.x * pct, size.y)), fill_color, true)
