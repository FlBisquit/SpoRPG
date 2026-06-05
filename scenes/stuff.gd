extends MeshInstance3D

var MOUSE_SENSITIVITY : float = 0.003

func _input(event: InputEvent) -> void:
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		return
	if event is InputEventMouseMotion:
		rotation.x -= event.relative.y * MOUSE_SENSITIVITY
		rotation.x = clamp(rotation.x, deg_to_rad(-80), deg_to_rad(80))
