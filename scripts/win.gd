extends Area2D

var started = false

func _ready() -> void:
	get_tree().create_timer(1).timeout.connect(start)

func _on_body_entered(_body: Node2D) -> void:
	if started:
		get_tree().change_scene_to_file("res://scenes/win.tscn")

func start():
	started = true
