extends Node3D
@export var item_res: Item

var is_on_ground= false
var fall_speed = 4.0
var rotation_speed = 3.0
@onready var raycast: RayCast3D = $RayCast3D

func _physics_process(delta: float) -> void:
	if not is_on_ground:
		if raycast.is_colliding():
			is_on_ground = true
			raycast.enabled = false
		else:
			global_position.y -= fall_speed * delta
			
			
	rotate_y(rotation_speed*delta)
func pickup(picker: Node) -> void:
	var inv = picker.get_node("CanvasLayer/Inventory")
	if inv and inv.add_item(inv.prep_item_from_res(item_res)):
		queue_free()
