extends Node3D

@export var player_scene: PackedScene = preload("res://scenes/player.tscn")
@onready var players: Node3D = $Players

func _ready() -> void:
	print("main ready, id: ", multiplayer.get_unique_id())
	multiplayer.peer_connected.connect(spawn_player)
	spawn_player(multiplayer.get_unique_id())

func spawn_player(id: int) -> void:
	var player = player_scene.instantiate()
	player.name = str(id)
	player.position = Vector3(0, 1, 0)
	player.set_multiplayer_authority(id)
	players.add_child(player)
	
	if id == multiplayer.get_unique_id():
		player.get_node("CanvasLayer/SpellChoiseMenu").init(player)
		#player.get_node("CanvasLayer/Inventory").init(player)
