extends Button
extends UpgradeButton

@export var stat: String = ""
@export var value: float = 1.0
@export var cost: int = 1

func _ready() -> void:
	toggle_mode = true
