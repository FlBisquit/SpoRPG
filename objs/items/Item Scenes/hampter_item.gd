extends Control

@export var item_res:Item

@onready var inventory: Control = $"../Inventory"


func _on_timer_timeout() -> void:
	$Button.disabled = false

func _on_button_pressed() -> void:
	if inventory.add_item(inventory.prep_item(self)):
		queue_free()
