extends Area3D

var damage = 10
var lifetime = 10
var current_lifetime = 0.0
var hit_effect = load("res://objs/effects/explossion_effect.tscn")


func _physics_process(delta: float) -> void:
	current_lifetime += delta
	if current_lifetime >= lifetime:
		queue_free()

func _on_explosion_area_body_entered(body: Node3D) -> void:
	var instance = hit_effect.instantiate()
	get_parent().add_child(instance)
	instance.global_transform = global_transform
	instance.explode()
	for b in $explosionArea.get_overlapping_bodies():
		if body.has_method("take_dmg"):
			var ray = PhysicsRayQueryParameters3D.create(global_position, body.global_position)
			ray.exclude = [self]
			var result = get_world_3d().direct_space_state.intersect_ray(ray)
			if result.get("collider") == body:
				body.take_dmg(damage, self)
				queue_free()
