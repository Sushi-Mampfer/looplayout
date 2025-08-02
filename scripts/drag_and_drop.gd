extends TextureRect

@export var movable = true

var layout_node: Control

func _ready() -> void:
	layout_node = get_parent().get_parent().get_parent().get_parent().get_parent()

func _can_drop_data(_position, _data) -> bool:
	if movable:
		return true
	elif texture == null:
		return true
	else:
		return false

func _drop_data(_position, data):
	data[1].texture = texture
	texture = data[0]
	layout_node.swap([data[2], data[3], get_parent().get_parent().name, get_parent().name])

func _get_drag_data(_position):
	if movable:
		var preview = load("res://scenes/preview.tscn").instantiate()
		preview.get_node("TextureRect").texture = texture
		layout_node.add_child(preview)
		return [texture, self, get_parent().get_parent().name, get_parent().name]
	else:
		return null
