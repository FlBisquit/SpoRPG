extends Node3D

const CHUNK_SIZE = 50.0
const DENSITY = 3
const VIEW_DISTANCE = 150.0

var chunks: Dictionary = {}
var player: Node3D
var grass_mesh: Mesh
const GRASS = preload("uid://cve53hpyy4c7e")

func _ready() -> void:
	player = get_parent()
	var grass_scene = load("res://objs/map/grass.glb")
	var temp = grass_scene.instantiate()
	var mesh_instance = temp.find_child("*", true, false) as MeshInstance3D
	grass_mesh = mesh_instance.mesh.duplicate()
	var mat = ShaderMaterial.new()
	mat.shader = GRASS
	grass_mesh.surface_set_material(0, mat)
	temp.free()
func _process(delta: float) -> void:
	var player_chunk = Vector2i(
		int(player.global_position.x / CHUNK_SIZE),
		int(player.global_position.z / CHUNK_SIZE)
	)
	update_chunks(player_chunk)

func update_chunks(center: Vector2i) -> void:
	var radius = int(VIEW_DISTANCE / CHUNK_SIZE)
	var needed = {}
	for x in range(center.x - radius, center.x + radius):
		for z in range(center.y - radius, center.y + radius):
			needed[Vector2i(x, z)] = true
			if not chunks.has(Vector2i(x, z)):
				spawn_chunk(Vector2i(x, z))
	for key in chunks.keys():
		if not needed.has(key) and chunks[key] != null:
			chunks[key].queue_free()
			chunks.erase(key)

func spawn_chunk(coord: Vector2i) -> void:
	chunks[coord] = null
	_spawn_chunk_async(coord)

func _spawn_chunk_async(coord: Vector2i) -> void:
	var space = get_world_3d().direct_space_state
	var mmi = MultiMeshInstance3D.new()
	var mm = MultiMesh.new()
	mm.mesh = grass_mesh
	mm.transform_format = MultiMesh.TRANSFORM_3D
	var count = int(CHUNK_SIZE * CHUNK_SIZE * DENSITY)
	mm.instance_count = count
	for i in count:
		var x = coord.x * CHUNK_SIZE + randf() * CHUNK_SIZE
		var z = coord.y * CHUNK_SIZE + randf() * CHUNK_SIZE
		var from = Vector3(x, 200.0, z)
		var to = Vector3(x, -200.0, z)
		var ray = PhysicsRayQueryParameters3D.create(from, to)
		ray.collision_mask = 2
		var result = space.intersect_ray(ray)
		if result.is_empty() or result["normal"].dot(Vector3.UP) < 0.7:
			mm.set_instance_transform(i, Transform3D().scaled(Vector3.ZERO))
		else:
			var t = Transform3D()
			t.origin = result["position"]
			mm.set_instance_transform(i, t)
		if i % 50 == 0:
			await get_tree().process_frame
	mmi.multimesh = mm
	get_tree().current_scene.add_child(mmi)
	chunks[coord] = mmi
