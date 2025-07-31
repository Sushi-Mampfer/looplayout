extends Node2D

signal exit(direction)

@export_category("Exits")
@export var top = false
@export var right = false
@export var bottom = false
@export var left = false

var enabled = false

func _ready() -> void:
	if top:
		get_node("Top/TopTileMap").enabled = false
	if right:
		get_node("Right/RightTileMap").enabled = false
	if bottom:
		get_node("Bottom/BottomTileMap").enabled = false
	if left:
		get_node("Left/LeftTileMap").enabled = false
	enabled = true

func _on_top_body_entered(body: Node2D) -> void:
	if body.name == "Player" and enabled:
		exit.emit("top")


func _on_right_body_entered(body: Node2D) -> void:
	if body.name == "Player" and enabled:
		exit.emit("right")


func _on_bottom_body_entered(body: Node2D) -> void:
	if body.name == "Player" and enabled:
		exit.emit("bottom")


func _on_left_body_entered(body: Node2D) -> void:
	if body.name == "Player" and enabled:
		exit.emit("left")
