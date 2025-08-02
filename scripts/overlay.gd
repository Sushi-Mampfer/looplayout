extends Control


@export var background = true

func _ready() -> void:
	get_node("Background").visible = background
