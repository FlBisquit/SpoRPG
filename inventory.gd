extends Control

signal spell_equipped(slot_index: int, spell_name: String)
signal spell_unequipped(slot_index: int)

const ITEM_SLOT = preload("res://images/interface/item_slot.tscn")
const SPELL_SLOT = preload("res://images/interface/spell_slot.tscn")
@onready var container: Container = $inventoryView/Container
@onready var spell_container: Container = $inventoryView/spell_container
@onready var inventory_view: Control = $inventoryView
@onready var powering_view: Control = $powering_view
@onready var hand: Control = $"../Hand"
@onready var player = owner


enum Chapter {INVENTORY, IMPROVEMENT}
var current_chapter: Chapter = Chapter.INVENTORY

var rows = 4
var collumns = 4
var max_spell_slots = 4
var spell_slots = []
var hovered_slot = null
var items = []
func update_view() -> void:
	match current_chapter:
		Chapter.INVENTORY:
			inventory_view.visible = true
			powering_view.visible = false
		Chapter.IMPROVEMENT:
			inventory_view.visible = false
			powering_view.visible = true

			inventory_view.visible = false
func _ready() -> void:
	for x in range(collumns):
		items.append([])
		for y in range(rows):
			items[x].append([])
			var instance = ITEM_SLOT.instantiate()
			instance.global_position = Vector2(x*120, y*120)
			instance.slot_num = Vector2i(x,y)
			container.add_child(instance)
			items[x][y] = instance
	for i in range(max_spell_slots):
		var slot = SPELL_SLOT.instantiate()
		slot.global_position = Vector2(i * 120, 0)
		slot.slot_index = i
		slot.spell_dropped.connect(_on_spell_dropped_in_slot)
		slot.spell_unequipped.connect(_on_spell_unequipped_from_slot)
		spell_container.add_child(slot)
		spell_slots.append(slot)
func _on_spell_unequipped_from_slot(slot_index: int) -> void:
	spell_unequipped.emit(slot_index)

func _on_spell_dropped_in_slot(slot_index: int, spell_name: String) -> void:
	spell_equipped.emit(slot_index, spell_name)

func _process(delta: float) -> void:
	if Input.is_action_just_released('m1') and hand.dragging:
		if hovered_slot != null:
			var received = hovered_slot.try_receive(hand.item, hand.item_count)
			if received:
				hand.clear()
			else:
				hand.drop_item()
		else:
			hand.drop_item()	

func prep_item(new_item) -> Dictionary:
	return prep_item_from_res(new_item.item_res)
func prep_item_from_res(res: Item) -> Dictionary:
	return {
		"name": res.name,
		"type": res.type,
		"inv_icon": res.inv_icon,
		"item_path": res.item_path,
		"stack_amnt": res.stack_amnt,
		"spell_name": res.get("spell_name")
	}

func add_item(item):
	for x in range(collumns):
		for y in range(rows):
			var slot = items[x][y]
			if slot.add_item(item):
				return true
	return false
func remove_item(slot_num):
	var slot = items[slot_num.x][slot_num.y]
	if slot.item.is_empty():
		return
	if not hand.item.is_empty():
		return
	hand.start_drag(slot.item, slot.item_count)
	slot.item_count = 0
	slot.item = {}
	slot.item_icon.texture = null
	slot.refresh_labels()

func _on_level_up_btn_pressed() -> void:
	current_chapter = Chapter.IMPROVEMENT
	update_view()
func _on_items_btn_pressed() -> void:
	current_chapter = Chapter.INVENTORY
	update_view()
