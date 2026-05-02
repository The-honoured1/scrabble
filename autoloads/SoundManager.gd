extends Node

var players: Dictionary = {}

func _ready() -> void:
	for key in ["tap", "success", "error", "win", "flip"]:
		var p := AudioStreamPlayer.new()
		p.name = key
		add_child(p)
		players[key] = p

func play_sfx(name: String) -> void:
	if players.has(name):
		var p: AudioStreamPlayer = players[name]
		if p.stream:
			p.play()
