extends Control

signal swap_signal(Array)

enum {UNSEEN, SEEN, BEATEN}

var container = Node.new()

func _ready() -> void:
	get_parent().connect("layout_signal", load)
	add_child(container)

func load(level_matrix, levels) -> void:
	container.queue_free()
	container = Node.new()
	add_child(container)
	for i in 5:
		for j in 5:
			var id = level_matrix[i][j]
			if id != " ":
				var viewport = SubViewport.new()
				viewport.size = Vector2i(320, 320)
				var level = load("res://scenes/levels/" + id + ".tscn").instantiate()
				level.position = Vector2(160, 160)
				viewport.add_child(level)
				var texture_node = get_node("Margin/VBox/" + str(i) + "/" + str(j) + "/TextureRect")
				if levels[id] != BEATEN:
					var overlay = load("res://scenes/overlay.tscn").instantiate()
					viewport.add_child(overlay)
					texture_node.movable = false
				else:
					texture_node.movable = true
				container.add_child(viewport)
				texture_node.texture = viewport.get_texture()
			else:
				var texture_node = get_node("Margin/VBox/" + str(i) + "/" + str(j) + "/TextureRect")
				texture_node.movable = true
				texture_node.texture = null

func swap(data) -> void:
	swap_signal.emit(data)
