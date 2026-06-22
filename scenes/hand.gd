extends Control
@onready var item_icon: TextureRect = $Item_Icon
@onready var stuff: MeshInstance3D = $"../../stuff"

var item: Dictionary
var item_count = 0
var dragging = false

func _process(delta: float) -> void:
	global_position = get_global_mouse_position()

func start_drag(new_item, count):
	item = new_item
	item_count = count
	item_icon.texture = item['inv_icon']
	dragging = true

func is_empty() -> bool:
	return item.is_empty()

func drop_item():
	if not item.is_empty():
		for i in item_count:
			var instance = load(item['item_path']).instantiate()
			instance.global_position = stuff.global_position
			get_parent().add_child(instance)
	clear()
	
func clear():
	item_icon.texture = null
	item = {}
	item_count = 0
	dragging = false
