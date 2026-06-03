extends Node3D

var MOUSE_SENSITIVITY : float = 0.003

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotation.y -= event.relative.x * MOUSE_SENSITIVITY
