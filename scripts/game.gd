extends Node2D

@onready var player: CharacterBody2D = $Player

var current_level: Node
var level_matrix_size = 4
var current_pos = [2, 2]
var level_matrix = [
	[" ", " ", " ", " ", " "], 
	[" ", " ", "2", " ", " "],
	[" ", " ", "1", " ", " "],
	[" ", " ", "2", " ", " "],
	[" ", " ", " ", " ", " "]
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_level("")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func load_level(side: String) -> void:
	if current_level:
		current_level.queue_free()
	var id = level_matrix[current_pos[0]][current_pos[1]]
	
	current_level = load("res://scenes/levels/" + id + ".tscn").instantiate()
	
	current_level.get_node("Finish").connect("finished", level_finished)
	var exits = current_level.get_node("Exits")
	
	if exits.top:
		if not current_pos[0] > 0:
			exits.top = false
		else:
			var scene = load("res://scenes/levels/" + level_matrix[current_pos[0] - 1][current_pos[1]] + ".tscn")
			if not scene:
				exits.top = false
			elif not scene.instantiate().get_node("Exits").bottom:
				exits.top = false
	
	if exits.right:
		if not current_pos[1] < level_matrix_size:
			exits.right = false
		else:
			var scene = load("res://scenes/levels/" + level_matrix[current_pos[0]][current_pos[1] + 1] + ".tscn")
			if not scene:
				exits.right = false
			elif not scene.instantiate().get_node("Exits").left:
				exits.right = false
	
	if exits.bottom:
		if not current_pos[0] < level_matrix_size:
			exits.bottom = false
		else:
			var scene = load("res://scenes/levels/" + level_matrix[current_pos[0] + 1][current_pos[1]] + ".tscn")
			if not scene:
				exits.bottom = false
			elif not scene.instantiate().get_node("Exits").top:
				exits.bottom = false
	
	if exits.left:
		if not current_pos[1] > 0:
			exits.left = false
		else:
			var scene = load("res://scenes/levels/" + level_matrix[current_pos[0]][current_pos[1] - 1] + ".tscn")
			if not scene:
				exits.left = false
			elif not scene.instantiate().get_node("Exits").right:
				exits.left = false
	
	exits.connect("exit", exit)
	
	match side:
		"top":
			player.position = current_level.top
		"right":
			player.position = current_level.right
		"bottom":
			player.position = current_level.bottom
		"left":
			player.position = current_level.left
		_:
			player.position = current_level.default
	
	add_child(current_level)

func level_finished() -> void:
	print("finished")

func exit(direction: String) -> void:
	match direction:
		"top":
			if current_pos[0] > 0 and level_matrix[current_pos[0] - 1][current_pos[1]] != " ":
				current_pos[0] -= 1
				player.velocity.y = 0
				player.velocity.x = 0
				load_level("bottom")
		"right":
			if current_pos[1] < level_matrix_size and level_matrix[current_pos[0]][current_pos[1] + 1] != " ":
				current_pos[1] += 1
				player.velocity.y = 0
				player.velocity.x = 0
				load_level("left")
		"bottom":
			if current_pos[0] < level_matrix_size and level_matrix[current_pos[0] + 1][current_pos[1]] != " ":
				current_pos[0] += 1
				player.velocity.y = 0
				player.velocity.x = 0
				load_level("top")
		"left":
			if current_pos[1] > 0 and level_matrix[current_pos[0]][current_pos[1] - 1] != " ":
				current_pos[1] -= 1
				player.velocity.y = 0
				player.velocity.x = 0
				load_level("right")
