extends Control

@onready var item_icon: TextureRect = $itemIcon
@onready var quantity: Label = $quantity

var slot_num: Vector2i
var item : Dictionary
var item_count = 0

func add_item(new_item):
	if item == {}:
		item = new_item
		item_count = 1
		item_icon.texture = item['inv_icon']
		refresh_labels()
		return true
	if (item_count !=0 and (item['name'] ==new_item['name']) and item_count<item['stack_amnt']):
		item_count +=1
		item = new_item
		item_icon.texture = item['inv_icon']
		refresh_labels()
		return true	
	return false
func refresh_labels():
	quantity.text = str(item_count)
