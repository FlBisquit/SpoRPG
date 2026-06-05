extends CharacterBody3D


var mana_pool = 200
var max_mana = 200

const JUMP_VELOCITY = 6.0
var double_jump = true

var max_speed = 7.0
var accelaration = 0.1

var hp = 100
var max_hp = 100

var dash_speed = 20.0
var dash_time = 0.15
var is_dashing = false
var dash_timer = 0.0
var dash_direction = Vector3.ZERO
var friction = 20.0

@onready var spell_choise_menu: Control = $CanvasLayer/SpellChoiseMenu
@onready var camera_pivot: Node3D = $CameraPivot
@onready var camera_3d: Camera3D = $CameraPivot/Camera3D
@onready var pos = $stuff/cast_pos
@onready var hitmarker: AudioStreamPlayer3D = $hitmarker

var spells = {"fireball": "res://objs/spells/fireball.tscn",
	"sparkle":"res://objs/spells/sparkle.tscn"
}

var spell = load(spells["fireball"])

func _on_fireball() -> void:
	spell = load(spells["fireball"])

func _on_sparkle() -> void:
	spell = load(spells["sparkle"])

var MOUSE_SENSITIVITY: float = 0.003


func take_dmg(damage):
	hp -= damage

func _input(event: InputEvent) -> void:
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		return
	if event is InputEventMouseMotion:
		rotation.y -= event.relative.x * MOUSE_SENSITIVITY

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	spell_choise_menu.fireball.connect(_on_fireball)
	spell_choise_menu.sparkle.connect(_on_sparkle)
func cast() -> void:
	var instance = spell.instantiate()
	instance.position = pos.global_position
	instance.transform.basis = pos.global_transform.basis
	instance.scale = Vector3.ONE
	#instance.hit.connect(hitmarker.play)
	get_parent().add_child(instance)

func dash():
	if Input.is_action_just_pressed("dash") and !is_dashing:
		is_dashing = true
		dash_timer = dash_time
		var input_dir := Input.get_vector("left", "right", "forward", "backward")
		var direction := (transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)).normalized()
		if direction == Vector3.ZERO:
			direction = -transform.basis.z
		dash_direction = direction

func speed(delta: float) -> void:
	var xz_velocity = Vector2(velocity.x, velocity.z)
	if xz_velocity.length() > max_speed:
		xz_velocity = xz_velocity.move_toward(xz_velocity.normalized() * max_speed, friction * delta)
		velocity.x = xz_velocity.x
		velocity.z = xz_velocity.y

func active_camera() -> void:
	var speed_ = velocity.length()
	var t = clamp(speed_ / dash_speed, 0.0, 1.0)
	var target_fov = lerp(75.0, 95.0, t)
	camera_3d.fov = lerp(camera_3d.fov, target_fov, t)


func _physics_process(delta: float) -> void:
	speed(delta)
	dash()

	if is_on_floor():
		double_jump = true
	if not is_on_floor():
		velocity += 1.9 * get_gravity() * delta

	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)).normalized()

	if direction:
		velocity.x = move_toward(velocity.x, direction.x * max_speed, accelaration * 2)
		velocity.z = move_toward(velocity.z, direction.z * max_speed, accelaration * 2)
	else:
		velocity.x = move_toward(velocity.x, 0.0, max_speed)
		velocity.z = move_toward(velocity.z, 0.0, max_speed)

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	elif Input.is_action_just_pressed("jump") and not is_on_floor() and double_jump:
		double_jump = false
		velocity.y = JUMP_VELOCITY

	if is_dashing:
		velocity.x = dash_direction.x * dash_speed
		velocity.z = dash_direction.z * dash_speed
		dash_timer -= delta
		if dash_timer <= 0:
			is_dashing = false

	if Input.is_action_just_pressed('m1') and mana_pool > 0 and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		cast()

	active_camera()
	move_and_slide()
