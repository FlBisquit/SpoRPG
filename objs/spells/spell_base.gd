class_name BaseSpell
extends CharacterBody3D

var caster = null
var spell_name: String = ""
var mana_cost = 15
var is_projectile = true

var speed = 50
var damage = 10
var lifetime = 2.0
var current_lifetime = 0.0
signal hit
var cooldown = 1.5
func _ready() -> void:
	if is_projectile:
		velocity = -transform.basis.z * speed
	on_ready()

func on_ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	if not is_projectile:
		return
	current_lifetime += delta
	if current_lifetime >= lifetime:
		queue_free()
		return
	before_move(delta)
	var collision = move_and_collide(velocity * delta)
	if collision or is_on_floor():
		on_hit(collision)
		queue_free()

func before_move(_delta: float) -> void:
	pass

func on_hit(collision) -> void:
	if collision:
		var body = collision.get_collider()
		if body.has_method("take_dmg"):
			body.take_dmg(damage)
			hit.emit()

func activate(who) -> void:
	caster = who
	on_activate()
	queue_free()

func on_activate() -> void:
	pass
