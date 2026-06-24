extends Control

@onready var hand: Control = get_parent().get_parent().get_parent().get_parent().get_node("Hand")
@onready var inventory: Control = get_parent().get_parent().get_parent()
@onready var item_icon: TextureRect = $itemIcon
@onready var quantity: Label = $quantity
var slot_num: Vector2i
var item: Dictionary
var item_count = 0

func add_item(new_item):
	if item.is_empty():
		item = new_item
		item_count = 1
		item_icon.texture = item['inv_icon']
		refresh_labels()
		return true
	if item['name'] == new_item['name'] and item_count < item['stack_amnt']:
		item_count += 1
		item_icon.texture = item['inv_icon']
		refresh_labels()
		return true
	return false

func refresh_labels():
	if item_count > 1:
		quantity.text = str(item_count)
		quantity.visible = true
	else:
		quantity.visible = false

func try_receive(incoming_item, count) -> bool:
	var accepted = 0
	for i in count:
		if not add_item(incoming_item):
			break
		accepted += 1
	return accepted > 0

func _on_button_mouse_entered() -> void:
	inventory.hovered_slot = self

func _on_button_mouse_exited() -> void:
	if inventory.hovered_slot == self:
		inventory.hovered_slot = null

func _on_button_button_down() -> void:
	if hand.item.is_empty() and not item.is_empty():
		hand.start_drag(item, item_count)
		item = {}
		item_count = 0
		item_icon.texture = null
		refresh_labels()
