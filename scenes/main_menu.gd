extends Node3D

signal hosted()
signal joined()

@export var speed: float = 3
var progress: float = 0.0
var is_moving: bool = false
var direction: float = 1.0
var current_scene: Current_scene = Current_scene.Main_ui

enum Current_scene {Main_ui, Settings_ui, Servers_ui}

@onready var join_ui: Control = $join_ui
@onready var main_ui: Control = $main_ui
@onready var path_follow_3d: PathFollow3D = $Path3D/PathFollow3D

func _process(delta):
	if is_moving:
		progress += delta * speed * direction
		progress = clamp(progress, 0.0, 1.0)
		path_follow_3d.progress_ratio = progress
	if progress >= 1.0 or progress <= 0.0:
		is_moving = false

func _on_start_pressed() -> void:
	direction = 1.0
	is_moving = true
	current_scene = Current_scene.Servers_ui
	join_ui.visible = true
	main_ui.visible = false

func _on_settings_pressed() -> void:
	current_scene = Current_scene.Settings_ui

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_host_pressed() -> void:
	print("host pressed")
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(7777, 32)
	multiplayer.multiplayer_peer = peer
	get_tree().change_scene_to_file("res://scenes/main.scn")

func _on_join_pressed() -> void:
	print("join pressed")
	var peer = ENetMultiplayerPeer.new()
	var err = peer.create_client("127.0.0.1", 7777)
	print("client error: ", err)
	multiplayer.multiplayer_peer = peer
	
	multiplayer.connected_to_server.connect(func():
		print("connected to server!")
		get_tree().change_scene_to_file("res://scenes/main.scn")
	)
	multiplayer.connection_failed.connect(func():
		print("connection failed!")
		multiplayer.multiplayer_peer = null
	)

func _on_back_to_menu_pressed() -> void:
	direction = -1.0
	is_moving = true
	current_scene = Current_scene.Main_ui
	join_ui.visible = false
	main_ui.visible = true
