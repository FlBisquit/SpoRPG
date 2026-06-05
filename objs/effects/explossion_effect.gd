extends Node3D

@onready var smoke: GPUParticles3D = $smoke
@onready var explosion: GPUParticles3D = $explosion
@onready var debris: GPUParticles3D = $debris
@onready var explosion_sound: AudioStreamPlayer3D = $ExplosionSound

func explode():
	debris.emitting = true
	explosion.emitting = true
	smoke.emitting = true
	explosion_sound.play()
	await get_tree().create_timer(2.0).timeout
	queue_free()
