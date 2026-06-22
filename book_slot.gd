extends Control

signal item_equipped(item: Dictionary)
signal item_unequipped()

@export var allowed_type: String = "Book"

@onready var hand: Control = get_node("/root/Main/Player/CanvasLayer/Hand")
@onready var inventory: Control = get_node("/root/Main/Player/CanvasLayer/Inventory")
@onready var item_icon: TextureRect = $itemIcon

var item: Dictionary = {}

func try_receive(incoming_item, count) -> bool:
	if incoming_item.get("type") != allowed_type:
		return false
	if not item.is_empty():
		hand.start_drag(item, 1)
	item = incoming_item
	item_icon.texture = item["inv_icon"]
	item_equipped.emit(item)
	return true

func _on_button_mouse_entered() -> void:
	inventory.hovered_slot = self

func _on_button_mouse_exited() -> void:
	if inventory.hovered_slot == self:
		inventory.hovered_slot = null

func _on_button_button_down() -> void:
	if hand.is_empty() and not item.is_empty():
		hand.start_drag(item, 1)
		item = {}
		item_icon.texture = null
		item_unequipped.emit()
