extends CharacterBody3D

var speed = 50
var damage = 50
var lifetime = 2.0 
var current_lifetime = 0.0

@onready var sound: AudioStreamPlayer3D = $sound

var hit_effect = load("res://objs/effects/explossion_effect.tscn")

signal hit

func projectile_lifetime(delta) -> void:
	current_lifetime += delta
	if current_lifetime >= lifetime:
		queue_free()

func _ready() -> void:
	velocity = -transform.basis.z * speed * 0.7
	sound.play()

func _physics_process(delta: float) -> void:
	projectile_lifetime(delta)
	velocity += get_gravity() * 1.5 * delta
	var collision = move_and_collide(velocity * delta) 
	
	if collision or is_on_floor():
		var instance = hit_effect.instantiate()
		get_parent().add_child(instance)
		instance.global_transform = global_transform
		instance.explode()
		var bodies = $explosionArea.get_overlapping_bodies()
		
		for body in bodies:
			if body.has_method('take_dmg'):
				var rayParams = PhysicsRayQueryParameters3D.create(global_transform.origin, body.global_transform.origin)
				rayParams.exclude = [self]
				var result = get_world_3d().direct_space_state.intersect_ray(rayParams)
				if result.is_empty():
					continue
				if result.collider.has_method('take_dmg') and result.collider == body:
					body.take_dmg(damage)
		queue_free()
	
