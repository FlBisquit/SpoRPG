extends BaseProjectile

func on_ready() -> void:
	speed = 20
	mana_cost = 30

func on_hit(collision) -> void:
	var body = collision.get_collider()
	if body.has_method("apply_speed_buff"):
		body.apply_speed_buff(2.0, 5.0)
	queue_free()
