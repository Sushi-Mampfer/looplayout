extends Area2D

signal finished(price: int)

@export var prize = 1

func _on_body_entered(_body: Node2D) -> void:
	finished.emit(prize)
