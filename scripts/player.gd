extends CharacterBody3D

signal equipped_spells_changed(spells: Array)

@export var player_name = "Player"

var stats: Dictionary = {
	"speed": 1.0,
	"damage": 1.0,
	"cooldown": 1.0,
	"mana_regen": 1.0,
	"stamina_regen": 1.0
}

@export var level = 1
@export var current_xp = 0
@export var xp_to_next_lvl = 100
@export var skill_point_per_lvl = 2
@export var current_skill_points = 2     

var max_stamina = 2
var current_stamina = 2
var stamina_regen = 0.5

var damage_multi = 1

var barrier = 1

var cooldowns: Dictionary = {}
var current_mana = 200
var max_mana = 200
var mana_regen = 5.0
const JUMP_VELOCITY = 6.0
var double_jump = true

var max_speed = 7.0
var accelaration = 0.1

var hp = 100
var max_hp = 100

var center: Vector2

var dash_speed = 20.0
var dash_time = 0.15
var is_dashing = false
var dash_timer = 0.0
var dash_direction = Vector3.ZERO
var friction = 20.0

@onready var spell_choise_menu: Control = $CanvasLayer/SpellChoiseMenu
@onready var inventory: Control = $CanvasLayer/Inventory

@onready var camera_pivot: Node3D = $CameraPivot
@onready var camera_3d: Camera3D = $CameraPivot/Camera3D
@onready var pos = $stuff/cast_pos
@onready var hitmarker: AudioStreamPlayer3D = $hitmarker
@onready var mana_counter: Label = $CanvasLayer/powersInterface/mana_counter
@onready var stamina_counter: Label = $CanvasLayer/powersInterface/stamina_counter



func gain_xp(amount):
	current_xp += amount
	if current_xp >= xp_to_next_lvl:
		level_up()

func level_up():
	current_xp = 0
	level +=1
	xp_to_next_lvl =int(xp_to_next_lvl * 1.5)
	current_skill_points += skill_point_per_lvl
	max_hp +=10
	hp = max_hp
	max_mana += 10
	
var equipped_spells: Array = ['sparkle', 'haste']
var spells = {"fireball": "res://objs/spells/fireball.tscn",
	"sparkle":"res://objs/spells/sparkle.tscn",
	"haste": "res://objs/spells/haste.tscn"
}
func apply_upgrade(stat: String, value: float) -> void:
	match stat:
		"max_stamina":
			max_stamina += value
		"max_mana":
			max_mana += value
			current_mana = max_mana
		"max_hp":
			max_hp += value
			hp = max_hp
		"mana_regen":
			mana_regen += value
		"stamina_regen":
			stamina_regen += value
		"damage_multi":
			damage_multi += value
var current_spell_name = "sparkle"
var current_spell = load(spells["sparkle"])

func _on_fireball() -> void:
	current_spell = load(spells["fireball"])
	current_spell_name = "fireball"

func _on_sparkle() -> void:
	current_spell = load(spells["sparkle"])
	current_spell_name = "sparkle"


func _on_haste() -> void:
	current_spell = load(spells["haste"])
	current_spell_name = "haste"


var MOUSE_SENSITIVITY: float = 0.003


func take_dmg(damage, caster) -> void:
	if caster == self:
		return
	if is_multiplayer_authority():
		hp -= damage - barrier
	else:
		receive_damage.rpc_id(get_multiplayer_authority(), damage)

@rpc("authority", "call_local", "reliable")
func receive_damage(damage: int) -> void:
	hp -= damage - barrier

func _input(event: InputEvent) -> void:
	if not is_multiplayer_authority():
		return
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		return
	if event is InputEventMouseMotion:
		rotation.y -= event.relative.x * MOUSE_SENSITIVITY

func _ready() -> void:
	if not is_multiplayer_authority():
		camera_3d.current = false
		$CanvasLayer.visible = false
		set_physics_process(false)
		set_process_input(false)
		return
	load_player()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	center = get_viewport().get_visible_rect().size * 0.5
	inventory.spell_equipped.connect(_on_spell_equipped)
	inventory.spell_unequipped.connect(_on_spell_unequipped)
	spell_choise_menu.spell_chosen.connect(_on_spell_chosen)
	spell_choise_menu.init(self)


func save_player() -> void:
	var save = PlayerSave.new()
	save.player_name = player_name
	save.level = level
	save.current_xp = current_xp
	save.xp_to_next_lvl = xp_to_next_lvl
	save.hp = hp
	save.max_hp = max_hp
	save.current_mana = current_mana
	save.max_mana = max_mana
	save.equipped_spells = equipped_spells.duplicate()
	save.skill_points = current_skill_points
	save.max_stamina = max_stamina
	save.damage_multi = damage_multi
	save.barrier = barrier
	ResourceSaver.save(save, "user://player_save.tres")

func load_player() -> void:
	if not ResourceLoader.exists("user://player_save.tres"):
		return
	var save = ResourceLoader.load("user://player_save.tres") as PlayerSave
	player_name = save.player_name
	level = save.level
	current_xp = save.current_xp
	xp_to_next_lvl = save.xp_to_next_lvl
	hp = save.hp
	max_hp = save.max_hp
	current_mana = save.current_mana
	max_mana = save.max_mana
	equipped_spells = save.equipped_spells.duplicate()
	current_skill_points = save.skill_points
	max_stamina = save.max_stamina
	damage_multi = save.damage_multi
	barrier = save.barrier

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		if is_multiplayer_authority():
			save_player()


func _on_spell_chosen(spell_name: String) -> void:
	if spell_name in spells:
		current_spell = load(spells[spell_name])
		current_spell_name = spell_name

func _on_spell_unequipped(slot_index: int) -> void:
	if slot_index < equipped_spells.size():
		equipped_spells.remove_at(slot_index)
	equipped_spells_changed.emit(equipped_spells)	

func _on_spell_equipped(slot_index: int, spell_name: String) -> void:
	if slot_index < equipped_spells.size():
		equipped_spells[slot_index] = spell_name
	else:
		equipped_spells.append(spell_name)
	equipped_spells_changed.emit(equipped_spells)

@rpc("authority", "call_local", "reliable")
func spawn_projectile(spell_name: String, spawn_pos: Vector3, shoot_dir: Vector3, caster_name_arg: String) -> void:
	var instance = load(spells[spell_name]).instantiate()
	instance.caster = self
	instance.caster_name = caster_name_arg
	instance.damage_multi = damage_multi
	instance.position = spawn_pos
	instance.scale = Vector3.ONE
	instance.shoot_direction = shoot_dir
	get_parent().add_child(instance)
	instance.global_position = spawn_pos
func cast() -> void:
	if current_spell == null or current_spell_name == "":
		return
	var viewport_center = get_viewport().get_visible_rect().size * 0.5
	var from = camera_3d.project_ray_origin(viewport_center)
	var dir = camera_3d.project_ray_normal(viewport_center)
	var space = get_world_3d().direct_space_state
	var ray = PhysicsRayQueryParameters3D.create(from, from + dir * 1000)
	ray.exclude = [self]
	var result = space.intersect_ray(ray)
	var aim_point = result.get("position", from + dir * 1000)
	if cooldowns.get(current_spell_name, 0.0) > 0:
		return
	if current_spell_name not in equipped_spells:
		return
	var instance = current_spell.instantiate()
	var cost = instance.mana_cost
	var cooldown_time = instance.cooldown
	var is_proj = instance.is_projectile
	instance.free()
	if current_mana < cost:
		return
	current_mana -= cost
	cooldowns[current_spell_name] = cooldown_time * stats.get("cooldown", 1.0)
	if is_proj:
		var shoot_dir = (aim_point - camera_3d.global_position).normalized()
		var spawn_pos = pos.global_position
		spawn_projectile.rpc(current_spell_name, spawn_pos, shoot_dir, player_name)
	else:
		var buff = current_spell.instantiate()
		buff.activate(self)
		buff.free()

func dash():
	if Input.is_action_just_pressed("dash") and !is_dashing and current_stamina>=1:
		current_stamina-=1
		is_dashing = true
		dash_timer = dash_time
		var input_dir := Input.get_vector("left", "right", "forward", "backward")
		var direction := (transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)).normalized()
		if direction == Vector3.ZERO:
			direction = -transform.basis.z
		dash_direction = direction

func show_inventory() -> void:
	if Input.is_action_just_pressed("inventory") and inventory.visible == false:
		inventory.visible = true
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	elif Input.is_action_just_pressed("inventory") and inventory.visible == true:
		inventory.visible = false
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func show_spell_choice_menu() -> void:
		if Input.is_action_just_pressed("spell_menu") and $CanvasLayer/SpellChoiseMenu.visible == false:
			$CanvasLayer/SpellChoiseMenu.show()
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		elif Input.is_action_just_released("spell_menu") and $CanvasLayer/SpellChoiseMenu.visible == true: 
			current_spell = load(spells[$CanvasLayer/SpellChoiseMenu.Close()])
			current_spell_name = $CanvasLayer/SpellChoiseMenu.Close()
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func speed(delta: float) -> void:
	var xz_velocity = Vector2(velocity.x, velocity.z)
	if xz_velocity.length() > max_speed:
		xz_velocity = xz_velocity.move_toward(xz_velocity.normalized() * max_speed, friction * delta)
		velocity.x = xz_velocity.x
		velocity.z = xz_velocity.y

func active_camera() -> void:
	var speed_mod = stats.get("speed", 1.0)
	var speed_ = velocity.length()
	var t = clamp(speed_ / dash_speed, 0.0, 1.0)
	var target_fov = lerp(75.0, 95.0, t)
	camera_3d.fov = lerp(camera_3d.fov, target_fov, t)

func handle_movement(delta: float) -> void:
	var speed_mod = stats.get("speed", 1.0)
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)).normalized()
	if direction:
		velocity.x = move_toward(velocity.x, direction.x * max_speed * speed_mod, accelaration * 2 * speed_mod)
		velocity.z = move_toward(velocity.z, direction.z * max_speed * speed_mod, accelaration * 2 * speed_mod)
	else:
		velocity.x = move_toward(velocity.x, 0.0, max_speed)
		velocity.z = move_toward(velocity.z, 0.0, max_speed)
func handle_jump() -> void:
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	elif Input.is_action_just_pressed("jump") and not is_on_floor() and double_jump:
		double_jump = false
		velocity.y = JUMP_VELOCITY
func apply_buff(stat: String, multiplier: float, duration: float) -> void:
	var base = stats.get(stat, 1.0)
	stats[stat] = base * multiplier
	await get_tree().create_timer(duration).timeout
	stats[stat] = base


func _physics_process(delta: float) -> void:
	if current_spell_name not in equipped_spells:
		if equipped_spells.is_empty():
			current_spell = null
			current_spell_name = ""
		else:
			current_spell_name = equipped_spells[0]
			current_spell = load(spells[current_spell_name])
	speed(delta)
	dash()
	show_inventory()
	show_spell_choice_menu()
	current_mana = min(current_mana + mana_regen * stats.get("mana_regen", 1.0) * delta, max_mana)
	mana_counter.text = str(int(current_mana))
	
	current_stamina = min(current_stamina + stamina_regen * stats.get("stamina_regen", 1.0) * delta, max_stamina)
	stamina_counter.text = str(int(current_stamina))
	

	for key in cooldowns:
		cooldowns[key] = max(0.0, cooldowns[key] - delta)
	if is_on_floor():
		double_jump = true
	if not is_on_floor():
		velocity += 1.9 * get_gravity() * delta
	handle_movement(delta)
	handle_jump()
	
	if is_dashing:
		velocity.x = dash_direction.x * dash_speed
		velocity.z = dash_direction.z * dash_speed
		dash_timer -= delta
		if dash_timer <= 0:
			is_dashing = false

	if Input.is_action_just_pressed('m1') and current_mana > 0 and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		cast()

	active_camera()
	move_and_slide()
