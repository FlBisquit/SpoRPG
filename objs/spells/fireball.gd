extends BaseSpell
@onready var sound: AudioStreamPlayer3D = $sound
var hit_effect = load("res://objs/effects/explossion_effect.tscn")
func _init() -> void:
	mana_cost = 65
	speed = 35
	damage = 50
	cooldown = 5.0
	spell_name = 'fireball'
func on_ready() -> void:
	sound.play()

	

func before_move(delta: float) -> void:
	velocity += get_gravity() * 1.5 * delta

func on_hit(_collision) -> void:
	var instance = hit_effect.instantiate()
	get_parent().add_child(instance)
	instance.global_transform = global_transform
	instance.explode()

	for body in $explosionArea.get_overlapping_bodies():
		if body.has_method("take_dmg"):
			var ray = PhysicsRayQueryParameters3D.create(global_position, body.global_position)
			ray.exclude = [self]
			var result = get_world_3d().direct_space_state.intersect_ray(ray)
			if result.get("collider") == body:
				body.take_dmg(damage)
	hit.emit()
