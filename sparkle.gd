extends CharacterBody3D

var speed = 50

func _ready() -> void:
	velocity = -transform.basis.z * speed

func _physics_process(delta: float) -> void:
	if is_on_floor():
		queue_free()
	if not is_on_floor():
		velocity += 0.2 * get_gravity() * delta
	move_and_slide()
