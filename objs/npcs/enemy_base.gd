class_name BaseEnemy

extends CharacterBody3D

var last_attacker = null
@export var spawn_cords: Vector3
@export var min_speed:float = 3.0
@export var max_speed:float = 5.0
@export var current_hp: int = 75
@export var max_hp: int = 75
@export var damage: int = 15
@export var xp_reward: int = 100
var target = null
var target_chase:bool = false
var attack_speed = Timer.new()
var attack_cooldown = Timer.new()
var aggression_time = Timer.new()
var is_attacking: bool = false
var hp_tick:float = 0.0
var can_attack: bool = true
@onready var attack_area: Area3D = $attack_area

var die_effect = load("res://objs/effects/explossion_effect.tscn")

func _ready():
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

func take_dmg(damage, attacker):
	current_hp -= damage
	last_attacker = attacker
	target = attacker
	target_chase = true
	aggression_time.start()
	death()

func try_attack(body) -> void:
	if body.has_method("take_dmg"):
		body.take_dmg(damage, self)
	can_attack = false
	is_attacking = true
	attack_speed.start()
	attack_cooldown.start()

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
		var target_pos = target.global_position
		target_pos.y = global_position.y
		var distance = global_position.distance_to(target_pos)
		if distance > 3:
			var direction = (target_pos - global_position).normalized()
			velocity.x = direction.x * max_speed
			velocity.z = direction.z * max_speed
			rotation.y = atan2(direction.x, direction.z)
		else:
			velocity.x = 0
			velocity.z = 0
			if can_attack:
				for body in attack_area.get_overlapping_bodies():
					if body == self:
						continue
					if body.has_method("take_dmg"):
						try_attack(body)
						break
	else:
		if spawn_cords != Vector3.ZERO:
			var direction = (spawn_cords - global_position).normalized()
			velocity.x = direction.x * min_speed
			velocity.z = direction.z * min_speed
			rotation.y = atan2(direction.x, direction.z)

	move_and_slide()
func _process(delta: float) -> void:	
	hp_tick += delta
	if hp_tick >= 1.0:
		hp_tick = 0.0
		if current_hp < max_hp:
			current_hp += 1
	
