class_name RangeEnemy
extends BaseEnemy
@export var preferred_distance: float = 10.0
@export var too_close_distance: float = 0

func _ready():
	super._ready()
	min_speed = 0.0
	max_speed = 0.0
	attack_range = preferred_distance
