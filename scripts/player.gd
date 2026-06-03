extends CharacterBody3D


const SPEED = 7.0
const JUMP_VELOCITY = 5.0 

var dash = true

var double_jump = true
@onready var camera_pivot: Node3D = $CameraPivot

func _physics_process(delta: float) -> void:
	if is_on_floor():
		double_jump = true
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	var input_dir := Input.get_vector("left","right","forward","backaward")
	var direction := (camera_pivot.basis * Vector3(input_dir.x, 0.0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0.0, SPEED)
		velocity.z  = move_toward(velocity.z, 0.0, SPEED)
		
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	elif Input.is_action_just_pressed("jump") and not is_on_floor() and double_jump:
		double_jump = false
		velocity.y = JUMP_VELOCITY
		print("double jump")
	move_and_slide()
