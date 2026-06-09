class_name BaseBuffSpell
extends Node

var mana_cost = 20
var caster = null

func activate(who) ->void:
	caster = who
	apply_buff()

func apply_buff() -> void:
	pass
	
