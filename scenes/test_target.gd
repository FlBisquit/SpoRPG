extends Node3D

var max_hp = 100
var hp = 100
var hp_tick = 0.0
@onready var hp_bar: Label3D = $hp_bar

var die_effect = load("res://objs/effects/explossion_effect.tscn")

func take_dmg(damage, caster):
	hp -= damage
func death() -> void:
	if hp > 0:
		return
	var instance = die_effect.instantiate()
	get_parent().add_child(instance)
	instance.global_transform = global_transform
	instance.explode()
	queue_free()

func _process(delta: float) -> void:
	death()
	hp_bar.text = "hp: %s" % hp
	hp_tick += delta
	if hp_tick >= 1.0:
		hp_tick = 0.0
		if hp < max_hp:
			hp += 1
