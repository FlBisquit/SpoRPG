extends Control
signal spell_dropped(slot_index: int, spell_name: String)
signal spell_unequipped(slot_index: int)
var hand: Control
var inventory: Control

func _get_hand():
	if not hand:
		hand = get_tree().get_first_node_in_group("hand")
	return hand

func _get_inventory():
	if not inventory:
		inventory = get_tree().get_first_node_in_group("inventory")
	return inventory
	
@onready var item_icon: TextureRect = $item_icon

var item_type = "spell"
var spell_slot_num: Vector2i
var slot_index: int = 0
var spell : Dictionary
var mana_cost_text: String
var cooldown_text: String
@onready var manacost_text: Label = $manacost_text
@onready var cooldown: Label = $cooldown

func add_spell(new_spell):
	if spell.is_empty():
		spell = new_spell
		refresh_labels()
		return true
	if spell['name'] == new_spell['name']:
		refresh_labels()
		return true
	return false

func refresh_labels():
	pass
	
	
func try_receive(incoming_item, count) -> bool:
	if incoming_item.get("type") != "Spell":
		return false
	if not spell.is_empty():
		return false
	spell = incoming_item
	item_icon.texture = spell["inv_icon"]
	spell_dropped.emit(slot_index, spell["spell_name"])
	return true

func _on_button_mouse_entered() -> void:
	_get_inventory().hovered_slot = self


func _on_button_button_down() -> void:
	if _get_hand().is_empty() and not spell.is_empty():
		_get_hand().start_drag(spell, 1)
		spell = {}
		item_icon.texture = null
		spell_unequipped.emit(slot_index)

func _on_button_mouse_exited() -> void:
	if _get_inventory().hovered_slot == self:
		_get_inventory().hovered_slot = null
