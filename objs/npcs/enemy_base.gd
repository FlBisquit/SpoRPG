class_name BaseEnemy
extends CharacterBody3D

var last_attacker = null
@export var spawn_cords: Vector3
@export var min_speed: float = 3.0
@export var max_speed: float = 5.0
@export var current_hp: int = 75
@export var max_hp: int = 75
@export var damage: int = 15
@export var xp_reward: int = 100
@export var attack_range: float = 3.0

var wander_target: Vector3 = Vector3.ZERO
var wander_timer: float = 0.0

var target = null
var target_chase: bool = false
var attack_speed = Timer.new()
var attack_cooldown = Timer.new()
var aggression_time = Timer.new()
var is_attacking: bool = false
var hp_tick: float = 0.0
var can_attack: bool = true

@onready var attack_area: Area3D = $attack_area
var die_effect = load("res://objs/effects/explossion_effect.tscn")

func _ready():
	await get_tree().process_frame
	spawn_cords = global_position
	spawn_cords = global_position
	add_child(attack_speed)
	attack_speed.wait_time = 2.0
	attack_speed.one_shot = true
	attack_speed.timeout.connect(_on_attack_speed_timeout)
	add_child(attack_cooldown)
	attack_cooldown.wait_time = 5.0
	attack_cooldown.one_shot = true
	attack_cooldown.timeout.connect(_on_attack_cooldown_timeout)
	add_child(aggression_time)
	aggression_time.wait_time = 5.0
	aggression_time.one_shot = true
	aggression_time.timeout.connect(_on_aggression_timeout)

func take_dmg(dmg, attacker):
	current_hp -= dmg
	last_attacker = attacker
	target = attacker
	target_chase = true
	aggression_time.start()
	death()

func try_attack(body) -> void:
	can_attack = false
	is_attacking = true
	attack_speed.wait_time = 1.5
	attack_speed.start()
	attack_cooldown.start()
	await attack_speed.timeout
	if body and is_instance_valid(body) and body.has_method("take_dmg"):
		if multiplayer.is_server():
			body.take_dmg(damage, self)
	attack_speed.wait_time = 0.5
	attack_speed.start()

func get_move_target_pos() -> Vector3:
	return target.global_position

func should_retreat(distance: float) -> bool:
	return false

func get_retreat_direction(target_pos: Vector3) -> Vector3:
	return Vector3.ZERO

func _on_attack_cooldown_timeout():
	can_attack = true

func _on_attack_speed_timeout():
	is_attacking = false

func _on_aggression_timeout():
	target_chase = false
	target = null

func death() -> void:
	if current_hp > 0:
		return
	if last_attacker and last_attacker.has_method("gain_xp"):
		last_attacker.gain_xp(xp_reward)
	var instance = die_effect.instantiate()
	get_parent().add_child(instance)
	instance.global_transform = global_transform
	instance.explode()
	queue_free()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= 9.8 * delta

	if is_attacking:
		velocity.x = 0
		velocity.z = 0
	elif target_chase and target != null and is_instance_valid(target):
		var target_pos = get_move_target_pos()
		target_pos.y = global_position.y
		var distance = global_position.distance_to(target_pos)
		var direction = (target_pos - global_position).normalized()
		var target_angle = atan2(direction.x, direction.z)

		if should_retreat(distance):
			var retreat = get_retreat_direction(target_pos)
			velocity.x = retreat.x * max_speed
			velocity.z = retreat.z * max_speed
			rotation.y = lerp_angle(rotation.y, target_angle, 5.0 * delta)
		elif distance > attack_range:
			velocity.x = direction.x * max_speed
			velocity.z = direction.z * max_speed
			rotation.y = lerp_angle(rotation.y, target_angle, 5.0 * delta)
		else:
			velocity.x = 0
			velocity.z = 0
			rotation.y = lerp_angle(rotation.y, target_angle, 5.0 * delta)
			if can_attack:
				for body in attack_area.get_overlapping_bodies():
					if body == self:
						continue
					if body.has_method("take_dmg"):
						try_attack(body)
						break
	else:
		wander_timer -= delta
		if wander_timer <= 0:
			wander_timer = randf_range(3.0, 7.0)
			wander_target = spawn_cords + Vector3(randf_range(-5, 5), 0, randf_range(-5, 5))
		if wander_target != Vector3.ZERO:
			var dir = (wander_target - global_position).normalized()
			var dist = global_position.distance_to(wander_target)
			if dist > 0.5:
				velocity.x = dir.x * min_speed
				velocity.z = dir.z * min_speed
				rotation.y = lerp_angle(rotation.y, atan2(dir.x, dir.z), 3.0 * delta)
			else:
				velocity.x = 0
				velocity.z = 0
	move_and_slide()

func _process(delta: float) -> void:
	hp_tick += delta
	if hp_tick >= 1.0:
		hp_tick = 0.0
		if current_hp < max_hp:
			current_hp += 1
