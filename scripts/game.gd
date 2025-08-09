extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var menu: Control = $Menu
@onready var store: Control = $Store
@onready var money_label: Label = $Label
@onready var layout: Control = $Layout
@onready var level_audio: AudioStreamPlayer2D = $LevelAudio
@onready var upgrade_audio: AudioStreamPlayer2D = $UpgradeAudio
@onready var reset_audio: AudioStreamPlayer2D = $ResetAudio
@onready var coin_sprite: AnimatedSprite2D = $CoinSprite

signal layout_signal(level_matrix, levels)

enum {UNSEEN, SEEN, BEATEN}

var levels = {
	"1": UNSEEN,
	"2": UNSEEN,
	"3": UNSEEN,
	"4": UNSEEN,
	"5": UNSEEN,
	"6": UNSEEN,
	"7": UNSEEN,
	"8": UNSEEN,
	"9": UNSEEN
}

var money = 0
var current_level: Node
var none: Button
var wall_jump: Button
var dash: Button
var double_jump: Button
var gravity_switch: Button
var back_button: Button
var wall_jump_bought = false
var dash_bought = false
var double_jump_bought = false
var gravity_switch_bought = false
var level_matrix_size = 4
var current_pos = [2, 2]
var level_matrix = [
	[" ", " ", "7", "6", " "], 
	["4", " ", " ", " ", " "],
	[" ", " ", "1", "2", "3"],
	[" ", " ", "5", " ", " "],
	[" ", " ", " ", " ", " "]
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	menu.visible = true
	menu.get_node("Margin/VBox/Play").pressed.connect(start)
	menu.get_node("Margin/VBox/Layout").pressed.connect(show_layout)
	menu.get_node("Margin/VBox/Store").pressed.connect(show_store)
	
	layout.connect("swap_signal", swap)
	back_button = layout.get_node("Margin/VBox/Back")
	back_button.pressed.connect(back)
	
	store.get_node("Margin/VBox/Back").pressed.connect(back)
	none = store.get_node("Margin/VBox/None")
	wall_jump = store.get_node("Margin/VBox/WallJump")
	dash = store.get_node("Margin/VBox/Dash")
	double_jump = store.get_node("Margin/VBox/DoubleJump")
	gravity_switch = store.get_node("Margin/VBox/GravitySwitch")
	
	none.pressed.connect(none_pressed)
	wall_jump.pressed.connect(wall_jump_pressed)
	dash.pressed.connect(dash_pressed)
	double_jump.pressed.connect(double_jump_pressed)
	gravity_switch.pressed.connect(gravity_switch_pressed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if level_matrix[2][2] == " ":
		back_button.disabled = true
	else:
		back_button.disabled = false
	
	if Input.is_action_just_pressed("reset"):
		reset_audio.play()
		current_level.queue_free()
		current_level = null
		menu.visible = true
	money_label.text = str(money)
	
	if money > 9 and not wall_jump_bought:
		wall_jump.disabled = false
	elif money < 10 and not wall_jump_bought:
		wall_jump.disabled = true
		
	if money > 99 and not dash_bought:
		dash.disabled = false
	elif money < 100 and not dash_bought:
		dash.disabled = true
		
	if money > 999 and not double_jump_bought:
		double_jump.disabled = false
	elif money < 1000 and not double_jump_bought:
		double_jump.disabled = true
		
	if money > 9999 and not gravity_switch_bought:
		gravity_switch.disabled = false
	elif money < 10000 and not gravity_switch_bought:
		gravity_switch.disabled = true
	
	if money > 9999:
		coin_sprite.position.x = 201.0
	elif money > 999:
		coin_sprite.position.x = 216.0
	elif money > 99:
		coin_sprite.position.x = 230.0
	elif money > 9:
		coin_sprite.position.x = 244.0
	else:
		coin_sprite.position.x = 258.0

func load_level(side: String) -> void:
	player.gravity = 1
	if current_level:
		current_level.queue_free()
	var id = level_matrix[current_pos[0]][current_pos[1]]
	if levels[id] == UNSEEN:
		levels[id] = SEEN
	
	current_level = load("res://scenes/levels/" + id + ".tscn").instantiate()
	
	current_level.get_node("Finish").connect("finished", level_finished)
	var exits = current_level.get_node("Exits")
	
	if exits.top:
		if not current_pos[0] > 0:
			exits.top = false
		elif level_matrix[current_pos[0] - 1][current_pos[1]] == " ":
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
		elif level_matrix[current_pos[0]][current_pos[1] + 1] == " ":
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
		elif level_matrix[current_pos[0] + 1][current_pos[1]] == " ":
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
		elif level_matrix[current_pos[0]][current_pos[1] - 1] == " ":
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
		
	player.velocity = Vector2(0, 0)
	get_tree().current_scene.call_deferred("add_child", current_level)

func level_finished(prize: int) -> void:
	level_audio.play()
	var id = level_matrix[current_pos[0]][current_pos[1]]
	levels[id] = BEATEN
	money += prize
	current_level.queue_free()
	current_level = null
	menu.visible = true

func exit(direction: String) -> void:
	match direction:
		"top":
			if current_pos[0] > 0 and level_matrix[current_pos[0] - 1][current_pos[1]] != " ":
				current_pos[0] -= 1
				player.velocity = Vector2(0, 0)
				load_level("bottom")
		"right":
			if current_pos[1] < level_matrix_size and level_matrix[current_pos[0]][current_pos[1] + 1] != " ":
				current_pos[1] += 1
				player.velocity = Vector2(0, 0)
				load_level("left")
		"bottom":
			if current_pos[0] < level_matrix_size and level_matrix[current_pos[0] + 1][current_pos[1]] != " ":
				current_pos[0] += 1
				player.velocity = Vector2(0, 0)
				load_level("top")
		"left":
			if current_pos[1] > 0 and level_matrix[current_pos[0]][current_pos[1] - 1] != " ":
				current_pos[1] -= 1
				player.velocity = Vector2(0, 0)
				load_level("right")

func start() -> void:
	current_pos = [2, 2]
	menu.visible = false
	load_level("")

func show_store() -> void:
	menu.visible = false
	store.visible = true

func show_layout() -> void:
	menu.visible = false
	store.visible = false
	layout.visible = true
	layout_signal.emit(level_matrix, levels)

func back() -> void:
	if level_matrix[2][2] == " ":
		pass
	else:
		store.visible = false
		layout.visible = false
		menu.visible = true

func none_pressed() -> void:
	enable_all()
	none.disabled = true

func wall_jump_pressed() -> void:
	upgrade_audio.play()
	if wall_jump_bought:
		enable_all()
		wall_jump.disabled = true
		player.wall_jump = true
	else:
		money -= 10
		wall_jump_bought = true
		wall_jump.text = "Wall Jump"
		enable_all()
		wall_jump.disabled = true
		player.wall_jump = true

func dash_pressed() -> void:
	upgrade_audio.play()
	if dash_bought:
		enable_all()
		dash.disabled = true
		player.dash = true
	else:
		money -= 100
		dash_bought = true
		dash.text = "Dash"
		enable_all()
		dash.disabled = true
		player.dash = true

func double_jump_pressed() -> void:
	upgrade_audio.play()
	if double_jump_bought:
		enable_all()
		double_jump.disabled = true
		player.double_jump = true
	else:
		money -= 1000
		double_jump_bought = true
		double_jump.text = "Double Jump"
		enable_all()
		double_jump.disabled = true
		player.double_jump = true

func gravity_switch_pressed() -> void:
	upgrade_audio.play()
	if gravity_switch_bought:
		enable_all()
		gravity_switch.disabled = true
		player.gravity_switch = true
	else:
		money -= 10000
		gravity_switch_bought = true
		gravity_switch.text = "Double Jump"
		enable_all()
		gravity_switch.disabled = true
		player.gravity_switch = true

func enable_all() -> void:
	none.disabled = false
	if wall_jump_bought:
		wall_jump.disabled = false
	if dash_bought:
		dash.disabled = false
	if double_jump_bought:
		double_jump.disabled = false
	
	player.wall_jump = false
	player.dash = false
	player.double_jump = false

func swap(data):
	var temp = level_matrix[int(data[0])][int(data[1])]
	level_matrix[int(data[0])][int(data[1])] = level_matrix[int(data[2])][int(data[3])]
	level_matrix[int(data[2])][int(data[3])] = temp
