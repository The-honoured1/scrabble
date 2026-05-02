extends CanvasLayer

var fade_overlay: ColorRect

func _ready() -> void:
	layer = 100
	fade_overlay = ColorRect.new()
	fade_overlay.color = Color.BLACK
	fade_overlay.modulate.a = 0.0
	fade_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fade_overlay.anchor_right = 1.0
	fade_overlay.anchor_bottom = 1.0
	add_child(fade_overlay)

func go_to(scene_path: String) -> void:
	var tween := create_tween()
	tween.tween_property(fade_overlay, "modulate:a", 1.0, 0.2)
	await tween.finished
	get_tree().change_scene_to_file(scene_path)
	await get_tree().process_frame
	tween = create_tween()
	tween.tween_property(fade_overlay, "modulate:a", 0.0, 0.2)
