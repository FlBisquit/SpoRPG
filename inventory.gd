extends Control

const ITEM_SLOT = preload("res://images/interface/spell_slot.tscn")

var rows = 6
var collumns = 7

var items = []

func _ready() -> void:
	for x in range(collumns):
		items.append([])
		for y in range(rows):
			items[x].append([])
