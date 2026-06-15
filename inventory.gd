extends Control

const ITEM_SLOT = preload("res://images/interface/item_slot.tscn")
const SPELL_SLOT = preload("res://images/interface/spell_slot.tscn")
@onready var container: Container = $Container

var rows = 7
var collumns = 4

var items = []

func _ready() -> void:
	for x in range(collumns):
		items.append([])
		for y in range(rows):
			items[x].append([])
			var instance = ITEM_SLOT.instantiate()
			instance.global_position = Vector2(x*150, y*150)
			instance.slot_num = Vector2i(x,y)
			container.add_child(instance)
			items[x][y] = instance

func prep_item(new_item):
	var item = {}
	item["name"] = new_item.item_res.name
	item["inv_icon"] = new_item.item_res.inv_icon
	item["item_path"] = new_item.item_res.item_path
	item["stack_amnt"] = new_item.item_res.stack_amnt
	return item

func add_item(item):
	for x in range(collumns):
		for y in range(rows):
			var slot = items[x][y]
			if slot.add_item(item):
				return true
	return false
