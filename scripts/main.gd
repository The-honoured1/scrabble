extends Control

func _ready() -> void:
	if get_tree().current_scene == self:
		SceneManager.go_to("res://scenes/Home.tscn")
