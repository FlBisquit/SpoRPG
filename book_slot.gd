extends Control

signal item_equipped(item: Dictionary)
signal item_unequipped()

@export var allowed_type: String = "Book"
@onready var item_icon: TextureRect = $itemIcon

var item: Dictionary = {}
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

func _on_button_mouse_entered() -> void:
	_get_inventory().hovered_slot = self

func _on_button_mouse_exited() -> void:
	if _get_inventory().hovered_slot == self:
		_get_inventory().hovered_slot = null

func _on_button_button_down() -> void:
	if _get_hand().is_empty() and not item.is_empty():
		_get_hand().start_drag(item, 1)
		item = {}
		item_icon.texture = null
		item_unequipped.emit()

func try_receive(incoming_item, count) -> bool:
	if incoming_item.get("type") != allowed_type:
		return false
	if not item.is_empty():
		_get_hand().start_drag(item, 1)
	item = incoming_item
	item_icon.texture = item["inv_icon"]
	item_equipped.emit(item)
	return true
