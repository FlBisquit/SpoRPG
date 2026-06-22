extends Area3D

func _process(delta: float) -> void:
	if Input.is_action_just_pressed('interact'):
		print("пытаюсь взять")
		var player = get_parent()
		for area in get_overlapping_areas():
			var target = area.get_parent()
			if target.has_method("pickup"):
				target.pickup(player)
				break
