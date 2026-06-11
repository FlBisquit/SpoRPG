extends BaseSpell

@onready var sound: AudioStreamPlayer3D = $sound
func _init() -> void:
	speed = 50
	damage = 15
	spell_name = 'sparkle'
func on_ready() -> void:
	sound.play()
	
