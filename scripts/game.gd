extends Node2D

var current_level: Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_level("1")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func load_level(name: String) -> void:
	if current_level:
		current_level.queue_free()
	
	current_level = load("res://scenes/levels/" + name + ".tscn").instantiate()
	
	add_child(current_level)
