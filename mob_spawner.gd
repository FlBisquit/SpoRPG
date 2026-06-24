extends Node3D

@export var mob_path: String
@export var respawn_time: float
@export var max_spawnables: int
@export var avaible_to_spawn: bool = true

var spawned_mobs: Array = []
var mob_scene: PackedScene

func _ready() -> void:
	if not multiplayer.is_server():
		return
	if mob_path != "":
		mob_scene = load(mob_path)
	_spawn_wave()

func _spawn_wave() -> void:
	if not avaible_to_spawn:
		return
	if not multiplayer.is_server():
		return
	spawned_mobs = spawned_mobs.filter(func(m): return is_instance_valid(m))
	var to_spawn = max_spawnables - spawned_mobs.size()
	for i in range(to_spawn):
		_spawn_mob()

func _spawn_mob() -> void:
	if mob_scene == null:
		return
	var mob = mob_scene.instantiate()
	mob.position = global_position
	get_parent().add_child.call_deferred(mob)
	spawned_mobs.append(mob)
	mob.tree_exited.connect(_on_mob_died)

func _on_mob_died() -> void:
	if not multiplayer.is_server():
		return
	await get_tree().create_timer(respawn_time).timeout
	spawned_mobs = spawned_mobs.filter(func(m): return is_instance_valid(m))
	if spawned_mobs.size() < max_spawnables and avaible_to_spawn:
		_spawn_mob()
