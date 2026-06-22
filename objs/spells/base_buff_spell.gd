class_name BaseBuffSpell
extends Node3D

var cooldown = 1.5
var mana_cost = 20
var caster = null
var caster_name: String = ""
var spell_name = ""
var is_projectile = false

func activate(who) -> void:
	caster = who
	on_activate()

func on_activate() -> void:
	pass
