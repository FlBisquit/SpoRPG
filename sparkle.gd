extends BaseProjectile

@onready var sound: AudioStreamPlayer3D = $sound

func on_ready() -> void:
	sound.play()
	speed = 50
	damage = 15
