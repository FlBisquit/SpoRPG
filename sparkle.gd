extends CharacterBody3D

var speed = 50
var damage = 15
@onready var sound: AudioStreamPlayer3D = $sound

signal hit

func _ready() -> void:
	velocity = -transform.basis.z * speed
	sound.play()
func _physics_process(delta: float) -> void:
	var collision = move_and_collide(velocity * delta)
	if is_on_floor(): 
		queue_free()
	if collision:
		var body = collision.get_collider()
		if body.has_method('take_dmg'):
			body.take_dmg(damage)
			hit.emit()
		queue_free()
	
