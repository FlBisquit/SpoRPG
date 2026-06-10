class_name BaseBuffSpell
extends Node3D

var mana_cost = 20
var caster = null
var is_projectile = false

func activate(who) -> void:
	caster = who
	on_activate()

func on_activate() -> void:
	pass
