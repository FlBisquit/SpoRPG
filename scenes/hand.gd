extends Control
@onready var item_icon: TextureRect = $Item_Icon
@onready var stuff: MeshInstance3D = $"../../stuff"

var item: Dictionary
var item_count = 0
var dragging = false
func _ready() -> void:
	add_to_group("hand")
func _process(delta: float) -> void:
	global_position = get_global_mouse_position()

func start_drag(new_item, count):
	item = new_item
	item_count = count
	item_icon.texture = item['inv_icon']
	dragging = true

func is_empty() -> bool:
	return item.is_empty()

@rpc("call_local", "reliable")
func spawn_dropped_item(item_path: String, pos: Vector3):
	var instance = load(item_path).instantiate()
	instance.global_position = pos
	get_parent().add_child(instance)

func drop_item():
	if not item.is_empty():
		for i in range(item_count):
			spawn_dropped_item.rpc(item["item_path"], stuff.global_position)

	clear()
	
func clear():
	item_icon.texture = null
	item = {}
	item_count = 0
	dragging = false
